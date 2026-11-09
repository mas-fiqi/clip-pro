import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/models/video_effect_model.dart';
import '../../../../core/services/effect_preview_player_manager.dart';
import 'animated_effect_preview_canvas.dart';

/// Widget Kartu Video Demonstrasi Nyata (Real Live Video Preview)
/// - Menjalankan video demo 2-4 detik berulang secara otomatis tanpa audio (muted)
/// - Menggunakan fallback ke Realistic Animated Canvas jika video asset tidak tersedia atau sedang loading
/// - Dikelola oleh EffectPreviewPlayerManager untuk mencegah memori bocor (Redmi Note 8 friendly)
class EffectVideoCardPreview extends StatefulWidget {
  final EffectCatalogItem item;
  final bool isSelected;
  final bool isLargePreview;
  final String? customImageUrl;

  const EffectVideoCardPreview({
    super.key,
    required this.item,
    required this.isSelected,
    this.isLargePreview = false,
    this.customImageUrl,
  });

  @override
  State<EffectVideoCardPreview> createState() => _EffectVideoCardPreviewState();
}

class _EffectVideoCardPreviewState extends State<EffectVideoCardPreview> {
  VideoPlayerController? _controller;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Hanya autoplay jika terpilih atau jika merupakan large preview
    if (widget.isSelected || widget.isLargePreview) {
      _initVideoPlayer();
    }
  }

  @override
  void didUpdateWidget(covariant EffectVideoCardPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.previewVideoAsset != oldWidget.item.previewVideoAsset ||
        widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected || widget.isLargePreview) {
        _initVideoPlayer();
      } else {
        _pauseVideo();
      }
    }
  }

  Future<void> _initVideoPlayer() async {
    final assetPath = widget.item.previewVideoAsset;
    if (assetPath == null || assetPath.isEmpty) return;

    if (_controller != null && _controller!.dataSource == assetPath) {
      try {
        if (!_controller!.value.isPlaying) {
          await _controller!.play();
        }
      } catch (_) {}
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      final controller = await EffectPreviewPlayerManager().getOrCreateController(assetPath);
      if (mounted) {
        if (controller != null && controller.value.isInitialized) {
          setState(() {
            _controller = controller;
            _isLoading = false;
            _hasError = false;
          });
          controller.play();
        } else {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _pauseVideo() {
    try {
      _controller?.pause();
    } catch (_) {}
  }

  @override
  void dispose() {
    // Tidak langsung mendispose manager controller di sini karena dipool oleh LRU EffectPreviewPlayerManager
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasVideo = widget.item.previewVideoAsset != null && !_hasError;
    final isInitialized = _controller != null && _controller!.value.isInitialized;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Fallback Animated Canvas
        AnimatedEffectPreviewCanvas(
          effectType: widget.item.type,
          effectName: widget.item.name,
          customImageUrl: widget.customImageUrl ?? widget.item.thumbnailFallback,
          isLarge: widget.isLargePreview,
        ),

        // 2. Video Demonstrasi Nyata jika Controller Aktif
        if (hasVideo && isInitialized && (widget.isSelected || widget.isLargePreview))
          ClipRRect(
            borderRadius: BorderRadius.circular(widget.isLargePreview ? 14 : 8),
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width > 0 ? _controller!.value.size.width : 240,
                height: _controller!.value.size.height > 0 ? _controller!.value.size.height : 320,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),

        // 3. Status Badge "LIVE VIDEO"
        if (hasVideo)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: (widget.isSelected || widget.isLargePreview)
                      ? const Color(0xFF23D2E2).withValues(alpha: 0.8)
                      : Colors.white24,
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_circle_fill_rounded,
                    size: 9,
                    color: (widget.isSelected || widget.isLargePreview)
                        ? const Color(0xFF23D2E2)
                        : Colors.white70,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'DEMO',
                    style: TextStyle(
                      color: (widget.isSelected || widget.isLargePreview)
                          ? const Color(0xFF23D2E2)
                          : Colors.white70,
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 4. Loading Indicator saat buffer video
        if (_isLoading && (widget.isSelected || widget.isLargePreview))
          Container(
            color: Colors.black38,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF23D2E2)),
              ),
            ),
          ),
      ],
    );
  }
}

