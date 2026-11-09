import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/clip_model.dart';
import 'package:video_clipper_app/core/models/quality_enhancement_model.dart';

void main() {
  group('Phase 4 — Quality Enhancement & AI Video Repair Unit Tests', () {
    test('1. Default QualityEnhancementModel has no active enhancements', () {
      const q = QualityEnhancementModel();
      expect(q.hasEnhancement, isFalse);
      expect(q.noiseReduction, isFalse);
      expect(q.deflicker, isFalse);
      expect(q.stabilization, isFalse);
      expect(q.autoEnhance, isFalse);
      expect(q.targetQuality, TargetQualityProfile.standard);
      expect(q.buildFFmpegFilters(), isEmpty);
    });

    test('2. Noise reduction generates valid hqdn3d filter with intensity', () {
      const q = QualityEnhancementModel(
        noiseReduction: true,
        noiseIntensity: 0.8,
      );
      expect(q.hasEnhancement, isTrue);
      final filters = q.buildFFmpegFilters();
      expect(filters.length, 1);
      expect(filters.first, contains('hqdn3d='));
    });

    test('3. Deflicker and Stabilization generate valid filters', () {
      const q = QualityEnhancementModel(
        deflicker: true,
        deflickerSize: 0.6,
        stabilization: true,
        stabilizationStrength: 0.7,
      );
      expect(q.hasEnhancement, isTrue);
      final filters = q.buildFFmpegFilters();
      expect(filters.any((f) => f.contains('deflicker')), isTrue);
      expect(filters.any((f) => f.contains('deshake')), isTrue);
    });

    test('4. Auto Enhance applies eq contrast/brightness and unsharp filter', () {
      const q = QualityEnhancementModel(
        autoEnhance: true,
      );
      expect(q.hasEnhancement, isTrue);
      final filters = q.buildFFmpegFilters();
      expect(filters.any((f) => f.contains('eq=contrast=')), isTrue);
      expect(filters.any((f) => f.contains('unsharp=')), isTrue);
    });

    test('5. TargetQualityProfile enum values and copyWith', () {
      const q = QualityEnhancementModel();
      final qHigh = q.copyWith(targetQuality: TargetQualityProfile.high);
      expect(qHigh.hasEnhancement, isTrue);
      expect(qHigh.targetQuality, TargetQualityProfile.high);

      final qUltra = q.copyWith(targetQuality: TargetQualityProfile.ultra);
      expect(qUltra.targetQuality, TargetQualityProfile.ultra);
    });

    test('6. Full QualityEnhancementModel serialization and ClipModel integration', () {
      final originalClip = ClipModel(
        id: 'clip_enh_1',
        sourcePath: '/tmp/test.mp4',
        startSource: 0.0,
        endSource: 10.0,
        quality: const QualityEnhancementModel(
          noiseReduction: true,
          noiseIntensity: 0.6,
          deflicker: true,
          deflickerSize: 0.4,
          stabilization: true,
          stabilizationStrength: 0.75,
          autoEnhance: true,
          targetQuality: TargetQualityProfile.high,
        ),
      );

      final json = originalClip.toJson();
      expect(json['quality'], isNotNull);

      final restoredClip = ClipModel.fromJson(json);
      expect(restoredClip.quality.noiseReduction, isTrue);
      expect(restoredClip.quality.noiseIntensity, 0.6);
      expect(restoredClip.quality.deflicker, isTrue);
      expect(restoredClip.quality.deflickerSize, 0.4);
      expect(restoredClip.quality.stabilization, isTrue);
      expect(restoredClip.quality.stabilizationStrength, 0.75);
      expect(restoredClip.quality.autoEnhance, isTrue);
      expect(restoredClip.quality.targetQuality, TargetQualityProfile.high);
      expect(restoredClip.quality.hasEnhancement, isTrue);
    });
  });
}
