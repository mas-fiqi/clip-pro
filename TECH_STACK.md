# 📄 TECH STACK JUSTIFICATION — QUICKCLIP PRO

Dokumen ini mencatat alasan teknis dan arsitektural di balik pemilihan setiap komponen teknologi untuk QuickClip Pro.

---

### 1. Framework Utama: Flutter (Dart ^3.9.2)
- **Alasan:** Flutter menyediakan kemampuan rendering cross-platform 60/120fps langsung ke canvas Skia/Impeller. Sangat ideal untuk timeline video interaktif multi-track dengan gesture panning/zooming yang mulus.
- **Kemandirian Platform:** Tidak bergantung pada layanan cloud, seluruh logika berjalan lokal di runtime Dart perangkat.

---

### 2. Video Processing Engine: FFmpeg Kit (`ffmpeg_kit_flutter_new`)
- **Alasan:** 
  - Standard emas industri untuk manipulasi multimedia offline lokal.
  - Mendukung filtergraph kompleks (`scale`, `crop`, `drawtext`, `overlay`, `atempo`, `concat`).
  - Memiliki wrapper native Android/iOS dengan support arsitektur `arm64-v8a`, `armeabi-v7a`, `x86_64`.
- **Abstraksi:** Dibuatkan antarmuka `VideoProcessingEngine` agar pemanggilan command FFmpeg terisolasi dari UI.

---

### 3. Media Preview & Player: `video_player`
- **Alasan:** Menggunakan platform native ExoPlayer (Android) dan AVPlayer (iOS). Memberikan performa decoding hardware acceleration langsung dari GPU ponsel, menjaga suhu perangkat tetap dingin saat preview editing.

---

### 4. Storage & Media Management: `gal` & `path_provider`
- **Alasan:**
  - Android 10+ memberlakukan Scoped Storage yang ketat. `gal` menggunakan MediaStore API resmi tanpa memerlukan izin root atau hack direktori.
  - `path_provider` mengelola cache sementara agar ruang penyimpanan ponsel pengguna tidak bocor setelah ekspor selesai.

