import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/advanced_color_model.dart';
import 'package:video_clipper_app/core/models/color_adjustment_model.dart';

void main() {
  group('Phase 3 — Professional Adjust & Color Studio Tests', () {
    test('1. Default ColorAdjustmentModel has no adjustment', () {
      const adj = ColorAdjustmentModel();
      expect(adj.hasAdjustment, isFalse);
      expect(adj.preset, FilterPreset.normal);
      expect(adj.brightness, 0.0);
      expect(adj.contrast, 0.0);
      expect(adj.exposure, 0.0);
      expect(adj.highlights, 0.0);
      expect(adj.shadows, 0.0);
      expect(adj.sharpen, 0.0);
      expect(adj.clarity, 0.0);
      expect(adj.hsl.hasAdjustment, isFalse);
      expect(adj.colorWheels.hasAdjustment, isFalse);
    });

    test('2. HSL 8-Warna Channel individual modifications and copyWith', () {
      const hsl = HslChannelsModel();
      final updatedHsl = hsl.copyWith(
        red: const HslColorAdjustment(hue: 15.0, saturation: 0.25, luminance: -0.1),
        cyan: const HslColorAdjustment(hue: -10.0, saturation: 0.5),
      );

      expect(updatedHsl.hasAdjustment, isTrue);
      expect(updatedHsl.red.hue, 15.0);
      expect(updatedHsl.red.saturation, 0.25);
      expect(updatedHsl.cyan.saturation, 0.5);
      expect(updatedHsl.green.hasAdjustment, isFalse);
    });

    test('3. Color Wheels Shadows, Midtones, Highlights verification', () {
      const wheels = ColorWheelsModel();
      expect(wheels.hasAdjustment, isFalse);

      final updatedWheels = wheels.copyWith(
        shadows: const ColorWheelValue(angleDegrees: 210.0, intensity: 0.35),
        highlights: const ColorWheelValue(angleDegrees: 45.0, intensity: 0.2),
      );

      expect(updatedWheels.hasAdjustment, isTrue);
      expect(updatedWheels.shadows.angleDegrees, 210.0);
      expect(updatedWheels.shadows.intensity, 0.35);
      expect(updatedWheels.highlights.angleDegrees, 45.0);
      expect(updatedWheels.midtones.hasAdjustment, isFalse);
    });

    test('4. JSON Serialization and reconstruction preserves all professional adjust parameters', () {
      const fullAdj = ColorAdjustmentModel(
        preset: FilterPreset.tealAndOrange,
        filterIntensity: 0.85,
        brightness: 0.12,
        contrast: 0.25,
        saturation: 0.15,
        exposure: 0.08,
        highlights: -0.15,
        shadows: 0.2,
        temperature: 0.1,
        tint: -0.05,
        sharpen: 0.3,
        clarity: 0.25,
        vignette: 0.4,
        hsl: HslChannelsModel(
          orange: HslColorAdjustment(hue: 8.0, saturation: 0.3),
          blue: HslColorAdjustment(hue: -5.0, luminance: 0.1),
        ),
        colorWheels: ColorWheelsModel(
          shadows: ColorWheelValue(angleDegrees: 200.0, intensity: 0.25),
        ),
      );

      final json = fullAdj.toJson();
      final restored = ColorAdjustmentModel.fromJson(json);

      expect(restored.preset, FilterPreset.tealAndOrange);
      expect(restored.filterIntensity, 0.85);
      expect(restored.brightness, 0.12);
      expect(restored.contrast, 0.25);
      expect(restored.exposure, 0.08);
      expect(restored.highlights, -0.15);
      expect(restored.shadows, 0.2);
      expect(restored.temperature, 0.1);
      expect(restored.tint, -0.05);
      expect(restored.sharpen, 0.3);
      expect(restored.clarity, 0.25);
      expect(restored.vignette, 0.4);
      expect(restored.hsl.orange.hue, 8.0);
      expect(restored.hsl.blue.luminance, 0.1);
      expect(restored.colorWheels.shadows.angleDegrees, 200.0);
    });
  });
}

