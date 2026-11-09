/// Tipe interpolasi / kurva transisi antar-keyframe
enum KeyframeEasing {
  linear,
  easeIn,
  easeOut,
  easeInOut,
}

/// Satu titik keyframe pada klip video
class KeyframeModel {
  final String id;
  final double timestampSeconds; // Waktu relatif dalam klip (0.0 s/d timelineDuration)
  final double positionX;        // Normalisasi offset X (-1.0 s/d 1.0, default 0.0)
  final double positionY;        // Normalisasi offset Y (-1.0 s/d 1.0, default 0.0)
  final double scale;            // Faktor skala / zoom (0.1 s/d 5.0, default 1.0)
  final double rotationDegrees;  // Rotasi bebas (-360.0 s/d 360.0, default 0.0)
  final double opacity;          // Tingkat transparansi (0.0 s/d 1.0, default 1.0)
  final double volume;           // Level volume audio (0.0 s/d 1.0, default 1.0)
  final KeyframeEasing easing;    // Kurva transisi menuju keyframe berikutnya

  const KeyframeModel({
    required this.id,
    required this.timestampSeconds,
    this.positionX = 0.0,
    this.positionY = 0.0,
    this.scale = 1.0,
    this.rotationDegrees = 0.0,
    this.opacity = 1.0,
    this.volume = 1.0,
    this.easing = KeyframeEasing.linear,
  }) : assert(timestampSeconds >= 0.0, 'timestamp tidak boleh negatif'),
       assert(scale > 0.0, 'scale harus lebih besar dari 0'),
       assert(opacity >= 0.0 && opacity <= 1.0, 'opacity harus 0.0 s/d 1.0'),
       assert(volume >= 0.0 && volume <= 1.0, 'volume harus 0.0 s/d 1.0');

  KeyframeModel copyWith({
    String? id,
    double? timestampSeconds,
    double? positionX,
    double? positionY,
    double? scale,
    double? rotationDegrees,
    double? opacity,
    double? volume,
    KeyframeEasing? easing,
  }) {
    return KeyframeModel(
      id: id ?? this.id,
      timestampSeconds: timestampSeconds ?? this.timestampSeconds,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      scale: scale ?? this.scale,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      opacity: opacity ?? this.opacity,
      volume: volume ?? this.volume,
      easing: easing ?? this.easing,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestampSeconds': timestampSeconds,
      'positionX': positionX,
      'positionY': positionY,
      'scale': scale,
      'rotationDegrees': rotationDegrees,
      'opacity': opacity,
      'volume': volume,
      'easing': easing.name,
    };
  }

  factory KeyframeModel.fromJson(Map<String, dynamic> json) {
    return KeyframeModel(
      id: json['id'] as String,
      timestampSeconds: (json['timestampSeconds'] as num).toDouble(),
      positionX: (json['positionX'] as num?)?.toDouble() ?? 0.0,
      positionY: (json['positionY'] as num?)?.toDouble() ?? 0.0,
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      rotationDegrees: (json['rotationDegrees'] as num?)?.toDouble() ?? 0.0,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      easing: KeyframeEasing.values.firstWhere(
        (e) => e.name == json['easing'],
        orElse: () => KeyframeEasing.linear,
      ),
    );
  }
}

/// Kumpulan nilai hasil interpolasi keyframe pada satu titik waktu spesifik
class InterpolatedKeyframeValues {
  final double positionX;
  final double positionY;
  final double scale;
  final double rotationDegrees;
  final double opacity;
  final double volume;

  const InterpolatedKeyframeValues({
    this.positionX = 0.0,
    this.positionY = 0.0,
    this.scale = 1.0,
    this.rotationDegrees = 0.0,
    this.opacity = 1.0,
    this.volume = 1.0,
  });

  /// Evaluasi nilai interpolasi dari daftar keyframe pada waktu t (detik)
  static InterpolatedKeyframeValues evaluate(List<KeyframeModel> keyframes, double t) {
    if (keyframes.isEmpty) {
      return const InterpolatedKeyframeValues();
    }

    // Urutkan keyframe berdasarkan waktu
    final sorted = List<KeyframeModel>.from(keyframes)
      ..sort((a, b) => a.timestampSeconds.compareTo(b.timestampSeconds));

    // Jika waktu sebelum atau sama dengan keyframe pertama
    if (t <= sorted.first.timestampSeconds) {
      final first = sorted.first;
      return InterpolatedKeyframeValues(
        positionX: first.positionX,
        positionY: first.positionY,
        scale: first.scale,
        rotationDegrees: first.rotationDegrees,
        opacity: first.opacity,
        volume: first.volume,
      );
    }

    // Jika waktu setelah atau sama dengan keyframe terakhir
    if (t >= sorted.last.timestampSeconds) {
      final last = sorted.last;
      return InterpolatedKeyframeValues(
        positionX: last.positionX,
        positionY: last.positionY,
        scale: last.scale,
        rotationDegrees: last.rotationDegrees,
        opacity: last.opacity,
        volume: last.volume,
      );
    }

    // Temukan segmen antara k0 dan k1
    for (int i = 0; i < sorted.length - 1; i++) {
      final k0 = sorted[i];
      final k1 = sorted[i + 1];

      if (t >= k0.timestampSeconds && t <= k1.timestampSeconds) {
        final duration = k1.timestampSeconds - k0.timestampSeconds;
        if (duration <= 0.0001) {
          return InterpolatedKeyframeValues(
            positionX: k1.positionX,
            positionY: k1.positionY,
            scale: k1.scale,
            rotationDegrees: k1.rotationDegrees,
            opacity: k1.opacity,
            volume: k1.volume,
          );
        }

        double progress = (t - k0.timestampSeconds) / duration;
        // Terapkan fungsi Easing
        progress = _applyEasing(progress, k0.easing);

        return InterpolatedKeyframeValues(
          positionX: _lerp(k0.positionX, k1.positionX, progress),
          positionY: _lerp(k0.positionY, k1.positionY, progress),
          scale: _lerp(k0.scale, k1.scale, progress),
          rotationDegrees: _lerp(k0.rotationDegrees, k1.rotationDegrees, progress),
          opacity: _lerp(k0.opacity, k1.opacity, progress).clamp(0.0, 1.0),
          volume: _lerp(k0.volume, k1.volume, progress).clamp(0.0, 1.0),
        );
      }
    }

    return const InterpolatedKeyframeValues();
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  static double _applyEasing(double t, KeyframeEasing easing) {
    switch (easing) {
      case KeyframeEasing.linear:
        return t;
      case KeyframeEasing.easeIn:
        return t * t;
      case KeyframeEasing.easeOut:
        return t * (2 - t);
      case KeyframeEasing.easeInOut:
        return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
    }
  }
}

