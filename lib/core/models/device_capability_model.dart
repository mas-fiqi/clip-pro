/// Model representasi Hardware/Software Video Encoder pada perangkat
class VideoEncoderCapability {
  final String name;
  final String mimeType;
  final bool isHardwareAccelerated;
  final int? maxWidth;
  final int? maxHeight;
  final int? maxFps;
  final List<int> colorFormats;

  const VideoEncoderCapability({
    required this.name,
    required this.mimeType,
    required this.isHardwareAccelerated,
    this.maxWidth,
    this.maxHeight,
    this.maxFps,
    this.colorFormats = const [],
  });

  bool supportsResolution(int width, int height) {
    if (maxWidth == null || maxHeight == null) return true;
    return (width <= maxWidth! && height <= maxHeight!) ||
        (height <= maxWidth! && width <= maxHeight!);
  }

  bool supportsFps(int fps) {
    if (maxFps == null) return true;
    return fps <= maxFps!;
  }

  factory VideoEncoderCapability.fromJson(Map<String, dynamic> json) {
    return VideoEncoderCapability(
      name: json['name'] as String? ?? 'unknown',
      mimeType: json['mimeType'] as String? ?? '',
      isHardwareAccelerated: json['isHardwareAccelerated'] as bool? ?? false,
      maxWidth: json['maxWidth'] as int?,
      maxHeight: json['maxHeight'] as int?,
      maxFps: (json['maxFps'] as num?)?.toInt(),
      colorFormats: (json['colorFormats'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mimeType': mimeType,
      'isHardwareAccelerated': isHardwareAccelerated,
      'maxWidth': maxWidth,
      'maxHeight': maxHeight,
      'maxFps': maxFps,
      'colorFormats': colorFormats,
    };
  }
}

/// Model representasi kemampuan perangkat keras
class DeviceCapabilityModel {
  final String deviceModel;
  final String androidVersion;
  final int sdkInt;
  final List<String> supportedAbis;
  final int? totalRamMB;
  final int? availableRamMB;
  final bool? isLowRam;
  final int? availableStorageMB;
  final int? totalStorageMB;
  final List<VideoEncoderCapability> videoEncoders;

  const DeviceCapabilityModel({
    this.deviceModel = 'Unknown Device',
    this.androidVersion = 'Unknown',
    this.sdkInt = 0,
    this.supportedAbis = const [],
    this.totalRamMB,
    this.availableRamMB,
    this.isLowRam,
    this.availableStorageMB,
    this.totalStorageMB,
    this.videoEncoders = const [],
  });

  /// Apakah perangkat memiliki hardware encoder H.264 (avc)
  bool get hasH264HardwareEncoder {
    return videoEncoders.any((enc) =>
        enc.isHardwareAccelerated &&
        (enc.mimeType == 'video/avc' || enc.name.toLowerCase().contains('avc') || enc.name.toLowerCase().contains('h264')));
  }

  /// Apakah perangkat memiliki hardware encoder HEVC (h.265)
  bool get hasHevcHardwareEncoder {
    return videoEncoders.any((enc) =>
        enc.isHardwareAccelerated &&
        (enc.mimeType == 'video/hevc' || enc.name.toLowerCase().contains('hevc')));
  }

  /// Cek apakah resolusi dan FPS tertentu didukung oleh hardware encoder
  bool isHardwareResolutionSupported(int width, int height, int fps) {
    final hwEncoders = videoEncoders.where((enc) =>
        enc.isHardwareAccelerated &&
        (enc.mimeType == 'video/avc' || enc.name.toLowerCase().contains('avc')));
    if (hwEncoders.isEmpty) return false;

    return hwEncoders.any((enc) =>
        enc.supportsResolution(width, height) && enc.supportsFps(fps));
  }

  factory DeviceCapabilityModel.fromJson(Map<String, dynamic> json) {
    final encodersRaw = json['videoEncoders'] as List<dynamic>? ?? [];
    final encoders = encodersRaw
        .map((e) => VideoEncoderCapability.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return DeviceCapabilityModel(
      deviceModel: json['deviceModel'] as String? ?? 'Unknown Device',
      androidVersion: json['androidVersion'] as String? ?? 'Unknown',
      sdkInt: json['sdkInt'] as int? ?? 0,
      supportedAbis: (json['supportedAbis'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      totalRamMB: json['totalRamMB'] as int?,
      availableRamMB: json['availableRamMB'] as int?,
      isLowRam: json['isLowRam'] as bool?,
      availableStorageMB: json['availableStorageMB'] as int?,
      totalStorageMB: json['totalStorageMB'] as int?,
      videoEncoders: encoders,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceModel': deviceModel,
      'androidVersion': androidVersion,
      'sdkInt': sdkInt,
      'supportedAbis': supportedAbis,
      'totalRamMB': totalRamMB,
      'availableRamMB': availableRamMB,
      'isLowRam': isLowRam,
      'availableStorageMB': availableStorageMB,
      'totalStorageMB': totalStorageMB,
      'videoEncoders': videoEncoders.map((e) => e.toJson()).toList(),
    };
  }
}

/// Model info runtime penyimpanan dan status termal baterai
class StorageAndThermalInfo {
  final int? availableStorageMB;
  final int? totalStorageMB;
  final double? batteryTemperatureCelsius;
  final int? batteryLevelPercent;

  const StorageAndThermalInfo({
    this.availableStorageMB,
    this.totalStorageMB,
    this.batteryTemperatureCelsius,
    this.batteryLevelPercent,
  });

  /// Evaluasi risiko penyimpanan terhadap estimasi output
  StorageRiskStatus evaluateStorageRisk(double estimatedOutputMB) {
    if (availableStorageMB == null) return StorageRiskStatus.unknown;
    // Butuh setidaknya 2x estimasi (untuk file sementara + output final)
    final requiredSafeMB = estimatedOutputMB * 2.0 + 100.0;
    if (availableStorageMB! < estimatedOutputMB) {
      return StorageRiskStatus.critical;
    } else if (availableStorageMB! < requiredSafeMB) {
      return StorageRiskStatus.warning;
    }
    return StorageRiskStatus.safe;
  }

  /// Evaluasi status termal
  ThermalWarningStatus get thermalStatus {
    if (batteryTemperatureCelsius == null) return ThermalWarningStatus.unknown;
    if (batteryTemperatureCelsius! >= 44.0) {
      return ThermalWarningStatus.hot;
    } else if (batteryTemperatureCelsius! >= 39.0) {
      return ThermalWarningStatus.warm;
    }
    return ThermalWarningStatus.normal;
  }

  factory StorageAndThermalInfo.fromJson(Map<String, dynamic> json) {
    return StorageAndThermalInfo(
      availableStorageMB: json['availableStorageMB'] as int?,
      totalStorageMB: json['totalStorageMB'] as int?,
      batteryTemperatureCelsius: (json['batteryTemperatureCelsius'] as num?)?.toDouble(),
      batteryLevelPercent: json['batteryLevelPercent'] as int?,
    );
  }
}

enum StorageRiskStatus {
  safe,
  warning,
  critical,
  unknown,
}

enum ThermalWarningStatus {
  normal,
  warm,
  hot,
  unknown,
}

