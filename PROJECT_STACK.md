# 📋 DOKUMENTASI TEKNOLOGI & ARSITEKTUR PROYEK
**Aplikasi: Video Clipper App**

Dokumen ini mencatat seluruh bahasa pemrograman, framework, native library, dan package yang digunakan dalam proyek ini beserta fungsinya, agar tidak lupa saat ditanyakan kembali di kemudian hari.

---

## 1. Bahasa Pemrograman & Engine yang Digunakan

| Komponen | Bahasa / Teknologi | Lokasi / Implementasi | Fungsi Utama |
| :--- | :--- | :--- | :--- |
| **Frontend & UI Logic** | **Dart (Flutter SDK ^3.9.2)** | `lib/` | Antarmuka pengguna (UI), tema Material 3, slider range pemotong, dan state management aplikasi. |
| **Video Processing Engine** | **C / C++ (FFmpeg Core)** | Melalui library native `ffmpeg_kit_flutter_new` (`.so` binaries) | Melakukan proses pemotongan (trimming), slicing frame, dan encoding MP4 secara cepat (ultrafast) langsung di level hardware/mesin. |
| **Media Player Engine** | **Java / Kotlin (ExoPlayer)** | Melalui plugin `video_player` | Memutar preview video dengan akselerasi perangkat keras (GPU HP) agar pemutaran lancar tanpa lag. |
| **OS & Storage Bridge** | **Kotlin (Android Platform)** | Melalui plugin `gal` & `image_picker` | Menjembatani Flutter dengan Android OS: membuka galeri (Photo Picker) dan menyimpan hasil video ke Android MediaStore (Galeri resmi HP). |
| **Build System** | **Gradle (Kotlin DSL / Groovy)** | `android/app/build.gradle.kts` | Mengatur kompilasi APK, versi Java (Java 17), dan target minimum Android SDK (minSdk 24). |

---

## 2. Daftar Library / Dependencies (Pubspec.yaml)

1. **`ffmpeg_kit_flutter_new: ^4.6.7`**
   - **Tipe:** Native C/C++ Binding via Platform Channel
   - **Kegunaan:** Menjalankan perintah FFmpeg (`-ss`, `-t`, `-c:v libx264`, `-c:a aac`) untuk memotong durasi video.
2. **`video_player: ^2.10.1`**
   - **Tipe:** Flutter Plugin (Android ExoPlayer / iOS AVPlayer)
   - **Kegunaan:** Menampilkan preview video di layar dan mengontrol posisi durasi (seek, play, pause).
3. **`image_picker: ^1.2.2`**
   - **Tipe:** Flutter Plugin (Android Intent & Photo Picker)
   - **Kegunaan:** Mengambil file video yang dipilih pengguna dari memori/galeri HP.
4. **`gal: ^2.3.3`**
   - **Tipe:** Storage & Media Library (Android MediaStore API)
   - **Kegunaan:** Menyimpan file video hasil potongan langsung ke galeri foto publik HP tanpa terkena blokir izin Scoped Storage Android 10/11/13+.
5. **`path_provider: ^2.1.5`**
   - **Tipe:** File System Utility
   - **Kegunaan:** Menyediakan folder sementara (*temporary directory*) tempat menyimpan file video potongan sebelum dipindahkan ke galeri.

---

## 3. Struktur Modul & File Proyek (`lib/`)

```text
lib/
├── core/
│   ├── services/
│   │   ├── ffmpeg_service.dart          # [C/C++ Binding] Menjalankan command potong video
│   │   ├── gallery_saver_service.dart   # [Kotlin/MediaStore] Menyimpan video ke galeri
│   │   └── video_picker_service.dart    # [Android Intent] Mengambil video dari galeri
│   └── utils/
│       └── time_formatter.dart          # Format detik ke HH:mm:ss & format timestamp FFmpeg
│
├── features/
│   └── video_clipper/
│       └── views/
│           ├── widgets/
│           │   ├── trim_range_slider.dart   # UI Slider 2 titik (rentang awal & akhir)
│           │   └── video_preview_player.dart# UI Player video interaktif
│           └── video_clipper_screen.dart    # Halaman utama & integrasi semua alur
│
└── main.dart                            # Entry point & Setup Theme Material 3
```

---

## 4. Alur Kerja Data (Workflow)
$$\text{User Pick Video (Kotlin)} \rightarrow \text{Preview di ExoPlayer} \rightarrow \text{Set Range Slider (Dart)} \rightarrow \text{Proses Potong FFmpeg (C/C++)} \rightarrow \text{Simpan ke Galeri (MediaStore)}$$

