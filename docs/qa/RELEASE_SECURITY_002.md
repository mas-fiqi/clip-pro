# MASTER TASK #002 — RELEASE SECURITY & BUILD DETERMINISM AUDIT REPORT

## Document Information
- **Task ID**: MASTER TASK #002
- **Date**: 2026-11-09
- **Project**: QuickClip Pro / VideoCraft — Flutter Video Editor
- **Environment**: Flutter 3.29.3 (Channel stable), Dart 3.7.2, Windows 10/11, Android SDK 35.0.0

---

## 1. BEFORE (Baseline Condition)
Berdasarkan temuan forensik pada Task #001 (`docs/qa/BASELINE_001.md` dan `docs/qa/KNOWN_ISSUES.md`):
1. **INTERNET Permission**:
   - `android/app/src/main/AndroidManifest.xml` tidak memiliki `<uses-permission android:name="android.permission.INTERNET"/>`.
   - Izin internet hanya terdapat pada manifest `debug` dan `profile`. Pada release APK, fitur pemanggilan online (iTunes API, MyInstants, HuggingFace effect catalog) berpotensi gagal total tanpa error yang jelas.
2. **Release Signing Configuration**:
   - `android/app/build.gradle.kts` baris 51–58 memiliki silent fallback ke debug signing:
     ```kotlin
     val debugSigning = signingConfigs.getByName("debug")
     keyAlias = debugSigning.keyAlias
     keyPassword = debugSigning.keyPassword
     storeFile = debugSigning.storeFile
     storePassword = debugSigning.storePassword
     ```
   - Akibatnya, `flutter build apk --release` tanpa `key.properties` menghasilkan APK yang ditandatangani debug key:
     `CN=Android Debug, O=Android, C=US`.
3. **Tree-shake Icons**:
   - Kompilasi release gagal pada tree-shaking dengan error `Could not find a command named const_finder.dart.snapshot` di instalasi Flutter SDK lokal.

---

## 2. CHANGES (Files Modified)
1. `android/app/src/main/AndroidManifest.xml`:
   - Menambahkan `<uses-permission android:name="android.permission.INTERNET"/>` langsung di bawah root element `<manifest>`.
2. `android/app/build.gradle.kts`:
   - Menghapus silent fallback ke debug key.
   - Mengimplementasikan runtime guard: jika credentials release pada `key.properties` tidak lengkap atau file keystore tidak ada, task graph release akan melemparkan `GradleException` yang menghentikan build dengan aman (*fail safely*). Debug build (`assembleDebug`) tetap berjalan normal menggunakan debug key bawaan.
3. `android/key.properties.example`:
   - Dibuat sebagai template panduan setup signing resmi. File asli `android/key.properties` dan keystore `*.jks`/`*.keystore` dilindungi oleh `.gitignore`.

---

## 3. AFTER (Hardened Behavior)
1. **INTERNET Permission**:
   - Android Manifest utama menyertakan `android.permission.INTERNET`.
   - Terverifikasi pada binary release APK menggunakan `aapt dump permissions`.
2. **Release Signing Determinism**:
   - **Kondisi Credentials Hilang**: Build release langsung gagal (*FAIL SAFELY*) dengan pesan jelas:
     `Release signing configuration is missing or incomplete in android/key.properties. Configure required release keystore credentials (storeFile, storePassword, keyAlias, keyPassword) before building a release artifact.`
   - **Kondisi Credentials Valid**: Build release berhasil (*BUILD SUCCESS*) dan binary ditandatangani sertifikat release resmi:
     `Signer #1 certificate DN: CN=QuickClip Pro Release, OU=Mobile, O=QuickClip, L=Jakarta, ST=Jakarta, C=ID`.
   - Tidak ada lagi kemungkinan release APK menggunakan `CN=Android Debug`.

---

## 4. SECURITY VERIFICATION MATRIX

| Check | Requirement | Result | Forensic Evidence |
|---|---|---|---|
| **INTERNET Source** | Ada di `src/main/AndroidManifest.xml` | **PASS** | Line 2 `<uses-permission android:name="android.permission.INTERNET"/>` |
| **INTERNET APK** | Ada di final compiled release APK | **PASS** | `aapt dump permissions build/app/outputs/flutter-apk/app-release.apk` -> `uses-permission: name='android.permission.INTERNET'` |
| **Silent Fallback Removed** | Debug fallback dihapus dari Gradle | **PASS** | `android/app/build.gradle.kts` baris 54-69 |
| **Missing Credentials Guard** | Release build gagal jika credentials hilang | **PASS** | Exit code 1: `Gradle task assembleRelease failed` dengan `GradleException` |
| **Debug Build Functionality** | Debug build tetap jalan normal | **PASS** | `assembleDebug` exit code 0 (`app-debug.apk`) |
| **Release Signing DN** | Bukan `CN=Android Debug` | **PASS** | `apksigner`: `CN=QuickClip Pro Release, OU=Mobile, O=QuickClip, L=Jakarta, ST=Jakarta, C=ID` |
| **Debug vs Release Distinction** | Debug APK dan Release APK memiliki cert berbeda | **PASS** | Debug: `CN=Android Debug` vs Release: `CN=QuickClip Pro Release` |
| **Secret Protection** | Keystore & `key.properties` tidak terlacak Git | **PASS** | `git status --short` bersih dari keystore dan credentials |

---

## 5. UNRESOLVED ITEMS & OUT OF SCOPE
1. **Unresolved Tree-Shake Issue**:
   - `flutter build apk --release` tanpa `--no-tree-shake-icons` gagal karena file `const_finder.dart.snapshot` tidak ada pada instalasi engine Flutter lokal (`C:\flutter\bin\cache\artifacts\engine\windows-x64\const_finder.dart.snapshot`).
   - Sesuai instruksi Task #002, masalah SDK/engine ini dicatat sebagai `P1 — UNRESOLVED TREE-SHAKE ISSUE` dan dikompilasi deterministik menggunakan flag `--no-tree-shake-icons`.
2. **Out of Scope (Master Task #002)**:
   - Task #002 secara tegas **TIDAK** menyentuh atau memodifikasi:
     - 900 animation & effect presets
     - 144 preview-only presets mapping
     - 671 approximate presets mapping
     - P1 runtime export bugs (`tempDir.stat().size`, progress jumps, `PopScope`, `try/catch initialize`)
     - Architecture refactor
     - Fitur UI/UX baru
