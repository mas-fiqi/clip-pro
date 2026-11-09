/// Target Profile Kualitas Video
enum TargetQualityProfile {
  standard, // 720p HD seimbang (efisien daya & cepat)
  high,     // 1080p FHD bitrate tinggi (kualitas prima)
  ultra,    // 1440p / 4K UHD bitrate maksimal (detail tajam)
  custom,   // Kustomisasi manual
}

/// Model Pengaturan Peningkatan Kualitas Video (Video Quality Enhancement)
/// Diproses secara 100% lokal & offline (teroptimasi untuk Snapdragon 665 / 4GB RAM)
class QualityEnhancementModel {
  final bool autoEnhance;        // Peningkatan kontras & kejernihan otomatis
  final TargetQualityProfile targetQuality;
  final bool noiseReduction;    // Filter peredam bintik/noise video (hqdn3d)
  final double noiseIntensity;   // 0.0 s/d 1.0 (kekuatan reduksi bintik)
  final bool deflicker;         // Mengurangi kedipan variasi kecerahan antar-frame
  final double deflickerSize;    // 0.1 s/d 1.0 (radius smoothing kecerahan)
  final bool stabilization;      // Stabilisasi guncangan kamera (deshake)
  final double stabilizationStrength; // 0.1 s/d 1.0 (kekuatan kompensasi guncangan)

  const QualityEnhancementModel({
    this.autoEnhance = false,
    this.targetQuality = TargetQualityProfile.standard,
    this.noiseReduction = false,
    this.noiseIntensity = 0.5,
    this.deflicker = false,
    this.deflickerSize = 0.5,
    this.stabilization = false,
    this.stabilizationStrength = 0.5,
  }) : assert(noiseIntensity >= 0.0 && noiseIntensity <= 1.0, 'noiseIntensity rentang 0.0 - 1.0'),
       assert(deflickerSize >= 0.0 && deflickerSize <= 1.0, 'deflickerSize rentang 0.0 - 1.0'),
       assert(stabilizationStrength >= 0.0 && stabilizationStrength <= 1.0, 'stabilizationStrength rentang 0.0 - 1.0');

  bool get hasEnhancement =>
      autoEnhance ||
      noiseReduction ||
      deflicker ||
      stabilization ||
      targetQuality != TargetQualityProfile.standard;

  QualityEnhancementModel copyWith({
    bool? autoEnhance,
    TargetQualityProfile? targetQuality,
    bool? noiseReduction,
    double? noiseIntensity,
    bool? deflicker,
    double? deflickerSize,
    bool? stabilization,
    double? stabilizationStrength,
  }) {
    return QualityEnhancementModel(
      autoEnhance: autoEnhance ?? this.autoEnhance,
      targetQuality: targetQuality ?? this.targetQuality,
      noiseReduction: noiseReduction ?? this.noiseReduction,
      noiseIntensity: noiseIntensity ?? this.noiseIntensity,
      deflicker: deflicker ?? this.deflicker,
      deflickerSize: deflickerSize ?? this.deflickerSize,
      stabilization: stabilization ?? this.stabilization,
      stabilizationStrength: stabilizationStrength ?? this.stabilizationStrength,
    );
  }

  Map<String, dynamic> toJson() => {
    'autoEnhance': autoEnhance,
    'targetQuality': targetQuality.name,
    'noiseReduction': noiseReduction,
    'noiseIntensity': noiseIntensity,
    'deflicker': deflicker,
    'deflickerSize': deflickerSize,
    'stabilization': stabilization,
    'stabilizationStrength': stabilizationStrength,
  };

  factory QualityEnhancementModel.fromJson(Map<String, dynamic> json) {
    return QualityEnhancementModel(
      autoEnhance: json['autoEnhance'] as bool? ?? false,
      targetQuality: TargetQualityProfile.values.firstWhere(
        (e) => e.name == json['targetQuality'],
        orElse: () => TargetQualityProfile.standard,
      ),
      noiseReduction: json['noiseReduction'] as bool? ?? false,
      noiseIntensity: (json['noiseIntensity'] as num?)?.toDouble() ?? 0.5,
      deflicker: json['deflicker'] as bool? ?? false,
      deflickerSize: (json['deflickerSize'] as num?)?.toDouble() ?? 0.5,
      stabilization: json['stabilization'] as bool? ?? false,
      stabilizationStrength: (json['stabilizationStrength'] as num?)?.toDouble() ?? 0.5,
    );
  }

  /// Menghasilkan filter FFmpeg nyata yang didukung oleh build lokal
  List<String> buildFFmpegFilters() {
    final List<String> filters = [];

    // 1. Auto Enhance: Meningkatkan detail dinamis dan kontras lembut
    if (autoEnhance) {
      filters.add('eq=contrast=1.12:brightness=0.02:saturation=1.08,unsharp=5:5:0.8:5:5:0.0');
    }

    // 2. Noise Reduction: hqdn3d (High Quality Denoise 3D - hemat CPU lokal)
    if (noiseReduction && noiseIntensity > 0.0) {
      final spatial = (noiseIntensity * 6.0).clamp(1.0, 10.0).toStringAsFixed(1);
      final temporal = (noiseIntensity * 8.0).clamp(1.0, 12.0).toStringAsFixed(1);
      filters.add('hqdn3d=$spatial:$spatial:$temporal:$temporal');
    }

    // 3. Deflicker: Mengurangi fluktuasi kedipan luminansi
    if (deflicker && deflickerSize > 0.0) {
      final size = (deflickerSize * 15.0).clamp(3.0, 20.0).toInt();
      filters.add('deflicker=size=$size:mode=pm');
    }

    // 4. Deshake Stabilization: Meredam guncangan kamera tanpa library eksternal berbayar
    // Catatan FFmpeg: parameter rx & ry pada filter deshake HARUS kelipatan 16 (16, 32, 48, 64)
    if (stabilization && stabilizationStrength > 0.0) {
      final rawX = (stabilizationStrength * 64.0).clamp(16.0, 64.0);
      final rx = (rawX / 16.0).round() * 16;
      final rawY = (stabilizationStrength * 64.0).clamp(16.0, 64.0);
      final ry = (rawY / 16.0).round() * 16;
      filters.add('deshake=rx=$rx:ry=$ry:edge=mirror');
    }

    return filters;
  }
}

