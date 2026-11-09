# Test Plan — QuickClip Pro Quality & Verification

## L0 — Static Analysis
- Target: Seluruh codebase `lib/` dan `test/`
- Tool: `flutter analyze`
- Kriteria Lulus: 0 error, 0 warning

## L1 — Unit & Model Testing
- Target:
  1. `animation_studio_test.dart`
  2. `basic_effects_semantic_audit_test.dart`
  3. `shake_effects_visual_audit_test.dart`
  4. `glitch_batch1_visual_audit_test.dart`
  5. `glitch_batch2_visual_audit_test.dart`
  6. `glitch_batch3_visual_audit_test.dart`
  7. Audio, speed, transform, color adjustment, timeline split unit tests.
- Kriteria Lulus: Seluruh 149+ unit tests lulus (Exit Code 0).

## L2 — Parity & Filter Verification Testing
- Target: `buildFFmpegFilter()` pada `ClipAnimationModel`.
- Verifikasi: Setiap kategori preset animasi harus menghasilkan string filter FFmpeg yang valid dan tidak menghasilkan string kosong tanpa penjelasan.

## L3 — Runtime & Build Verification
- Target: Build verifikasi APK Android (`flutter build apk --debug`).
- Kriteria Lulus: APK terkompilasi tanpa failure native/gradle.

