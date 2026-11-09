import 'package:flutter/material.dart';
import '../../../../core/models/speed_config_model.dart';

/// Speed Curve Graph Canvas Interaktif:
/// Memungkinkan penambahan titik, penggeseran titik kurva, preview kurva Bézier mulus ala CapCut Pro
class SpeedCurveInteractiveCanvas extends StatefulWidget {
  final SpeedConfigModel speedConfig;
  final ValueChanged<SpeedConfigModel> onConfigChanged;

  const SpeedCurveInteractiveCanvas({
    super.key,
    required this.speedConfig,
    required this.onConfigChanged,
  });

  @override
  State<SpeedCurveInteractiveCanvas> createState() => _SpeedCurveInteractiveCanvasState();
}

class _SpeedCurveInteractiveCanvasState extends State<SpeedCurveInteractiveCanvas> {
  int? _selectedPointIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Info & Controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                'Template: ${widget.speedConfig.curveTemplateId.toUpperCase()}',
                style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // Tombol Tambah Titik
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white70, size: 20),
                tooltip: 'Tambah Titik Kontrol',
                onPressed: _addNewPointAtCenter,
              ),
              // Tombol Hapus Titik Terpilih
              if (_selectedPointIndex != null && widget.speedConfig.curvePoints.length > 2)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFFEF4444), size: 20),
                  tooltip: 'Hapus Titik Terpilih',
                  onPressed: _removeSelectedPoint,
                ),
            ],
          ),
        ),

        // Interactive Canvas Area
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF161622),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanDown: (details) => _handleTouch(details.localPosition, w, h),
                  onPanUpdate: (details) => _handleDrag(details.localPosition, w, h),
                  onPanEnd: (_) => setState(() {}),
                  child: CustomPaint(
                    size: Size(w, h),
                    painter: _SpeedCurvePainter(
                      curvePoints: widget.speedConfig.curvePoints,
                      selectedIndex: _selectedPointIndex,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Titik Terpilih Speed Value Text
        if (_selectedPointIndex != null && _selectedPointIndex! < widget.speedConfig.curvePoints.length)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.speed_rounded, size: 14, color: Color(0xFF00E5FF)),
                const SizedBox(width: 6),
                Text(
                  'Titik #${_selectedPointIndex! + 1}: ${widget.speedConfig.curvePoints[_selectedPointIndex!].y.toStringAsFixed(2)}x Kecepatan',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _handleTouch(Offset localPos, double width, double height) {
    const pad = 24.0;
    final usableW = width - (pad * 2);
    final usableH = height - (pad * 2);

    int? nearestIdx;
    double minDistance = 30.0; // Touch radius

    for (int i = 0; i < widget.speedConfig.curvePoints.length; i++) {
      final pt = widget.speedConfig.curvePoints[i];
      final px = pad + (pt.x * usableW);
      // Logarithmic / linear scale: 0.1x (bawah) s/d 10.0x (atas)
      final py = pad + usableH - ((pt.y - 0.1) / (10.0 - 0.1) * usableH);
      final dist = (Offset(px, py) - localPos).distance;

      if (dist < minDistance) {
        minDistance = dist;
        nearestIdx = i;
      }
    }

    setState(() {
      _selectedPointIndex = nearestIdx;
    });
  }

  void _handleDrag(Offset localPos, double width, double height) {
    if (_selectedPointIndex == null) return;
    final idx = _selectedPointIndex!;
    if (idx >= widget.speedConfig.curvePoints.length) return;

    const pad = 24.0;
    final usableW = width - (pad * 2);
    final usableH = height - (pad * 2);

    // Hitung posisi x & y baru
    var newX = ((localPos.dx - pad) / usableW).clamp(0.0, 1.0);
    // Titik awal & titik akhir x terkunci di 0.0 dan 1.0
    if (idx == 0) newX = 0.0;
    if (idx == widget.speedConfig.curvePoints.length - 1) newX = 1.0;

    final normY = 1.0 - ((localPos.dy - pad) / usableH).clamp(0.0, 1.0);
    final newY = (0.1 + (normY * (10.0 - 0.1))).clamp(0.1, 10.0);

    final updated = List<SpeedCurvePoint>.from(widget.speedConfig.curvePoints);
    updated[idx] = SpeedCurvePoint(x: newX, y: newY);

    // Jaga agar urutan titik x tetap ascending (kecuali titik pertama & terakhir)
    if (idx > 0 && idx < updated.length - 1) {
      updated.sort((a, b) => a.x.compareTo(b.x));
      _selectedPointIndex = updated.indexWhere((p) => (p.x - newX).abs() < 0.01 && (p.y - newY).abs() < 0.01);
    }

    widget.onConfigChanged(
      widget.speedConfig.copyWith(
        curveTemplateId: 'custom',
        curvePoints: updated,
      ),
    );
  }

  void _addNewPointAtCenter() {
    final updated = List<SpeedCurvePoint>.from(widget.speedConfig.curvePoints);
    final newPt = const SpeedCurvePoint(x: 0.5, y: 1.0);
    updated.add(newPt);
    updated.sort((a, b) => a.x.compareTo(b.x));

    final newIdx = updated.indexOf(newPt);
    setState(() {
      _selectedPointIndex = newIdx >= 0 ? newIdx : null;
    });

    widget.onConfigChanged(
      widget.speedConfig.copyWith(
        curveTemplateId: 'custom',
        curvePoints: updated,
      ),
    );
  }

  void _removeSelectedPoint() {
    if (_selectedPointIndex == null) return;
    final idx = _selectedPointIndex!;
    // Jangan hapus ujung batas 0.0 dan 1.0
    if (idx == 0 || idx == widget.speedConfig.curvePoints.length - 1) return;

    final updated = List<SpeedCurvePoint>.from(widget.speedConfig.curvePoints);
    updated.removeAt(idx);

    setState(() {
      _selectedPointIndex = null;
    });

    widget.onConfigChanged(
      widget.speedConfig.copyWith(
        curveTemplateId: 'custom',
        curvePoints: updated,
      ),
    );
  }
}

class _SpeedCurvePainter extends CustomPainter {
  final List<SpeedCurvePoint> curvePoints;
  final int? selectedIndex;

  _SpeedCurvePainter({
    required this.curvePoints,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 24.0;
    final usableW = size.width - (pad * 2);
    final usableH = size.height - (pad * 2);

    // 1. Grid Garis Referensi
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1.0;

    // Garis 1.0x (Normal)
    final y1x = pad + usableH - ((1.0 - 0.1) / (10.0 - 0.1) * usableH);
    final normalLinePaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.25)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(pad, y1x), Offset(pad + usableW, y1x), normalLinePaint);

    // Garis Batas Atas 10.0x & Bawah 0.1x
    canvas.drawLine(Offset(pad, pad), Offset(pad + usableW, pad), gridPaint);
    canvas.drawLine(Offset(pad, pad + usableH), Offset(pad + usableW, pad + usableH), gridPaint);

    // Label 10x, 1x, 0.1x
    final tp10 = _textPainter('10x');
    tp10.paint(canvas, Offset(4, pad - 6));
    final tp1 = _textPainter('1x');
    tp1.paint(canvas, Offset(8, y1x - 6));
    final tp01 = _textPainter('0.1x');
    tp01.paint(canvas, Offset(4, pad + usableH - 6));

    if (curvePoints.isEmpty) return;

    final sorted = List<SpeedCurvePoint>.from(curvePoints)..sort((a, b) => a.x.compareTo(b.x));

    // 2. Gambar Kurva Halus Hermite / Bézier
    final curvePath = Path();
    final fillPath = Path();

    final firstPx = pad + (sorted.first.x * usableW);
    final firstPy = pad + usableH - ((sorted.first.y - 0.1) / (10.0 - 0.1) * usableH);
    curvePath.moveTo(firstPx, firstPy);
    fillPath.moveTo(firstPx, pad + usableH);
    fillPath.lineTo(firstPx, firstPy);

    for (int i = 0; i < sorted.length - 1; i++) {
      final p0 = sorted[i];
      final p1 = sorted[i + 1];

      final x0 = pad + (p0.x * usableW);
      final y0 = pad + usableH - ((p0.y - 0.1) / (10.0 - 0.1) * usableH);
      final x1 = pad + (p1.x * usableW);
      final y1 = pad + usableH - ((p1.y - 0.1) / (10.0 - 0.1) * usableH);

      final ctrlX1 = x0 + (x1 - x0) / 2.0;
      final ctrlX2 = ctrlX1;
      curvePath.cubicTo(ctrlX1, y0, ctrlX2, y1, x1, y1);
      fillPath.cubicTo(ctrlX1, y0, ctrlX2, y1, x1, y1);
    }

    final lastPx = pad + (sorted.last.x * usableW);
    fillPath.lineTo(lastPx, pad + usableH);
    fillPath.close();

    // Fill Gradient di Bawah Kurva
    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF00E5FF).withValues(alpha: 0.25),
        const Color(0xFF00E5FF).withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromLTWH(pad, pad, usableW, usableH));

    canvas.drawPath(fillPath, Paint()..shader = fillGradient);

    // Garis Utama Kurva Kuning Emas Ala CapCut
    final curvePaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(curvePath, curvePaint);

    // 3. Gambar Titik-Titik Kontrol
    for (int i = 0; i < sorted.length; i++) {
      final pt = sorted[i];
      final px = pad + (pt.x * usableW);
      final py = pad + usableH - ((pt.y - 0.1) / (10.0 - 0.1) * usableH);
      final isSel = (selectedIndex == i);

      // Lingkaran luar seleksi
      if (isSel) {
        canvas.drawCircle(
          Offset(px, py),
          10,
          Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.4),
        );
      }

      // Lingkaran utama
      canvas.drawCircle(
        Offset(px, py),
        6,
        Paint()..color = isSel ? const Color(0xFF00E5FF) : Colors.white,
      );

      // Titik tengah
      canvas.drawCircle(
        Offset(px, py),
        3,
        Paint()..color = Colors.black,
      );
    }
  }

  TextPainter _textPainter(String text) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.white38, fontSize: 9, fontFamily: 'monospace'),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    return tp;
  }

  @override
  bool shouldRepaint(covariant _SpeedCurvePainter oldDelegate) => true;
}
