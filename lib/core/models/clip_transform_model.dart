enum CanvasRatioMode {
  original,
  ratio9x16,  // TikTok, Reels, Shorts (0.5625)
  ratio16x9,  // YouTube, Cinema Landscape (1.777)
  ratio1x1,   // Feed Instagram Persegi (1.0)
  ratio4x5,   // Feed Instagram Portrait (0.8)
  ratio3x4,   // Tablet Portrait (0.75)
  ratio4x3,   // Retro TV / Presentation (1.333)
  ratio185x1, // Widescreen Sinematik (1.85:1)
  ratio235x1, // Anamorphic Sinematik (2.35:1)
  ratio239x1, // Panavision Sinematik (2.39:1)
  ratio2x1,   // Univisium / Modern Mobile (2.0)
  ratio21x9,  // Ultra-Widescreen Cinematic (2.333)
  custom,     // Custom ratio yang ditentukan pengguna
}

enum FitMode {
  fit,  // Muat penuh dengan background / letterbox
  fill, // Isi penuh kanvas (crop otomatis bagian luar)
}

enum CanvasBackgroundType {
  solidColor,
  blur,
}

/// Model data yang menyimpan konfigurasi transformasi dan crop per klip
class ClipTransformModel {
  final CanvasRatioMode canvasRatio;
  final FitMode fitMode;
  final CanvasBackgroundType backgroundType;
  final double rotationDegrees; // Sudut rotasi halus: -180.0 s/d +180.0 derajat
  final bool flipHorizontal;
  final bool flipVertical;
  // Normalisasi koordinat crop: 0.0 - 1.0 (proporsional dari resolusi asli)
  final double cropLeft;
  final double cropTop;
  final double cropRight;
  final double cropBottom;
  final String backgroundColorHex; // misal "000000" (Hitam) atau "FFFFFF" (Putih)
  final double? customAspectRatio; // Nilai numerik jika canvasRatio == CanvasRatioMode.custom

  const ClipTransformModel({
    this.canvasRatio = CanvasRatioMode.original,
    this.fitMode = FitMode.fit,
    this.backgroundType = CanvasBackgroundType.solidColor,
    this.rotationDegrees = 0.0,
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.cropLeft = 0.0,
    this.cropTop = 0.0,
    this.cropRight = 1.0,
    this.cropBottom = 1.0,
    this.backgroundColorHex = '000000',
    this.customAspectRatio,
  }) : assert(cropLeft >= 0.0 && cropLeft < cropRight, 'cropLeft harus < cropRight'),
       assert(cropTop >= 0.0 && cropTop < cropBottom, 'cropTop harus < cropBottom'),
       assert(cropRight <= 1.0 && cropBottom <= 1.0, 'crop boundary maksimal 1.0');

  /// Apakah klip ini memiliki crop khusus
  bool get hasCustomCrop =>
      cropLeft > 0.001 || cropTop > 0.001 || cropRight < 0.999 || cropBottom < 0.999;

  /// Rasio numerik (lebar / tinggi)
  double? get targetAspectRatio {
    switch (canvasRatio) {
      case CanvasRatioMode.ratio9x16:
        return 9.0 / 16.0;
      case CanvasRatioMode.ratio16x9:
        return 16.0 / 9.0;
      case CanvasRatioMode.ratio1x1:
        return 1.0;
      case CanvasRatioMode.ratio4x5:
        return 4.0 / 5.0;
      case CanvasRatioMode.ratio3x4:
        return 3.0 / 4.0;
      case CanvasRatioMode.ratio4x3:
        return 4.0 / 3.0;
      case CanvasRatioMode.ratio185x1:
        return 1.85;
      case CanvasRatioMode.ratio235x1:
        return 2.35;
      case CanvasRatioMode.ratio239x1:
        return 2.39;
      case CanvasRatioMode.ratio2x1:
        return 2.0 / 1.0;
      case CanvasRatioMode.ratio21x9:
        return 21.0 / 9.0;
      case CanvasRatioMode.custom:
        return customAspectRatio;
      case CanvasRatioMode.original:
        return null;
    }
  }

  ClipTransformModel copyWith({
    CanvasRatioMode? canvasRatio,
    FitMode? fitMode,
    CanvasBackgroundType? backgroundType,
    double? rotationDegrees,
    bool? flipHorizontal,
    bool? flipVertical,
    double? cropLeft,
    double? cropTop,
    double? cropRight,
    double? cropBottom,
    String? backgroundColorHex,
    double? customAspectRatio,
  }) {
    return ClipTransformModel(
      canvasRatio: canvasRatio ?? this.canvasRatio,
      fitMode: fitMode ?? this.fitMode,
      backgroundType: backgroundType ?? this.backgroundType,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      flipHorizontal: flipHorizontal ?? this.flipHorizontal,
      flipVertical: flipVertical ?? this.flipVertical,
      cropLeft: cropLeft ?? this.cropLeft,
      cropTop: cropTop ?? this.cropTop,
      cropRight: cropRight ?? this.cropRight,
      cropBottom: cropBottom ?? this.cropBottom,
      backgroundColorHex: backgroundColorHex ?? this.backgroundColorHex,
      customAspectRatio: customAspectRatio ?? this.customAspectRatio,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'canvasRatio': canvasRatio.name,
      'fitMode': fitMode.name,
      'backgroundType': backgroundType.name,
      'rotationDegrees': rotationDegrees,
      'flipHorizontal': flipHorizontal,
      'flipVertical': flipVertical,
      'cropLeft': cropLeft,
      'cropTop': cropTop,
      'cropRight': cropRight,
      'cropBottom': cropBottom,
      'backgroundColorHex': backgroundColorHex,
      if (customAspectRatio != null) 'customAspectRatio': customAspectRatio,
    };
  }

  factory ClipTransformModel.fromJson(Map<String, dynamic> json) {
    return ClipTransformModel(
      canvasRatio: CanvasRatioMode.values.firstWhere(
        (e) => e.name == json['canvasRatio'],
        orElse: () => CanvasRatioMode.original,
      ),
      fitMode: FitMode.values.firstWhere(
        (e) => e.name == json['fitMode'],
        orElse: () => FitMode.fit,
      ),
      backgroundType: CanvasBackgroundType.values.firstWhere(
        (e) => e.name == json['backgroundType'],
        orElse: () => CanvasBackgroundType.solidColor,
      ),
      rotationDegrees: (json['rotationDegrees'] as num?)?.toDouble() ?? 0.0,
      flipHorizontal: json['flipHorizontal'] as bool? ?? false,
      flipVertical: json['flipVertical'] as bool? ?? false,
      cropLeft: (json['cropLeft'] as num?)?.toDouble() ?? 0.0,
      cropTop: (json['cropTop'] as num?)?.toDouble() ?? 0.0,
      cropRight: (json['cropRight'] as num?)?.toDouble() ?? 1.0,
      cropBottom: (json['cropBottom'] as num?)?.toDouble() ?? 1.0,
      backgroundColorHex: json['backgroundColorHex'] as String? ?? '000000',
      customAspectRatio: (json['customAspectRatio'] as num?)?.toDouble(),
    );
  }
}
