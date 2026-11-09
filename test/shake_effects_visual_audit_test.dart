import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/animation_model.dart';
import 'package:video_clipper_app/core/services/animation_library_service.dart';

void main() {
  group('100 Shake Effects Semantic Forensic Audit & Visual Differentiation Suite', () {
    final library = AnimationLibraryService();
    final allShakes = library.filterPresets(category: AnimationCategory.shake);

    test('1. Catalog Integrity: Exactly 100 Shake Presets Available', () {
      expect(allShakes.length, equals(100));
    });

    test('2. Strict Directional Verification: Horizontal Shake vs Vertical Shake', () {
      const hShake = ClipAnimationModel(presetId: 'horizontal_shake', duration: 1.0);
      const vShake = ClipAnimationModel(presetId: 'vertical_shake', duration: 1.0);

      final rH = hShake.evaluate(timeInClip: 0.1, totalClipDuration: 1.0);
      final rV = vShake.evaluate(timeInClip: 0.1, totalClipDuration: 1.0);

      // Horizontal Shake MUST move along X and have 0 on Y
      expect(rH.positionX.abs(), greaterThan(0.001));
      expect(rH.positionY.abs(), equals(0.0));

      // Vertical Shake MUST move along Y and have 0 on X
      expect(rV.positionY.abs(), greaterThan(0.001));
      expect(rV.positionX.abs(), equals(0.0));
    });

    test('3. Camera Shake vs Handheld Camera vs Sway Differentiation', () {
      const cam = ClipAnimationModel(presetId: 'camera_shake', duration: 1.0);
      const handheld = ClipAnimationModel(presetId: 'handheld_camera', duration: 1.0);
      const sway = ClipAnimationModel(presetId: 'slight_sway', duration: 1.0);

      final rCam = cam.evaluate(timeInClip: 0.25, totalClipDuration: 1.0);
      final rHandheld = handheld.evaluate(timeInClip: 0.25, totalClipDuration: 1.0);
      final rSway = sway.evaluate(timeInClip: 0.25, totalClipDuration: 1.0);

      // Verify they do not share identical coordinates
      expect(rCam.positionX, isNot(equals(rHandheld.positionX)));
      expect(rCam.rotationDegrees, isNot(equals(rSway.rotationDegrees)));
      expect(rSway.positionY, equals(0.0)); // Sway is lateral + rotation only
    });

    test('4. Heartbeat Family: Pure scale expansion with lub-dub cycle', () {
      const hb = ClipAnimationModel(presetId: 'heartbeat', duration: 1.0);
      final rRest = hb.evaluate(timeInClip: 0.5, totalClipDuration: 1.0); // During pause phase
      final rPeak = hb.evaluate(timeInClip: 0.08, totalClipDuration: 1.0); // During Lub phase

      expect(rPeak.scale, greaterThan(1.05));
      expect(rRest.scale, equals(1.0)); // Resting phase
      expect(rPeak.positionX, equals(0.0)); // Heartbeat does not displace camera frame
      expect(rPeak.positionY, equals(0.0));
    });

    test('5. Impact Family Non-Continuous Behavior (Attack -> Peak -> Decay Settle)', () {
      const punch = ClipAnimationModel(presetId: 'punch_impact', duration: 1.0, easing: AnimationEasingCurve.linear);
      const sniper = ClipAnimationModel(presetId: 'shake_sniper_single_jolt', duration: 1.0, easing: AnimationEasingCurve.linear);

      final rPunchPeak = punch.evaluate(timeInClip: 0.1, totalClipDuration: 1.0);
      final rPunchSettled = punch.evaluate(timeInClip: 0.8, totalClipDuration: 1.0);

      expect(rPunchPeak.positionX.abs(), greaterThan(0.08));
      expect(rPunchSettled.positionX.abs(), lessThan(0.01)); // Settle down at rest

      final rSniperPeak = sniper.evaluate(timeInClip: 0.07, totalClipDuration: 1.0);
      final rSniperSettled = sniper.evaluate(timeInClip: 0.8, totalClipDuration: 1.0);

      expect(rSniperPeak.positionY.abs(), greaterThan(0.1));
      expect(rSniperSettled.positionY.abs(), lessThan(0.01));
    });

    test('6. Automated 100% Unique Trajectory Kinematics across all 100 presets', () {
      final sampleTimes = [0.05, 0.1, 0.2, 0.35, 0.5, 0.7, 0.9];
      final Map<String, List<double>> trajectoryMap = {};

      for (final p in allShakes) {
        final model = ClipAnimationModel(presetId: p.id, duration: 1.0, intensity: 1.0);
        final List<double> vector = [];
        for (final t in sampleTimes) {
          final res = model.evaluate(timeInClip: t, totalClipDuration: 1.0);
          vector.add(double.parse(res.positionX.toStringAsFixed(4)));
          vector.add(double.parse(res.positionY.toStringAsFixed(4)));
          vector.add(double.parse(res.rotationDegrees.toStringAsFixed(3)));
          vector.add(double.parse(res.scale.toStringAsFixed(4)));
          vector.add(double.parse(res.flashOpacity.toStringAsFixed(2)));
        }
        trajectoryMap[p.id] = vector;
      }

      // Check for zero identical pairs among all 100 presets
      final presetIds = allShakes.map((e) => e.id).toList();
      for (int i = 0; i < presetIds.length; i++) {
        for (int j = i + 1; j < presetIds.length; j++) {
          final idA = presetIds[i];
          final idB = presetIds[j];
          final vecA = trajectoryMap[idA]!;
          final vecB = trajectoryMap[idB]!;

          // Calculate Euclidean distance between vectors
          double diff = 0.0;
          for (int k = 0; k < vecA.length; k++) {
            diff += (vecA[k] - vecB[k]).abs();
          }

          expect(
            diff,
            greaterThan(0.01),
            reason: 'Preset [$idA] and [$idB] have identical or near-identical trajectory (diff: $diff)! Must be visually differentiated.',
          );
        }
      }
    });
  });
}
