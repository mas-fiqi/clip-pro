/// Utility murni untuk menghitung progress ekspor timeline secara linear, proporsional, dan bounded (0.0 - 1.0)
class ExportProgressCalculator {
  /// Menghitung progress untuk tahap intermediate clip encoding (mengambil alokasi 0.0 - 0.85)
  static double calculateClipStageProgress({
    required double accumulatedDuration,
    required double currentClipDuration,
    required double currentClipProgress,
    required double totalDuration,
  }) {
    if (totalDuration <= 0) return 0.0;
    final clampedClipProgress = currentClipProgress.clamp(0.0, 1.0);
    final currentTotalTime = accumulatedDuration + (currentClipDuration * clampedClipProgress);
    // Maksimum tahap klip adalah 0.85 (85%)
    return (currentTotalTime / totalDuration * 0.85).clamp(0.0, 0.85);
  }

  /// Menghitung progress untuk statistik FFmpeg per klip
  static double calculateSingleClipProgress({
    required int timeMillis,
    required int totalExpectedMillis,
  }) {
    if (totalExpectedMillis <= 0 || timeMillis <= 0) return 0.0;
    return (timeMillis / totalExpectedMillis).clamp(0.0, 1.0);
  }

  /// Memastikan progress tidak melompat melebihi 1.0 dan completion hanya valid jika proses sukses
  static double clampProgress(double rawProgress) {
    if (rawProgress.isNaN || rawProgress.isInfinite) return 0.0;
    return rawProgress.clamp(0.0, 1.0);
  }
}

