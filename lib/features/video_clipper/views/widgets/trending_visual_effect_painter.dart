import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Painter Khusus untuk Efek Visual Trending Nyata:
/// - Laser Beam Sweep
/// - Prism Rainbow Flare & Chromatic Dispersion
/// - Supernova Radial Core Burst
/// - 3D Shattered Glass Polygons
/// - Double Helix DNA Twisted Strands
/// - Datamosh Pixel Smear Blocks
/// - TV Static Noise Matrix
/// - VHS Tracking Tear Lines
/// - Blue Anamorphic Horizontal Flare

class TrendingVisualEffectPainter extends CustomPainter {
  final String effectId;
  final double progress; // 0.0 sampai 1.0 (loop)
  final double intensity;

  TrendingVisualEffectPainter({
    required this.effectId,
    required this.progress,
    this.intensity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final id = effectId.toLowerCase();

    // 1. LASER BEAM SWEEP
    if (id.contains('laser')) {
      _paintLaserBeam(canvas, size);
      return;
    }

    // 2. PRISM RAINBOW FLARE
    if (id.contains('prism') || id.contains('rainbow')) {
      _paintPrismRainbow(canvas, size);
      return;
    }

    // 3. SUPERNOVA BURST / CORE
    if (id.contains('supernova')) {
      _paintSupernova(canvas, size);
      return;
    }

    // 4. 3D SHATTERED GLASS
    if (id.contains('shatter')) {
      _paintShatteredGlass(canvas, size);
      return;
    }

    // 5. DOUBLE HELIX TWIST
    if (id.contains('helix')) {
      _paintDoubleHelix(canvas, size);
      return;
    }

    // 6. DATAMOSH SMEAR
    if (id.contains('datamosh') || id.contains('mosh')) {
      _paintDatamosh(canvas, size);
      return;
    }

    // 7. TV STATIC SNOW
    if (id.contains('static') || id.contains('snow')) {
      _paintTvStatic(canvas, size);
      return;
    }

    // 8. VHS TRACKING NOISE
    if (id.contains('vhs') || id.contains('tracking')) {
      _paintVhsTracking(canvas, size);
      return;
    }

    // 9. BLUE ANAMORPHIC STREAK
    if (id.contains('anamorphic') || id.contains('blue_streak')) {
      _paintAnamorphicStreak(canvas, size);
      return;
    }

    // 10. EXPLOSION SHOCKWAVE RING
    if (id.contains('explosion') || id.contains('shockwave')) {
      _paintExplosionShockwave(canvas, size);
      return;
    }

    // 11. CORRUPTED RAM BLOCKS
    if (id.contains('corrupt') || id.contains('block')) {
      _paintCorruptedBlocks(canvas, size);
      return;
    }

    // 12. PIXEL SORT WATERFALL
    if (id.contains('pixel_sort')) {
      _paintPixelSort(canvas, size);
      return;
    }
  }

  void _paintLaserBeam(Canvas canvas, Size size) {
    // Sinar laser horizontal/diagonal melesat dari kiri ke kanan dengan core putih berpendar merah/cyan
    final beamX = (progress * 1.4 - 0.2) * size.width;
    final beamWidth = 14.0 * intensity;

    // Outer glow
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFFFF0055).withValues(alpha: 0.65),
          const Color(0xFF00F0FF).withValues(alpha: 0.85),
          const Color(0xFFFF0055).withValues(alpha: 0.65),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(beamX - beamWidth * 2, 0, beamWidth * 4, size.height));
    canvas.drawRect(Rect.fromLTWH(beamX - beamWidth * 2, 0, beamWidth * 4, size.height), glowPaint);

    // Inner sharp core beam
    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..strokeWidth = 3.5 * intensity
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(beamX, 0), Offset(beamX, size.height), corePaint);
  }

  void _paintPrismRainbow(Canvas canvas, Size size) {
    // Pembiasan prisma spektrum pelangi diagonal melintasi frame
    final angle = 35.0 * math.pi / 180.0;
    final sweep = (progress * size.width * 1.5) - (size.width * 0.25);

    canvas.save();
    canvas.translate(sweep, size.height * 0.5);
    canvas.rotate(angle);

    final rainbowColors = [
      Colors.red.withValues(alpha: 0.0),
      Colors.red.withValues(alpha: 0.45 * intensity),
      Colors.orange.withValues(alpha: 0.5 * intensity),
      Colors.yellow.withValues(alpha: 0.55 * intensity),
      Colors.green.withValues(alpha: 0.5 * intensity),
      Colors.cyan.withValues(alpha: 0.6 * intensity),
      Colors.blue.withValues(alpha: 0.5 * intensity),
      Colors.purple.withValues(alpha: 0.45 * intensity),
      Colors.purple.withValues(alpha: 0.0),
    ];

    final prismPaint = Paint()
      ..shader = LinearGradient(
        colors: rainbowColors,
      ).createShader(Rect.fromLTWH(-30, -size.height, 60, size.height * 2));

    canvas.drawRect(Rect.fromLTWH(-30, -size.height, 60, size.height * 2), prismPaint);
    canvas.restore();
  }

  void _paintSupernova(Canvas canvas, Size size) {
    // Ledakan inti supernova: cincin ekspansi cahaya keemasan/putih menyilaukan dari pusat
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final maxRadius = size.width * 0.75;
    final r = (progress * maxRadius).clamp(0.0, maxRadius);
    final alpha = (1.0 - progress).clamp(0.0, 1.0) * intensity;

    // Glowing core
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: alpha * 0.95),
          const Color(0xFFFFB300).withValues(alpha: alpha * 0.7),
          const Color(0xFFFF3D00).withValues(alpha: alpha * 0.35),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: r + 10));
    canvas.drawCircle(center, r + 10, corePaint);

    // Shockwave ring
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: alpha)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, r, ringPaint);
  }

  void _paintShatteredGlass(Canvas canvas, Size size) {
    // Garis retakan kaca 3D poligon tajam memancar dari titik tengah
    final spread = progress * 6.0 * intensity;

    final crackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85 * intensity)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final fragmentGlow = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.25 * (1.0 - progress) * intensity)
      ..style = PaintingStyle.fill;

    // 6 Pecahan poligon segitiga kaca
    const points = [
      [Offset(0, 0), Offset(0.5, 0.2), Offset(0.2, 0.6)],
      [Offset(0.5, 0.2), Offset(1.0, 0), Offset(0.8, 0.5)],
      [Offset(0.8, 0.5), Offset(1.0, 1.0), Offset(0.5, 0.8)],
      [Offset(0.5, 0.8), Offset(0, 1.0), Offset(0.2, 0.6)],
      [Offset(0.2, 0.6), Offset(0.5, 0.5), Offset(0.5, 0.8)],
      [Offset(0.5, 0.2), Offset(0.8, 0.5), Offset(0.5, 0.5)],
    ];

    for (int i = 0; i < points.length; i++) {
      final poly = points[i];
      final path = Path();
      final dir = (i * 60.0) * math.pi / 180.0;
      final offX = math.cos(dir) * spread;
      final offY = math.sin(dir) * spread;

      path.moveTo(poly[0].dx * size.width + offX, poly[0].dy * size.height + offY);
      path.lineTo(poly[1].dx * size.width + offX, poly[1].dy * size.height + offY);
      path.lineTo(poly[2].dx * size.width + offX, poly[2].dy * size.height + offY);
      path.close();

      canvas.drawPath(path, fragmentGlow);
      canvas.drawPath(path, crackPaint);
    }
  }

  void _paintDoubleHelix(Canvas canvas, Size size) {
    // Dua untaian spiral DNA berputar bersilangan (Strand 1 cyan, Strand 2 magenta)
    final strandPaint1 = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.85 * intensity)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final strandPaint2 = Paint()
      ..color = const Color(0xFFFF007F).withValues(alpha: 0.85 * intensity)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final rungsPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45 * intensity)
      ..strokeWidth = 1.2;

    final path1 = Path();
    final path2 = Path();
    const steps = 18;
    final h = size.height;

    for (int i = 0; i <= steps; i++) {
      final y = (i / steps) * h;
      final phase = (i / steps) * 4 * math.pi + (progress * 2 * math.pi);
      final x1 = (size.width * 0.5) + math.sin(phase) * (size.width * 0.35);
      final x2 = (size.width * 0.5) - math.sin(phase) * (size.width * 0.35);

      if (i == 0) {
        path1.moveTo(x1, y);
        path2.moveTo(x2, y);
      } else {
        path1.lineTo(x1, y);
        path2.lineTo(x2, y);
      }

      if (i % 2 == 0) {
        canvas.drawLine(Offset(x1, y), Offset(x2, y), rungsPaint);
      }
    }

    canvas.drawPath(path1, strandPaint1);
    canvas.drawPath(path2, strandPaint2);
  }

  void _paintDatamosh(Canvas canvas, Size size) {
    // Blok kompresi mosh melorot dan terdistorsi
    final blockPaint1 = Paint()..color = const Color(0x7700FFFF);
    final blockPaint2 = Paint()..color = const Color(0x77FF00FF);
    final step = (progress * 5.0).floor();

    for (int i = 0; i < 4; i++) {
      final y = ((step + i * 2) % 6) * (size.height / 6.0);
      final x = (math.sin(i * 2.0 + progress * 6) * 12.0);
      final w = size.width * (0.3 + (i * 0.15));
      final h = size.height / 7.0;

      canvas.drawRect(Rect.fromLTWH(x, y, w, h), i % 2 == 0 ? blockPaint1 : blockPaint2);
    }
  }

  void _paintTvStatic(Canvas canvas, Size size) {
    // Derau titik semut TV analog acak
    final rand = math.Random((progress * 1000).toInt());
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.45 * intensity);

    for (int i = 0; i < 90; i++) {
      final dx = rand.nextDouble() * size.width;
      final dy = rand.nextDouble() * size.height;
      final w = rand.nextDouble() * 3.5 + 1.0;
      canvas.drawRect(Rect.fromLTWH(dx, dy, w, 1.2), dotPaint);
    }
  }

  void _paintVhsTracking(Canvas canvas, Size size) {
    // Garis pita kusut tracking error bergerak vertikal dari bawah ke atas
    final barY = ((1.0 - progress) * size.height * 1.3) - (size.height * 0.15);
    final tearPaint = Paint()..color = Colors.white.withValues(alpha: 0.75 * intensity);
    final blueChromaPaint = Paint()..color = Colors.cyanAccent.withValues(alpha: 0.5 * intensity);

    canvas.drawRect(Rect.fromLTWH(0, barY, size.width, 5.0), tearPaint);
    canvas.drawRect(Rect.fromLTWH(-4, barY + 4, size.width + 8, 3.0), blueChromaPaint);
  }

  void _paintAnamorphicStreak(Canvas canvas, Size size) {
    // Garis biru horizontal tajam melintang di sepertiga atas
    final cy = size.height * 0.42;
    final pulse = (math.sin(progress * math.pi * 2.0).abs() * 0.4 + 0.6) * intensity;

    final streakPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF00D4FF).withValues(alpha: 0.35 * pulse),
          Colors.white.withValues(alpha: 0.95 * pulse),
          const Color(0xFF0077FF).withValues(alpha: 0.85 * pulse),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(0, cy - 8, size.width, 16));

    canvas.drawRect(Rect.fromLTWH(0, cy - 8, size.width, 16), streakPaint);

    final coreLine = Paint()
      ..color = Colors.white.withValues(alpha: pulse)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), coreLine);
  }

  void _paintExplosionShockwave(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final r = progress * size.width * 0.75;
    final alpha = (1.0 - progress).clamp(0.0, 1.0) * intensity;

    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: alpha * 0.9)
      ..strokeWidth = 3.5 * (1.0 - progress * 0.5)
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, r, wavePaint);
  }

  void _paintCorruptedBlocks(Canvas canvas, Size size) {
    final p1 = Paint()..color = Colors.cyan.withValues(alpha: 0.45 * intensity);
    final p2 = Paint()..color = Colors.redAccent.withValues(alpha: 0.45 * intensity);
    final p3 = Paint()..color = Colors.yellowAccent.withValues(alpha: 0.45 * intensity);

    final step = (progress * 6.0).floor();
    canvas.drawRect(Rect.fromLTWH((step * 15.0) % size.width, size.height * 0.2, 28, 18), p1);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.5, (step * 22.0) % size.height, 35, 14), p2);
    canvas.drawRect(Rect.fromLTWH((size.width * 0.7) - step * 5, size.height * 0.65, 40, 16), p3);
  }

  void _paintPixelSort(Canvas canvas, Size size) {
    // Garis lumer vertikal ke bawah
    final sortPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.6 * intensity),
          Colors.cyanAccent.withValues(alpha: 0.7 * intensity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    for (int i = 0; i < 7; i++) {
      final x = (i * (size.width / 7.0)) + 3;
      final y = (progress * size.height * 0.7);
      canvas.drawRect(Rect.fromLTWH(x, y, 4.0, size.height * 0.4), sortPaint);
    }
  }

  @override
  bool shouldRepaint(covariant TrendingVisualEffectPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.effectId != effectId ||
        oldDelegate.intensity != intensity;
  }
}
