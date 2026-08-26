# ChiliGuard — Rencana Pengembangan

## Status Saat Ini (26 Agustus 2026)

### Sudah Berfungsi
- Sensor tab fetch + auto-refresh 5s + Live/Offline indicator
- Aktuator sync ke Laravel (pompa, pestisida, laser, fan)
- ESP32 WebServer + relay sync + POST telemetry ke Laravel
- ESP32 pesticide relay pin 27 (+ /pesticide/on, /pesticide/off endpoints)
- Flutter pesticide toggle kirim ke ESP32 (sudah di-fix)
- Flutter parse pesticide state dari ESP32 langsung
- Node Management (CRUD ESP32 nodes)
- AI Chat via OpenRouter (backend call, bukan lokal)
- AI Scan foto via OpenRouter (backend call)
- Pull-to-refresh di sensor tab

### Belum Berfungsi / Placeholder
- Upload foto AI → model OpenRouter free tidak reliable (rate limit 429, response kosong)
- Kamera tab → `_isCameraOnline = false` (hardcoded offline, semua mock)
- DetailScanScreen → chat = keyword matching lokal, tombol save = stub (cuma toast)
- DetailScanScreen → AI greeting selalu "Cercospora" meski diagnosis beda
- Flash toggle = UI-only, tidak kirim ke ESP32
- Stream kamera = gambar Unsplash statis
- `temperatureAtScan` dan `soilMoisture` dikirim ke AI tapi tidak dipakai di prompt
- Save ke server = fire-and-forget, error di-swallow
- Tidak ada validasi ukuran gambar sebelum upload
- Tidak ada ML offline (semua tergantung internet)

---

## Rencana Perbaikan — 27 Agustus 2026

### Pagi: Fix Upload Foto AI

1. **Ganti model OpenRouter default** → `google/gemma-4-31b-it:free` atau tambah fallback chain
2. **Fix DetailScanScreen:**
   - Chat → ganti keyword lokal dengan `AiService.instance.chat()`
   - Tombol Simpan → panggil `onSaveToHistory` callback ke DashboardScreen
   - AI greeting → gunakan nama disease dari scan result, bukan hardcoded "Cercospora"
3. **Optimasi gambar upload** → kompres sebelum kirim ke backend (max 800KB base64)
4. **Pakai `temperatureAtScan` dan `soilMoisture` di prompt AI**

### Sore: Setup ML Offline untuk Deteksi Bercak Daun

#### Arsitektur
```
Upload Foto
    ↓
[ML TFLite di HP] → Deteksi bercak (offline, 0.1s)
    ↓
Hasil: "Bercak terdeteksi, confidence 87%"
    ↓
[Pilihan user]
├── Lihat detail → Tampilkan hasil ML langsung
└── Analisis AI → Kirim foto ke Laravel → OpenRouter → Rekomendasi lengkap
```

#### Yang Perlu Dibuat

**Package Flutter:**
- `flutter_litert: ^3.8.0` (TFLite interpreter, auto-bundled native)
- `image: ^4.5.2` (preprocessing: resize, normalize)

**Struktur File Baru:**
```
chiliguard/
  assets/
    models/
      chili_classifier.tflite    # Model TFLite (~3-5MB)
      chili_labels.txt           # Label: Cercospora, Antraknosa, Bacterial Spot, Sehat
  lib/
    ml/
      leaf_classifier.dart       # Load model + inference
      image_preprocessor.dart    # Resize 224x224 + normalize [0,1]
      classification_result.dart # Model hasil klasifikasi
```

**Modifikasi File:**
- `pubspec.yaml` → tambah dependencies + assets
- `ai_service.dart` → tambah path on-device (`useOnDevice` param)
- `daun_tab_view.dart` → pilihan "Scan Offline" vs "Analisis AI"
- `main.dart` → preload model saat startup

**Spesifikasi Model:**
- Input: 224x224x3 RGB, normalisasi [0.0, 1.0]
- Output: 4 kelas (Cercospora, Antraknosa, Bacterial Spot, Sehat)
- Target ukuran: < 5MB (quantized int8)
- Target inference: < 100ms di HP Android
- MinSDK: API 21+ (Android 5.0)

#### Dataset yang Dibutuhkan
- Minimal 100 gambar per kelas (4 kelas = 400 gambar minimum)
- Resolusi asli bebas, akan di-resize ke 224x224
- Augmentasi: flip, rotate, brightness shift, crop
- Sumber: Google Images, PlantVillage dataset, foto sendiri

---

## Checklist Besok

- [ ] **URGENT: Download & install NDK 28.2.13676358**
  Folder `C:\Users\ADMIN\AppData\Local\Android\Sdk\ndk\28.2.13676358` tidak sengaja terhapus.
  Tanpa NDK, `flutter run` ke HP gagal. Cara install:
  ```
  sdkmanager "ndk;28.2.13676358"
  ```
  Atau download manual dari: https://dl.google.com/android/repository/android-ndk-r28c-windows.zip (~1.1GB)
  Ekstrak ke `C:\Users\ADMIN\AppData\Local\Android\Sdk\ndk\28.2.13676358\`
- [ ] Fix model OpenRouter (ganti/tambah fallback)
- [ ] Fix DetailScanScreen chat → pakai AI API
- [ ] Fix DetailScanScreen save → panggil callback
- [ ] Fix DetailScanScreen greeting → dinamis
- [ ] Tambah kompresi gambar upload
- [ ] Install `flutter_litert` + `image` package
- [ ] Buat `lib/ml/` module
- [ ] Buat `assets/models/` directory
- [ ] Mulai kumpulkan dataset bercak daun

## Setup Backend untuk Development (26 Agustus 2026)

### Port Allocation
- **Port 8000**: Laravel API (`leafguard-api/`) — CRUD scans, sensor readings, actuators, AI
- **Port 8001**: FastAPI ML (`app.py`) — predict, telemetry, ESP32 communication

### Perubahan yang Dilakukan
- `app.py`: Port diubah 8000 → 8001, import keras/tensorflow dibuat optional (ML belum siap)
- `esp_service.dart`: `_serverIp` default diubah `192.168.43.182` → `127.0.0.1`
- `esp_service.dart`: `armServerUrl` port diubah 8000 → 8001
- Android SDK: install `platforms;android-34`, `build-tools;34.0.0`, `build-tools;35.0.0`, `platforms;android-36`

### Cara Run (Development)
```powershell
# 1. Start MySQL (Laragon)
# 2. Start Laravel
cd leafguard-api; php artisan serve --host=0.0.0.0 --port=8000

# 3. Start FastAPI
python app.py  # port 8001

# 4. adb reverse (untuk run di HP via USB)
adb reverse tcp:8000 tcp:8000
adb reverse tcp:8001 tcp:8001

# 5. Flutter run
flutter run -d <device-id>
```
