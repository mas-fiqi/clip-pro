enum OverlayType {
  text,
  sticker,
  subtitle,
  image, // Foto / Stiker Gambar dari Galeri
  video, // Video PiP (Picture-in-Picture)
}

enum TextPresetStyle {
  plain,
  bold,
  outline,
  shadow,
  highlightBox,
  neon,
}

/// Model data overlay multi-layer (Teks, Subtitle, Stiker, Gambar, Video PiP)
class OverlayModel {
  final String id;
  final OverlayType type;
  final String content; // Teks tulisan, emoji, atau path berkas media gambar/video
  final double startTime; // detik timeline global
  final double endTime;   // detik timeline global
  // Posisi normalisasi (0.0 - 1.0) terhadap kanvas
  final double normalizedX; // default 0.5 (tengah horizontal)
  final double normalizedY; // default 0.5 (tengah vertikal)
  final double scale;
  final double rotationDegrees;
  final double opacity;
  final bool isVisible;
  final int layerOrder;

  // Atribut styling teks & media
  final double fontSize;
  final String textColorHex; // misal "FFFFFF" (Putih)
  final String? backgroundColorHex; // misal "000000" (Hitam)
  final String? outlineColorHex;
  final double outlineWidth;
  final TextPresetStyle presetStyle;

  const OverlayModel({
    required this.id,
    required this.type,
    required this.content,
    required this.startTime,
    required this.endTime,
    this.normalizedX = 0.5,
    this.normalizedY = 0.5,
    this.scale = 1.0,
    this.rotationDegrees = 0.0,
    this.opacity = 1.0,
    this.isVisible = true,
    this.layerOrder = 0,
    this.fontSize = 24.0,
    this.textColorHex = 'FFFFFF',
    this.backgroundColorHex,
    this.outlineColorHex,
    this.outlineWidth = 0.0,
    this.presetStyle = TextPresetStyle.plain,
  }) : assert(id.length > 0, 'ID tidak boleh kosong'),
       assert(endTime > startTime, 'endTime harus lebih besar dari startTime'),
       assert(opacity >= 0.0 && opacity <= 1.0, 'opacity harus 0.0 - 1.0');

  /// Apakah overlay ini sedang aktif pada posisi detik timeline saat ini
  bool isActiveAt(double globalTime) {
    if (!isVisible) return false;
    return globalTime >= startTime && globalTime <= endTime;
  }

  OverlayModel copyWith({
    String? id,
    OverlayType? type,
    String? content,
    double? startTime,
    double? endTime,
    double? normalizedX,
    double? normalizedY,
    double? scale,
    double? rotationDegrees,
    double? opacity,
    bool? isVisible,
    int? layerOrder,
    double? fontSize,
    String? textColorHex,
    String? backgroundColorHex,
    String? outlineColorHex,
    double? outlineWidth,
    TextPresetStyle? presetStyle,
  }) {
    return OverlayModel(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      normalizedX: normalizedX ?? this.normalizedX,
      normalizedY: normalizedY ?? this.normalizedY,
      scale: scale ?? this.scale,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      opacity: opacity ?? this.opacity,
      isVisible: isVisible ?? this.isVisible,
      layerOrder: layerOrder ?? this.layerOrder,
      fontSize: fontSize ?? this.fontSize,
      textColorHex: textColorHex ?? this.textColorHex,
      backgroundColorHex: backgroundColorHex ?? this.backgroundColorHex,
      outlineColorHex: outlineColorHex ?? this.outlineColorHex,
      outlineWidth: outlineWidth ?? this.outlineWidth,
      presetStyle: presetStyle ?? this.presetStyle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'content': content,
      'startTime': startTime,
      'endTime': endTime,
      'normalizedX': normalizedX,
      'normalizedY': normalizedY,
      'scale': scale,
      'rotationDegrees': rotationDegrees,
      'opacity': opacity,
      'isVisible': isVisible,
      'layerOrder': layerOrder,
      'fontSize': fontSize,
      'textColorHex': textColorHex,
      'backgroundColorHex': backgroundColorHex,
      'outlineColorHex': outlineColorHex,
      'outlineWidth': outlineWidth,
      'presetStyle': presetStyle.name,
    };
  }

  factory OverlayModel.fromJson(Map<String, dynamic> json) {
    return OverlayModel(
      id: json['id'] as String,
      type: OverlayType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => OverlayType.text,
      ),
      content: json['content'] as String,
      startTime: (json['startTime'] as num).toDouble(),
      endTime: (json['endTime'] as num).toDouble(),
      normalizedX: (json['normalizedX'] as num?)?.toDouble() ?? 0.5,
      normalizedY: (json['normalizedY'] as num?)?.toDouble() ?? 0.5,
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      rotationDegrees: (json['rotationDegrees'] as num?)?.toDouble() ?? 0.0,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      isVisible: json['isVisible'] as bool? ?? true,
      layerOrder: (json['layerOrder'] as num?)?.toInt() ?? 0,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 24.0,
      textColorHex: json['textColorHex'] as String? ?? 'FFFFFF',
      backgroundColorHex: json['backgroundColorHex'] as String?,
      outlineColorHex: json['outlineColorHex'] as String?,
      outlineWidth: (json['outlineWidth'] as num?)?.toDouble() ?? 0.0,
      presetStyle: TextPresetStyle.values.firstWhere(
        (e) => e.name == json['presetStyle'],
        orElse: () => TextPresetStyle.plain,
      ),
    );
  }
}
