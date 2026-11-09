import 'package:flutter/material.dart';
import '../../../../core/models/clip_transform_model.dart';

/// Interactive Crop Canvas dengan 8 Handle Titik Kontrol, Rule of Thirds Grid, & Center Guides
class InteractiveCropCanvas extends StatefulWidget {
  final ClipTransformModel initialTransform;
  final double videoNaturalAspectRatio;
  final ValueChanged<ClipTransformModel> onTransformChanged;

  const InteractiveCropCanvas({
    super.key,
    required this.initialTransform,
    required this.videoNaturalAspectRatio,
    required this.onTransformChanged,
  });

  @override
  State<InteractiveCropCanvas> createState() => _InteractiveCropCanvasState();
}

class _InteractiveCropCanvasState extends State<InteractiveCropCanvas> {
  late double _cropLeft;
  late double _cropTop;
  late double _cropRight;
  late double _cropBottom;

  @override
  void initState() {
    super.initState();
    _cropLeft = widget.initialTransform.cropLeft;
    _cropTop = widget.initialTransform.cropTop;
    _cropRight = widget.initialTransform.cropRight;
    _cropBottom = widget.initialTransform.cropBottom;
  }

  @override
  void didUpdateWidget(covariant InteractiveCropCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTransform != widget.initialTransform) {
      _cropLeft = widget.initialTransform.cropLeft;
      _cropTop = widget.initialTransform.cropTop;
      _cropRight = widget.initialTransform.cropRight;
      _cropBottom = widget.initialTransform.cropBottom;
    }
  }

  void _notifyChange() {
    widget.onTransformChanged(
      widget.initialTransform.copyWith(
        cropLeft: _cropLeft,
        cropTop: _cropTop,
        cropRight: _cropRight,
        cropBottom: _cropBottom,
      ),
    );
  }

  void resetCrop() {
    setState(() {
      _cropLeft = 0.0;
      _cropTop = 0.0;
      _cropRight = 1.0;
      _cropBottom = 1.0;
    });
    _notifyChange();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Hitung bounding rect aktual video dalam rasio
        double boxW = w;
        double boxH = w / widget.videoNaturalAspectRatio;
        if (boxH > h) {
          boxH = h;
          boxW = h * widget.videoNaturalAspectRatio;
        }

        final offsetX = (w - boxW) / 2.0;
        final offsetY = (h - boxH) / 2.0;

        final cropPixelLeft = offsetX + (_cropLeft * boxW);
        final cropPixelTop = offsetY + (_cropTop * boxH);
        final cropPixelWidth = (_cropRight - _cropLeft) * boxW;
        final cropPixelHeight = (_cropBottom - _cropTop) * boxH;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Dark Mask Dim di Luar Area Crop
            CustomPaint(
              size: Size(w, h),
              painter: _CropOverlayMaskPainter(
                cropRect: Rect.fromLTWH(
                  cropPixelLeft,
                  cropPixelTop,
                  cropPixelWidth,
                  cropPixelHeight,
                ),
                videoRect: Rect.fromLTWH(offsetX, offsetY, boxW, boxH),
              ),
            ),

            // Garis Kotak Crop, Grid Rule-of-Thirds & Center Crosshair
            Positioned(
              left: cropPixelLeft,
              top: cropPixelTop,
              width: cropPixelWidth,
              height: cropPixelHeight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) {
                  // Drag seluruh area crop
                  final deltaX = details.delta.dx / boxW;
                  final deltaY = details.delta.dy / boxH;
                  final cropW = _cropRight - _cropLeft;
                  final cropH = _cropBottom - _cropTop;

                  setState(() {
                    var newL = (_cropLeft + deltaX).clamp(0.0, 1.0 - cropW);
                    var newT = (_cropTop + deltaY).clamp(0.0, 1.0 - cropH);
                    
                    // Snap to Center jika mendekati sumbu tengah
                    final centerDiffX = (newL + cropW / 2.0) - 0.5;
                    if (centerDiffX.abs() < 0.02) {
                      newL = 0.5 - (cropW / 2.0);
                    }
                    final centerDiffY = (newT + cropH / 2.0) - 0.5;
                    if (centerDiffY.abs() < 0.02) {
                      newT = 0.5 - (cropH / 2.0);
                    }

                    _cropLeft = newL;
                    _cropTop = newT;
                    _cropRight = newL + cropW;
                    _cropBottom = newT + cropH;
                  });
                  _notifyChange();
                },
                child: CustomPaint(
                  painter: _CropGridPainter(),
                ),
              ),
            ),

            // 8 Titik Handle Kontrol (4 Sudut + 4 Sisi)
            // Top-Left
            _buildHandle(cropPixelLeft, cropPixelTop, _CropHandle.topLeft, boxW, boxH, offsetX, offsetY),
            // Top-Right
            _buildHandle(cropPixelLeft + cropPixelWidth, cropPixelTop, _CropHandle.topRight, boxW, boxH, offsetX, offsetY),
            // Bottom-Left
            _buildHandle(cropPixelLeft, cropPixelTop + cropPixelHeight, _CropHandle.bottomLeft, boxW, boxH, offsetX, offsetY),
            // Bottom-Right
            _buildHandle(cropPixelLeft + cropPixelWidth, cropPixelTop + cropPixelHeight, _CropHandle.bottomRight, boxW, boxH, offsetX, offsetY),

            // Top-Center
            _buildHandle(cropPixelLeft + cropPixelWidth / 2, cropPixelTop, _CropHandle.topCenter, boxW, boxH, offsetX, offsetY),
            // Bottom-Center
            _buildHandle(cropPixelLeft + cropPixelWidth / 2, cropPixelTop + cropPixelHeight, _CropHandle.bottomCenter, boxW, boxH, offsetX, offsetY),
            // Left-Center
            _buildHandle(cropPixelLeft, cropPixelTop + cropPixelHeight / 2, _CropHandle.centerLeft, boxW, boxH, offsetX, offsetY),
            // Right-Center
            _buildHandle(cropPixelLeft + cropPixelWidth, cropPixelTop + cropPixelHeight / 2, _CropHandle.centerRight, boxW, boxH, offsetX, offsetY),
          ],
        );
      },
    );
  }

  Widget _buildHandle(
    double cx,
    double cy,
    _CropHandle handle,
    double boxW,
    double boxH,
    double offsetX,
    double offsetY,
  ) {
    const handleHitSize = 36.0;
    const handleVisualSize = 14.0;

    return Positioned(
      left: cx - (handleHitSize / 2),
      top: cy - (handleHitSize / 2),
      width: handleHitSize,
      height: handleHitSize,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) {
          final dx = details.delta.dx / boxW;
          final dy = details.delta.dy / boxH;

          setState(() {
            const minSize = 0.15; // Minimum 15% area crop agar tidak terlipat

            switch (handle) {
              case _CropHandle.topLeft:
                _cropLeft = (_cropLeft + dx).clamp(0.0, _cropRight - minSize);
                _cropTop = (_cropTop + dy).clamp(0.0, _cropBottom - minSize);
                break;
              case _CropHandle.topRight:
                _cropRight = (_cropRight + dx).clamp(_cropLeft + minSize, 1.0);
                _cropTop = (_cropTop + dy).clamp(0.0, _cropBottom - minSize);
                break;
              case _CropHandle.bottomLeft:
                _cropLeft = (_cropLeft + dx).clamp(0.0, _cropRight - minSize);
                _cropBottom = (_cropBottom + dy).clamp(_cropTop + minSize, 1.0);
                break;
              case _CropHandle.bottomRight:
                _cropRight = (_cropRight + dx).clamp(_cropLeft + minSize, 1.0);
                _cropBottom = (_cropBottom + dy).clamp(_cropTop + minSize, 1.0);
                break;
              case _CropHandle.topCenter:
                _cropTop = (_cropTop + dy).clamp(0.0, _cropBottom - minSize);
                break;
              case _CropHandle.bottomCenter:
                _cropBottom = (_cropBottom + dy).clamp(_cropTop + minSize, 1.0);
                break;
              case _CropHandle.centerLeft:
                _cropLeft = (_cropLeft + dx).clamp(0.0, _cropRight - minSize);
                break;
              case _CropHandle.centerRight:
                _cropRight = (_cropRight + dx).clamp(_cropLeft + minSize, 1.0);
                break;
            }
          });
          _notifyChange();
        },
        child: Center(
          child: Container(
            width: handleVisualSize,
            height: handleVisualSize,
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.0),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _CropHandle {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  topCenter,
  bottomCenter,
  centerLeft,
  centerRight,
}

/// Painter untuk Masking Gelap di luar Crop Area
class _CropOverlayMaskPainter extends CustomPainter {
  final Rect cropRect;
  final Rect videoRect;

  _CropOverlayMaskPainter({
    required this.cropRect,
    required this.videoRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(cropRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, backgroundPaint);

    // Border video boundaries
    final borderPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(videoRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _CropOverlayMaskPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect || oldDelegate.videoRect != videoRect;
  }
}

/// Painter untuk Garis Kisi Rule of Thirds dan Border Crop Emas
class _CropGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

    // Rule of Thirds Grid Lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final w1 = size.width / 3.0;
    final w2 = size.width * 2.0 / 3.0;
    final h1 = size.height / 3.0;
    final h2 = size.height * 2.0 / 3.0;

    canvas.drawLine(Offset(w1, 0), Offset(w1, size.height), gridPaint);
    canvas.drawLine(Offset(w2, 0), Offset(w2, size.height), gridPaint);
    canvas.drawLine(Offset(0, h1), Offset(size.width, h1), gridPaint);
    canvas.drawLine(Offset(0, h2), Offset(size.width, h2), gridPaint);

    // Corner L-shapes Accent
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    const cornerLen = 14.0;
    // Top-Left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLen, 0), cornerPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLen), cornerPaint);

    // Top-Right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLen, 0), cornerPaint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLen), cornerPaint);

    // Bottom-Left
    canvas.drawLine(Offset(0, size.height), Offset(cornerLen, size.height), cornerPaint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLen), cornerPaint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLen, size.height), cornerPaint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLen), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _CropGridPainter oldDelegate) => false;
}
