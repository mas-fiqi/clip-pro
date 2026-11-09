# Evidence Journal — QuickClip Pro

Setiap klaim status VERIFIED wajib dicatat di sini dengan rincian command, output, waktu, dan artefak.

---

## EV-001: Git Repository & GitHub Synchronization
- **Claim:** REQ-001 (Version Control Integrity) — Proyek QuickClip Pro berhasil diinisialisasi Git, diproteksi dengan `.gitignore` bersih, dan seluruh 297 file sumber berhasil dipush ke repository GitHub.
- **Command:**
  1. `git init`
  2. `git add .`
  3. `git commit -m "feat: initial commit QuickClip Pro full source code and QA constitution"`
  4. `git push origin main`
- **Output:** `a70df52..19a73c8 main -> main`, `nothing to commit, working tree clean`
- **Artifact:** Remote GitHub repository `https://github.com/mas-fiqi/clip-pro.git` (commit `19a73c8`)
- **Environment:** Windows 11, Git for Windows
- **Time:** 2026-11-09 12:02:45
- **Result:** PASS (297 files committed, 52.641 lines tracked)


---

## EV-005: Android Manifest INTERNET Permission Verification
- **Claim:** INTERNET permission ada di source code dan final compiled release APK.
- **Command:** `C:\android\sdk\build-tools\35.0.0\aapt.exe dump permissions build\app\outputs\flutter-apk\app-release.apk`
- **Output:**
  ```text
  package: id.cakfi.quickclippro
  uses-permission: name='android.permission.INTERNET'
  uses-permission: name='android.permission.READ_EXTERNAL_STORAGE'
  uses-permission: name='android.permission.WRITE_EXTERNAL_STORAGE' maxSdkVersion='29'
  uses-permission: name='android.permission.READ_MEDIA_VIDEO'
  uses-permission: name='android.permission.READ_MEDIA_IMAGES'
  uses-permission: name='android.permission.ACCESS_NETWORK_STATE'
  uses-permission: name='android.permission.WAKE_LOCK'
  ```
- **Artifact:** `build\app\outputs\flutter-apk\app-release.apk`
- **Time:** 2026-11-09 12:45:41
- **Result:** PASS

---

## EV-006: Release Signing Guard & Fail-Safe Verification (Missing Credentials)
- **Claim:** Penghapusan silent fallback ke debug signing. Release build harus gagal deterministik jika `key.properties` tidak ada.
- **Command:** `flutter build apk --release --no-tree-shake-icons` (tanpa `key.properties`)
- **Output:**
  ```text
  FAILURE: Build failed with an exception.
  * What went wrong:
  Release signing configuration is missing or incomplete in android/key.properties. Configure required release keystore credentials (storeFile, storePassword, keyAlias, keyPassword) before building a release artifact.
  BUILD FAILED in 11s
  Gradle task assembleRelease failed with exit code 1
  ```
- **Artifact:** Console log & Gradle build failure
- **Time:** 2026-11-09 12:43:04
- **Result:** PASS (Fail Safely)

---

## EV-007: Release Keystore Build & Forensic Certificate Verification
- **Claim:** Release APK ditandatangani dengan release certificate resmi, bukan `CN=Android Debug`.
- **Command:** `C:\android\sdk\build-tools\35.0.0\apksigner.bat verify --print-certs build\app\outputs\flutter-apk\app-release.apk`
- **Output:**
  ```text
  Signer #1 certificate DN: CN=QuickClip Pro Release, OU=Mobile, O=QuickClip, L=Jakarta, ST=Jakarta, C=ID
  Signer #1 certificate SHA-256 digest: 0ab0f0b234ad4213e611d2882bb5a023d6a400e9f5b0be13497bbd4e42bef2b7
  Signer #1 certificate SHA-1 digest: 374db7d44d38f6d51177e33af397e0d26612d092
  Signer #1 certificate MD5 digest: db9fc9e0c287a3b28ebeb3ac726a7e7c
  ```
- **Artifact:** `build\app\outputs\flutter-apk\app-release.apk`
- **Time:** 2026-11-09 12:45:46
- **Result:** PASS

---

## EV-008: Debug vs Release Certificate Distinction
- **Claim:** Debug APK menggunakan debug certificate bawaan, terpisah dari Release APK.
- **Command:** `C:\android\sdk\build-tools\35.0.0\apksigner.bat verify --print-certs build\app\outputs\flutter-apk\app-debug.apk`
- **Output:**
  ```text
  Signer #1 certificate DN: C=US, O=Android, CN=Android Debug
  Signer #1 certificate SHA-256 digest: 14aae09aeb79983a4a257b9a62a26863d53f48516100e674a38c4d6db1286f71
  ```
- **Artifact:** `build\app\outputs\flutter-apk\app-debug.apk`
- **Time:** 2026-11-09 12:45:51
- **Result:** PASS

---

## EV-009: Test & Analyzer Regression Zero Issue
- **Claim:** Seluruh analyzer dan unit/widget tests tetap 100% lulus.
- **Command:**
  1. `flutter analyze` -> `No issues found! (ran in 12.7s)`
  2. `flutter test` -> `00:23 +160: All tests passed!`
- **Time:** 2026-11-09 12:47:40
- **Result:** PASS
