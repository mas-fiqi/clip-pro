import 'color_adjustment_model.dart';

class FilterCatalog {
  static const List<FilterItem> items = [
    // Original
    FilterItem(
      preset: FilterPreset.normal,
      name: 'Original',
      category: FilterCategory.original,
      description: 'Warna asli rekaman tanpa efek pewarnaan',
      matrix: [
        1, 0, 0, 0, 0,
        0, 1, 0, 0, 0,
        0, 0, 1, 0, 0,
        0, 0, 0, 1, 0,
      ],
    ),

    // Popular
    FilterItem(
      preset: FilterPreset.cinematic,
      name: 'Popular Cinema',
      category: FilterCategory.popular,
      description: 'Kontras sinematik populer paling disukai pembuat video',
      matrix: [
        1.1, 0, 0, 0, 5,
        0, 1.0, 0, 0, 0,
        0, 0, 1.15, 0, 10,
        0, 0, 0, 1, 0,
      ],
    ),

    // Kids
    FilterItem(
      preset: FilterPreset.vivid,
      name: 'Kids Cheerful',
      category: FilterCategory.kids,
      description: 'Tone cerah dan penuh warna khusus untuk momen anak-anak',
      matrix: [
        1.2, 0, 0, 0, 10,
        0, 1.2, 0, 0, 10,
        0, 0, 1.2, 0, 10,
        0, 0, 0, 1, 0,
      ],
    ),

    // Gaming
    FilterItem(
      preset: FilterPreset.cyberpunk,
      name: 'Gaming Cyber',
      category: FilterCategory.gaming,
      description: 'Gaya neon gaming cyberpunk kontras tinggi',
      matrix: [
        1.3, 0, 0, 0, 20,
        0, 0.9, 0, 0, -10,
        0, 0, 1.4, 0, 25,
        0, 0, 0, 1, 0,
      ],
    ),

    // Custom
    FilterItem(
      preset: FilterPreset.normal,
      name: 'Custom User Base',
      category: FilterCategory.custom,
      description: 'Titik dasar untuk pengaturan preset kustom',
      matrix: [
        1, 0, 0, 0, 0,
        0, 1, 0, 0, 0,
        0, 0, 1, 0, 0,
        0, 0, 0, 1, 0,
      ],
    ),

    // Natural
    FilterItem(
      preset: FilterPreset.naturalBright,
      name: 'Bright',
      category: FilterCategory.natural,
      description: 'Mencerahkan tone alami dengan eksposur jernih',
      matrix: [
        1.1, 0, 0, 0, 15,
        0, 1.1, 0, 0, 15,
        0, 0, 1.1, 0, 15,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterItem(
      preset: FilterPreset.fresh,
      name: 'Fresh Clean',
      category: FilterCategory.natural,
      description: 'Tone segar dengan penekanan pada kejernihan hijau dan biru',
      matrix: [
        0.95, 0, 0, 0, 5,
        0, 1.15, 0, 0, 10,
        0, 0, 1.1, 0, 12,
        0, 0, 0, 1, 0,
      ],
    ),

    // Warm
    FilterItem(
      preset: FilterPreset.warm,
      name: 'Warm Sunset',
      category: FilterCategory.warm,
      description: 'Nuansa hangat lembut dengan highlight oranye lembut',
      matrix: [
        1.15, 0, 0, 0, 20,
        0, 1.05, 0, 0, 10,
        0, 0, 0.85, 0, -15,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterItem(
      preset: FilterPreset.goldenHour,
      name: 'Golden Hour',
      category: FilterCategory.warm,
      description: 'Sinar keemasan sore hari yang sinematik',
      matrix: [
        1.25, 0, 0, 0, 28,
        0, 1.1, 0, 0, 15,
        0, 0, 0.75, 0, -25,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterItem(
      preset: FilterPreset.sunset,
      name: 'Deep Sunset',
      category: FilterCategory.warm,
      description: 'Pijar senja merah saga dan magenta dramatis',
      matrix: [
        1.3, 0, 0, 0, 30,
        0, 0.95, 0, 0, 5,
        0, 0, 0.9, 0, 15,
        0, 0, 0, 1, 0,
      ],
    ),

    // Cool
    FilterItem(
      preset: FilterPreset.cool,
      name: 'Cool Breeze',
      category: FilterCategory.cool,
      description: 'Pemberian nuansa sejuk dingin bernada biru',
      matrix: [
        0.85, 0, 0, 0, -10,
        0, 1.0, 0, 0, 5,
        0, 0, 1.25, 0, 25,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterItem(
      preset: FilterPreset.nordic,
      name: 'Nordic Mood',
      category: FilterCategory.cool,
      description: 'Gaya sinematik Skandinavia dengan saturasi teduh',
      matrix: [
        0.8, 0, 0, 0, 0,
        0, 0.95, 0, 0, 5,
        0, 0, 1.3, 0, 20,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterItem(
      preset: FilterPreset.arctic,
      name: 'Arctic Frost',
      category: FilterCategory.cool,
      description: 'Kontras dingin tajam seperti es glasier kutub',
      matrix: [
        0.75, 0, 0, 0, 5,
        0, 1.05, 0, 0, 10,
        0, 0, 1.4, 0, 35,
        0, 0, 0, 1, 0,
      ],
    ),

    // Cinematic
    FilterItem(
      preset: FilterPreset.cinematic,
      name: 'Film Standard',
      category: FilterCategory.cinematic,
      description: 'Kontras kaya dan kedalaman warna layar bioskop',
      matrix: [
        1.15, 0, 0, 0, -5,
        0, 1.1, 0, 0, -5,
        0, 0, 1.05, 0, -5,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterItem(
      preset: FilterPreset.tealAndOrange,
      name: 'Teal & Orange',
      category: FilterCategory.cinematic,
      description: 'Keseimbangan legendaris Hollywood: kulit hangat & bayangan teal',
      matrix: [
        1.25, 0, 0, 0, 20,
        0, 1.05, 0, 0, 0,
        0, 0, 1.25, 0, 15,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterItem(
      preset: FilterPreset.blockbuster,
      name: 'Blockbuster',
      category: FilterCategory.cinematic,
      description: 'Gaya film aksi berenergi tinggi dengan kontras tajam',
      matrix: [
        1.3, 0, 0, 0, 10,
        0, 1.2, 0, 0, 5,
        0, 0, 1.2, 0, 10,
        0, 0, 0, 1, 0,
      ],
    ),

    // Vintage
    FilterItem(
      preset: FilterPreset.vintage,
      name: 'Vintage 90s',
      category: FilterCategory.vintage,
      description: 'Warna hangat pudar ala kaset VHS dan foto analog 90-an',
      matrix: [
        1.1, 0, 0, 0, 15,
        0, 1.0, 0, 0, 10,
        0, 0, 0.8, 0, 5,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterItem(
      preset: FilterPreset.sepia,
      name: 'Classic Sepia',
      category: FilterCategory.vintage,
      description: 'Coklat keemasan monokromatik antik abad 19',
      matrix: [
        0.393, 0.769, 0.189, 0, 0,
        0.349, 0.686, 0.168, 0, 0,
        0.272, 0.534, 0.131, 0, 0,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterItem(
      preset: FilterPreset.seventies,
      name: 'Retro 70s',
      category: FilterCategory.vintage,
      description: 'Palet hangat kusam dengan saturasi coklat oranye retro',
      matrix: [
        1.2, 0, 0, 0, 18,
        0, 1.05, 0, 0, 12,
        0, 0, 0.7, 0, -20,
        0, 0, 0, 1, 0,
      ],
    ),

    // Portrait
    FilterItem(
      preset: FilterPreset.softSkin,
      name: 'Soft Glow',
      category: FilterCategory.portrait,
      description: 'Tone lembut halus yang mencerahkan kulit wajah',
      matrix: [
        1.08, 0, 0, 0, 16,
        0, 1.04, 0, 0, 12,
        0, 0, 1.02, 0, 10,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterItem(
      preset: FilterPreset.glowPortrait,
      name: 'Rose Blush',
      category: FilterCategory.portrait,
      description: 'Sentuhan rona merah muda merona dan bercahaya',
      matrix: [
        1.15, 0, 0, 0, 22,
        0, 1.0, 0, 0, 8,
        0, 0, 1.05, 0, 16,
        0, 0, 0, 1, 0,
      ],
    ),

    // Landscape
    FilterItem(
      preset: FilterPreset.forestGreen,
      name: 'Deep Forest',
      category: FilterCategory.landscape,
      description: 'Memperkuat kedalaman daun dan panorama alam hijau',
      matrix: [
        0.9, 0, 0, 0, -5,
        0, 1.25, 0, 0, 18,
        0, 0, 0.95, 0, -5,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterItem(
      preset: FilterPreset.deepOcean,
      name: 'Deep Ocean',
      category: FilterCategory.landscape,
      description: 'Kaya akan warna biru toska samudra dan langit cerah',
      matrix: [
        0.85, 0, 0, 0, -10,
        0, 1.1, 0, 0, 12,
        0, 0, 1.35, 0, 30,
        0, 0, 0, 1, 0,
      ],
    ),

    // Black & White
    FilterItem(
      preset: FilterPreset.grayscale,
      name: 'Classic B&W',
      category: FilterCategory.blackAndWhite,
      description: 'Konversi hitam putih natural seimbang',
      matrix: [
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterItem(
      preset: FilterPreset.monoContrast,
      name: 'Mono Contrast',
      category: FilterCategory.blackAndWhite,
      description: 'Hitam putih dramatis dengan rasio kontras tegas',
      matrix: [
        0.3, 0.7, 0.1, 0, -15,
        0.3, 0.7, 0.1, 0, -15,
        0.3, 0.7, 0.1, 0, -15,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterItem(
      preset: FilterPreset.noirFilm,
      name: 'Film Noir',
      category: FilterCategory.blackAndWhite,
      description: 'Estetika film misteri Hollywood lawas penuh bayangan pekat',
      matrix: [
        0.35, 0.65, 0.1, 0, -30,
        0.35, 0.65, 0.1, 0, -30,
        0.35, 0.65, 0.1, 0, -30,
        0, 0, 0, 1, 0,
      ],
    ),

    // Dramatic
    FilterItem(
      preset: FilterPreset.dramatic,
      name: 'Dark Moody',
      category: FilterCategory.dramatic,
      description: 'Mood gelap sinematik penuh misteri',
      matrix: [
        1.1, 0, 0, 0, -25,
        0, 1.05, 0, 0, -25,
        0, 0, 1.15, 0, -15,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterItem(
      preset: FilterPreset.highContrast,
      name: 'High Pop',
      category: FilterCategory.dramatic,
      description: 'Menonjolkan detail dan saturasi tinggi yang memukau',
      matrix: [
        1.3, 0, 0, 0, -10,
        0, 1.3, 0, 0, -10,
        0, 0, 1.3, 0, -10,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterItem(
      preset: FilterPreset.cyberpunk,
      name: 'Cyber Neon',
      category: FilterCategory.dramatic,
      description: 'Nuansa futuristik neon ungu dan biru neon',
      matrix: [
        1.25, 0, 0, 0, 20,
        0, 0.85, 0, 0, -15,
        0, 0, 1.45, 0, 35,
        0, 0, 0, 1, 0,
      ],
    ),

    // Film
    FilterItem(
      preset: FilterPreset.faded,
      name: 'Matte Fade',
      category: FilterCategory.film,
      description: 'Pencahayaan matte lembut dengan shadow terangkat',
      matrix: [
        0.9, 0, 0, 0, 25,
        0, 0.9, 0, 0, 25,
        0, 0, 0.9, 0, 25,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterItem(
      preset: FilterPreset.retroRolling,
      name: 'Retro Rolling',
      category: FilterCategory.film,
      description: 'Gaya pita seluloid retro dengan scanline dan warmth',
      matrix: [
        1.15, 0, 0, 0, 15,
        0, 1.05, 0, 0, 8,
        0, 0, 0.8, 0, -10,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterItem(
      preset: FilterPreset.kodakGold,
      name: 'Kodak Film',
      category: FilterCategory.film,
      description: 'Warna emas hangat khas film rol Kodak legendaris',
      matrix: [
        1.2, 0, 0, 0, 18,
        0, 1.1, 0, 0, 10,
        0, 0, 0.85, 0, -12,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterItem(
      preset: FilterPreset.vivid,
      name: 'Fuji Chrome',
      category: FilterCategory.film,
      description: 'Saturasi hidup kaya warna khas film slide lanskap',
      matrix: [
        1.25, 0, 0, 0, 5,
        0, 1.25, 0, 0, 5,
        0, 0, 1.25, 0, 5,
        0, 0, 0, 1, 0,
      ],
    ),
  ];

  static FilterItem getItem(FilterPreset preset) {
    return items.firstWhere(
      (e) => e.preset == preset,
      orElse: () => items.first,
    );
  }

  /// Menghitung matrix interpolasi berdasarkan intensitas 0.0 - 1.0
  static List<double> getBlendedMatrix(FilterPreset preset, double intensity) {
    final target = getItem(preset).matrix;
    const identity = [
      1.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 1.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 1.0, 0.0,
    ];

    if (intensity <= 0.0 || preset == FilterPreset.normal) {
      return identity;
    }
    if (intensity >= 1.0) {
      return target;
    }

    final result = List<double>.filled(20, 0.0);
    for (int i = 0; i < 20; i++) {
      result[i] = identity[i] + (target[i] - identity[i]) * intensity;
    }
    return result;
  }
}
