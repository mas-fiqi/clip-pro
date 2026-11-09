/// Profil Performa Editor (Adaptive Engine)
enum EditorPerformanceProfile {
  low,      // Device low-end (e.g. Redmi Note 8 / Snapdragon 665 / RAM <= 4GB)
  balanced, // Device mid-range (RAM 6-8GB)
  high,     // Device flagship / PC
}

/// Konfigurasi tuning performa yang aktif pada editor
class EditorPerformanceConfig {
  final EditorPerformanceProfile profile;
  final int maxThumbnailsPerClip;
  final int thumbnailWidth;
  final int thumbnailQuality;
  final int maxCachedThumbnails;
  final int maxCachedWaveforms;
  final bool enableThumbnailCacheEviction;
  final bool lazyTimelinePainting;
  final Duration sliderDebounceDuration;

  const EditorPerformanceConfig({
    required this.profile,
    required this.maxThumbnailsPerClip,
    required this.thumbnailWidth,
    required this.thumbnailQuality,
    required this.maxCachedThumbnails,
    required this.maxCachedWaveforms,
    required this.enableThumbnailCacheEviction,
    required this.lazyTimelinePainting,
    required this.sliderDebounceDuration,
  });

  /// Factory preset untuk Low Performance (Spesifik target Redmi Note 8 / RAM 4GB)
  factory EditorPerformanceConfig.low() {
    return const EditorPerformanceConfig(
      profile: EditorPerformanceProfile.low,
      maxThumbnailsPerClip: 4,
      thumbnailWidth: 70,
      thumbnailQuality: 4,
      maxCachedThumbnails: 30,
      maxCachedWaveforms: 15,
      enableThumbnailCacheEviction: true,
      lazyTimelinePainting: true,
      sliderDebounceDuration: Duration(milliseconds: 60),
    );
  }

  /// Factory preset untuk Balanced Performance (Mid-range)
  factory EditorPerformanceConfig.balanced() {
    return const EditorPerformanceConfig(
      profile: EditorPerformanceProfile.balanced,
      maxThumbnailsPerClip: 6,
      thumbnailWidth: 90,
      thumbnailQuality: 3,
      maxCachedThumbnails: 60,
      maxCachedWaveforms: 30,
      enableThumbnailCacheEviction: true,
      lazyTimelinePainting: true,
      sliderDebounceDuration: Duration(milliseconds: 40),
    );
  }

  /// Factory preset untuk High Performance
  factory EditorPerformanceConfig.high() {
    return const EditorPerformanceConfig(
      profile: EditorPerformanceProfile.high,
      maxThumbnailsPerClip: 8,
      thumbnailWidth: 120,
      thumbnailQuality: 2,
      maxCachedThumbnails: 120,
      maxCachedWaveforms: 60,
      enableThumbnailCacheEviction: false,
      lazyTimelinePainting: false,
      sliderDebounceDuration: Duration(milliseconds: 20),
    );
  }

  /// Deteksi otomatis profil performa berbasis spesifikasi perangkat riil
  static EditorPerformanceConfig detectFromSpecs({
    int? totalRamMB,
    int? availableRamMB,
    bool? isLowRam,
    String? deviceModel,
  }) {
    // Jika low RAM flag aktif atau RAM <= 4096MB (Redmi Note 8 standard adalah 4GB RAM)
    final ram = totalRamMB ?? 4096;
    final isBudgetDevice = (isLowRam == true) || ram <= 4200;

    if (isBudgetDevice) {
      return EditorPerformanceConfig.low();
    } else if (ram <= 8192) {
      return EditorPerformanceConfig.balanced();
    } else {
      return EditorPerformanceConfig.high();
    }
  }
}

