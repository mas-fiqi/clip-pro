# QA Requirements Inventory & Traceability Matrix
QuickClip Pro — Project Quality, Completeness & Verification

## 1. Capability Declaration (FASE 0)

| Kemampuan | Tersedia? | Bukti / Catatan |
|---|---|---|
| Menjalankan unit & widget test | Ya | `flutter test` via Flutter 3.35.7 stable |
| Static Analyzer | Ya | `flutter analyze` |
| Membangun release Android | Ya | Android SDK 35.0.0 terinstal (`flutter build apk`) |
| Mengakses jaringan | Ya | Network resources OK via `flutter doctor` |
| FFmpeg / ffprobe di Host | Ya | FFmpeg 8.0-essentials & ffprobe 8.0 terpasang di path |
| Device terhubung | Ya | Redmi Note 8 (`android-arm64`, Android 11 API 30) terdeteksi via adb |
| Menjalankan Web | Terbatas | Scaffolding web ada, namun plugin native mobile (`ffmpeg_kit_flutter_new`, `gal`, `path_provider`) tidak support web |
| Menjalankan Windows Desktop | Tidak | Visual Studio C++ workload belum terpasang |

---

## 2. Requirement Matrix & Action Plan

| ID | Requirement Area | Acceptance Criteria | Priority | Implementation | UI | Logic | Output | Test | Status |
|---|---|---|---|---|---|---|---|---|---|
| REQ-001 | Version Control Integrity | Project memiliki git repository aktif, .gitignore bersih, dan initial commit tersimpan | P0 | ✗ | N/A | ✓ | ✓ | ✗ | NOT IMPLEMENTED |
| REQ-002 | Export Filter Parity Audit | Semua preset animasi/efek yang ada di UI memiliki perlakuan filter ekspor nyata atau fallback kategori terdefinisi (tidak silent drop ke empty filter tanpa efek) | P0 | ✗ | ✓ | ✓ | ✗ | ✗ | PARTIAL |
| REQ-003 | AI Claim & Licensing Sanitization | Bersihkan klaim palsu "AI" di `OnlineAiEffectApiService` (hanya pencarian model HF tanpa inferensi); amankan sumber audio offline | P1 | ✗ | ✓ | ✗ | ✗ | ✗ | PARTIAL |
| REQ-004 | State Architecture Separation | Pecah monolit `video_clipper_screen.dart` ke controller/notifier independen (Timeline, Overlay, Export) | P1 | ✗ | ✓ | ✓ | ✗ | ✗ | PARTIAL |
| REQ-005 | Product Documentation Integrity | Perbarui `README.md` dan `pubspec.yaml` dengan deskripsi resmi produk QuickClip Pro, batasan platform mobile-first, dan panduan build | P2 | ✗ | N/A | N/A | ✓ | ✗ | NOT IMPLEMENTED |
| REQ-006 | Integration Export Test | Test verifikasi output nyata: klip + efek + overlay diekspor dan divalidasi strukturnya | P0 | ✗ | N/A | ✓ | ✗ | ✗ | UNVERIFIED |

## 3. Counter
- Requested: 6 Core Action Areas
- Verified: 0 / 6 (0.0%)
- Overall Status: NOT READY (Sedang dalam proses pengerjaan bertahap dengan pembuktian nyata)

