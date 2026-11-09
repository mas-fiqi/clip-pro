import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/color_adjustment_model.dart';
import 'package:video_clipper_app/core/models/clip_model.dart';

void main() {
  group('ColorAdjustmentModel Unit Tests', () {
    test('Nilai default tanpa penyesuaian (hasAdjustment false)', () {
      const defaultAdj = ColorAdjustmentModel();
      expect(defaultAdj.preset, FilterPreset.normal);
      expect(defaultAdj.brightness, 0.0);
      expect(defaultAdj.contrast, 0.0);
      expect(defaultAdj.saturation, 0.0);
      expect(defaultAdj.vignette, 0.0);
      expect(defaultAdj.hasAdjustment, isFalse);
    });

    test('Validasi rentang nilai slider -1.0 s/d 1.0', () {
      expect(
        () => ColorAdjustmentModel(brightness: 1.5),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => ColorAdjustmentModel(contrast: -1.2),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => ColorAdjustmentModel(vignette: 2.0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('Integrasi ke ClipModel dan serialisasi JSON', () {
      final clip = ClipModel(
        id: 'c1',
        sourcePath: '/video.mp4',
        startSource: 0.0,
        endSource: 10.0,
        adjustment: const ColorAdjustmentModel(
          preset: FilterPreset.cinematic,
          brightness: 0.1,
          contrast: 0.2,
          saturation: 0.3,
          vignette: 0.5,
        ),
      );

      expect(clip.adjustment.hasAdjustment, isTrue);

      final json = clip.toJson();
      final restored = ClipModel.fromJson(json);

      expect(restored.adjustment.preset, FilterPreset.cinematic);
      expect(restored.adjustment.brightness, 0.1);
      expect(restored.adjustment.contrast, 0.2);
      expect(restored.adjustment.saturation, 0.3);
      expect(restored.adjustment.vignette, 0.5);
    });
  });
}

