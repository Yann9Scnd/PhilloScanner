# Phylloscanner — Rencana Pengembangan

## Status Saat Ini (28 Agustus 2026)

### Sudah Berfungsi
- Sensor tab real-time → baca LANGSUNG dari ESP32 `/status` setiap 5 detik (sama dengan serial monitor)
- Fallback ke Laravel bila ESP32 offline
- Aktuator sync: pompa & pestisida kirim ke ESP32 real + rollback jika gagal + toast feedback
- ESP32 WebServer + relay sync + POST telemetry ke Laravel
- ESP32 pesticide relay pin 27 (+ /pesticide/on, /pesticide/off endpoints)
- Flutter pesticide toggle kirim ke ESP32 (sudah di-fix)
- Telemetry POST ke Laravel di code.ino (dikembalikan)
- Node Management (CRUD ESP32 nodes)
- AI Chat via OpenRouter (backend call, bukan lokal)
- AI Scan foto via OpenRouter (backend call)
- Pull-to-refresh di sensor tab
- **ML Scan daun OFFLINE** via TFLite on-device (Model Lokal) — SELESAI (28/8)
  - Model `model_daun_cabai.h5` → `.tflite` int8 (2.6MB), akurasi test 78%
  - `lib/ml/` (4 file) + `assets/models/` + deps `flutter_litert`, `image`
  - `daun_tab_view.dart` → pilihan "Model Lokal (Offline)" vs "AI Cloud (Gemini)"
  - `flutter analyze` bersih, `flutter build apk --debug` berhasil

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

#### ✅ Status: SELESAI (28 Agustus 2026)

Model lokal sudah berhasil dikonversi & diintegrasikan **on-device di HP** (offline, tanpa AI cloud).

**Model:** `model_daun_cabai.h5` (Keras, 2.26M params)
- Input: `(None, 224, 224, 3)` RGB
- Output: 5 kelas → `healthy`, `leaf curl`, `leaf spot`, `whitefly`, `yellowish`
- Dikonversi ke TFLite int8: `assets/models/model_daun_cabai.tflite` (**2.6 MB**)

**Akurasi (TFLite, test set 50 gambar): 78%**
| Kelas | Akurasi |
|-------|---------|
| healthy | 70% |
| leaf curl | 90% |
| leaf spot | 100% |
| whitefly | 60% |
| yellowish | 70% |

#### Arsitektur
```
Upload Foto
    ↓
[ML TFLite di HP] → klasifikasi (offline, ~ms)
    ↓
[Pilihan user]
├── Model Lokal (Offline) → TFLite on-device → hasil + rekomendasi lokal
└── AI Cloud (Gemini) → Laravel → OpenRouter → rekomendasi lengkap
```

#### File Baru
```
assets/
  models/
    model_daun_cabai.tflite     # Model TFLite int8 (2.6 MB)
    chili_classifier.txt        # 5 label (urutan = indeks output)
lib/
  ml/
    leaf_classifier.dart        # Load model + inference (Offline)
    image_preprocessor.dart     # Resize 224x224 → uint8 RGB
    classification_result.dart  # Hasil klasifikasi
    chili_disease_info.dart     # Metadata label → nama/severity/rekomendasi BI
```

**Modifikasi:**
- `pubspec.yaml` → tambah `flutter_litert: ^3.8.0`, `image: ^4.9.2` + `assets/models/`
- `daun_tab_view.dart` → `_pickAndScanImage` pilih "Model Lokal (Offline)" vs "AI Cloud"; tambah `_runOfflineScan`

**Cara konversi ulang model** (bila `.h5` berubah):
```powershell
python C:\Users\ADMIN\AppData\Local\Temp\opencode\convert_tflite.py
```
(Catatan: model `.h5` pakai custom `Dense` → butuh `custom_objects={'Dense': FixedDense}` saat load di script.)

#### Dataset yang Dibutuhkan
- Dataset aktual: `dataset_daun_cabai.zip` (5 kelas × train/test/val). Sudah dipakai validasi.
- `CLASS_NAMES` di `app.py` = 5 kelas yang sama dengan label TFLite.

---

## Checklist Besok (29 Agustus 2026)

### A. Uji / Verifikasi ML Offline (prioritas karena baru selesai)
- [ ] Jalankan app (Chrome + HP Android via USB) → uji scan offline "Model Lokal"
- [ ] Pastikan model TFLite termuat & hasil klasifikasi tampil (nama penyakit + confidence)
- [ ] Cek akurasi manual dengan foto daun asli
- [ ] (Opsional) Preload model saat startup di `main.dart` agar scan pertama tidak lama

### B. Fix Upload Foto AI
- [ ] Ganti model OpenRouter default → `google/gemma-4-31b-it:free` atau tambah fallback chain
- [ ] Optimasi gambar upload → kompres sebelum kirim ke backend (max 800KB base64)
- [ ] Pakai `temperatureAtScan` & `soilMoisture` di prompt AI
- [ ] Hidupkan `/predict` di `app.py` sekarang tensorflow sudah terinstal (ML_AVAILABLE=True)
  - Jalankan validasi silang: hasil FastAPI `/predict` vs TFLite on-device

### C. Fix DetailScanScreen
- [ ] Chat → ganti keyword lokal dengan `AiService.instance.chat()`
- [ ] Tombol Simpan → panggil `onSaveToHistory` callback ke DashboardScreen
- [ ] AI greeting → gunakan nama disease dari scan result, bukan hardcoded "Cercospora"

### D. Kamera / ESP32
- [ ] Kamera tab: hidupkan `_isCameraOnline` (probe ESP32) — bukan hardcoded false
- [ ] Flash toggle → kirim ke ESP32 (bukan UI-only)
- [ ] Stream kamera → ganti dari gambar Unsplash statis

### E. Backend / Data
- [ ] Save ke server → tambah error handling (bukan fire-and-forget)
- [ ] Validasi ukuran gambar sebelum upload
- [ ] Update model jika akurasi di bawah target → konversi ulang:
  ```
  python C:\Users\ADMIN\AppData\Local\Temp\opencode\convert_tflite.py
  ```

---
## Log Harian

### 28 Agustus 2026 — ML Scan Daun OFFLINE ✅
- Instal `tensorflow-cpu 2.21` + `keras 3.12` (untuk konversi & validasi)
- Verifikasi `model_daun_cabai.h5`: input 224x224x3, output 5 kelas (sesuai CLASS_NAMES), 2.26M params
- Konversi → TFLite int8: `assets/models/model_daun_cabai.tflite` (24MB → **2.6MB**)
- Buat `assets/models/chili_classifier.txt` (5 label, urutan = indeks output)
- Tambah dep: `flutter_litert ^3.8.0`, `image ^4.9.2` + `assets/models/`
- Buat modul `lib/ml/`: `leaf_classifier.dart`, `image_preprocessor.dart`, `classification_result.dart`, `chili_disease_info.dart`
- Tambah scan offline di `daun_tab_view.dart` (pilih Model Lokal vs AI Cloud)
- Validasi akurasi TFLite (test, 50 gambar): **78%** (healthy 70, leaf curl 90, leaf spot 100, whitefly 60, yellowish 70)
- `flutter analyze` → no issues; `flutter build apk --debug` → sukses
- **Fix Gradle OOM**: heap `-Xmx8G → -Xmx3G` + `org.gradle.daemon=false` di `android/gradle.properties` (RAM laptop hanya 7.6GB, daemon -Xmx8G bikin crash)

---
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
