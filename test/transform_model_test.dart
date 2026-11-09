import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/clip_model.dart';
import 'package:video_clipper_app/core/models/clip_transform_model.dart';

void main() {
  group('ClipTransformModel Unit Tests (Extended Phase 7 - Bagian 9)', () {
    test('Perhitungan seluruh rasio preset dan custom yang benar', () {
      const tOriginal = ClipTransformModel(canvasRatio: CanvasRatioMode.original);
      expect(tOriginal.targetAspectRatio, isNull);

      const t9x16 = ClipTransformModel(canvasRatio: CanvasRatioMode.ratio9x16);
      expect(t9x16.targetAspectRatio, closeTo(9.0 / 16.0, 0.0001));

      const t16x9 = ClipTransformModel(canvasRatio: CanvasRatioMode.ratio16x9);
      expect(t16x9.targetAspectRatio, closeTo(16.0 / 9.0, 0.0001));

      const t1x1 = ClipTransformModel(canvasRatio: CanvasRatioMode.ratio1x1);
      expect(t1x1.targetAspectRatio, 1.0);

      const t4x5 = ClipTransformModel(canvasRatio: CanvasRatioMode.ratio4x5);
      expect(t4x5.targetAspectRatio, 0.8);

      const t3x4 = ClipTransformModel(canvasRatio: CanvasRatioMode.ratio3x4);
      expect(t3x4.targetAspectRatio, 0.75);

      const t4x3 = ClipTransformModel(canvasRatio: CanvasRatioMode.ratio4x3);
      expect(t4x3.targetAspectRatio, closeTo(4.0 / 3.0, 0.0001));

      const t2x1 = ClipTransformModel(canvasRatio: CanvasRatioMode.ratio2x1);
      expect(t2x1.targetAspectRatio, 2.0);

      const t21x9 = ClipTransformModel(canvasRatio: CanvasRatioMode.ratio21x9);
      expect(t21x9.targetAspectRatio, closeTo(21.0 / 9.0, 0.0001));

      const t185x1 = ClipTransformModel(canvasRatio: CanvasRatioMode.ratio185x1);
      expect(t185x1.targetAspectRatio, closeTo(1.85, 0.001));

      const t235x1 = ClipTransformModel(canvasRatio: CanvasRatioMode.ratio235x1);
      expect(t235x1.targetAspectRatio, closeTo(2.35, 0.001));

      const t239x1 = ClipTransformModel(canvasRatio: CanvasRatioMode.ratio239x1);
      expect(t239x1.targetAspectRatio, closeTo(2.39, 0.001));

      const tCustom = ClipTransformModel(
        canvasRatio: CanvasRatioMode.custom,
        customAspectRatio: 1.85,
      );
      expect(tCustom.targetAspectRatio, 1.85);
    });

    test('FitMode dan CanvasBackgroundType tersimpan dalam copyWith dan JSON', () {
      const model = ClipTransformModel(
        canvasRatio: CanvasRatioMode.ratio9x16,
        fitMode: FitMode.fit,
        backgroundType: CanvasBackgroundType.blur,
        backgroundColorHex: '1E1E2C',
      );

      final json = model.toJson();
      final restored = ClipTransformModel.fromJson(json);

      expect(restored.canvasRatio, CanvasRatioMode.ratio9x16);
      expect(restored.fitMode, FitMode.fit);
      expect(restored.backgroundType, CanvasBackgroundType.blur);
      expect(restored.backgroundColorHex, '1E1E2C');
    });

    test('Validasi rotasi halus dan kelipatan derajat', () {
      const t45 = ClipTransformModel(rotationDegrees: 45.0);
      expect(t45.rotationDegrees, 45.0);

      const t90 = ClipTransformModel(rotationDegrees: 90.0);
      expect(t90.rotationDegrees, 90.0);

      const t180 = ClipTransformModel(rotationDegrees: 180.0);
      expect(t180.rotationDegrees, 180.0);

      const tNeg = ClipTransformModel(rotationDegrees: -135.5);
      expect(tNeg.rotationDegrees, -135.5);
    });

    test('Validasi crop boundaries', () {
      expect(
        () => ClipTransformModel(cropLeft: 0.8, cropRight: 0.2), // left > right
        throwsA(isA<AssertionError>()),
      );

      const validCrop = ClipTransformModel(
        cropLeft: 0.1,
        cropTop: 0.1,
        cropRight: 0.9,
        cropBottom: 0.9,
      );
      expect(validCrop.hasCustomCrop, isTrue);
    });

    test('Transformasi disimpan di ClipModel dan diserialisasi JSON', () {
      final clip = ClipModel(
        id: 'c1',
        sourcePath: '/test.mp4',
        startSource: 0.0,
        endSource: 5.0,
        transform: const ClipTransformModel(
          canvasRatio: CanvasRatioMode.ratio9x16,
          fitMode: FitMode.fill,
          rotationDegrees: 90,
          flipHorizontal: true,
          cropLeft: 0.05,
          cropRight: 0.95,
        ),
      );

      final json = clip.toJson();
      final reconstructed = ClipModel.fromJson(json);

      expect(reconstructed.transform.canvasRatio, CanvasRatioMode.ratio9x16);
      expect(reconstructed.transform.fitMode, FitMode.fill);
      expect(reconstructed.transform.rotationDegrees, 90);
      expect(reconstructed.transform.flipHorizontal, isTrue);
      expect(reconstructed.transform.cropLeft, 0.05);
      expect(reconstructed.transform.cropRight, 0.95);
    });
  });
}
