import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ExportSuccessDialog extends StatefulWidget {
  final String filePath;
  final bool isSavedToGallery;
  final String resolutionText;
  final int fileSizeEstimateMb;

  const ExportSuccessDialog({
    super.key,
    required this.filePath,
    required this.isSavedToGallery,
    required this.resolutionText,
    required this.fileSizeEstimateMb,
  });

  static Future<void> show(
    BuildContext context, {
    required String filePath,
    required bool isSavedToGallery,
    required String resolutionText,
    required int fileSizeEstimateMb,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExportSuccessDialog(
        filePath: filePath,
        isSavedToGallery: isSavedToGallery,
        resolutionText: resolutionText,
        fileSizeEstimateMb: fileSizeEstimateMb,
      ),
    );
  }

  @override
  State<ExportSuccessDialog> createState() => _ExportSuccessDialogState();
}

class _ExportSuccessDialogState extends State<ExportSuccessDialog> {
  VideoPlayerController? _previewController;
  bool _isPlaying = false;
  int _actualFileSizeBytes = 0;

  @override
  void initState() {
    super.initState();
    _checkFileAndInitPlayer();
  }

  Future<void> _checkFileAndInitPlayer() async {
    final file = File(widget.filePath);
    if (await file.exists()) {
      final size = await file.length();
      if (mounted) {
        setState(() => _actualFileSizeBytes = size);
      }

      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      controller.setLooping(true);
      if (mounted) {
        setState(() {
          _previewController = controller;
        });
      }
    }
  }

  @override
  void dispose() {
    _previewController?.dispose();
    super.dispose();
  }

  String _formatActualSize() {
    if (_actualFileSizeBytes <= 0) {
      return '~${widget.fileSizeEstimateMb} MB';
    }
    final mb = _actualFileSizeBytes / (1024 * 1024);
    if (mb < 1.0) {
      final kb = (_actualFileSizeBytes / 1024).toStringAsFixed(1);
      return '$kb KB';
    }
    return '${mb.toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.filePath.split(Platform.pathSeparator).last;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF161622),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Icon & Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ekspor Video Selesai!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.isSavedToGallery
                            ? 'Tersimpan otomatis di Galeri HP'
                            : 'Tersimpan di media storage internal',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Mini Video Player Preview (jika siap)
            if (_previewController != null && _previewController!.value.isInitialized)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: Colors.black,
                  height: 190,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: _previewController!.value.aspectRatio,
                        child: VideoPlayer(_previewController!),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_previewController!.value.isPlaying) {
                              _previewController!.pause();
                              _isPlaying = false;
                            } else {
                              _previewController!.play();
                              _isPlaying = true;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white30, width: 1.5),
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2D),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.movie_filter_rounded, color: Color(0xFF8B5CF6), size: 36),
                    const SizedBox(height: 8),
                    Text(
                      fileName,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Video Meta Details Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetaCol(Icons.high_quality_rounded, 'Resolusi', widget.resolutionText),
                  Container(width: 1, height: 28, color: Colors.white12),
                  _buildMetaCol(Icons.sd_storage_rounded, 'Ukuran', _formatActualSize()),
                  Container(width: 1, height: 28, color: Colors.white12),
                  _buildMetaCol(Icons.video_file_rounded, 'Format', 'MP4 (H.264)'),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Editor', style: TextStyle(fontWeight: FontWeight.w600)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.done_all_rounded, size: 18),
                    label: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaCol(IconData icon, String label, String value) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF8B5CF6)),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

