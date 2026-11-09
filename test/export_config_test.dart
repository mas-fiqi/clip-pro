import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/export_config_model.dart';

void main() {
  group('ExportConfigModel Unit Tests', () {
    test('Nilai default konfigurasi ekspor (720p HD, 30 FPS, Standard Bitrate)', () {
      const config = ExportConfigModel();
      expect(config.resolution, ExportResolutionPreset.res720p);
      expect(config.targetHeight, 720);
      expect(config.fps, ExportFps.fps30);
      expect(config.fpsValue, 30);
      expect(config.bitrateQuality, ExportBitrateQuality.standard);
      expect(config.videoBitrateKbps, 3000);
      expect(config.includeAudio, isTrue);
    });

    test('Perhitungan estimasi ukuran file proporsional durasi & bitrate', () {
      const config720p = ExportConfigModel(
        resolution: ExportResolutionPreset.res720p,
        bitrateQuality: ExportBitrateQuality.standard, // 3000 kbps + 128 kbps audio = 3128 kbps
        includeAudio: true,
      );

      // 60 detik video: (3128 * 60) / 8192 = ~22.91 MB
      final estimated60s = config720p.estimateFileSizeMB(60.0);
      expect(estimated60s, closeTo(22.9, 0.2));

      // Tanpa audio: (3000 * 60) / 8192 = ~21.97 MB
      final noAudio = config720p.copyWith(includeAudio: false);
      final estimatedNoAudio = noAudio.estimateFileSizeMB(60.0);
      expect(estimatedNoAudio, closeTo(21.9, 0.2));
    });

    test('Skalabilitas resolusi target height & 4K UHD', () {
      const c360 = ExportConfigModel(resolution: ExportResolutionPreset.res360p);
      expect(c360.targetHeight, 360);
      expect(c360.maxDimension, 640);

      const c480 = ExportConfigModel(resolution: ExportResolutionPreset.res480p);
      expect(c480.targetHeight, 480);
      expect(c480.maxDimension, 854);

      const c720 = ExportConfigModel(resolution: ExportResolutionPreset.res720p);
      expect(c720.targetHeight, 720);
      expect(c720.maxDimension, 1280);

      const c1080 = ExportConfigModel(resolution: ExportResolutionPreset.res1080p);
      expect(c1080.targetHeight, 1080);
      expect(c1080.maxDimension, 1920);

      const c1440 = ExportConfigModel(resolution: ExportResolutionPreset.res1440p);
      expect(c1440.targetHeight, 1440);
      expect(c1440.maxDimension, 2560);

      const c4k = ExportConfigModel(resolution: ExportResolutionPreset.res4k);
      expect(c4k.targetHeight, 2160);
      expect(c4k.maxDimension, 3840);
      expect(c4k.videoBitrateKbps, 20000);
    });

    test('Validasi seluruh opsi frame rate FPS (24, 25, 30, 50, 60)', () {
      const f24 = ExportConfigModel(fps: ExportFps.fps24);
      expect(f24.fpsValue, 24);

      const f25 = ExportConfigModel(fps: ExportFps.fps25);
      expect(f25.fpsValue, 25);

      const f30 = ExportConfigModel(fps: ExportFps.fps30);
      expect(f30.fpsValue, 30);

      const f50 = ExportConfigModel(fps: ExportFps.fps50);
      expect(f50.fpsValue, 50);

      const f60 = ExportConfigModel(fps: ExportFps.fps60);
      expect(f60.fpsValue, 60);
    });

    test('Serialisasi JSON ExportConfigModel mencakup 4K, FPS baru & Encoder Mode', () {
      const original = ExportConfigModel(
        resolution: ExportResolutionPreset.res4k,
        fps: ExportFps.fps50,
        bitrateQuality: ExportBitrateQuality.high,
        encoderMode: ExportEncoderMode.hardware,
        includeAudio: false,
      );

      final json = original.toJson();
      final restored = ExportConfigModel.fromJson(json);

      expect(restored.resolution, ExportResolutionPreset.res4k);
      expect(restored.fps, ExportFps.fps50);
      expect(restored.fpsValue, 50);
      expect(restored.targetHeight, 2160);
      expect(restored.bitrateQuality, ExportBitrateQuality.high);
      expect(restored.encoderMode, ExportEncoderMode.hardware);
      expect(restored.includeAudio, isFalse);
    });

    test('Validasi opsi Encoder Mode (Auto, Hardware, Software)', () {
      const autoConfig = ExportConfigModel(encoderMode: ExportEncoderMode.auto);
      expect(autoConfig.encoderMode, ExportEncoderMode.auto);

      const hwConfig = ExportConfigModel(encoderMode: ExportEncoderMode.hardware);
      expect(hwConfig.encoderMode, ExportEncoderMode.hardware);

      const swConfig = ExportConfigModel(encoderMode: ExportEncoderMode.software);
      expect(swConfig.encoderMode, ExportEncoderMode.software);
    });
  });
}
