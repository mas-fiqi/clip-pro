import '../models/animation_model.dart';
import 'animation_builtin_presets_data.dart';
import 'animation_presets_data.dart';

/// Tingkat dukungan sebuah preset animasi pada proses ekspor FFmpeg.
enum AnimationExportMode {
  /// Preset punya filter FFmpeg khusus (hasil ekspor paling dekat dengan preview).
  full,

  /// Preset tidak punya filter khusus, tetapi bisa didekati dengan filter
  /// keluarga animasi yang setara secara visual (mis. shake, zoom, flash).
  approximate,

  /// Belum ada padanan FFmpeg yang wajar (particle, mask, 3D kompleks).
  /// Animasi tetap tampil di preview, tetapi tidak ikut dirender saat ekspor.
  previewOnly,
}

class AnimationExportSupport {
  final AnimationExportMode mode;
  final String reason;

  const AnimationExportSupport(this.mode, this.reason);
}

/// Penentu dukungan ekspor untuk katalog animasi QuickClip Pro.
///
/// Sebelumnya `buildFFmpegFilter()` hanya mengenali sebagian preset dan
/// mengembalikan string kosong untuk sisanya, sehingga animasi tampil di
/// preview tetapi hilang pada video hasil ekspor tanpa pemberitahuan apa pun.
/// Service ini menutup celah tersebut dengan tiga tingkat dukungan di atas.
class AnimationExportSupportService {
  const AnimationExportSupportService._();

  /// Cek apakah preset hanya bisa dipakai di preview.
  static bool isPreviewOnly(AnimationPresetModel preset) =>
      resolve(preset).mode == AnimationExportMode.previewOnly;

  /// Tentukan mode ekspor sebuah preset.
  ///
  /// Deteksi filter eksplisit dilakukan dengan benar-benar memanggil
  /// `buildFFmpegFilter()`, sehingga daftar preset yang didukung selalu
  /// sinkron dengan implementasi di model — tidak ada daftar duplikat yang
  /// bisa basi.
  static AnimationExportSupport resolve(AnimationPresetModel preset) {
    final probe = ClipAnimationModel(
      presetId: preset.id,
      type: preset.type,
      duration: 1.0,
    );
    final explicitFilter = probe.buildFFmpegFilter(
      clipDuration: 5.0,
      videoWidth: 1080,
      videoHeight: 1920,
    );

    if (explicitFilter.isNotEmpty) {
      return const AnimationExportSupport(
        AnimationExportMode.full,
        'Filter ekspor khusus tersedia',
      );
    }

    final family = _familyFor(preset.category, '${preset.name} ${preset.id}');
    if (family == _ExportFamily.previewOnly) {
      return const AnimationExportSupport(
        AnimationExportMode.previewOnly,
        'Hanya preview — belum ada padanan FFmpeg yang setara',
      );
    }

    return AnimationExportSupport(
      AnimationExportMode.approximate,
      'Didekati dengan filter ${_familyLabel(family)} saat ekspor',
    );
  }

  /// Cari preset berdasarkan id pada katalog 800 animasi.
  static AnimationPresetModel? findPreset(String presetId) {
    for (final preset in AnimationBuiltinPresetsData.allPresets) {
      if (preset.id == presetId) return preset;
    }
    for (final preset in AnimationPresetsData.allPresets) {
      if (preset.id == presetId) return preset;
    }
    return null;
  }

  /// Bangun filter ekspor untuk sebuah animasi.
  ///
  /// Filter khusus (jika ada) selalu diutamakan. Jika tidak ada, filter
  /// perkiraan per keluarga animasi dipakai. String kosong hanya dikembalikan
  /// untuk preset yang memang ditandai `previewOnly`.
  static String buildExportFilter(
    ClipAnimationModel animation, {
    AnimationPresetModel? preset,
    required double clipDuration,
  }) {
    if (!animation.hasAnimation) return '';

    final explicit = animation.buildFFmpegFilter(
      clipDuration: clipDuration,
      videoWidth: 1080,
      videoHeight: 1920,
    );
    if (explicit.isNotEmpty) return explicit;

    final resolvedPreset = preset ?? findPreset(animation.presetId);
    final family = _familyFor(
      resolvedPreset?.category,
      '${resolvedPreset?.name ?? ''} ${animation.presetId}',
    );

    return _buildFamilyFilter(
      family,
      animation,
      clipDuration.clamp(0.1, double.infinity),
    );
  }

  static String _buildFamilyFilter(
    _ExportFamily family,
    ClipAnimationModel animation,
    double clipDuration,
  ) {
    final intensity = animation.intensity.clamp(0.1, 2.0);
    final animDur = animation.duration.clamp(0.1, clipDuration);
    final delay = animation.delay.clamp(0.0, clipDuration);
    final startOut = (clipDuration - animDur).clamp(0.0, clipDuration);
    final isOut = animation.type == AnimationApplicationType.outAnimation;

    switch (family) {
      case _ExportFamily.shake:
        // Guncangan kamera: crop bergoyang dengan margin aman, tanpa scale
        // karena pipeline utama sudah menormalkan resolusi di akhir.
        final ampX = _n(14 * intensity);
        final ampY = _n(10 * intensity);
        return "crop=w='in_w-80':h='in_h-80':"
            "x='40+$ampX*sin(t*18)':y='40+$ampY*cos(t*16)'";

      case _ExportFamily.pan:
        // Geser/pan halus di dalam frame (aman untuk semua rasio).
        return "crop=w='in_w*0.92':h='in_h*0.92':"
            "x='(in_w-out_w)*abs(sin(PI*t/$animDur))':"
            "y='(in_h-out_h)/2'";

      case _ExportFamily.zoom:
        // Crop statis dipilih daripada zoompan karena zoompan memaksa
        // resolusi/fps bawaan dan membuat durasi klip melar.
        final crop =
            "crop=w='trunc(in_w*0.92/2)*2':"
            "h='trunc(in_h*0.92/2)*2':"
            "x='(in_w-out_w)/2':y='(in_h-out_h)/2'";
        if (isOut) {
          return '$crop,fade=t=out:st=${_n(startOut)}:d=${_n(animDur)}';
        }
        if (animation.type == AnimationApplicationType.comboAnimation) {
          return crop;
        }
        return '$crop,fade=t=in:st=${_n(delay)}:d=${_n(animDur)}';

      case _ExportFamily.rotate:
        return "rotate=a='0.04*$intensity*sin(2*PI*t/$animDur)':c=black";

      case _ExportFamily.flash:
        final flashStart = isOut ? startOut : delay;
        final flashEnd =
            (flashStart + (animDur * 0.4).clamp(0.12, clipDuration)).clamp(
              0.0,
              clipDuration,
            );
        final startText = _n(flashStart);
        final endText = _n(flashEnd);
        return "drawbox=x=0:y=0:w=iw:h=ih:color=white@0.7:t=fill:"
            "enable='between(t\\,$startText\\,$endText)'";

      case _ExportFamily.glitch:
        return 'noise=c0s=12:allf=t+u,eq=contrast=1.15:saturation=1.25';

      case _ExportFamily.blur:
        return "gblur=sigma='${_n(3 * intensity)}'";

      case _ExportFamily.retroGrade:
        return 'eq=saturation=0.82:contrast=1.06:brightness=-0.01,vignette=PI/5';

      case _ExportFamily.cinematicGrade:
        return 'eq=saturation=0.9:contrast=1.1,vignette=PI/4';

      case _ExportFamily.fade:
        if (isOut) {
          return 'fade=t=out:st=${_n(startOut)}:d=${_n(animDur)}';
        }
        return 'fade=t=in:st=${_n(delay)}:d=${_n(animDur)}';

      case _ExportFamily.previewOnly:
        return '';
    }
  }

  /// Klasifikasi keluarga animasi. Kategori katalog menjadi sinyal utama,
  /// lalu nama/id dipakai untuk kategori campuran seperti `basic`.
  static _ExportFamily _familyFor(AnimationCategory? category, String text) {
    final haystack = text.toLowerCase();

    // Masking, partikel, dan 3D volumetrik butuh render multi-layer yang
    // tidak bisa direpresentasikan jujur oleh satu rantai filter FFmpeg.
    if (category == AnimationCategory.mask ||
        category == AnimationCategory.particle ||
        category == AnimationCategory.threeD) {
      return _ExportFamily.previewOnly;
    }

    if (category == AnimationCategory.shake) return _ExportFamily.shake;
    if (category == AnimationCategory.light) return _ExportFamily.flash;
    if (category == AnimationCategory.glitch) return _ExportFamily.glitch;
    if (category == AnimationCategory.blur) return _ExportFamily.blur;
    if (category == AnimationCategory.motion) return _ExportFamily.pan;
    if (category == AnimationCategory.retro) return _ExportFamily.retroGrade;
    if (category == AnimationCategory.cinematic) {
      return _ExportFamily.cinematicGrade;
    }

    // Keluarga yang secara struktur tidak bisa ditiru dengan crop/fade.
    if (_containsAny(haystack, const [
      'iris',
      'mask',
      'wipe',
      'blinds',
      'checkerboard',
      'curtain',
      'shatter',
      'particle',
      'confetti',
      'sparkle',
      'dust',
      'bokeh',
      'cube',
      'origami',
      'mirror',
      'door',
    ])) {
      return _ExportFamily.previewOnly;
    }

    if (_containsAny(haystack, const [
      'shake',
      'rumble',
      'jolt',
      'quake',
      'tremor',
      'rattle',
      'impact',
      'stomp',
      'thud',
      'blast',
      'earthquake',
      'vibrat',
    ])) {
      return _ExportFamily.shake;
    }

    if (_containsAny(haystack, const [
      'spin',
      'rotat',
      'twirl',
      'whirl',
      'roll',
      'tumble',
    ])) {
      return _ExportFamily.rotate;
    }

    if (_containsAny(haystack, const [
      'zoom',
      'scale',
      'pop',
      'punch',
      'expand',
      'shrink',
      'burst',
      'pulse',
      'breathe',
      'breathing',
      'magnif',
    ])) {
      return _ExportFamily.zoom;
    }

    if (_containsAny(haystack, const [
      'slide',
      'push',
      'pan',
      'sweep',
      'swipe',
      'drift',
      'glide',
      'track',
    ])) {
      return _ExportFamily.pan;
    }

    if (_containsAny(haystack, const [
      'flash',
      'glow',
      'strobe',
      'flare',
      'light',
      'leak',
      'aurora',
      'laser',
      'prism',
      'neon',
      'bloom',
    ])) {
      return _ExportFamily.flash;
    }

    if (_containsAny(haystack, const [
      'glitch',
      'vhs',
      'static',
      'rgb',
      'chroma',
      'scan',
      'tape',
      'hdmi',
      'digital',
      'jitter',
      'interference',
      'distort',
    ])) {
      return _ExportFamily.glitch;
    }

    if (_containsAny(haystack, const [
      'blur',
      'focus',
      'haze',
      'dream',
      'soft',
    ])) {
      return _ExportFamily.blur;
    }

    if (_containsAny(haystack, const [
      'retro',
      'vintage',
      'sepia',
      'film',
      'grain',
      'polaroid',
      '8mm',
      '16mm',
      'lomo',
      'analog',
    ])) {
      return _ExportFamily.retroGrade;
    }

    if (_containsAny(haystack, const [
      'cinematic',
      'anamorphic',
      'letterbox',
      'noir',
      'drama',
      'epic',
    ])) {
      return _ExportFamily.cinematicGrade;
    }

    // Fade adalah perilaku dasar yang paling aman dan paling tidak menipu
    // untuk kategori campuran (basic/trending) yang tidak cocok keyword lain.
    if (category == AnimationCategory.basic ||
        category == AnimationCategory.trending) {
      return _ExportFamily.fade;
    }

    return _ExportFamily.previewOnly;
  }

  static bool _containsAny(String haystack, List<String> needles) =>
      needles.any(haystack.contains);

  static String _familyLabel(_ExportFamily family) {
    switch (family) {
      case _ExportFamily.shake:
        return 'guncangan (crop jitter)';
      case _ExportFamily.pan:
        return 'geser (crop pan)';
      case _ExportFamily.zoom:
        return 'zoom';
      case _ExportFamily.rotate:
        return 'rotasi';
      case _ExportFamily.flash:
        return 'kilatan cahaya';
      case _ExportFamily.glitch:
        return 'glitch/noise';
      case _ExportFamily.blur:
        return 'blur';
      case _ExportFamily.retroGrade:
        return 'color grading retro';
      case _ExportFamily.cinematicGrade:
        return 'color grading sinematik';
      case _ExportFamily.fade:
        return 'fade';
      case _ExportFamily.previewOnly:
        return 'tanpa filter';
    }
  }

  /// Format angka agar ekspresi FFmpeg tetap ringkas dan tanpa notasi ilmiah.
  static String _n(double value) {
    final text = value.toStringAsFixed(3);
    return text
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}

enum _ExportFamily {
  shake,
  pan,
  zoom,
  rotate,
  flash,
  glitch,
  blur,
  retroGrade,
  cinematicGrade,
  fade,
  previewOnly,
}
