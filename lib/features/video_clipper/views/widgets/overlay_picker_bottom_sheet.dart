import 'package:flutter/material.dart';
import '../../../../core/services/video_picker_service.dart';

class OverlayPickerBottomSheet extends StatelessWidget {
  final VideoPickerService pickerService;
  final Function(String path, bool isVideo) onMediaSelected;

  const OverlayPickerBottomSheet({
    super.key,
    required this.pickerService,
    required this.onMediaSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required VideoPickerService pickerService,
    required Function(String path, bool isVideo) onMediaSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OverlayPickerBottomSheet(
        pickerService: pickerService,
        onMediaSelected: onMediaSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF14141E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Tambahkan Lapisan Overlay (PiP)',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Tambahkan Video PiP
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pop();
                    final file = await pickerService.pickVideoFromGallery();
                    if (file != null) {
                      onMediaSelected(file.path, true);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.video_camera_back_rounded, color: Color(0xFF00E5FF), size: 36),
                        SizedBox(height: 10),
                        Text('Video PiP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        SizedBox(height: 4),
                        Text('Video di atas video utama', style: TextStyle(color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Tambahkan Foto / Gambar / GIF Overlay
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pop();
                    final file = await pickerService.pickImageFromGallery();
                    if (file != null) {
                      onMediaSelected(file.path, false);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFA78BFA).withValues(alpha: 0.3)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.image_rounded, color: Color(0xFFA78BFA), size: 36),
                        SizedBox(height: 10),
                        Text('Foto / GIF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        SizedBox(height: 4),
                        Text('Logo, foto, stiker, GIF', style: TextStyle(color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
