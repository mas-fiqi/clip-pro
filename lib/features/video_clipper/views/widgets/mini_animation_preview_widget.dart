import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/models/animation_model.dart';
import 'trending_visual_effect_painter.dart';
import 'glitch_visual_effect_painter.dart';

/// Custom Clipper untuk Efek Iris (Lingkaran & Diamond) dan Wipe
class AnimationShapeClipper extends CustomClipper<Path> {
  final AnimationClipShape shape;
  final double progress; // 0.0 sampai 1.0

  AnimationShapeClipper({
    required this.shape,
    required this.progress,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final p = progress.clamp(0.0, 1.0);

    switch (shape) {
      case AnimationClipShape.circleIris:
        // Lingkaran membesar dari tengah
        final center = Offset(size.width / 2, size.height / 2);
        final maxRadius = math.sqrt(size.width * size.width + size.height * size.height) / 2;
        final currentRadius = maxRadius * p;
        path.addOval(Rect.fromCircle(center: center, radius: currentRadius));
        break;

      case AnimationClipShape.diamondIris:
        // Belah ketupat membesar dari tengah
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
        // Pentagon 5-sisi geometris presisi
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
        // Bintang 5-sudut simetris membesar dari poros tengah
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
        // Sapuan sudut dari Top-Left ke Bottom-Right
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
        // Sapuan diagonal dari Bottom-Right ke Top-Left
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
        // Menutup tirai dari tepi luar menuju tengah
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
        // Sapuan jarum jam lingkaran penuh
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
        // Sapuan berlawanan jarum jam
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
        // Perluasan dari 4 titik sudut kanvas menyatu ke tengah
        final w = size.width * (p * 0.5);
        final h = size.height * (p * 0.5);
        path.addRect(Rect.fromLTWH(0, 0, w, h)); // Top-Left
        path.addRect(Rect.fromLTWH(size.width - w, 0, w, h)); // Top-Right
        path.addRect(Rect.fromLTWH(0, size.height - h, w, h)); // Bottom-Left
        path.addRect(Rect.fromLTWH(size.width - w, size.height - h, w, h)); // Bottom-Right
        break;

      case AnimationClipShape.none:
        path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
        break;
    }

    return path;
  }

  @override
  bool shouldReclip(covariant AnimationShapeClipper oldClipper) {
    return oldClipper.progress != progress || oldClipper.shape != shape;
  }
}

/// Mini Animation Preview Widget dengan demonstrasi visual dinamis
class MiniAnimationPreviewWidget extends StatefulWidget {
  final AnimationPresetModel preset;
  final bool isSelected;

  const MiniAnimationPreviewWidget({
    super.key,
    required this.preset,
    this.isSelected = false,
  });

  @override
  State<MiniAnimationPreviewWidget> createState() => _MiniAnimationPreviewWidgetState();
}

class _MiniAnimationPreviewWidgetState extends State<MiniAnimationPreviewWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  static const List<String> _diverseSubjects = [
    'assets/images/effect_previews/woman_portrait.jpg',
    'assets/images/effect_previews/man_model.jpg',
    'assets/images/effect_previews/portrait_girl.jpg',
    'assets/images/effect_previews/portrait_boy.jpg',
    'assets/images/effect_previews/cool_boy.jpg',
    'assets/images/effect_previews/portrait_glamour.jpg',
    'assets/images/effect_previews/portrait_man.jpg',
    'assets/images/effect_previews/portrait_woman.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _selectSubjectAsset(String name, AnimationCategory category, String id) {
    // Untuk kategori Shake dan Glitch, gunakan subject konsisten berorientasi vertikal/horizontal jelas
    // agar pergerakan kinematik trajectory dan artefak dapat langsung terlihat dan dibanding-bandingkan user tanpa distraksi foto acak.
    if (category == AnimationCategory.shake || category == AnimationCategory.glitch) {
      return 'assets/images/effect_previews/portrait_man.jpg';
    }

    // Gunakan hash polinomial dari ID unik preset agar setiap preset kartu mendapat foto yang berbeda-beda
    int hash = 17;
    for (int i = 0; i < id.length; i++) {
      hash = (hash * 31 + id.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return _diverseSubjects[hash % _diverseSubjects.length];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        final t = _animController.value;
        final subjectAsset = _selectSubjectAsset(widget.preset.name, widget.preset.category, widget.preset.id);

        // Evaluasi transformasi animasi nyata
        final animModel = ClipAnimationModel(
          presetId: widget.preset.id,
          type: widget.preset.type,
          duration: 1.6,
          intensity: 1.0,
        );
        final res = animModel.evaluate(timeInClip: t * 1.6, totalClipDuration: 1.6);

        final scale = res.scale.clamp(0.2, 2.5);
        final rot = res.rotationDegrees * math.pi / 180.0;
        final posX = res.positionX * 36.0;
        final posY = res.positionY * 36.0;
        final opacity = res.opacity.clamp(0.05, 1.0);

        Widget imageContent = Image.asset(
          subjectAsset,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF2A2D35),
            child: const Icon(Icons.movie, color: Colors.white24),
          ),
        );

        // 1. Terapkan Blur nyata jika ada
        if (res.blurRadius > 0.0) {
          imageContent = ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: res.blurRadius * 0.5, sigmaY: res.blurRadius * 0.5),
            child: imageContent,
          );
        }

        // 2. Terapkan Chromatic Aberration RGB Split jika ada
        if (res.chromaticAberration > 0.0) {
          final splitOffset = res.chromaticAberration * 20.0;
          imageContent = Stack(
            fit: StackFit.expand,
            children: [
              Transform.translate(
                offset: Offset(splitOffset, 0),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(Colors.redAccent, BlendMode.screen),
                  child: imageContent,
                ),
              ),
              Transform.translate(
                offset: Offset(-splitOffset, 0),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(Colors.cyanAccent, BlendMode.screen),
                  child: imageContent,
                ),
              ),
            ],
          );
        }

        // 3. Terapkan Clipping Geometris Nyata (Circle Iris, Diamond Iris, Wipe, Blinds, Split)
        if (res.clipShape != AnimationClipShape.none) {
          imageContent = ClipPath(
            clipper: AnimationShapeClipper(
              shape: res.clipShape,
              progress: res.clipProgress,
            ),
            child: imageContent,
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161622),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected ? const Color(0xFF23D2E2) : Colors.white12,
              width: widget.isSelected ? 2.0 : 0.8,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              // Background gelap di balik clipping shape
              Container(color: const Color(0xFF0F1016)),

              // Transformasi 3D Perspektif Nyata + 2D Posisi, Rotasi, Skala
              Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, res.perspective)
                  ..rotateX(res.rotateXDegrees * math.pi / 180.0)
                  ..rotateY(res.rotateYDegrees * math.pi / 180.0)
                  ..rotateZ(rot),
                alignment: Alignment.center,
                child: Transform.translate(
                  offset: Offset(posX, posY),
                  child: Transform.scale(
                    scale: scale,
                    child: Transform.scale(
                      scaleX: res.scaleX,
                      scaleY: res.scaleY,
                      child: Opacity(
                        opacity: opacity,
                        child: imageContent,
                      ),
                    ),
                  ),
                ),
              ),

              // Scanlines CRT jika aktif
              if (res.scanlineIntensity > 0.0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.5, 0.51, 1.0],
                          colors: [
                            Colors.black.withValues(alpha: 0.35 * res.scanlineIntensity),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.35 * res.scanlineIntensity),
                            Colors.transparent,
                          ],
                          tileMode: TileMode.repeated,
                        ),
                      ),
                    ),
                  ),
                ),

              // Flash & Glow Overlay Nyata jika ada (maksimal alpha 0.45 agar foto tetap terlihat jelas)
              if (res.flashOpacity > 0.0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(
                      color: Colors.white.withValues(alpha: res.flashOpacity.clamp(0.0, 0.45)),
                    ),
                  ),
                ),

              // Color Overlay Nyata untuk Dip to Black & Dip to White
              if (res.colorOverlayOpacity > 0.0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(
                      color: Color(res.colorOverlayValue).withValues(alpha: res.colorOverlayOpacity.clamp(0.0, 1.0)),
                    ),
                  ),
                ),

              // Trending Real Visual Canvas Overlay (Laser sweep, Prism flare, Supernova shockwave, Shatter glass, etc.)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: TrendingVisualEffectPainter(
                      effectId: widget.preset.id,
                      progress: t,
                      intensity: 1.0,
                    ),
                  ),
                ),
              ),

              // Glitch Batch 1 Visual Canvas Overlay (Pixel sort, static snow, tracking bands, interlaced, matrix, neon slice)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: GlitchVisualEffectPainter(
                      effectId: widget.preset.id,
                      progress: t,
                      intensity: 1.0,
                    ),
                  ),
                ),
              ),



              // Selection Halo Overlay
              if (widget.isSelected)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF23D2E2), width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
