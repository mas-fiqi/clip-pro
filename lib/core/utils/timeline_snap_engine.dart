/// Pengelola snapping cerdas antara klip, playhead, dan titik transisi timeline
class TimelineSnapEngine {
  final double snapToleranceSeconds;

  const TimelineSnapEngine({this.snapToleranceSeconds = 0.2});

  /// Mencari titik snap terdekat untuk targetTime
  double? snapTime({
    required double targetTime,
    required List<double> snapPoints,
    bool enabled = true,
  }) {
    if (!enabled || snapPoints.isEmpty) return null;

    double? closestPoint;
    double minDiff = double.infinity;

    for (final point in snapPoints) {
      final diff = (point - targetTime).abs();
      if (diff <= snapToleranceSeconds && diff < minDiff) {
        minDiff = diff;
        closestPoint = point;
      }
    }

    return closestPoint;
  }
}
