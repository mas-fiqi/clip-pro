import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/clip_model.dart';
import '../../../../core/models/overlay_model.dart';
import '../../../../core/models/timeline_model.dart';
import '../../../../core/services/audio_waveform_service.dart';
import '../../../../core/services/thumbnail_generator_service.dart';
import '../../../../core/utils/time_formatter.dart';

class MultiClipTimelineView extends StatefulWidget {
  final TimelineModel timeline;
  final String? selectedClipId;
  final double currentPosition;
  final ValueNotifier<double>? positionNotifier;
  final bool isPlaying;
  final ValueChanged<String> onSelectClip;
  final ValueChanged<double> onSeek;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(String clipId, double newStart, double newEnd)? onTrimClip;
  final VoidCallback? onToggleKeyframe;
  final VoidCallback? onPrevKeyframe;
  final VoidCallback? onNextKeyframe;
  final bool hasKeyframeAtCurrentPosition;
  final VoidCallback onAddVideoTap;
  final VoidCallback onAddAudioTap;
  final VoidCallback onAddTextTap;
  final VoidCallback onPlayPauseTap;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onMuteToggle;
  final bool isMuted;
  final VoidCallback? onDuplicateSelectedClip;
  final VoidCallback? onSplitClip;
  final VoidCallback? onDeleteSelectedClip;
  final ValueChanged<String>? onReplaceClip;

  const MultiClipTimelineView({
    super.key,
    required this.timeline,
    required this.selectedClipId,
    required this.currentPosition,
    this.positionNotifier,
    this.isPlaying = false,
    required this.onSelectClip,
    required this.onSeek,
    required this.onReorder,
    this.onTrimClip,
    this.onToggleKeyframe,
    this.onPrevKeyframe,
    this.onNextKeyframe,
    this.hasKeyframeAtCurrentPosition = false,
    required this.onAddVideoTap,
    required this.onAddAudioTap,
    required this.onAddTextTap,
    required this.onPlayPauseTap,
    required this.onToggleFullscreen,
    required this.onMuteToggle,
    this.isMuted = false,
    this.onDuplicateSelectedClip,
    this.onSplitClip,
    this.onDeleteSelectedClip,
    this.onReplaceClip,
  });

  @override
  State<MultiClipTimelineView> createState() => _MultiClipTimelineViewState();
}

class _MultiClipTimelineViewState extends State<MultiClipTimelineView> {
  double _zoomScale = 1.0; // 0.6x s/d 2.5x
  bool _isSnapEnabled = true;
  final ScrollController _horizontalScrollController = ScrollController();
  final ThumbnailGeneratorService _thumbnailService = ThumbnailGeneratorService();
  final AudioWaveformService _waveformService = AudioWaveformService();
  bool _isUserScrolling = false;

  double get _pixelsPerSecond => 30.0 * _zoomScale;

  @override
  void initState() {
    super.initState();
    widget.positionNotifier?.addListener(_onNotifierTick);
  }

  @override
  void didUpdateWidget(covariant MultiClipTimelineView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.positionNotifier != widget.positionNotifier) {
      oldWidget.positionNotifier?.removeListener(_onNotifierTick);
      widget.positionNotifier?.addListener(_onNotifierTick);
    }
    // Auto-scroll timeline mengikuti posisi playhead secara presisi 1:1
    if (widget.isPlaying && !_isUserScrolling && _horizontalScrollController.hasClients) {
      _syncScrollToPosition(widget.currentPosition);
    }
  }

  @override
  void dispose() {
    widget.positionNotifier?.removeListener(_onNotifierTick);
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _onNotifierTick() {
    if (widget.isPlaying && !_isUserScrolling && _horizontalScrollController.hasClients && widget.positionNotifier != null) {
      _syncScrollToPosition(widget.positionNotifier!.value);
    }
  }

  void _syncScrollToPosition(double pos) {
    // 1:1 sinkronisasi offset scroll dengan posisi waktu playhead
    final targetScroll = pos * _pixelsPerSecond;
    if (!_horizontalScrollController.hasClients) return;
    final maxScroll = _horizontalScrollController.position.maxScrollExtent;
    final clampedScroll = targetScroll.clamp(0.0, maxScroll);
    if ((clampedScroll - _horizontalScrollController.offset).abs() > 1.0) {
      _horizontalScrollController.jumpTo(clampedScroll);
    }
  }

  void _zoomIn() {
    setState(() {
      _zoomScale = (_zoomScale + 0.25).clamp(0.6, 2.5);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomScale = (_zoomScale - 0.25).clamp(0.6, 2.5);
    });
  }

  void _seekToStart() {
    widget.onSeek(0.0);
  }

  void _seekToEnd() {
    widget.onSeek(widget.timeline.totalDuration);
  }

  @override
  Widget build(BuildContext context) {
    final totalDur = widget.timeline.totalDuration;

    return Container(
      color: const Color(0xFF141414),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Playback & Playhead Control Bar with Zoom & Snap Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: const BoxDecoration(
              color: Color(0xFF14141E),
              border: Border(
                top: BorderSide(color: Color(0xFF242424), width: 0.8),
                bottom: BorderSide(color: Color(0xFF242424), width: 0.8),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  // Navigasi Start & Play/Pause
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                    icon: const Icon(Icons.skip_previous_rounded, color: Colors.white70, size: 18),
                    tooltip: 'Ke Awal Proyek',
                    onPressed: _seekToStart,
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    icon: Icon(
                      widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: widget.onPlayPauseTap,
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                    icon: const Icon(Icons.skip_next_rounded, color: Colors.white70, size: 18),
                    tooltip: 'Ke Akhir Proyek',
                    onPressed: _seekToEnd,
                  ),

                  const SizedBox(width: 8),

                  // Controls Keyframe Profesional (Prev, Diamond Add/Remove, Next)
                  if (widget.selectedClipId != null && widget.onToggleKeyframe != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2C),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                            icon: const Icon(Icons.arrow_left_rounded, size: 18, color: Colors.white70),
                            tooltip: 'Keyframe Sebelumnya',
                            onPressed: widget.onPrevKeyframe,
                          ),
                          InkWell(
                            onTap: widget.onToggleKeyframe,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: widget.hasKeyframeAtCurrentPosition
                                    ? const Color(0xFFEF4444).withValues(alpha: 0.25)
                                    : const Color(0xFF00E5FF).withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: widget.hasKeyframeAtCurrentPosition
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF00E5FF),
                                ),
                              ),
                              child: Icon(
                                widget.hasKeyframeAtCurrentPosition
                                    ? Icons.diamond_rounded
                                    : Icons.diamond_outlined,
                                size: 14,
                                color: widget.hasKeyframeAtCurrentPosition
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF00E5FF),
                              ),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                            icon: const Icon(Icons.arrow_right_rounded, size: 18, color: Colors.white70),
                            tooltip: 'Keyframe Berikutnya',
                            onPressed: widget.onNextKeyframe,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Time Code / Playhead position & Duration (Reactive via ValueNotifier if provided)
                  widget.positionNotifier != null
                      ? ValueListenableBuilder<double>(
                          valueListenable: widget.positionNotifier!,
                          builder: (context, pos, _) {
                            return Text(
                              '${TimeFormatter.formatSeconds(pos)} / ${TimeFormatter.formatSeconds(totalDur)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        )
                      : Text(
                          '${TimeFormatter.formatSeconds(widget.currentPosition)} / ${TimeFormatter.formatSeconds(totalDur)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                  const SizedBox(width: 8),

                  // Zoom & Magnet Snap Toggles
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                    icon: Icon(
                      _isSnapEnabled ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                      color: _isSnapEnabled ? const Color(0xFF00E5FF) : Colors.white38,
                      size: 15,
                    ),
                    tooltip: 'Magnet / Snapping',
                    onPressed: () {
                      setState(() => _isSnapEnabled = !_isSnapEnabled);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isSnapEnabled ? 'Magnet Snap Aktif' : 'Magnet Snap Nonaktif'),
                          duration: const Duration(milliseconds: 800),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                    icon: const Icon(Icons.zoom_out, color: Colors.white70, size: 15),
                    tooltip: 'Zoom Out',
                    onPressed: _zoomOut,
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                    icon: const Icon(Icons.zoom_in, color: Colors.white70, size: 15),
                    tooltip: 'Zoom In',
                    onPressed: _zoomIn,
                  ),
                ],
              ),
            ),
          ),

          // 2. Main Timeline Area with Timeline Ruler, Video Tracks, Audio Tracks, Text Tracks
          LayoutBuilder(
            builder: (context, constraints) {
              const double leftSidebarWidth = 120.0;
              const double playheadOffsetInViewport = 40.0;
              final double viewportTrackWidth = (constraints.maxWidth - leftSidebarWidth - 1.0).clamp(100.0, 5000.0);
              final double contentWidth = totalDur * _pixelsPerSecond;
              // Padding kanan dinamis memastikan titik waktu totalDur bisa di-scroll tepat di bawah playhead
              final double trailingPadding = (viewportTrackWidth - playheadOffsetInViewport).clamp(100.0, 5000.0);
              final double totalTimelineWidth = contentWidth + playheadOffsetInViewport + trailingPadding;

              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sisi Kiri: CapCut Quick Buttons (Bisukan, Sampul)
                        SizedBox(
                          width: leftSidebarWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildLeftActionBtn(
                                    icon: widget.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                    label: widget.isMuted ? 'Bersuara' : 'Bisukan',
                                    isHighlighted: widget.isMuted,
                                    onTap: widget.onMuteToggle,
                                  ),
                                  _buildLeftActionBtn(
                                    icon: Icons.image_outlined,
                                    label: 'Sampul',
                                    isHighlighted: false,
                                    onTap: () {},
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildLeftTrackHeader(Icons.movie_creation_outlined, 'Video'),
                              const SizedBox(height: 12),
                              _buildLeftTrackHeader(Icons.music_note_rounded, 'Audio'),
                              const SizedBox(height: 12),
                              _buildLeftTrackHeader(Icons.title_rounded, 'Teks'),
                            ],
                          ),
                        ),

                        // Garis Pemisah Tipis
                        Container(
                          width: 1,
                          height: 190,
                          color: const Color(0xFF2A2A2A),
                        ),

                        // Sisi Kanan: Multi-Track Scrolling Area
                        Expanded(
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is ScrollStartNotification) {
                                if (notification.dragDetails != null) {
                                  _isUserScrolling = true;
                                }
                              } else if (notification is ScrollEndNotification) {
                                if (_isUserScrolling) {
                                  _isUserScrolling = false;
                                  final currentOffset = _horizontalScrollController.offset;
                                  final seekTime = (currentOffset / _pixelsPerSecond).clamp(0.0, totalDur);
                                  widget.onSeek(seekTime);
                                }
                              }
                              return false;
                            },
                            child: SingleChildScrollView(
                              controller: _horizontalScrollController,
                              scrollDirection: Axis.horizontal,
                              physics: const ClampingScrollPhysics(),
                              child: SizedBox(
                                width: totalTimelineWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 0. Time Ruler (Penggaris Waktu Profesional)
                                    Padding(
                                      padding: const EdgeInsets.only(left: playheadOffsetInViewport),
                                      child: _buildTimeRuler(totalDur, contentWidth + trailingPadding),
                                    ),
                                    const SizedBox(height: 4),

                                    // TRACK 1: Video Clips Track with Thumbnails & Trim Handles
                                    SizedBox(
                                      height: 58,
                                      child: Row(
                                        children: [
                                          const SizedBox(width: playheadOffsetInViewport),
                                          ...List.generate(widget.timeline.clips.length, (index) {
                                            final clip = widget.timeline.clips[index];
                                            final isSelected = clip.id == widget.selectedClipId;
                                            final width = (clip.timelineDuration * _pixelsPerSecond).clamp(30.0, 30000.0);

                                            // Cek apakah playhead berada di perbatasan klip ini (CapCut style junction highlight)
                                            double clipStartGlobal = 0.0;
                                            for (int k = 0; k < index; k++) {
                                              clipStartGlobal += widget.timeline.clips[k].timelineDuration;
                                            }
                                            final clipEndGlobal = clipStartGlobal + clip.timelineDuration;
                                            final isNearEnd = (widget.currentPosition - clipEndGlobal).abs() < 0.35;
                                            final isNearStart = (widget.currentPosition - clipStartGlobal).abs() < 0.35 && index > 0;
                                            final isBorderJunction = isNearEnd || isNearStart;

                                            final effectiveBorderColor = isSelected
                                                ? const Color(0xFF00E5FF)
                                                : (isBorderJunction ? const Color(0xFF38BDF8) : Colors.white12);
                                            final effectiveBorderWidth = (isSelected || isBorderJunction) ? 2.0 : 1.0;

                                            return GestureDetector(
                                              key: ValueKey(clip.id),
                                              onTap: () => widget.onSelectClip(clip.id),
                                              onLongPress: () => _showClipContextMenu(context, clip, index),
                                              child: Container(
                                                width: width,
                                                margin: const EdgeInsets.only(right: 4),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF282828),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: effectiveBorderColor,
                                                    width: effectiveBorderWidth,
                                                  ),
                                                  boxShadow: (isSelected || isBorderJunction)
                                                      ? [
                                                          BoxShadow(
                                                            color: (isSelected ? const Color(0xFF00E5FF) : const Color(0xFF38BDF8)).withValues(alpha: 0.35),
                                                            blurRadius: 6,
                                                            offset: const Offset(0, 1),
                                                          ),
                                                        ]
                                                      : null,
                                                ),
                                                child: Stack(
                                                  children: [
                                                    // Thumbnail strip background
                                                    Positioned.fill(
                                                      child: _buildVideoClipThumbnails(clip.sourcePath, clip.startSource, clip.sourceDuration, width),
                                                    ),

                                                    // Header Label & Badges
                                                    Positioned(
                                                      top: 4,
                                                      left: 6,
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () => _showClipContextMenu(context, clip, index),
                                                            child: Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                              decoration: BoxDecoration(
                                                                color: Colors.black54,
                                                                borderRadius: BorderRadius.circular(3),
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  const Icon(Icons.movie_outlined, size: 10, color: Colors.white),
                                                                  const SizedBox(width: 4),
                                                                  Text(
                                                                    'Klip ${index + 1}',
                                                                    style: const TextStyle(
                                                                      color: Colors.white,
                                                                      fontSize: 10,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(width: 3),
                                                                  const Icon(Icons.more_vert, size: 10, color: Colors.white70),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          if (clip.startSource > 0.05) ...[
                                                            const SizedBox(width: 4),
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                              decoration: BoxDecoration(
                                                                color: const Color(0xFFF59E0B), // Amber orange badge
                                                                borderRadius: BorderRadius.circular(3),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors.black.withValues(alpha: 0.3),
                                                                    blurRadius: 2,
                                                                    offset: const Offset(0, 1),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  const Icon(Icons.content_cut_rounded, size: 9, color: Colors.black),
                                                                  const SizedBox(width: 2),
                                                                  Text(
                                                                    'Dipangkas +${clip.startSource.toStringAsFixed(1)}s',
                                                                    style: const TextStyle(
                                                                      color: Colors.black,
                                                                      fontSize: 8.5,
                                                                      fontWeight: FontWeight.w900,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                          if (clip.animation.hasAnimation) ...[
                                                            const SizedBox(width: 4),
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                              decoration: BoxDecoration(
                                                                color: const Color(0xFF00E5FF).withValues(alpha: 0.85),
                                                                borderRadius: BorderRadius.circular(3),
                                                              ),
                                                              child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  const Icon(Icons.auto_awesome_motion_rounded, size: 8, color: Colors.black),
                                                                  const SizedBox(width: 2),
                                                                  Text(
                                                                    clip.animation.presetId.replaceAll('_', ' ').toUpperCase(),
                                                                    style: const TextStyle(
                                                                      color: Colors.black,
                                                                      fontSize: 8,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    ),

                                                    // Durasi Label
                                                    Positioned(
                                                      bottom: 4,
                                                      right: 6,
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: Colors.black54,
                                                          borderRadius: BorderRadius.circular(3),
                                                        ),
                                                        child: Text(
                                                          '${clip.timelineDuration.toStringAsFixed(1)}s',
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 9,
                                                            fontFamily: 'monospace',
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    // Indikator Titik Berlian Keyframe pada Klip
                                                    if (clip.keyframes.isNotEmpty)
                                                      ...clip.keyframes.map((kf) {
                                                        final progress = clip.timelineDuration > 0
                                                            ? (kf.timestampSeconds / clip.timelineDuration).clamp(0.0, 1.0)
                                                            : 0.0;
                                                        final kfLeft = (progress * (width - 12.0)) + 6.0;
                                                        return Positioned(
                                                          left: kfLeft - 5,
                                                          top: 24,
                                                          child: Container(
                                                            width: 10,
                                                            height: 10,
                                                            decoration: BoxDecoration(
                                                              color: const Color(0xFFEF4444),
                                                              borderRadius: BorderRadius.circular(2),
                                                              border: Border.all(color: Colors.white, width: 1.2),
                                                            ),
                                                            transform: Matrix4.rotationZ(0.785398), // 45 derajat (Diamond shape)
                                                          ),
                                                        );
                                                      }),

                                                    // Visual & Interactive Trim Handles saat klip terpilih
                                                    if (isSelected) ...[
                                                      // Handle Kiri (Geser titik awal pengambilan video)
                                                      Positioned(
                                                        left: 0,
                                                        top: 0,
                                                        bottom: 0,
                                                        width: 28,
                                                        child: GestureDetector(
                                                          behavior: HitTestBehavior.opaque,
                                                          onTap: () {
                                                            // Klik handle langsung melompatkan playhead ke awal klip
                                                            double accumulated = 0.0;
                                                            for (int k = 0; k < index; k++) {
                                                              accumulated += widget.timeline.clips[k].timelineDuration;
                                                            }
                                                            widget.onSeek(accumulated);
                                                          },
                                                          onHorizontalDragUpdate: (details) {
                                                            if (widget.onTrimClip == null) return;
                                                            final deltaSec = (details.primaryDelta ?? 0.0) / _pixelsPerSecond;
                                                            // Geser ke depan memangkas awal (memulai dari titik baru), geser ke belakang mengembalikan hingga 0.0
                                                            final newStart = (clip.startSource + (deltaSec * clip.speed))
                                                                .clamp(0.0, clip.endSource - (0.2 * clip.speed));
                                                            widget.onTrimClip!(clip.id, newStart, clip.endSource);
                                                          },
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              color: clip.startSource > 0.05
                                                                  ? const Color(0xFFF59E0B) // Amber jika sudah dipangkas
                                                                  : const Color(0xFF00E5FF),
                                                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors.black.withValues(alpha: 0.4),
                                                                  blurRadius: 4,
                                                                ),
                                                              ],
                                                            ),
                                                            child: Center(
                                                              child: Icon(
                                                                clip.startSource > 0.05 ? Icons.content_cut_rounded : Icons.drag_indicator,
                                                                size: 16,
                                                                color: Colors.black87,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // Handle Kanan (Geser titik akhir pengambilan video)
                                                      Positioned(
                                                        right: 0,
                                                        top: 0,
                                                        bottom: 0,
                                                        width: 28,
                                                        child: GestureDetector(
                                                          behavior: HitTestBehavior.opaque,
                                                          onTap: () {
                                                            // Klik handle kanan melompatkan playhead ke akhir klip
                                                            double accumulated = 0.0;
                                                            for (int k = 0; k <= index; k++) {
                                                              accumulated += widget.timeline.clips[k].timelineDuration;
                                                            }
                                                            widget.onSeek(accumulated);
                                                          },
                                                          onHorizontalDragUpdate: (details) {
                                                            if (widget.onTrimClip == null) return;
                                                            final deltaSec = (details.primaryDelta ?? 0.0) / _pixelsPerSecond;
                                                            final newEnd = clip.endSource + (deltaSec * clip.speed);
                                                            if (newEnd > clip.startSource + (0.2 * clip.speed)) {
                                                              widget.onTrimClip!(clip.id, clip.startSource, newEnd);
                                                            }
                                                          },
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              color: const Color(0xFF00E5FF),
                                                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors.black.withValues(alpha: 0.4),
                                                                  blurRadius: 4,
                                                                ),
                                                              ],
                                                            ),
                                                            child: const Center(
                                                              child: Icon(Icons.drag_indicator, size: 16, color: Colors.black87),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Tombol Transisi Sambungan Potongan (+) CapCut Style
                                                      if (index < widget.timeline.clips.length - 1)
                                                        Positioned(
                                                          right: 0,
                                                          top: 15,
                                                          bottom: 15,
                                                          width: 20,
                                                          child: InkWell(
                                                            onTap: widget.onAddVideoTap,
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                color: const Color(0xFF1E1E2C),
                                                                borderRadius: BorderRadius.circular(4),
                                                                border: Border.all(color: const Color(0xFF00E5FF), width: 1.2),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors.black.withValues(alpha: 0.5),
                                                                    blurRadius: 4,
                                                                  ),
                                                                ],
                                                              ),
                                                              child: const Center(
                                                                child: Icon(
                                                                  Icons.add_rounded,
                                                                  size: 13,
                                                                  color: Color(0xFF00E5FF),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),

                                      // Tombol Tambah Video (+)
                                          InkWell(
                                            onTap: widget.onAddVideoTap,
                                            borderRadius: BorderRadius.circular(6),
                                            child: Container(
                                              width: 40,
                                              height: 58,
                                              margin: const EdgeInsets.only(left: 4, right: 16),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF222222),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: Colors.white24, width: 1),
                                              ),
                                              child: const Icon(Icons.add, color: Colors.white, size: 20),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // TRACK 2: Audio Waveform Track
                                    Padding(
                                      padding: const EdgeInsets.only(left: playheadOffsetInViewport),
                                      child: RepaintBoundary(
                                        child: _buildAudioTrack(contentWidth + trailingPadding),
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // TRACK 3: Text & Overlay Track
                                    Padding(
                                      padding: const EdgeInsets.only(left: playheadOffsetInViewport),
                                      child: RepaintBoundary(
                                        child: _buildTextOverlayTrack(contentWidth + trailingPadding),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Vertical Playhead Line (Di garis referensi playhead timeline)
                  Positioned(
                    left: leftSidebarWidth + playheadOffsetInViewport,
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Column(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: 2,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Timeline Ruler (Penggaris waktu dengan penanda detik)
  Widget _buildTimeRuler(double totalDuration, double totalWidth) {
    return Container(
      height: 18,
      width: totalWidth,
      color: Colors.black26,
      child: CustomPaint(
        painter: _RulerPainter(
          totalDuration: totalDuration,
          pixelsPerSecond: _pixelsPerSecond,
        ),
      ),
    );
  }

  /// Thumbnail klip video dengan cache instan tanpa memicu re-render frame
  Widget _buildVideoClipThumbnails(String sourcePath, double startSource, double duration, double width) {
    final maxAllowed = _thumbnailService.config.maxThumbnailsPerClip;
    final thumbCount = (width / 60.0).ceil().clamp(1, maxAllowed);
    return Row(
      children: List.generate(thumbCount, (index) {
        final timeOffset = startSource + (duration / thumbCount) * index;
        final cached = _thumbnailService.getCachedThumbnail(sourcePath, timeOffset);
        if (cached != null) {
          return Expanded(
            child: Image.memory(
              cached,
              fit: BoxFit.cover,
              height: double.infinity,
              gaplessPlayback: true,
              cacheWidth: 100,
            ),
          );
        }

        return Expanded(
          child: FutureBuilder<Uint8List?>(
            future: _thumbnailService.generateThumbnail(
              videoPath: sourcePath,
              timestampSeconds: timeOffset,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  gaplessPlayback: true,
                  cacheWidth: 100,
                );
              }
              return Container(
                color: Colors.white.withValues(alpha: 0.04),
              );
            },
          ),
        );
      }),
    );
  }

  /// Track Audio dengan Waveform Amplitudo
  Widget _buildAudioTrack(double totalWidth) {
    if (widget.timeline.audioClips.isEmpty) {
      return GestureDetector(
        onTap: widget.onAddAudioTap,
        child: Container(
          height: 30,
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2329),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.add, size: 14, color: Color(0xFF00E5FF)),
              SizedBox(width: 6),
              Text('Tambahkan audio / musik', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 11)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 32,
      child: Stack(
        children: widget.timeline.audioClips.map((audio) {
          final leftOffset = audio.startTimeline * _pixelsPerSecond;
          final clipWidth = (audio.duration * _pixelsPerSecond).clamp(40.0, 3000.0);
          final samples = _waveformService.getWaveformSamples(
            key: audio.id,
            durationSeconds: audio.duration,
            volume: audio.volume,
            filePath: audio.sourcePath,
          );

          // Hitung progress playback audio pada posisi playhead saat ini
          double playedFraction = 0.0;
          if (widget.currentPosition >= audio.startTimeline &&
              widget.currentPosition <= audio.endTimeline &&
              audio.duration > 0) {
            playedFraction = ((widget.currentPosition - audio.startTimeline) / audio.duration).clamp(0.0, 1.0);
          } else if (widget.currentPosition > audio.endTimeline) {
            playedFraction = 1.0;
          }

          return Positioned(
            left: leftOffset,
            child: Container(
              width: clipWidth,
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF102830),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: const Color(0xFF00E5FF), width: 1),
              ),
              child: Stack(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.music_note, size: 12, color: Color(0xFF00E5FF)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: CustomPaint(
                          painter: _WaveformPainter(
                            samples: samples,
                            playedFraction: playedFraction,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${audio.duration.toStringAsFixed(1)}s',
                        style: const TextStyle(color: Colors.white70, fontSize: 9, fontFamily: 'monospace'),
                      ),
                    ],
                  ),

                  // Beat Markers Kuning Emas Ala CapCut pada Trek Audio
                  if (audio.rhythm.hasMarkers)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Stack(
                          children: audio.rhythm.markers.map((bm) {
                            final bmX = (bm.timestampSeconds / (audio.duration > 0 ? audio.duration : 1.0)) * clipWidth;
                            return Positioned(
                              left: bmX - 3,
                              bottom: 0,
                              child: Container(
                                width: bm.isStrongBeat ? 6 : 4,
                                height: bm.isStrongBeat ? 8 : 5,
                                decoration: BoxDecoration(
                                  color: bm.isStrongBeat ? const Color(0xFFFBBF24) : Colors.amber.shade200,
                                  shape: BoxShape.circle,
                                  boxShadow: bm.isStrongBeat
                                      ? [BoxShadow(color: Colors.amber.withValues(alpha: 0.6), blurRadius: 4)]
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Track Teks & Overlay Layer
  Widget _buildTextOverlayTrack(double totalWidth) {
    if (widget.timeline.overlays.isEmpty) {
      return GestureDetector(
        onTap: widget.onAddTextTap,
        child: Container(
          height: 30,
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF262015),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: const Color(0xFFFBBF24).withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.add, size: 14, color: Color(0xFFFBBF24)),
              SizedBox(width: 6),
              Text('Tambahkan teks / stiker', style: TextStyle(color: Color(0xFFFBBF24), fontSize: 11)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 30,
      child: Stack(
        children: widget.timeline.overlays.map((overlay) {
          final leftOffset = overlay.startTime * _pixelsPerSecond;
          final duration = (overlay.endTime - overlay.startTime).clamp(0.5, 30.0);
          final clipWidth = (duration * _pixelsPerSecond).clamp(40.0, 3000.0);

          final isVideoPip = overlay.type == OverlayType.video;
          final trackColor = isVideoPip ? const Color(0xFF1E2838) : const Color(0xFF332610);
          final borderColor = isVideoPip ? const Color(0xFF38BDF8) : const Color(0xFFFBBF24);
          final iconData = isVideoPip ? Icons.video_collection_rounded : Icons.title_rounded;
          final titleText = isVideoPip ? 'Video PiP (Duplikat)' : overlay.content;

          return Positioned(
            left: leftOffset,
            child: Container(
              width: clipWidth,
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                children: [
                  Icon(iconData, size: 12, color: borderColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      titleText,
                      style: const TextStyle(color: Colors.white, fontSize: 10, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  Text(
                    '${duration.toStringAsFixed(1)}s',
                    style: const TextStyle(color: Colors.white70, fontSize: 9, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showClipContextMenu(BuildContext context, ClipModel clip, int index) {
    HapticFeedback.heavyImpact();
    widget.onSelectClip(clip.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181824),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Klip Info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.movie_filter_rounded, color: Color(0xFF00E5FF), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Klip ${index + 1} (${clip.timelineDuration.toStringAsFixed(1)}s)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Pilih aksi cepat untuk klip video ini',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 8),

                // Menu Actions Grid / List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildContextActionButton(
                      icon: Icons.call_split_rounded,
                      label: 'Bagi (Split)',
                      color: const Color(0xFF00E5FF),
                      onTap: () {
                        Navigator.pop(ctx);
                        if (widget.onSplitClip != null) {
                          widget.onSplitClip!();
                        }
                      },
                    ),
                    _buildContextActionButton(
                      icon: Icons.copy_rounded,
                      label: 'Duplikat',
                      color: const Color(0xFF10B981),
                      onTap: () {
                        Navigator.pop(ctx);
                        if (widget.onDuplicateSelectedClip != null) {
                          widget.onDuplicateSelectedClip!();
                        }
                      },
                    ),
                    _buildContextActionButton(
                      icon: Icons.published_with_changes_rounded,
                      label: 'Ganti File',
                      color: const Color(0xFFF59E0B),
                      onTap: () {
                        Navigator.pop(ctx);
                        if (widget.onReplaceClip != null) {
                          widget.onReplaceClip!(clip.id);
                        }
                      },
                    ),
                    _buildContextActionButton(
                      icon: Icons.delete_outline_rounded,
                      label: 'Hapus',
                      color: const Color(0xFFEF4444),
                      onTap: () {
                        Navigator.pop(ctx);
                        if (widget.onDeleteSelectedClip != null) {
                          widget.onDeleteSelectedClip!();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContextActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftActionBtn({
    required IconData icon,
    required String label,
    required bool isHighlighted,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: isHighlighted ? const Color(0xFF00E5FF).withValues(alpha: 0.2) : const Color(0xFF222222),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isHighlighted ? const Color(0xFF00E5FF) : Colors.white10,
              ),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isHighlighted ? const Color(0xFF00E5FF) : Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLeftTrackHeader(IconData icon, String label) {
    return Container(
      width: 100,
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF202020),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}

/// Painter Penggaris Waktu
class _RulerPainter extends CustomPainter {
  final double totalDuration;
  final double pixelsPerSecond;

  _RulerPainter({required this.totalDuration, required this.pixelsPerSecond});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 1.0;

    final majorPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1.2;

    const textStyle = TextStyle(color: Colors.white54, fontSize: 9);

    final totalSec = totalDuration.ceil() + 2;
    for (int s = 0; s <= totalSec; s++) {
      final x = s * pixelsPerSecond;
      if (x > size.width) break;

      // Major tick tiap 1 detik
      canvas.drawLine(Offset(x, 0), Offset(x, size.height * 0.5), majorPaint);

      // Label teks tiap 2 detik
      if (s % 2 == 0) {
        final tp = TextPainter(
          text: TextSpan(text: '${s}s', style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x + 2, 2));
      } else {
        // Minor tick
        canvas.drawLine(Offset(x, 0), Offset(x, size.height * 0.25), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RulerPainter oldDelegate) {
    return oldDelegate.totalDuration != totalDuration ||
        oldDelegate.pixelsPerSecond != pixelsPerSecond;
  }
}

/// Painter Audio Waveform Bars dengan visualisasi progress playback yang sinkron
class _WaveformPainter extends CustomPainter {
  final List<double> samples;
  final double playedFraction;

  _WaveformPainter({
    required this.samples,
    this.playedFraction = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;

    final playedPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final unplayedPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.35)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final step = size.width / samples.length;
    final midY = size.height / 2;
    final playedX = size.width * playedFraction;

    for (int i = 0; i < samples.length; i++) {
      final x = i * step + step / 2;
      final barH = (samples[i] * size.height * 0.85) / 2;
      final isPlayed = x <= playedX;
      canvas.drawLine(
        Offset(x, midY - barH),
        Offset(x, midY + barH),
        isPlayed ? playedPaint : unplayedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.samples != samples || oldDelegate.playedFraction != playedFraction;
  }
}
