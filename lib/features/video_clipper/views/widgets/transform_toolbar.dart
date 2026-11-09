import 'package:flutter/material.dart';
import '../../../../core/models/clip_transform_model.dart';

class TransformToolbar extends StatelessWidget {
  final ClipTransformModel currentTransform;
  final ValueChanged<ClipTransformModel> onTransformChanged;
  final VoidCallback? onOpenAdvancedRatioSheet;

  const TransformToolbar({
    super.key,
    required this.currentTransform,
    required this.onTransformChanged,
    this.onOpenAdvancedRatioSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF181826),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Pilihan Aspek Rasio (Klik membuka BottomSheet Rasio Lengkap)
          GestureDetector(
            onTap: onOpenAdvancedRatioSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.aspect_ratio_rounded, size: 16, color: Color(0xFF00E5FF)),
                  const SizedBox(width: 6),
                  Text(
                    'Rasio: ${_getRatioLabel(currentTransform.canvasRatio)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),

          // Action Icons Transformasi
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fit / Fill Toggle
              IconButton(
                tooltip: currentTransform.fitMode == FitMode.fit ? 'Mode Fit' : 'Mode Fill',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  currentTransform.fitMode == FitMode.fit ? Icons.fit_screen_rounded : Icons.fullscreen_rounded,
                  color: const Color(0xFF00E5FF),
                  size: 20,
                ),
                onPressed: () {
                  final next = currentTransform.fitMode == FitMode.fit ? FitMode.fill : FitMode.fit;
                  onTransformChanged(currentTransform.copyWith(fitMode: next));
                },
              ),

              // Rotasi 90 Derajat
              IconButton(
                tooltip: 'Putar 90°',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.rotate_90_degrees_cw_rounded, color: Colors.white70, size: 20),
                onPressed: () {
                  final nextRot = (currentTransform.rotationDegrees + 90) % 360;
                  onTransformChanged(currentTransform.copyWith(rotationDegrees: nextRot));
                },
              ),

              // Flip Horizontal
              IconButton(
                tooltip: 'Cermin (Flip H)',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.flip_rounded,
                  color: currentTransform.flipHorizontal ? const Color(0xFFA78BFA) : Colors.white70,
                  size: 20,
                ),
                onPressed: () {
                  onTransformChanged(
                    currentTransform.copyWith(flipHorizontal: !currentTransform.flipHorizontal),
                  );
                },
              ),

              // Flip Vertikal
              IconButton(
                tooltip: 'Balik (Flip V)',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.flip_camera_android_rounded,
                  color: currentTransform.flipVertical ? const Color(0xFFA78BFA) : Colors.white70,
                  size: 20,
                ),
                onPressed: () {
                  onTransformChanged(
                    currentTransform.copyWith(flipVertical: !currentTransform.flipVertical),
                  );
                },
              ),

              // Reset Transform
              IconButton(
                tooltip: 'Reset Kanvas',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFFF87171), size: 20),
                onPressed: () {
                  onTransformChanged(const ClipTransformModel());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getRatioLabel(CanvasRatioMode mode) {
    switch (mode) {
      case CanvasRatioMode.original:
        return 'Original';
      case CanvasRatioMode.ratio9x16:
        return '9:16';
      case CanvasRatioMode.ratio16x9:
        return '16:9';
      case CanvasRatioMode.ratio1x1:
        return '1:1';
      case CanvasRatioMode.ratio4x5:
        return '4:5';
      case CanvasRatioMode.ratio3x4:
        return '3:4';
      case CanvasRatioMode.ratio4x3:
        return '4:3';
      case CanvasRatioMode.ratio2x1:
        return '2:1';
      case CanvasRatioMode.ratio185x1:
        return '1.85:1';
      case CanvasRatioMode.ratio235x1:
        return '2.35:1';
      case CanvasRatioMode.ratio239x1:
        return '2.39:1';
      case CanvasRatioMode.ratio21x9:
        return '21:9';
      case CanvasRatioMode.custom:
        return 'Custom';
    }
  }
}
