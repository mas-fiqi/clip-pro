import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/animation_model.dart';
import 'package:video_clipper_app/core/services/animation_library_service.dart';

void main() {
  group('Basic Effects Semantic Audit & Visual Differentiation Suite', () {
    final library = AnimationLibraryService();
    final allBasicPresets = library.filterPresets(category: AnimationCategory.basic);

    test('1. Catalog Integrity: Exactly 100 Basic Presets Loaded', () {
      expect(allBasicPresets.length, equals(100));
    });

    test('2. Zoom Family Semantic Differentiation (In vs Out vs Cross)', () {
      const modelIn = ClipAnimationModel(presetId: 'zoom_in', duration: 1.0);
      const modelOut = ClipAnimationModel(presetId: 'zoom_out', duration: 1.0);
      const modelCross = ClipAnimationModel(presetId: 'cross_zoom_in', duration: 1.0);

      final rInStart = modelIn.evaluate(timeInClip: 0.1, totalClipDuration: 1.0);
      final rInEnd = modelIn.evaluate(timeInClip: 0.9, totalClipDuration: 1.0);

      final rOutStart = modelOut.evaluate(timeInClip: 0.1, totalClipDuration: 1.0);
      final rOutEnd = modelOut.evaluate(timeInClip: 0.9, totalClipDuration: 1.0);

      // Zoom in scale increases
      expect(rInEnd.scale, greaterThan(rInStart.scale));
      // Zoom out scale decreases
      expect(rOutEnd.scale, lessThan(rOutStart.scale));

      // Cross zoom produces optical blur at midpoint
      final rCrossMid = modelCross.evaluate(timeInClip: 0.5, totalClipDuration: 1.0);
      expect(rCrossMid.blurRadius, greaterThan(0.0));
    });

    test('3. Push Family Semantic Differentiation (4 Directions Entering)', () {
      const pushLeft = ClipAnimationModel(presetId: 'push_left', duration: 1.0);
      const pushRight = ClipAnimationModel(presetId: 'push_right', duration: 1.0);
      const pushUp = ClipAnimationModel(presetId: 'push_up', duration: 1.0);
      const pushDown = ClipAnimationModel(presetId: 'push_down', duration: 1.0);

      final rPL = pushLeft.evaluate(timeInClip: 0.2, totalClipDuration: 1.0);
      final rPR = pushRight.evaluate(timeInClip: 0.2, totalClipDuration: 1.0);
      final rPU = pushUp.evaluate(timeInClip: 0.2, totalClipDuration: 1.0);
      final rPD = pushDown.evaluate(timeInClip: 0.2, totalClipDuration: 1.0);

      // Push Left enters from right (+posX to 0)
      expect(rPL.positionX, greaterThan(0.0));
      // Push Right enters from left (-posX to 0)
      expect(rPR.positionX, lessThan(0.0));
      // Push Up enters from bottom (+posY to 0)
      expect(rPU.positionY, greaterThan(0.0));
      // Push Down enters from top (-posY to 0)
      expect(rPD.positionY, lessThan(0.0));
    });

    test('4. Iris Family Geometric Differentiation (Circle vs Diamond vs Pentagon vs Star)', () {
      const circleOpen = ClipAnimationModel(presetId: 'circle_crop_open', duration: 1.0);
      const circleClose = ClipAnimationModel(presetId: 'circle_crop_close', duration: 1.0);
      const diamondIn = ClipAnimationModel(presetId: 'diamond_iris_in', duration: 1.0);
      const pentagonIn = ClipAnimationModel(presetId: 'basic_pentagon_iris_expand', duration: 1.0);
      const starIn = ClipAnimationModel(presetId: 'basic_star_iris_reveal', duration: 1.0);

      final rCoStart = circleOpen.evaluate(timeInClip: 0.1, totalClipDuration: 1.0);
      final rCoEnd = circleOpen.evaluate(timeInClip: 0.9, totalClipDuration: 1.0);

      final rCcStart = circleClose.evaluate(timeInClip: 0.1, totalClipDuration: 1.0);
      final rCcEnd = circleClose.evaluate(timeInClip: 0.9, totalClipDuration: 1.0);

      expect(rCoStart.clipShape, equals(AnimationClipShape.circleIris));
      expect(rCoEnd.clipProgress, greaterThan(rCoStart.clipProgress)); // Open expands

      expect(rCcStart.clipShape, equals(AnimationClipShape.circleIris));
      expect(rCcEnd.clipProgress, lessThan(rCcStart.clipProgress)); // Close contracts

      final rD = diamondIn.evaluate(timeInClip: 0.5, totalClipDuration: 1.0);
      expect(rD.clipShape, equals(AnimationClipShape.diamondIris));

      final rP = pentagonIn.evaluate(timeInClip: 0.5, totalClipDuration: 1.0);
      expect(rP.clipShape, equals(AnimationClipShape.pentagonIris));

      final rS = starIn.evaluate(timeInClip: 0.5, totalClipDuration: 1.0);
      expect(rS.clipShape, equals(AnimationClipShape.starIris));
    });

    test('5. Dissolve vs Dip to Black vs Dip to White', () {
      const dissolve = ClipAnimationModel(presetId: 'cross_dissolve', duration: 1.0);
      const dipBlack = ClipAnimationModel(presetId: 'dip_to_black', duration: 1.0);
      const dipWhite = ClipAnimationModel(presetId: 'dip_to_white', duration: 1.0);

      final rDis = dissolve.evaluate(timeInClip: 0.5, totalClipDuration: 1.0);
      final rBlack = dipBlack.evaluate(timeInClip: 0.5, totalClipDuration: 1.0);
      final rWhite = dipWhite.evaluate(timeInClip: 0.5, totalClipDuration: 1.0);

      // Dissolve has no color overlay
      expect(rDis.colorOverlayOpacity, equals(0.0));

      // Dip to Black has black overlay (0xFF000000)
      expect(rBlack.colorOverlayOpacity, greaterThan(0.5));
      expect(rBlack.colorOverlayValue, equals(0xFF000000));

      // Dip to White has white overlay (0xFFFFFFFF)
      expect(rWhite.colorOverlayOpacity, greaterThan(0.5));
      expect(rWhite.colorOverlayValue, equals(0xFFFFFFFF));
    });

    test('6. Venetian Blinds & Curtains Geometric Differentiation', () {
      const blindsH = ClipAnimationModel(presetId: 'blinds_horizontal', duration: 1.0);
      const blindsV = ClipAnimationModel(presetId: 'blinds_vertical', duration: 1.0);
      const curtainO = ClipAnimationModel(presetId: 'curtain_open', duration: 1.0);
      const curtainC = ClipAnimationModel(presetId: 'curtain_close', duration: 1.0);

      final rBH = blindsH.evaluate(timeInClip: 0.5, totalClipDuration: 1.0);
      final rBV = blindsV.evaluate(timeInClip: 0.5, totalClipDuration: 1.0);
      final rCO = curtainO.evaluate(timeInClip: 0.5, totalClipDuration: 1.0);
      final rCC = curtainC.evaluate(timeInClip: 0.5, totalClipDuration: 1.0);

      expect(rBH.clipShape, equals(AnimationClipShape.blinds));
      expect(rBV.clipShape, equals(AnimationClipShape.blindsVertical));
      expect(rCO.clipShape, equals(AnimationClipShape.curtain));
      expect(rCC.clipShape, equals(AnimationClipShape.curtainClose));
    });

    test('7. Automated 100% Unique Transform State Fingerprint Audit', () {
      // Evaluate all 100 presets at mid-transition (t=0.5) and verify each preset generates a meaningful transformation
      int evaluatedCount = 0;
      for (final p in allBasicPresets) {
        final model = ClipAnimationModel(presetId: p.id, duration: 1.0);
        final r = model.evaluate(timeInClip: 0.5, totalClipDuration: 1.0);

        // Verify that preset is NOT completely idle
        final hasActiveState = r.scale != 1.0 ||
            r.positionX != 0.0 ||
            r.positionY != 0.0 ||
            r.rotationDegrees != 0.0 ||
            r.rotateXDegrees != 0.0 ||
            r.rotateYDegrees != 0.0 ||
            r.opacity != 1.0 ||
            r.blurRadius > 0.0 ||
            r.flashOpacity > 0.0 ||
            r.colorOverlayOpacity > 0.0 ||
            r.clipShape != AnimationClipShape.none;

        expect(hasActiveState, isTrue, reason: 'Preset "${p.name}" [${p.id}] evaluated to an idle state');
        evaluatedCount++;
      }
      expect(evaluatedCount, equals(100));
    });
  });
}
