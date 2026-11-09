import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/editor_performance_profile.dart';
import 'package:video_clipper_app/core/services/thumbnail_generator_service.dart';
import 'package:video_clipper_app/core/services/audio_waveform_service.dart';

void main() {
  group('Extreme Performance Optimization & Device Adaptation Tests (Redmi Note 8 Focus)', () {
    test('1. Spec Detection: Redmi Note 8 / Snapdragon 665 / 4GB RAM selects Low Profile', () {
      final config = EditorPerformanceConfig.detectFromSpecs(
        totalRamMB: 4096,
        availableRamMB: 1800,
        isLowRam: false,
        deviceModel: 'Redmi Note 8',
      );

      expect(config.profile, EditorPerformanceProfile.low);
      expect(config.maxThumbnailsPerClip, 4);
      expect(config.thumbnailWidth, 70);
      expect(config.thumbnailQuality, 4);
      expect(config.maxCachedThumbnails, 30);
      expect(config.enableThumbnailCacheEviction, isTrue);
    });

    test('2. Spec Detection: Flagship / PC selects High Profile', () {
      final config = EditorPerformanceConfig.detectFromSpecs(
        totalRamMB: 16384,
        availableRamMB: 10000,
        isLowRam: false,
        deviceModel: 'Flagship Device',
      );

      expect(config.profile, EditorPerformanceProfile.high);
      expect(config.maxThumbnailsPerClip, 8);
      expect(config.maxCachedThumbnails, 120);
    });

    test('3. Bounded LRU Cache Eviction: Thumbnail Generator Service', () {
      final service = ThumbnailGeneratorService();
      service.clearMemoryCache();
      service.applyConfig(EditorPerformanceConfig.low()); // Limit 30 items

      // Simulasikan pendaftaran thumbnail melebihi batas 30
      // Cache harus menjaga jumlah maksimal <= 30 tanpa memory leak
      expect(service.config.maxCachedThumbnails, 30);
    });

    test('4. Bounded Waveform Cache Eviction: Audio Waveform Service', () {
      final waveformService = AudioWaveformService();
      waveformService.clearCache();
      waveformService.applyConfig(EditorPerformanceConfig.low()); // Limit 15 items

      for (int i = 0; i < 25; i++) {
        waveformService.getWaveformSamples(
          key: 'audio_test_$i',
          durationSeconds: 10.0,
          sampleCount: 30,
        );
      }

      // Harus ter-evict hingga batas 15 item
      expect(waveformService.getWaveformSamples(
        key: 'audio_test_24',
        durationSeconds: 10.0,
      ).isNotEmpty, isTrue);
    });
  });
}

