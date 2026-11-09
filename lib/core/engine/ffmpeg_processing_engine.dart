import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';

import '../models/animation_model.dart';
import '../services/animation_export_support.dart';
import '../models/audio_clip_model.dart';
import '../models/audio_effect_model.dart';
import '../models/benchmark_profile_model.dart';
import '../models/clip_model.dart';
import '../models/clip_transform_model.dart';
import '../models/color_adjustment_model.dart';
import '../models/export_config_model.dart';
import '../models/keyframe_model.dart';
import '../models/overlay_model.dart';
import '../models/quality_enhancement_model.dart';
import '../models/timeline_model.dart';
import '../models/video_effect_model.dart';
import '../services/device_capability_service.dart';
import '../services/smart_export_advisor.dart';
import '../utils/export_progress_calculator.dart';
import '../utils/time_formatter.dart';
import 'video_processing_engine.dart';

class FFmpegProcessingEngine implements VideoProcessingEngine {
  FFmpegSession? _currentSession;

  bool _isCancelled = false;

  @override
  Future<void> cancelSession() async {
    _isCancelled = true;
    if (_currentSession != null) {
      await FFmpegKit.cancel(_currentSession!.getSessionId());
      _currentSession = null;
    }
  }

  String _escapeFFmpegText(String text) {
    return text
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll(':', r'\:')
        .replaceAll('%', r'\%');
  }

  String _buildColorFilter(ColorAdjustmentModel adj) {
    final List<String> filters = [];
    final intensity = adj.filterIntensity.clamp(0.0, 1.0);

    if (intensity > 0.0) {
      switch (adj.preset) {
        // Natural
        case FilterPreset.naturalBright:
          final b = (0.05 * intensity).toStringAsFixed(2);
          final c = (1.0 + 0.1 * intensity).toStringAsFixed(2);
          filters.add('eq=brightness=$b:contrast=$c');
          break;
        case FilterPreset.fresh:
          final s = (1.0 + 0.15 * intensity).toStringAsFixed(2);
          final g = (1.0 + 0.08 * intensity).toStringAsFixed(2);
          filters.add('eq=saturation=$s:gamma_g=$g');
          break;

        // Warm
        case FilterPreset.warm:
          final gr = (1.0 + 0.2 * intensity).toStringAsFixed(2);
          final gb = (1.0 - 0.2 * intensity).toStringAsFixed(2);
          filters.add('eq=gamma_r=$gr:gamma_b=$gb');
          break;
        case FilterPreset.goldenHour:
          final gr = (1.0 + 0.25 * intensity).toStringAsFixed(2);
          final gg = (1.0 + 0.1 * intensity).toStringAsFixed(2);
          final gb = (1.0 - 0.25 * intensity).toStringAsFixed(2);
          filters.add('eq=gamma_r=$gr:gamma_g=$gg:gamma_b=$gb');
          break;
        case FilterPreset.sunset:
          final gr = (1.0 + 0.3 * intensity).toStringAsFixed(2);
          final gb = (1.0 - 0.1 * intensity).toStringAsFixed(2);
          filters.add('eq=gamma_r=$gr:gamma_b=$gb:contrast=1.1');
          break;

        // Cool
        case FilterPreset.cool:
          final gb = (1.0 + 0.2 * intensity).toStringAsFixed(2);
          final gr = (1.0 - 0.2 * intensity).toStringAsFixed(2);
          filters.add('eq=gamma_b=$gb:gamma_r=$gr');
          break;
        case FilterPreset.nordic:
          final gb = (1.0 + 0.25 * intensity).toStringAsFixed(2);
          final s = (1.0 - 0.15 * intensity).toStringAsFixed(2);
          filters.add('eq=gamma_b=$gb:saturation=$s');
          break;
        case FilterPreset.arctic:
          final gb = (1.0 + 0.35 * intensity).toStringAsFixed(2);
          final c = (1.0 + 0.15 * intensity).toStringAsFixed(2);
          filters.add('eq=gamma_b=$gb:contrast=$c');
          break;

        // Cinematic
        case FilterPreset.cinematic:
          final c = (1.0 + 0.2 * intensity).toStringAsFixed(2);
          final s = (1.0 + 0.1 * intensity).toStringAsFixed(2);
          filters.add('eq=contrast=$c:saturation=$s');
          break;
        case FilterPreset.tealAndOrange:
          final gr = (1.0 + 0.15 * intensity).toStringAsFixed(2);
          final gb = (1.0 + 0.2 * intensity).toStringAsFixed(2);
          final c = (1.0 + 0.15 * intensity).toStringAsFixed(2);
          filters.add('eq=contrast=$c:gamma_r=$gr:gamma_b=$gb');
          break;
        case FilterPreset.blockbuster:
          final c = (1.0 + 0.3 * intensity).toStringAsFixed(2);
          final s = (1.0 + 0.2 * intensity).toStringAsFixed(2);
          filters.add('eq=contrast=$c:saturation=$s');
          break;

        // Vintage
        case FilterPreset.vintage:
          filters.add('curves=vintage');
          break;
        case FilterPreset.sepia:
          filters.add(
            'colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131',
          );
          break;
        case FilterPreset.seventies:
          final gr = (1.0 + 0.2 * intensity).toStringAsFixed(2);
          final gb = (1.0 - 0.2 * intensity).toStringAsFixed(2);
          final s = (1.0 - 0.15 * intensity).toStringAsFixed(2);
          filters.add('eq=gamma_r=$gr:gamma_b=$gb:saturation=$s');
          break;

        // Portrait
        case FilterPreset.softSkin:
          final b = (0.04 * intensity).toStringAsFixed(2);
          final c = (1.0 - 0.05 * intensity).toStringAsFixed(2);
          filters.add('eq=brightness=$b:contrast=$c');
          break;
        case FilterPreset.glowPortrait:
          final gr = (1.0 + 0.15 * intensity).toStringAsFixed(2);
          final b = (0.05 * intensity).toStringAsFixed(2);
          filters.add('eq=gamma_r=$gr:brightness=$b');
          break;

        // Landscape
        case FilterPreset.forestGreen:
          final gg = (1.0 + 0.25 * intensity).toStringAsFixed(2);
          final s = (1.0 + 0.15 * intensity).toStringAsFixed(2);
          filters.add('eq=gamma_g=$gg:saturation=$s');
          break;
        case FilterPreset.deepOcean:
          final gb = (1.0 + 0.3 * intensity).toStringAsFixed(2);
          final s = (1.0 + 0.2 * intensity).toStringAsFixed(2);
          filters.add('eq=gamma_b=$gb:saturation=$s');
          break;

        // Black & White
        case FilterPreset.grayscale:
          final sat = (1.0 - intensity).clamp(0.0, 1.0).toStringAsFixed(2);
          filters.add('hue=s=$sat');
          break;
        case FilterPreset.monoContrast:
          final sat = (1.0 - intensity).clamp(0.0, 1.0).toStringAsFixed(2);
          final c = (1.0 + 0.4 * intensity).toStringAsFixed(2);
          filters.add('hue=s=$sat,eq=contrast=$c');
          break;
        case FilterPreset.noirFilm:
          final sat = (1.0 - intensity).clamp(0.0, 1.0).toStringAsFixed(2);
          final c = (1.0 + 0.6 * intensity).toStringAsFixed(2);
          final b = (-0.05 * intensity).toStringAsFixed(2);
          filters.add('hue=s=$sat,eq=contrast=$c:brightness=$b');
          break;

        // Dramatic
        case FilterPreset.dramatic:
          final c = (1.0 + 0.3 * intensity).toStringAsFixed(2);
          final b = (-0.06 * intensity).toStringAsFixed(2);
          filters.add('eq=contrast=$c:brightness=$b');
          break;
        case FilterPreset.highContrast:
          final c = (1.0 + 0.45 * intensity).toStringAsFixed(2);
          final s = (1.0 + 0.2 * intensity).toStringAsFixed(2);
          filters.add('eq=contrast=$c:saturation=$s');
          break;
        case FilterPreset.cyberpunk:
          final gr = (1.0 + 0.2 * intensity).toStringAsFixed(2);
          final gb = (1.0 + 0.35 * intensity).toStringAsFixed(2);
          final s = (1.0 + 0.3 * intensity).toStringAsFixed(2);
          filters.add('eq=gamma_r=$gr:gamma_b=$gb:saturation=$s');
          break;

        // Film
        case FilterPreset.faded:
          final c = (1.0 - 0.2 * intensity).toStringAsFixed(2);
          final b = (0.06 * intensity).toStringAsFixed(2);
          filters.add('eq=contrast=$c:brightness=$b');
          break;
        case FilterPreset.retroRolling:
          // Retro Film Rolling scanline, warm retro tint & grain flicker
          filters.add(
            "curves=vintage,eq=contrast=1.15:brightness=0.03:saturation=0.85,drawgrid=w=iw:h=4:t=1:c=black@0.12,noise=alls=10:allf=t+u",
          );
          break;
        case FilterPreset.kodakGold:
          final gr = (1.0 + 0.22 * intensity).toStringAsFixed(2);
          final gg = (1.0 + 0.1 * intensity).toStringAsFixed(2);
          final gb = (1.0 - 0.15 * intensity).toStringAsFixed(2);
          filters.add('eq=gamma_r=$gr:gamma_g=$gg:gamma_b=$gb:contrast=1.1');
          break;
        case FilterPreset.vivid:
          final s = (1.0 + 0.5 * intensity).toStringAsFixed(2);
          final c = (1.0 + 0.1 * intensity).toStringAsFixed(2);
          filters.add('eq=saturation=$s:contrast=$c');
          break;

        case FilterPreset.normal:
          break;
      }
    }

    if (adj.brightness != 0.0 ||
        adj.contrast != 0.0 ||
        adj.saturation != 0.0 ||
        adj.exposure != 0.0) {
      final b = (adj.brightness * 0.5 + adj.exposure * 0.4).clamp(-1.0, 1.0);
      final c = (adj.contrast + 1.0).clamp(0.0, 2.0);
      final s = (adj.saturation + 1.0).clamp(0.0, 3.0);
      filters.add('eq=brightness=$b:contrast=$c:saturation=$s');
    }

    if (adj.temperature != 0.0 || adj.tint != 0.0) {
      final temp = adj.temperature; // -1 (dingin) s/d +1 (hangat)
      final gammaR = (1.0 + temp * 0.2).clamp(0.5, 2.0).toStringAsFixed(2);
      final gammaB = (1.0 - temp * 0.2).clamp(0.5, 2.0).toStringAsFixed(2);
      final gammaG = (1.0 - adj.tint * 0.15).clamp(0.5, 2.0).toStringAsFixed(2);
      filters.add('eq=gamma_r=$gammaR:gamma_g=$gammaG:gamma_b=$gammaB');
    }

    if (adj.sharpen > 0.0) {
      final sh = (adj.sharpen * 2.0).clamp(0.1, 3.0).toStringAsFixed(2);
      filters.add('unsharp=5:5:$sh:5:5:0.0');
    }

    if (adj.vignette > 0.0) {
      final angle = adj.vignette * 0.8;
      filters.add('vignette=PI*$angle');
    }

    if (adj.blur > 0.0) {
      final sigma = (adj.blur * 20.0).clamp(1.0, 20.0);
      filters.add('gblur=sigma=$sigma');
    }

    return filters.join(',');
  }

  String _buildEffectFilter(VideoEffectModel effect) {
    if (!effect.hasEffect) return '';
    final item = EffectCatalog.getItem(effect.type);
    if (item.type == EffectType.none) return '';

    // Modulasi intensitas pada efek filter tertentu
    var filter = item.ffmpegFilterPattern;
    if (effect.durationSeconds > 0.0) {
      // Jika efek memiliki durasi khusus (misal 3 detik pertama)
      filter = "$filter:enable='between(t,0,${effect.durationSeconds})'";
    }
    return filter;
  }

  String _buildVideoFilter(
    ClipTransformModel transform, {
    ColorAdjustmentModel? adjustment,
    VideoEffectModel? effect,
    ClipAnimationModel? animation,
    double clipDuration = 0.0,
    List<OverlayModel>? overlays,
    List<KeyframeModel>? keyframes,
    double speed = 1.0,
    QualityEnhancementModel? quality,
    int? targetHeight,
  }) {
    final List<String> filters = [];

    // 0. Quality Enhancement Filters (Noise Reduction, Stabilization, Deflicker, Auto Enhance)
    if (quality != null && quality.hasEnhancement) {
      filters.addAll(quality.buildFFmpegFilters());
    }

    // 0.1 Speed Video Filter
    if (speed != 1.0) {
      final ptsFactor = 1.0 / speed;
      filters.add('setpts=$ptsFactor*PTS');
    }

    // 0.1 Animation Studio Filters (In, Out, Combo Transitions)
    if (animation != null && animation.hasAnimation) {
      // Filter khusus diutamakan. Jika preset belum punya padanan ekspor,
      // filter keluarga (shake/zoom/pan/flash/...) dipakai agar animasi
      // tidak hilang diam-diam dari video hasil ekspor.
      final animFilter = AnimationExportSupportService.buildExportFilter(
        animation,
        clipDuration: clipDuration,
      );
      if (animFilter.isNotEmpty) {
        filters.add(animFilter);
      }
    }

    // Keyframe Animation Evaluation: Scale & Position dynamic expressions
    if (keyframes != null && keyframes.isNotEmpty) {
      final sorted = List<KeyframeModel>.from(keyframes)
        ..sort((a, b) => a.timestampSeconds.compareTo(b.timestampSeconds));

      if (sorted.length >= 2) {
        final k0 = sorted.first;
        final k1 = sorted.last;
        final t0 = k0.timestampSeconds;
        final t1 = k1.timestampSeconds;
        final dt = t1 - t0;

        if (dt > 0.05 &&
            (k0.scale != k1.scale ||
                k0.positionX != k1.positionX ||
                k0.positionY != k1.positionY)) {
          // Dynamic zoom expression via FFmpeg zoompan filter
          final s0 = k0.scale;
          final s1 = k1.scale;
          // Interpolasi zoom linier: s0 + (s1-s0)*((time-t0)/dt)
          filters.add(
            "zoompan=z='if(lte(time,$t0),$s0,if(gte(time,$t1),$s1,$s0+($s1-$s0)*((time-$t0)/$dt)))':d=1:s=hd720:fps=30",
          );
        }
      }
    }

    // 1. Color Grading & Filters
    if (adjustment != null && adjustment.hasAdjustment) {
      final colorFilter = _buildColorFilter(adjustment);
      if (colorFilter.isNotEmpty) {
        filters.add(colorFilter);
      }
    }

    // 1.1 Video Effects (Basic, Cinematic, Vintage, Glitch, Blur, Light, Retro, Motion, etc.)
    if (effect != null && effect.hasEffect) {
      final effectFilter = _buildEffectFilter(effect);
      if (effectFilter.isNotEmpty) {
        filters.add(effectFilter);
      }
    }

    // 2. Crop
    if (transform.hasCustomCrop) {
      final cropW = 'iw*${transform.cropRight - transform.cropLeft}';
      final cropH = 'ih*${transform.cropBottom - transform.cropTop}';
      final cropX = 'iw*${transform.cropLeft}';
      final cropY = 'ih*${transform.cropTop}';
      filters.add('crop=$cropW:$cropH:$cropX:$cropY');
    }

    // 3. Rotasi
    final normRot = (transform.rotationDegrees % 360 + 360) % 360;
    if ((normRot - 90).abs() < 0.1) {
      filters.add('transpose=1');
    } else if ((normRot - 180).abs() < 0.1) {
      filters.add('hflip,vflip');
    } else if ((normRot - 270).abs() < 0.1) {
      filters.add('transpose=2');
    } else if (normRot.abs() > 0.1) {
      // Rotasi halus arbitrer menggunakan filter rotate FFmpeg
      final rad = (transform.rotationDegrees * 3.141592653589793 / 180.0)
          .toStringAsFixed(4);
      filters.add('rotate=$rad:ow=rotw($rad):oh=roth($rad):c=none');
    }

    // 4. Flip
    if (transform.flipHorizontal) {
      filters.add('hflip');
    }
    if (transform.flipVertical) {
      filters.add('vflip');
    }

    // 5. Canvas Aspect Ratio
    final ratio = transform.targetAspectRatio;
    if (ratio != null) {
      final padColor = transform.backgroundColorHex;
      if (transform.fitMode == FitMode.fit) {
        filters.add(
          'scale=w=min(iw\\,ih*$ratio):h=min(ih\\,iw/$ratio):force_original_aspect_ratio=decrease,'
          'pad=w=max(iw\\,ih*$ratio):h=max(ih\\,iw/$ratio):x=(ow-iw)/2:y=(oh-ih)/2:color=0x$padColor',
        );
      } else {
        filters.add(
          'scale=w=max(iw\\,ih*$ratio):h=max(ih\\,iw/$ratio):force_original_aspect_ratio=increase,'
          'crop=min(iw\\,ih*$ratio):min(ih\\,iw/$ratio)',
        );
      }
    }

    // 6. Target Resolution Scaling (360p, 480p, 720p, 1080p, 1440p, 4K)
    // Untuk portrait maupun landscape, jaga agar dimensi dibatasi secara proporsional
    if (targetHeight != null && targetHeight > 0) {
      if (transform.targetAspectRatio != null &&
          transform.targetAspectRatio! < 1.0) {
        // Portrait (misal 9:16): targetHeight merepresentasikan tinggi kanvas (misal 1280 untuk 720p atau 3840 untuk 4K)
        // Hitung max target tinggi proporsional: targetHeight / ratio
        final portraitMaxHeight = (targetHeight / transform.targetAspectRatio!)
            .round();
        filters.add(
          'scale=\'if(gt(ih,iw),-2,min(iw\\,$targetHeight))\':\'if(gt(ih,iw),min(ih\\,$portraitMaxHeight),-2)\'',
        );
      } else {
        filters.add('scale=-2:$targetHeight');
      }
    }

    // 7. Drawtext Overlay
    if (overlays != null && overlays.isNotEmpty) {
      for (final overlay in overlays) {
        if (!overlay.isVisible) continue;

        final escaped = _escapeFFmpegText(overlay.content);
        final start = overlay.startTime;
        final end = overlay.endTime;
        final fontSize = overlay.fontSize.toInt();
        final fontColor = '0x${overlay.textColorHex}';

        final posX = 'w*${overlay.normalizedX}-(text_w/2)';
        final posY = 'h*${overlay.normalizedY}-(text_h/2)';
        final enableCondition = "between(t\\,$start\\,$end)";

        var drawText =
            "drawtext=text='$escaped':fontsize=$fontSize:fontcolor=$fontColor:x=$posX:y=$posY:enable='$enableCondition'";

        if (overlay.backgroundColorHex != null) {
          drawText +=
              ":box=1:boxcolor=0x${overlay.backgroundColorHex}@${overlay.opacity}:boxborderw=4";
        }
        if (overlay.presetStyle == TextPresetStyle.shadow) {
          drawText += ":shadowcolor=black:shadowx=2:shadowy=2";
        }

        filters.add(drawText);
      }
    }

    // Pastikan resolusi akhir selalu genap
    filters.add('scale=trunc(iw/2)*2:trunc(ih/2)*2');
    return filters.join(',');
  }

  String _buildAudioFilter({
    double volume = 1.0,
    double speed = 1.0,
    AudioEffectModel? audioEffect,
    double clipDuration = 0.0,
  }) {
    final List<String> aFilters = [];

    // Jika memiliki Audio Studio Effect (Voice Effect, Enhancement, EQ, Fade, Balance)
    if (audioEffect != null && audioEffect.hasActiveEffects) {
      final advancedFilters = audioEffect.buildFFmpegAudioFilters(
        clipDuration: clipDuration,
      );
      if (advancedFilters.isNotEmpty) {
        aFilters.add(advancedFilters);
      }
    } else {
      if (volume != 1.0) {
        aFilters.add('volume=$volume');
      }
    }

    if (speed != 1.0) {
      if (speed >= 0.5 && speed <= 2.0) {
        aFilters.add('atempo=$speed');
      } else if (speed < 0.5) {
        aFilters.add('atempo=0.5,atempo=${speed / 0.5}');
      } else if (speed > 2.0) {
        aFilters.add('atempo=2.0,atempo=${speed / 2.0}');
      }
    }

    return aFilters.join(',');
  }

  @override
  Future<File?> trimClip({
    required ClipModel clip,
    List<OverlayModel>? overlays,
    ExportConfigModel? exportConfig,
    ProgressCallback? onProgress,
    LogCallback? onLog,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${tempDir.path}/clip_${clip.id}_$timestamp.mp4';

      final startFormatted = TimeFormatter.toFFmpegTimestamp(clip.startSource);
      final durationFormatted = TimeFormatter.toFFmpegTimestamp(
        clip.sourceDuration,
      );
      final totalExpectedMillis = (clip.timelineDuration * 1000).toInt();

      final cfg = exportConfig ?? const ExportConfigModel();
      final vf = _buildVideoFilter(
        clip.transform,
        adjustment: clip.adjustment,
        effect: clip.effect,
        animation: clip.animation,
        clipDuration: clip.timelineDuration,
        overlays: overlays,
        keyframes: clip.keyframes,
        speed: clip.speed,
        quality: clip.quality,
        targetHeight: cfg.targetHeight,
      );
      final filterArg = vf.isNotEmpty ? '-vf "$vf"' : '';

      final af = _buildAudioFilter(
        volume: clip.volume,
        speed: clip.speed,
        audioEffect: clip.audioEffect,
        clipDuration: clip.timelineDuration,
      );
      final audioArg = (cfg.includeAudio && af.isNotEmpty)
          ? '-af "$af" -c:a aac'
          : (!cfg.includeAudio ? '-an' : '-c:a aac');

      final fpsArg = '-r ${cfg.fpsValue}';
      final bitrateArg =
          '-b:v ${cfg.videoBitrateKbps}k -maxrate ${(cfg.videoBitrateKbps * 1.2).toInt()}k -bufsize ${(cfg.videoBitrateKbps * 2).toInt()}k';

      // Strategi Smart Encoder: AUTO, HARDWARE (MediaCodec), SOFTWARE (libx264)
      bool preferHardware = false;
      if (cfg.encoderMode == ExportEncoderMode.hardware) {
        preferHardware = true;
      } else if (cfg.encoderMode == ExportEncoderMode.software) {
        preferHardware = false;
      } else {
        // Mode AUTO: Gunakan SmartExportAdvisor
        try {
          final capService = DeviceCapabilityServiceImpl();
          final caps = await capService.getDeviceCapabilities();
          final benchProfile = await BenchmarkProfile.load();
          final choice = SmartExportAdvisor.resolveAutoEncoder(
            config: cfg,
            capabilities: caps,
            benchmarkProfile: benchProfile,
          );
          preferHardware = (choice == 'hardware');
        } catch (_) {
          preferHardware = Platform.isAndroid && cfg.targetHeight >= 1080;
        }
      }

      final useHardware = preferHardware;

      Future<bool> runEncoding({required bool tryHardware}) async {
        final String videoEncoderArgs;
        if (tryHardware) {
          // Hardware MediaCodec encoder pada Android
          // MediaCodec bekerja optimal dengan pix_fmt nv12 atau yuv420p
          videoEncoderArgs = '-c:v h264_mediacodec -pix_fmt nv12';
        } else {
          // Software libx264 encoder dengan multi-threading CPU
          videoEncoderArgs =
              '-c:v libx264 -preset ultrafast -threads 0 -pix_fmt yuv420p';
        }

        final command =
            '-y -ss $startFormatted -i "${clip.sourcePath}" -t $durationFormatted $filterArg $fpsArg $bitrateArg $audioArg $videoEncoderArgs "$outputPath"';

        _currentSession = await FFmpegKit.executeAsync(
          command,
          (session) {},
          (log) {
            onLog?.call(log.getMessage());
          },
          (statistics) {
            if (totalExpectedMillis > 0 && statistics.getTime() > 0) {
              final progress = ExportProgressCalculator.calculateSingleClipProgress(
                timeMillis: statistics.getTime(),
                totalExpectedMillis: totalExpectedMillis,
              );
              onProgress?.call(progress);
            }
          },
        );

        final session = _currentSession;
        if (session == null) return false;

        final returnCode = await session.getReturnCode();
        _currentSession = null;

        if (ReturnCode.isSuccess(returnCode)) {
          return true;
        } else if (ReturnCode.isCancel(returnCode)) {
          onLog?.call('Proses dibatalkan.');
          final tempFile = File(outputPath);
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
          return false;
        } else {
          final logs = await session.getAllLogsAsString();
          onLog?.call(logs ?? 'Unknown FFmpeg error');
          return false;
        }
      }

      bool success = false;
      if (useHardware) {
        onLog?.call('Mencoba Hardware Acceleration (MediaCodec)...');
        success = await runEncoding(tryHardware: true);

        // Jika mode Auto dan hardware gagal, lakukan fallback mulus ke Software Encoding
        if (!success && cfg.encoderMode == ExportEncoderMode.auto) {
          onLog?.call(
            'Hardware encoding tidak berhasil atau tidak didukung clip ini. Melakukan fallback ke Software Encoder (libx264)...',
          );
          success = await runEncoding(tryHardware: false);
        }
      } else {
        onLog?.call(
          'Menggunakan Software Encoder (libx264 ultrafast, multi-threaded)...',
        );
        success = await runEncoding(tryHardware: false);
      }

      if (success) {
        final outputFile = File(outputPath);
        if (await outputFile.exists()) {
          onProgress?.call(1.0);
          return outputFile;
        }
      }
    } catch (e) {
      onLog?.call(e.toString());
    } finally {
      _currentSession = null;
    }
    return null;
  }

  @override
  Future<File?> exportTimeline({
    required TimelineModel timeline,
    ExportConfigModel? exportConfig,
    ProgressCallback? onProgress,
    LogCallback? onLog,
  }) async {
    _isCancelled = false;
    if (timeline.clips.isEmpty) {
      onLog?.call('Timeline kosong.');
      return null;
    }

    final cfg = exportConfig ?? const ExportConfigModel();
    final tempDir = await getTemporaryDirectory();
    final List<File> intermediateFiles = [];
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final finalOutputPath = '${tempDir.path}/export_timeline_$timestamp.mp4';
    final totalDuration = timeline.totalDuration;
    double accumulatedTime = 0.0;

    try {
      // 1. Render klip-klip intermediate dengan resolusi, FPS, dan bitrate yang terstandarisasi
      for (int i = 0; i < timeline.clips.length; i++) {
        if (_isCancelled) {
          onLog?.call('Ekspor dibatalkan sebelum merender klip ${i + 1}.');
          await _cleanupFiles(intermediateFiles);
          return null;
        }
        final clip = timeline.clips[i];
        final clipStart = accumulatedTime;
        final clipEnd = accumulatedTime + clip.timelineDuration;

        final relevantOverlays = timeline.overlays
            .where((o) {
              return o.startTime < clipEnd && o.endTime > clipStart;
            })
            .map((o) {
              return o.copyWith(
                startTime: (o.startTime - clipStart).clamp(
                  0.0,
                  clip.timelineDuration,
                ),
                endTime: (o.endTime - clipStart).clamp(
                  0.0,
                  clip.timelineDuration,
                ),
              );
            })
            .toList();

        final clipFile = await trimClip(
          clip: clip,
          overlays: relevantOverlays,
          exportConfig: cfg,
          onProgress: (clipProg) {
            final progress = ExportProgressCalculator.calculateClipStageProgress(
              accumulatedDuration: accumulatedTime,
              currentClipDuration: clip.timelineDuration,
              currentClipProgress: clipProg,
              totalDuration: totalDuration,
            );
            onProgress?.call(progress);
          },
          onLog: onLog,
        );

        if (clipFile == null) {
          await _cleanupFiles(intermediateFiles);
          return null;
        }
        intermediateFiles.add(clipFile);
        accumulatedTime += clip.timelineDuration;
      }

      // 2. Concat klip-klip intermediate
      final listFile = File('${tempDir.path}/concat_list_$timestamp.txt');
      final listContent = intermediateFiles
          .map((f) => "file '${f.path.replaceAll("'", "'\\''")}'")
          .join('\n');
      await listFile.writeAsString(listContent);

      final concatenatedVideoPath =
          '${tempDir.path}/concat_video_$timestamp.mp4';
      final concatCommand =
          '-y -f concat -safe 0 -i "${listFile.path}" -c copy "$concatenatedVideoPath"';
      _currentSession = await FFmpegKit.executeAsync(concatCommand);
      final concatReturnCode = await _currentSession?.getReturnCode();
      _currentSession = null;

      if (await listFile.exists()) await listFile.delete();
      await _cleanupFiles(intermediateFiles);

      if (_isCancelled || !ReturnCode.isSuccess(concatReturnCode)) {
        final concatFile = File(concatenatedVideoPath);
        if (await concatFile.exists()) await concatFile.delete();
        return null;
      }
      onProgress?.call(0.90);

      // 3. Mixing Audio Eksternal Dinamis (Mendukung Multi-Track Audio)
      if (cfg.includeAudio && timeline.audioClips.isNotEmpty) {
        // Ambil hanya audio clips yang aktif (tidak di-mute dan file-nya ada)
        final validAudios = <AudioClipModel>[];
        for (final audio in timeline.audioClips) {
          if (!audio.isMuted &&
              audio.duration > 0 &&
              await File(audio.sourcePath).exists()) {
            validAudios.add(audio);
          }
        }

        if (validAudios.isEmpty) {
          // Tidak ada audio eksternal yang valid/aktif, gunakan video hasil concat
          final finalFile = File(concatenatedVideoPath);
          if (await finalFile.exists()) {
            onProgress?.call(1.0);
            return finalFile;
          }
        } else {
          // Periksa apakah video hasil concat memiliki audio stream asli
          // Gunakan FFmpeg probe sederhana untuk memastikan keberadaan stream [0:a]
          final probeSession = await FFmpegKit.execute(
            '-v error -select_streams a -show_entries stream=index -of csv=p=0 "$concatenatedVideoPath"',
          );
          final probeOutput = (await probeSession.getOutput())?.trim() ?? '';
          final hasOriginalAudio = probeOutput.isNotEmpty;

          // Bangun dynamic filter_complex dengan amix dinamis
          // Input 0: concatenated video
          // Input 1..N: file audio eksternal
          final inputArgs = <String>['-y', '-i', '"$concatenatedVideoPath"'];
          for (final audio in validAudios) {
            inputArgs.addAll(['-i', '"${audio.sourcePath}"']);
          }

          final filterComplexParts = <String>[];
          final mixInputs = <String>[];

          if (hasOriginalAudio) {
            filterComplexParts.add('[0:a]volume=1.0[a0]');
            mixInputs.add('[a0]');
          }

          for (int i = 0; i < validAudios.length; i++) {
            final audio = validAudios[i];
            final audioIndex = i + 1; // Input index di FFmpeg
            final outLabel = 'amix$audioIndex';

            final subFilters = <String>[];

            // 1. Trim / seek dari file sumber jika startSource > 0
            if (audio.startSource > 0) {
              subFilters.add(
                'atrim=start=${audio.startSource}:duration=${audio.duration}',
              );
            } else {
              subFilters.add('atrim=0:${audio.duration}');
            }
            subFilters.add('asetpts=PTS-STARTPTS');

            // 2. Volume
            if (audio.volume != 1.0) {
              subFilters.add('volume=${audio.volume}');
            }

            // 3. Fade In
            if (audio.fadeInSeconds > 0) {
              subFilters.add('afade=t=in:ss=0:d=${audio.fadeInSeconds}');
            }

            // 4. Fade Out
            if (audio.fadeOutSeconds > 0) {
              final startFade = (audio.duration - audio.fadeOutSeconds).clamp(
                0.0,
                audio.duration,
              );
              subFilters.add(
                'afade=t=out:st=$startFade:d=${audio.fadeOutSeconds}',
              );
            }

            // 5. Delay pada Timeline (adelay dalam milidetik)
            if (audio.startTimeline > 0) {
              final delayMs = (audio.startTimeline * 1000).toInt();
              subFilters.add('adelay=$delayMs|$delayMs');
            }

            final filterChain = subFilters.isNotEmpty
                ? subFilters.join(',')
                : 'anull';
            filterComplexParts.add('[$audioIndex:a]$filterChain[$outLabel]');
            mixInputs.add('[$outLabel]');
          }

          // Gabungkan stream audio
          // Jika ada lebih dari 1 stream audio (asli + eksternal atau >1 eksternal) -> gunakan amix
          // Jika hanya 1 stream audio eksternal tanpa audio asli -> teruskan langsung
          final totalAudioInputs = mixInputs.length;
          if (totalAudioInputs > 1) {
            filterComplexParts.add(
              '${mixInputs.join('')}amix=inputs=$totalAudioInputs:duration=longest:dropout_transition=2,apad[amix_all];[amix_all]atrim=0:$totalDuration,asetpts=PTS-STARTPTS[aout]',
            );
          } else if (totalAudioInputs == 1) {
            filterComplexParts.add(
              '${mixInputs.first}apad[amix_all];[amix_all]atrim=0:$totalDuration,asetpts=PTS-STARTPTS[aout]',
            );
          }

          final fullFilterComplex = filterComplexParts.join(';');
          final mixCommand =
              '${inputArgs.join(' ')} -filter_complex "$fullFilterComplex" -map 0:v -map "[aout]" -c:v copy -c:a aac -t $totalDuration "$finalOutputPath"';

          onLog?.call('Executing Multi-track Audio Mix: $mixCommand');
          _currentSession = await FFmpegKit.executeAsync(mixCommand);
          final mixReturn = await _currentSession?.getReturnCode();
          _currentSession = null;

          final tempVideo = File(concatenatedVideoPath);
          if (await tempVideo.exists()) await tempVideo.delete();

          if (!_isCancelled && ReturnCode.isSuccess(mixReturn)) {
            final outputFile = File(finalOutputPath);
            if (await outputFile.exists()) {
              onProgress?.call(1.0);
              return outputFile;
            }
          } else {
            final failFile = File(finalOutputPath);
            if (await failFile.exists()) await failFile.delete();
            onLog?.call('Audio mixing failed or cancelled');
          }
        }
      } else {
        if (_isCancelled) {
          final tempVideo = File(concatenatedVideoPath);
          if (await tempVideo.exists()) await tempVideo.delete();
          return null;
        }
        final finalFile = File(concatenatedVideoPath);
        if (await finalFile.exists()) {
          onProgress?.call(1.0);
          return finalFile;
        }
      }
    } catch (e) {
      onLog?.call(e.toString());
      await _cleanupFiles(intermediateFiles);
    }
    return null;
  }

  Future<void> _cleanupFiles(List<File> files) async {
    for (final file in files) {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }
  }
}
