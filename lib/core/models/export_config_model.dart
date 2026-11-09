enum ExportResolutionPreset {
  res360p,
  res480p,
  res720p,  // Default HD
  res1080p, // Full HD
  res1440p, // 2K QHD
  res4k,    // 4K UHD (2160p)
}

enum ExportFps {
  fps24,
  fps25,
  fps30,
  fps50,
  fps60,
}

enum ExportBitrateQuality {
  low,      // Hemat ruang
  standard, // Seimbang
  high,     // Kualitas tinggi
}

enum ExportEncoderMode {
  auto,     // Deteksi hardware acceleration, fallback ke software jika gagal
  hardware, // Paksa hardware encoding (MediaCodec)
  software, // Paksa software encoding (libx264)
}

/// Konfigurasi parameter ekspor profesional
class ExportConfigModel {
  final ExportResolutionPreset resolution;
  final ExportFps fps;
  final ExportBitrateQuality bitrateQuality;
  final ExportEncoderMode encoderMode;
  final bool includeAudio;

  const ExportConfigModel({
    this.resolution = ExportResolutionPreset.res720p,
    this.fps = ExportFps.fps30,
    this.bitrateQuality = ExportBitrateQuality.standard,
    this.encoderMode = ExportEncoderMode.auto,
    this.includeAudio = true,
  });

  int get fpsValue {
    switch (fps) {
      case ExportFps.fps24:
        return 24;
      case ExportFps.fps25:
        return 25;
      case ExportFps.fps30:
        return 30;
      case ExportFps.fps50:
        return 50;
      case ExportFps.fps60:
        return 60;
    }
  }

  /// Target batas tinggi piksel (height) atau bounding box untuk orientasi video
  int get targetHeight {
    switch (resolution) {
      case ExportResolutionPreset.res360p:
        return 360;
      case ExportResolutionPreset.res480p:
        return 480;
      case ExportResolutionPreset.res720p:
        return 720;
      case ExportResolutionPreset.res1080p:
        return 1080;
      case ExportResolutionPreset.res1440p:
        return 1440;
      case ExportResolutionPreset.res4k:
        return 2160;
    }
  }

  /// Target batas dimensi maksimum (lebar untuk landscape 16:9, tinggi untuk portrait 9:16)
  int get maxDimension {
    switch (resolution) {
      case ExportResolutionPreset.res360p:
        return 640;
      case ExportResolutionPreset.res480p:
        return 854;
      case ExportResolutionPreset.res720p:
        return 1280;
      case ExportResolutionPreset.res1080p:
        return 1920;
      case ExportResolutionPreset.res1440p:
        return 2560;
      case ExportResolutionPreset.res4k:
        return 3840;
    }
  }

  /// Bitrate video dalam kbps
  int get videoBitrateKbps {
    final baseBitrate = switch (resolution) {
      ExportResolutionPreset.res360p => 800,
      ExportResolutionPreset.res480p => 1500,
      ExportResolutionPreset.res720p => 3000,
      ExportResolutionPreset.res1080p => 6000,
      ExportResolutionPreset.res1440p => 10000,
      ExportResolutionPreset.res4k => 20000,
    };

    return switch (bitrateQuality) {
      ExportBitrateQuality.low => (baseBitrate * 0.6).toInt(),
      ExportBitrateQuality.standard => baseBitrate,
      ExportBitrateQuality.high => (baseBitrate * 1.5).toInt(),
    };
  }

  /// Estimasi ukuran file dalam MegaByte (MB) berdasarkan total durasi proyek
  double estimateFileSizeMB(double totalDurationSeconds) {
    if (totalDurationSeconds <= 0) return 0.0;
    final totalBitrateKbps = videoBitrateKbps + (includeAudio ? 128 : 0);
    // (kbps * detik) / 8 = KiloByte / 1024 = MegaByte
    return (totalBitrateKbps * totalDurationSeconds) / (8 * 1024);
  }

  ExportConfigModel copyWith({
    ExportResolutionPreset? resolution,
    ExportFps? fps,
    ExportBitrateQuality? bitrateQuality,
    ExportEncoderMode? encoderMode,
    bool? includeAudio,
  }) {
    return ExportConfigModel(
      resolution: resolution ?? this.resolution,
      fps: fps ?? this.fps,
      bitrateQuality: bitrateQuality ?? this.bitrateQuality,
      encoderMode: encoderMode ?? this.encoderMode,
      includeAudio: includeAudio ?? this.includeAudio,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resolution': resolution.name,
      'fps': fps.name,
      'bitrateQuality': bitrateQuality.name,
      'encoderMode': encoderMode.name,
      'includeAudio': includeAudio,
    };
  }

  factory ExportConfigModel.fromJson(Map<String, dynamic> json) {
    return ExportConfigModel(
      resolution: ExportResolutionPreset.values.firstWhere(
        (e) => e.name == json['resolution'],
        orElse: () => ExportResolutionPreset.res720p,
      ),
      fps: ExportFps.values.firstWhere(
        (e) => e.name == json['fps'],
        orElse: () => ExportFps.fps30,
      ),
      bitrateQuality: ExportBitrateQuality.values.firstWhere(
        (e) => e.name == json['bitrateQuality'],
        orElse: () => ExportBitrateQuality.standard,
      ),
      encoderMode: ExportEncoderMode.values.firstWhere(
        (e) => e.name == json['encoderMode'],
        orElse: () => ExportEncoderMode.auto,
      ),
      includeAudio: json['includeAudio'] as bool? ?? true,
    );
  }
}
