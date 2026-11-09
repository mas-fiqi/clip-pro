import 'rhythm_model.dart';

/// Model data untuk satu klip audio / musik di timeline
class AudioClipModel {
  final String id;
  final String sourcePath;
  final String title;
  final double startTimeline; // Detik mulai pada timeline proyek
  final double startSource;   // Detik offset dalam file audio
  final double duration;      // Durasi pemutaran (detik)
  final double volume;        // 0.0 s/d 1.0 (default 1.0)
  final bool isMuted;
  final double fadeInSeconds;
  final double fadeOutSeconds;
  final RhythmModel rhythm;   // Analisis irama beat detection & rhythm sync

  const AudioClipModel({
    required this.id,
    required this.sourcePath,
    required this.title,
    required this.startTimeline,
    this.startSource = 0.0,
    required this.duration,
    this.volume = 1.0,
    this.isMuted = false,
    this.fadeInSeconds = 0.0,
    this.fadeOutSeconds = 0.0,
    this.rhythm = const RhythmModel(),
  }) : assert(id.length > 0, 'ID tidak boleh kosong'),
       assert(sourcePath.length > 0, 'sourcePath tidak boleh kosong'),
       assert(startTimeline >= 0.0, 'startTimeline tidak boleh negatif'),
       assert(startSource >= 0.0, 'startSource tidak boleh negatif'),
       assert(duration > 0.0, 'duration harus lebih besar dari 0'),
       assert(volume >= 0.0 && volume <= 1.0, 'volume rentang 0.0 s/d 1.0');

  double get endTimeline => startTimeline + duration;

  AudioClipModel copyWith({
    String? id,
    String? sourcePath,
    String? title,
    double? startTimeline,
    double? startSource,
    double? duration,
    double? volume,
    bool? isMuted,
    double? fadeInSeconds,
    double? fadeOutSeconds,
    RhythmModel? rhythm,
  }) {
    return AudioClipModel(
      id: id ?? this.id,
      sourcePath: sourcePath ?? this.sourcePath,
      title: title ?? this.title,
      startTimeline: startTimeline ?? this.startTimeline,
      startSource: startSource ?? this.startSource,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      fadeInSeconds: fadeInSeconds ?? this.fadeInSeconds,
      fadeOutSeconds: fadeOutSeconds ?? this.fadeOutSeconds,
      rhythm: rhythm ?? this.rhythm,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourcePath': sourcePath,
      'title': title,
      'startTimeline': startTimeline,
      'startSource': startSource,
      'duration': duration,
      'volume': volume,
      'isMuted': isMuted,
      'fadeInSeconds': fadeInSeconds,
      'fadeOutSeconds': fadeOutSeconds,
      'rhythm': rhythm.toJson(),
    };
  }

  factory AudioClipModel.fromJson(Map<String, dynamic> json) {
    return AudioClipModel(
      id: json['id'] as String,
      sourcePath: json['sourcePath'] as String,
      title: json['title'] as String? ?? 'Audio',
      startTimeline: (json['startTimeline'] as num).toDouble(),
      startSource: (json['startSource'] as num?)?.toDouble() ?? 0.0,
      duration: (json['duration'] as num).toDouble(),
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      isMuted: json['isMuted'] as bool? ?? false,
      fadeInSeconds: (json['fadeInSeconds'] as num?)?.toDouble() ?? 0.0,
      fadeOutSeconds: (json['fadeOutSeconds'] as num?)?.toDouble() ?? 0.0,
      rhythm: json['rhythm'] != null
          ? RhythmModel.fromJson(json['rhythm'] as Map<String, dynamic>)
          : const RhythmModel(),
    );
  }
}

