# Baseline Inspection Report (Task #001)
**QuickClip Pro / VideoCraft — Baseline Project State & Recovery**

Audit Date: 2026-11-09 12:35  
Investigator: Antigravity AI Engine (Under AI Engineering Constitution v2.0)

---

## 1. Project Information

- **Project Name:** QuickClip Pro (package / folder: `video_clipper_app`)
- **Flutter Version:** 3.35.7 (channel stable, revision `adc9010625`)
- **Dart Version:** 3.9.2 (DevTools 2.48.0)
- **Compile SDK:** Android 35 (`compileSdk = flutter.compileSdkVersion`)
- **Min SDK:** Android 24 (Android 7.0 Nougat)
- **Target SDK:** Default Flutter targetSdkVersion (Android 34/35)
- **Application ID:** `id.cakfi.quickclippro`
- **Current App Version:** `1.0.0+1`
- **Host OS:** Windows 11 Version 10.0.26300.9818
- **Android SDK Path:** `C:\android\sdk` (Build Tools 35.0.0)
- **Host FFmpeg:** 8.0-essentials (`ffprobe` version 8.0)
- **Target Platforms:** Android-first (Mobile)

---

## 2. Project Statistics

*(Dihitung langsung via PowerShell Command Line pada file fisik)*

- **Total File dalam Proyek:** 8.848 file (termasuk .dart_tool, android gradle cache, dan assets)
- **Jumlah File Dart di `lib/`:** 91 file Dart
- **Ukuran File di `lib/`:** 1.46 MB
- **Jumlah File Test di `test/`:** 27 file Dart
- **Ukuran File di `test/`:** 0.135 MB (138 KB)
- **Jumlah Unit / Widget Test:** 160 passing tests
- **Jumlah Aset Terdaftar (`assets/`):** 98 file aset
  - Audio Lokal: 22 file (`assets/audio/music`, SFX, viral)
  - Gambar/Preview: 28 file gambar
- **Ukuran Folder `dist/` (Artefak Lama):** 580.17 MB
- **Ukuran Folder `build/` (Build Cache Lokal):** 4.578 MB (4.57 GB)

---

## 3. Git Status & Version Control Baseline

- **Repository Initialized:** YES (`C:\flater\video_clipper_app\.git\`)
- **Remote Origin:** `https://github.com/mas-fiqi/clip-pro.git` (branch `main`)
- **Working Tree State:** `CLEAN` (`nothing to commit, working tree clean`)
- **Latest Commit Hash:** `f055291`
- **Commit History Baseline:**
  1. `a70df52` - `first commit`
  2. `19a73c8` - `feat: initial commit QuickClip Pro full source code and QA constitution`
  3. `f055291` - `docs(qa): record EV-001 for git repository verification`
- **Protection Rules (`.gitignore`):**
  - Mengabaikan `build/`, `dist/`, `.dart_tool/`, `key.properties`, `*.jks`, `*.keystore`, video tes sementara (`test_*.mp4`), dan python cache (`__pycache__`).

---

## 4. Release Configuration & Forensic Findings (P0 / P1)

### P0 Findings (Blocker Rilis)
1. **[P0-01] Missing INTERNET Permission in Release Manifest:**
   - **Lokasi:** `android/app/src/main/AndroidManifest.xml`
   - **Bukti Forensik:** `aapt dump permissions build\app\outputs\flutter-apk\app-release.apk`
   - **Hasil Dump:** Hanya terdapat `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, `READ_MEDIA_VIDEO`, `READ_MEDIA_IMAGES`, `ACCESS_NETWORK_STATE`, dan `WAKE_LOCK`.
   - **Dampak:** Izin `INTERNET` hanya aktif pada `debug` & `profile`. Saat APK di-build release, fitur pencarian audio online / katalog remote gagal diam-diam (*silent failure*).
   - **Status:** OPEN (Teridentifikasi).

2. **[P0-02] Release Signing Silent Fallback to Debug Key:**
   - **Lokasi:** `android/app/build.gradle.kts` (baris 51-58)
   - **Bukti Forensik:** `apksigner verify --print-certs build\app\outputs\flutter-apk\app-release.apk`
   - **Hasil Verifikasi:** `Signer #1 certificate DN: C=US, O=Android, CN=Android Debug`
   - **Dampak:** Karena `key.properties` belum disiapkan di mesin ini, Gradle secara otomatis melakukan fallback diam-diam ke `debug.keystore`. Google Play Console akan menolak keras sertifikat debug ini.
   - **Status:** OPEN (Teridentifikasi).

3. **[P0-03] Gap Paritas Preview vs Ekspor FFmpeg:**
   - **Status:** OPEN (Sebanyak 144 preset berstatus preview-only, 671 approximate, dan 85 setara penuh). Berada di luar scope Task #001.

---

## 5. Summary Tabel Baseline BEFORE & AFTER

| Area | Before Task #001 | After Task #001 Baseline | Status | Evidence |
|---|---|---|---|---|
| **Git Repository** | `fatal: not a git repository` | Active repo + remote tracked | **VERIFIED** | `git status` clean, commit `f055291` |
| **.gitignore** | Belum ada rule ignore test video & clean dist | `.gitignore` komprehensif | **VERIFIED** | `.gitignore` file |
| **Working Tree** | Untracked / unversioned | Clean working tree | **VERIFIED** | `git status` -> `working tree clean` |
| **Flutter Analyze** | 0 issue | 0 issue (clean) | **VERIFIED** | `flutter analyze` exit 0 (14.7s) |
| **Flutter Test** | 160 tests passing | 160 tests passing | **VERIFIED** | `flutter test` exit 0 (24s) |
| **Debug Build** | Belum terverifikasi | APK debug berhasil di-build | **VERIFIED** | `build\app\outputs\flutter-apk\app-debug.apk` (128.6s) |
| **Release Build** | Tidak diketahui | Berhasil kompilasi dengan `--no-tree-shake-icons` | **PARTIAL** | `build\app\outputs\flutter-apk\app-release.apk` (233.8MB) |
| **Release Signing** | Debug key fallback aktif | Terbukti CN=Android Debug via apksigner | **OPEN / P0** | `apksigner verify --print-certs` |
| **INTERNET Permission** | Belum diaudit di manifest | Terbukti absen di release manifest via aapt | **OPEN / P0** | `aapt dump permissions` |
