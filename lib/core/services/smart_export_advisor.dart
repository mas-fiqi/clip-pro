import '../models/benchmark_profile_model.dart';
import '../models/device_capability_model.dart';
import '../models/export_config_model.dart';

enum CompatibilityLevel {
  recommended,
  supported,
  limited,
  notSupported,
}

/// Evaluator cerdas pemilihan encoder, resolusi, FPS, dan estimasi waktu ekspor
class SmartExportAdvisor {
  /// Memutuskan encoder terbaik untuk mode AUTO
  static String resolveAutoEncoder({
    required ExportConfigModel config,
    required DeviceCapabilityModel capabilities,
    BenchmarkProfile? benchmarkProfile,
  }) {
    // 1. Cek apakah perangkat mendukung hardware encoder untuk AVC (H.264)
    final hwSupported = capabilities.isHardwareResolutionSupported(
      config.maxDimension,
      config.targetHeight,
      config.fpsValue,
    );

    // Jika hardware tidak didukung atau tidak ada, mutlak gunakan software
    if (!hwSupported && capabilities.videoEncoders.isNotEmpty) {
      return 'software';
    }

    // 2. Evaluasi profil benchmark lokal jika tersedia data komparatif
    if (benchmarkProfile != null) {
      final faster = benchmarkProfile.getFasterEncoder(
        resolution: config.resolution,
        fps: config.fpsValue,
      );
      if (faster != null) {
        return faster; // 'software' atau 'hardware' berdasarkan fakta aktual perangkat
      }
    }

    // 3. Kebijakan resolusi default:
    // - Resolusi rendah s/d menengah (360p, 480p, 720p): Software encoding (libx264 ultrafast multi-threaded)
    //   terbukti sangat kencang pada octa-core tanpa overhead frame buffer GPU-to-CPU context switch.
    // - Resolusi tinggi (1080p, 1440p, 4K): Hardware encoder (MediaCodec) lebih efisien dalam memori & termal
    //   jika didukung chip perangkat.
    if (config.resolution == ExportResolutionPreset.res360p ||
        config.resolution == ExportResolutionPreset.res480p ||
        config.resolution == ExportResolutionPreset.res720p) {
      return 'software';
    } else {
      return hwSupported ? 'hardware' : 'software';
    }
  }

  /// Evaluasi tingkat kompatibilitas resolusi & FPS pada perangkat
  static CompatibilityLevel evaluateCompatibility({
    required ExportConfigModel config,
    required DeviceCapabilityModel capabilities,
  }) {
    // 4K pada perangkat dengan RAM <= 3GB atau hardware encoder tidak mendukung 4K
    if (config.resolution == ExportResolutionPreset.res4k) {
      if (capabilities.isLowRam == true || (capabilities.totalRamMB != null && capabilities.totalRamMB! <= 3500)) {
        return CompatibilityLevel.limited;
      }
      final supports4kHw = capabilities.isHardwareResolutionSupported(3840, 2160, config.fpsValue);
      if (!supports4kHw && capabilities.videoEncoders.isNotEmpty) {
        return CompatibilityLevel.limited;
      }
    }

    // FPS 60 pada resolusi 1440p atau 4K
    if (config.fps == ExportFps.fps60 &&
        (config.resolution == ExportResolutionPreset.res1440p ||
         config.resolution == ExportResolutionPreset.res4k)) {
      return CompatibilityLevel.limited;
    }

    // Resolusi standar (720p / 1080p @ 30fps)
    if (config.resolution == ExportResolutionPreset.res720p &&
        config.fps == ExportFps.fps30) {
      return CompatibilityLevel.recommended;
    }

    return CompatibilityLevel.supported;
  }

  /// Menghasilkan label penjelasan kompatibilitas
  static String getCompatibilityDescription({
    required ExportConfigModel config,
    required DeviceCapabilityModel capabilities,
  }) {
    final level = evaluateCompatibility(config: config, capabilities: capabilities);
    switch (level) {
      case CompatibilityLevel.recommended:
        return 'Paling optimal untuk kecepatan rendering, kualitas, dan efisiensi memori.';
      case CompatibilityLevel.supported:
        return 'Didukung penuh oleh perangkat dan engine rendering.';
      case CompatibilityLevel.limited:
        if (config.resolution == ExportResolutionPreset.res4k) {
          return 'Beban pemrosesan tinggi. Pastikan memori dan daya baterai mencukupi.';
        }
        return 'Konfigurasi membutuhkan daya komputasi tinggi pada perangkat ini.';
      case CompatibilityLevel.notSupported:
        return 'Format atau resolusi melebihi spesifikasi encoder perangkat.';
    }
  }

  /// Menghasilkan rekomendasi preset siap pakai (Draft, Standard, High Quality)
  static ExportConfigModel getPresetRecommendation({
    required String presetName, // 'draft', 'standard', 'high'
    required DeviceCapabilityModel capabilities,
  }) {
    switch (presetName.toLowerCase()) {
      case 'draft':
        return const ExportConfigModel(
          resolution: ExportResolutionPreset.res480p,
          fps: ExportFps.fps30,
          bitrateQuality: ExportBitrateQuality.low,
          encoderMode: ExportEncoderMode.auto,
        );
      case 'high':
        final canDo1080p = capabilities.isHardwareResolutionSupported(1920, 1080, 30);
        return ExportConfigModel(
          resolution: canDo1080p ? ExportResolutionPreset.res1080p : ExportResolutionPreset.res720p,
          fps: ExportFps.fps30,
          bitrateQuality: ExportBitrateQuality.high,
          encoderMode: ExportEncoderMode.auto,
        );
      case 'standard':
      default:
        return const ExportConfigModel(
          resolution: ExportResolutionPreset.res720p,
          fps: ExportFps.fps30,
          bitrateQuality: ExportBitrateQuality.standard,
          encoderMode: ExportEncoderMode.auto,
        );
    }
  }

  /// Estimasi waktu pemrosesan video (Kualitatif & Kuantitatif aman)
  static String estimateExportDurationText({
    required double totalDurationSeconds,
    required ExportConfigModel config,
    BenchmarkProfile? benchmarkProfile,
  }) {
    if (totalDurationSeconds <= 0) return 'Tidak diketahui';

    // Cari data benchmark relevan
    BenchmarkRecord? record;
    if (benchmarkProfile != null) {
      record = benchmarkProfile.getRecord(
        encoder: 'libx264',
        resolution: config.resolution,
        fps: config.fpsValue,
      ) ?? benchmarkProfile.getRecord(
        encoder: 'h264_mediacodec',
        resolution: config.resolution,
        fps: config.fpsValue,
      );
    }

    if (record != null && record.speedFactor > 0) {
      final estimatedSec = (totalDurationSeconds * record.speedFactor).round();
      if (estimatedSec < 60) {
        return 'Perkiraan Cepat (~$estimatedSec detik)';
      } else {
        final mins = (estimatedSec / 60).floor();
        final remainingSec = estimatedSec % 60;
        return 'Perkiraan Sedang (~$mins m $remainingSec d)';
      }
    }

    // Heuristik kualitatif jika belum ada benchmark lokal
    final multiplier = switch (config.resolution) {
      ExportResolutionPreset.res360p => 0.25,
      ExportResolutionPreset.res480p => 0.35,
      ExportResolutionPreset.res720p => 0.5,
      ExportResolutionPreset.res1080p => 1.2,
      ExportResolutionPreset.res1440p => 2.5,
      ExportResolutionPreset.res4k => 5.0,
    };

    final rawEstimatedSec = (totalDurationSeconds * multiplier * (config.fpsValue / 30.0)).round();

    if (rawEstimatedSec <= 15) {
      return 'Perkiraan Cepat (< 15 detik)';
    } else if (rawEstimatedSec <= 60) {
      return 'Perkiraan Sedang (~$rawEstimatedSec detik)';
    } else {
      final mins = (rawEstimatedSec / 60).round();
      return 'Perkiraan Berat (~$mins menit)';
    }
  }
}

