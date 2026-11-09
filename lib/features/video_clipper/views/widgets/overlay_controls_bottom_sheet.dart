import 'package:flutter/material.dart';
import '../../../../core/models/overlay_model.dart';

class OverlayControlsBottomSheet extends StatefulWidget {
  final OverlayModel overlay;
  final ValueChanged<OverlayModel> onOverlayChanged;
  final VoidCallback onDelete;

  const OverlayControlsBottomSheet({
    super.key,
    required this.overlay,
    required this.onOverlayChanged,
    required this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required OverlayModel overlay,
    required ValueChanged<OverlayModel> onOverlayChanged,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OverlayControlsBottomSheet(
        overlay: overlay,
        onOverlayChanged: onOverlayChanged,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<OverlayControlsBottomSheet> createState() => _OverlayControlsBottomSheetState();
}

class _OverlayControlsBottomSheetState extends State<OverlayControlsBottomSheet> {
  late OverlayModel _overlay;

  @override
  void initState() {
    super.initState();
    _overlay = widget.overlay;
  }

  void _update(OverlayModel updated) {
    setState(() => _overlay = updated);
    widget.onOverlayChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final typeTitle = _overlay.type == OverlayType.video
        ? 'Overlay Video (PiP)'
        : (_overlay.type == OverlayType.image ? 'Overlay Foto / GIF' : 'Overlay Teks');

    final duration = (_overlay.endTime - _overlay.startTime).clamp(0.5, 60.0);

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

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    typeTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Hapus', style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onDelete();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 1. Resize (Ukuran / Skala Objek)
              Row(
                children: [
                  const Icon(Icons.photo_size_select_small_rounded, color: Color(0xFF00E5FF), size: 18),
                  const SizedBox(width: 8),
                  const Text('Ukuran (Resize):', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Expanded(
                    child: Slider(
                      value: _overlay.scale.clamp(0.2, 3.0),
                      min: 0.2,
                      max: 3.0,
                      activeColor: const Color(0xFF00E5FF),
                      inactiveColor: Colors.white12,
                      onChanged: (val) => _update(_overlay.copyWith(scale: val)),
                    ),
                  ),
                  Text('${(_overlay.scale * 100).toInt()}%', style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),

              // 2. Opacity (Transparansi)
              Row(
                children: [
                  const Icon(Icons.opacity_rounded, color: Color(0xFFA78BFA), size: 18),
                  const SizedBox(width: 8),
                  const Text('Opasitas (Transparansi):', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Expanded(
                    child: Slider(
                      value: _overlay.opacity.clamp(0.0, 1.0),
                      min: 0.0,
                      max: 1.0,
                      activeColor: const Color(0xFFA78BFA),
                      inactiveColor: Colors.white12,
                      onChanged: (val) => _update(_overlay.copyWith(opacity: val)),
                    ),
                  ),
                  Text('${(_overlay.opacity * 100).toInt()}%', style: const TextStyle(color: Color(0xFFA78BFA), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),

              // 3. Rotate (Putar Derajat)
              Row(
                children: [
                  const Icon(Icons.rotate_right_rounded, color: Color(0xFF38BDF8), size: 18),
                  const SizedBox(width: 8),
                  const Text('Rotasi (Rotate):', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Expanded(
                    child: Slider(
                      value: _overlay.rotationDegrees % 360,
                      min: 0.0,
                      max: 360.0,
                      activeColor: const Color(0xFF38BDF8),
                      inactiveColor: Colors.white12,
                      onChanged: (val) => _update(_overlay.copyWith(rotationDegrees: val)),
                    ),
                  ),
                  Text('${_overlay.rotationDegrees.toInt()}°', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),

              // 4. Trim (Durasi Overlay)
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Color(0xFFFBBF24), size: 18),
                  const SizedBox(width: 8),
                  const Text('Durasi (Trim):', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Expanded(
                    child: Slider(
                      value: duration,
                      min: 0.5,
                      max: 30.0,
                      divisions: 59,
                      activeColor: const Color(0xFFFBBF24),
                      inactiveColor: Colors.white12,
                      onChanged: (val) {
                        _update(_overlay.copyWith(endTime: _overlay.startTime + val));
                      },
                    ),
                  ),
                  Text('${duration.toStringAsFixed(1)}s', style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),

              // 5. Tombol Cepat Posisi Tengah & Reset
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.filter_center_focus_rounded, size: 16),
                    label: const Text('Posisi Tengah', style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      _update(_overlay.copyWith(normalizedX: 0.5, normalizedY: 0.5));
                    },
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.rotate_90_degrees_cw_rounded, size: 16),
                    label: const Text('+90°', style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      _update(_overlay.copyWith(rotationDegrees: (_overlay.rotationDegrees + 90) % 360));
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
