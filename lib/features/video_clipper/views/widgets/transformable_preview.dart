import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/models/animation_model.dart';
import '../../../../core/models/clip_transform_model.dart';
import '../../../../core/models/color_adjustment_model.dart';
import '../../../../core/models/filter_catalog.dart';
import '../../../../core/models/keyframe_model.dart';
import '../../../../core/models/video_effect_model.dart';
import 'trending_visual_effect_painter.dart';
import 'glitch_visual_effect_painter.dart';
import 'video_preview_player.dart';
import 'package:video_player/video_player.dart';

class TransformablePreview extends StatelessWidget {
  final VideoPlayerController controller;
  final ClipTransformModel transform;
  final ColorAdjustmentModel adjustment;
  final VideoEffectModel effect;
  final ClipAnimationModel animation;
  final List<KeyframeModel> keyframes;
  final double currentClipSeconds;
  final double totalClipSeconds;

  const TransformablePreview({
    super.key,
    required this.controller,
    required this.transform,
    this.adjustment = const ColorAdjustmentModel(),
    this.effect = const VideoEffectModel(),
    this.animation = const ClipAnimationModel(),
    this.keyframes = const [],
    this.currentClipSeconds = 0.0,
    this.totalClipSeconds = 10.0,
  });

  ColorFilter? _getColorFilter() {
    if (adjustment.preset == FilterPreset.normal && adjustment.filterIntensity <= 0.0) {
      return null;
    }

    final matrix = FilterCatalog.getBlendedMatrix(
      adjustment.preset,
      adjustment.filterIntensity,
    );
    return ColorFilter.matrix(matrix);
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final targetRatio =
        transform.targetAspectRatio ?? controller.value.aspectRatio;
    Color bgColor;
    try {
      final hex = transform.backgroundColorHex.replaceAll('#', '');
      bgColor = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      bgColor = Colors.black;
    }

    final effectiveRatio = (targetRatio > 0.0 && !targetRatio.isNaN && !targetRatio.isInfinite)
        ? targetRatio
        : (controller.value.aspectRatio > 0.0 ? controller.value.aspectRatio : 16 / 9);

    // Evaluasi nilai interpolasi keyframe pada waktu pemutaran klip
    final kfValues = InterpolatedKeyframeValues.evaluate(keyframes, currentClipSeconds);
    final totalRotation = transform.rotationDegrees + kfValues.rotationDegrees;
    final radians = (totalRotation % 360) * (math.pi / 180.0);
    final filter = _getColorFilter();

    Widget playerWidget = SizedBox(
      width: controller.value.size.width,
      height: controller.value.size.height,
      child: VideoPreviewPlayer(controller: controller),
    );

    // Terapkan Custom Crop jika aktif (cropLeft, cropTop, cropRight, cropBottom)
    if (transform.hasCustomCrop) {
      playerWidget = ClipRect(
        clipper: _RelativeVideoClipper(
          cropLeft: transform.cropLeft,
          cropTop: transform.cropTop,
          cropRight: transform.cropRight,
          cropBottom: transform.cropBottom,
        ),
        child: playerWidget,
      );
    }

    // Terapkan Color Filter
    if (filter != null) {
      playerWidget = ColorFiltered(colorFilter: filter, child: playerWidget);
    }

    // Terapkan Video Effect Visual Preview
    if (effect.hasEffect) {
      switch (effect.type) {
        case EffectType.invert:
          playerWidget = ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              -1, 0, 0, 0, 255,
              0, -1, 0, 0, 255,
              0, 0, -1, 0, 255,
              0, 0, 0, 1, 0,
            ]),
            child: playerWidget,
          );
          break;
        case EffectType.mirrorHorizontal:
          playerWidget = Transform.scale(scaleX: -1.0, child: playerWidget);
          break;
        case EffectType.mirrorVertical:
          playerWidget = Transform.scale(scaleY: -1.0, child: playerWidget);
          break;
        case EffectType.letterbox:
          playerWidget = Stack(
            fit: StackFit.passthrough,
            children: [
              playerWidget,
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: controller.value.size.height * 0.12,
                child: const ColoredBox(color: Colors.black),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: controller.value.size.height * 0.12,
                child: const ColoredBox(color: Colors.black),
              ),
            ],
          );
          break;
        case EffectType.cyberpunkGlow:
        case EffectType.duotoneCyanRed:
          playerWidget = ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.purpleAccent.withValues(alpha: 0.25 * effect.intensity),
              BlendMode.color,
            ),
            child: playerWidget,
          );
          break;
        default:
          break;
      }
    }

    // Evaluasi Animasi Presets (CapCut Style In, Out, Combo)
    final animResult = animation.evaluate(
      timeInClip: currentClipSeconds,
      totalClipDuration: totalClipSeconds > 0 ? totalClipSeconds : 10.0,
    );

    // Gabungkan nilai Keyframe dan Presets Animasi
    final combinedScale = kfValues.scale * animResult.scale;
    final combinedOpacity = (kfValues.opacity * animResult.opacity).clamp(0.0, 1.0);
    final combinedPosX = kfValues.positionX + animResult.positionX;
    final combinedPosY = kfValues.positionY + animResult.positionY;
    final combinedRotation = radians + (animResult.rotationDegrees * math.pi / 180.0);

    // Terapkan opacity animasi
    if (combinedOpacity < 1.0) {
      playerWidget = Opacity(opacity: combinedOpacity, child: playerWidget);
    }

    // Terapkan blur animasi jika ada
    if (animResult.blurRadius > 0.0) {
      playerWidget = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: animResult.blurRadius, sigmaY: animResult.blurRadius),
        child: playerWidget,
      );
    }

    // Terapkan geometric iris / wipe clipping jika ada
    if (animResult.clipShape != AnimationClipShape.none) {
      playerWidget = ClipPath(
        clipper: _TransformableAnimationClipper(
          shape: animResult.clipShape,
          progress: animResult.clipProgress,
        ),
        child: playerWidget,
      );
    }

    // Matriks 3D Perspektif Nyata (Pitch X, Yaw Y, Roll Z)
    final matrix3D = Matrix4.identity()
      ..setEntry(3, 2, animResult.perspective)
      ..rotateX(animResult.rotateXDegrees * math.pi / 180.0)
      ..rotateY(animResult.rotateYDegrees * math.pi / 180.0)
      ..rotateZ(combinedRotation);

    // Foreground Player Container yang ditransformasi dengan True 3D + 2D
    Widget transformedPlayer = Transform(
      transform: matrix3D,
      alignment: Alignment.center,
      child: Transform.translate(
        offset: Offset(
          combinedPosX * (controller.value.size.width * 0.5),
          combinedPosY * (controller.value.size.height * 0.5),
        ),
        child: Transform.scale(
          scale: combinedScale,
          child: Transform.scale(
            scaleX: (transform.flipHorizontal ? -1.0 : 1.0) * animResult.scaleX,
            scaleY: (transform.flipVertical ? -1.0 : 1.0) * animResult.scaleY,
            child: FittedBox(
              fit: transform.fitMode == FitMode.fill
                  ? BoxFit.cover
                  : BoxFit.contain,
              child: playerWidget,
            ),
          ),
        ),
      ),
    );

    // Terapkan Flash / Glow Overlay jika ada
    if (animResult.flashOpacity > 0.0) {
      transformedPlayer = Stack(
        fit: StackFit.passthrough,
        children: [
          transformedPlayer,
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(
                color: Colors.white.withValues(alpha: animResult.flashOpacity.clamp(0.0, 0.45)),
              ),
            ),
          ),
        ],
      );
    }

    // Terapkan Color Overlay Nyata untuk Dip to Black & Dip to White
    if (animResult.colorOverlayOpacity > 0.0) {
      transformedPlayer = Stack(
        fit: StackFit.passthrough,
        children: [
          transformedPlayer,
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(
                color: Color(animResult.colorOverlayValue).withValues(alpha: animResult.colorOverlayOpacity.clamp(0.0, 1.0)),
              ),
            ),
          ),
        ],
      );
    }

    // Terapkan Trending & Glitch Real Visual Canvas Overlay pada Player Utama jika ada preset yang aktif
    if (animation.presetId.isNotEmpty) {
      final normProgress = totalClipSeconds > 0 ? (currentClipSeconds / totalClipSeconds).clamp(0.0, 1.0) : 0.0;
      transformedPlayer = Stack(
        fit: StackFit.passthrough,
        children: [
          transformedPlayer,
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: TrendingVisualEffectPainter(
                  effectId: animation.presetId,
                  progress: normProgress,
                  intensity: animation.intensity,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: GlitchVisualEffectPainter(
                  effectId: animation.presetId,
                  progress: normProgress,
                  intensity: animation.intensity,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: effectiveRatio,
        child: Container(
          color: bgColor,
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Lapisan Blur Background Video jika diaktifkan
                if (transform.backgroundType == CanvasBackgroundType.blur &&
                    transform.fitMode == FitMode.fit)
                  Positioned.fill(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: controller.value.size.width,
                            height: controller.value.size.height,
                            child: VideoPreviewPlayer(controller: controller),
                          ),
                        ),
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.25),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Lapisan Utama Video Player
                transformedPlayer,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom Clipper untuk memotong video sesuai koordinat normalisasi (0.0 - 1.0)
class _RelativeVideoClipper extends CustomClipper<Rect> {
  final double cropLeft;
  final double cropTop;
  final double cropRight;
  final double cropBottom;

  const _RelativeVideoClipper({
    required this.cropLeft,
    required this.cropTop,
    required this.cropRight,
    required this.cropBottom,
  });

  @override
  Rect getClip(Size size) {
    final l = cropLeft * size.width;
    final t = cropTop * size.height;
    final w = (cropRight - cropLeft) * size.width;
    final h = (cropBottom - cropTop) * size.height;
    return Rect.fromLTWH(l, t, w.clamp(1.0, size.width), h.clamp(1.0, size.height));
  }

  @override
  bool shouldReclip(covariant _RelativeVideoClipper oldClipper) {
    return oldClipper.cropLeft != cropLeft ||
        oldClipper.cropTop != cropTop ||
        oldClipper.cropRight != cropRight ||
        oldClipper.cropBottom != cropBottom;
  }
}

/// Custom Clipper untuk Efek Iris (Lingkaran & Diamond) dan Wipe pada canvas utama
class _TransformableAnimationClipper extends CustomClipper<Path> {
  final AnimationClipShape shape;
  final double progress;

  const _TransformableAnimationClipper({
    required this.shape,
    required this.progress,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final p = progress.clamp(0.0, 1.0);

    switch (shape) {
      case AnimationClipShape.circleIris:
        final center = Offset(size.width / 2, size.height / 2);
        final maxRadius = math.sqrt(size.width * size.width + size.height * size.height) / 2;
        path.addOval(Rect.fromCircle(center: center, radius: maxRadius * p));
        break;

      case AnimationClipShape.diamondIris:
        final cx = size.width / 2;
        final cy = size.height / 2;
        final maxH = math.max(size.width, size.height) * 1.5;
        final hw = maxH * p;
        final hh = maxH * p;
        path.moveTo(cx, cy - hh);
        path.lineTo(cx + hw, cy);
        path.lineTo(cx, cy + hh);
        path.lineTo(cx - hw, cy);
        path.close();
        break;

      case AnimationClipShape.pentagonIris:
        final cx = size.width / 2;
        final cy = size.height / 2;
        final maxR = math.sqrt(size.width * size.width + size.height * size.height) * 0.75;
        final r = maxR * p;
        for (int i = 0; i < 5; i++) {
          final angle = -math.pi / 2 + (i * 2 * math.pi / 5);
          final px = cx + r * math.cos(angle);
          final py = cy + r * math.sin(angle);
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        break;

      case AnimationClipShape.starIris:
        final cx = size.width / 2;
        final cy = size.height / 2;
        final maxOuter = math.sqrt(size.width * size.width + size.height * size.height) * 0.85;
        final outerR = maxOuter * p;
        final innerR = outerR * 0.42;
        for (int i = 0; i < 10; i++) {
          final angle = -math.pi / 2 + (i * math.pi / 5);
          final rad = (i % 2 == 0) ? outerR : innerR;
          final px = cx + rad * math.cos(angle);
          final py = cy + rad * math.sin(angle);
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        break;

      case AnimationClipShape.wipeLeft:
        path.addRect(Rect.fromLTWH(0, 0, size.width * p, size.height));
        break;

      case AnimationClipShape.wipeRight:
        final w = size.width * p;
        path.addRect(Rect.fromLTWH(size.width - w, 0, w, size.height));
        break;

      case AnimationClipShape.wipeUp:
        path.addRect(Rect.fromLTWH(0, 0, size.width, size.height * p));
        break;

      case AnimationClipShape.wipeDown:
        final h = size.height * p;
        path.addRect(Rect.fromLTWH(0, size.height - h, size.width, h));
        break;

      case AnimationClipShape.wipeDiagonalTL:
        final maxD = size.width + size.height;
        final currentD = maxD * p;
        path.moveTo(0, 0);
        path.lineTo(math.min(currentD, size.width), 0);
        if (currentD > size.width) {
          path.lineTo(size.width, currentD - size.width);
        }
        if (currentD > size.height) {
          path.lineTo(currentD - size.height, size.height);
        }
        path.lineTo(0, math.min(currentD, size.height));
        path.close();
        break;

      case AnimationClipShape.wipeDiagonalBR:
        final maxD = size.width + size.height;
        final currentD = maxD * p;
        path.moveTo(size.width, size.height);
        path.lineTo(math.max(0.0, size.width - currentD), size.height);
        if (currentD > size.width) {
          path.lineTo(0, size.height - (currentD - size.width));
        }
        if (currentD > size.height) {
          path.lineTo(size.width - (currentD - size.height), 0);
        }
        path.lineTo(size.width, math.max(0.0, size.height - currentD));
        path.close();
        break;

      case AnimationClipShape.splitHorizontal:
      case AnimationClipShape.curtain:
        final hw = (size.width / 2) * p;
        path.addRect(Rect.fromLTWH((size.width / 2) - hw, 0, hw * 2, size.height));
        break;

      case AnimationClipShape.curtainClose:
        final marginW = (size.width / 2) * (1.0 - p);
        path.addRect(Rect.fromLTWH(0, 0, marginW, size.height));
        path.addRect(Rect.fromLTWH(size.width - marginW, 0, marginW, size.height));
        break;

      case AnimationClipShape.splitVertical:
        final hh = (size.height / 2) * p;
        path.addRect(Rect.fromLTWH(0, (size.height / 2) - hh, size.width, hh * 2));
        break;

      case AnimationClipShape.blinds:
        const slats = 6;
        final slatHeight = size.height / slats;
        final visibleH = slatHeight * p;
        for (int i = 0; i < slats; i++) {
          path.addRect(Rect.fromLTWH(0, i * slatHeight, size.width, visibleH));
        }
        break;

      case AnimationClipShape.blindsVertical:
        const slats = 6;
        final slatWidth = size.width / slats;
        final visibleW = slatWidth * p;
        for (int i = 0; i < slats; i++) {
          path.addRect(Rect.fromLTWH(i * slatWidth, 0, visibleW, size.height));
        }
        break;

      case AnimationClipShape.checkerboard:
        const rows = 4;
        const cols = 4;
        final cellW = size.width / cols;
        final cellH = size.height / rows;
        for (int r = 0; r < rows; r++) {
          for (int c = 0; c < cols; c++) {
            final delay = (r + c) / (rows + cols - 2);
            final cellProg = ((p - delay * 0.4) / 0.6).clamp(0.0, 1.0);
            if (cellProg > 0) {
              final w = cellW * cellProg;
              final h = cellH * cellProg;
              final x = c * cellW + (cellW - w) / 2;
              final y = r * cellH + (cellH - h) / 2;
              path.addRect(Rect.fromLTWH(x, y, w, h));
            }
          }
        }
        break;

      case AnimationClipShape.clockWipe:
        final center = Offset(size.width / 2, size.height / 2);
        final r = math.sqrt(size.width * size.width + size.height * size.height);
        final sweepAngle = 2 * math.pi * p;
        path.moveTo(center.dx, center.dy);
        path.arcTo(
          Rect.fromCircle(center: center, radius: r),
          -math.pi / 2,
          sweepAngle,
          false,
        );
        path.close();
        break;

      case AnimationClipShape.counterClockWipe:
        final center = Offset(size.width / 2, size.height / 2);
        final r = math.sqrt(size.width * size.width + size.height * size.height);
        final sweepAngle = -2 * math.pi * p;
        path.moveTo(center.dx, center.dy);
        path.arcTo(
          Rect.fromCircle(center: center, radius: r),
          -math.pi / 2,
          sweepAngle,
          false,
        );
        path.close();
        break;

      case AnimationClipShape.cornerPin:
        final w = size.width * (p * 0.5);
        final h = size.height * (p * 0.5);
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        path.addRect(Rect.fromLTWH(size.width - w, 0, w, h));
        path.addRect(Rect.fromLTWH(0, size.height - h, w, h));
        path.addRect(Rect.fromLTWH(size.width - w, size.height - h, w, h));
        break;

      case AnimationClipShape.none:
        path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
        break;
    }

    return path;
  }

  @override
  bool shouldReclip(covariant _TransformableAnimationClipper oldClipper) {
    return oldClipper.progress != progress || oldClipper.shape != shape;
  }
}
