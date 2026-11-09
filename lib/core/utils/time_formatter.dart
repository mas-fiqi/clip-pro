class TimeFormatter {
  /// Format Duration or seconds to HH:mm:ss or mm:ss
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }

  /// Format seconds directly into a string with 2 decimal places or mm:ss.ms
  static String formatSeconds(double seconds) {
    final dur = Duration(milliseconds: (seconds * 1000).toInt());
    return formatDuration(dur);
  }

  /// Alias for display duration
  static String formatDisplayDuration(double seconds) {
    return formatSeconds(seconds);
  }

  /// Format seconds to FFmpeg timestamp format HH:mm:ss.ms
  static String toFFmpegTimestamp(double seconds) {
    final dur = Duration(milliseconds: (seconds * 1000).toInt());
    final hours = dur.inHours.toString().padLeft(2, '0');
    final minutes = dur.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = dur.inSeconds.remainder(60).toString().padLeft(2, '0');
    final millis = (dur.inMilliseconds.remainder(1000)).toString().padLeft(3, '0');
    return '$hours:$minutes:$secs.$millis';
  }
}

