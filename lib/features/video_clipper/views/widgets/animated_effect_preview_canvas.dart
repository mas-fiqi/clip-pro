import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/models/video_effect_model.dart';

/// Animated Live Effect Preview Canvas dengan Model Manusia Realistis ala CapCut
/// Menghadirkan model foto potret nyata (pria & wanita fotogenik) dengan simulasi efek visual dinamis 60fps
class AnimatedEffectPreviewCanvas extends StatefulWidget {
  final EffectType effectType;
  final String effectName;
  final bool isLarge;
  final String? customImageUrl;

  const AnimatedEffectPreviewCanvas({
    super.key,
    required this.effectType,
    required this.effectName,
    this.isLarge = false,
    this.customImageUrl,
  });

  @override
  State<AnimatedEffectPreviewCanvas> createState() => _AnimatedEffectPreviewCanvasState();
}

class _AnimatedEffectPreviewCanvasState extends State<AnimatedEffectPreviewCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Pilih foto model yang paling cocok dengan karakter efeknya
  String _selectModelImage(EffectType type, String lower) {
    if (type == EffectType.vhsTape || type == EffectType.oldFilmGrain || type == EffectType.sepiaFilm) {
      return 'assets/images/effect_previews/retro_vintage.jpg';
    }
    if (type == EffectType.cyberpunkGlow || type == EffectType.duotoneCyanRed || lower.contains('neon')) {
      return 'assets/images/effect_previews/cinematic_neon.jpg';
    }
    if (type == EffectType.stutterMotion || type == EffectType.speedLines || lower.contains('action')) {
      return 'assets/images/effect_previews/cool_boy.jpg';
    }
    if (type == EffectType.lensBrightness || type == EffectType.lightLeak || type == EffectType.glowAura) {
      return 'assets/images/effect_previews/woman_portrait.jpg';
    }
    if (type == EffectType.motionBlur || type == EffectType.zoomPulse) {
      return 'assets/images/effect_previews/man_model.jpg';
    }
    if (type.index % 2 == 0) {
      return 'assets/images/effect_previews/woman_portrait.jpg';
    }
    return 'assets/images/effect_previews/man_model.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return _buildEffectScene(t);
      },
    );
  }

  Widget _buildEffectScene(double t) {
    final type = widget.effectType;
    final lower = widget.effectName.toLowerCase();
    final modelAsset = _selectModelImage(type, lower);

    // Transformasi gerakan & overlay efek
    double scale = 1.0;
    double rotAngle = 0.0;
    Offset translateOffset = Offset.zero;
    Widget effectOverlay = const SizedBox.shrink();
    ColorFilter? colorFilter;

    // 1. STUTTER STOP-MOTION (Claymation 12 FPS)
    if (type == EffectType.stutterMotion || lower.contains('stutter') || lower.contains('stop-motion')) {
      final step = (t * 4).floor() / 4.0;
      final stepX = math.sin(step * math.pi * 2) * (widget.isLarge ? 14.0 : 6.0);
      translateOffset = Offset(stepX, 0);
      effectOverlay = Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text('12 FPS', style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold)),
        ),
      );
    }
    // 2. RGB SPLIT & GLITCH
    else if (type == EffectType.rgbSplit || type == EffectType.colorGlitch || lower.contains('glitch') || lower.contains('rgb')) {
      final glitchCycle = ((t * 8).floor() % 3 == 0);
      if (glitchCycle) {
        translateOffset = Offset((t % 0.1 > 0.05 ? 4.0 : -4.0), 0);
      }
      effectOverlay = CustomPaint(
        painter: _DynamicGlitchSlicePainter(progress: t),
        child: const SizedBox.expand(),
      );
    }
    // 3. RETRO CRT TV SCANLINES & VHS TAPE
    else if (type == EffectType.retroScanline || type == EffectType.vhsTape || lower.contains('scanline') || lower.contains('crt') || lower.contains('vhs')) {
      effectOverlay = Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _ScrollingScanlinePainter(offsetY: t * 40.0),
            child: const SizedBox.expand(),
          ),
          if (type == EffectType.vhsTape || lower.contains('vhs'))
            Positioned(
              top: 4,
              left: 6,
              child: Text(
                'VHS PLAY ►',
                style: TextStyle(
                  color: Colors.cyanAccent.withValues(alpha: 0.9),
                  fontSize: widget.isLarge ? 10.0 : 7.5,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                ),
              ),
            ),
        ],
      );
    }
    // 4. ZOOM PULSE & IMPACT FLASH
    else if (type == EffectType.zoomPulse || lower.contains('pulse') || lower.contains('zoom')) {
      final pulse = math.sin(t * math.pi * 2);
      scale = 1.0 + (pulse.abs() * 0.16);
      if (pulse > 0.7) {
        effectOverlay = Container(
          color: Colors.white.withValues(alpha: (pulse - 0.7) * 2.0 * 0.6),
        );
      }
    }
    // 5. MOTION BLUR (GERAK SAMAR CAPCUT)
    else if (type == EffectType.motionBlur || lower.contains('blur') || lower.contains('samar')) {
      final blurSweep = math.sin(t * math.pi * 2);
      translateOffset = Offset(blurSweep * (widget.isLarge ? 18.0 : 8.0), 0);
      effectOverlay = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.cyanAccent.withValues(alpha: 0.25),
              Colors.transparent,
              Colors.cyanAccent.withValues(alpha: 0.25),
            ],
          ),
        ),
      );
    }
    // 6. CINEMATIC LETTERBOX 2.35:1
    else if (type == EffectType.letterbox || lower.contains('letterbox') || lower.contains('cinematic')) {
      effectOverlay = Column(
        children: [
          Container(height: widget.isLarge ? 14 : 9, color: Colors.black),
          const Spacer(),
          Container(height: widget.isLarge ? 14 : 9, color: Colors.black),
        ],
      );
    }
    // 7. OLD FILM GRAIN & SEPIA
    else if (type == EffectType.oldFilmGrain || type == EffectType.sepiaFilm || lower.contains('film') || lower.contains('sepia')) {
      colorFilter = const ColorFilter.matrix(<double>[
        0.393, 0.769, 0.189, 0, 0,
        0.349, 0.686, 0.168, 0, 0,
        0.272, 0.534, 0.131, 0, 0,
        0,     0,     0,     1, 0,
      ]);
      effectOverlay = CustomPaint(
        painter: _FilmFlickerDustPainter(seed: (t * 20).toInt()),
        child: const SizedBox.expand(),
      );
    }
    // 8. ANAMORPHIC FLARE & LIGHT LEAK
    else if (type == EffectType.anamorphicFlare || type == EffectType.lightLeak || lower.contains('flare') || lower.contains('leak')) {
      final flareX = (math.sin(t * math.pi * 2) * 0.5) + 0.5;
      effectOverlay = Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment((flareX * 2.0) - 1.0, -0.2),
            radius: 0.8,
            colors: [
              Colors.amberAccent.withValues(alpha: 0.75),
              Colors.deepOrangeAccent.withValues(alpha: 0.35),
              Colors.transparent,
            ],
          ),
        ),
      );
    }
    // 9. MIRROR HORIZONTAL & VERTICAL
    else if (type == EffectType.mirrorHorizontal || lower.contains('mirror') || lower.contains('cermin')) {
      effectOverlay = Row(
        children: [
          Expanded(child: Container(color: Colors.transparent)),
          Container(width: 1.5, color: Colors.cyanAccent.withValues(alpha: 0.8)),
          Expanded(
            child: Transform.flip(
              flipX: true,
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      );
    }
    // 10. THERMAL HEAT VISION
    else if (type == EffectType.thermalVision || lower.contains('thermal') || lower.contains('heat')) {
      effectOverlay = Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x990000FF),
              Color(0x9900FF00),
              Color(0x99FFFF00),
              Color(0x99FF0000),
            ],
          ),
        ),
      );
    }
    // 11. CYBERPUNK NEON & DUOTONE
    else if (type == EffectType.cyberpunkGlow || type == EffectType.duotoneCyanRed || lower.contains('cyberpunk') || lower.contains('neon')) {
      final neonGlow = 0.45 + (math.sin(t * math.pi * 4) * 0.15);
      effectOverlay = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purpleAccent.withValues(alpha: neonGlow),
              Colors.cyanAccent.withValues(alpha: neonGlow),
            ],
          ),
        ),
      );
    }
    // 12. GLOW AURA / BERSINAR
    else if (type == EffectType.glowAura || lower.contains('glow') || lower.contains('bersinar')) {
      final aura = 0.35 + (math.sin(t * math.pi * 3) * 0.2);
      effectOverlay = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withValues(alpha: aura),
              blurRadius: 18,
              spreadRadius: 4,
            ),
          ],
        ),
      );
    }

    // Render adegan foto model asli dengan filter & efek dinamis
    final imagePath = widget.customImageUrl ?? modelAsset;
    Widget imageWidget = imagePath.startsWith('http')
        ? Image.network(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              modelAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _FallbackPhotogenicGraphic(),
            ),
          )
        : Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) => const _FallbackPhotogenicGraphic(),
          );

    if (colorFilter != null) {
      imageWidget = ColorFiltered(
        colorFilter: colorFilter,
        child: imageWidget,
      );
    }

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gambar Model Foto Asli dengan Transformasi
          Transform.translate(
            offset: translateOffset,
            child: Transform.rotate(
              angle: rotAngle,
              child: Transform.scale(
                scale: scale,
                child: imageWidget,
              ),
            ),
          ),
          // Dynamic Effect Overlay
          effectOverlay,
        ],
      ),
    );
  }
}

/// Fallback Graphic jika foto aset belum terpasang sempurna
class _FallbackPhotogenicGraphic extends StatelessWidget {
  const _FallbackPhotogenicGraphic();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2C3E50),
            Color(0xFF1A252F),
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.person_rounded, size: 36, color: Colors.white30),
      ),
    );
  }
}

class _ScrollingScanlinePainter extends CustomPainter {
  final double offsetY;
  const _ScrollingScanlinePainter({required this.offsetY});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..strokeWidth = 1.2;

    for (double y = offsetY % 4.0; y < size.height; y += 4.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScrollingScanlinePainter oldDelegate) => oldDelegate.offsetY != offsetY;
}

class _DynamicGlitchSlicePainter extends CustomPainter {
  final double progress;
  const _DynamicGlitchSlicePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random((progress * 30).toInt());
    if (rand.nextDouble() > 0.6) {
      final sliceY = rand.nextDouble() * size.height;
      final sliceH = rand.nextDouble() * 8.0 + 2.0;
      final slicePaint = Paint()
        ..color = (rand.nextBool() ? Colors.cyanAccent : Colors.redAccent).withValues(alpha: 0.4);
      canvas.drawRect(Rect.fromLTWH(0, sliceY, size.width, sliceH), slicePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DynamicGlitchSlicePainter oldDelegate) => oldDelegate.progress != progress;
}

class _FilmFlickerDustPainter extends CustomPainter {
  final int seed;
  const _FilmFlickerDustPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(seed);
    final dustPaint = Paint()..color = Colors.white.withValues(alpha: 0.6);

    for (int i = 0; i < 4; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.8, dustPaint);
    }

    if (rand.nextDouble() > 0.7) {
      final lineX = rand.nextDouble() * size.width;
      final scratchPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..strokeWidth = 0.8;
      canvas.drawLine(Offset(lineX, 0), Offset(lineX, size.height), scratchPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FilmFlickerDustPainter oldDelegate) => oldDelegate.seed != seed;
}
