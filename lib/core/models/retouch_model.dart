/// Kategori Retouch Wajah & Tubuh
enum RetouchCategory {
  skin,    // Kulit: Halus, Cerah, Noda
  face,    // Wajah: Bentuk Tirus, Rahang, Pipi
  eyes,    // Mata: Mata Cerah, Ukuran Mata
  makeup,  // Riasan: Lipstik, Perona Pipi, Alis
  details, // Detail: Pemutih Gigi, Detail Mata
  body,    // Tubuh: Rampingkan Tubuh, Bentuk Tubuh
  beauty,  // Preset: Alami, Lembut, Glamor
}

/// Model Data Beauty Retouch & Face Enhancement per Klip
class RetouchModel {
  // 1. Skin (Kulit)
  final double smoothSkin;       // 0.0 s/d 1.0 (Menghaluskan tekstur kulit)
  final double brightenSkin;     // 0.0 s/d 1.0 (Mencerahkan kulit)
  final double blemishRemoval;   // 0.0 s/d 1.0 (Menyamarkan noda & jerawat)

  // 2. Face (Bentuk Wajah)
  final double faceSlim;         // 0.0 s/d 1.0 (Meniruskan wajah)
  final double jawline;          // 0.0 s/d 1.0 (Membentuk garis rahang)
  final double cheekbones;       // 0.0 s/d 1.0 (Pipi tirus/naik)

  // 3. Eyes (Mata)
  final double eyeBrighten;      // 0.0 s/d 1.0 (Mencerahkan sorot mata)
  final double eyeSize;          // 0.0 s/d 1.0 (Membesarkan ukuran mata)

  // 4. Makeup (Riasan Digital)
  final double lipstick;         // 0.0 s/d 1.0 (Rona bibir)
  final double blush;            // 0.0 s/d 1.0 (Perona pipi)
  final double eyebrow;          // 0.0 s/d 1.0 (Ketegasan alis)

  // 5. Details (Detail Kecantikan)
  final double teethWhitening;   // 0.0 s/d 1.0 (Pemutih gigi)
  final double eyeDetail;        // 0.0 s/d 1.0 (Ketajaman iris mata)

  // 6. Body (Tubuh)
  final double bodySlim;         // 0.0 s/d 1.0 (Merampingkan tubuh)
  final double bodyShape;        // 0.0 s/d 1.0 (Postur tubuh proporsional)

  // Status Modul
  final bool isEnabled;

  const RetouchModel({
    this.smoothSkin = 0.0,
    this.brightenSkin = 0.0,
    this.blemishRemoval = 0.0,
    this.faceSlim = 0.0,
    this.jawline = 0.0,
    this.cheekbones = 0.0,
    this.eyeBrighten = 0.0,
    this.eyeSize = 0.0,
    this.lipstick = 0.0,
    this.blush = 0.0,
    this.eyebrow = 0.0,
    this.teethWhitening = 0.0,
    this.eyeDetail = 0.0,
    this.bodySlim = 0.0,
    this.bodyShape = 0.0,
    this.isEnabled = true,
  });

  bool get hasActiveRetouch =>
      isEnabled &&
      (smoothSkin > 0.0 ||
          brightenSkin > 0.0 ||
          blemishRemoval > 0.0 ||
          faceSlim > 0.0 ||
          jawline > 0.0 ||
          cheekbones > 0.0 ||
          eyeBrighten > 0.0 ||
          eyeSize > 0.0 ||
          lipstick > 0.0 ||
          blush > 0.0 ||
          eyebrow > 0.0 ||
          teethWhitening > 0.0 ||
          eyeDetail > 0.0 ||
          bodySlim > 0.0 ||
          bodyShape > 0.0);

  RetouchModel copyWith({
    double? smoothSkin,
    double? brightenSkin,
    double? blemishRemoval,
    double? faceSlim,
    double? jawline,
    double? cheekbones,
    double? eyeBrighten,
    double? eyeSize,
    double? lipstick,
    double? blush,
    double? eyebrow,
    double? teethWhitening,
    double? eyeDetail,
    double? bodySlim,
    double? bodyShape,
    bool? isEnabled,
  }) {
    return RetouchModel(
      smoothSkin: smoothSkin ?? this.smoothSkin,
      brightenSkin: brightenSkin ?? this.brightenSkin,
      blemishRemoval: blemishRemoval ?? this.blemishRemoval,
      faceSlim: faceSlim ?? this.faceSlim,
      jawline: jawline ?? this.jawline,
      cheekbones: cheekbones ?? this.cheekbones,
      eyeBrighten: eyeBrighten ?? this.eyeBrighten,
      eyeSize: eyeSize ?? this.eyeSize,
      lipstick: lipstick ?? this.lipstick,
      blush: blush ?? this.blush,
      eyebrow: eyebrow ?? this.eyebrow,
      teethWhitening: teethWhitening ?? this.teethWhitening,
      eyeDetail: eyeDetail ?? this.eyeDetail,
      bodySlim: bodySlim ?? this.bodySlim,
      bodyShape: bodyShape ?? this.bodyShape,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'smoothSkin': smoothSkin,
      'brightenSkin': brightenSkin,
      'blemishRemoval': blemishRemoval,
      'faceSlim': faceSlim,
      'jawline': jawline,
      'cheekbones': cheekbones,
      'eyeBrighten': eyeBrighten,
      'eyeSize': eyeSize,
      'lipstick': lipstick,
      'blush': blush,
      'eyebrow': eyebrow,
      'teethWhitening': teethWhitening,
      'eyeDetail': eyeDetail,
      'bodySlim': bodySlim,
      'bodyShape': bodyShape,
      'isEnabled': isEnabled,
    };
  }

  factory RetouchModel.fromJson(Map<String, dynamic> json) {
    return RetouchModel(
      smoothSkin: (json['smoothSkin'] as num?)?.toDouble() ?? 0.0,
      brightenSkin: (json['brightenSkin'] as num?)?.toDouble() ?? 0.0,
      blemishRemoval: (json['blemishRemoval'] as num?)?.toDouble() ?? 0.0,
      faceSlim: (json['faceSlim'] as num?)?.toDouble() ?? 0.0,
      jawline: (json['jawline'] as num?)?.toDouble() ?? 0.0,
      cheekbones: (json['cheekbones'] as num?)?.toDouble() ?? 0.0,
      eyeBrighten: (json['eyeBrighten'] as num?)?.toDouble() ?? 0.0,
      eyeSize: (json['eyeSize'] as num?)?.toDouble() ?? 0.0,
      lipstick: (json['lipstick'] as num?)?.toDouble() ?? 0.0,
      blush: (json['blush'] as num?)?.toDouble() ?? 0.0,
      eyebrow: (json['eyebrow'] as num?)?.toDouble() ?? 0.0,
      teethWhitening: (json['teethWhitening'] as num?)?.toDouble() ?? 0.0,
      eyeDetail: (json['eyeDetail'] as num?)?.toDouble() ?? 0.0,
      bodySlim: (json['bodySlim'] as num?)?.toDouble() ?? 0.0,
      bodyShape: (json['bodyShape'] as num?)?.toDouble() ?? 0.0,
      isEnabled: (json['isEnabled'] as bool?) ?? true,
    );
  }
}

