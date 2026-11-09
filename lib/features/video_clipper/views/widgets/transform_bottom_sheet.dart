import 'package:flutter/material.dart';
import '../../../../core/models/clip_transform_model.dart';

class TransformBottomSheet extends StatefulWidget {
  final ClipTransformModel currentTransform;
  final VoidCallback? onOpenAdvancedRatioSheet;
  final VoidCallback? onOpenSpeedCurveSheet;

  const TransformBottomSheet({
    super.key,
    required this.currentTransform,
    this.onOpenAdvancedRatioSheet,
    this.onOpenSpeedCurveSheet,
  });

  static Future<ClipTransformModel?> show(
    BuildContext context, {
    required ClipTransformModel currentTransform,
    VoidCallback? onOpenAdvancedRatioSheet,
    VoidCallback? onOpenSpeedCurveSheet,
  }) {
    return showModalBottomSheet<ClipTransformModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransformBottomSheet(
        currentTransform: currentTransform,
        onOpenAdvancedRatioSheet: onOpenAdvancedRatioSheet,
        onOpenSpeedCurveSheet: onOpenSpeedCurveSheet,
      ),
    );
  }

  @override
  State<TransformBottomSheet> createState() => _TransformBottomSheetState();
}

class _TransformBottomSheetState extends State<TransformBottomSheet> {
  late ClipTransformModel _transform;

  @override
  void initState() {
    super.initState();
    _transform = widget.currentTransform;
  }

  void _rotate90() {
    setState(() {
      _transform = _transform.copyWith(
        rotationDegrees: (_transform.rotationDegrees + 90) % 360,
      );
    });
  }

  void _toggleFlipHorizontal() {
    setState(() {
      _transform = _transform.copyWith(
        flipHorizontal: !_transform.flipHorizontal,
      );
    });
  }

  void _toggleFlipVertical() {
    setState(() {
      _transform = _transform.copyWith(
        flipVertical: !_transform.flipVertical,
      );
    });
  }

  void _toggleFitMode() {
    setState(() {
      _transform = _transform.copyWith(
        fitMode: _transform.fitMode == FitMode.fit ? FitMode.fill : FitMode.fit,
      );
    });
  }

  void _reset() {
    setState(() {
      _transform = const ClipTransformModel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF14141E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Header Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Transformasi & Kanvas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Navigator.pop(context, _transform),
                    child: const Text('Terapkan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Baris Opsi Transformasi Cepat
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    // 1. Putar 90°
                    _buildToolButton(
                      icon: Icons.rotate_90_degrees_cw_rounded,
                      label: 'Putar 90° (${_transform.rotationDegrees}°)',
                      isActive: _transform.rotationDegrees != 0,
                      onTap: _rotate90,
                    ),
                    const SizedBox(width: 10),

                    // 2. Cermin Horizontal (Mirror H)
                    _buildToolButton(
                      icon: Icons.flip_rounded,
                      label: 'Cermin H',
                      isActive: _transform.flipHorizontal,
                      onTap: _toggleFlipHorizontal,
                    ),
                    const SizedBox(width: 10),

                    // 3. Cermin Vertikal (Flip V)
                    _buildToolButton(
                      icon: Icons.flip_camera_android_rounded,
                      label: 'Cermin V',
                      isActive: _transform.flipVertical,
                      onTap: _toggleFlipVertical,
                    ),
                    const SizedBox(width: 10),

                    // 4. Mode Fit / Fill
                    _buildToolButton(
                      icon: _transform.fitMode == FitMode.fit ? Icons.fit_screen_rounded : Icons.fullscreen_rounded,
                      label: _transform.fitMode == FitMode.fit ? 'Mode Fit' : 'Mode Fill',
                      isActive: _transform.fitMode == FitMode.fill,
                      onTap: _toggleFitMode,
                    ),
                    const SizedBox(width: 10),

                    // 5. Kurva Kecepatan
                    _buildToolButton(
                      icon: Icons.show_chart_rounded,
                      label: 'Kurva Kustom',
                      isActive: false,
                      onTap: () {
                        Navigator.pop(context, _transform);
                        widget.onOpenSpeedCurveSheet?.call();
                      },
                    ),
                    const SizedBox(width: 10),

                    // 6. Reset
                    _buildToolButton(
                      icon: Icons.refresh_rounded,
                      label: 'Reset',
                      isActive: false,
                      isDestructive: true,
                      onTap: _reset,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tombol Pemilihan Aspek Rasio Kanvas
              InkWell(
                onTap: () {
                  Navigator.pop(context, _transform);
                  widget.onOpenAdvancedRatioSheet?.call();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.aspect_ratio_rounded, color: Color(0xFF00E5FF), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Aspek Rasio & Kanvas',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Format: ${_getRatioLabel(_transform.canvasRatio)} (Ketuk untuk ubah)',
                              style: const TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required bool isActive,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 82,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF00E5FF).withValues(alpha: 0.15)
              : const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? const Color(0xFF00E5FF)
                : (isDestructive ? Colors.redAccent.withValues(alpha: 0.4) : Colors.white10),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive
                  ? const Color(0xFF00E5FF)
                  : (isDestructive ? Colors.redAccent : Colors.white70),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isActive ? const Color(0xFF00E5FF) : Colors.white70,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getRatioLabel(CanvasRatioMode mode) {
    switch (mode) {
      case CanvasRatioMode.original:
        return 'Original';
      case CanvasRatioMode.ratio9x16:
        return '9:16 (TikTok/Shorts)';
      case CanvasRatioMode.ratio16x9:
        return '16:9 (YouTube)';
      case CanvasRatioMode.ratio1x1:
        return '1:1 (Square)';
      case CanvasRatioMode.ratio4x5:
        return '4:5 (IG Feed)';
      case CanvasRatioMode.ratio3x4:
        return '3:4 (Tablet)';
      case CanvasRatioMode.ratio4x3:
        return '4:3 (Classic)';
      case CanvasRatioMode.ratio2x1:
        return '2:1 (Univisium)';
      case CanvasRatioMode.ratio185x1:
        return '1.85:1 (Cinema)';
      case CanvasRatioMode.ratio235x1:
        return '2.35:1 (Scope)';
      case CanvasRatioMode.ratio239x1:
        return '2.39:1 (Panavision)';
      case CanvasRatioMode.ratio21x9:
        return '21:9 (Cinema)';
      case CanvasRatioMode.custom:
        return 'Kustom';
    }
  }
}

