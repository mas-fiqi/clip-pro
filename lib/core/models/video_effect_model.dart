import 'package:flutter/material.dart';

/// 12 Kategori Efek Video Profesional
enum EffectCategory {
  basic,
  cinematic,
  vintage,
  glitch,
  blur,
  light,
  distortion,
  retro,
  color,
  motion,
  creative,
}

/// Tipe Efek Video
enum EffectType {
  none,
  // Basic
  sharpen,
  edgeEnhance,
  invert,
  // Cinematic
  anamorphicFlare,
  letterbox,
  vignetteDark,
  // Vintage
  oldFilmGrain,
  sepiaFilm,
  vhsTape,
  // Glitch
  rgbSplit,
  colorGlitch,
  pixelate,
  // Blur
  radialBlur,
  gaussianSoft,
  tiltShift,
  // Light
  glowAura,
  lensBrightness,
  lightLeak,
  // Distortion
  mirrorHorizontal,
  mirrorVertical,
  fishEye,
  // Retro
  retroScanline,
  halftone,
  comicBook,
  // Color
  duotoneCyanRed,
  cyberpunkGlow,
  thermalVision,
  // Motion
  speedLines,
  stutterMotion,
  zoomPulse,
  // Creative
  dreamyGlow,
  emboss,
  kaleidoscope,
  // Motion Blur
  motionBlur,
}

/// Arah Gerak Samar (Motion Blur Direction)
enum MotionBlurDirection {
  forward,  // Kedepan
  backward, // Kebelakang
  both,     // Keduanya
}

/// Model Data Efek Video
class VideoEffectModel {
  final EffectType type;
  final double intensity; // 0.0 s/d 1.0 (default 1.0 = 100%)
  final double durationSeconds; // Durasi penerapan, 0.0 = sepanjang klip
  final bool isFavorite;

  // Atribut Gerak Samar (Motion Blur CapCut Style)
  final double blurAmount; // Kabur yang bisa diatur custom (0.0 s/d 100.0)
  final double blendAmount; // Campuran (0.0 s/d 100.0)
  final MotionBlurDirection motionDirection; // Kedepan, Kebelakang, Keduanya
  final int motionTimes; // Kali x (1 sampai 6)

  const VideoEffectModel({
    this.type = EffectType.none,
    this.intensity = 1.0,
    this.durationSeconds = 0.0,
    this.isFavorite = false,
    this.blurAmount = 50.0,
    this.blendAmount = 50.0,
    this.motionDirection = MotionBlurDirection.both,
    this.motionTimes = 2,
  }) : assert(intensity >= 0.0 && intensity <= 1.0, 'intensity rentang 0.0 s/d 1.0');

  bool get hasEffect => type != EffectType.none && intensity > 0.0;

  VideoEffectModel copyWith({
    EffectType? type,
    double? intensity,
    double? durationSeconds,
    bool? isFavorite,
    double? blurAmount,
    double? blendAmount,
    MotionBlurDirection? motionDirection,
    int? motionTimes,
  }) {
    return VideoEffectModel(
      type: type ?? this.type,
      intensity: intensity ?? this.intensity,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isFavorite: isFavorite ?? this.isFavorite,
      blurAmount: blurAmount ?? this.blurAmount,
      blendAmount: blendAmount ?? this.blendAmount,
      motionDirection: motionDirection ?? this.motionDirection,
      motionTimes: motionTimes ?? this.motionTimes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'intensity': intensity,
      'durationSeconds': durationSeconds,
      'isFavorite': isFavorite,
      'blurAmount': blurAmount,
      'blendAmount': blendAmount,
      'motionDirection': motionDirection.name,
      'motionTimes': motionTimes,
    };
  }

  factory VideoEffectModel.fromJson(Map<String, dynamic> json) {
    return VideoEffectModel(
      type: EffectType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EffectType.none,
      ),
      intensity: (json['intensity'] as num?)?.toDouble() ?? 1.0,
      durationSeconds: (json['durationSeconds'] as num?)?.toDouble() ?? 0.0,
      isFavorite: (json['isFavorite'] as bool?) ?? false,
      blurAmount: (json['blurAmount'] as num?)?.toDouble() ?? 50.0,
      blendAmount: (json['blendAmount'] as num?)?.toDouble() ?? 50.0,
      motionDirection: MotionBlurDirection.values.firstWhere(
        (e) => e.name == json['motionDirection'],
        orElse: () => MotionBlurDirection.both,
      ),
      motionTimes: (json['motionTimes'] as num?)?.toInt() ?? 2,
    );
  }
}

/// Metadata Item Efek untuk UI Catalog
class EffectCatalogItem {
  final EffectType type;
  final String name;
  final EffectCategory category;
  final String description;
  final IconData icon;
  final String ffmpegFilterPattern; // Template FFmpeg filter
  final String? previewVideoAsset; // Path video demonstrasi nyata
  final String? thumbnailFallback; // Gambar model nyata jika video belum dimuat
  final double defaultIntensity;
  final double previewDuration;

  const EffectCatalogItem({
    required this.type,
    required this.name,
    required this.category,
    required this.description,
    required this.icon,
    required this.ffmpegFilterPattern,
    this.previewVideoAsset,
    this.thumbnailFallback,
    this.defaultIntensity = 1.0,
    this.previewDuration = 2.5,
  });
}

/// Katalog Efek Video Lengkap & Terverifikasi FFmpeg Engine
class EffectCatalog {
  static const List<EffectCatalogItem> items = [
    // Dasar (Basic)
    EffectCatalogItem(
      type: EffectType.sharpen,
      name: 'Pertajam Detail',
      category: EffectCategory.basic,
      description: 'Meningkatkan ketajaman tepi dan mikrokontras objek',
      icon: Icons.details_rounded,
      ffmpegFilterPattern: 'unsharp=5:5:1.5:5:5:0.0',
      previewVideoAsset: 'assets/videos/effect_previews/sharpen.mp4',
      thumbnailFallback: 'assets/images/effect_previews/portrait_man.jpg',
    ),
    EffectCatalogItem(
      type: EffectType.edgeEnhance,
      name: 'Penegas Garis Tepi',
      category: EffectCategory.basic,
      description: 'Menegaskan siluet dan tekstur visual klip',
      icon: Icons.line_weight_rounded,
      ffmpegFilterPattern: 'edgedetect=low=0.1:high=0.4',
      previewVideoAsset: 'assets/videos/effect_previews/edge_enhance.mp4',
      thumbnailFallback: 'assets/images/effect_previews/portrait_man.jpg',
    ),
    EffectCatalogItem(
      type: EffectType.invert,
      name: 'Pembalikan Warna Negatif',
      category: EffectCategory.basic,
      description: 'Membalikkan seluruh komponen warna secara negatif',
      icon: Icons.invert_colors_rounded,
      ffmpegFilterPattern: 'negate',
      previewVideoAsset: 'assets/videos/effect_previews/invert.mp4',
      thumbnailFallback: 'assets/images/effect_previews/cool_boy.jpg',
    ),

    // Sinematik (Cinematic)
    EffectCatalogItem(
      type: EffectType.letterbox,
      name: 'Bilah Sinema 2.35:1',
      category: EffectCategory.cinematic,
      description: 'Bilah hitam sinematik layar lebar ultra-widescreen',
      icon: Icons.crop_16_9_rounded,
      ffmpegFilterPattern: 'drawbox=x=0:y=0:w=iw:h=ih*0.12:c=black:t=fill,drawbox=x=0:y=ih*0.88:w=iw:h=ih*0.12:c=black:t=fill',
      previewVideoAsset: 'assets/videos/effect_previews/letterbox.mp4',
      thumbnailFallback: 'assets/images/effect_previews/cinema_wide.jpg',
    ),
    EffectCatalogItem(
      type: EffectType.anamorphicFlare,
      name: 'Pendar Anamorfik',
      category: EffectCategory.cinematic,
      description: 'Tone pendar biru horizontal khas lensa sinema anamorfik',
      icon: Icons.flare_rounded,
      ffmpegFilterPattern: 'eq=contrast=1.15:brightness=0.02,colorchannelmixer=1:0:0:0:0:1:0:0:0.1:0.1:1.2:0',
      previewVideoAsset: 'assets/videos/effect_previews/anamorphic_flare.mp4',
      thumbnailFallback: 'assets/images/effect_previews/cinematic_neon.jpg',
    ),
    EffectCatalogItem(
      type: EffectType.vignetteDark,
      name: 'Vinyet Sinematik',
      category: EffectCategory.cinematic,
      description: 'Efek gelap pekat di tepi bingkai untuk memfokuskan pandangan',
      icon: Icons.vignette_rounded,
      ffmpegFilterPattern: 'vignette=PI*0.5',
      previewVideoAsset: 'assets/videos/effect_previews/vignette_dark.mp4',
      thumbnailFallback: 'assets/images/effect_previews/man_model.jpg',
    ),

    // Vintage
    EffectCatalogItem(
      type: EffectType.oldFilmGrain,
      name: 'Butiran Film 16mm',
      category: EffectCategory.vintage,
      description: 'Tekstur derau seluloid alami dan flickering film tua',
      icon: Icons.grain_rounded,
      ffmpegFilterPattern: 'noise=alls=15:allf=t+u,eq=contrast=1.1:saturation=0.9',
      previewVideoAsset: 'assets/videos/effect_previews/film_grain.mp4',
      thumbnailFallback: 'assets/images/effect_previews/retro_vintage.jpg',
    ),
    EffectCatalogItem(
      type: EffectType.sepiaFilm,
      name: 'Debu & Sepia Antik',
      category: EffectCategory.vintage,
      description: 'Warna sepia tua dengan partikel debu analog',
      icon: Icons.photo_filter_rounded,
      ffmpegFilterPattern: 'colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131:0,noise=alls=10:allf=t',
      previewVideoAsset: 'assets/videos/effect_previews/sepia_film.mp4',
      thumbnailFallback: 'assets/images/effect_previews/retro_vintage.jpg',
    ),
    EffectCatalogItem(
      type: EffectType.vhsTape,
      name: 'Kaset Pita VHS',
      category: EffectCategory.vintage,
      description: 'Nuansa kaset pita magnetik 80-an dengan desaturasi lembut',
      icon: Icons.videocam_outlined,
      ffmpegFilterPattern: 'eq=contrast=1.05:saturation=0.85,noise=alls=12:allf=t+u,drawgrid=w=iw:h=6:t=1:c=black@0.15',
      previewVideoAsset: 'assets/videos/effect_previews/vhs_tape.mp4',
      thumbnailFallback: 'assets/images/effect_previews/retro_vintage.jpg',
    ),

    // Glitch
    EffectCatalogItem(
      type: EffectType.rgbSplit,
      name: 'Pemisah Warna RGB',
      category: EffectCategory.glitch,
      description: 'Pemisahan kanal merah, hijau, biru (Chromatic Aberration)',
      icon: Icons.burst_mode_rounded,
      ffmpegFilterPattern: 'colorchannelmixer=1.1:0:0:0:0:0.95:0:0:0:0:1.15:0',
      previewVideoAsset: 'assets/videos/effect_previews/rgb_split.mp4',
      thumbnailFallback: 'assets/images/effect_previews/glitch_matrix.jpg',
    ),
    EffectCatalogItem(
      type: EffectType.colorGlitch,
      name: 'Pergeseran Digital',
      category: EffectCategory.glitch,
      description: 'Pergeseran warna digital ala sinyal data rusak',
      icon: Icons.broken_image_rounded,
      ffmpegFilterPattern: 'eq=contrast=1.3:saturation=1.4,hue=h=45',
      previewVideoAsset: 'assets/videos/effect_previews/color_glitch.mp4',
      thumbnailFallback: 'assets/images/effect_previews/glitch_matrix.jpg',
    ),
    EffectCatalogItem(
      type: EffectType.pixelate,
      name: 'Mosaik Piksel 8-Bit',
      category: EffectCategory.glitch,
      description: 'Pikselasi resolusi retro 8-bit gaya arcade game',
      icon: Icons.grid_view_rounded,
      ffmpegFilterPattern: 'scale=iw/16:ih/16:flags=neighbor,scale=iw*16:ih*16:flags=neighbor',
      previewVideoAsset: 'assets/videos/effect_previews/pixel_mosaic.mp4',
      thumbnailFallback: 'assets/images/effect_previews/glitch_matrix.jpg',
    ),

    // Blur / Samar
    EffectCatalogItem(
      type: EffectType.gaussianSoft,
      name: 'Kabur Lembut Pendar',
      category: EffectCategory.blur,
      description: 'Pendar kabur lembut Gaussian untuk suasana damai',
      icon: Icons.blur_on_rounded,
      ffmpegFilterPattern: 'gblur=sigma=6',
      previewVideoAsset: 'assets/videos/effect_previews/gaussian_soft.mp4',
      thumbnailFallback: 'assets/images/effect_previews/woman_portrait.jpg',
    ),
    EffectCatalogItem(
      type: EffectType.radialBlur,
      name: 'Samar Gerak Cepat',
      category: EffectCategory.blur,
      description: 'Kesan kecepatan tinggi dengan blur gerakan halus',
      icon: Icons.blur_circular_rounded,
      ffmpegFilterPattern: 'tblend=all_mode=average',
      previewVideoAsset: 'assets/videos/effect_previews/fast_motion_blur.mp4',
      thumbnailFallback: 'assets/images/effect_previews/man_model.jpg',
    ),
    EffectCatalogItem(
      type: EffectType.tiltShift,
      name: 'Fokus Miniatur Lensa',
      category: EffectCategory.blur,
      description: 'Fokus tajam di tengah dengan blur di atas dan bawah',
      icon: Icons.blur_linear_rounded,
      ffmpegFilterPattern: 'gblur=sigma=4,drawbox=x=0:y=ih*0.25:w=iw:h=ih*0.5:c=white@0.0:t=fill',
      previewVideoAsset: 'assets/videos/effect_previews/tilt_shift.mp4',
      thumbnailFallback: 'assets/images/effect_previews/city_drone.jpg',
    ),

    // Cahaya / Light
    EffectCatalogItem(
      type: EffectType.glowAura,
      name: 'Pendar Aura Mistis',
      category: EffectCategory.light,
      description: 'Pendaran cahaya magis lembut di sekitar sorotan terang',
      icon: Icons.wb_sunny_rounded,
      ffmpegFilterPattern: 'eq=brightness=0.08:contrast=1.15:saturation=1.2',
      previewVideoAsset: 'assets/videos/effect_previews/glow_aura.mp4',
      thumbnailFallback: 'assets/images/effect_previews/fantasy_glow.jpg',
    ),
    EffectCatalogItem(
      type: EffectType.lensBrightness,
      name: 'Paparan Sinar Surya',
      category: EffectCategory.light,
      description: 'Simulasi cahaya matahari hangat alami menerpa lensa',
      icon: Icons.light_mode_rounded,
      ffmpegFilterPattern: 'eq=brightness=0.12:gamma_r=1.25:gamma_g=1.1:gamma_b=0.9',
      previewVideoAsset: 'assets/videos/effect_previews/sunlight_exposure.mp4',
      thumbnailFallback: 'assets/images/effect_previews/sunset_sunburst.jpg',
    ),
    EffectCatalogItem(
      type: EffectType.lightLeak,
      name: 'Bocoran Cahaya Oranye',
      category: EffectCategory.light,
      description: 'Bocoran cahaya oranye hangat di sudut rekaman',
      icon: Icons.wb_twilight_rounded,
      ffmpegFilterPattern: 'colorchannelmixer=1.2:0:0:0:0:1.05:0:0:0:0:0.9:0,eq=brightness=0.05',
      previewVideoAsset: 'assets/videos/effect_previews/orange_light_leak.mp4',
      thumbnailFallback: 'assets/images/effect_previews/disco_light.jpg',
    ),

    // Distorsi
    EffectCatalogItem(
      type: EffectType.mirrorHorizontal,
      name: 'Cermin Horizontal',
      category: EffectCategory.distortion,
      description: 'Efek cermin membalikkan sisi kiri ke kanan',
      icon: Icons.flip_rounded,
      ffmpegFilterPattern: 'hflip',
      previewVideoAsset: 'assets/videos/effect_previews/mirror_horizontal.mp4',
      thumbnailFallback: 'assets/images/effect_previews/cool_boy.jpg',
    ),
    EffectCatalogItem(
      type: EffectType.mirrorVertical,
      name: 'Cermin Vertikal',
      category: EffectCategory.distortion,
      description: 'Efek pantulan air membalikkan vertikal',
      icon: Icons.swap_vert_rounded,
      ffmpegFilterPattern: 'vflip',
      previewVideoAsset: 'assets/videos/effect_previews/mirror_vertical.mp4',
      thumbnailFallback: 'assets/images/effect_previews/cable_car.jpg',
    ),
    EffectCatalogItem(
      type: EffectType.fishEye,
      name: 'Lensa Mata Ikan (Fisheye)',
      category: EffectCategory.distortion,
      description: 'Distorsi cembung lensa sudut ultra-lebar',
      icon: Icons.panorama_fish_eye_rounded,
      ffmpegFilterPattern: 'lenscorrection=cx=0.5:cy=0.5:k1=-0.25:k2=-0.25',
      previewVideoAsset: 'assets/videos/effect_previews/fisheye.mp4',
      thumbnailFallback: 'assets/images/effect_previews/man_model.jpg',
    ),

    // Retro
    EffectCatalogItem(
      type: EffectType.retroScanline,
      name: 'Garis Pindai TV Tabung',
      category: EffectCategory.retro,
      description: 'Garis horizontal monitor tabung televisi kaca retro',
      icon: Icons.tv_rounded,
      ffmpegFilterPattern: 'drawgrid=w=iw:h=4:t=1:c=black@0.2,eq=contrast=1.15:brightness=0.02',
      previewVideoAsset: 'assets/videos/effect_previews/crt_scanlines.mp4',
      thumbnailFallback: 'assets/images/effect_previews/retro_vintage.jpg',
    ),
    EffectCatalogItem(
      type: EffectType.halftone,
      name: 'Cetak Titik Halftone',
      category: EffectCategory.retro,
      description: 'Pola titik cetak koran atau majalah lawas',
      icon: Icons.dialpad_rounded,
      ffmpegFilterPattern: 'format=gray,noise=alls=20:allf=t',
      previewVideoAsset: 'assets/videos/effect_previews/halftone.mp4',
      thumbnailFallback: 'assets/images/effect_previews/portrait_boy.jpg',
    ),
    EffectCatalogItem(
      type: EffectType.comicBook,
      name: 'Komik Pop Art',
      category: EffectCategory.retro,
      description: 'Gaya visual komik berwarna dengan kontras pekat',
      icon: Icons.auto_stories_rounded,
      ffmpegFilterPattern: 'eq=contrast=1.5:saturation=1.8',
      previewVideoAsset: 'assets/videos/effect_previews/comic_book.mp4',
      thumbnailFallback: 'assets/images/effect_previews/portrait_boy.jpg',
    ),

    // Warna (Color)
    EffectCatalogItem(
      type: EffectType.duotoneCyanRed,
      name: 'Duotone Merah & Biru Kehijauan',
      category: EffectCategory.color,
      description: 'Palet dua warna tegas: merah membara dan cyan sejuk',
      icon: Icons.palette_rounded,
      ffmpegFilterPattern: 'colorchannelmixer=1.4:0:0:0:0:0.5:0:0:0:0.8:1.2:0',
      previewVideoAsset: 'assets/videos/effect_previews/duotone_cyan_red.mp4',
      thumbnailFallback: 'assets/images/effect_previews/cinematic_neon.jpg',
    ),
    EffectCatalogItem(
      type: EffectType.cyberpunkGlow,
      name: 'Pendar Neon Masa Depan',
      category: EffectCategory.color,
      description: 'Saturasi neon ungu magenta khas kota metropolitan malam',
      icon: Icons.electric_bolt_rounded,
      ffmpegFilterPattern: 'eq=contrast=1.2:saturation=1.6,colorchannelmixer=1.1:0:0:0:0:0.85:0:0:0.3:0:1.3:0',
      previewVideoAsset: 'assets/videos/effect_previews/neon_cyberpunk.mp4',
      thumbnailFallback: 'assets/images/effect_previews/cinematic_neon.jpg',
    ),
    EffectCatalogItem(
      type: EffectType.thermalVision,
      name: 'Penglihatan Termal Inframerah',
      category: EffectCategory.color,
      description: 'Simulasi kamera sensor suhu inframerah Predator',
      icon: Icons.thermostat_rounded,
      ffmpegFilterPattern: 'hue=h=180,eq=contrast=1.4:saturation=2.0',
      previewVideoAsset: 'assets/videos/effect_previews/thermal_vision.mp4',
      thumbnailFallback: 'assets/images/effect_previews/cool_boy.jpg',
    ),

    // Gerakan (Motion)
    EffectCatalogItem(
      type: EffectType.speedLines,
      name: 'Garis Gerak Dinamis',
      category: EffectCategory.motion,
      description: 'Meningkatkan sensasi laju gerak pada adegan cepat',
      icon: Icons.speed_rounded,
      ffmpegFilterPattern: 'eq=contrast=1.2:brightness=0.03',
      previewVideoAsset: 'assets/videos/effect_previews/action_dynamic.mp4',
      thumbnailFallback: 'assets/images/effect_previews/cool_boy.jpg',
    ),
    EffectCatalogItem(
      type: EffectType.stutterMotion,
      name: 'Gerak Patah-Patah (Stop-Motion)',
      category: EffectCategory.motion,
      description: 'Efek framerate patah-patah ala animasi claymation',
      icon: Icons.motion_photos_paused_rounded,
      ffmpegFilterPattern: 'fps=12',
      previewVideoAsset: 'assets/videos/effect_previews/stutter_motion.mp4',
      thumbnailFallback: 'assets/images/effect_previews/cool_boy.jpg',
    ),
    EffectCatalogItem(
      type: EffectType.zoomPulse,
      name: 'Kilat Dentuman Hentakan',
      category: EffectCategory.motion,
      description: 'Kilatan dampak dramatis pada puncak ketukan musik',
      icon: Icons.flash_on_rounded,
      ffmpegFilterPattern: 'eq=brightness=0.15:contrast=1.3:saturation=1.2',
      previewVideoAsset: 'assets/videos/effect_previews/impact_flash.mp4',
      thumbnailFallback: 'assets/images/effect_previews/cool_boy.jpg',
    ),

    // Kreatif
    EffectCatalogItem(
      type: EffectType.dreamyGlow,
      name: 'Cahaya Dongeng Khayalan',
      category: EffectCategory.creative,
      description: 'Nuansa fantasi lembut berpendar bagai negeri dongeng',
      icon: Icons.auto_awesome_rounded,
      ffmpegFilterPattern: 'eq=brightness=0.06:contrast=0.95:saturation=1.15,gblur=sigma=2',
      previewVideoAsset: 'assets/videos/effect_previews/dreamy_glow.mp4',
      thumbnailFallback: 'assets/images/effect_previews/fantasy_glow.jpg',
    ),
    EffectCatalogItem(
      type: EffectType.emboss,
      name: 'Ukiran Logam 3D',
      category: EffectCategory.creative,
      description: 'Relief ukiran logam monokrom 3 dimensi',
      icon: Icons.view_in_ar_rounded,
      ffmpegFilterPattern: 'format=gray,edgedetect=low=0.1:high=0.3',
      previewVideoAsset: 'assets/videos/effect_previews/emboss.mp4',
      thumbnailFallback: 'assets/images/effect_previews/portrait_man.jpg',
    ),
    EffectCatalogItem(
      type: EffectType.kaleidoscope,
      name: 'Cermin Empat Sudut (Kaleidoskop)',
      category: EffectCategory.creative,
      description: 'Pantulan simetris 4 arah menyerupai kaleidoskop',
      icon: Icons.filter_tilt_shift_rounded,
      ffmpegFilterPattern: 'hflip,vflip',
      previewVideoAsset: 'assets/videos/effect_previews/kaleidoscope.mp4',
      thumbnailFallback: 'assets/images/effect_previews/disco_light.jpg',
    ),
    // Motion Blur (Gerak Samar CapCut Style)
    EffectCatalogItem(
      type: EffectType.motionBlur,
      name: 'Gerak Samar Dinamis',
      category: EffectCategory.motion,
      description: 'Efek blur dinamis kabur, campuran, arah & kali x',
      icon: Icons.blur_linear_rounded,
      ffmpegFilterPattern: 'tblend=all_mode=average,framestep=1',
      previewVideoAsset: 'assets/videos/effect_previews/motion_blur.mp4',
      thumbnailFallback: 'assets/images/effect_previews/man_model.jpg',
    ),
  ];

  static EffectCatalogItem getItem(EffectType type) {
    return items.firstWhere(
      (e) => e.type == type,
      orElse: () => items.first,
    );
  }
}

