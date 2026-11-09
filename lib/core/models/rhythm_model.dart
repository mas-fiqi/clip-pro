/// Model marker ketukan irama musik (Beat Marker)
class BeatMarkerModel {
  final String id;
  final double timestampSeconds; // Posisi waktu beat dalam detik
  final bool isStrongBeat;        // Apakah ketukan kuat (downbeat) atau ketukan lemah
  final double strength;          // Kekuatan amplitudo ketukan (0.0 s/d 1.0)

  const BeatMarkerModel({
    required this.id,
    required this.timestampSeconds,
    this.isStrongBeat = true,
    this.strength = 1.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestampSeconds': timestampSeconds,
    'isStrongBeat': isStrongBeat,
    'strength': strength,
  };

  factory BeatMarkerModel.fromJson(Map<String, dynamic> json) {
    return BeatMarkerModel(
      id: json['id'] as String,
      timestampSeconds: (json['timestampSeconds'] as num).toDouble(),
      isStrongBeat: json['isStrongBeat'] as bool? ?? true,
      strength: (json['strength'] as num?)?.toDouble() ?? 1.0,
    );
  }

  BeatMarkerModel copyWith({
    String? id,
    double? timestampSeconds,
    bool? isStrongBeat,
    double? strength,
  }) {
    return BeatMarkerModel(
      id: id ?? this.id,
      timestampSeconds: timestampSeconds ?? this.timestampSeconds,
      isStrongBeat: isStrongBeat ?? this.isStrongBeat,
      strength: strength ?? this.strength,
    );
  }
}

/// Sensitivitas Deteksi Beat Otomatis
enum BeatSensitivity {
  low,    // Hanya ketukan sangat kuat
  medium, // Standar musik pop/edm
  high,   // Seluruh variasi ritme mikro
}

/// Konfigurasi & Hasil Analisis Irama Rhythm Studio
class RhythmModel {
  final double estimatedBpm;
  final BeatSensitivity sensitivity;
  final List<BeatMarkerModel> markers;
  final bool isSnapEnabled; // Snap klip ke beat marker di timeline
  final double manualBpmOffset; // Offset milidetik sinkronisasi

  const RhythmModel({
    this.estimatedBpm = 120.0,
    this.sensitivity = BeatSensitivity.medium,
    this.markers = const [],
    this.isSnapEnabled = true,
    this.manualBpmOffset = 0.0,
  });

  bool get hasMarkers => markers.isNotEmpty;

  RhythmModel copyWith({
    double? estimatedBpm,
    BeatSensitivity? sensitivity,
    List<BeatMarkerModel>? markers,
    bool? isSnapEnabled,
    double? manualBpmOffset,
  }) {
    return RhythmModel(
      estimatedBpm: estimatedBpm ?? this.estimatedBpm,
      sensitivity: sensitivity ?? this.sensitivity,
      markers: markers ?? this.markers,
      isSnapEnabled: isSnapEnabled ?? this.isSnapEnabled,
      manualBpmOffset: manualBpmOffset ?? this.manualBpmOffset,
    );
  }

  Map<String, dynamic> toJson() => {
    'estimatedBpm': estimatedBpm,
    'sensitivity': sensitivity.name,
    'markers': markers.map((m) => m.toJson()).toList(),
    'isSnapEnabled': isSnapEnabled,
    'manualBpmOffset': manualBpmOffset,
  };

  factory RhythmModel.fromJson(Map<String, dynamic> json) {
    return RhythmModel(
      estimatedBpm: (json['estimatedBpm'] as num?)?.toDouble() ?? 120.0,
      sensitivity: BeatSensitivity.values.firstWhere(
        (s) => s.name == json['sensitivity'],
        orElse: () => BeatSensitivity.medium,
      ),
      markers: json['markers'] != null
          ? (json['markers'] as List)
              .map((m) => BeatMarkerModel.fromJson(m as Map<String, dynamic>))
              .toList()
          : const [],
      isSnapEnabled: json['isSnapEnabled'] as bool? ?? true,
      manualBpmOffset: (json['manualBpmOffset'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Menghasilkan marker beat otomatis dari analisis tempo BPM & durasi audio
  static List<BeatMarkerModel> generateBeatsFromBpm({
    required double bpm,
    required double durationSeconds,
    BeatSensitivity sensitivity = BeatSensitivity.medium,
  }) {
    final validBpm = bpm.clamp(40.0, 240.0);
    final beatInterval = 60.0 / validBpm;
    final markers = <BeatMarkerModel>[];

    int stepFactor = 1;
    if (sensitivity == BeatSensitivity.low) {
      stepFactor = 2; // Hanya downbeats
    }

    double current = 0.0;
    int index = 0;
    while (current < durationSeconds) {
      if (index % stepFactor == 0) {
        final isStrong = (index % 4 == 0);
        markers.add(BeatMarkerModel(
          id: 'beat_$index',
          timestampSeconds: current,
          isStrongBeat: isStrong,
          strength: isStrong ? 1.0 : 0.6,
        ));
      }
      current += beatInterval;
      index++;
    }

    return markers;
  }
}
