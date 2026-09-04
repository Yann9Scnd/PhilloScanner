# Konfigurasi ESP32 & Integrasi Telemetri (Phylloscanner)

Dokumen ini mencatat konfigurasi firmware dan alur data sensor ESP32 menuju
aplikasi Flutter. Firmware otoritatif node sensor adalah `code.ino` (root repo);
sketch `arduino/ESP32_Sensor_Node/ESP32_Sensor_Node.ino` adalah salinannya.

## 1. Arsitektur

```
ESP32 DevKit (Node Sensor)           ESP32-CAM                Backend & Klien
+--------------------------+    UART2   +----------------+    +--------------+
| DHT11/22   (GPIO 4)      | (TX2 27 /  | ESP32-CAM      |    | Laravel API  |
| HC-SR04    (TRIG 5,      |  RX2 26)   | (stream video  |    | (histori &   |
|             ECHO 18)     |===========>|  + relai data) |    |  telemetri)  |
| Soil       (GPIO 34)     |<===========| (kirim hasil   |    | FastAPI      |
| Laser      (GPIO 15)     | 500 ms     |  AI via UART)  |    | /set-servo   |
| LED        (GPIO 32)     |            +----------------+    | (kontrol     |
| Dual OLED  (bus 0 & 1)   |                                  |  lengan)     |
+--------------------------+                                  +--------------+
                                                                   |
                                                              Flutter app
                                                              (SensorTab,
                                                               KameraTab)
```

- Node sensor **tidak memakai WiFi** dan **tidak membaca baterai**. Semua data
  dikirim ke ESP32-CAM via Serial2 (UART2, 115200 baud) dalam format
  `temp,hum,dist,soil\n` setiap 500 ms.
- ESP32-CAM membalikkan hasil diagnosa AI (`penyakit,akurasi\n`) via UART yang
  ditampilkan pada OLED kiri. ESP32-CAM juga bertugas meneruskan telemetri ke
  FastAPI `/update-telemetry` dan menyajikan stream video.
- Lengan robot (Base, Shoulder, Elbow) dikontrol lewat FastAPI `/set-servo`
  yang dipanggil oleh aplikasi Flutter (KameraTab).

## 2. Pinout node sensor (code.ino)

| Fungsi             | GPIO   | Keterangan                                |
|--------------------|--------|-------------------------------------------|
| DHT (suhu/udara)   | 4      | `DHTTYPE = DHT11` (ubah jadi `DHT22` bila pakai DHT22) |
| HC-SR04 TRIG       | 5      |                                            |
| HC-SR04 ECHO       | 18     | `pulseIn` timeout 20 ms                    |
| Soil kapasitif     | 34     | ADC; kalibrasi AIR_VALUE=3200 / WATER_VALUE=1500 |
| Laser              | 15     | Berkedip tiap 1 detik (non-blocking)       |
| LED selalu nyala   | 32     | `digitalWrite(HIGH)` permanen              |
| Serial2 TX2/RX2    | 27/26  | UART ke ESP32-CAM (115200)                 |
| OLED bus 0 (SDA/SCL)| 19/23 | OLED kiri: hasil diagnosa AI               |
| OLED bus 1 (SDA/SCL)| 21/22 | OLED kanan: monitor sensor                 |

## 3. Protokol UART (node sensor <-> ESP32-CAM)

- Sensor → CAM, tiap 500 ms:
  ```
  <suhu>,<kelembapan_udara>,<jarak_cm>,<tanah_persen>\n
  contoh: 27.5,72,25.3,64\n
  ```
- CAM → Sensor (hasil AI):
  ```
  <nama_penyakit>,<akurasi_persen>\n
  contoh: Cercospora capsici,94.50%\n
  ```

## 4. Kontrak endpoint

### GET `/set-servo` (FastAPI app.py, dipanggil KameraTab)
```
/set-servo?base=90&shoulder=90&elbow=90
```
Menggerakkan servo lengan robot. Gripper tidak dipakai di aplikasi (3 slider:
Base, Shoulder, Elbow). URL dari Flutter: `http://<serverIp>:8000/set-servo`.

### GET `/update-telemetry` (dikirim ESP32-CAM bila meneruskan telemetri)
Field `temp`, `hum`, `dist`, `soil` (tanpa `batt`, node tidak membaca baterai).

## 5. Pemetaan sensor ke model Flutter

| Sensor (ESP32)          | Key       | Model Flutter        |
|-------------------------|-----------|----------------------|
| DHT suhu                | `temp`    | `SensorDataModel.temperature` |
| DHT kelembapan udara    | `hum`     | `SensorDataModel.airHumidity` |
| HC-SR04 jarak daun      | `dist`    | `SensorDataModel.leafDistance` |
| Soil kapasitif          | `soil`    | `SensorDataModel.soilMoisture` |

Tidak ada `battery_level` pada node (tile Baterai di SensorTab sudah dihapus).

## 6. Aktuator di aplikasi

| Aktuator        | Status firmware sekarang                 | Aksi app (SensorTab)            |
|-----------------|------------------------------------------|----------------------------------|
| Laser (GPIO 15) | Berkedip otomatis di code.ino            | Sakelar tersedia, siap dikendalikan firmware berikutnya |
| Lampu LED (32)  | Selalu menyala di code.ino               | Sakelar tersedia, siap dikendalikan firmware berikutnya |
| Pompa Irigasi   | Belum ada di firmware                    | Sakelar tersedia (siapkan tempat) |
| Pompa Pestisida | Belum ada di firmware                    | Sakelar tersedia (siapkan tempat) |

Perintah sakelar app memanggil `GET http://<sensorIp>/actuator?<nama>=0|1`;
jika firmware node belum memprosesnya, sakelar hanya mencerminkan status UI.

## 7. Cara pakai

1. Upload `arduino/ESP32_Sensor_Node/ESP32_Sensor_Node.ino` (salinan `code.ino`)
   ke ESP32 DevKit V1 dengan library: Adafruit SSD1306, Adafruit GFX, DHT.
2. Hubungkan UART2 node (RX2=26, TX2=27) ke ESP32-CAM sesuai protokol di atas.
3. Jalankan FastAPI `uvicorn app:app --host 0.0.0.0 --port 8000` untuk
   `/set-servo` (lengan robot) dan relai telemetri.
4. Set `serverIp` di aplikasi Flutter (Pengaturan > IP) agar `/set-servo`
   mengarah ke komputer server.
