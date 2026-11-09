import 'dart:math' as math;
import 'shake_semantic_engine.dart';
import 'glitch_semantic_engine.dart';

/// Tipe penerapan animasi ala CapCut
enum AnimationApplicationType {
  inAnimation, // Animasi masuk saat klip mulai
  outAnimation, // Animasi keluar saat klip berakhir
  comboAnimation, // Animasi selama klip berlangsung (loop / continuous)
}

/// Kategori Animasi Profesional
enum AnimationCategory {
  trending,
  basic,
  light,
  glitch,
  mask,
  threeD,
  shake,
  motion,
  blur,
  particle,
  retro,
  cinematic,
}

/// Kurva Easing Animasi
enum AnimationEasingCurve {
  linear,
  easeIn,
  easeOut,
  easeInOut,
  bounce,
  elastic,
}

/// Model preset animasi individual
class AnimationPresetModel {
  final String id;
  final String name;
  final AnimationCategory category;
  final AnimationApplicationType type;
  final String description;
  final bool isOnline;
  final String? downloadUrl;
  final int fileSize; // in bytes
  final String license; // MIT, Apache-2.0, CC-BY-4.0, Public Domain
  final String author;
  final bool isDownloaded;

  const AnimationPresetModel({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    this.description = '',
    this.isOnline = false,
    this.downloadUrl,
    this.fileSize = 0,
    this.license = 'MIT / Open-Source',
    this.author = 'QuickClip Community',
    this.isDownloaded = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category.name,
    'type': type.name,
    'description': description,
    'isOnline': isOnline,
    'downloadUrl': downloadUrl,
    'fileSize': fileSize,
    'license': license,
    'author': author,
    'isDownloaded': isDownloaded,
  };

  factory AnimationPresetModel.fromJson(Map<String, dynamic> json) {
    return AnimationPresetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: AnimationCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => AnimationCategory.basic,
      ),
      type: AnimationApplicationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => AnimationApplicationType.inAnimation,
      ),
      description: json['description'] as String? ?? '',
      isOnline: json['isOnline'] as bool? ?? false,
      downloadUrl: json['downloadUrl'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      license: json['license'] as String? ?? 'MIT / Open-Source',
      author: json['author'] as String? ?? 'QuickClip Community',
      isDownloaded: json['isDownloaded'] as bool? ?? true,
    );
  }

  AnimationPresetModel copyWith({
    String? id,
    String? name,
    AnimationCategory? category,
    AnimationApplicationType? type,
    String? description,
    bool? isOnline,
    String? downloadUrl,
    int? fileSize,
    String? license,
    String? author,
    bool? isDownloaded,
  }) {
    return AnimationPresetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      type: type ?? this.type,
      description: description ?? this.description,
      isOnline: isOnline ?? this.isOnline,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      fileSize: fileSize ?? this.fileSize,
      license: license ?? this.license,
      author: author ?? this.author,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }
}

/// Tipe bentuk clipping / masking untuk efek transisi dan animasi geometris
enum AnimationClipShape {
  none,
  circleIris,
  diamondIris,
  pentagonIris,
  starIris,
  wipeLeft,
  wipeRight,
  wipeUp,
  wipeDown,
  wipeDiagonalTL,
  wipeDiagonalBR,
  blinds,
  blindsVertical,
  splitHorizontal,
  splitVertical,
  curtain,
  curtainClose,
  checkerboard,
  clockWipe,
  counterClockWipe,
  cornerPin,
}

/// Overlay visual yang digambar di atas klip untuk memperjelas karakter efek.
///
/// Overlay ini hanya dipakai preview; ekspor video tetap memakai filter FFmpeg.
enum PreviewOverlay {
  none,
  letterbox,
  filmFrame,
  countdown,
  focusBrackets,
  radar,
  sunburst,
  bokeh,
  synthGrid,
  scanlines,
  grain,
  vignette,
  ornateFrame,
  splitFlap,
  typewriter,
  projectorBeam,
  reticle,
  halftone,
  vuMeter,
  reel,
  lightLeak,
  dust,
  neon,
  smoke,
  ripples,
  wireframe,
  spotlight,
  curtain,
  credits,
  cracks,
  prism,
  pageCurl,
  tunnelRings,
  testCard,
  newspaper,
  discoBall,
  aurora,
  hologram,
  flames,
  water,
  mirror,
}

/// Hasil transformasi animasi pada frame waktu tertentu (untuk preview & render)
class AnimationTransformResult {
  final double scale;
  final double scaleX; // Horizontal scale (e.g. stretch, flip)
  final double scaleY; // Vertical scale (e.g. squash, flip)
  final double positionX; // Normalized offset -1.0 to 1.0
  final double positionY; // Normalized offset -1.0 to 1.0
  final double rotationDegrees; // 2D Rotation Z-axis
  final double rotateXDegrees; // 3D Pitch rotation
  final double rotateYDegrees; // 3D Yaw rotation
  final double perspective; // 3D Perspective depth (default 0.0015)
  final double opacity;
  final double blurRadius; // For blur effects
  final double flashOpacity; // For flash & glow overlays
  final double colorOverlayOpacity; // For Dip to Black / Dip to White overlay
  final int colorOverlayValue; // 0xFF000000 (black) or 0xFFFFFFFF (white)
  final double chromaticAberration; // RGB split offset
  final double scanlineIntensity;
  final AnimationClipShape clipShape;
  final double clipProgress; // 0.0 (tertutup/awal) sampai 1.0 (terbuka penuh)

  // --- Khusus preview: overlay dan color grade yang mengikuti nama efek ---
  final PreviewOverlay previewOverlay;
  final double previewOverlayProgress;
  final int tintColor; // ARGB, dipakai sebagai warna modulate
  final double tintOpacity; // 0.0 = tanpa tint
  final bool grayscale;

  const AnimationTransformResult({
    this.scale = 1.0,
    this.scaleX = 1.0,
    this.scaleY = 1.0,
    this.positionX = 0.0,
    this.positionY = 0.0,
    this.rotationDegrees = 0.0,
    this.rotateXDegrees = 0.0,
    this.rotateYDegrees = 0.0,
    this.perspective = 0.0015,
    this.opacity = 1.0,
    this.blurRadius = 0.0,
    this.flashOpacity = 0.0,
    this.colorOverlayOpacity = 0.0,
    this.colorOverlayValue = 0xFF000000,
    this.chromaticAberration = 0.0,
    this.scanlineIntensity = 0.0,
    this.clipShape = AnimationClipShape.none,
    this.clipProgress = 1.0,
    this.previewOverlay = PreviewOverlay.none,
    this.previewOverlayProgress = 1.0,
    this.tintColor = 0xFFFFFFFF,
    this.tintOpacity = 0.0,
    this.grayscale = false,
  });
}

/// Konfigurasi animasi yang diterapkan pada sebuah klip video
class ClipAnimationModel {
  final String presetId;
  final AnimationApplicationType type;
  final double duration; // Durasi animasi (detik, default 1.0)
  final double intensity; // 0.0 - 2.0 (default 1.0)
  final double speed; // 0.2x - 3.0x (default 1.0)
  final double delay; // Jeda sebelum animasi mulai (detik, default 0.0)
  final bool repeat; // Ulangi animasi terus-menerus
  final bool reverse; // Putar animasi terbalik
  final AnimationEasingCurve easing;

  const ClipAnimationModel({
    this.presetId = '',
    this.type = AnimationApplicationType.inAnimation,
    this.duration = 1.0,
    this.intensity = 1.0,
    this.speed = 1.0,
    this.delay = 0.0,
    this.repeat = false,
    this.reverse = false,
    this.easing = AnimationEasingCurve.easeInOut,
  });

  bool get hasAnimation => presetId.isNotEmpty;

  ClipAnimationModel copyWith({
    String? presetId,
    AnimationApplicationType? type,
    double? duration,
    double? intensity,
    double? speed,
    double? delay,
    bool? repeat,
    bool? reverse,
    AnimationEasingCurve? easing,
  }) {
    return ClipAnimationModel(
      presetId: presetId ?? this.presetId,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      intensity: intensity ?? this.intensity,
      speed: speed ?? this.speed,
      delay: delay ?? this.delay,
      repeat: repeat ?? this.repeat,
      reverse: reverse ?? this.reverse,
      easing: easing ?? this.easing,
    );
  }

  Map<String, dynamic> toJson() => {
    'presetId': presetId,
    'type': type.name,
    'duration': duration,
    'intensity': intensity,
    'speed': speed,
    'delay': delay,
    'repeat': repeat,
    'reverse': reverse,
    'easing': easing.name,
  };

  factory ClipAnimationModel.fromJson(Map<String, dynamic> json) {
    return ClipAnimationModel(
      presetId: json['presetId'] as String? ?? '',
      type: AnimationApplicationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => AnimationApplicationType.inAnimation,
      ),
      duration: (json['duration'] as num?)?.toDouble() ?? 1.0,
      intensity: (json['intensity'] as num?)?.toDouble() ?? 1.0,
      speed: (json['speed'] as num?)?.toDouble() ?? 1.0,
      delay: (json['delay'] as num?)?.toDouble() ?? 0.0,
      repeat: json['repeat'] as bool? ?? false,
      reverse: json['reverse'] as bool? ?? false,
      easing: AnimationEasingCurve.values.firstWhere(
        (e) => e.name == json['easing'],
        orElse: () => AnimationEasingCurve.easeInOut,
      ),
    );
  }

  /// Evaluasi nilai animasi pada waktu tertentu (timeInClip) dalam klip
  AnimationTransformResult evaluate({
    required double timeInClip,
    required double totalClipDuration,
  }) {
    if (!hasAnimation) {
      return const AnimationTransformResult();
    }

    double progress = 0.0;
    final effectiveDuration = duration.clamp(0.1, totalClipDuration);

    switch (type) {
      case AnimationApplicationType.inAnimation:
        if (timeInClip < delay) {
          progress = 0.0;
        } else if (timeInClip >= delay + effectiveDuration) {
          progress = 1.0;
        } else {
          progress = (timeInClip - delay) / effectiveDuration;
        }
        break;

      case AnimationApplicationType.outAnimation:
        final outStart = totalClipDuration - effectiveDuration;
        if (timeInClip < outStart) {
          progress = 0.0;
        } else {
          progress = ((timeInClip - outStart) / effectiveDuration).clamp(
            0.0,
            1.0,
          );
        }
        break;

      case AnimationApplicationType.comboAnimation:
        if (effectiveDuration <= 0) {
          progress = 0.0;
        } else {
          final cycleTime = (timeInClip * speed) % effectiveDuration;
          progress = cycleTime / effectiveDuration;
        }
        break;
    }

    if (reverse) {
      progress = 1.0 - progress;
    }

    // Terapkan kurva Easing
    final eased = _applyEasing(progress, easing);

    // Hitung output berdasarkan presetId
    return _computePresetTransform(presetId, eased, intensity, type);
  }

  static double _applyEasing(double t, AnimationEasingCurve easing) {
    switch (easing) {
      case AnimationEasingCurve.linear:
        return t;
      case AnimationEasingCurve.easeIn:
        return t * t;
      case AnimationEasingCurve.easeOut:
        return t * (2 - t);
      case AnimationEasingCurve.easeInOut:
        return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
      case AnimationEasingCurve.bounce:
        if (t < (1 / 2.75)) {
          return 7.5625 * t * t;
        } else if (t < (2 / 2.75)) {
          final t2 = t - (1.5 / 2.75);
          return 7.5625 * t2 * t2 + 0.75;
        } else if (t < (2.5 / 2.75)) {
          final t2 = t - (2.25 / 2.75);
          return 7.5625 * t2 * t2 + 0.9375;
        } else {
          final t2 = t - (2.625 / 2.75);
          return 7.5625 * t2 * t2 + 0.984375;
        }
      case AnimationEasingCurve.elastic:
        if (t == 0 || t == 1) return t;
        return math.sin(t * math.pi * 4.5) * math.pow(2, 10 * (t - 1)) + 1;
    }
  }

  static AnimationTransformResult _computePresetTransform(
    String preset,
    double t,
    double intensity,
    AnimationApplicationType type,
  ) {
    switch (preset) {
      // --- TRENDING ---
      case 'zoom_burst':
        // Zoom burst mendadak dengan efek hentakan boost dinamis
        final boostCurve = math.pow(1.0 - t, 2.2).toDouble();
        final scale = 1.0 + (boostCurve * 0.9 * intensity);
        final flash = math.pow(1.0 - t, 3.0).toDouble() * 0.85 * intensity;
        return AnimationTransformResult(scale: scale, flashOpacity: flash);

      // --- BATCH 1: TRENDING 1 - 10 (REAL IMPLEMENTATION) ---
      case 'trending_fade_in_cinematic':
        // 2. Fade from black dengan smooth cinematic easing & gradual reveal
        final isOut = type == AnimationApplicationType.outAnimation;
        final fadeProg = isOut ? (1.0 - t) : t;
        final cineEase = math.sin(fadeProg * math.pi * 0.5);
        final cineScale = 1.0 + (1.0 - cineEase) * 0.04;
        return AnimationTransformResult(
          opacity: cineEase.clamp(0.0, 1.0),
          scale: cineScale,
        );

      case 'trending_spin_drop':
        // 3. Putaran rotasi 360 derajat + drop vertikal + recovery bounce
        final isOut = type == AnimationApplicationType.outAnimation;
        final prog = isOut ? (1.0 - t) : t;
        final spinAngle = (1.0 - prog) * 360.0 * intensity;
        final dropY = (1.0 - prog) * -0.7 * intensity;
        final bounceScale =
            0.5 + (prog * 0.5) + (math.sin(prog * math.pi) * 0.08 * intensity);
        return AnimationTransformResult(
          rotationDegrees: spinAngle,
          positionY: dropY,
          scale: bounceScale.clamp(0.2, 1.3),
          opacity: (prog * 2.0).clamp(0.0, 1.0),
        );

      case 'trending_wipe_sweep_right':
        // 4. Wipe / mask bergerak kiri -> kanan bertahap
        final isOut = type == AnimationApplicationType.outAnimation;
        final sweepProg = isOut ? (1.0 - t) : t;
        return AnimationTransformResult(
          clipShape: AnimationClipShape.wipeRight,
          clipProgress: sweepProg.clamp(0.0, 1.0),
          scale: 1.0,
        );

      case 'trending_circle_iris_open':
        // 5. Circular mask membesar reveal dari tengah
        final isOut = type == AnimationApplicationType.outAnimation;
        final irisProg = isOut ? (1.0 - t) : t;
        return AnimationTransformResult(
          clipShape: AnimationClipShape.circleIris,
          clipProgress: irisProg.clamp(0.0, 1.0),
          scale: 1.0,
        );

      case 'trending_diamond_iris_pop':
        // 6. Diamond mask membesar dengan pop-style elastic easing
        final isOut = type == AnimationApplicationType.outAnimation;
        final baseProg = isOut ? (1.0 - t) : t;
        final popProg = math.sin(baseProg * math.pi * 0.5) * 1.04;
        return AnimationTransformResult(
          clipShape: AnimationClipShape.diamondIris,
          clipProgress: popProg.clamp(0.0, 1.0),
          scale: 1.0 + (math.sin(baseProg * math.pi) * 0.05 * intensity),
        );

      case 'trending_checkerboard_reveal':
        // 7. Checkerboard pattern tile-based reveal
        final isOut = type == AnimationApplicationType.outAnimation;
        final checkProg = isOut ? (1.0 - t) : t;
        return AnimationTransformResult(
          clipShape: AnimationClipShape.checkerboard,
          clipProgress: checkProg.clamp(0.0, 1.0),
          scale: 1.0,
        );

      case 'trending_split_vertical_in':
        // 8. Layar terbagi secara vertikal dua sisi bergerak masuk
        final isOut = type == AnimationApplicationType.outAnimation;
        final splitProg = isOut ? (1.0 - t) : t;
        return AnimationTransformResult(
          clipShape: AnimationClipShape.splitVertical,
          clipProgress: splitProg.clamp(0.0, 1.0),
          scale: 1.0,
        );

      case 'trending_slide_left_fast':
        // 9. Slide cepat ke kiri dengan velocity tinggi dan snap tajam
        final isOut = type == AnimationApplicationType.outAnimation;
        final slideT = isOut ? t : (1.0 - t);
        final snapX =
            math.pow(slideT, 2.8).toDouble() * (isOut ? -1.0 : 1.0) * intensity;
        return AnimationTransformResult(
          positionX: snapX,
          opacity: isOut ? (1.0 - t).clamp(0.0, 1.0) : t.clamp(0.0, 1.0),
          scale: 1.0,
        );

      case 'trending_curtain_open_smooth':
        // 10. Dua sisi seperti tirai panggung membuka dari tengah
        final isOut = type == AnimationApplicationType.outAnimation;
        final curtainProg = isOut ? (1.0 - t) : t;
        final smoothProg = 0.5 - 0.5 * math.cos(curtainProg * math.pi);
        return AnimationTransformResult(
          clipShape: AnimationClipShape.curtain,
          clipProgress: smoothProg.clamp(0.0, 1.0),
          scale: 1.0,
        );

      // --- BATCH 2: TRENDING 11 - 25 (REAL IMPLEMENTATION) ---
      case 'trending_elastic_scale_pop':
        // 11. Scale up dengan overshoot elastis lalu return stabil
        final isOut = type == AnimationApplicationType.outAnimation;
        final prog = isOut ? (1.0 - t) : t;
        final elasticS =
            1.0 +
            math.sin(prog * math.pi * 3.5) *
                math.exp(-prog * 3.0) *
                0.45 *
                intensity;
        return AnimationTransformResult(
          scale: elasticS.clamp(0.4, 2.0),
          opacity: (prog * 2.5).clamp(0.0, 1.0),
        );

      case 'trending_box_zoom_impact':
      case 'box_zoom_impact':
        // 12. Zoom berbasis impact hentakan cepat dengan sentakan recoil
        final impactTime = math.exp(-t * 5.0);
        final impactScale = 1.0 + (impactTime * 0.55 * intensity);
        final recoilY =
            math.sin(t * math.pi * 8.0) * impactTime * 0.05 * intensity;
        return AnimationTransformResult(
          scale: impactScale,
          positionY: recoilY,
          flashOpacity: (impactTime * 0.4 * intensity).clamp(0.0, 1.0),
        );

      case 'trending_venetian_blinds_in':
        // 13. Strip horizontal/vertikal membuka bertahap seperti blinds
        final isOut = type == AnimationApplicationType.outAnimation;
        final blindProg = isOut ? (1.0 - t) : t;
        return AnimationTransformResult(
          clipShape: AnimationClipShape.blinds,
          clipProgress: blindProg.clamp(0.0, 1.0),
          scale: 1.0,
        );

      case 'trending_bass_boom_shake':
        // 14. Low-frequency heavy boom shake (frekuensi rendah, denyut bass berat)
        final boomPulse = math.sin(t * math.pi * 6.0);
        final decay = math.exp(-t * 2.5);
        final scaleBoom = 1.0 + (boomPulse.abs() * 0.18 * decay * intensity);
        final posX = math.sin(t * math.pi * 8.0) * 0.04 * decay * intensity;
        final posY = math.cos(t * math.pi * 6.0) * 0.05 * decay * intensity;
        return AnimationTransformResult(
          scale: scaleBoom,
          positionX: posX,
          positionY: posY,
        );

      case 'trending_camera_shake_heavy':
        // 15. Heavy camera shake multi-axis kuat dengan rotasi acak
        final decayH = math.exp(-t * 1.8);
        final sx = math.sin(t * math.pi * 18.0) * 0.08 * decayH * intensity;
        final sy = math.cos(t * math.pi * 14.0) * 0.09 * decayH * intensity;
        final rotShake =
            math.sin(t * math.pi * 12.0) * 3.5 * decayH * intensity;
        return AnimationTransformResult(
          positionX: sx,
          positionY: sy,
          rotationDegrees: rotShake,
          scale: 1.0 + (decayH * 0.05 * intensity),
        );

      case 'trending_micro_jitter_fast':
        // 16. Micro jitter frekuensi tinggi dengan amplitudo mikro sangat kecil
        final jx = math.sin(t * math.pi * 32.0) * 0.015 * intensity;
        final jy = math.cos(t * math.pi * 28.0) * 0.015 * intensity;
        return AnimationTransformResult(positionX: jx, positionY: jy);

      case 'trending_explosion_shockwave':
        // 17. Shockwave ledakan cepat: flash instan, ekspansi distorsi radial, dan recovery
        final shockDecay = math.exp(-t * 4.0);
        final shockScale = 1.0 + (shockDecay * 0.6 * intensity);
        final shockFlash =
            math.pow((1.0 - t).clamp(0.0, 1.0), 3.5).toDouble() *
            0.95 *
            intensity;
        final shockJitter =
            math.sin(t * math.pi * 22.0) * 0.04 * shockDecay * intensity;
        return AnimationTransformResult(
          scale: shockScale,
          flashOpacity: shockFlash.clamp(0.0, 1.0),
          positionX: shockJitter,
          chromaticAberration: (shockDecay * 0.06 * intensity).clamp(0.0, 0.1),
        );

      case 'trending_punch_impact_recoil':
        // 18. Hentakan tinju seketika (forward punch snap lalu recoil ke belakang)
        final punchT = t < 0.2 ? (t / 0.2) : (1.0 - (t - 0.2) / 0.8);
        final punchScale = 1.0 + (punchT * 0.3 * intensity);
        final punchRecoil = t < 0.2
            ? (-punchT * 0.08 * intensity)
            : ((t - 0.2) * 0.04 * intensity * math.exp(-t * 3.0));
        return AnimationTransformResult(
          scale: punchScale,
          positionY: punchRecoil,
          flashOpacity: t < 0.15 ? (1.0 - t / 0.15) * 0.5 * intensity : 0.0,
        );

      case 'trending_gunfire_kickback':
        // 19. Sentakan tembakan super agresif & singkat dengan muzzle flash tajam
        final kickProg = t < 0.12 ? (t / 0.12) : math.exp(-(t - 0.12) * 8.0);
        final kickY = -kickProg * 0.07 * intensity;
        final kickRot =
            (math.sin(t * math.pi * 10.0) * 1.5 * kickProg) * intensity;
        final muzzleFlash = t < 0.1 ? (1.0 - t / 0.1) * 0.9 * intensity : 0.0;
        return AnimationTransformResult(
          positionY: kickY,
          rotationDegrees: kickRot,
          flashOpacity: muzzleFlash,
          scale: 1.0 + (kickProg * 0.08 * intensity),
        );

      case 'trending_earthquake_rumble':
        // 20. Gempa bumi gemuruh ireguler, gelombang horizontal + vertikal frekuensi rendah-menengah
        final eqX =
            (math.sin(t * math.pi * 14.0) +
                math.sin(t * math.pi * 23.0) * 0.5) *
            0.045 *
            intensity;
        final eqY =
            (math.cos(t * math.pi * 11.0) +
                math.cos(t * math.pi * 19.0) * 0.5) *
            0.055 *
            intensity;
        return AnimationTransformResult(
          positionX: eqX,
          positionY: eqY,
          scale:
              1.03, // Sedikit zoom agar tepi kanvas tidak terpotong saat berguncang
        );

      case 'trending_stumble_jolt':
        // 21. Entakan tersandung asimetris mendadak lalu kembali seimbang
        final stumbleT = math.sin(t * math.pi * 2.0) * math.exp(-t * 2.2);
        final stumX = stumbleT * 0.12 * intensity;
        final stumY = (stumbleT.abs() * 0.08 * intensity);
        final stumRot = stumbleT * 4.5 * intensity;
        return AnimationTransformResult(
          positionX: stumX,
          positionY: stumY,
          rotationDegrees: stumRot,
        );

      case 'trending_helicopter_turbulence':
        // 22. Turbulensi getaran helikopter kontinu multi-sumbu dengan rotasi halus
        final rotorFast = math.sin(t * math.pi * 26.0) * 0.015 * intensity;
        final turbSlowX = math.sin(t * math.pi * 3.5) * 0.04 * intensity;
        final turbSlowY = math.cos(t * math.pi * 4.0) * 0.035 * intensity;
        final turbRoll = math.sin(t * math.pi * 3.0) * 2.0 * intensity;
        return AnimationTransformResult(
          positionX: turbSlowX + rotorFast,
          positionY: turbSlowY + rotorFast,
          rotationDegrees: turbRoll,
        );

      case 'trending_subwoofer_pulse':
        // 23. Denyut ritmis subwoofer low-frequency memompa skala frame
        final subBeat = (math.sin(t * math.pi * 4.0).abs());
        final subPump = math.pow(subBeat, 2.5).toDouble() * 0.22 * intensity;
        return AnimationTransformResult(
          scale: 1.0 + subPump,
          positionY: subBeat * -0.02 * intensity,
        );

      case 'trending_speed_bump_hop':
        // 24. Lompatan polisi tidur: entakan vertikal ke atas seketika lalu mereda
        final hopT = math.sin(t * math.pi * 2.5) * math.exp(-t * 3.0);
        final hopY = -hopT * 0.16 * intensity;
        final hopScale = 1.0 + (math.max(0.0, -hopY) * 0.4);
        return AnimationTransformResult(positionY: hopY, scale: hopScale);

      case 'trending_aftershock_wave':
        // 25. Gelombang susulan: hentakan utama di awal disusul riak kedua yang meluruh
        final mainShock =
            math.sin(t * math.pi * 16.0) *
            math.exp(-t * 3.5) *
            0.07 *
            intensity;
        final secondaryRipple = (t > 0.4)
            ? math.sin((t - 0.4) * math.pi * 12.0) *
                  math.exp(-(t - 0.4) * 4.0) *
                  0.04 *
                  intensity
            : 0.0;
        return AnimationTransformResult(
          positionX: mainShock + secondaryRipple,
          positionY: (mainShock * 0.7) - (secondaryRipple * 0.5),
          scale: 1.0 + (mainShock.abs() * 0.3),
        );

      // --- BATCH 3: TRENDING 26 - 40 (REAL IMPLEMENTATION: LIGHT & GLITCH) ---
      case 'trending_white_flash_bang':
      case 'white_flash_bang':
        // 26. White flash bang: kilatan putih membutakan seketika dengan decay cepat
        final flashBang =
            math.pow((1.0 - t).clamp(0.0, 1.0), 3.0).toDouble() *
            1.0 *
            intensity;
        final flashScale = 1.0 + (flashBang * 0.12);
        return AnimationTransformResult(
          flashOpacity: flashBang.clamp(0.0, 1.0),
          scale: flashScale,
        );

      case 'trending_lens_flare_streak':
        // 27. Sunburst / Lens Flare Streak: pergerakan suar radial melintasi sudut kamera
        final flareMove = (math.sin(t * math.pi * 2.0) * 0.12 * intensity);
        final flareIntensity = (math.sin(t * math.pi).abs() * 0.75 * intensity);
        return AnimationTransformResult(
          positionX: flareMove,
          flashOpacity: flareIntensity.clamp(0.0, 0.85),
          scale: 1.0 + (flareIntensity * 0.05),
        );

      case 'trending_anamorphic_blue_streak':
      case 'anamorphic_blue':
      case 'anamorphic_flare_streak':
        // 28. Horizontal blue anamorphic streak berdenyut halus
        final bluePulse =
            (math.sin(t * math.pi * 2.0).abs() * 0.6 + 0.2) * intensity;
        final blueAberration =
            (0.05 + math.sin(t * math.pi * 2.0).abs() * 0.04) * intensity;
        return AnimationTransformResult(
          chromaticAberration: blueAberration.clamp(0.0, 0.12),
          flashOpacity: (bluePulse * 0.4).clamp(0.0, 0.6),
          scaleX: 1.0 + (bluePulse * 0.04), // Peregangan optik horizontal
        );

      case 'trending_light_leak_golden':
        // 29. Bocoran cahaya keemasan vintage hangat mengalun lembut
        final goldenWave =
            (math.sin(t * math.pi * 1.5).abs() * 0.7 * intensity);
        final warmDrift = math.sin(t * math.pi) * 0.03 * intensity;
        return AnimationTransformResult(
          flashOpacity: goldenWave.clamp(0.0, 0.75),
          positionX: warmDrift,
          scale: 1.0 + (goldenWave * 0.04),
        );

      case 'trending_paparazzi_strobe':
        // 30. Kilatan blitz kamera paparazzi cepat & acak
        final strobeSeed = ((t * 24.0).floor() % 5);
        final strobeOn = (strobeSeed == 0 || strobeSeed == 2);
        final strobeFlash = (strobeOn ? 0.95 : 0.0) * intensity;
        final strobeScale = 1.0 + (strobeOn ? 0.04 * intensity : 0.0);
        return AnimationTransformResult(
          flashOpacity: strobeFlash,
          scale: strobeScale,
        );

      case 'trending_laser_beam_sweep':
      case 'laser_beam_sweep':
        // 31. Sapuan berkas sinar laser horizontal melintasi layar
        final beamX = (t - 0.5) * 1.2 * intensity;
        final beamFlash =
            math.exp(-math.pow((t - 0.5) * 6.0, 2)) * 0.8 * intensity;
        return AnimationTransformResult(
          positionX: beamX * 0.15,
          flashOpacity: beamFlash.clamp(0.0, 0.85),
          chromaticAberration: (beamFlash * 0.05).clamp(0.0, 0.08),
        );

      case 'trending_prism_rainbow_flare':
      case 'prism_rainbow':
        // 32. Dispersi spektrum prisma pelangi dengan pemisahan warna optik kuat
        final prismWave = math.sin(t * math.pi * 2.0);
        final prismAberration = (0.04 + prismWave.abs() * 0.06) * intensity;
        return AnimationTransformResult(
          chromaticAberration: prismAberration.clamp(0.0, 0.12),
          rotationDegrees: prismWave * 2.0 * intensity,
          flashOpacity: (prismWave.abs() * 0.4 * intensity).clamp(0.0, 0.6),
        );

      case 'trending_aurora_borealis_glow':
        // 33. Pendaran aura kutub yang mengalun lembut bergelombang tenang
        final auroraWave = math.sin(t * math.pi * 1.5) * 0.04 * intensity;
        final auroraGlow =
            (math.cos(t * math.pi * 2.0) * 0.35 + 0.45) * intensity;
        return AnimationTransformResult(
          positionY: auroraWave,
          flashOpacity: auroraGlow.clamp(0.0, 0.7),
          scale: 1.0 + (auroraGlow * 0.03),
        );

      case 'trending_glow_pulse_rhythm':
        // 34. Denyut glow ritmis mengikuti tempo musik
        final rhythmPulse =
            math.pow((math.sin(t * math.pi * 3.0).abs()), 2.0).toDouble() *
            0.75 *
            intensity;
        return AnimationTransformResult(
          flashOpacity: rhythmPulse.clamp(0.0, 0.85),
          scale: 1.0 + (rhythmPulse * 0.08),
        );

      case 'trending_lightning_strike_flash':
        // 35. Sambaran petir ganda: kilatan pertama tajam, redup mikro, kilatan kedua, lalu lenyap
        double strikeFlash = 0.0;
        if (t < 0.08) {
          strikeFlash = 1.0;
        } else if (t < 0.14) {
          strikeFlash = 0.2;
        } else if (t < 0.22) {
          strikeFlash = 0.85;
        } else {
          strikeFlash = math.exp(-(t - 0.22) * 8.0) * 0.3;
        }
        return AnimationTransformResult(
          flashOpacity: (strikeFlash * intensity).clamp(0.0, 1.0),
          chromaticAberration: t < 0.25 ? 0.05 * intensity : 0.0,
          scale: 1.0 + (strikeFlash * 0.05 * intensity),
        );

      case 'trending_supernova_burst':
      case 'supernova_pulse':
        // 36. Ledakan supernova kosmik: ekspansi skala masif dari titik pusat diiringi pendaran
        final novaT = math.pow(t, 2.0).toDouble();
        final novaScale = 1.0 + (novaT * 0.55 * intensity);
        final novaFlash = (math.sin(t * math.pi) * 0.9 * intensity).clamp(
          0.0,
          1.0,
        );
        return AnimationTransformResult(
          scale: novaScale,
          flashOpacity: novaFlash,
          chromaticAberration: (novaT * 0.06 * intensity).clamp(0.0, 0.08),
        );

      case 'trending_disco_light_dots':
        // 37. Efek kilatan pantulan bola disko retro berfrekuensi cepat
        final discoPhase = ((t * 16.0).floor() % 3);
        final discoFlash = (discoPhase == 1 ? 0.7 : 0.15) * intensity;
        final discoRot = math.sin(t * math.pi * 4.0) * 1.5 * intensity;
        return AnimationTransformResult(
          flashOpacity: discoFlash.clamp(0.0, 0.8),
          rotationDegrees: discoRot,
        );

      case 'trending_rgb_split_chromatic':
        // 38. Glitch RGB split murni dengan dispersi chromatic aberration ekstrem
        final rgbCycle = ((t * 12.0).floor() % 3 == 0);
        final splitAmount = (rgbCycle ? 0.08 : 0.02) * intensity;
        final rgbJitterX = rgbCycle
            ? math.sin(t * math.pi * 20.0) * 0.04 * intensity
            : 0.0;
        return AnimationTransformResult(
          chromaticAberration: splitAmount.clamp(0.0, 0.15),
          positionX: rgbJitterX,
          scanlineIntensity: 0.3 * intensity,
        );

      case 'trending_datamosh_compression':
        // 39. Datamosh smear: frame membeku parsial lalu melorot terdistorsi
        final moshStep = ((t * 6.0).floor() / 6.0);
        final moshShiftX =
            math.sin(moshStep * math.pi * 4.0) * 0.08 * intensity;
        final moshShiftY = (t * 0.1 * intensity);
        return AnimationTransformResult(
          positionX: moshShiftX,
          positionY: moshShiftY,
          chromaticAberration: 0.05 * intensity,
          scale: 1.04,
        );

      case 'trending_vhs_tracking_noise':
        // 40. Pita kaset VHS tracking error: derau scanline pekat & goyangan horizontal pita
        final vhsTear = math.sin(t * math.pi * 18.0) * 0.05 * intensity;
        final vhsRoll = (t * 2.0) % 1.0;
        return AnimationTransformResult(
          positionX: vhsTear,
          scanlineIntensity: (0.75 * intensity).clamp(0.0, 1.0),
          chromaticAberration: 0.035 * intensity,
          positionY: (vhsRoll < 0.1 ? 0.04 : 0.0) * intensity,
        );

      // --- BATCH 4: TRENDING 41 - 60 (REAL IMPLEMENTATION: GLITCH & 3D PERSPECTIVE) ---
      case 'trending_static_tv_snow':
        // 41. TV static snow: flicker intensitas cepat dengan goyangan frekuensi tinggi mikro
        final snowFlicker =
            ((t * 30.0).floor() % 2 == 0 ? 0.35 : 0.0) * intensity;
        final snowJitter = math.sin(t * math.pi * 36.0) * 0.02 * intensity;
        return AnimationTransformResult(
          flashOpacity: snowFlicker,
          positionX: snowJitter,
          scanlineIntensity: 0.6 * intensity,
          chromaticAberration: 0.025 * intensity,
        );

      case 'trending_pixel_sort_down':
        // 42. Pixel sort waterfall: efek lumeran piksel melorot vertikal ke bawah
        final sortY = (t * 0.25 * intensity);
        final sortSplit =
            (math.sin(t * math.pi * 4.0).abs() * 0.05) * intensity;
        return AnimationTransformResult(
          positionY: sortY,
          chromaticAberration: sortSplit,
          scaleY: 1.0 + (sortY * 0.5),
        );

      case 'trending_scanline_crt_buzz':
        // 43. CRT scanlines buzz dengan getaran horizontal dengung tabung kaca
        final crtBuzz = math.sin(t * math.pi * 40.0) * 0.018 * intensity;
        return AnimationTransformResult(
          positionX: crtBuzz,
          scanlineIntensity: 0.85 * intensity,
        );

      case 'trending_corrupted_ram_blocks':
        // 44. Corrupted RAM memory blocks: loncatan patah-patah blok data
        final blockStep = ((t * 8.0).floor() % 4);
        final blockShiftX =
            (blockStep == 1 ? 0.06 : (blockStep == 3 ? -0.06 : 0.0)) *
            intensity;
        final blockShiftY = (blockStep == 2 ? 0.03 : 0.0) * intensity;
        return AnimationTransformResult(
          positionX: blockShiftX,
          positionY: blockShiftY,
          chromaticAberration: blockStep != 0 ? 0.07 * intensity : 0.0,
        );

      case 'trending_block_displacement':
        // 45. Block displacement horizontal slice glitch
        final dispActive = ((t * 10.0).floor() % 3 == 0);
        final dispX = dispActive
            ? (math.sin(t * math.pi * 24.0) * 0.09 * intensity)
            : 0.0;
        return AnimationTransformResult(
          positionX: dispX,
          chromaticAberration: dispActive ? 0.08 * intensity : 0.01,
          scale: dispActive ? 1.03 : 1.0,
        );

      case 'trending_digital_tear_fast':
        // 46. Sobekan sinyal digital cepat (interlaced tear)
        final tearJump = ((t * 14.0).floor() % 2 == 0);
        return AnimationTransformResult(
          positionX: tearJump ? 0.05 * intensity : -0.05 * intensity,
          chromaticAberration: 0.06 * intensity,
          scanlineIntensity: 0.5 * intensity,
        );

      case 'trending_h264_macroblock_loss':
        // 47. H264 macroblock loss: frame stutter beku seketika diiringi distorsi
        final lossPhase = (t * 4.0) % 1.0;
        final isFrozen = lossPhase < 0.4;
        return AnimationTransformResult(
          positionX: isFrozen ? 0.02 * intensity : 0.0,
          chromaticAberration: isFrozen ? 0.05 * intensity : 0.0,
          scale: isFrozen ? 1.02 : 1.0,
        );

      case 'trending_chroma_channel_shift':
        // 48. Pergeseran kanal kroma independen (fase warna miring)
        final chromaPhase = math.sin(t * math.pi * 2.0);
        return AnimationTransformResult(
          chromaticAberration: (chromaPhase.abs() * 0.09 * intensity).clamp(
            0.0,
            0.15,
          ),
          positionX: chromaPhase * 0.02 * intensity,
        );

      case 'trending_glitch_teleport_burst':
        // 49. Teleport burst: hilang dalam sekejap dengan kilatan glitch lalu muncul kembali
        final teleT = math.sin(t * math.pi);
        final teleScale = (1.0 - teleT * 0.4 * intensity).clamp(0.2, 1.0);
        final teleFlash = (teleT * 0.85 * intensity).clamp(0.0, 1.0);
        return AnimationTransformResult(
          scale: teleScale,
          flashOpacity: teleFlash,
          chromaticAberration: teleT * 0.1 * intensity,
          positionX: math.sin(t * math.pi * 16.0) * 0.05 * teleT * intensity,
        );

      case 'trending_3d_card_flip_horiz':
        // 50. 3D Card Flip Horizontal nyata (membalik pada sumbu Yaw Y)
        final isOut = type == AnimationApplicationType.outAnimation;
        final flipProg = isOut ? t : (1.0 - t);
        final yawAngle = flipProg * 90.0 * intensity;
        final flipOpac = isOut ? (1.0 - t).clamp(0.0, 1.0) : t.clamp(0.0, 1.0);
        return AnimationTransformResult(
          rotateYDegrees: yawAngle,
          opacity: flipOpac,
          perspective: 0.002,
        );

      case 'trending_3d_cube_rotation':
        // 51. 3D Cube Rotation (sisi kubus berputar masuk dari kiri)
        final isOut = type == AnimationApplicationType.outAnimation;
        final cubeProg = isOut ? t : (1.0 - t);
        final cubeYaw = cubeProg * 90.0 * intensity;
        final cubeX = -cubeProg * 0.35 * intensity;
        return AnimationTransformResult(
          rotateYDegrees: cubeYaw,
          positionX: cubeX,
          opacity: (1.0 - cubeProg * 0.5).clamp(0.2, 1.0),
          perspective: 0.0022,
        );

      case 'trending_3d_door_swing_open':
        // 52. 3D Door Swing Open: berengsel di sisi kiri, membuka 85 derajat ke dalam ruang 3D
        final isOut = type == AnimationApplicationType.outAnimation;
        final doorProg = isOut ? t : (1.0 - t);
        final doorAngle = -doorProg * 85.0 * intensity;
        final doorPivotX = -doorProg * 0.28 * intensity;
        return AnimationTransformResult(
          rotateYDegrees: doorAngle,
          positionX: doorPivotX,
          opacity: (1.0 - doorProg * 0.3).clamp(0.2, 1.0),
          perspective: 0.0025,
        );

      case 'trending_3d_origami_fold':
        // 53. 3D Origami Fold: lipatan kertas menyempit pada sumbu X dengan kemiringan 3D
        final isOut = type == AnimationApplicationType.outAnimation;
        final foldProg = isOut ? t : (1.0 - t);
        final foldScaleX = (1.0 - foldProg * 0.85).clamp(0.1, 1.0);
        final foldPitch = foldProg * 45.0 * intensity;
        return AnimationTransformResult(
          scaleX: foldScaleX,
          rotateXDegrees: foldPitch,
          opacity: (1.0 - foldProg * 0.6).clamp(0.0, 1.0),
          perspective: 0.0018,
        );

      case 'trending_3d_spatial_cylinder_roll':
        // 54. 3D Spatial Cylinder Roll: bergulir melengkung di permukaan silinder
        final isOut = type == AnimationApplicationType.outAnimation;
        final rollProg = isOut ? t : (1.0 - t);
        final rollPitch = -rollProg * 110.0 * intensity;
        final rollY = rollProg * 0.45 * intensity;
        return AnimationTransformResult(
          rotateXDegrees: rollPitch,
          positionY: rollY,
          opacity: (1.0 - rollProg * 0.4).clamp(0.0, 1.0),
          perspective: 0.0022,
        );

      case 'trending_3d_depth_push_z':
        // 55. 3D Depth Push Z-Axis: meluncur ke kedalaman ruang Z dengan perbesaran perspektif
        final isOut = type == AnimationApplicationType.outAnimation;
        final pushProg = isOut ? t : (1.0 - t);
        final pushScale = 1.0 + (pushProg * 0.45 * intensity);
        final pushPitch = math.sin(pushProg * math.pi) * 12.0 * intensity;
        return AnimationTransformResult(
          scale: pushScale.clamp(0.6, 2.0),
          rotateXDegrees: pushPitch,
          opacity: (1.0 - pushProg * 0.5).clamp(0.2, 1.0),
          perspective: 0.002,
        );

      case 'trending_3d_tunnel_dive_in':
        // 56. 3D Tunnel Dive In: menyelam ke terowongan dengan pusaran rotasi Z dan dorongan maju
        final isOut = type == AnimationApplicationType.outAnimation;
        final diveProg = isOut ? (1.0 - t) : t;
        final diveScale = 0.2 + (diveProg * 0.85);
        final diveRotZ = (1.0 - diveProg) * 180.0 * intensity;
        return AnimationTransformResult(
          scale: diveScale.clamp(0.1, 1.5),
          rotationDegrees: diveRotZ,
          opacity: diveProg.clamp(0.0, 1.0),
          perspective: 0.0028,
        );

      case 'trending_3d_shatter_glass':
      case 'shatter_glass_3d':
      case 'shatter_glass_out':
      case 'threed_shattered_glass_depth':
        // 57. 3D Shattered Glass: perpecahan fragmen kaca miring berkedalaman
        final shatterT = math.sin(t * math.pi * 2.0) * 0.06 * intensity;
        final shatterYaw = math.sin(t * math.pi * 3.0) * 20.0 * intensity;
        final shatterPitch = math.cos(t * math.pi * 2.0) * 15.0 * intensity;
        return AnimationTransformResult(
          positionX: shatterT,
          rotateYDegrees: shatterYaw,
          rotateXDegrees: shatterPitch,
          chromaticAberration: 0.04 * intensity,
          perspective: 0.002,
        );

      case 'trending_3d_tesseract_spin':
        // 58. 3D Tesseract Spin: hiperkubus 4 dimensi memutar ganda sumbu X dan Y bersamaan
        final tessX = math.sin(t * math.pi * 2.0) * 35.0 * intensity;
        final tessY = math.cos(t * math.pi * 2.0) * 45.0 * intensity;
        final tessScale =
            0.92 + (math.sin(t * math.pi * 4.0).abs() * 0.12 * intensity);
        return AnimationTransformResult(
          rotateXDegrees: tessX,
          rotateYDegrees: tessY,
          scale: tessScale,
          perspective: 0.0024,
        );

      case 'trending_3d_anti_gravity_rise':
        // 59. 3D Anti-Gravity Rise: mengambang melayang ke atas melawan gravitasi dengan pitch anggun
        final riseY = -math.sin(t * math.pi * 1.5) * 0.22 * intensity;
        final risePitch = -math.sin(t * math.pi) * 16.0 * intensity;
        final riseScale = 1.0 + (math.sin(t * math.pi) * 0.08 * intensity);
        return AnimationTransformResult(
          positionY: riseY,
          rotateXDegrees: risePitch,
          scale: riseScale,
          perspective: 0.0018,
        );

      case 'trending_3d_infinite_mirror_zoom':
        // 60. 3D Infinite Mirror Zoom: lorong cermin pantulan tak berhingga
        final mirrorZ = math.sin(t * math.pi * 2.0);
        final mirrorScale = 1.0 + (mirrorZ * 0.18 * intensity);
        final mirrorYaw = mirrorZ * 12.0 * intensity;
        return AnimationTransformResult(
          scale: mirrorScale,
          rotateYDegrees: mirrorYaw,
          perspective: 0.003,
        );

      // --- BATCH 5: TRENDING 61 - 80 (REAL IMPLEMENTATION: MOTION & RETRO) ---
      case 'trending_3d_floating_card_hover':
        // 61. 3D Floating Card Hover: kartu 3D melayang anggun di udara dengan goyangan tilt
        final floatHoverY = math.sin(t * math.pi * 2.0) * 0.05 * intensity;
        final floatPitch = math.sin(t * math.pi * 2.0) * 8.0 * intensity;
        final floatYaw = math.cos(t * math.pi * 2.0) * 10.0 * intensity;
        return AnimationTransformResult(
          positionY: floatHoverY,
          rotateXDegrees: floatPitch,
          rotateYDegrees: floatYaw,
          scale: 0.96 + (math.cos(t * math.pi * 2.0).abs() * 0.04),
          perspective: 0.0018,
        );

      case 'trending_speed_ramp_curve':
        // 62. Speed ramp curve: akselerasi super cepat di tengah lalu melambat halus (ease-in-out tajam)
        final rampCurve = math.pow(math.sin(t * math.pi), 3.0).toDouble();
        final rampScale = 1.0 + (rampCurve * 0.45 * intensity);
        final rampBlur = rampCurve * 7.0 * intensity;
        return AnimationTransformResult(scale: rampScale, blurRadius: rampBlur);

      case 'trending_kinetic_flow_whip':
        // 63. Kinetic whip pan: sapuan horizontal super cepat dengan blur dinamis
        final whipX =
            (t < 0.5 ? (t * 2.0) : (1.0 - (t - 0.5) * 2.0)) * 0.55 * intensity;
        final whipBlur = math.sin(t * math.pi) * 9.0 * intensity;
        return AnimationTransformResult(positionX: whipX, blurRadius: whipBlur);

      case 'trending_hyper_speed_dash':
        // 64. Hyper speed dash motion: dorongan lari secepat kilat dengan peregangan scaleX
        final dashT = math.sin(t * math.pi);
        final dashStretch = 1.0 + (dashT * 0.35 * intensity);
        final dashCompress = 1.0 - (dashT * 0.15 * intensity);
        return AnimationTransformResult(
          scaleX: dashStretch,
          scaleY: dashCompress,
          positionX: (t - 0.5) * 0.4 * intensity,
          blurRadius: dashT * 8.0 * intensity,
        );

      case 'trending_rubber_band_bounce':
        // 65. Rubber band bounce: pantulan karet melar dan membal secara kenyal
        final rubberY =
            -math.sin(t * math.pi * 3.0).abs() *
            math.exp(-t * 2.2) *
            0.3 *
            intensity;
        final rubberSquash =
            1.0 +
            math.sin(t * math.pi * 6.0) * math.exp(-t * 2.5) * 0.2 * intensity;
        return AnimationTransformResult(
          positionY: rubberY,
          scaleY: rubberSquash,
          scaleX: 2.0 - rubberSquash,
        );

      case 'trending_fpv_drone_flythrough':
      case 'fpv_drone_knife_edge':
      case 'motion_fpv_drone_dive_bomb':
      case 'motion_fpv_drone_knife_edge':
      case 'plane_fly_in':
      case 'plane_fly_out':
        // 66. FPV drone dive bomb & plane flythrough: manuver drone meliuk tajam, roll miring, dan menukik
        final droneRoll = math.sin(t * math.pi * 2.0) * 14.0 * intensity;
        final dronePitch = math.cos(t * math.pi * 2.0) * 12.0 * intensity;
        final droneZ = 1.0 + (t * 0.3 * intensity);
        final droneX = math.sin(t * math.pi * 2.0) * 0.15 * intensity;
        return AnimationTransformResult(
          rotationDegrees: droneRoll,
          rotateXDegrees: dronePitch,
          scale: droneZ,
          positionX: droneX,
          perspective: 0.002,
        );

      case 'trending_jelly_physics_wobble':
        // 67. Jelly physics wobble: goyangan agar-agar kenyal multi-arah
        final jellyWave =
            math.sin(t * math.pi * 4.5) * math.exp(-t * 1.8) * 0.22 * intensity;
        return AnimationTransformResult(
          scaleX: 1.0 + jellyWave,
          scaleY: 1.0 - jellyWave,
        );

      case 'trending_magnetic_pull_snap':
        // 68. Tarikan magnetik snap: perlahan ditarik lalu tersentak seketika menempel
        final magnetProg = math.pow(t, 4.0).toDouble();
        final magnetScale = 0.7 + (magnetProg * 0.3);
        final magnetY = (1.0 - magnetProg) * -0.4 * intensity;
        return AnimationTransformResult(
          scale: magnetScale,
          positionY: magnetY,
          opacity: (0.4 + magnetProg * 0.6).clamp(0.0, 1.0),
        );

      case 'trending_pendulum_swing_in':
        // 69. Ayunan pendulum gravitasi nyata dari sudut atas melintasi titik tengah
        final pendAngle =
            math.sin(t * math.pi * 2.0) * math.exp(-t * 1.5) * 16.0 * intensity;
        final pendX = math.sin(pendAngle * math.pi / 180.0) * 0.35;
        return AnimationTransformResult(
          rotationDegrees: pendAngle,
          positionX: pendX,
        );

      case 'trending_slingshot_release':
        // 70. Pelepasan ketapel (slingshot recoil fire): ditarik mundur lambat lalu melesat kencang
        double slingX = 0.0;
        double slingScale = 1.0;
        if (t < 0.4) {
          // Tarik mundur
          slingX = -(t / 0.4) * 0.12 * intensity;
          slingScale = 1.0 - (t / 0.4) * 0.08;
        } else {
          // Melesat maju
          final releaseT = (t - 0.4) / 0.6;
          slingX = (-0.12 + releaseT * 1.2) * intensity;
          slingScale = 0.92 + releaseT * 0.35;
        }
        return AnimationTransformResult(
          positionX: slingX,
          scale: slingScale.clamp(0.5, 2.0),
          blurRadius: t > 0.4
              ? (math.sin((t - 0.4) * math.pi) * 6.0 * intensity)
              : 0.0,
        );

      case 'trending_camera_slider_push':
        // 71. Motorized slider push: dorongan rel slider kamera yang sangat stabil dan mulus
        final sliderProg = math.sin(t * math.pi * 0.5);
        final sliderScale = 1.0 + (sliderProg * 0.22 * intensity);
        final sliderPanX = (sliderProg - 0.5) * 0.08 * intensity;
        return AnimationTransformResult(
          scale: sliderScale,
          positionX: sliderPanX,
        );

      case 'trending_smooth_pedestal_up':
        // 72. Smooth pedestal up: kamera bergerak naik vertikal secara stabil
        final pedY = (0.5 - t) * 0.25 * intensity;
        return AnimationTransformResult(positionY: pedY, scale: 1.04);

      case 'trending_rollercoaster_dive':
        // 73. Rollercoaster dive: turunan tajam dengan dorongan G-force dan pitch menukik
        final rcProg = math.pow(t, 2.2).toDouble();
        final rcY = rcProg * 0.45 * intensity;
        final rcPitch = -rcProg * 35.0 * intensity;
        final rcScale = 1.0 + (rcProg * 0.3 * intensity);
        return AnimationTransformResult(
          positionY: rcY,
          rotateXDegrees: rcPitch,
          scale: rcScale,
          perspective: 0.002,
        );

      case 'trending_vhs_vintage_flicker':
        // 74. VHS vintage flicker: kedipan lembut tape analog 90s dengan garis derau
        final vhsFlicker = (math.sin(t * math.pi * 24.0) * 0.08 * intensity);
        return AnimationTransformResult(
          opacity: (0.92 + vhsFlicker).clamp(0.65, 1.0),
          scanlineIntensity: 0.55 * intensity,
          positionY: math.cos(t * math.pi * 16.0) * 0.01 * intensity,
        );

      case 'trending_8mm_silent_film_jitter':
        // 75. Rol film 8mm bisu: goyangan vertikal proyektor mekanik dan kedipan pencahayaan
        final filmWeaveY =
            (math.sin(t * math.pi * 18.0) +
                math.cos(t * math.pi * 27.0) * 0.5) *
            0.02 *
            intensity;
        final filmFlicker =
            (math.sin(t * math.pi * 20.0).abs() * 0.12 * intensity);
        return AnimationTransformResult(
          positionY: filmWeaveY,
          flashOpacity: filmFlicker,
          rotationDegrees: math.sin(t * math.pi * 4.0) * 0.8 * intensity,
        );

      case 'trending_16mm_projector_hum':
        // 76. Proyektor 16mm hum: dengung rol film mekanis stabil dengan framing bergetar halus
        final humY = math.sin(t * math.pi * 22.0) * 0.012 * intensity;
        return AnimationTransformResult(
          positionY: humY,
          flashOpacity: (math.sin(t * math.pi * 12.0).abs() * 0.08 * intensity),
        );

      case 'trending_film_countdown_leader':
        // 77. Film leader hitungan mundur 5-4-3-2-1: putaran garis jarum jam pembuka film
        final clockAngle = (t * 360.0);
        final leaderFlicker =
            ((t * 10.0).floor() % 2 == 0 ? 0.2 : 0.0) * intensity;
        return AnimationTransformResult(
          rotationDegrees: clockAngle * 0.1 * intensity,
          flashOpacity: leaderFlicker,
          scanlineIntensity: 0.4 * intensity,
        );

      case 'trending_polaroid_develop_fade':
        // 78. Polaroid instant develop: warna dan gambar perlahan muncul dari lapisan abu-abu gelap
        final isOut = type == AnimationApplicationType.outAnimation;
        final devProg = isOut ? (1.0 - t) : t;
        final polaroidOpac = math.pow(devProg, 1.5).toDouble().clamp(0.0, 1.0);
        return AnimationTransformResult(
          opacity: polaroidOpac,
          scale: 0.95 + (devProg * 0.05),
          flashOpacity: (1.0 - devProg) * 0.3 * intensity,
        );

      case 'trending_halftone_comic_pop':
        // 79. Halftone comic pop: zoom pop-out gaya komik cetak pop art
        final comicPop =
            math.sin(t * math.pi * 3.0) * math.exp(-t * 2.0) * 0.18 * intensity;
        return AnimationTransformResult(
          scale: 1.0 + comicPop,
          chromaticAberration: 0.03 * intensity,
        );

      case 'trending_crt_phosphor_decay':
        // 80. CRT phosphor decay: pendaran fosfor tabung TV menyala lalu padam perlahan
        final phosphorGlow = math.sin(t * math.pi) * 0.6 * intensity;
        return AnimationTransformResult(
          flashOpacity: phosphorGlow.clamp(0.0, 0.8),
          scanlineIntensity: 0.7 * intensity,
          scale: 1.0 + (phosphorGlow * 0.03),
        );

      // --- BATCH 6: TRENDING 81 - 101 (REAL IMPLEMENTATION: RETRO & CINEMATIC) ---
      case 'trending_typewriter_clack_frame':
        // 81. Typewriter mechanical step: hentakan ketukan mesin tik berirama staccato
        final typeStep = ((t * 8.0).floor() % 2 == 0);
        return AnimationTransformResult(
          positionX: typeStep ? 0.015 * intensity : -0.015 * intensity,
          scale: 1.0 + (typeStep ? 0.02 * intensity : 0.0),
        );

      case 'trending_gramophone_scratch_audio':
        // 82. Gramophone vinyl dust: goyangan piringan hitam mikro berputar konstan
        final vinylWobble = math.sin(t * math.pi * 3.3) * 0.015 * intensity;
        return AnimationTransformResult(
          positionY: vinylWobble,
          rotationDegrees: math.sin(t * math.pi * 3.3) * 0.6 * intensity,
        );

      case 'trending_kodachrome_64_vintage':
        // 83. Kodachrome 64 warmth: saturasi hangat film positif vintage dengan breathing stabil
        final kodaGlow = (math.sin(t * math.pi * 1.5).abs() * 0.25 * intensity);
        return AnimationTransformResult(
          flashOpacity: kodaGlow,
          scale: 1.0 + (kodaGlow * 0.04),
        );

      case 'trending_technicolor_vivid_strip':
      case 'retro_technicolor_two_strip':
        // 84. Technicolor vivid 2-strip: pemisahan optik dua strip warna klasik dengan pendaran kontras
        final techAberration =
            (0.03 + math.sin(t * math.pi * 2.0).abs() * 0.03) * intensity;
        return AnimationTransformResult(
          chromaticAberration: techAberration,
          scale: 1.02,
        );

      case 'trending_super8_home_movie_edge':
        // 85. Super 8 home movie edge weave: goyangan rol seluloid proyektor rumahan 8mm
        final s8WeaveX = math.sin(t * math.pi * 16.0) * 0.015 * intensity;
        final s8WeaveY = math.cos(t * math.pi * 14.0) * 0.02 * intensity;
        final s8Flicker = (math.sin(t * math.pi * 22.0) * 0.06 * intensity);
        return AnimationTransformResult(
          positionX: s8WeaveX,
          positionY: s8WeaveY,
          opacity: (0.94 + s8Flicker).clamp(0.7, 1.0),
        );

      case 'trending_cinema_letterbox_in':
        // 86. 2.39:1 Cinema Letterbox: bilah hitam bioskop menutup proporsional
        final isOut = type == AnimationApplicationType.outAnimation;
        final letProg = isOut ? (1.0 - t) : t;
        return AnimationTransformResult(
          clipShape: AnimationClipShape.splitVertical,
          clipProgress: (0.45 + letProg * 0.55).clamp(0.0, 1.0),
          scale: 1.0,
        );

      case 'trending_blockbuster_hero_reveal':
        // 87. Blockbuster hero reveal: pengenalan tokoh megah dengan slow push, fade halus, dan flare pendaran
        final isOut = type == AnimationApplicationType.outAnimation;
        final revProg = isOut ? (1.0 - t) : t;
        final heroScale = 0.92 + (revProg * 0.12);
        return AnimationTransformResult(
          scale: heroScale,
          opacity: math.sin(revProg * math.pi * 0.5).clamp(0.0, 1.0),
          flashOpacity: (1.0 - revProg) * 0.45 * intensity,
        );

      case 'trending_teal_orange_grade':
      case 'teal_and_orange_mood':
        // 88. Teal & Orange blockbuster color grade breathing: slow push dengan nuansa film Hollywood
        final toScale = 1.0 + (t * 0.12 * intensity);
        return AnimationTransformResult(
          scale: toScale,
          chromaticAberration: 0.025 * intensity,
        );

      case 'trending_rack_focus_bokeh':
        // 89. Rack focus depth of field: perpindahan optik kamera dari blur lembut ke tajam 100%
        final isOut = type == AnimationApplicationType.outAnimation;
        final focusProg = isOut ? t : (1.0 - t);
        final blurAmount = (focusProg * 14.0 * intensity).clamp(0.0, 20.0);
        return AnimationTransformResult(
          blurRadius: blurAmount,
          scale: 1.0 + (focusProg * 0.04),
        );

      case 'trending_hitchcock_vertigo_dolly':
        // 90. Hitchcock Vertigo Dolly Zoom: peregangan optik Zolly (skala kamera melawan perspektif)
        final zollyWave = math.sin(t * math.pi);
        final zollyScale = 1.0 + (zollyWave * 0.35 * intensity);
        final zollyBlur = (zollyWave * 3.5 * intensity);
        final zollyPitch = zollyWave * 6.0 * intensity;
        return AnimationTransformResult(
          scale: zollyScale,
          blurRadius: zollyBlur,
          rotateXDegrees: zollyPitch,
          perspective: 0.0025,
        );

      case 'trending_epic_crane_shot_swoop':
        // 91. Epic crane shot swoop: lintasan derek kamera melambung turun melengkung
        final isOut = type == AnimationApplicationType.outAnimation;
        final craneProg = isOut ? t : (1.0 - t);
        final craneY = -craneProg * 0.35 * intensity;
        final cranePitch = -craneProg * 22.0 * intensity;
        final craneScale = 1.0 + (craneProg * 0.15);
        return AnimationTransformResult(
          positionY: craneY,
          rotateXDegrees: cranePitch,
          scale: craneScale,
          perspective: 0.002,
        );

      case 'trending_bleach_bypass_war_film':
        // 92. Bleach bypass war tone: kontras tajam pekat dengan mikro getaran kamera genggam dokumenter perang
        final warJitter = math.sin(t * math.pi * 16.0) * 0.015 * intensity;
        return AnimationTransformResult(
          positionX: warJitter,
          positionY: math.cos(t * math.pi * 14.0) * 0.015 * intensity,
          scale: 1.02,
        );

      case 'trending_chiaroscuro_noir_shadow':
        // 93. Chiaroscuro noir shadow: kontras bayangan tajam gaya film noir detektif
        final noirBreath = math.sin(t * math.pi * 1.5) * 0.04 * intensity;
        return AnimationTransformResult(scale: 1.0 + noirBreath, opacity: 0.95);

      case 'trending_anamorphic_oval_bokeh':
        // 94. Anamorphic oval bokeh: pendaran lonjong elips khas lensa anamorfik bioskop
        final ovalPulse =
            (math.sin(t * math.pi * 2.0).abs() * 0.05 * intensity);
        return AnimationTransformResult(
          scaleX: 1.0 + ovalPulse * 1.5,
          scaleY: 1.0 - ovalPulse * 0.5,
          flashOpacity: (ovalPulse * 3.0).clamp(0.0, 0.5),
        );

      case 'trending_fpv_ridge_sweep_cinema':
      case 'epic_crane_descend':
      case 'epic_crane_ascend':
        // 95. FPV ridge sweep cinema / crane flight: sapuan kamera meluncur cepat di atas kontur tebing
        final ridgeProg = math.pow(t, 2.0).toDouble();
        final ridgePanX = (t - 0.5) * 0.25 * intensity;
        final ridgePitch = -ridgeProg * 18.0 * intensity;
        return AnimationTransformResult(
          positionX: ridgePanX,
          rotateXDegrees: ridgePitch,
          scale: 1.0 + (ridgeProg * 0.18),
          perspective: 0.002,
        );

      case 'trending_dramatic_slow_push':
        // 96. Dramatic slow push in: dorongan kamera sangat halus dan lambat merapat ke subjek
        final slowPushScale = 1.0 + (t * 0.16 * intensity);
        return AnimationTransformResult(scale: slowPushScale);

      case 'trending_cinema_dolly_lateral':
        // 97. Cinematic lateral dolly: lintasan rel dolly menyamping secara anggun
        final dollyX = (t - 0.5) * 0.28 * intensity;
        return AnimationTransformResult(positionX: dollyX, scale: 1.04);

      case 'trending_action_impact_cut':
        // 98. Action impact jump cut: lompatan potongan adegan laga berkecepatan tinggi
        final jumpPhase = ((t * 6.0).floor() % 2 == 0);
        return AnimationTransformResult(
          scale: jumpPhase ? 1.08 * intensity : 1.0,
          positionX: jumpPhase ? 0.02 * intensity : 0.0,
        );

      case 'trending_cross_scale_dissolve':
        // 99. Cross scale dissolve: peleburan dua frame berpadu skala mikro yang elegan
        final isOut = type == AnimationApplicationType.outAnimation;
        final disProg = isOut ? (1.0 - t) : t;
        return AnimationTransformResult(
          opacity: disProg.clamp(0.0, 1.0),
          scale: 0.94 + (disProg * 0.08),
        );

      case 'trending_cinema_curtain_reveal':
        // 100. Cinema curtain reveal: bukaan tirai perak bioskop membuka adegan agung
        final isOut = type == AnimationApplicationType.outAnimation;
        final curProg = isOut ? (1.0 - t) : t;
        return AnimationTransformResult(
          clipShape: AnimationClipShape.curtain,
          clipProgress: curProg.clamp(0.0, 1.0),
          scale: 1.0,
        );

      case 'online_cyberpunk_neon':
      case 'cyberpunk_neon':
        // 101. Cyberpunk neon shift: pergeseran warna neon distrik cyberpunk malam hari
        final cyberPulse =
            (math.sin(t * math.pi * 2.0).abs() * 0.6 * intensity);
        return AnimationTransformResult(
          chromaticAberration: (0.04 + cyberPulse * 0.05).clamp(0.0, 0.12),
          flashOpacity: (cyberPulse * 0.4).clamp(0.0, 0.6),
          scale: 1.0 + (cyberPulse * 0.04),
        );

      case 'flash_zoom':
        // Flash cahaya transisi disusul penarikan zoom tajam ke subjek
        final zoomProgress = math.sin(t * (math.pi / 2.0));
        final scale = 1.0 + (1.0 - zoomProgress) * 0.7 * intensity;
        final flash = t < 0.35 ? (1.0 - (t / 0.35)) * 0.95 * intensity : 0.0;
        return AnimationTransformResult(scale: scale, flashOpacity: flash);

      case 'beat_zoom':
        final bump = (math.sin(t * math.pi * 2.0).abs()) * 0.35 * intensity;
        return AnimationTransformResult(scale: 1.0 + bump);

      case 'bounce':
        final bounceY =
            (math.sin(t * math.pi * 3.0).abs() * (1.0 - t)) * 0.25 * intensity;
        return AnimationTransformResult(positionY: -bounceY);

      case 'pop_up':
        final scale = t < 0.7
            ? (t / 0.7) * 1.15
            : 1.15 - ((t - 0.7) / 0.3) * 0.15;
        return AnimationTransformResult(scale: scale * intensity);

      case 'dynamic_zoom':
        final scale = 1.0 + (t * 0.4 * intensity);
        return AnimationTransformResult(scale: scale);

      case 'camera_push':
        return AnimationTransformResult(scale: 1.0 + (t * 0.3 * intensity));

      case 'camera_pull':
        return AnimationTransformResult(
          scale: (1.3 * intensity) - (t * 0.3 * intensity),
        );

      case 'smooth_reveal':
        return AnimationTransformResult(opacity: t, scale: 0.9 + (t * 0.1));

      case 'speed_ramp_anim':
        final scale = 1.0 + math.pow(t, 3) * 0.4 * intensity;
        return AnimationTransformResult(scale: scale);

      // ==========================================
      // --- BASIC IN / OUT / TRANSITIONS (100 REAL PRESETS) ---
      // ==========================================

      // 1. Fade In / Out
      case 'fade_in':
        return AnimationTransformResult(opacity: t.clamp(0.0, 1.0));
      case 'fade_out':
        return AnimationTransformResult(opacity: (1.0 - t).clamp(0.0, 1.0));

      // 2. Zoom In / Out / Burst / Smooth
      case 'zoom_in':
        // Zoom In: Mulai dari skala kecil (0.2) mendekat ke ukuran normal (1.0) dengan scale ramping
        final zInScale = 0.2 + (t * 0.8 * intensity);
        return AnimationTransformResult(
          scale: zInScale.clamp(0.1, 1.0),
          opacity: (t * 1.5).clamp(0.0, 1.0),
        );
      case 'zoom_out':
        // Zoom Out: Dari frame normal (1.0) mengecil menjauh ke background (0.1)
        final zOutScale = 1.0 - (t * 0.85 * intensity);
        return AnimationTransformResult(
          scale: zOutScale.clamp(0.05, 1.0),
          opacity: (1.0 - t).clamp(0.0, 1.0),
        );

      // 3. Slide 4-Way In & Out (Scene meluncur masuk / keluar kanvas dengan velocity nyata)
      case 'slide_in_left':
        // Masuk dari sisi kiri ke posisi tengah
        return AnimationTransformResult(
          positionX: -(1.0 - t) * 1.2 * intensity,
          opacity: (t * 2.0).clamp(0.0, 1.0),
        );
      case 'slide_in_right':
        // Masuk dari sisi kanan ke posisi tengah
        return AnimationTransformResult(
          positionX: (1.0 - t) * 1.2 * intensity,
          opacity: (t * 2.0).clamp(0.0, 1.0),
        );
      case 'slide_in_top':
        // Masuk dari sisi atas ke posisi tengah
        return AnimationTransformResult(
          positionY: -(1.0 - t) * 1.2 * intensity,
          opacity: (t * 2.0).clamp(0.0, 1.0),
        );
      case 'slide_in_bottom':
        // Masuk dari sisi bawah ke posisi tengah
        return AnimationTransformResult(
          positionY: (1.0 - t) * 1.2 * intensity,
          opacity: (t * 2.0).clamp(0.0, 1.0),
        );
      case 'slide_out_left':
        // Keluar dari tengah menuju sisi kiri kanvas
        return AnimationTransformResult(
          positionX: -t * 1.2 * intensity,
          opacity: (1.0 - t).clamp(0.0, 1.0),
        );
      case 'slide_out_right':
        // Keluar dari tengah menuju sisi kanan kanvas
        return AnimationTransformResult(
          positionX: t * 1.2 * intensity,
          opacity: (1.0 - t).clamp(0.0, 1.0),
        );
      case 'slide_out_top':
        // Keluar dari tengah meluncur ke sisi atas kanvas
        return AnimationTransformResult(
          positionY: -t * 1.2 * intensity,
          opacity: (1.0 - t).clamp(0.0, 1.0),
        );
      case 'slide_out_bottom':
        // Keluar dari tengah meluncur ke sisi bawah kanvas
        return AnimationTransformResult(
          positionY: t * 1.2 * intensity,
          opacity: (1.0 - t).clamp(0.0, 1.0),
        );

      // 4. Push 4-Way (Klip baru mendorong secara mekanis & penuh energi dari arah datangnya)
      case 'push_left':
        // Push Left: Klip baru masuk dari kanan (offset 1.0 -> 0.0)
        return AnimationTransformResult(
          positionX: (1.0 - t) * 1.05 * intensity,
          opacity: 1.0,
        );
      case 'push_right':
        // Push Right: Klip baru masuk dari kiri (offset -1.0 -> 0.0)
        return AnimationTransformResult(
          positionX: -(1.0 - t) * 1.05 * intensity,
          opacity: 1.0,
        );
      case 'push_up':
        // Push Up: Klip baru masuk dari bawah (offset 1.0 -> 0.0)
        return AnimationTransformResult(
          positionY: (1.0 - t) * 1.05 * intensity,
          opacity: 1.0,
        );
      case 'push_down':
        // Push Down: Klip baru masuk dari atas (offset -1.0 -> 0.0)
        return AnimationTransformResult(
          positionY: -(1.0 - t) * 1.05 * intensity,
          opacity: 1.0,
        );

      // 5. Dissolve & Dip to Color
      case 'cross_dissolve':
        // Peleburan dua klip bertingkat halus dengan interpolasi kurva S-curve
        final sProg = (math.sin((t - 0.5) * math.pi) * 0.5 + 0.5);
        return AnimationTransformResult(opacity: sProg.clamp(0.0, 1.0));
      case 'dip_to_black':
        // Fade ke hitam pekat di puncak transisi
        return AnimationTransformResult(
          colorOverlayOpacity: (math.sin(t * math.pi) * 1.0).clamp(0.0, 1.0),
          colorOverlayValue: 0xFF000000,
          opacity: 1.0 - (math.sin(t * math.pi) * 0.7),
        );
      case 'dip_to_white':
        // Fade ke kilau putih bersih di puncak transisi
        return AnimationTransformResult(
          colorOverlayOpacity: (math.sin(t * math.pi) * 1.0).clamp(0.0, 1.0),
          colorOverlayValue: 0xFFFFFFFF,
          opacity: 1.0,
        );
      // 6. IRIS & GEOMETRIC MASKS (BATCH 2)
      case 'circle_crop_open':
        // Lingkaran membesar dari poros tengah membuka frame penuh (0.0 -> 1.0)
        return AnimationTransformResult(
          clipShape: AnimationClipShape.circleIris,
          clipProgress: t.clamp(0.0, 1.0),
          opacity: 1.0,
        );
      case 'circle_crop_close':
        // Lingkaran mengecil dari frame penuh menuju titik poros tengah (1.0 -> 0.0)
        return AnimationTransformResult(
          clipShape: AnimationClipShape.circleIris,
          clipProgress: (1.0 - t).clamp(0.0, 1.0),
          opacity: 1.0,
        );
      case 'diamond_iris_in':
      case 'basic_diamond_iris_expand':
        // Belah ketupat berlian geometris membesar dari tengah (0.0 -> 1.0)
        return AnimationTransformResult(
          clipShape: AnimationClipShape.diamondIris,
          clipProgress: t.clamp(0.0, 1.0),
          opacity: 1.0,
        );
      case 'diamond_iris_out':
        // Belah ketupat berlian mengecil dari frame penuh ke tengah (1.0 -> 0.0)
        return AnimationTransformResult(
          clipShape: AnimationClipShape.diamondIris,
          clipProgress: (1.0 - t).clamp(0.0, 1.0),
          opacity: 1.0,
        );
      case 'basic_pentagon_iris_expand':
        // Segi lima (pentagon 5 sisi presisi) membesar dari tengah (0.0 -> 1.0)
        return AnimationTransformResult(
          clipShape: AnimationClipShape.pentagonIris,
          clipProgress: t.clamp(0.0, 1.0),
          opacity: 1.0,
        );
      case 'basic_star_iris_reveal':
        // Bintang 5-sudut simetris membesar dari poros tengah membuka video
        return AnimationTransformResult(
          clipShape: AnimationClipShape.starIris,
          clipProgress: t.clamp(0.0, 1.0),
          opacity: 1.0,
        );
      case 'soft_iris_in':
        // Iris lingkaran dengan blur tepi halus memudar masuk
        return AnimationTransformResult(
          clipShape: AnimationClipShape.circleIris,
          clipProgress: t.clamp(0.0, 1.0),
          blurRadius: (1.0 - t) * 6.0 * intensity,
          opacity: 1.0,
        );
      case 'soft_iris_out':
        // Iris lingkaran dengan blur tepi halus memudar keluar
        return AnimationTransformResult(
          clipShape: AnimationClipShape.circleIris,
          clipProgress: (1.0 - t).clamp(0.0, 1.0),
          blurRadius: t * 6.0 * intensity,
          opacity: 1.0,
        );

      // 7. LINEAR WIPES & MATTE SWEEPS
      case 'wipe_right':
        return AnimationTransformResult(
          clipShape: AnimationClipShape.wipeRight,
          clipProgress: t.clamp(0.0, 1.0),
          opacity: 1.0,
        );
      case 'wipe_left':
        return AnimationTransformResult(
          clipShape: AnimationClipShape.wipeLeft,
          clipProgress: t.clamp(0.0, 1.0),
          opacity: 1.0,
        );
      case 'wipe_up':
      case 'basic_linear_wipe_up':
        return AnimationTransformResult(
          clipShape: AnimationClipShape.wipeUp,
          clipProgress: t.clamp(0.0, 1.0),
          opacity: 1.0,
        );
      case 'wipe_down':
      case 'basic_linear_wipe_down':
        return AnimationTransformResult(
          clipShape: AnimationClipShape.wipeDown,
          clipProgress: t.clamp(0.0, 1.0),
          opacity: 1.0,
        );
      case 'diagonal_wipe_tl':
      case 'basic_matte_wipe_diagonal':
        // Sapu bidang matte bersudut diagonal 45 derajat membelah layar dari Top-Left
        return AnimationTransformResult(
          clipShape: AnimationClipShape.wipeDiagonalTL,
          clipProgress: t.clamp(0.0, 1.0),
          opacity: 1.0,
        );
      case 'diagonal_wipe_br':
        // Sapuan diagonal dari sudut Bottom-Right ke Top-Left
        return AnimationTransformResult(
          clipShape: AnimationClipShape.wipeDiagonalBR,
          clipProgress: t.clamp(0.0, 1.0),
          opacity: 1.0,
        );

      // 8. RADIAL & CLOCK WIPES
      case 'clock_wipe':
      case 'basic_radial_clock_wipe':
        // Sapuan jarum jam melingkar searah 360 derajat membuka seluruh sudut bidang
        return AnimationTransformResult(
          clipShape: AnimationClipShape.clockWipe,
          clipProgress: t.clamp(0.0, 1.0),
          opacity: 1.0,
        );
      case 'basic_radial_counter_clock':
        // Sapu berlawanan arah jarum jam 360 derajat melingkar
        return AnimationTransformResult(
          clipShape: AnimationClipShape.counterClockWipe,
          clipProgress: t.clamp(0.0, 1.0),
          opacity: 1.0,
        );

      // 9. CHECKERBOARD
      case 'checkerboard_in':
      case 'basic_checkerboard_flip':
      case 'basic_checkerboard_wipe_down':
        return AnimationTransformResult(
          clipShape: AnimationClipShape.checkerboard,
          clipProgress: t.clamp(0.0, 1.0),
          opacity: 1.0,
        );
      // 10. SPINS & SPIRALS
      case 'spin_in':
        return AnimationTransformResult(
          scale: t,
          rotationDegrees: (1.0 - t) * 360.0 * intensity,
          opacity: t.clamp(0.0, 1.0),
        );
      case 'spin_out':
        return AnimationTransformResult(
          scale: (1.0 - t).clamp(0.0, 1.0),
          rotationDegrees: t * 360.0 * intensity,
          opacity: (1.0 - t).clamp(0.0, 1.0),
        );
      case 'spiral_in':
        // Spiral Swirl In: Rotasi tajam 720 derajat + scale membesar dari poros tengah
        return AnimationTransformResult(
          scale: (t * t).clamp(0.05, 1.0),
          rotationDegrees: -(1.0 - t) * 720.0 * intensity,
          opacity: (t * 2.0).clamp(0.0, 1.0),
        );
      case 'spiral_out':
        // Spiral Swirl Out: Rotasi berpusar ke pusat sambil mengecil ke nol
        return AnimationTransformResult(
          scale: (1.0 - t).clamp(0.0, 1.0),
          rotationDegrees: t * 720.0 * intensity,
          opacity: (1.0 - t).clamp(0.0, 1.0),
        );

      // 11. VENETIAN BLINDS & CURTAINS
      case 'blinds_horizontal':
      case 'basic_venetian_blinds_horiz':
        return AnimationTransformResult(
          clipShape: AnimationClipShape.blinds,
          clipProgress: t.clamp(0.0, 1.0),
          opacity: 1.0,
        );
      case 'blinds_vertical':
      case 'basic_venetian_blinds_vert':
        return AnimationTransformResult(
          clipShape: AnimationClipShape.blindsVertical,
          clipProgress: t.clamp(0.0, 1.0),
          opacity: 1.0,
        );
      case 'curtain_open':
        // Dua tirai panggung membuka dari tengah ke kiri dan kanan
        return AnimationTransformResult(
          clipShape: AnimationClipShape.curtain,
          clipProgress: t.clamp(0.0, 1.0),
          opacity: 1.0,
        );
      case 'curtain_close':
        // Dua sisi tirai menutup dari kiri dan kanan menuju garis tengah
        return AnimationTransformResult(
          clipShape: AnimationClipShape.curtainClose,
          clipProgress: t.clamp(0.0, 1.0),
          opacity: 1.0,
        );

      // 12. SPLIT EFFECTS
      case 'split_horizontal_in':
      case 'basic_center_split_horizontal':
        return AnimationTransformResult(
          clipShape: AnimationClipShape.splitHorizontal,
          clipProgress: t.clamp(0.0, 1.0),
          opacity: 1.0,
        );
      case 'split_horizontal_out':
        return AnimationTransformResult(
          clipShape: AnimationClipShape.splitHorizontal,
          clipProgress: (1.0 - t).clamp(0.0, 1.0),
          opacity: 1.0,
        );
      case 'split_vertical_in':
      case 'basic_center_split_vertical':
        return AnimationTransformResult(
          clipShape: AnimationClipShape.splitVertical,
          clipProgress: t.clamp(0.0, 1.0),
          opacity: 1.0,
        );
      case 'split_vertical_out':
        return AnimationTransformResult(
          clipShape: AnimationClipShape.splitVertical,
          clipProgress: (1.0 - t).clamp(0.0, 1.0),
          opacity: 1.0,
        );

      // 13. BOUNCE, POP & ELASTIC (Overshoot + Rebound + Settle)
      case 'elastic_pop':
        // Lenturan elastis memantul lembut (overshoot 1.15x -> settle 1.0x)
        final popScale = t < 0.7
            ? (t / 0.7) * 1.18 * intensity
            : 1.18 - ((t - 0.7) / 0.3) * 0.18;
        return AnimationTransformResult(
          scale: popScale.clamp(0.1, 1.3),
          opacity: (t * 2.5).clamp(0.0, 1.0),
        );
      case 'scale_snap_in':
        // Snap skala dari ukuran raksasa ke normal dengan hentakan cepat
        final snapScale = 1.6 - (math.pow(t, 2.5) * 0.6 * intensity);
        return AnimationTransformResult(
          scale: snapScale.clamp(1.0, 1.8),
          opacity: (t * 2.0).clamp(0.0, 1.0),
        );
      case 'scale_snap_out':
        // Snap skala meledak keluar seketika
        final snapOutScale = 1.0 + (math.pow(t, 2.0) * 0.8 * intensity);
        return AnimationTransformResult(
          scale: snapOutScale,
          opacity: (1.0 - t).clamp(0.0, 1.0),
        );
      case 'bounce_in_down':
        // Jatuh memantul dari atas layar: Overshoot -> Rebound -> Settle
        double bY = 0.0;
        if (t < 0.45) {
          bY = -(1.0 - (t / 0.45)) * 1.2;
        } else if (t < 0.75) {
          final sub = (t - 0.45) / 0.3;
          bY = math.sin(sub * math.pi) * 0.22 * intensity;
        } else {
          final sub = (t - 0.75) / 0.25;
          bY = -math.sin(sub * math.pi) * 0.08 * intensity;
        }
        return AnimationTransformResult(
          positionY: bY,
          opacity: (t * 2.0).clamp(0.0, 1.0),
        );
      case 'bounce_in_up':
        // Terlempar memantul dari bawah layar
        double bY = 0.0;
        if (t < 0.45) {
          bY = (1.0 - (t / 0.45)) * 1.2;
        } else if (t < 0.75) {
          final sub = (t - 0.45) / 0.3;
          bY = -math.sin(sub * math.pi) * 0.22 * intensity;
        } else {
          final sub = (t - 0.75) / 0.25;
          bY = math.sin(sub * math.pi) * 0.08 * intensity;
        }
        return AnimationTransformResult(
          positionY: bY,
          opacity: (t * 2.0).clamp(0.0, 1.0),
        );
      case 'bounce_out_down':
        // Jatuh memantul keluar ke bawah layar
        final bOutY = math.pow(t, 2.2).toDouble() * 1.2 * intensity;
        return AnimationTransformResult(
          positionY: bOutY,
          opacity: (1.0 - t).clamp(0.0, 1.0),
        );
      // 14. FLASH & SPECIAL FADES (BATCH 4)
      case 'flash_fade_in':
        // Memudar masuk diawali kilatan cahaya putih terang
        final fInLight = math.pow(1.0 - t, 2.0).toDouble() * 0.9 * intensity;
        return AnimationTransformResult(
          opacity: t.clamp(0.0, 1.0),
          flashOpacity: fInLight.clamp(0.0, 1.0),
        );
      case 'flash_fade_out':
        // Memudar keluar diawali ledakan flash terang
        final fOutLight = math.pow(t, 2.0).toDouble() * 0.9 * intensity;
        return AnimationTransformResult(
          opacity: (1.0 - t).clamp(0.0, 1.0),
          flashOpacity: fOutLight.clamp(0.0, 1.0),
        );
      case 'basic_fade_through_black':
        // Transisi meredup ke hitam penuh di tengah (t=0.5) lalu kembali terang
        final bAlpha = t < 0.5 ? (t * 2.0) : ((1.0 - t) * 2.0);
        return AnimationTransformResult(
          colorOverlayOpacity: bAlpha.clamp(0.0, 1.0),
          colorOverlayValue: 0xFF000000,
          opacity: 1.0,
        );
      case 'basic_fade_through_white':
        // Transisi memutih penuh di tengah (t=0.5) lalu normal kembali
        final wAlpha = t < 0.5 ? (t * 2.0) : ((1.0 - t) * 2.0);
        return AnimationTransformResult(
          colorOverlayOpacity: wAlpha.clamp(0.0, 1.0),
          colorOverlayValue: 0xFFFFFFFF,
          opacity: 1.0,
        );

      // 15. CENTER EXPAND / SHRINK & BOX ZOOM
      case 'center_expand':
      case 'basic_box_zoom_in':
        // Melebar simetris dari titik tengah dengan pembesaran skala
        final ceScale = 0.3 + (t * 0.7 * intensity);
        return AnimationTransformResult(
          scale: ceScale.clamp(0.1, 1.0),
          opacity: (t * 2.0).clamp(0.0, 1.0),
        );
      case 'center_shrink':
      case 'basic_box_zoom_out':
        // Mengecil simetris ke titik tengah
        final csScale = 1.0 - (t * 0.75 * intensity);
        return AnimationTransformResult(
          scale: csScale.clamp(0.05, 1.0),
          opacity: (1.0 - t).clamp(0.0, 1.0),
        );

      // 16. SKEW SLIDE (Jajar genjang dinamis)
      case 'skew_slide_in':
        return AnimationTransformResult(
          positionX: -(1.0 - t) * 1.1 * intensity,
          rotateYDegrees: -(1.0 - t) * 28.0 * intensity,
          opacity: (t * 2.0).clamp(0.0, 1.0),
        );
      case 'skew_slide_out':
        return AnimationTransformResult(
          positionX: t * 1.1 * intensity,
          rotateYDegrees: t * 28.0 * intensity,
          opacity: (1.0 - t).clamp(0.0, 1.0),
        );

      // 17. CORNER GROW (TL, TR, BL, BR) & CORNER PIN
      case 'corner_grow_tl':
        return AnimationTransformResult(
          positionX: -(1.0 - t) * 0.5 * intensity,
          positionY: -(1.0 - t) * 0.5 * intensity,
          scale: 0.2 + (t * 0.8 * intensity),
          opacity: (t * 2.0).clamp(0.0, 1.0),
        );
      case 'corner_grow_tr':
        return AnimationTransformResult(
          positionX: (1.0 - t) * 0.5 * intensity,
          positionY: -(1.0 - t) * 0.5 * intensity,
          scale: 0.2 + (t * 0.8 * intensity),
          opacity: (t * 2.0).clamp(0.0, 1.0),
        );
      case 'corner_grow_bl':
        return AnimationTransformResult(
          positionX: -(1.0 - t) * 0.5 * intensity,
          positionY: (1.0 - t) * 0.5 * intensity,
          scale: 0.2 + (t * 0.8 * intensity),
          opacity: (t * 2.0).clamp(0.0, 1.0),
        );
      case 'corner_grow_br':
        return AnimationTransformResult(
          positionX: (1.0 - t) * 0.5 * intensity,
          positionY: (1.0 - t) * 0.5 * intensity,
          scale: 0.2 + (t * 0.8 * intensity),
          opacity: (t * 2.0).clamp(0.0, 1.0),
        );
      case 'basic_corner_pin_in':
        return AnimationTransformResult(
          clipShape: AnimationClipShape.cornerPin,
          clipProgress: t.clamp(0.0, 1.0),
          opacity: 1.0,
        );

      // 18. CROSS ZOOM & CROSS SCALE
      case 'cross_zoom_in':
        final cziScale =
            0.5 +
            (t * 0.5 * intensity) +
            (math.sin(t * math.pi) * 0.12 * intensity);
        final cziBlur = (math.sin(t * math.pi) * 8.0 * intensity);
        return AnimationTransformResult(
          scale: cziScale,
          blurRadius: cziBlur,
          opacity: (t * 2.0).clamp(0.0, 1.0),
        );
      case 'cross_zoom_out':
        final czoScale =
            1.0 +
            (t * 0.6 * intensity) +
            (math.sin(t * math.pi) * 0.15 * intensity);
        final czoBlur = (math.sin(t * math.pi) * 8.0 * intensity);
        return AnimationTransformResult(
          scale: czoScale,
          blurRadius: czoBlur,
          opacity: (1.0 - t).clamp(0.0, 1.0),
        );
      case 'basic_cross_scale_dissolve':
        final csdScale = 0.92 + (t * 0.08 * intensity);
        return AnimationTransformResult(
          scale: csdScale,
          opacity: t.clamp(0.0, 1.0),
        );
      case 'basic_cross_scale_pop':
        final cspScale = t < 0.6
            ? 0.3 + (t / 0.6) * 0.85
            : 1.15 - ((t - 0.6) / 0.4) * 0.15;
        return AnimationTransformResult(
          scale: cspScale,
          opacity: (t * 2.0).clamp(0.0, 1.0),
        );

      // 19. DIAGONAL PUSH SLIDES (4 Sudut)
      case 'basic_push_slide_top_right':
        return AnimationTransformResult(
          positionX: (1.0 - t) * 1.0 * intensity,
          positionY: -(1.0 - t) * 1.0 * intensity,
          opacity: 1.0,
        );
      case 'basic_push_slide_bottom_left':
        return AnimationTransformResult(
          positionX: -(1.0 - t) * 1.0 * intensity,
          positionY: (1.0 - t) * 1.0 * intensity,
          opacity: 1.0,
        );
      case 'basic_push_slide_top_left':
        return AnimationTransformResult(
          positionX: -(1.0 - t) * 1.0 * intensity,
          positionY: -(1.0 - t) * 1.0 * intensity,
          opacity: 1.0,
        );
      case 'basic_push_slide_bottom_right':
        return AnimationTransformResult(
          positionX: (1.0 - t) * 1.0 * intensity,
          positionY: (1.0 - t) * 1.0 * intensity,
          opacity: 1.0,
        );

      // 20. DISSOLVE VARIATIONS & GAUSSIAN BLEND
      case 'basic_cross_dissolve_soft':
        final softCurve = math.pow(t, 1.6).toDouble();
        return AnimationTransformResult(opacity: softCurve.clamp(0.0, 1.0));
      case 'basic_cross_dissolve_sharp':
        // Linier tajam
        return AnimationTransformResult(opacity: t.clamp(0.0, 1.0));
      case 'basic_gaussian_fade_blend':
        final gBlur = (1.0 - t) * 16.0 * intensity;
        return AnimationTransformResult(
          opacity: t.clamp(0.0, 1.0),
          blurRadius: gBlur,
        );

      // 21. PAN & TILT / FLOAT COMBO ANIMATIONS
      case 'smooth_pan_left':
      case 'basic_smooth_pan_left_edge':
        final panX = (math.sin(t * math.pi * 2.0) * 0.12 * intensity);
        return AnimationTransformResult(positionX: panX, scale: 1.08);
      case 'smooth_pan_right':
      case 'basic_smooth_pan_right_edge':
        final panX = -(math.sin(t * math.pi * 2.0) * 0.12 * intensity);
        return AnimationTransformResult(positionX: panX, scale: 1.08);
      case 'smooth_tilt_up':
        final tiltY = -(math.sin(t * math.pi * 2.0) * 0.10 * intensity);
        return AnimationTransformResult(positionY: tiltY, scale: 1.08);
      case 'smooth_tilt_down':
        final tiltY = (math.sin(t * math.pi * 2.0) * 0.10 * intensity);
        return AnimationTransformResult(positionY: tiltY, scale: 1.08);
      case 'gentle_float':
        final fX = math.sin(t * math.pi * 2.0) * 0.04 * intensity;
        final fY = math.cos(t * math.pi * 2.0) * 0.04 * intensity;
        final fRot = math.sin(t * math.pi * 2.0) * 1.5 * intensity;
        return AnimationTransformResult(
          positionX: fX,
          positionY: fY,
          rotationDegrees: fRot,
          scale: 1.04,
        );
      case 'blur_in':
        return AnimationTransformResult(
          opacity: t,
          blurRadius: (1.0 - t) * 20.0 * intensity,
        );
      case 'blur_out':
        return AnimationTransformResult(
          opacity: 1.0 - t,
          blurRadius: t * 20.0 * intensity,
        );

      // --- LIGHT EFFECTS ---
      case 'light_leak':
        final flash = (math.sin(t * math.pi) * 0.8 * intensity).clamp(0.0, 1.0);
        return AnimationTransformResult(flashOpacity: flash);
      case 'glow':
      case 'neon_glow':
        final glow = ((math.sin(t * math.pi * 2.0) + 1.0) * 0.4 * intensity);
        return AnimationTransformResult(flashOpacity: glow);
      case 'lens_flare':
      case 'bloom':
        final flare = (math.sin(t * math.pi) * 0.75 * intensity);
        return AnimationTransformResult(flashOpacity: flare);
      case 'strobe':
        final strobe =
            ((math.sin(t * math.pi * 8.0) > 0.0) ? 0.8 : 0.0) * intensity;
        return AnimationTransformResult(flashOpacity: strobe);

      // --- GLITCH & RUSAK SINYAL (BATCH 1 & 2: 1-60 DELEGASI KE GLITCH SEMANTIC ENGINE) ---
      case 'rgb_split':
      case 'digital_glitch':
      case 'vhs_glitch':
      case 'scanlines':
      case 'pixel_sort_down':
      case 'pixel_sort_horizontal':
      case 'color_channel_offset':
      case 'block_displacement':
      case 'data_moshing':
      case 'frame_drop_glitch':
      case 'vhs_tracking_noise':
      case 'static_snow_noise':
      case 'analog_signal_drop':
      case 'interlaced_tear':
      case 'corrupted_ram':
      case 'chromatic_jitter':
      case 'glitch_flash_in':
      case 'glitch_flash_out':
      case 'horizontal_slice_tear':
      case 'vertical_sync_roll':
      case 'bad_antenna_ghost':
      case 'low_bitrate_chunky':
      case 'cyber_matrix_corruption':
      case 'tape_rewind_artifact':
      case 'bad_codec_stutter':
      case 'glitch_rgb_radial':
      case 'audio_sync_glitch':
      case 'neon_glitch_slice':
      case 'quantization_noise':
      case 'color_negative_glitch':
      case 'screen_flicker_60hz':
      case 'tape_pause_wobble':
      case 'glitch_dissolve':
      case 'hologram_breakdown':
      case 'satellite_feed_loss':
      case 'glitch_zoom_pop':
      case 'rgb_strobe_jitter':
      case 'digital_banding':
      case 'glitch_wave_warp':
      case 'tape_head_clog':
      case 'quantum_entangle_glitch':
      case 'circuit_short_spark':
      case 'lcd_pixel_dead':
      case 'buffer_overflow_junk':
      case 'vhs_color_bleed':
      case 'raster_beam_skew':
      case 'deep_fried_meme':
      case 'glitch_bounce_in':
      case 'glitch_drop_out':
      case 'wireframe_wire_tear':
      case 'glitch_scan_sweep':
      case 'sensor_overheat_noise':
      case 'broken_hdmi_sparkle':
      case 'packet_loss_drop':
      case 'neon_distortion_fuzz':
      case 'phosphor_ghost_trail':
      case 'anamorphic_glitch_streak':
      case 'cyber_stutter_step':
      case 'sub_zero_freeze_glitch':
      case 'rf_interference_moiré':
      // BATCH 3: 61 - 100
      case 'hologram_reboot_cycle':
      case 'chroma_phase_shift':
      case 'scan_frequency_drift':
      case 'digital_jitter_fast':
      case 'glitch_split_horiz':
      case 'tape_crinkle_wrinkle':
      case 'glitch_teleport_in':
      case 'glitch_teleport_out':
      case 'neural_corrupt_warp':
      case 'final_static_burst':
      case 'glitch_gpu_driver_crash':
      case 'glitch_buffer_overflow_smear':
      case 'glitch_sync_pulse_drop':
      case 'glitch_h264_macroblock_loss':
      case 'glitch_matrix_digital_rain_tear':
      case 'glitch_vram_memory_leak_artifact':
      case 'glitch_analog_demodulator_hum':
      case 'glitch_quantum_decoherence':
      case 'glitch_jpeg_spectral_artifact':
      case 'glitch_cracked_lcd_screen_bleed':
      case 'glitch_parity_check_error':
      case 'glitch_yuv_chroma_subsample_drop':
      case 'glitch_hdmi_handshake_failure':
      case 'glitch_satellite_uplink_loss':
      case 'glitch_corrupted_nvram_boot':
      case 'glitch_crt_degauss_coil_wobble':
      case 'glitch_rf_signal_cross_modulation':
      case 'glitch_mpeg2_transport_stream_tear':
      case 'glitch_digital_ghosting_echo':
      case 'glitch_interlaced_comb_artifact':
      case 'glitch_defective_ccd_sensor_line':
      case 'glitch_rolling_shutter_wobble':
      case 'glitch_static_discharge_spark':
      case 'glitch_audio_video_desync_flutter':
      case 'glitch_bit_rot_decay':
      case 'glitch_analog_tape_crease':
      case 'glitch_laserdisc_dropout_snow':
      case 'glitch_raster_beam_collapse':
      case 'glitch_color_burst_phase_jitter':
      case 'glitch_zero_day_malware_glitch':
        return GlitchSemanticEngine.evaluate(preset, t, intensity, type);

      // --- 3D ANIMATION REAL PERSPECTIVE ---
      case 'three_d_flip':
      case 'card_flip':
      case 'flip_horizontal_card':
        final isOut = type == AnimationApplicationType.outAnimation;
        final rotY = isOut
            ? -t * 90.0 * intensity
            : (1.0 - t) * 90.0 * intensity;
        final opac = isOut ? (1.0 - t).clamp(0.0, 1.0) : t.clamp(0.0, 1.0);
        return AnimationTransformResult(rotateYDegrees: rotY, opacity: opac);

      case 'flip_vertical_card':
        final isOut = type == AnimationApplicationType.outAnimation;
        final rotX = isOut
            ? t * 90.0 * intensity
            : -(1.0 - t) * 90.0 * intensity;
        final opac = isOut ? (1.0 - t).clamp(0.0, 1.0) : t.clamp(0.0, 1.0);
        return AnimationTransformResult(rotateXDegrees: rotX, opacity: opac);

      case 'cube_rotation':
      case 'box_turn_left':
        final isOut = type == AnimationApplicationType.outAnimation;
        final rotY = isOut
            ? 90.0 * t * intensity
            : -(1.0 - t) * 90.0 * intensity;
        final posX = isOut ? -0.4 * t * intensity : (1.0 - t) * 0.4 * intensity;
        return AnimationTransformResult(
          rotateYDegrees: rotY,
          positionX: posX,
          opacity: (isOut ? 1.0 - t : t).clamp(0.3, 1.0),
        );

      case 'box_turn_right':
        final isOut = type == AnimationApplicationType.outAnimation;
        final rotY = isOut
            ? -90.0 * t * intensity
            : (1.0 - t) * 90.0 * intensity;
        final posX = isOut ? 0.4 * t * intensity : -(1.0 - t) * 0.4 * intensity;
        return AnimationTransformResult(
          rotateYDegrees: rotY,
          positionX: posX,
          opacity: (isOut ? 1.0 - t : t).clamp(0.3, 1.0),
        );

      case 'box_turn_up':
        final isOut = type == AnimationApplicationType.outAnimation;
        final rotX = isOut
            ? 90.0 * t * intensity
            : -(1.0 - t) * 90.0 * intensity;
        final posY = isOut ? -0.4 * t * intensity : (1.0 - t) * 0.4 * intensity;
        return AnimationTransformResult(
          rotateXDegrees: rotX,
          positionY: posY,
          opacity: (isOut ? 1.0 - t : t).clamp(0.3, 1.0),
        );

      case 'box_turn_down':
        final isOut = type == AnimationApplicationType.outAnimation;
        final rotX = isOut
            ? -90.0 * t * intensity
            : (1.0 - t) * 90.0 * intensity;
        final posY = isOut ? 0.4 * t * intensity : -(1.0 - t) * 0.4 * intensity;
        return AnimationTransformResult(
          rotateXDegrees: rotX,
          positionY: posY,
          opacity: (isOut ? 1.0 - t : t).clamp(0.3, 1.0),
        );

      case 'door_swing_open':
        return AnimationTransformResult(
          rotateYDegrees: -(1.0 - t) * 80.0 * intensity,
          positionX: (1.0 - t) * 0.25 * intensity,
          opacity: t.clamp(0.0, 1.0),
        );

      case 'door_swing_close':
        return AnimationTransformResult(
          rotateYDegrees: t * -80.0 * intensity,
          positionX: -t * 0.25 * intensity,
          opacity: (1.0 - t).clamp(0.0, 1.0),
        );

      case 'carousel_rotate':
        return AnimationTransformResult(
          rotateYDegrees: math.sin(t * math.pi * 2.0) * 55.0 * intensity,
          scale: 0.96 + (math.cos(t * math.pi * 2.0).abs() * 0.08 * intensity),
        );

      case 'three_d_spin':
        return AnimationTransformResult(
          rotateYDegrees: (1.0 - t) * 180.0 * intensity,
          rotateXDegrees: (1.0 - t) * 45.0 * intensity,
          opacity: t.clamp(0.0, 1.0),
        );

      case 'perspective_zoom':
        // Real optical perspective dolly
        final fovScale = 1.0 + (math.sin(t * math.pi) * 0.2 * intensity);
        final rotP = math.sin(t * math.pi * 2.0) * 12.0 * intensity;
        return AnimationTransformResult(scale: fovScale, rotateXDegrees: rotP);

      // --- SHAKE / GETARAN (DELEGASI KE SHAKE SEMANTIC ENGINE) ---
      case 'camera_shake':
      case 'handheld_camera':
      case 'slight_sway':
      case 'shake_handheld_walk_steady':
      case 'shake_handheld_run_sprint':
      case 'horizontal_shake':
      case 'vertical_shake':
      case 'speed_wobble':
      case 'earthquake':
      case 'cinematic_quake':
      case 'shake_aftershock_rumble':
      case 'shake_seismic_wave_jolt':
      case 'shake_volcanic_tremor_pulse':
      case 'shake_deep_mine_cave_in':
      case 'heartbeat':
      case 'shake_heartbeat_panic_thump':
      case 'adrenaline_twitch':
      case 'punch_impact':
      case 'shake_boxing_cross_hit':
      case 'shake_karate_chop_break':
      case 'shake_wrestling_body_slam':
      case 'action_stumble':
      case 'shake_stumble_trip_fall':
      case 'impact_shake':
      case 'explosion_shockwave':
      case 'shake_grenade_blast_concussion':
      case 'shake_artillery_cannon_thud':
      case 'shake_sonic_boom_shockwave':
      case 'shake_sub_depth_charge_blast':
      case 'shake_thunder_crack_bump':
      case 'gunfire_recoil':
      case 'shake_shotgun_kickback_recoil':
      case 'shake_sniper_single_jolt':
      case 'extreme_jolt':
      case 'drop_impact':
      case 'shake_skate_drop_impact':
      case 'shake_car_crash_whiplash':
      case 'shake_heavy_club_drop':
      case 'shake_sledgehammer_strike':
      case 'shake_anvil_hammer_strike':
      case 'shake_bowling_strike_impact':
      case 'shake_heavy_vault_door_slam':
      case 'shake_heavy_iron_gate_clang':
      case 'shake_battering_ram_strike':
      case 'micro_jitter':
      case 'shake_jackhammer_rattle':
      case 'shake_pneumatic_drill_burst':
      case 'shake_diesel_generator_hum':
      case 'shake_hydraulic_press_crush':
      case 'shake_pile_driver_slam':
      case 'shake_demolition_wrecking_ball':
      case 'vehicle_engine_vibe':
      case 'shake_motorcycle_engine_idle':
      case 'shake_heavy_tank_tread':
      case 'rough_offroad':
      case 'shake_subway_rail_click_clack':
      case 'shake_formula_one_curb_hop':
      case 'shake_speed_bump_hit_hard':
      case 'shake_train_derail_tumbler':
      case 'shake_maglev_speed_pass':
      case 'shake_jet_engine_reverse_thrust':
      case 'turbulence_bump':
      case 'shake_helicopter_rotor_wash':
      case 'shake_speedboat_wake_bounce':
      case 'shake_boat_stormy_seas':
      case 'shake_paraglider_turbulence':
      case 'shake_aircraft_carrier_catapult':
      case 'shake_wind_gust_buffet':
      case 'shake_parachute_canopy_pop':
      case 'heavy_rumble':
      case 'bass_boom_shake':
      case 'shake_subwoofer_heavy_pulse':
      case 'shake_heavy_bass_kick_drum':
      case 'shake_gong_deep_reverberation':
      case 'footstep_thud':
      case 'shake_giant_robot_footstep':
      case 'shake_rhino_charge_impact':
      case 'shake_stampede_ground_rumble':
      case 'shake_avalanche_tumble':
      case 'shake_space_rocket_launch':
      case 'shake_warp_drive_shudder':
      case 'shake_meteor_entry_buffeting':
      case 'shake_asteroid_crater_impact':
      case 'shake_elevator_cable_snap':
      case 'shake_bungee_cord_snapback':
      case 'shake_tsunami_surge_push':
      case 'shake_glacier_calving_splash':
      case 'shake_water_canon_blast':
      case 'shake_icebreaker_hull_ram':
      case 'shake_rollercoaster_wooden_rattle':
      case 'shake_bridge_cable_sway':
      case 'shake_monument_topple_crash':
      case 'shake_wrecking_crane_lurch':
      case 'shake_jackpot_coin_avalanche':
      case 'subtle_drift_shake':
      case 'glitch_shiver':
      case 'staccato_bounce':
      case 'wobble_wave':
      case 'pulse_jitter':
      case 'tremble_horror':
        return ShakeSemanticEngine.evaluate(preset, t, intensity, type);

      // --- COMBO LOOPS ---
      case 'pulse':
      case 'zoom_pulse':
        final p = (math.sin(t * math.pi * 2.0) * 0.1 * intensity);
        return AnimationTransformResult(scale: 1.0 + p);
      case 'floating':
        final fly = (math.sin(t * math.pi * 2.0) * 0.04 * intensity);
        return AnimationTransformResult(positionY: fly);
      case 'swing':
      case 'pendulum':
        final ang = (math.sin(t * math.pi * 2.0) * 8.0 * intensity);
        return AnimationTransformResult(rotationDegrees: ang);
      case 'breathing':
        final br = (math.sin(t * math.pi * 1.5) * 0.05 * intensity);
        return AnimationTransformResult(scale: 1.0 + br);

      default:
        return _evaluateDynamicPresetByCategory(preset, t, intensity, type);
    }
  }

  static AnimationTransformResult _evaluateDynamicPresetByCategory(
    String preset,
    double t,
    double intensity,
    AnimationApplicationType type,
  ) {
    final lower = preset.toLowerCase();

    // Nilai hash unik untuk setiap ID preset agar variasi parameter setiap efek selalu berbeda
    int seed = 5381;
    for (int i = 0; i < preset.length; i++) {
      seed = ((seed << 5) + seed) + preset.codeUnitAt(i);
    }
    final int uHash = seed.abs();
    final double var1 = ((uHash % 100) / 100.0); // 0.00 - 0.99
    final double var2 = (((uHash ~/ 100) % 100) / 100.0); // 0.00 - 0.99
    final double var3 = (((uHash ~/ 10000) % 100) / 100.0); // 0.00 - 0.99
    final int signX = (uHash % 2 == 0) ? 1 : -1;
    final int signY = ((uHash ~/ 2) % 2 == 0) ? 1 : -1;

    // 1. SHAKE & GETARAN (Guncangan frekuensi tinggi, gempa, hentakan)
    if (lower.contains('shake') ||
        lower.contains('rumble') ||
        lower.contains('jolt') ||
        lower.contains('quake') ||
        lower.contains('impact') ||
        lower.contains('rattle') ||
        lower.contains('concussion') ||
        lower.contains('shudder') ||
        lower.contains('tremor') ||
        lower.contains('buffet') ||
        lower.contains('thud') ||
        lower.contains('blast') ||
        lower.contains('stomp') ||
        lower.contains('clang') ||
        lower.contains('strike') ||
        lower.contains('twitch') ||
        lower.contains('wobble') ||
        lower.contains('jitter')) {
      double freq = 12.0 + (var1 * 22.0);
      double amp = (0.03 + (var2 * 0.06)) * intensity;
      final decay =
          (lower.contains('impact') ||
              lower.contains('blast') ||
              lower.contains('drop') ||
              lower.contains('shock'))
          ? math.exp(-t * 3.5)
          : 1.0;

      final sx =
          math.sin(t * math.pi * freq + var1 * 3.14) * amp * decay * signX;
      final sy =
          math.cos(t * math.pi * (freq * 0.9) + var2 * 3.14) *
          amp *
          decay *
          signY;
      final rot =
          math.sin(t * math.pi * (freq * 0.5)) *
          (var3 * 6.0) *
          intensity *
          decay;
      final flash =
          (lower.contains('blast') ||
                  lower.contains('gunfire') ||
                  lower.contains('shock')) &&
              t < 0.25
          ? (1.0 - (t / 0.25)) * 0.8 * intensity
          : 0.0;

      return AnimationTransformResult(
        positionX: sx,
        positionY: sy,
        rotationDegrees: rot,
        flashOpacity: flash,
        scale: 1.0 + (decay * (var1 * 0.08) * intensity),
      );
    }

    // 2. LIGHT & FLASH (Kilatan cahaya, suar, glow, pendaran neon)
    if (lower.contains('light') ||
        lower.contains('flash') ||
        lower.contains('flare') ||
        lower.contains('glow') ||
        lower.contains('strobe') ||
        lower.contains('streak') ||
        lower.contains('spark') ||
        lower.contains('leak') ||
        lower.contains('beam') ||
        lower.contains('aura') ||
        lower.contains('refract') ||
        lower.contains('rainbow') ||
        lower.contains('burst') ||
        lower.contains('luminance') ||
        lower.contains('sun') ||
        lower.contains('shimmer') ||
        lower.contains('glimmer') ||
        lower.contains('twinkle') ||
        lower.contains('neon') ||
        lower.contains('plasma') ||
        lower.contains('god_ray')) {
      double flash = 0.0;
      if (lower.contains('strobe') ||
          lower.contains('flicker') ||
          lower.contains('lightning')) {
        final strobeFreq = 8.0 + (var1 * 12.0);
        flash =
            ((math.sin(t * math.pi * strobeFreq) > 0.0) ? 0.85 : 0.0) *
            intensity;
      } else if (lower.contains('burst') ||
          lower.contains('bang') ||
          lower.contains('flash')) {
        flash =
            (math.pow((1.0 - t).clamp(0.0, 1.0), 2.5).toDouble()) *
            0.95 *
            intensity;
      } else {
        flash =
            (math.sin(t * math.pi * (1.0 + var1 * 2.0)).abs() * 0.7 + 0.1) *
            intensity;
      }

      final scalePulse =
          1.0 + (math.sin(t * math.pi * 2.0) * (var2 * 0.12) * intensity);
      final chrom = (0.01 + var3 * 0.05) * intensity;

      return AnimationTransformResult(
        flashOpacity: flash.clamp(0.0, 1.0),
        scale: scalePulse,
        chromaticAberration:
            (lower.contains('prism') ||
                lower.contains('rainbow') ||
                lower.contains('chroma'))
            ? chrom
            : 0.0,
      );
    }

    // 3. GLITCH (Distorsi piksel, pemisahan RGB, scanlines CRT)
    if (lower.contains('glitch') ||
        lower.contains('rgb') ||
        lower.contains('chroma') ||
        lower.contains('datamosh') ||
        lower.contains('pixel') ||
        lower.contains('tear') ||
        lower.contains('noise') ||
        lower.contains('scanline') ||
        lower.contains('vram') ||
        lower.contains('corrupt') ||
        lower.contains('comb') ||
        lower.contains('artifact') ||
        lower.contains('teleport') ||
        lower.contains('jitter') ||
        lower.contains('sync') ||
        lower.contains('drop') ||
        lower.contains('stutter') ||
        lower.contains('bad_')) {
      final step = ((t * (10.0 + var1 * 15.0)).floor() % 3 == 0);
      final shiftX = step
          ? math.sin(t * math.pi * 20.0 + var2) *
                (0.04 + var1 * 0.06) *
                intensity *
                signX
          : 0.0;
      final shiftY = step
          ? math.cos(t * math.pi * 18.0) *
                (0.02 + var2 * 0.03) *
                intensity *
                signY
          : 0.0;
      final split = (step ? 0.06 + (var3 * 0.06) : 0.015) * intensity;
      final scanline = (0.3 + (var2 * 0.6)) * intensity;

      return AnimationTransformResult(
        positionX: shiftX,
        positionY: shiftY,
        chromaticAberration: split,
        scanlineIntensity: scanline,
        scale: 1.0 + (step ? (var1 * 0.05) : 0.0),
      );
    }

    // 4. 3D & PERSPEKTIF SPASIAL (Rotasi spasial 3 dimensi nyata, perspektif, kubus, kedalaman Z)
    if (lower.contains('3d') ||
        lower.contains('threed') ||
        lower.contains('perspective') ||
        lower.contains('cube') ||
        lower.contains('orbit') ||
        lower.contains('tilt') ||
        lower.contains('pitch') ||
        lower.contains('yaw') ||
        lower.contains('roll') ||
        lower.contains('depth') ||
        lower.contains('spatial') ||
        lower.contains('helix') ||
        lower.contains('origami') ||
        lower.contains('tunnel') ||
        lower.contains('torus') ||
        lower.contains('sphere') ||
        lower.contains('tesseract') ||
        lower.contains('cylinder') ||
        lower.contains('door') ||
        lower.contains('flip') ||
        lower.contains('box') ||
        lower.contains('carousel') ||
        lower.contains('plane') ||
        lower.contains('prism') ||
        lower.contains('vortex') ||
        lower.contains('wormhole') ||
        lower.contains('flyby') ||
        lower.contains('matrix') ||
        lower.contains('isomet')) {
      final isOut = type == AnimationApplicationType.outAnimation;
      final isCombo = type == AnimationApplicationType.comboAnimation;
      final prog = isOut ? (1.0 - t) : t;

      double rotX = 0.0;
      double rotY = 0.0;
      double rotZ = 0.0;
      double posX = 0.0;
      double posY = 0.0;
      double scale = 1.0;
      double scaleX = 1.0;
      double scaleY = 1.0;

      final style = uHash % 6;
      if (style == 0) {
        // Rotasi Yaw 3D (Membalik horizontal berputar)
        rotY = isCombo
            ? math.sin(t * math.pi * 2.0) * (35.0 + var1 * 35.0) * intensity
            : (1.0 - prog) * (70.0 + var1 * 40.0) * intensity * signX;
        posX = math.sin(t * math.pi) * (0.1 + var2 * 0.2) * intensity * signX;
      } else if (style == 1) {
        // Rotasi Pitch 3D (Jungkir balik atas/bawah)
        rotX = isCombo
            ? math.cos(t * math.pi * 2.0) * (30.0 + var2 * 35.0) * intensity
            : -(1.0 - prog) * (70.0 + var2 * 40.0) * intensity * signY;
        posY = math.sin(t * math.pi) * (0.1 + var1 * 0.2) * intensity * signY;
      } else if (style == 2) {
        // 3D Skew & Origami Roll
        rotY = (1.0 - prog) * (45.0 + var1 * 40.0) * intensity * signX;
        scaleX = (0.3 + (prog * 0.7)).clamp(0.2, 1.0);
        rotZ = math.sin(t * math.pi) * (15.0 * var3) * intensity;
      } else if (style == 3) {
        // Tunnel / Vortex / Orbit Z
        rotZ = isCombo
            ? (t * 360.0 * (var1 > 0.5 ? 1 : -1))
            : (1.0 - prog) * 180.0 * intensity * signX;
        scale = isCombo
            ? 0.85 + (math.sin(t * math.pi * 2.0) * 0.2)
            : (0.2 + prog * 0.8);
        rotX = math.sin(t * math.pi * 2.0) * 20.0 * intensity;
      } else if (style == 4) {
        // Door swing & card pivot
        rotY = (1.0 - prog) * 85.0 * intensity * signX;
        posX = (1.0 - prog) * 0.3 * intensity * signX;
        rotX = (1.0 - prog) * 25.0 * intensity * signY;
      } else {
        // Polyhedral gem / 3D Tumble
        rotX =
            math.sin(t * math.pi * 2.0 + var1) *
            (40.0 + var2 * 30.0) *
            intensity;
        rotY =
            math.cos(t * math.pi * 2.0 + var2) *
            (40.0 + var3 * 30.0) *
            intensity;
        rotZ = math.sin(t * math.pi) * 15.0 * intensity * signX;
        scale = 0.9 + (math.cos(t * math.pi * 2.0) * 0.15 * intensity);
      }

      final opac = isCombo ? 1.0 : (prog * 1.5).clamp(0.0, 1.0);

      return AnimationTransformResult(
        scale: scale.clamp(0.3, 2.2),
        scaleX: scaleX,
        scaleY: scaleY,
        positionX: posX,
        positionY: posY,
        rotationDegrees: rotZ,
        rotateXDegrees: rotX,
        rotateYDegrees: rotY,
        opacity: opac,
      );
    }

    // 5. MOTION & KINETIC 2D (Kecepatan, whip pan, laju gerak, drone, elastic)
    if (lower.contains('motion') ||
        lower.contains('ramp') ||
        lower.contains('whip') ||
        lower.contains('kinetic') ||
        lower.contains('drone') ||
        lower.contains('dash') ||
        lower.contains('elastic') ||
        lower.contains('rubber') ||
        lower.contains('bounce') ||
        lower.contains('jelly') ||
        lower.contains('pan') ||
        lower.contains('dolly') ||
        lower.contains('sweep') ||
        lower.contains('slider') ||
        lower.contains('pedestal') ||
        lower.contains('speed') ||
        lower.contains('glide') ||
        lower.contains('sprint') ||
        lower.contains('drift') ||
        lower.contains('flow') ||
        lower.contains('undulat')) {
      final motionStyle = uHash % 5;
      double posX = 0.0;
      double posY = 0.0;
      double scale = 1.0;
      double scaleX = 1.0;
      double scaleY = 1.0;
      double rotZ = 0.0;

      if (motionStyle == 0) {
        // Horizontal Whip / Glide
        final whipProg = math.pow(t, 2.0).toDouble();
        posX =
            (lower.contains('left') || signX < 0 ? -whipProg : whipProg) *
            (0.4 + var1 * 0.4) *
            intensity;
      } else if (motionStyle == 1) {
        // Vertical Pedestal / Drop / Rise
        final riseProg = math.sin(t * math.pi * 2.0);
        posY = riseProg * (0.2 + var2 * 0.25) * intensity * signY;
      } else if (motionStyle == 2) {
        // Elastic Jelly Squash & Stretch
        final pulse =
            math.sin(t * math.pi * 4.0) * math.exp(-t * 1.8) * 0.3 * intensity;
        scaleX = 1.0 + pulse * (var1 > 0.5 ? 1 : -1);
        scaleY = 1.0 - pulse * (var1 > 0.5 ? 1 : -1);
      } else if (motionStyle == 3) {
        // Orbit Centrifugal & Swirl
        posX = math.sin(t * math.pi * 2.0) * (0.15 + var1 * 0.15) * intensity;
        posY = math.cos(t * math.pi * 2.0) * (0.15 + var2 * 0.15) * intensity;
        rotZ = math.sin(t * math.pi * 2.0) * 12.0 * intensity;
      } else {
        // Kinetic Zoom Pop Pulse
        scale =
            1.0 +
            (math.sin(t * math.pi * 3.0) * (0.1 + var3 * 0.2) * intensity);
      }

      return AnimationTransformResult(
        positionX: posX,
        positionY: posY,
        scale: scale.clamp(0.4, 2.2),
        scaleX: scaleX,
        scaleY: scaleY,
        rotationDegrees: rotZ,
        blurRadius:
            (lower.contains('dash') ||
                lower.contains('blur') ||
                lower.contains('whip'))
            ? 6.0 * intensity
            : 0.0,
      );
    }

    // 6. RETRO & VINTAGE (Flicker 8mm, derau pita analog, 16mm hum, nada lawas)
    if (lower.contains('retro') ||
        lower.contains('vintage') ||
        lower.contains('8mm') ||
        lower.contains('16mm') ||
        lower.contains('35mm') ||
        lower.contains('film') ||
        lower.contains('kodak') ||
        lower.contains('polaroid') ||
        lower.contains('technicolor') ||
        lower.contains('crt') ||
        lower.contains('vhs') ||
        lower.contains('sepia') ||
        lower.contains('monochrome') ||
        lower.contains('tape') ||
        lower.contains('gameboy') ||
        lower.contains('cga') ||
        lower.contains('amiga') ||
        lower.contains('super8')) {
      final flickerSpeed = 16.0 + (var1 * 16.0);
      final flicker =
          (math.sin(t * math.pi * flickerSpeed) *
          (0.05 + var2 * 0.08) *
          intensity);
      final jitterY =
          math.cos(t * math.pi * (flickerSpeed * 0.7)) *
          (0.01 + var3 * 0.02) *
          intensity;
      final rotWeave =
          math.sin(t * math.pi * 4.0) * (0.5 + var1 * 1.5) * intensity;

      return AnimationTransformResult(
        opacity: (0.92 + flicker).clamp(0.55, 1.0),
        positionY: jitterY,
        rotationDegrees: rotWeave,
        scanlineIntensity: (0.3 + var2 * 0.6) * intensity,
        flashOpacity: (var3 > 0.6)
            ? (flicker.abs() * 1.8).clamp(0.0, 0.8)
            : 0.0,
      );
    }

    // 7. CINEMATIC (Letterbox, dolly zoom, rack focus, hero reveal, slow push)
    if (lower.contains('cinema') ||
        lower.contains('letterbox') ||
        lower.contains('blockbuster') ||
        lower.contains('hero') ||
        lower.contains('vertigo') ||
        lower.contains('crane') ||
        lower.contains('noir') ||
        lower.contains('anamorphic') ||
        lower.contains('dramatic') ||
        lower.contains('scope') ||
        lower.contains('hollywood') ||
        lower.contains('cinematic')) {
      final cineStyle = uHash % 4;
      double scale = 1.0;
      double blur = 0.0;
      double posX = 0.0;
      double posY = 0.0;

      if (cineStyle == 0) {
        // Slow cinematic push in
        scale = 1.0 + (t * (0.15 + var1 * 0.2) * intensity);
      } else if (cineStyle == 1) {
        // Dramatic cinematic pull out
        scale = (1.25 + var2 * 0.15) - (t * (0.15 + var2 * 0.2) * intensity);
      } else if (cineStyle == 2) {
        // Dolly Zoom Vertigo (Scale & Pan shift)
        scale = 1.0 + math.sin(t * math.pi) * 0.25 * intensity;
        blur = (math.cos(t * math.pi).abs() * 3.0 * intensity);
      } else {
        // Crane Sweep Pan
        posX = (t - 0.5) * (0.2 + var1 * 0.2) * intensity * signX;
        posY = math.sin(t * math.pi) * (0.08 * var2) * intensity;
        scale = 1.08;
      }

      return AnimationTransformResult(
        scale: scale.clamp(0.6, 2.0),
        positionX: posX,
        positionY: posY,
        blurRadius: blur,
        opacity: (0.8 + (t * 0.2)).clamp(0.7, 1.0),
      );
    }

    // 8. BASIC & GEOMETRIC TRANSITIONS (Fade, slide, zoom, spin, wipe, split, iris, blinds, checkerboard)
    AnimationClipShape shape = AnimationClipShape.none;
    if (lower.contains('circle') ||
        lower.contains('iris_circle') ||
        (lower.contains('iris') && !lower.contains('diamond'))) {
      shape = AnimationClipShape.circleIris;
    } else if (lower.contains('diamond')) {
      shape = AnimationClipShape.diamondIris;
    } else if (lower.contains('wipe')) {
      if (lower.contains('right')) {
        shape = AnimationClipShape.wipeRight;
      } else if (lower.contains('up') || lower.contains('top')) {
        shape = AnimationClipShape.wipeUp;
      } else if (lower.contains('down') || lower.contains('bottom')) {
        shape = AnimationClipShape.wipeDown;
      } else {
        shape = AnimationClipShape.wipeLeft;
      }
    } else if (lower.contains('blind')) {
      shape = AnimationClipShape.blinds;
    } else if (lower.contains('split') ||
        lower.contains('buka_tengah') ||
        lower.contains('curtain')) {
      shape = lower.contains('vertical')
          ? AnimationClipShape.splitVertical
          : AnimationClipShape.splitHorizontal;
    }

    if (type == AnimationApplicationType.inAnimation) {
      if (shape != AnimationClipShape.none) {
        final isCloseType = lower.contains('close') || lower.contains('tutup');
        final clipProg = isCloseType ? (1.0 - t) : t;
        return AnimationTransformResult(
          clipShape: shape,
          clipProgress: clipProg.clamp(0.0, 1.0),
          opacity: 1.0,
          scale: 1.0,
        );
      } else if (lower.contains('slide')) {
        final dir = lower.contains('left')
            ? -1.0
            : (lower.contains('right')
                  ? 1.0
                  : (lower.contains('up') ? -1.0 : 1.0));
        return lower.contains('up') || lower.contains('down')
            ? AnimationTransformResult(
                positionY: (1.0 - t) * dir * intensity,
                opacity: t.clamp(0.0, 1.0),
                scale: 1.0,
              )
            : AnimationTransformResult(
                positionX: (1.0 - t) * dir * intensity,
                opacity: t.clamp(0.0, 1.0),
                scale: 1.0,
              );
      } else if (lower.contains('spin')) {
        return AnimationTransformResult(
          rotationDegrees: (1.0 - t) * 360.0 * intensity * signX,
          opacity: t.clamp(0.0, 1.0),
          scale: 1.0,
        );
      } else if (lower.contains('blur')) {
        return AnimationTransformResult(
          blurRadius: (1.0 - t) * 20.0 * intensity,
          opacity: t.clamp(0.0, 1.0),
          scale: 1.0,
        );
      } else if (lower.contains('zoom')) {
        final initialScale = lower.contains('out') ? 1.3 : 0.75;
        return AnimationTransformResult(
          scale: initialScale + (t * (1.0 - initialScale) * intensity),
          opacity: t.clamp(0.0, 1.0),
        );
      } else {
        return AnimationTransformResult(opacity: t.clamp(0.0, 1.0), scale: 1.0);
      }
    } else if (type == AnimationApplicationType.outAnimation) {
      if (shape != AnimationClipShape.none) {
        final isOpenType = lower.contains('open') || lower.contains('buka');
        final clipProg = isOpenType ? t : (1.0 - t);
        return AnimationTransformResult(
          clipShape: shape,
          clipProgress: clipProg.clamp(0.0, 1.0),
          opacity: (1.0 - (t * 0.3)).clamp(0.0, 1.0),
          scale: 1.0,
        );
      } else if (lower.contains('slide')) {
        final dir = lower.contains('left')
            ? -1.0
            : (lower.contains('right')
                  ? 1.0
                  : (lower.contains('up') ? -1.0 : 1.0));
        return lower.contains('up') || lower.contains('down')
            ? AnimationTransformResult(
                positionY: t * dir * intensity,
                opacity: (1.0 - t).clamp(0.0, 1.0),
                scale: 1.0,
              )
            : AnimationTransformResult(
                positionX: t * dir * intensity,
                opacity: (1.0 - t).clamp(0.0, 1.0),
                scale: 1.0,
              );
      } else if (lower.contains('spin')) {
        return AnimationTransformResult(
          rotationDegrees: t * 360.0 * intensity * signX,
          opacity: (1.0 - t).clamp(0.0, 1.0),
          scale: 1.0,
        );
      } else if (lower.contains('blur')) {
        return AnimationTransformResult(
          blurRadius: t * 20.0 * intensity,
          opacity: (1.0 - t).clamp(0.0, 1.0),
          scale: 1.0,
        );
      } else if (lower.contains('zoom')) {
        final targetScale = lower.contains('in') ? 1.3 : 0.75;
        return AnimationTransformResult(
          scale: 1.0 + (t * (targetScale - 1.0) * intensity),
          opacity: (1.0 - t).clamp(0.0, 1.0),
        );
      } else {
        return AnimationTransformResult(
          opacity: (1.0 - t).clamp(0.0, 1.0),
          scale: 1.0,
        );
      }
    } else {
      // COMBO / LOOP
      if (shape != AnimationClipShape.none) {
        final wave = (math.sin(t * math.pi * 2.0) * 0.5 + 0.5);
        return AnimationTransformResult(
          clipShape: shape,
          clipProgress: (0.3 + (wave * 0.7)).clamp(0.0, 1.0),
          scale: 1.0,
        );
      }
      // Dapatkan variasi unik per-item combo yang tidak monoton
      final loopStyle = uHash % 4;
      if (loopStyle == 0) {
        final p =
            (math.sin(t * math.pi * 2.0) * (0.05 + var1 * 0.08) * intensity);
        return AnimationTransformResult(scale: 1.0 + p);
      } else if (loopStyle == 1) {
        final fly =
            (math.sin(t * math.pi * 2.0) * (0.03 + var2 * 0.05) * intensity) *
            signY;
        return AnimationTransformResult(positionY: fly, scale: 1.0);
      } else if (loopStyle == 2) {
        final ang =
            (math.sin(t * math.pi * 2.0) * (4.0 + var3 * 8.0) * intensity) *
            signX;
        return AnimationTransformResult(rotationDegrees: ang, scale: 1.0);
      } else {
        final posX =
            (math.sin(t * math.pi * 2.0) * (0.04 + var1 * 0.05) * intensity) *
            signX;
        return AnimationTransformResult(positionX: posX, scale: 1.0);
      }
    }
  }

  /// Menghasilkan FFmpeg filter string untuk rendering video ekspor
  String buildFFmpegFilter({
    required double clipDuration,
    int? videoWidth,
    int? videoHeight,
  }) {
    if (!hasAnimation) return '';

    final animDur = duration.clamp(0.1, clipDuration);
    final startOut = (clipDuration - animDur).clamp(0.0, clipDuration);

    switch (presetId) {
      // 1. Fades & Dissolves
      case 'fade_in':
      case 'cross_dissolve':
      case 'basic_cross_dissolve_soft':
      case 'basic_cross_dissolve_sharp':
      case 'basic_cross_scale_dissolve':
      case 'trending_fade_in_cinematic':
        return 'fade=t=in:st=$delay:d=$animDur';
      case 'fade_out':
        return 'fade=t=out:st=$startOut:d=$animDur';
      case 'dip_to_black':
      case 'basic_fade_through_black':
        return "drawbox=x=0:y=0:w=iw:h=ih:color=black:t=fill:enable='between(t\\,$startOut\\,${startOut + animDur})'";
      case 'dip_to_white':
      case 'basic_fade_through_white':
      case 'flash_fade_in':
      case 'flash_fade_out':
        return "drawbox=x=0:y=0:w=iw:h=ih:color=white@0.8:t=fill:enable='between(t\\,$delay\\,${delay + animDur * 0.4})'";

      // 2. Zooms & Pops
      // Zoom memakai crop statis + fade, bukan zoompan: zoompan selalu
      // memaksa resolusi 1280x720 dan 25 fps sehingga klip memanjang dan
      // desinkron dengan audio. Crop menjaga durasi serta rasio asli.
      case 'zoom_in':
      case 'zoom_burst':
      case 'center_expand':
      case 'basic_box_zoom_in':
      case 'cross_zoom_in':
      case 'elastic_pop':
      case 'basic_cross_scale_pop':
      case 'scale_snap_in':
        return "crop=w='trunc(in_w*0.92/2)*2':h='trunc(in_h*0.92/2)*2':"
            "x='(in_w-out_w)/2':y='(in_h-out_h)/2',"
            "fade=t=in:st=$delay:d=$animDur";
      case 'zoom_out':
      case 'center_shrink':
      case 'basic_box_zoom_out':
      case 'cross_zoom_out':
      case 'scale_snap_out':
        return "crop=w='trunc(in_w*0.92/2)*2':h='trunc(in_h*0.92/2)*2':"
            "x='(in_w-out_w)/2':y='(in_h-out_h)/2',"
            "fade=t=out:st=$startOut:d=$animDur";

      // 3. Slides & Pushes
      // Pad + crop menjaga filter tetap valid untuk dimensi sumber apa pun.
      // Sebelumnya crop memakai lebar/tinggi target (mis. 1080x1920) sehingga
      // ekspor video landscape gagal total.
      case 'slide_in_left':
      case 'push_right':
      case 'trending_slide_left_fast':
      case 'skew_slide_in':
        return "pad=w='iw*1.5':h='ih*1.5':x='iw*0.25':y='ih*0.25':color=black,"
            "crop=w='in_w/1.5':h='in_h/1.5':"
            "x='(in_w-out_w)*(1.0-0.5*min((t-$delay)/$animDur,1.0))':"
            "y='(in_h-out_h)/2'";
      case 'slide_in_right':
      case 'push_left':
        return "pad=w='iw*1.5':h='ih*1.5':x='iw*0.25':y='ih*0.25':color=black,"
            "crop=w='in_w/1.5':h='in_h/1.5':"
            "x='(in_w-out_w)*0.5*min((t-$delay)/$animDur,1.0)':"
            "y='(in_h-out_h)/2'";
      case 'slide_in_top':
      case 'push_down':
      case 'bounce_in_down':
        return "pad=w='iw*1.5':h='ih*1.5':x='iw*0.25':y='ih*0.25':color=black,"
            "crop=w='in_w/1.5':h='in_h/1.5':x='(in_w-out_w)/2':"
            "y='(in_h-out_h)*(1.0-0.5*min((t-$delay)/$animDur,1.0))'";
      case 'slide_in_bottom':
      case 'push_up':
      case 'bounce_in_up':
        return "pad=w='iw*1.5':h='ih*1.5':x='iw*0.25':y='ih*0.25':color=black,"
            "crop=w='in_w/1.5':h='in_h/1.5':x='(in_w-out_w)/2':"
            "y='(in_h-out_h)*0.5*min((t-$delay)/$animDur,1.0)'";
      case 'slide_out_left':
        return "pad=w='iw*1.5':h='ih*1.5':x='iw*0.25':y='ih*0.25':color=black,"
            "crop=w='in_w/1.5':h='in_h/1.5':"
            "x='(in_w-out_w)*(0.5+0.5*min((t-$startOut)/$animDur,1.0))':"
            "y='(in_h-out_h)/2'";
      case 'slide_out_right':
        return "pad=w='iw*1.5':h='ih*1.5':x='iw*0.25':y='ih*0.25':color=black,"
            "crop=w='in_w/1.5':h='in_h/1.5':"
            "x='(in_w-out_w)*(0.5-0.5*min((t-$startOut)/$animDur,1.0))':"
            "y='(in_h-out_h)/2'";
      case 'slide_out_top':
        return "pad=w='iw*1.5':h='ih*1.5':x='iw*0.25':y='ih*0.25':color=black,"
            "crop=w='in_w/1.5':h='in_h/1.5':x='(in_w-out_w)/2':"
            "y='(in_h-out_h)*(0.5+0.5*min((t-$startOut)/$animDur,1.0))'";
      case 'slide_out_bottom':
      case 'bounce_out_down':
        return "pad=w='iw*1.5':h='ih*1.5':x='iw*0.25':y='ih*0.25':color=black,"
            "crop=w='in_w/1.5':h='in_h/1.5':x='(in_w-out_w)/2':"
            "y='(in_h-out_h)*(0.5-0.5*min((t-$startOut)/$animDur,1.0))'";

      // 4. Spins & Rotations
      case 'spin_in':
      case 'spiral_in':
      case 'trending_spin_drop':
        return "rotate=a='(1.0-min((t-$delay)/$animDur,1.0))*2*PI*$intensity':c=black";
      case 'spin_out':
      case 'spiral_out':
        return "rotate=a='min((t-$startOut)/$animDur,1.0)*2*PI*$intensity':c=black";

      // 5. Blurs
      // gblur tidak mendukung ekspresi berbasis waktu, jadi blur dibuat
      // statis dan dipadukan dengan fade agar tetap menghasilkan transisi.
      case 'blur_in':
      case 'basic_gaussian_fade_blend':
        return "gblur=sigma='${15 * intensity}',fade=t=in:st=$delay:d=$animDur";
      case 'blur_out':
        return "gblur=sigma='${15 * intensity}',fade=t=out:st=$startOut:d=$animDur";
      case 'camera_push':
      case 'dynamic_zoom':
        return "crop=w='trunc(in_w*0.94/2)*2':h='trunc(in_h*0.94/2)*2':"
            "x='(in_w-out_w)/2':y='(in_h-out_h)/2',"
            "fade=t=in:st=$delay:d=$animDur";
      case 'camera_pull':
        return "crop=w='trunc(in_w*0.94/2)*2':h='trunc(in_h*0.94/2)*2':"
            "x='(in_w-out_w)/2':y='(in_h-out_h)/2',"
            "fade=t=out:st=$startOut:d=$animDur";
      case 'rgb_split':
      case 'chromatic_jitter':
      case 'glitch_rgb_radial':
        return 'split[main][tmp];[tmp]lutrgb=r=0:g=0[b];[main]lutrgb=b=0[rg];[rg][b]blend=all_mode=addition';
      case 'color_channel_offset':
        return 'split[main][tmp];[tmp]lutrgb=r=0[gb];[main]lutrgb=g=0:b=0[r];[r][gb]blend=all_mode=addition';
      case 'scanlines':
      case 'vhs_glitch':
      case 'vhs_tracking_noise':
        return 'drawgrid=w=iw:h=4:t=1:c=black@0.4';
      case 'color_negative_glitch':
        return 'negate';
      case 'interlaced_tear':
      case 'screen_flicker_60hz':
        return 'tinterlace=mode=interleave_top';
      case 'rgb_strobe_jitter':
      case 'vhs_color_bleed':
        return 'hue=s=2.0';
      case 'deep_fried_meme':
        return 'eq=contrast=2.5:saturation=3.0:brightness=0.1';
      case 'hologram_breakdown':
      case 'phosphor_ghost_trail':
        return 'colorchannelmixer=rr=0:gg=1.2:bb=0.5';
      case 'tape_pause_wobble':
      case 'tape_head_clog':
      case 'glitch_scan_sweep':
        return 'drawgrid=w=iw:h=8:t=1:c=white@0.3';
      case 'broken_hdmi_sparkle':
      case 'sensor_overheat_noise':
      case 'glitch_static_discharge_spark':
      case 'glitch_laserdisc_dropout_snow':
      case 'final_static_burst':
        return 'noise=c0s=20:allf=t+u';
      case 'chroma_phase_shift':
      case 'glitch_color_burst_phase_jitter':
      case 'glitch_yuv_chroma_subsample_drop':
        return 'hue=h=90:s=1.8';
      case 'glitch_raster_beam_collapse':
        return 'scale=iw:trunc(ih*0.5/2)*2,pad=w=iw:h=ih*2:x=0:y=ih/2:color=black';
      case 'glitch_matrix_digital_rain_tear':
      case 'glitch_zero_day_malware_glitch':
        return 'colorchannelmixer=rr=0.2:gg=1.4:bb=0.2';
      case 'glitch_interlaced_comb_artifact':
        return 'tinterlace=mode=interleave_top';
      case 'camera_shake':
      case 'horizontal_shake':
        return "pad=w='iw*1.2':h='ih*1.2':x='iw*0.1':y='ih*0.1':color=black,"
            "crop=w='in_w/1.2':h='in_h/1.2':"
            "x='(in_w-out_w)/2+10*sin(t*18)*$intensity':"
            "y='(in_h-out_h)/2+8*cos(t*16)*$intensity'";
      case 'vertical_shake':
        return "pad=w='iw*1.2':h='ih*1.2':x='iw*0.1':y='ih*0.1':color=black,"
            "crop=w='in_w/1.2':h='in_h/1.2':x='(in_w-out_w)/2':"
            "y='(in_h-out_h)/2+12*sin(t*20)*$intensity'";
      case 'flash_zoom':
        return "drawbox=x=0:y=0:w=iw:h=ih:color=white@0.6:t=fill:enable='between(t\\,$delay\\,${delay + animDur * 0.3})'";
      case 'heartbeat':
      case 'pulse':
        return "crop=w='trunc(in_w*0.94/2)*2':h='trunc(in_h*0.94/2)*2':"
            "x='(in_w-out_w)/2':y='(in_h-out_h)/2'";
      default:
        return '';
    }
  }
}
