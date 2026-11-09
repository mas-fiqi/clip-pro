import 'advanced_color_model.dart';

/// Kategori Filter Video Profesional
enum FilterCategory {
  original,
  popular,
  natural,
  warm,
  cool,
  cinematic,
  vintage,
  portrait,
  landscape,
  kids,
  gaming,
  blackAndWhite,
  dramatic,
  film,
  custom, // My Presets
}

/// Definisi Preset Filter
enum FilterPreset {
  normal,
  // Natural
  naturalBright,
  fresh,
  // Warm
  warm,
  goldenHour,
  sunset,
  // Cool
  cool,
  nordic,
  arctic,
  // Cinematic
  cinematic,
  tealAndOrange,
  blockbuster,
  // Vintage
  vintage,
  sepia,
  seventies,
  // Portrait
  softSkin,
  glowPortrait,
  // Landscape
  forestGreen,
  deepOcean,
  // Black & White
  grayscale,
  monoContrast,
  noirFilm,
  // Dramatic
  dramatic,
  highContrast,
  cyberpunk,
  // Film
  faded,
  retroRolling,
  kodakGold,
  vivid,
}

/// Metadata Item Filter untuk UI Catalog
class FilterItem {
  final FilterPreset preset;
  final String name;
  final FilterCategory category;
  final String description;
  final List<double> matrix; // 4x5 ColorMatrix untuk WYSIWYG Flutter preview

  const FilterItem({
    required this.preset,
    required this.name,
    required this.category,
    required this.description,
    required this.matrix,
  });
}

/// Model data untuk penyesuaian warna dan efek visual per klip
class ColorAdjustmentModel {
  final FilterPreset preset;
  final double filterIntensity; // 0.0 s/d 1.0 (default 1.0 = 100%)
  final double brightness;      // -1.0 s/d 1.0 (default 0.0)
  final double contrast;        // -1.0 s/d 1.0 (default 0.0)
  final double saturation;      // -1.0 s/d 1.0 (default 0.0)
  final double exposure;        // -1.0 s/d 1.0 (default 0.0)
  final double highlights;      // -1.0 s/d 1.0 (default 0.0)
  final double shadows;         // -1.0 s/d 1.0 (default 0.0)
  final double whites;          // -1.0 s/d 1.0 (default 0.0)
  final double blacks;          // -1.0 s/d 1.0 (default 0.0)
  final double temperature;     // -1.0 s/d 1.0 (default 0.0, dingin ke hangat)
  final double tint;            // -1.0 s/d 1.0 (default 0.0, hijau ke magenta)
  final double sharpen;         // 0.0 s/d 1.0 (default 0.0)
  final double clarity;         // 0.0 s/d 1.0 (default 0.0)
  final double vignette;        // 0.0 s/d 1.0 (default 0.0)
  final double blur;            // 0.0 s/d 1.0 (default 0.0)
  final HslChannelsModel hsl;   // HSL 8-Warna (Merah, Jingga, Kuning, Hijau, Cyan, Biru, Ungu, Magenta)
  final ColorWheelsModel colorWheels; // Tonal Wheels: Shadows, Midtones, Highlights

  const ColorAdjustmentModel({
    this.preset = FilterPreset.normal,
    this.filterIntensity = 1.0,
    this.brightness = 0.0,
    this.contrast = 0.0,
    this.saturation = 0.0,
    this.exposure = 0.0,
    this.highlights = 0.0,
    this.shadows = 0.0,
    this.whites = 0.0,
    this.blacks = 0.0,
    this.temperature = 0.0,
    this.tint = 0.0,
    this.sharpen = 0.0,
    this.clarity = 0.0,
    this.vignette = 0.0,
    this.blur = 0.0,
    this.hsl = const HslChannelsModel(),
    this.colorWheels = const ColorWheelsModel(),
  }) : assert(filterIntensity >= 0.0 && filterIntensity <= 1.0, 'filterIntensity rentang 0.0 s/d 1.0'),
       assert(brightness >= -1.0 && brightness <= 1.0, 'brightness rentang -1.0 s/d 1.0'),
       assert(contrast >= -1.0 && contrast <= 1.0, 'contrast rentang -1.0 s/d 1.0'),
       assert(saturation >= -1.0 && saturation <= 1.0, 'saturation rentang -1.0 s/d 1.0'),
       assert(exposure >= -1.0 && exposure <= 1.0, 'exposure rentang -1.0 s/d 1.0'),
       assert(highlights >= -1.0 && highlights <= 1.0, 'highlights rentang -1.0 s/d 1.0'),
       assert(shadows >= -1.0 && shadows <= 1.0, 'shadows rentang -1.0 s/d 1.0'),
       assert(temperature >= -1.0 && temperature <= 1.0, 'temperature rentang -1.0 s/d 1.0'),
       assert(tint >= -1.0 && tint <= 1.0, 'tint rentang -1.0 s/d 1.0'),
       assert(vignette >= 0.0 && vignette <= 1.0, 'vignette rentang 0.0 s/d 1.0'),
       assert(blur >= 0.0 && blur <= 1.0, 'blur rentang 0.0 s/d 1.0');

  bool get hasAdjustment =>
      (preset != FilterPreset.normal && filterIntensity > 0.0) ||
      brightness != 0.0 ||
      contrast != 0.0 ||
      saturation != 0.0 ||
      exposure != 0.0 ||
      highlights != 0.0 ||
      shadows != 0.0 ||
      whites != 0.0 ||
      blacks != 0.0 ||
      temperature != 0.0 ||
      tint != 0.0 ||
      sharpen != 0.0 ||
      clarity != 0.0 ||
      vignette != 0.0 ||
      blur != 0.0 ||
      hsl.hasAdjustment ||
      colorWheels.hasAdjustment;

  ColorAdjustmentModel copyWith({
    FilterPreset? preset,
    double? filterIntensity,
    double? brightness,
    double? contrast,
    double? saturation,
    double? exposure,
    double? highlights,
    double? shadows,
    double? whites,
    double? blacks,
    double? temperature,
    double? tint,
    double? sharpen,
    double? clarity,
    double? vignette,
    double? blur,
    HslChannelsModel? hsl,
    ColorWheelsModel? colorWheels,
  }) {
    return ColorAdjustmentModel(
      preset: preset ?? this.preset,
      filterIntensity: filterIntensity ?? this.filterIntensity,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      exposure: exposure ?? this.exposure,
      highlights: highlights ?? this.highlights,
      shadows: shadows ?? this.shadows,
      whites: whites ?? this.whites,
      blacks: blacks ?? this.blacks,
      temperature: temperature ?? this.temperature,
      tint: tint ?? this.tint,
      sharpen: sharpen ?? this.sharpen,
      clarity: clarity ?? this.clarity,
      vignette: vignette ?? this.vignette,
      blur: blur ?? this.blur,
      hsl: hsl ?? this.hsl,
      colorWheels: colorWheels ?? this.colorWheels,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preset': preset.name,
      'filterIntensity': filterIntensity,
      'brightness': brightness,
      'contrast': contrast,
      'saturation': saturation,
      'exposure': exposure,
      'highlights': highlights,
      'shadows': shadows,
      'whites': whites,
      'blacks': blacks,
      'temperature': temperature,
      'tint': tint,
      'sharpen': sharpen,
      'clarity': clarity,
      'vignette': vignette,
      'blur': blur,
      'hsl': hsl.toJson(),
      'colorWheels': colorWheels.toJson(),
    };
  }

  factory ColorAdjustmentModel.fromJson(Map<String, dynamic> json) {
    return ColorAdjustmentModel(
      preset: FilterPreset.values.firstWhere(
        (e) => e.name == json['preset'],
        orElse: () => FilterPreset.normal,
      ),
      filterIntensity: (json['filterIntensity'] as num?)?.toDouble() ?? 1.0,
      brightness: (json['brightness'] as num?)?.toDouble() ?? 0.0,
      contrast: (json['contrast'] as num?)?.toDouble() ?? 0.0,
      saturation: (json['saturation'] as num?)?.toDouble() ?? 0.0,
      exposure: (json['exposure'] as num?)?.toDouble() ?? 0.0,
      highlights: (json['highlights'] as num?)?.toDouble() ?? 0.0,
      shadows: (json['shadows'] as num?)?.toDouble() ?? 0.0,
      whites: (json['whites'] as num?)?.toDouble() ?? 0.0,
      blacks: (json['blacks'] as num?)?.toDouble() ?? 0.0,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      tint: (json['tint'] as num?)?.toDouble() ?? 0.0,
      sharpen: (json['sharpen'] as num?)?.toDouble() ?? 0.0,
      clarity: (json['clarity'] as num?)?.toDouble() ?? 0.0,
      vignette: (json['vignette'] as num?)?.toDouble() ?? 0.0,
      blur: (json['blur'] as num?)?.toDouble() ?? 0.0,
      hsl: json['hsl'] != null ? HslChannelsModel.fromJson(json['hsl'] as Map<String, dynamic>) : const HslChannelsModel(),
      colorWheels: json['colorWheels'] != null ? ColorWheelsModel.fromJson(json['colorWheels'] as Map<String, dynamic>) : const ColorWheelsModel(),
    );
  }
}
