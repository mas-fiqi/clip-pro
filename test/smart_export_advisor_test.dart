import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/benchmark_profile_model.dart';
import 'package:video_clipper_app/core/models/device_capability_model.dart';
import 'package:video_clipper_app/core/models/export_config_model.dart';
import 'package:video_clipper_app/core/services/smart_export_advisor.dart';

void main() {
  group('Phase 3: Device Capability & Smart Export Tests', () {
    test('DeviceCapabilityModel parsing & hardware detection', () {
      final json = {
        'deviceModel': 'Xiaomi Redmi Note 8',
        'androidVersion': '11',
        'sdkInt': 30,
        'supportedAbis': ['arm64-v8a', 'armeabi-v7a'],
        'totalRamMB': 3720,
        'availableRamMB': 1550,
        'isLowRam': false,
        'availableStorageMB': 4100,
        'totalStorageMB': 49000,
        'videoEncoders': [
          {
            'name': 'c2.qti.avc.encoder',
            'mimeType': 'video/avc',
            'isHardwareAccelerated': true,
            'maxWidth': 3840,
            'maxHeight': 2160,
            'maxFps': 30,
            'colorFormats': [21, 2130708361],
          },
          {
            'name': 'c2.android.avc.encoder',
            'mimeType': 'video/avc',
            'isHardwareAccelerated': false,
            'maxWidth': 1920,
            'maxHeight': 1080,
            'maxFps': 30,
          }
        ],
      };

      final model = DeviceCapabilityModel.fromJson(json);
      expect(model.deviceModel, 'Xiaomi Redmi Note 8');
      expect(model.hasH264HardwareEncoder, isTrue);
      expect(model.isHardwareResolutionSupported(1920, 1080, 30), isTrue);
      expect(model.isHardwareResolutionSupported(3840, 2160, 30), isTrue);
      expect(model.isHardwareResolutionSupported(3840, 2160, 60), isFalse); // exceeds 30fps
    });

    test('Storage and Thermal evaluation logic', () {
      const storageSafe = StorageAndThermalInfo(
        availableStorageMB: 5000,
        batteryTemperatureCelsius: 35.0,
      );
      expect(storageSafe.evaluateStorageRisk(50.0), StorageRiskStatus.safe);
      expect(storageSafe.thermalStatus, ThermalWarningStatus.normal);

      const storageWarning = StorageAndThermalInfo(
        availableStorageMB: 150,
        batteryTemperatureCelsius: 40.5,
      );
      expect(storageWarning.evaluateStorageRisk(50.0), StorageRiskStatus.warning);
      expect(storageWarning.thermalStatus, ThermalWarningStatus.warm);

      const storageCritical = StorageAndThermalInfo(
        availableStorageMB: 30,
        batteryTemperatureCelsius: 45.0,
      );
      expect(storageCritical.evaluateStorageRisk(50.0), StorageRiskStatus.critical);
      expect(storageCritical.thermalStatus, ThermalWarningStatus.hot);
    });

    test('BenchmarkRecord and BenchmarkProfile calculation', () {
      final profile = BenchmarkProfile();
      profile.addRecord(BenchmarkRecord(
        encoder: 'libx264',
        resolution: ExportResolutionPreset.res720p,
        fps: 30,
        sampleDurationSeconds: 10.0,
        executionTimeMs: 1750,
        outputSizeBytes: 1865254,
        isSuccess: true,
        timestamp: DateTime.now(),
      ));
      profile.addRecord(BenchmarkRecord(
        encoder: 'h264_mediacodec',
        resolution: ExportResolutionPreset.res720p,
        fps: 30,
        sampleDurationSeconds: 10.0,
        executionTimeMs: 2940,
        outputSizeBytes: 1360015,
        isSuccess: true,
        timestamp: DateTime.now(),
      ));

      // Verifikasi penentuan encoder tercepat berdasarkan data riil
      final faster = profile.getFasterEncoder(
        resolution: ExportResolutionPreset.res720p,
        fps: 30,
      );
      expect(faster, 'software'); // Software (1.75s) lebih cepat daripada HW (2.94s)
    });

    test('SmartExportAdvisor Auto selection heuristic', () {
      final caps = DeviceCapabilityModel(
        videoEncoders: [
          const VideoEncoderCapability(
            name: 'c2.qti.avc.encoder',
            mimeType: 'video/avc',
            isHardwareAccelerated: true,
            maxWidth: 3840,
            maxHeight: 2160,
            maxFps: 30,
          ),
        ],
      );

      // Resolusi 720p tanpa benchmark data: default software (CPU multi-threading responsif)
      const config720p = ExportConfigModel(
        resolution: ExportResolutionPreset.res720p,
        fps: ExportFps.fps30,
      );
      final choice720p = SmartExportAdvisor.resolveAutoEncoder(
        config: config720p,
        capabilities: caps,
      );
      expect(choice720p, 'software');

      // Resolusi 1080p: hardware preferred jika didukung
      const config1080p = ExportConfigModel(
        resolution: ExportResolutionPreset.res1080p,
        fps: ExportFps.fps30,
      );
      final choice1080p = SmartExportAdvisor.resolveAutoEncoder(
        config: config1080p,
        capabilities: caps,
      );
      expect(choice1080p, 'hardware');

      // Resolusi 4K: jika perangkat tidak mendukung HW, mundur ke software
      const unsupportedCaps = DeviceCapabilityModel(videoEncoders: []);
      const config4k = ExportConfigModel(
        resolution: ExportResolutionPreset.res4k,
        fps: ExportFps.fps30,
      );
      final choice4k = SmartExportAdvisor.resolveAutoEncoder(
        config: config4k,
        capabilities: unsupportedCaps,
      );
      expect(choice4k, 'software');
    });

    test('Compatibility evaluation & description', () {
      const caps = DeviceCapabilityModel(
        totalRamMB: 3720,
        isLowRam: false,
      );

      const configRecommended = ExportConfigModel(
        resolution: ExportResolutionPreset.res720p,
        fps: ExportFps.fps30,
      );
      expect(
        SmartExportAdvisor.evaluateCompatibility(config: configRecommended, capabilities: caps),
        CompatibilityLevel.recommended,
      );

      const config4k = ExportConfigModel(
        resolution: ExportResolutionPreset.res4k,
        fps: ExportFps.fps30,
      );
      expect(
        SmartExportAdvisor.evaluateCompatibility(config: config4k, capabilities: caps),
        CompatibilityLevel.supported,
      );

      // Perangkat RAM terbatas
      const lowRamCaps = DeviceCapabilityModel(
        totalRamMB: 2048,
        isLowRam: true,
      );
      expect(
        SmartExportAdvisor.evaluateCompatibility(config: config4k, capabilities: lowRamCaps),
        CompatibilityLevel.limited,
      );
    });

    test('Quick presets (Draft, Standard, High Quality)', () {
      const caps = DeviceCapabilityModel();
      final draft = SmartExportAdvisor.getPresetRecommendation(presetName: 'draft', capabilities: caps);
      expect(draft.resolution, ExportResolutionPreset.res480p);

      final standard = SmartExportAdvisor.getPresetRecommendation(presetName: 'standard', capabilities: caps);
      expect(standard.resolution, ExportResolutionPreset.res720p);

      final high = SmartExportAdvisor.getPresetRecommendation(presetName: 'high', capabilities: caps);
      expect(high.bitrateQuality, ExportBitrateQuality.high);
    });
  });
}

