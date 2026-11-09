/// HSL Color Adjustments (Hue, Saturation, Luminance) per channel warna
class HslColorAdjustment {
  final double hue; // -180.0 s/d 180.0 (pergeseran derajat hue)
  final double saturation; // -1.0 s/d 1.0 (default 0.0)
  final double luminance; // -1.0 s/d 1.0 (default 0.0)

  const HslColorAdjustment({
    this.hue = 0.0,
    this.saturation = 0.0,
    this.luminance = 0.0,
  });

  bool get hasAdjustment => hue != 0.0 || saturation != 0.0 || luminance != 0.0;

  HslColorAdjustment copyWith({
    double? hue,
    double? saturation,
    double? luminance,
  }) {
    return HslColorAdjustment(
      hue: hue ?? this.hue,
      saturation: saturation ?? this.saturation,
      luminance: luminance ?? this.luminance,
    );
  }

  Map<String, dynamic> toJson() => {
    'hue': hue,
    'saturation': saturation,
    'luminance': luminance,
  };

  factory HslColorAdjustment.fromJson(Map<String, dynamic> json) {
    return HslColorAdjustment(
      hue: (json['hue'] as num?)?.toDouble() ?? 0.0,
      saturation: (json['saturation'] as num?)?.toDouble() ?? 0.0,
      luminance: (json['luminance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// 8 Saluran Warna Standar Editor Video Profesional
class HslChannelsModel {
  final HslColorAdjustment red;
  final HslColorAdjustment orange;
  final HslColorAdjustment yellow;
  final HslColorAdjustment green;
  final HslColorAdjustment cyan;
  final HslColorAdjustment blue;
  final HslColorAdjustment purple;
  final HslColorAdjustment magenta;

  const HslChannelsModel({
    this.red = const HslColorAdjustment(),
    this.orange = const HslColorAdjustment(),
    this.yellow = const HslColorAdjustment(),
    this.green = const HslColorAdjustment(),
    this.cyan = const HslColorAdjustment(),
    this.blue = const HslColorAdjustment(),
    this.purple = const HslColorAdjustment(),
    this.magenta = const HslColorAdjustment(),
  });

  bool get hasAdjustment =>
      red.hasAdjustment ||
      orange.hasAdjustment ||
      yellow.hasAdjustment ||
      green.hasAdjustment ||
      cyan.hasAdjustment ||
      blue.hasAdjustment ||
      purple.hasAdjustment ||
      magenta.hasAdjustment;

  HslChannelsModel copyWith({
    HslColorAdjustment? red,
    HslColorAdjustment? orange,
    HslColorAdjustment? yellow,
    HslColorAdjustment? green,
    HslColorAdjustment? cyan,
    HslColorAdjustment? blue,
    HslColorAdjustment? purple,
    HslColorAdjustment? magenta,
  }) {
    return HslChannelsModel(
      red: red ?? this.red,
      orange: orange ?? this.orange,
      yellow: yellow ?? this.yellow,
      green: green ?? this.green,
      cyan: cyan ?? this.cyan,
      blue: blue ?? this.blue,
      purple: purple ?? this.purple,
      magenta: magenta ?? this.magenta,
    );
  }

  Map<String, dynamic> toJson() => {
    'red': red.toJson(),
    'orange': orange.toJson(),
    'yellow': yellow.toJson(),
    'green': green.toJson(),
    'cyan': cyan.toJson(),
    'blue': blue.toJson(),
    'purple': purple.toJson(),
    'magenta': magenta.toJson(),
  };

  factory HslChannelsModel.fromJson(Map<String, dynamic> json) {
    return HslChannelsModel(
      red: json['red'] != null ? HslColorAdjustment.fromJson(json['red'] as Map<String, dynamic>) : const HslColorAdjustment(),
      orange: json['orange'] != null ? HslColorAdjustment.fromJson(json['orange'] as Map<String, dynamic>) : const HslColorAdjustment(),
      yellow: json['yellow'] != null ? HslColorAdjustment.fromJson(json['yellow'] as Map<String, dynamic>) : const HslColorAdjustment(),
      green: json['green'] != null ? HslColorAdjustment.fromJson(json['green'] as Map<String, dynamic>) : const HslColorAdjustment(),
      cyan: json['cyan'] != null ? HslColorAdjustment.fromJson(json['cyan'] as Map<String, dynamic>) : const HslColorAdjustment(),
      blue: json['blue'] != null ? HslColorAdjustment.fromJson(json['blue'] as Map<String, dynamic>) : const HslColorAdjustment(),
      purple: json['purple'] != null ? HslColorAdjustment.fromJson(json['purple'] as Map<String, dynamic>) : const HslColorAdjustment(),
      magenta: json['magenta'] != null ? HslColorAdjustment.fromJson(json['magenta'] as Map<String, dynamic>) : const HslColorAdjustment(),
    );
  }
}

/// Color Wheels (Tonal Color Wheels): Shadows, Midtones, Highlights
class ColorWheelValue {
  final double angleDegrees; // 0 s/d 360 derajat (arah warna)
  final double intensity; // 0.0 s/d 1.0 (kejenuhan tint)
  final double luminanceOffset; // -1.0 s/d 1.0

  const ColorWheelValue({
    this.angleDegrees = 0.0,
    this.intensity = 0.0,
    this.luminanceOffset = 0.0,
  });

  bool get hasAdjustment => intensity > 0.0 || luminanceOffset != 0.0;

  Map<String, dynamic> toJson() => {
    'angleDegrees': angleDegrees,
    'intensity': intensity,
    'luminanceOffset': luminanceOffset,
  };

  factory ColorWheelValue.fromJson(Map<String, dynamic> json) {
    return ColorWheelValue(
      angleDegrees: (json['angleDegrees'] as num?)?.toDouble() ?? 0.0,
      intensity: (json['intensity'] as num?)?.toDouble() ?? 0.0,
      luminanceOffset: (json['luminanceOffset'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ColorWheelsModel {
  final ColorWheelValue shadows;
  final ColorWheelValue midtones;
  final ColorWheelValue highlights;

  const ColorWheelsModel({
    this.shadows = const ColorWheelValue(),
    this.midtones = const ColorWheelValue(),
    this.highlights = const ColorWheelValue(),
  });

  bool get hasAdjustment =>
      shadows.hasAdjustment || midtones.hasAdjustment || highlights.hasAdjustment;

  ColorWheelsModel copyWith({
    ColorWheelValue? shadows,
    ColorWheelValue? midtones,
    ColorWheelValue? highlights,
  }) {
    return ColorWheelsModel(
      shadows: shadows ?? this.shadows,
      midtones: midtones ?? this.midtones,
      highlights: highlights ?? this.highlights,
    );
  }

  Map<String, dynamic> toJson() => {
    'shadows': shadows.toJson(),
    'midtones': midtones.toJson(),
    'highlights': highlights.toJson(),
  };

  factory ColorWheelsModel.fromJson(Map<String, dynamic> json) {
    return ColorWheelsModel(
      shadows: json['shadows'] != null ? ColorWheelValue.fromJson(json['shadows'] as Map<String, dynamic>) : const ColorWheelValue(),
      midtones: json['midtones'] != null ? ColorWheelValue.fromJson(json['midtones'] as Map<String, dynamic>) : const ColorWheelValue(),
      highlights: json['highlights'] != null ? ColorWheelValue.fromJson(json['highlights'] as Map<String, dynamic>) : const ColorWheelValue(),
    );
  }
}

/// Model Preset Filter Buatan Pengguna (My Presets)
class UserCustomPresetModel {
  final String id;
  final String name;
  final bool isFavorite;
  final DateTime createdAt;

  const UserCustomPresetModel({
    required this.id,
    required this.name,
    this.isFavorite = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isFavorite': isFavorite,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserCustomPresetModel.fromJson(Map<String, dynamic> json) {
    return UserCustomPresetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

