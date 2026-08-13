import io
import os
from fastapi import FastAPI, File, Form, Response, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
import keras
import numpy as np
from PIL import Image
import tensorflow as tf
import uvicorn


class FixedDense(keras.layers.Dense):

  def __init__(self, *args, quantization_config=None, **kwargs):
    super().__init__(*args, **kwargs)


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
STATIC_DIR = os.path.join(BASE_DIR, "static")
os.makedirs(STATIC_DIR, exist_ok=True)
app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")

POSSIBLE_MODEL_NAMES = [
    "model_daun_cabai.h5",
    "model_daun_cabai.keras",
    "model_daun_cabai.h5.h5",
]
model = None

for filename in POSSIBLE_MODEL_NAMES:
  full_path = os.path.join(BASE_DIR, filename)
  if os.path.exists(full_path):
    try:
      model = tf.keras.models.load_model(
          full_path, custom_objects={"Dense": FixedDense}, compile=False
      )
      print(f"[SUCCESS] Model dimuat: {filename}")
      break
    except Exception as e:
      print(f"[ERROR] Gagal memuat {filename}: {e}")

CLASS_NAMES = ["healthy", "leaf curl", "leaf spot", "whitefly", "yellowish"]

# State Global Sistem
flash_state = False
camera_mode = "predict"  # 'predict', 'cctv', 'off'
reset_state = False  # Trigger reboot ESP32
servo_state = {"base": 90, "shoulder": 90, "elbow": 90, "gripper": 90}

latest_frame_bytes = None
latest_prediksi = "Menunggu Kamera..."
latest_akurasi = "0.00%"
telemetry_data = {"temp": "--", "hum": "--", "dist": "--"}


@app.get("/", response_class=HTMLResponse)
def read_root():
  index_file = os.path.join(STATIC_DIR, "index.html")
  if os.path.exists(index_file):
    with open(index_file, "r", encoding="utf-8") as f:
      return f.read()
  return "<h1>Server Agri-Vision AI Aktif!</h1>"


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
  global latest_frame_bytes, latest_prediksi, latest_akurasi, flash_state, camera_mode, reset_state

  try:
    image_bytes = await file.read()

    do_reset = reset_state
    if reset_state:
      reset_state = False  # Reset flag otomatis setelah dikirim ke ESP32

    if camera_mode == "off":
      latest_frame_bytes = None
      return JSONResponse({
          "status": "success",
          "prediksi": "Kamera Nonaktif (OFF)",
          "akurasi": "N/A",
          "flash": flash_state,
          "mode": camera_mode,
          "reset": do_reset,
      })

    latest_frame_bytes = image_bytes

    if camera_mode == "predict" and model is not None:
      image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
      image_resized = image.resize((224, 224))
      img_array = np.array(image_resized, dtype=np.float32) / 255.0
      img_array = np.expand_dims(img_array, axis=0)

      predictions = model.predict(img_array, verbose=0)
      predicted_index = int(np.argmax(predictions[0]))
      latest_prediksi = CLASS_NAMES[predicted_index]
      confidence = float(np.max(predictions[0])) * 100
      latest_akurasi = f"{confidence:.2f}%"
    elif camera_mode == "cctv":
      latest_prediksi = "Mode CCTV (Robot Arm Active)"
      latest_akurasi = "N/A"

    return JSONResponse({
        "status": "success",
        "prediksi": latest_prediksi,
        "akurasi": latest_akurasi,
        "flash": flash_state,
        "mode": camera_mode,
        "reset": do_reset,
    })

  except Exception as e:
    return JSONResponse(status_code=500, content={"message": str(e)})


@app.get("/video_feed")
def video_feed():
  global latest_frame_bytes, camera_mode
  if camera_mode != "off" and latest_frame_bytes is not None:
    return Response(content=latest_frame_bytes, media_type="image/jpeg")

  blank_jpeg = b"\xff\xd8\xff\xe0\x00\x10JFIF\x00\x01\x01\x00\x00\x01\x00\x01\x00\x00\xff\xdb\x00C\x00\x08\x06\x06\x07\x06\x05\x08\x07\x07\x07\x09\t\x08\n\x0c\x14\r\x0c\x0b\x0b\x0c\x19\x12\x13\x0f\x14\x1d\x1a\x1f\x1e\x1d\x1a\x1c\x1c $.\x27 \",#\x1c\x1c(7),01444\x1f\x279=82<.342\xff\xc0\x00\x0b\x08\x00\x01\x00\x01\x01\x01\x11\x00\xff\xc4\x00\x1f\x00\x00\x01\x05\x01\x01\x01\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x01\x02\x03\x04\x05\x06\x07\x08\t\n\x0b\xff\xda\x00\x08\x01\x01\x00\x00?\x00\xbf\x00\xff\xd9"
  return Response(content=blank_jpeg, media_type="image/jpeg")


@app.get("/get-flash")
def get_flash():
  global flash_state, camera_mode, latest_prediksi, latest_akurasi, telemetry_data, reset_state

  do_reset = reset_state
  if reset_state:
    reset_state = False

  return JSONResponse({
      "flash": flash_state,
      "mode": camera_mode,
      "reset": do_reset,
      "prediksi": latest_prediksi,
      "akurasi": latest_akurasi,
      "temp": telemetry_data["temp"],
      "hum": telemetry_data["hum"],
      "dist": telemetry_data["dist"],
  })


@app.get("/set-camera-mode")
def set_camera_mode(mode: str):
  global camera_mode, latest_prediksi, latest_akurasi, latest_frame_bytes
  if mode in ["predict", "cctv", "off"]:
    camera_mode = mode
    if camera_mode == "cctv":
      latest_prediksi = "Mode CCTV (Robot Arm Active)"
      latest_akurasi = "N/A"
    elif camera_mode == "off":
      latest_prediksi = "Kamera Nonaktif (OFF)"
      latest_akurasi = "N/A"
      latest_frame_bytes = None
    return {"status": "success", "mode": camera_mode}
  return JSONResponse(status_code=400, content={"message": "Mode tidak valid"})


@app.get("/reset-esp")
def reset_esp():
  global reset_state
  reset_state = True
  return {"status": "success", "message": "Signal reboot dikirim"}


@app.post("/toggle-flash")
def toggle_flash():
  global flash_state
  flash_state = not flash_state
  return JSONResponse({"flash": flash_state})


@app.post("/update-telemetry")
async def update_telemetry(
    temp: str = Form(...), hum: str = Form(...), dist: str = Form(...)
):
  global telemetry_data
  telemetry_data["temp"] = temp
  telemetry_data["hum"] = hum
  telemetry_data["dist"] = dist
  return {"status": "success"}


@app.get("/set-servo")
def set_servo(
    base: int = 90, shoulder: int = 90, elbow: int = 90, gripper: int = 90
):
  global servo_state
  servo_state = {
      "base": base,
      "shoulder": shoulder,
      "elbow": elbow,
      "gripper": gripper,
  }
  return {"status": "success", "servo": servo_state}


@app.get("/get-servo")
def get_servo():
  global servo_state
  return JSONResponse(servo_state)


if __name__ == "__main__":
  uvicorn.run(app, host="0.0.0.0", port=8000)