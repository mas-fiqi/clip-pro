import 'dart:math' as math;

/// Satu titik kontrol pada grafik Kurva Kecepatan (Speed Curve Point)
class SpeedCurvePoint {
  final double x; // Posisi waktu relatif klip (0.0 s/d 1.0)
  final double y; // Kecepatan pada titik ini (0.1x s/d 10.0x)

  const SpeedCurvePoint({
    required this.x,
    required this.y,
  }) : assert(x >= 0.0 && x <= 1.0, 'x harus berada di rentang 0.0 s/d 1.0'),
       assert(y >= 0.1 && y <= 10.0, 'y kecepatan harus berada di rentang 0.1 s/d 10.0');

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  factory SpeedCurvePoint.fromJson(Map<String, dynamic> json) {
    return SpeedCurvePoint(
      x: (json['x'] as num).toDouble().clamp(0.0, 1.0),
      y: (json['y'] as num).toDouble().clamp(0.1, 10.0),
    );
  }

  SpeedCurvePoint copyWith({double? x, double? y}) {
    return SpeedCurvePoint(
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}

/// Model Lengkap Speed Configuration (Normal, Curve & Speed Effects)
class SpeedConfigModel {
  final double normalSpeed; // 0.1x s/d 100.0x
  final bool isCurveMode;   // Apakah menggunakan kurva dinamis
  final String curveTemplateId; // 'custom', 'montage', 'hero', 'bullet', 'jump_cut', 'flash_in', 'flash_out', 'action', 'slow_mo', 'fast_mo', 'cinematic'
  final List<SpeedCurvePoint> curvePoints; // Daftar titik kontrol kecepatan
  final bool keepPitch; // Pertahankan nada audio saat dipercepat/diperlambat

  const SpeedConfigModel({
    this.normalSpeed = 1.0,
    this.isCurveMode = false,
    this.curveTemplateId = 'custom',
    this.curvePoints = const [
      SpeedCurvePoint(x: 0.0, y: 1.0),
      SpeedCurvePoint(x: 0.25, y: 1.0),
      SpeedCurvePoint(x: 0.5, y: 1.0),
      SpeedCurvePoint(x: 0.75, y: 1.0),
      SpeedCurvePoint(x: 1.0, y: 1.0),
    ],
    this.keepPitch = true,
  });

  /// Menghitung kecepatan rata-rata efektif untuk timeline dan durasi
  double get effectiveSpeed {
    if (!isCurveMode || curvePoints.isEmpty) {
      return normalSpeed.clamp(0.1, 100.0);
    }
    // Rata-rata integral kurva kecepatan
    double totalSpeed = 0.0;
    for (final pt in curvePoints) {
      totalSpeed += pt.y;
    }
    return (totalSpeed / curvePoints.length).clamp(0.1, 10.0);
  }

  /// Evaluasi kecepatan instan pada progress klip (0.0 s/d 1.0)
  double evaluateSpeedAt(double progress) {
    if (!isCurveMode || curvePoints.isEmpty) {
      return normalSpeed;
    }
    final p = progress.clamp(0.0, 1.0);
    final sorted = List<SpeedCurvePoint>.from(curvePoints)..sort((a, b) => a.x.compareTo(b.x));

    if (p <= sorted.first.x) return sorted.first.y;
    if (p >= sorted.last.x) return sorted.last.y;

    for (int i = 0; i < sorted.length - 1; i++) {
      final p0 = sorted[i];
      final p1 = sorted[i + 1];
      if (p >= p0.x && p <= p1.x) {
        final t = (p1.x - p0.x) > 0.0001 ? (p - p0.x) / (p1.x - p0.x) : 0.0;
        // Smooth Hermite / Cosine interpolation
        final smoothT = (1.0 - math.cos(t * math.pi)) / 2.0;
        return p0.y + (p1.y - p0.y) * smoothT;
      }
    }
    return 1.0;
  }

  SpeedConfigModel copyWith({
    double? normalSpeed,
    bool? isCurveMode,
    String? curveTemplateId,
    List<SpeedCurvePoint>? curvePoints,
    bool? keepPitch,
  }) {
    return SpeedConfigModel(
      normalSpeed: normalSpeed ?? this.normalSpeed,
      isCurveMode: isCurveMode ?? this.isCurveMode,
      curveTemplateId: curveTemplateId ?? this.curveTemplateId,
      curvePoints: curvePoints ?? this.curvePoints,
      keepPitch: keepPitch ?? this.keepPitch,
    );
  }

  Map<String, dynamic> toJson() => {
    'normalSpeed': normalSpeed,
    'isCurveMode': isCurveMode,
    'curveTemplateId': curveTemplateId,
    'curvePoints': curvePoints.map((p) => p.toJson()).toList(),
    'keepPitch': keepPitch,
  };

  factory SpeedConfigModel.fromJson(Map<String, dynamic> json) {
    return SpeedConfigModel(
      normalSpeed: (json['normalSpeed'] as num?)?.toDouble() ?? 1.0,
      isCurveMode: json['isCurveMode'] as bool? ?? false,
      curveTemplateId: json['curveTemplateId'] as String? ?? 'custom',
      curvePoints: json['curvePoints'] != null
          ? (json['curvePoints'] as List)
              .map((p) => SpeedCurvePoint.fromJson(p as Map<String, dynamic>))
              .toList()
          : const [
              SpeedCurvePoint(x: 0.0, y: 1.0),
              SpeedCurvePoint(x: 0.25, y: 1.0),
              SpeedCurvePoint(x: 0.5, y: 1.0),
              SpeedCurvePoint(x: 0.75, y: 1.0),
              SpeedCurvePoint(x: 1.0, y: 1.0),
            ],
      keepPitch: json['keepPitch'] as bool? ?? true,
    );
  }

  /// Template Bawaan Speed Curve CapCut Style
  static SpeedConfigModel getTemplate(String templateId) {
    switch (templateId) {
      case 'montage':
        return const SpeedConfigModel(
          isCurveMode: true,
          curveTemplateId: 'montage',
          curvePoints: [
            SpeedCurvePoint(x: 0.0, y: 2.5),
            SpeedCurvePoint(x: 0.25, y: 0.4),
            SpeedCurvePoint(x: 0.5, y: 3.0),
            SpeedCurvePoint(x: 0.75, y: 0.3),
            SpeedCurvePoint(x: 1.0, y: 2.0),
          ],
        );
      case 'hero':
        return const SpeedConfigModel(
          isCurveMode: true,
          curveTemplateId: 'hero',
          curvePoints: [
            SpeedCurvePoint(x: 0.0, y: 2.8),
            SpeedCurvePoint(x: 0.3, y: 0.3),
            SpeedCurvePoint(x: 0.7, y: 0.3),
            SpeedCurvePoint(x: 1.0, y: 3.0),
          ],
        );
      case 'bullet':
        return const SpeedConfigModel(
          isCurveMode: true,
          curveTemplateId: 'bullet',
          curvePoints: [
            SpeedCurvePoint(x: 0.0, y: 4.0),
            SpeedCurvePoint(x: 0.4, y: 0.2),
            SpeedCurvePoint(x: 0.6, y: 0.2),
            SpeedCurvePoint(x: 1.0, y: 4.0),
          ],
        );
      case 'jump_cut':
        return const SpeedConfigModel(
          isCurveMode: true,
          curveTemplateId: 'jump_cut',
          curvePoints: [
            SpeedCurvePoint(x: 0.0, y: 0.5),
            SpeedCurvePoint(x: 0.35, y: 3.5),
            SpeedCurvePoint(x: 0.65, y: 0.4),
            SpeedCurvePoint(x: 1.0, y: 3.0),
          ],
        );
      case 'flash_in':
        return const SpeedConfigModel(
          isCurveMode: true,
          curveTemplateId: 'flash_in',
          curvePoints: [
            SpeedCurvePoint(x: 0.0, y: 0.2),
            SpeedCurvePoint(x: 0.4, y: 0.5),
            SpeedCurvePoint(x: 0.8, y: 3.5),
            SpeedCurvePoint(x: 1.0, y: 4.5),
          ],
        );
      case 'flash_out':
        return const SpeedConfigModel(
          isCurveMode: true,
          curveTemplateId: 'flash_out',
          curvePoints: [
            SpeedCurvePoint(x: 0.0, y: 4.5),
            SpeedCurvePoint(x: 0.3, y: 3.0),
            SpeedCurvePoint(x: 0.7, y: 0.5),
            SpeedCurvePoint(x: 1.0, y: 0.2),
          ],
        );
      case 'action':
        return const SpeedConfigModel(
          isCurveMode: true,
          curveTemplateId: 'action',
          curvePoints: [
            SpeedCurvePoint(x: 0.0, y: 1.5),
            SpeedCurvePoint(x: 0.3, y: 0.4),
            SpeedCurvePoint(x: 0.6, y: 3.2),
            SpeedCurvePoint(x: 1.0, y: 1.2),
          ],
        );
      case 'slow_mo':
        return const SpeedConfigModel(
          isCurveMode: true,
          curveTemplateId: 'slow_mo',
          curvePoints: [
            SpeedCurvePoint(x: 0.0, y: 1.0),
            SpeedCurvePoint(x: 0.2, y: 0.3),
            SpeedCurvePoint(x: 0.8, y: 0.25),
            SpeedCurvePoint(x: 1.0, y: 1.0),
          ],
        );
      case 'fast_mo':
        return const SpeedConfigModel(
          isCurveMode: true,
          curveTemplateId: 'fast_mo',
          curvePoints: [
            SpeedCurvePoint(x: 0.0, y: 1.0),
            SpeedCurvePoint(x: 0.3, y: 3.5),
            SpeedCurvePoint(x: 0.7, y: 4.0),
            SpeedCurvePoint(x: 1.0, y: 1.0),
          ],
        );
      case 'cinematic':
        return const SpeedConfigModel(
          isCurveMode: true,
          curveTemplateId: 'cinematic',
          curvePoints: [
            SpeedCurvePoint(x: 0.0, y: 1.2),
            SpeedCurvePoint(x: 0.35, y: 0.6),
            SpeedCurvePoint(x: 0.65, y: 0.6),
            SpeedCurvePoint(x: 1.0, y: 1.2),
          ],
        );
      default:
        return const SpeedConfigModel(
          isCurveMode: true,
          curveTemplateId: 'custom',
          curvePoints: [
            SpeedCurvePoint(x: 0.0, y: 1.0),
            SpeedCurvePoint(x: 0.25, y: 1.0),
            SpeedCurvePoint(x: 0.5, y: 1.0),
            SpeedCurvePoint(x: 0.75, y: 1.0),
            SpeedCurvePoint(x: 1.0, y: 1.0),
          ],
        );
    }
  }
}

