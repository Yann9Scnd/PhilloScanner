# Konfigurasi ESP32 & Integrasi Telemetri (ChiliGuard)

Dokumen ini mencatat semua perubahan dan konfigurasi agar sensor ESP32 dapat
diambil dengan baik oleh dashboard `index.html` (FastAPI) dan aplikasi Flutter.

## 1. Arsitektur

```
ESP32 DevKit (Node Sensor)          FastAPI (app.py)                Klien
+--------------------------+        +-------------------+     +-------------+
| DHT22   (GPIO 4)         |        | /update-telemetry |     | index.html  |
| HC-SR04 (GPIO 16/17)     |  POST  | /get-flash        |---->| (dashboard)|
| Baterai (GPIO 35)        |------->| /telemetry        |     +-------------+
| Soil    (GPIO 34, ops.)  |  form  +-------------------+     +-------------+
+--------------------------+        |                 |      | Flutter     |
                                    +-----------------+      | (SensorTab) |
                                                            +-------------+
```

- ESP32 membaca sensor lalu `POST /update-telemetry` (form-urlencoded).
- FastAPI menyimpan ke `telemetry_data` dan menyajikan ulang via
  `/get-flash` (untuk index.html) dan `/telemetry` (untuk Flutter).
- Servo robot arm (Base 12, Shoulder 14, Elbow 27, Gripper 13) dikontrol lewat
  `/set-servo` & `/get-servo`; akan disambungkan saat konfigurasi menu kamera.

## 2. Perubahan file

| File | Perubahan |
|------|-----------|
| `app (1).py` -> `app.py` | Di-rename, ditambah `soil` & `batt`, endpoint `/telemetry`, timestamp otomatis |
| `index.html` | Nilai baterai diambil dari `data.batt` telemetri |
| `arduino/ESP32_Sensor_Node/ESP32_Sensor_Node.ino` | Sketch baru node sensor ESP32 |

## 3. Kontrak endpoint

### POST `/update-telemetry` (dikirim ESP32)
| Field | Wajib | Contoh |
|-------|-------|--------|
| `temp` | ya | `27.5` |
| `hum` | ya | `72.3` |
| `dist` | ya | `25.0` |
| `soil` | opsional | `65` |
| `batt` | opsional | `86` |

### GET `/telemetry` (untuk Flutter `SensorDataModel.fromMap`)
```json
{
  "device_id": "Node 2: ESP32 Sensor",
  "temperature": "27.5",
  "air_humidity": "72.3",
  "soil_moisture": "65",
  "battery_level": "86",
  "leaf_distance": "25.0",
  "pump_status": "Standby",
  "timestamp": "13 Aug 2026 • 14:30 WIB"
}
```

## 4. Pemetaan sensor ke model Flutter

| Sensor (ESP32) | Key FastAPI | Model Flutter |
|----------------|-------------|---------------|
| DHT22 suhu | `temp` / `temperature` | `SensorDataModel.temperature` |
| DHT22 kelembapan | `hum` / `air_humidity` | `SensorDataModel.airHumidity` |
| HC-SR04 ultrasonik | `dist` / `leaf_distance` | `SensorDataModel.leafDistance` |
| Baterai (ADC) | `batt` / `battery_level` | `SensorDataModel.batteryLevel` |
| Soil kapasitif (ops.) | `soil` / `soil_moisture` | `SensorDataModel.soilMoisture` |

## 5. Cara pakai

1. Isi `SSID`, `WIFI_PASSWORD`, dan `SERVER_URL` di sketch Arduino.
   - Lokal: `http://<IP-komputer>:8000/update-telemetry`
   - Remote (ngrok): `https://<nama>.ngrok-free.dev/update-telemetry`
2. Upload `ESP32_Sensor_Node.ino` ke ESP32 DevKit V1.
3. Jalankan `uvicorn app:app --host 0.0.0.0 --port 8000`.
4. Buka `index.html` (via FastAPI `/` atau langsung) untuk mengecek nilai
   Suhu, Kelembapan, Jarak Daun, dan Baterai.

## 6. Catatan

- Menu kamera (ESP32-CAM) akan dikonfigurasi menyusul; pin servo sudah disiapkan
  di sketch dan mengikuti GPIO pada `index.html`.
- Jika ESP32 DevKit dipakai sebagai node tanpa Wi-Fi, kirim data ke ESP32-CAM
  via UART2 (115200 baud) dan biarkan ESP32-CAM yang meneruskan ke FastAPI.
