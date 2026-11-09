# FORENSIC PARITY AUDIT & MASTER PLAN #005
## QuickClip Pro — Preview vs Output Integrity & Media Pipeline

Dokumen ini memetakan seluruh komponen visual dan audio antara apa yang dilihat pengguna di preview Flutter (`TransformablePreview`, `VideoPreviewPlayer`, `TextOverlayView`) dengan apa yang diproses dan dihasilkan oleh FFmpeg engine (`FFmpegProcessingEngine`).

---

## 1. INVENTORY & STATUS PARITAS 10 KOMPONEN EDITING

| No | Komponen Editing | Status Preview UI | Status FFmpeg Export Filter | Status Paritas | Temuan Masalah & Tindakan |
|---|---|---|---|---|---|
| 1 | **Trim & Cut Points** | `controller.seekTo(startSource)` & limit slider | `-ss start -t duration` | **VERIFIED** | Timestamp FFmpeg akurat via `TimeFormatter.toFFmpegTimestamp`. Perlu guard durasi minimum > 0.1s. |
| 2 | **Crop Boundaries** | `ClipRect` + `_RelativeVideoClipper` | `crop=w:h:x:y` | **PARTIAL** | Koordinat crop di FFmpeg memakai perkalian float (`cropRight - cropLeft`), namun jika ukuran tidak genap (ganjil) FFmpeg dapat menolak yuv420p. Scale genap di akhir menyelamatkan, namun crop dimensi perlu dibulatkan genap sejak awal. |
| 3 | **Rotation & Flip** | `Transform(matrix3D)` + `Transform.scale(-1)` | `transpose`, `hflip,vflip`, `rotate` | **PARTIAL** | Rotasi 90°, 180°, 270° sudah ada `transpose=1`, `hflip,vflip`, `transpose=2`. Rotasi arbitrer menggunakan `rotate=rad:ow=...:oh=...` namun belum memperhitungkan rotasi keyframe dinamis di FFmpeg (hanya statis). |
| 4 | **Canvas Aspect Ratio & Fit Mode** | `FittedBox(fitMode: fit/fill)` | `scale=...pad=...` vs `scale=...crop=...` | **VERIFIED** | Formula aspect ratio sudah menangani mode `fit` (padding dengan color hex) dan `fill` (crop center). |
| 5 | **Target Resolution** | Display size di layar | `scale=-2:targetHeight` & portrait scale | **VERIFIED** | Dimensi dibatasi proporsional dengan skala kelipatan 2 (`trunc(iw/2)*2`). |
| 6 | **Text & Overlay** | `Positioned` + `Text` + `Container` | `drawtext=text='...':x=...:y=...` | **PARTIAL** | 1. FFmpeg drawtext font default bergantung pada ketersediaan font di sistem Android (`fontfile` belum eksplisit). 2. Karakter khusus perlu escaping ketat. |
| 7 | **Color Adjustment & Filters** | `ColorFilter.matrix(FilterCatalog)` | `eq=brightness=...:contrast=...:saturation=...` | **PARTIAL** | Filter Matrix di UI memiliki 15 preset warna, namun mapping FFmpeg beberapa filter masih berupa pendekatan approximate atau fallback. |
| 8 | **Speed Control & Curves** | `controller.setPlaybackSpeed(speed)` | `-filter_complex setpts=PTS/SPEED` + `atempo=SPEED` | **VERIFIED** | Speed 0.5x sampai 2.0x telah didukung dengan rantai `atempo` bertingkat untuk batas di luar 0.5 - 2.0. |
| 9 | **Multi-Track Audio Mixing** | SoundPool / AudioPlayer terpisah | `amix=inputs=N:duration=longest,apad` | **VERIFIED** | Telah dioptimasi dengan validasi stream probe dan dynamic amix. |
| 10 | **Single / Multi-Clip Sequence** | Timeline multi-clip UI | Intermediate clip encoding $\to$ Concat / Direct bypass | **VERIFIED** | Single clip di-bypass langsung, multi-clip digabung via `concat` demuxer. |

---

## 2. RENCANA EKSEKUSI (IMPLEMENTATION & VERIFICATION)

1. **Parity Test Suite**:
   Buat `test/preview_export_parity_test.dart` untuk menguji konsistensi parameter matematika antara preview dan argumen FFmpeg (Crop, Rotate, Flip, Scale, AspectRatio, Speed, Overlay Duration).
2. **Text Font Fallback**:
   Pastikan argumen `drawtext` aman pada Android (jika font file eksternal tidak ditemukan, gunakan fallback yang tidak membuat FFmpeg crash).
3. **Pembersihan Cache Deterministic**:
   Pastikan tidak ada file sementara yang tertinggal di cache saat export sukses maupun batal.
