import 'package:flutter/material.dart';

/// Mini Visual Preview Scene untuk Thumbnail Filter & Efek Video.
/// Menggantikan placeholder ikon dengan visualisasi nyata dinamis (simulasi shader, blur, glitch, flare, dll)
class FilterPreviewSceneWidget extends StatelessWidget {
  final List<double>? matrix;
  final Widget? effectOverlay;
  final IconData? fallbackIcon;

  const FilterPreviewSceneWidget({
    super.key,
    this.matrix,
    this.effectOverlay,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    Widget scene = const _SampleLandscapeGraphic();

    if (matrix != null) {
      scene = ColorFiltered(
        colorFilter: ColorFilter.matrix(matrix!),
        child: scene,
      );
    }

    if (effectOverlay != null) {
      scene = Stack(
        fit: StackFit.expand,
        children: [
          scene,
          effectOverlay!,
        ],
      );
    }

    return ClipRect(
      child: scene,
    );
  }
}

/// Kanvas Ilustrasi Sinematik Realistis (Matahari terbenam, siluet bukit, langit gradasi)
class _SampleLandscapeGraphic extends StatelessWidget {
  const _SampleLandscapeGraphic();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LandscapePainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _LandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Langit Matahari Terbenam (Sunset Sky Gradient)
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF2C3E50),
          Color(0xFFE74C3C),
          Color(0xFFF39C12),
          Color(0xFFF1C40F),
        ],
        stops: [0.0, 0.45, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // 2. Matahari Bersinar (Sun Disc)
    final sunCenter = Offset(size.width * 0.65, size.height * 0.45);
    final sunRadius = size.width * 0.16;

    final sunGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          const Color(0xFFFFE082).withValues(alpha: 0.8),
          Colors.orange.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: sunRadius * 1.8));
    canvas.drawCircle(sunCenter, sunRadius * 1.8, sunGlow);

    final sunPaint = Paint()..color = const Color(0xFFFFF9C4);
    canvas.drawCircle(sunCenter, sunRadius, sunPaint);

    // 3. Pegunungan Jauh
    final mountainFarPath = Path();
    mountainFarPath.moveTo(0, size.height * 0.75);
    mountainFarPath.lineTo(size.width * 0.25, size.height * 0.58);
    mountainFarPath.lineTo(size.width * 0.5, size.height * 0.68);
    mountainFarPath.lineTo(size.width * 0.78, size.height * 0.52);
    mountainFarPath.lineTo(size.width, size.height * 0.7);
    mountainFarPath.lineTo(size.width, size.height);
    mountainFarPath.lineTo(0, size.height);
    mountainFarPath.close();

    final mountainFarPaint = Paint()..color = const Color(0xFF6C3483).withValues(alpha: 0.85);
    canvas.drawPath(mountainFarPath, mountainFarPaint);

    // 4. Bukit Depan
    final hillNearPath = Path();
    hillNearPath.moveTo(0, size.height * 0.82);
    hillNearPath.quadraticBezierTo(size.width * 0.35, size.height * 0.7, size.width * 0.65, size.height * 0.84);
    hillNearPath.quadraticBezierTo(size.width * 0.85, size.height * 0.9, size.width, size.height * 0.86);
    hillNearPath.lineTo(size.width, size.height);
    hillNearPath.lineTo(0, size.height);
    hillNearPath.close();

    final hillNearPaint = Paint()..color = const Color(0xFF1B2631);
    canvas.drawPath(hillNearPath, hillNearPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dynamic Effect Preview Widget: Merender representasi visual asli tiap efek
class EffectVisualPreviewWidget extends StatelessWidget {
  final IconData icon;
  final String effectName;
  final bool isLarge;

  const EffectVisualPreviewWidget({
    super.key,
    required this.icon,
    required this.effectName,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget overlay = const SizedBox.shrink();
    final lower = effectName.toLowerCase();

    if (lower.contains('letterbox')) {
      overlay = Column(
        children: [
          Container(height: isLarge ? 24 : 12, color: Colors.black),
          const Spacer(),
          Container(height: isLarge ? 24 : 12, color: Colors.black),
        ],
      );
    } else if (lower.contains('glitch') || lower.contains('rgb')) {
      overlay = Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: -2,
            right: 2,
            top: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.4,
              child: Container(color: Colors.red),
            ),
          ),
          Positioned(
            left: 2,
            right: -2,
            top: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.35,
              child: Container(color: Colors.cyanAccent),
            ),
          ),
          CustomPaint(
            painter: _ScanlineOverlayPainter(gap: 3.0),
          ),
        ],
      );
    } else if (lower.contains('scanline') || lower.contains('vhs') || lower.contains('crt')) {
      overlay = CustomPaint(
        painter: _ScanlineOverlayPainter(gap: 4.0),
        child: const SizedBox.expand(),
      );
    } else if (lower.contains('vignette')) {
      overlay = Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 0.85,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
          ),
        ),
      );
    } else if (lower.contains('flare') || lower.contains('light') || lower.contains('glow') || lower.contains('aura')) {
      overlay = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.cyanAccent.withValues(alpha: 0.5),
              Colors.transparent,
              Colors.amberAccent.withValues(alpha: 0.4),
            ],
          ),
        ),
      );
    } else if (lower.contains('blur') || lower.contains('samar') || lower.contains('soft')) {
      overlay = Container(
        color: Colors.white.withValues(alpha: 0.18),
        child: BackdropFilter(
          filter: ColorFilter.mode(Colors.white.withValues(alpha: 0.1), BlendMode.softLight),
          child: const SizedBox.expand(),
        ),
      );
    } else if (lower.contains('cyberpunk') || lower.contains('duotone')) {
      overlay = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purpleAccent.withValues(alpha: 0.5),
              Colors.cyanAccent.withValues(alpha: 0.5),
            ],
          ),
        ),
      );
    } else if (lower.contains('thermal') || lower.contains('heat')) {
      overlay = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.withValues(alpha: 0.6),
              Colors.green.withValues(alpha: 0.5),
              Colors.yellow.withValues(alpha: 0.6),
              Colors.red.withValues(alpha: 0.7),
            ],
          ),
        ),
      );
    } else if (lower.contains('invert')) {
      overlay = Container(
        color: Colors.indigo.withValues(alpha: 0.4),
      );
    } else if (lower.contains('film') || lower.contains('grain') || lower.contains('sepia')) {
      overlay = Container(
        color: const Color(0xFF704214).withValues(alpha: 0.35),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base Scenic Landscape Image
        const _SampleLandscapeGraphic(),
        // Visual Simulation Overlay
        overlay,
        // Center Effect Badge Pill
        if (!isLarge)
          Center(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white30, width: 0.8),
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
          ),
      ],
    );
  }
}

class _ScanlineOverlayPainter extends CustomPainter {
  final double gap;
  const _ScanlineOverlayPainter({this.gap = 4.0});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..strokeWidth = 1.0;

    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
