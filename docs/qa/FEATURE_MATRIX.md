# QuickClip Pro — Feature Matrix Architecture

Dokumen ini mendata seluruh kapabilitas sistem, status verifikasi, dan pemetaan uji coba.
Status yang diizinkan: `VERIFIED`, `PARTIAL`, `BROKEN`, `UNVERIFIED`, `NOT IMPLEMENTED`, `BLOCKED`, `NOT IN SCOPE`.

---

## 1. Core Platform & Project Management

| ID | Feature | Implementation | UI | Runtime | Output | Test | Status | Catatan / Evidence |
|---|---|:---:|:---:|:---:|:---:|:---:|:---:|---|
| MGT-001 | Project Listing & Sorting | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | Unit test `test/project_management_test.dart` |
| MGT-002 | Atomic Save & Relink Media | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | Temp file write + json verify + atomic rename |
| MGT-003 | Crash Recovery Snapshot | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | Journal recovery snapshot parsing test |
| MGT-004 | Backup & Restore ZIP | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | File archive export/import |

---

## 2. Timeline Multi-Clip & Editing Engine

| ID | Feature | Implementation | UI | Runtime | Output | Test | Status | Catatan / Evidence |
|---|---|:---:|:---:|:---:|:---:|:---:|:---:|---|
| TML-001 | Trim Handle In/Out | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | `timeline_split_test.dart` |
| TML-002 | Split Clip with Speed Comp | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | Perhitungan speed offset presisi |
| TML-003 | Delete Left / Delete Right | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | Head/tail deletion timeline test |
| TML-004 | Reorder & Duplicate Clip | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | Multi-clip track testing |
| TML-005 | Undo / Redo History | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | `TimelineHistory` state stack |

---

## 3. Video Transformation & Canvas Framing

| ID | Feature | Implementation | UI | Runtime | Output | Test | Status | Catatan / Evidence |
|---|---|:---:|:---:|:---:|:---:|:---:|:---:|---|
| TRN-001 | Aspect Ratio (9:16, 16:9, 1:1, 4:5) | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | `transform_model_test.dart` |
| TRN-002 | Interactive Crop & Scale | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | Pan & pinch boundary clamping |
| TRN-003 | Flip Horizontal & Vertical | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | FFmpeg `hflip`/`vflip` string |
| TRN-004 | Rotation 90° Increments & Smooth | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | Rotasi derajat tersimpan di JSON |

---

## 4. Audio Mixing & Rhythm Studio

| ID | Feature | Implementation | UI | Runtime | Output | Test | Status | Catatan / Evidence |
|---|---|:---:|:---:|:---:|:---:|:---:|:---:|---|
| AUD-001 | Multi-Track Audio Mixing | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | FFmpeg `amix` filter syntax test |
| AUD-002 | Audio Volume & Mute | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | `volume=X` audio filter |
| AUD-003 | Fade In & Fade Out | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | `afade` timing calculation |
| AUD-004 | Local Offline Asset Catalog (22) | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | 22 file MP3 fisik terverifikasi |
| AUD-005 | Online Audio Fetch (iTunes/MyInstants)| ✓ | ✓ | ? | ? | ✗ | **PARTIAL** | Rentan hak cipta & izin INTERNET release |

---

## 5. Speed Curve & Retouch

| ID | Feature | Implementation | UI | Runtime | Output | Test | Status | Catatan / Evidence |
|---|---|:---:|:---:|:---:|:---:|:---:|:---:|---|
| SPD-001 | Constant Speed (0.25x - 2.0x) | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | `setpts` & `atempo` sync |
| SPD-002 | Speed Curve Graph (Montage, Hero, Bullet)| ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | Cubic bezier curve points |
| RTC-001 | Skin Retouch & Slim Canvas | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | Shader & color grading overlay |

---

## 6. Overlay & Text Studio

| ID | Feature | Implementation | UI | Runtime | Output | Test | Status | Catatan / Evidence |
|---|---|:---:|:---:|:---:|:---:|:---:|:---:|---|
| OVL-001 | Draggable Text Layer | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | Normalized coordinates $(X, Y)$ |
| OVL-002 | Subtitle Time Window | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | In-point & out-point visibility |
| OVL-003 | FFmpeg drawtext Escaping | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | Escape quote & special character test |

---

## 7. Export Pipeline & Hardware Acceleration

| ID | Feature | Implementation | UI | Runtime | Output | Test | Status | Catatan / Evidence |
|---|---|:---:|:---:|:---:|:---:|:---:|:---:|---|
| EXP-001 | Resolution 480p/720p/1080p | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | Scale aspect bounding |
| EXP-002 | Bitrate (Low, Standard, High) | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | Estimated file size calculation test |
| EXP-003 | MediaCodec Hardware with Software Fallback | ✓ | ✓ | ✓ | ✓ | ✓ | **VERIFIED** | Hardware detection & libx264 switch |
| EXP-004 | Save to Gallery (MediaStore) | ✓ | ✓ | ✓ | ✓ | ✗ | **PARTIAL** | Error handling belum membedakan permission |
| EXP-005 | Disk Space Pre-Check | ✓ | ✓ | ✗ | ✗ | ✗ | **BROKEN** | Menggunakan `.stat().size` (ukuran folder inode) |

---

## 8. Effect & Animation Library (900 Presets)

| Kategori | Total Preset | Preview Status | Export Filter Status | Evaluasi Paritas |
|---|:---:|:---:|:---:|---|
| **Shake** | 100 | ✓ Kinematik | ✓ Filter Crop/Zoom | High Parity |
| **Glitch** | 100 | ✓ Kinematik + Canvas | ✓ Filter Hue/Noise/Tinterlace | High Parity |
| **Basic** | 100 | ✓ Kinematik + Mask | 71 Filter / 29 PreviewOnly | Partial (29 preview-only) |
| **Trending** | 100 | ✓ Prosedural | 42 Filter / 58 Approximate | Approximate |
| **Light & Flash** | 100 | ✓ Shader/Glow | Approximate Filter | Approximate |
| **Motion** | 100 | ✓ Prosedural | Approximate Filter | Approximate |
| **Retro** | 100 | ✓ Prosedural | Approximate Filter | Approximate |
| **Cinematic** | 100 | ✓ Prosedural | Approximate Filter | Approximate |
| **3D** | 100 | ✓ Prosedural | 0 Filter / 100 PreviewOnly | 100% Preview-Only |
| **TOTAL** | **900** | **900 Preview Ada** | **85 Full / 671 Approx / 144 Only** | **PARTIAL (NOT IN SCOPE TASK #001)** |

