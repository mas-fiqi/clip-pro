import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/clip_model.dart';
import 'package:video_clipper_app/core/models/clip_transform_model.dart';
import 'package:video_clipper_app/core/models/timeline_model.dart';

void main() {
  group('Crop & Transform Studio Comprehensive Unit & Integration Tests (Phase 1)', () {
    test('1. Rotasi sudut halus arbitrer (-180° s/d +180°)', () {
      const t0 = ClipTransformModel(rotationDegrees: 0.0);
      expect(t0.rotationDegrees, 0.0);

      const t45 = ClipTransformModel(rotationDegrees: 45.0);
      expect(t45.rotationDegrees, 45.0);

      const tNeg90 = ClipTransformModel(rotationDegrees: -90.0);
      expect(tNeg90.rotationDegrees, -90.0);

      const t180 = ClipTransformModel(rotationDegrees: 180.0);
      expect(t180.rotationDegrees, 180.0);

      const tNeg180 = ClipTransformModel(rotationDegrees: -180.0);
      expect(tNeg180.rotationDegrees, -180.0);
    });

    test('2. Seluruh rasio aspek kanvas (termasuk 1.85:1, 2.35:1, 2.39:1)', () {
      const rOrig = ClipTransformModel(canvasRatio: CanvasRatioMode.original);
      expect(rOrig.targetAspectRatio, isNull);

      const r9x16 = ClipTransformModel(canvasRatio: CanvasRatioMode.ratio9x16);
      expect(r9x16.targetAspectRatio, closeTo(9.0 / 16.0, 0.0001));

      const r16x9 = ClipTransformModel(canvasRatio: CanvasRatioMode.ratio16x9);
      expect(r16x9.targetAspectRatio, closeTo(16.0 / 9.0, 0.0001));

      const r1x1 = ClipTransformModel(canvasRatio: CanvasRatioMode.ratio1x1);
      expect(r1x1.targetAspectRatio, 1.0);

      const r4x5 = ClipTransformModel(canvasRatio: CanvasRatioMode.ratio4x5);
      expect(r4x5.targetAspectRatio, 0.8);

      const r3x4 = ClipTransformModel(canvasRatio: CanvasRatioMode.ratio3x4);
      expect(r3x4.targetAspectRatio, 0.75);

      const r4x3 = ClipTransformModel(canvasRatio: CanvasRatioMode.ratio4x3);
      expect(r4x3.targetAspectRatio, closeTo(4.0 / 3.0, 0.0001));

      const r185 = ClipTransformModel(canvasRatio: CanvasRatioMode.ratio185x1);
      expect(r185.targetAspectRatio, closeTo(1.85, 0.001));

      const r235 = ClipTransformModel(canvasRatio: CanvasRatioMode.ratio235x1);
      expect(r235.targetAspectRatio, closeTo(2.35, 0.001));

      const r239 = ClipTransformModel(canvasRatio: CanvasRatioMode.ratio239x1);
      expect(r239.targetAspectRatio, closeTo(2.39, 0.001));

      const r21x9 = ClipTransformModel(canvasRatio: CanvasRatioMode.ratio21x9);
      expect(r21x9.targetAspectRatio, closeTo(21.0 / 9.0, 0.0001));
    });

    test('3. Crop boundaries validasi dan deteksi hasCustomCrop', () {
      const defaultTransform = ClipTransformModel();
      expect(defaultTransform.hasCustomCrop, isFalse);

      const croppedTransform = ClipTransformModel(
        cropLeft: 0.1,
        cropTop: 0.15,
        cropRight: 0.85,
        cropBottom: 0.9,
      );
      expect(croppedTransform.hasCustomCrop, isTrue);

      // Boundaries validation
      expect(
        () => ClipTransformModel(cropLeft: 0.9, cropRight: 0.3),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => ClipTransformModel(cropTop: 0.8, cropBottom: 0.2),
        throwsA(isA<AssertionError>()),
      );
    });

    test('4. Kombinasi Flip Horizontal dan Vertical', () {
      const tFlip = ClipTransformModel(
        flipHorizontal: true,
        flipVertical: true,
      );
      expect(tFlip.flipHorizontal, isTrue);
      expect(tFlip.flipVertical, isTrue);
    });

    test('5. Non-destruktif persistence pada ClipModel dan TimelineModel (Undo/Redo)', () {
      final clip = ClipModel(
        id: 'clip_crop_1',
        sourcePath: '/path/to/test.mp4',
        startSource: 0.0,
        endSource: 10.0,
        transform: const ClipTransformModel(
          rotationDegrees: 90.0,
          flipHorizontal: true,
          cropLeft: 0.1,
          cropTop: 0.1,
          cropRight: 0.9,
          cropBottom: 0.9,
          canvasRatio: CanvasRatioMode.ratio9x16,
          fitMode: FitMode.fill,
        ),
      );

      final timeline = TimelineModel(clips: [clip]);
      final history = TimelineHistory();
      // Rekam state awal sebelum aksi edit
      history.recordState(timeline);

      // Ubah rotasi ke 180°
      final updatedClip = clip.copyWith(
        transform: clip.transform.copyWith(rotationDegrees: 180.0),
      );
      final updatedTimeline = timeline.updateClip(updatedClip);

      expect(updatedTimeline.clips.first.transform.rotationDegrees, 180.0);

      // Lakukan Undo
      final previousTimeline = history.undo(updatedTimeline);
      expect(previousTimeline, isNotNull);
      expect(previousTimeline!.clips.first.transform.rotationDegrees, 90.0);
      expect(previousTimeline.clips.first.transform.flipHorizontal, isTrue);
      expect(previousTimeline.clips.first.transform.cropLeft, 0.1);

      // Lakukan Redo
      final redoTimeline = history.redo(previousTimeline);
      expect(redoTimeline, isNotNull);
      expect(redoTimeline!.clips.first.transform.rotationDegrees, 180.0);
    });

    test('6. Serialisasi JSON dan rekonstruksi ClipTransformModel', () {
      const original = ClipTransformModel(
        canvasRatio: CanvasRatioMode.ratio185x1,
        fitMode: FitMode.fill,
        backgroundType: CanvasBackgroundType.blur,
        rotationDegrees: -45.5,
        flipHorizontal: true,
        flipVertical: false,
        cropLeft: 0.05,
        cropTop: 0.1,
        cropRight: 0.95,
        cropBottom: 0.85,
        backgroundColorHex: '14141E',
      );

      final json = original.toJson();
      final restored = ClipTransformModel.fromJson(json);

      expect(restored.canvasRatio, CanvasRatioMode.ratio185x1);
      expect(restored.fitMode, FitMode.fill);
      expect(restored.backgroundType, CanvasBackgroundType.blur);
      expect(restored.rotationDegrees, -45.5);
      expect(restored.flipHorizontal, isTrue);
      expect(restored.flipVertical, isFalse);
      expect(restored.cropLeft, 0.05);
      expect(restored.cropTop, 0.1);
      expect(restored.cropRight, 0.95);
      expect(restored.cropBottom, 0.85);
      expect(restored.backgroundColorHex, '14141E');
    });
  });
}
