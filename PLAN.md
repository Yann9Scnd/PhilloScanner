# ChiliGuard — Rencana Pengembangan

## Status Saat Ini (26 Agustus 2026)

### Sudah Berfungsi
- Sensor tab fetch + auto-refresh 5s + Live/Offline indicator
- Aktuator sync ke Laravel (pompa, pestisida, laser, fan)
- ESP32 WebServer + relay sync + POST telemetry ke Laravel
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

- [ ] Fix model OpenRouter (ganti/tambah fallback)
- [ ] Fix DetailScanScreen chat → pakai AI API
- [ ] Fix DetailScanScreen save → panggil callback
- [ ] Fix DetailScanScreen greeting → dinamis
- [ ] Tambah kompresi gambar upload
- [ ] Install `flutter_litert` + `image` package
- [ ] Buat `lib/ml/` module
- [ ] Buat `assets/models/` directory
- [ ] Mulai kumpulkan dataset bercak daun
