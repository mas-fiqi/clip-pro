import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../../core/audio/timeline_audio_sync_service.dart';
import '../../../core/engine/ffmpeg_processing_engine.dart';
import '../../../core/engine/video_processing_engine.dart';
import '../../../core/models/clip_model.dart';
import '../../../core/models/clip_transform_model.dart';
import '../../../core/models/keyframe_model.dart';
import '../../../core/models/overlay_model.dart';
import '../../../core/models/project_model.dart';
import '../../../core/models/timeline_model.dart';
import '../../../core/models/rhythm_model.dart';
import '../../../core/services/gallery_saver_service.dart';
import '../../../core/services/project_storage_service.dart';
import '../../../core/services/storage_check_service.dart';
import '../../../core/services/video_picker_service.dart';
import '../../../core/models/editor_performance_profile.dart';
import '../../../core/services/audio_waveform_service.dart';
import '../../../core/services/device_capability_service.dart';
import '../../../core/services/thumbnail_generator_service.dart';
import 'widgets/animation_studio_bottom_sheet.dart';
import 'widgets/audio_library_bottom_sheet.dart';
import 'widgets/audio_studio_bottom_sheet.dart';
import 'widgets/audio_volume_dialog.dart';
import 'widgets/aspect_ratio_bottom_sheet.dart';
import 'widgets/backup_manager_bottom_sheet.dart';
import 'widgets/crop_transform_studio_bottom_sheet.dart';
import 'widgets/duplicate_options_bottom_sheet.dart';
import 'widgets/filter_library_bottom_sheet.dart';
import 'widgets/quality_enhancement_bottom_sheet.dart';
import 'widgets/replace_clip_confirmation_dialog.dart';
import 'widgets/crash_recovery_dialog.dart';
import 'widgets/effect_library_bottom_sheet.dart';
import 'widgets/export_settings_bottom_sheet.dart';
import 'widgets/export_success_dialog.dart';
import 'widgets/interactive_overlay_layer.dart';
import 'widgets/multi_clip_timeline_view.dart';
import 'widgets/overlay_controls_bottom_sheet.dart';
import 'widgets/overlay_editor_dialog.dart';
import 'widgets/overlay_picker_bottom_sheet.dart';
import 'widgets/quick_clip_bottom_bar.dart';
import 'widgets/retouch_bottom_sheet.dart';
import 'widgets/rhythm_studio_bottom_sheet.dart';
import 'widgets/speed_control_dialog.dart';
import 'widgets/transform_toolbar.dart';
import 'widgets/transformable_preview.dart';

class VideoClipperScreen extends StatefulWidget {
  final ProjectModel? initialProject;

  const VideoClipperScreen({super.key, this.initialProject});

  @override
  State<VideoClipperScreen> createState() => _VideoClipperScreenState();
}

class _VideoClipperScreenState extends State<VideoClipperScreen> with WidgetsBindingObserver {
  final VideoPickerService _pickerService = VideoPickerService();
  final VideoProcessingEngine _engine = FFmpegProcessingEngine();
  final GallerySaverService _galleryService = GallerySaverService();
  final TimelineHistory _history = TimelineHistory();
  final ProjectStorageService _storage = ProjectStorageService();

  late ProjectModel _project;
  TimelineModel get _timeline => _project.timeline;
  set _timeline(TimelineModel newTimeline) {
    _project = _project.copyWith(timeline: newTimeline);
    _storage.scheduleAutoSave(_project);
  }

  String? _selectedClipId;
  String? _selectedOverlayId;
  ClipModel? _copiedClipAttributes; // Menyimpan atribut klip yang disalin untuk Paste Attributes

  VideoPlayerController? _videoPlayerController;
  int _activePlayingClipIndex = 0;
  final ValueNotifier<double> _globalPositionNotifier = ValueNotifier<double>(0.0);
  double get _currentGlobalPosition => _globalPositionNotifier.value;
  set _currentGlobalPosition(double val) => _globalPositionNotifier.value = val;
  bool _isSwitchingClip = false;
  bool _isEditSubmenuOpen = false;
  bool _showTransformToolbar = false;
  bool _isMuted = false;

  bool _isProcessing = false;
  double _exportProgress = 0.0;
  String _statusMessage = '';

  ClipModel? get _currentSelectedClip {
    if (_selectedClipId == null || _timeline.clips.isEmpty) return null;
    return _timeline.clips.firstWhere(
      (c) => c.id == _selectedClipId,
      orElse: () => _timeline.clips.first,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.initialProject != null) {
      _project = widget.initialProject!;
    } else {
      _project = ProjectModel(
        id: 'project_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Proyek ${DateTime.now().day}/${DateTime.now().month}',
      );
    }

    // Inisialisasi deteksi profil performa dan preview jika klip awal tersedia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPerformanceProfile();
      _checkCrashRecovery();
      if (_timeline.clips.isNotEmpty) {
        _selectedClipId = _timeline.clips.first.id;
        _loadClipForPreview(0);
      }
    });
  }

  Future<void> _initPerformanceProfile() async {
    try {
      final devService = DeviceCapabilityServiceImpl();
      final caps = await devService.getDeviceCapabilities();
      final perfConfig = EditorPerformanceConfig.detectFromSpecs(
        totalRamMB: caps.totalRamMB,
        availableRamMB: caps.availableRamMB,
        isLowRam: caps.isLowRam,
        deviceModel: caps.deviceModel,
      );
      ThumbnailGeneratorService().applyConfig(perfConfig);
      AudioWaveformService().applyConfig(perfConfig);
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _storage.flushAutoSave();
    }
  }

  Future<void> _checkCrashRecovery() async {
    // Hanya periksa recovery jika project kosong baru dibuat
    if (_timeline.clips.isNotEmpty) return;

    final recovery = await _storage.checkRecoveryData();
    if (recovery != null && mounted) {
      final recoveredProject = recovery['project'] as ProjectModel;
      final timestamp = recovery['timestamp'] as DateTime;

      if (recoveredProject.timeline.clips.isNotEmpty) {
        final shouldRestore = await CrashRecoveryDialog.show(
          context,
          project: recoveredProject,
          crashTimestamp: timestamp,
        );

        if (shouldRestore == true && mounted) {
          setState(() {
            _project = recoveredProject;
            if (_timeline.clips.isNotEmpty) {
              _selectedClipId = _timeline.clips.first.id;
              _loadClipForPreview(0);
            }
          });
          await _storage.saveProjectAtomic(_project);
        } else {
          await _storage.clearRecoveryData();
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isProcessing) {
      _engine.cancelSession();
    }
    _storage.flushAutoSave();
    _videoPlayerController?.dispose();
    TimelineAudioSyncService().dispose();
    ThumbnailGeneratorService().clearMemoryCache();
    AudioWaveformService().clearCache();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final videoFile = await _pickerService.pickVideoFromGallery();
    if (videoFile == null) return;

    final tempController = VideoPlayerController.file(videoFile);
    try {
      await tempController.initialize();
      final durSecs = tempController.value.duration.inMilliseconds / 1000.0;
      await tempController.dispose();

      if (durSecs <= 0.05) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File video tidak memiliki durasi yang valid.')),
          );
        }
        return;
      }

      final newClip = ClipModel(
        id: 'clip_${DateTime.now().millisecondsSinceEpoch}',
        sourcePath: videoFile.path,
        startSource: 0.0,
        endSource: durSecs,
      );

      _history.recordState(_timeline);
      setState(() {
        _timeline = _timeline.addClip(newClip);
        _selectedClipId = newClip.id;
      });

      if (_videoPlayerController == null) {
        _loadClipForPreview(0, seekToSource: 0.0);
      }
    } catch (e) {
      await tempController.dispose();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat video: Format tidak didukung atau file rusak.')),
        );
      }
    }
  }

  Future<void> _loadClipForPreview(int clipIndex, {double? seekToSource, bool autoPlay = true}) async {
    if (clipIndex < 0 || clipIndex >= _timeline.clips.length) return;

    final oldController = _videoPlayerController;
    _videoPlayerController = null; // Lepaskan referensi terlebih dahulu sebelum dispose agar UI tidak merender controller yang sedang ditutup

    if (oldController != null) {
      await oldController.dispose();
    }

    final clip = _timeline.clips[clipIndex];
    final file = File(clip.sourcePath);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File media klip tidak ditemukan di perangkat.')),
        );
      }
      return;
    }

    final controller = VideoPlayerController.file(file);
    try {
      await controller.initialize();

      final initialSeek = seekToSource ?? clip.startSource;
      await controller.seekTo(Duration(milliseconds: (initialSeek * 1000).toInt()));
      await controller.setPlaybackSpeed(clip.speed);
      await controller.setVolume(clip.volume);

      controller.addListener(() => _onPlayerTick(clipIndex));

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _activePlayingClipIndex = clipIndex;
        _videoPlayerController = controller;
        _selectedClipId = clip.id;
      });

      if (autoPlay) {
        controller.play();
      }
    } catch (e) {
      await controller.dispose();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memutar video: File tidak dapat dibaca atau rusak.')),
        );
      }
    }
  }

  void _onPlayerTick(int clipIndex) {
    if (!mounted || _videoPlayerController == null || _isSwitchingClip) return;
    if (clipIndex != _activePlayingClipIndex || clipIndex >= _timeline.clips.length) return;

    final controller = _videoPlayerController!;
    if (!controller.value.isInitialized) return;

    final clip = _timeline.clips[clipIndex];
    final posSecs = controller.value.position.inMilliseconds / 1000.0;

    // Periksa transisi klip berikutnya secara seamless
    if (posSecs >= clip.endSource) {
      if (_isSwitchingClip) return;
      _isSwitchingClip = true;

      if (clipIndex + 1 < _timeline.clips.length) {
        _loadClipForPreview(clipIndex + 1, autoPlay: true).then((_) {
          _isSwitchingClip = false;
        });
      } else {
        // Sudah mencapai ujung akhir timeline proyek
        _isSwitchingClip = false;
        controller.pause();
        // Berhenti tepat di ujung akhir timeline proyek (bukan mendadak lompat)
        setState(() {
          _currentGlobalPosition = _timeline.totalDuration;
        });
      }
      return;
    }

    double clipOffsetInTimeline = 0.0;
    for (int i = 0; i < clipIndex; i++) {
      clipOffsetInTimeline += _timeline.clips[i].timelineDuration;
    }
    final relativePos = (posSecs - clip.startSource).clamp(0.0, clip.sourceDuration);
    final globalPos = clipOffsetInTimeline + (relativePos / clip.speed);

    if ((globalPos - _currentGlobalPosition).abs() < 0.015) {
      return; // 15ms threshold (~60fps sinkronisasi video)
    }

    // Perbarui posisi playhead secara langsung via notifier tanpa memicu full-widget rebuild setState
    _currentGlobalPosition = globalPos;

    // Sinkronisasi audio eksternal real-time
    TimelineAudioSyncService().onTimelineTick(
      currentGlobalPosition: globalPos,
      isVideoPlaying: controller.value.isPlaying,
    );
  }

  void _seekGlobal(double globalSecs) {
    if (_timeline.clips.isEmpty) return;
    final clampedSecs = globalSecs.clamp(0.0, _timeline.totalDuration);
    _currentGlobalPosition = clampedSecs;

    // Sinkronisasi seek pada semua track audio eksternal
    TimelineAudioSyncService().seekAll(clampedSecs);

    double accumulated = 0.0;
    for (int i = 0; i < _timeline.clips.length; i++) {
      final clip = _timeline.clips[i];
      final clipEnd = accumulated + clip.timelineDuration;

      if (clampedSecs >= accumulated && (clampedSecs <= clipEnd || i == _timeline.clips.length - 1)) {
        final offset = clampedSecs - accumulated;
        final targetSource = clip.startSource + (offset * clip.speed);

        if (_activePlayingClipIndex == i && _videoPlayerController != null) {
          _videoPlayerController!.seekTo(Duration(milliseconds: (targetSource * 1000).toInt()));
          if (_selectedClipId != clip.id) {
            setState(() {
              _selectedClipId = clip.id;
            });
          }
        } else {
          final shouldAutoPlay = _videoPlayerController != null && _videoPlayerController!.value.isPlaying;
          _loadClipForPreview(i, seekToSource: targetSource, autoPlay: shouldAutoPlay);
          setState(() {
            _selectedClipId = clip.id;
          });
        }
        return;
      }
      accumulated += clip.timelineDuration;
    }
  }

  void _splitClipAtPlayhead() {
    if (_timeline.clips.isEmpty) return;

    final updated = _timeline.splitAt(_currentGlobalPosition);
    if (updated == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Posisi playhead terlalu dekat ke tepi klip (minimal 0.1 detik).'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    _history.recordState(_timeline);

    // Cari klip bagian kedua (kanan) untuk langsung diseleksi
    String? newSelectedId = _selectedClipId;
    int targetClipIndex = _activePlayingClipIndex;
    double accumulated = 0.0;
    for (int i = 0; i < updated.clips.length; i++) {
      final clip = updated.clips[i];
      final clipEnd = accumulated + clip.timelineDuration;
      if (_currentGlobalPosition >= accumulated && _currentGlobalPosition <= clipEnd) {
        newSelectedId = clip.id;
        targetClipIndex = i;
        break;
      }
      accumulated += clip.timelineDuration;
    }

    setState(() {
      _timeline = updated;
      if (newSelectedId != null) {
        _selectedClipId = newSelectedId;
      }
    });

    // Sinkronkan video controller ke klip aktif agar tidak terjadi preview glitch/out of bounds
    _loadClipForPreview(targetClipIndex);

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✂️ Klip berhasil dipotong (Split)!'),
        duration: Duration(milliseconds: 900),
      ),
    );
  }

  void _deleteLeftAtPlayhead() {
    if (_timeline.clips.isEmpty) return;
    final updated = _timeline.deleteLeftAt(_currentGlobalPosition);
    if (updated == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak bisa menghapus kiri: playhead berada di ujung awal klip.'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    _history.recordState(_timeline);
    setState(() {
      _timeline = updated;
    });
    HapticFeedback.mediumImpact();
    _seekGlobal(_currentGlobalPosition);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🗑️ Bagian kiri berhasil dihapus!'),
        duration: Duration(milliseconds: 900),
      ),
    );
  }

  void _deleteRightAtPlayhead() {
    if (_timeline.clips.isEmpty) return;
    final updated = _timeline.deleteRightAt(_currentGlobalPosition);
    if (updated == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak bisa menghapus kanan: playhead berada di ujung akhir klip.'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    _history.recordState(_timeline);
    setState(() {
      _timeline = updated;
    });
    HapticFeedback.mediumImpact();
    _seekGlobal((_currentGlobalPosition - 0.05).clamp(0.0, updated.totalDuration));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🗑️ Bagian kanan berhasil dihapus!'),
        duration: Duration(milliseconds: 900),
      ),
    );
  }

  void _handleTrimClip(String clipId, double newStart, double newEnd) {
    _history.recordState(_timeline);
    final updated = _timeline.trimClip(clipId, newStart, newEnd);
    setState(() {
      _timeline = updated;
    });

    // Cari posisi global start klip ini agar preview video seketika seek ke titik potong
    double accumulated = 0.0;
    for (int i = 0; i < updated.clips.length; i++) {
      final c = updated.clips[i];
      if (c.id == clipId) {
        final targetGlobalPos = accumulated;
        _currentGlobalPosition = targetGlobalPos;
        if (_activePlayingClipIndex == i && _videoPlayerController != null) {
          _videoPlayerController!.seekTo(Duration(milliseconds: (newStart * 1000).toInt()));
        } else {
          _loadClipForPreview(i, seekToSource: newStart, autoPlay: false);
        }
        break;
      }
      accumulated += c.timelineDuration;
    }
  }

  void _rotateSelectedClip() {
    final clip = _currentSelectedClip;
    if (clip == null) return;
    final currentDeg = clip.transform.rotationDegrees;
    final nextDeg = (currentDeg + 90) % 360;
    _updateClipTransform(clip.transform.copyWith(rotationDegrees: nextDeg));
    HapticFeedback.selectionClick();
  }

  void _flipSelectedClipHorizontal() {
    final clip = _currentSelectedClip;
    if (clip == null) return;
    _updateClipTransform(clip.transform.copyWith(flipHorizontal: !clip.transform.flipHorizontal));
    HapticFeedback.selectionClick();
  }

  void _flipSelectedClipVertical() {
    final clip = _currentSelectedClip;
    if (clip == null) return;
    _updateClipTransform(clip.transform.copyWith(flipVertical: !clip.transform.flipVertical));
    HapticFeedback.selectionClick();
  }

  void _deleteSelectedClip() {
    if (_selectedClipId == null || _timeline.clips.isEmpty) return;

    _history.recordState(_timeline);
    final updated = _timeline.removeClip(_selectedClipId!);

    setState(() {
      _timeline = updated;
      _selectedClipId = updated.clips.isNotEmpty ? updated.clips.first.id : null;
      _currentGlobalPosition = 0.0;
    });

    if (updated.clips.isNotEmpty) {
      _loadClipForPreview(0);
    } else {
      _videoPlayerController?.dispose();
      _videoPlayerController = null;
    }
  }

  void _togglePlayPause() {
    if (_videoPlayerController == null) return;
    if (_videoPlayerController!.value.isPlaying) {
      _videoPlayerController!.pause();
      TimelineAudioSyncService().pauseAll();
      setState(() {});
    } else {
      if (_currentGlobalPosition >= _timeline.totalDuration - 0.1) {
        _seekGlobal(0.0);
      }
      _videoPlayerController?.play();
      TimelineAudioSyncService().onTimelineTick(
        currentGlobalPosition: _currentGlobalPosition,
        isVideoPlaying: true,
      );
      setState(() {});
    }
  }

  Future<void> _duplicateSelectedClip() async {
    if (_selectedClipId == null || _timeline.clips.isEmpty) return;
    final targetClip = _currentSelectedClip;
    if (targetClip == null) return;

    final action = await DuplicateOptionsBottomSheet.show(
      context,
      hasCopiedAttributes: _copiedClipAttributes != null,
    );
    if (action == null) return;

    switch (action) {
      case DuplicateActionType.afterCurrent:
        _history.recordState(_timeline);
        final updated = _timeline.duplicateClip(targetClip.id);
        setState(() {
          _timeline = updated;
        });
        HapticFeedback.mediumImpact();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📑 Klip diduplikat tepat setelah klip ini!'),
              backgroundColor: Color(0xFF00E5FF),
              duration: Duration(milliseconds: 1200),
            ),
          );
        }
        break;

      case DuplicateActionType.toOverlay:
        _history.recordState(_timeline);
        int clipIdx = _timeline.clips.indexWhere((c) => c.id == targetClip.id);
        double accumulated = 0.0;
        for (int i = 0; i < clipIdx; i++) {
          accumulated += _timeline.clips[i].timelineDuration;
        }
        final clipStart = accumulated;
        final clipEnd = accumulated + targetClip.timelineDuration;

        final overlayVideo = OverlayModel(
          id: 'overlay_pip_${DateTime.now().millisecondsSinceEpoch}',
          type: OverlayType.video,
          content: targetClip.sourcePath,
          startTime: clipStart,
          endTime: clipEnd,
          normalizedX: 0.5,
          normalizedY: 0.5,
          scale: 0.85,
        );

        final updated = _timeline.addOverlay(overlayVideo);
        setState(() {
          _timeline = updated;
          _selectedOverlayId = overlayVideo.id;
        });
        HapticFeedback.mediumImpact();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📑 Klip diduplikat ke trek Overlay (PiP)!'),
              backgroundColor: Color(0xFF00E5FF),
              duration: Duration(milliseconds: 1200),
            ),
          );
        }
        break;

      case DuplicateActionType.multiple:
        _history.recordState(_timeline);
        var currentTimeline = _timeline;
        for (int i = 0; i < 3; i++) {
          currentTimeline = currentTimeline.duplicateClip(targetClip.id);
        }
        setState(() {
          _timeline = currentTimeline;
        });
        HapticFeedback.heavyImpact();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📑 Klip berhasil diduplikat 3 kali berurutan!'),
              backgroundColor: Color(0xFF00E5FF),
              duration: Duration(milliseconds: 1200),
            ),
          );
        }
        break;

      case DuplicateActionType.copyAttributes:
        setState(() {
          _copiedClipAttributes = targetClip;
        });
        HapticFeedback.lightImpact();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📋 Atribut klip berhasil disalin!'),
              backgroundColor: Color(0xFF00E5FF),
              duration: Duration(milliseconds: 1200),
            ),
          );
        }
        break;

      case DuplicateActionType.pasteAttributes:
        if (_copiedClipAttributes == null) return;
        _history.recordState(_timeline);
        final pastedClip = targetClip.copyWith(
          speed: _copiedClipAttributes!.speed,
          speedConfig: _copiedClipAttributes!.speedConfig,
          transform: _copiedClipAttributes!.transform,
          adjustment: _copiedClipAttributes!.adjustment,
          effect: _copiedClipAttributes!.effect,
          retouch: _copiedClipAttributes!.retouch,
          audioEffect: _copiedClipAttributes!.audioEffect,
          animation: _copiedClipAttributes!.animation,
        );
        setState(() {
          _timeline = _timeline.updateClip(pastedClip);
        });
        HapticFeedback.mediumImpact();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Atribut berhasil ditempel ke klip ini!'),
              backgroundColor: Color(0xFF10B981),
              duration: Duration(milliseconds: 1200),
            ),
          );
        }
        break;
    }
  }

  Future<void> _replaceClipWithNewVideo(String clipId) async {
    final videoFile = await _pickerService.pickVideoFromGallery();
    if (videoFile == null) return;

    final tempController = VideoPlayerController.file(videoFile);
    final double newDurSecs;
    try {
      await tempController.initialize();
      newDurSecs = tempController.value.duration.inMilliseconds / 1000.0;
      await tempController.dispose();
      if (newDurSecs <= 0.05) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File video pengganti tidak valid.')),
          );
        }
        return;
      }
    } catch (e) {
      await tempController.dispose();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membaca video pengganti: File rusak atau tidak didukung.')),
        );
      }
      return;
    }

    final targetClip = _timeline.clips.firstWhere((c) => c.id == clipId, orElse: () => _timeline.clips.first);
    final oldDuration = targetClip.sourceDuration;

    // Tampilkan Dialog Konfirmasi Replace dengan Opsi Durasi jika berbeda
    if (!mounted) return;
    final choice = await ReplaceClipConfirmationDialog.show(
      context,
      oldDuration: oldDuration,
      newDuration: newDurSecs,
      hasAttributeChanges: true,
    );
    if (choice == null) return;

    double finalStart = 0.0;
    double finalEnd = newDurSecs;

    if (choice == ReplaceFitChoice.keepDuration) {
      final targetSpan = oldDuration;
      finalEnd = (finalStart + targetSpan).clamp(0.1, newDurSecs);
    }

    _history.recordState(_timeline);

    final updatedClip = targetClip.copyWith(
      sourcePath: videoFile.path,
      startSource: finalStart,
      endSource: finalEnd,
      // Seluruh atribut transform, crop, filter, retouch, dan audio effect tetap dipertahankan
    );

    setState(() {
      _timeline = _timeline.updateClip(updatedClip);
    });

    final clipIndex = _timeline.clips.indexWhere((c) => c.id == clipId);
    if (clipIndex != -1) {
      _loadClipForPreview(clipIndex, seekToSource: 0.0);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Sumber klip berhasil diganti dengan tetap menjaga atribut!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  void _updateClipTransform(ClipTransformModel newTransform) {
    final clip = _currentSelectedClip;
    if (clip == null) return;

    _history.recordState(_timeline);
    final updatedClip = clip.copyWith(transform: newTransform);
    setState(() {
      _timeline = _timeline.updateClip(updatedClip);
    });
  }

  // --- Speed Control & Volume ---

  Future<void> _openSpeedDialog() async {
    final clip = _currentSelectedClip;
    if (clip == null) return;

    final result = await SpeedControlBottomSheet.show(
      context,
      initialConfig: clip.speedConfig,
      clipDuration: clip.sourceDuration,
      onApply: (newConfig) {
        _history.recordState(_timeline);
        final effectiveSpeed = newConfig.effectiveSpeed;
        final updatedClip = clip.copyWith(
          speed: effectiveSpeed,
          speedConfig: newConfig,
        );
        setState(() {
          _timeline = _timeline.updateClip(updatedClip);
        });
        _videoPlayerController?.setPlaybackSpeed(effectiveSpeed.clamp(0.25, 2.0));
      },
    );

    if (result != null) {
      _history.recordState(_timeline);
      final effectiveSpeed = result.effectiveSpeed;
      final updatedClip = clip.copyWith(
        speed: effectiveSpeed,
        speedConfig: result,
      );
      setState(() {
        _timeline = _timeline.updateClip(updatedClip);
      });
      _videoPlayerController?.setPlaybackSpeed(effectiveSpeed.clamp(0.25, 2.0));
    }
  }

  // --- Rhythm & Beat Studio (Irama Musik) ---

  Future<void> _openRhythmDialog() async {
    final audio = _timeline.audioClips.isNotEmpty ? _timeline.audioClips.first : null;
    final initialRhythm = audio != null ? audio.rhythm : const RhythmModel();
    final dur = audio != null ? audio.duration : _timeline.totalDuration;

    await RhythmStudioBottomSheet.show(
      context,
      initialRhythm: initialRhythm,
      audioDuration: dur,
      onApply: (newRhythm) {
        if (_timeline.audioClips.isNotEmpty) {
          _history.recordState(_timeline);
          final updatedAudio = _timeline.audioClips.first.copyWith(rhythm: newRhythm);
          setState(() {
            _timeline = _timeline.updateAudioClip(updatedAudio);
          });
        }
      },
    );
  }

  Future<void> _openVolumeDialog() async {
    final clip = _currentSelectedClip;
    if (clip == null) return;

    final result = await AudioVolumeBottomSheet.show(
      context,
      clip: clip,
    );

    if (result != null) {
      _history.recordState(_timeline);
      final updatedClip = clip.copyWith(volume: result);
      setState(() {
        _timeline = _timeline.updateClip(updatedClip);
      });
      _videoPlayerController?.setVolume(result);
    }
  }

  // --- Audio Studio & Voice Enhancement ---

  Future<void> _openAudioStudioDialog() async {
    final clip = _currentSelectedClip;
    if (clip == null) return;

    final result = await AudioStudioBottomSheet.show(
      context,
      clip: clip,
    );

    if (result != null && mounted) {
      _history.recordState(_timeline);
      final updatedClip = clip.copyWith(audioEffect: result);
      setState(() {
        _timeline = _timeline.updateClip(updatedClip);
      });
      _videoPlayerController?.setVolume(result.volume.clamp(0.0, 1.0));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎙️ Efek suara Audio Studio berhasil diterapkan!'),
          backgroundColor: Color(0xFF00E5FF),
          duration: Duration(milliseconds: 1000),
        ),
      );
    }
  }

  // --- Filter & Color Grading (CapCut Style Filter Library) ---

  Future<void> _openFilterDialog() async {
    final clip = _currentSelectedClip;
    if (clip == null) return;

    final result = await FilterLibraryBottomSheet.show(
      context,
      initialAdjustment: clip.adjustment,
    );

    if (result != null) {
      _history.recordState(_timeline);
      final updatedClip = clip.copyWith(adjustment: result);
      setState(() {
        _timeline = _timeline.updateClip(updatedClip);
      });
    }
  }

  // --- Effect Library (Bagian 7 Redesign) ---

  Future<void> _openEffectDialog() async {
    final clip = _currentSelectedClip;
    if (clip == null) return;

    final originalEffect = clip.effect;

    final result = await EffectLibraryBottomSheet.show(
      context,
      initialEffect: clip.effect,
      onPreviewEffectChanged: (previewEffect) {
        // Terapkan efek sementara pada video pengguna (Live Preview)
        final tempClip = clip.copyWith(effect: previewEffect);
        setState(() {
          _timeline = _timeline.updateClip(tempClip);
        });
      },
    );

    if (result != null) {
      _history.recordState(_timeline);
      final updatedClip = clip.copyWith(effect: result);
      setState(() {
        _timeline = _timeline.updateClip(updatedClip);
      });
    } else {
      // Jika pengguna membatalkan (dismiss), kembalikan ke efek awal
      final revertedClip = clip.copyWith(effect: originalEffect);
      setState(() {
        _timeline = _timeline.updateClip(revertedClip);
      });
    }
  }

  // --- Beauty Retouch Modul (Wajah, Kulit, Mata, Riasan & Tubuh) ---

  Future<void> _openRetouchDialog() async {
    final clip = _currentSelectedClip;
    if (clip == null) return;

    final result = await RetouchBottomSheet.show(
      context,
      initialRetouch: clip.retouch,
    );

    if (result != null && mounted) {
      _history.recordState(_timeline);
      final updatedClip = clip.copyWith(retouch: result);
      setState(() {
        _timeline = _timeline.updateClip(updatedClip);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Beauty Retouch berhasil diterapkan!'),
          backgroundColor: Color(0xFF00E5FF),
          duration: Duration(milliseconds: 1000),
        ),
      );
    }
  }

  // --- Quality Enhancement (Phase 4 Studio) ---

  Future<void> _openQualityEnhancementDialog() async {
    final clip = _currentSelectedClip;
    if (clip == null) return;

    await QualityEnhancementBottomSheet.show(
      context,
      initialQuality: clip.quality,
      onApply: (newQuality) {
        _history.recordState(_timeline);
        final updatedClip = clip.copyWith(quality: newQuality);
        setState(() {
          _timeline = _timeline.updateClip(updatedClip);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Peningkatan Kualitas Video diterapkan!'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(milliseconds: 1200),
          ),
        );
      },
    );
  }

  // --- Animation Studio CapCut Style (IN, OUT, COMBO, Presets) ---

  Future<void> _openAnimationStudioDialog() async {
    final clip = _currentSelectedClip;
    if (clip == null) return;

    final initialAnim = clip.animation;
    bool hasConfirmed = false;

    final result = await AnimationStudioBottomSheet.show(
      context,
      initialAnimation: clip.animation,
      clipDuration: clip.timelineDuration,
      onApply: (newAnim) {
        hasConfirmed = true;
        _history.recordState(_timeline);
        final updatedClip = clip.copyWith(animation: newAnim);
        setState(() {
          _timeline = _timeline.updateClip(updatedClip);
        });
      },
      onTriggerPreviewPlayback: () {
        // Otomatis putar cuplikan klip 0.sekian detik saat preset ditekan agar terlihat langsung di layar video
        if (_videoPlayerController != null) {
          int clipIdx = _timeline.clips.indexWhere((c) => c.id == clip.id);
          double accumulated = 0.0;
          for (int i = 0; i < clipIdx; i++) {
            accumulated += _timeline.clips[i].timelineDuration;
          }
          _seekGlobal(accumulated);
          _videoPlayerController!.play();
        }
      },
    );

    if (result != null) {
      // Tombol centang/Terapkan diklik
      _history.recordState(_timeline);
      final updatedClip = clip.copyWith(animation: result);
      setState(() {
        _timeline = _timeline.updateClip(updatedClip);
      });
      // Segera simpan draft proyek secara atomic/autosave
      await _storage.saveProjectAtomic(_project);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.hasAnimation 
              ? '✅ Animasi "${result.presetId.replaceAll('_', ' ').toUpperCase()}" berhasil disimpan ke klip!'
              : '✅ Animasi berhasil dihapus dari klip!'),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    } else if (!hasConfirmed) {
      // Pengguna membatalkan / menutup modal tanpa menekan tombol Terapkan (centang)
      // Kembalikan ke animasi semula (initialAnim)
      final revertedClip = clip.copyWith(animation: initialAnim);
      setState(() {
        _timeline = _timeline.updateClip(revertedClip);
      });
    }
  }

  // --- Aspect Ratio & Canvas (Bagian 9 Redesign) ---

  Future<void> _openAspectRatioDialog() async {
    final clip = _currentSelectedClip;
    if (clip == null) return;

    final result = await AspectRatioBottomSheet.show(
      context,
      initialTransform: clip.transform,
      videoNaturalAspectRatio: _videoPlayerController?.value.aspectRatio ?? (16.0 / 9.0),
    );

    if (result != null) {
      _history.recordState(_timeline);
      final updatedClip = clip.copyWith(transform: result);
      setState(() {
        _timeline = _timeline.updateClip(updatedClip);
      });
    }
  }

  // --- Audio Track Operations ---

  Future<void> _handlePickExternalAudio() async {
    // Membuka BottomSheet Audio Library Profesional (Online Free, SFX, Lokal, Rekam & Ekstrak)
    await AudioLibraryBottomSheet.show(
      context,
      currentTimelinePosition: _currentGlobalPosition,
      onAddAudioToTimeline: (newAudio) {
        _history.recordState(_timeline);
        setState(() {
          _timeline = _timeline.addAudioClip(newAudio);
        });
        TimelineAudioSyncService().syncAudioClips(_timeline.audioClips);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audio "${newAudio.title}" berhasil ditambahkan ke timeline!'),
            backgroundColor: const Color(0xFF00E5FF),
          ),
        );
      },
    );
  }

  // --- Keyframe Animation Operations ---

  double _getCurrentClipRelativeTime() {
    final clip = _currentSelectedClip;
    if (clip == null) return 0.0;
    int clipIndex = _timeline.clips.indexWhere((c) => c.id == clip.id);
    if (clipIndex < 0) return 0.0;

    double accumulated = 0.0;
    for (int i = 0; i < clipIndex; i++) {
      accumulated += _timeline.clips[i].timelineDuration;
    }
    return (_currentGlobalPosition - accumulated).clamp(0.0, clip.timelineDuration);
  }

  bool _hasKeyframeAtCurrentPosition() {
    final clip = _currentSelectedClip;
    if (clip == null || clip.keyframes.isEmpty) return false;
    final relTime = _getCurrentClipRelativeTime();
    return clip.keyframes.any((k) => (k.timestampSeconds - relTime).abs() <= 0.15);
  }

  void _handleToggleKeyframe() {
    final clip = _currentSelectedClip;
    if (clip == null) return;
    final relTime = _getCurrentClipRelativeTime();

    final existingIdx = clip.keyframes.indexWhere((k) => (k.timestampSeconds - relTime).abs() <= 0.15);
    _history.recordState(_timeline);

    final updatedKeyframes = List<KeyframeModel>.from(clip.keyframes);
    if (existingIdx >= 0) {
      // Hapus keyframe di posisi waktu ini
      updatedKeyframes.removeAt(existingIdx);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keyframe dihapus'),
          duration: Duration(milliseconds: 700),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    } else {
      // Tambahkan keyframe baru di posisi waktu ini dengan nilai default/interpolasi saat ini
      final currentValues = InterpolatedKeyframeValues.evaluate(clip.keyframes, relTime);
      final newKf = KeyframeModel(
        id: 'kf_${DateTime.now().millisecondsSinceEpoch}',
        timestampSeconds: relTime,
        positionX: currentValues.positionX,
        positionY: currentValues.positionY,
        scale: currentValues.scale,
        rotationDegrees: currentValues.rotationDegrees,
        opacity: currentValues.opacity,
        volume: currentValues.volume,
      );
      updatedKeyframes.add(newKf);
      updatedKeyframes.sort((a, b) => a.timestampSeconds.compareTo(b.timestampSeconds));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keyframe ditambahkan di titik ini'),
          duration: Duration(milliseconds: 700),
          backgroundColor: Color(0xFF00E5FF),
        ),
      );
    }

    setState(() {
      _timeline = _timeline.updateClip(clip.copyWith(keyframes: updatedKeyframes));
    });
  }

  void _handlePrevKeyframe() {
    final clip = _currentSelectedClip;
    if (clip == null || clip.keyframes.isEmpty) return;
    final relTime = _getCurrentClipRelativeTime();

    int clipIndex = _timeline.clips.indexWhere((c) => c.id == clip.id);
    double accumulated = 0.0;
    for (int i = 0; i < clipIndex; i++) {
      accumulated += _timeline.clips[i].timelineDuration;
    }

    final prevKeyframes = clip.keyframes
        .where((k) => k.timestampSeconds < relTime - 0.05)
        .toList();

    if (prevKeyframes.isNotEmpty) {
      prevKeyframes.sort((a, b) => a.timestampSeconds.compareTo(b.timestampSeconds));
      final target = prevKeyframes.last;
      _seekGlobal(accumulated + target.timestampSeconds);
    }
  }

  void _handleNextKeyframe() {
    final clip = _currentSelectedClip;
    if (clip == null || clip.keyframes.isEmpty) return;
    final relTime = _getCurrentClipRelativeTime();

    int clipIndex = _timeline.clips.indexWhere((c) => c.id == clip.id);
    double accumulated = 0.0;
    for (int i = 0; i < clipIndex; i++) {
      accumulated += _timeline.clips[i].timelineDuration;
    }

    final nextKeyframes = clip.keyframes
        .where((k) => k.timestampSeconds > relTime + 0.05)
        .toList();

    if (nextKeyframes.isNotEmpty) {
      nextKeyframes.sort((a, b) => a.timestampSeconds.compareTo(b.timestampSeconds));
      final target = nextKeyframes.first;
      _seekGlobal(accumulated + target.timestampSeconds);
    }
  }

  // --- Overlay (Teks, Stiker, Gambar & Video PiP) ---

  Future<void> _openOverlayPickerBottomSheet() async {
    await OverlayPickerBottomSheet.show(
      context,
      pickerService: _pickerService,
      onMediaSelected: (path, isVideo) {
        final start = _currentGlobalPosition;
        final end = (start + 5.0).clamp(0.0, _timeline.totalDuration > 0 ? _timeline.totalDuration : start + 5.0);
        final newOverlay = OverlayModel(
          id: 'overlay_${DateTime.now().millisecondsSinceEpoch}',
          type: isVideo ? OverlayType.video : OverlayType.image,
          content: path,
          startTime: start,
          endTime: end > start ? end : start + 3.0,
          scale: 1.0,
          normalizedX: 0.5,
          normalizedY: 0.5,
        );

        _history.recordState(_timeline);
        setState(() {
          _timeline = _timeline.addOverlay(newOverlay);
          _selectedOverlayId = newOverlay.id;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isVideo ? 'Video Overlay (PiP) ditambahkan!' : 'Gambar Overlay ditambahkan!'),
            backgroundColor: const Color(0xFF00E5FF),
          ),
        );
      },
    );
  }

  Future<void> _openAddOrEditTextDialog({OverlayModel? existing}) async {
    final result = await showDialog<OverlayModel>(
      context: context,
      builder: (context) => OverlayEditorDialog(
        initialOverlay: existing,
        currentGlobalTime: _currentGlobalPosition,
      ),
    );

    if (result != null) {
      _history.recordState(_timeline);
      setState(() {
        if (existing == null) {
          _timeline = _timeline.addOverlay(result);
          _selectedOverlayId = result.id;
        } else {
          _timeline = _timeline.updateOverlay(result);
        }
      });
    }
  }

  void _handleDragOverlay(String id, double deltaNormX, double deltaNormY) {
    final overlay = _timeline.overlays.firstWhere((o) => o.id == id);
    final newX = (overlay.normalizedX + deltaNormX).clamp(0.05, 0.95);
    final newY = (overlay.normalizedY + deltaNormY).clamp(0.05, 0.95);

    setState(() {
      _timeline = _timeline.updateOverlay(
        overlay.copyWith(normalizedX: newX, normalizedY: newY),
      );
    });
  }

  void _deleteSelectedOverlay() {
    if (_selectedOverlayId == null) return;
    _history.recordState(_timeline);
    setState(() {
      _timeline = _timeline.removeOverlay(_selectedOverlayId!);
      _selectedOverlayId = null;
    });
  }

  void _handleUndo() {
    final prev = _history.undo(_timeline);
    if (prev != null) {
      setState(() {
        _timeline = prev;
        _selectedClipId = prev.clips.isNotEmpty ? prev.clips.first.id : null;
      });
      if (prev.clips.isNotEmpty) {
        _loadClipForPreview(0);
      }
    }
  }

  void _handleRedo() {
    final next = _history.redo(_timeline);
    if (next != null) {
      setState(() {
        _timeline = next;
        _selectedClipId = next.clips.isNotEmpty ? next.clips.first.id : null;
      });
      if (next.clips.isNotEmpty) {
        _loadClipForPreview(0);
      }
    }
  }

  Future<void> _exportTimelineVideo() async {
    if (_timeline.clips.isEmpty) return;

    final config = await ExportSettingsBottomSheet.show(
      context,
      totalDurationSeconds: _timeline.totalDuration,
    );

    if (config == null) return;

    // 1. Storage Pre-Check: Periksa kecukupan estimasi penyimpanan nyata (StatFs / DeviceCapability)
    final estimatedMb = config.estimateFileSizeMB(_timeline.totalDuration).ceil();
    final storageCheck = await StorageCheckService().checkStorageSufficiency(estimatedMb.toDouble());
    if (!storageCheck.isSufficient) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(storageCheck.message),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    _videoPlayerController?.pause();
    // Gunakan immutable snapshot timeline & simpan status sebelum ekspor
    final exportSnapshot = TimelineModel(
      clips: List.from(_timeline.clips),
      overlays: List.from(_timeline.overlays),
      audioClips: List.from(_timeline.audioClips),
    );
    await _storage.flushAutoSave();

    setState(() {
      _isProcessing = true;
      _exportProgress = 0.0;
      _statusMessage = 'Mengekspor video (${config.targetHeight}p @ ${config.fpsValue}fps)... 0%';
    });

    final outputFile = await _engine.exportTimeline(
      timeline: exportSnapshot,
      exportConfig: config,
      onProgress: (prog) {
        if (mounted) {
          setState(() {
            _exportProgress = prog;
            _statusMessage = 'Mengekspor video (${config.targetHeight}p)... ${(prog * 100).toInt()}%';
          });
        }
      },
      onLog: (log) => debugPrint('FFmpeg: $log'),
    );

    if (outputFile == null) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ekspor dibatalkan atau terjadi kegagalan.')),
        );
      }
      return;
    }

    if (mounted) {
      setState(() => _statusMessage = 'Menyimpan video ke galeri...');
    }

    final saveResult = await _galleryService.saveVideoToGalleryWithResult(outputFile.path);

    if (mounted) {
      setState(() => _isProcessing = false);
      if (!saveResult.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(saveResult.userMessage),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      // Tampilkan Interactive Export Success BottomSheet
      ExportSuccessDialog.show(
        context,
        filePath: outputFile.path,
        isSavedToGallery: saveResult.isSuccess,
        resolutionText: '${config.targetHeight}p (${config.fpsValue} FPS)',
        fileSizeEstimateMb: estimatedMb,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasClips = _timeline.clips.isNotEmpty;
    final selectedClip = _currentSelectedClip;

    final isPlaying = _videoPlayerController?.value.isPlaying ?? false;

    return PopScope(
      canPop: !_isProcessing,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_isProcessing) {
          final shouldCancel = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF222222),
              title: const Text('Batalkan Ekspor?', style: TextStyle(color: Colors.white, fontSize: 16)),
              content: const Text(
                'Video sedang dalam proses ekspor. Apakah Anda yakin ingin membatalkan proses ini?',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Lanjutkan Ekspor', style: TextStyle(color: Colors.white54)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Batalkan', style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
          );

          if (shouldCancel == true) {
            await _engine.cancelSession();
            if (context.mounted) {
              setState(() {
                _isProcessing = false;
                _statusMessage = 'Ekspor dibatalkan.';
              });
              Navigator.of(context).maybePop();
            }
          }
        }
      },
      child: Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          tooltip: 'Kembali ke Manajer Proyek',
          onPressed: () async {
            if (_isProcessing) {
              final shouldCancel = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF222222),
                  title: const Text('Batalkan Ekspor?', style: TextStyle(color: Colors.white, fontSize: 16)),
                  content: const Text(
                    'Video sedang dalam proses ekspor. Apakah Anda yakin ingin membatalkan proses ini?',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Lanjutkan Ekspor', style: TextStyle(color: Colors.white54)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Batalkan', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
              if (shouldCancel == true) {
                await _engine.cancelSession();
                if (context.mounted) {
                  setState(() => _isProcessing = false);
                  Navigator.of(context).maybePop();
                }
              }
              return;
            }

            await _storage.flushAutoSave();
            if (context.mounted) {
              Navigator.of(context).maybePop();
            }
          },
        ),
        titleSpacing: 0,
        title: const SizedBox.shrink(),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        actions: [
          // Auto Save Status Icon
          ValueListenableBuilder<AutoSaveStatus>(
            valueListenable: _storage.autoSaveStatusNotifier,
            builder: (context, status, _) {
              Color color = Colors.white38;
              String tooltip = 'Otomatis tersimpan';
              IconData icon = Icons.check_circle_outline_rounded;

              switch (status) {
                case AutoSaveStatus.saving:
                  color = const Color(0xFFFBBF24); // Amber
                  tooltip = 'Sedang menyimpan...';
                  icon = Icons.sync_rounded;
                  break;
                case AutoSaveStatus.saved:
                  color = const Color(0xFF10B981); // Emerald
                  tooltip = 'Proyek tersimpan rapi';
                  icon = Icons.cloud_done_rounded;
                  break;
                case AutoSaveStatus.unsavedChanges:
                  color = const Color(0xFF60A5FA); // Blue
                  tooltip = 'Ada perubahan draft baru';
                  icon = Icons.edit_note_rounded;
                  break;
                case AutoSaveStatus.failed:
                  color = const Color(0xFFEF4444); // Red
                  tooltip = 'Penyimpanan draft gagal';
                  icon = Icons.error_outline_rounded;
                  break;
                case AutoSaveStatus.idle:
                  return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Tooltip(
                  message: tooltip,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Icon(icon, size: 14, color: color),
                  ),
                ),
              );
            },
          ),

          IconButton(
            tooltip: 'Cadangan (Backup)',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: const Icon(Icons.archive_outlined, size: 18, color: Colors.white70),
            onPressed: () async {
              final restored = await BackupManagerBottomSheet.show(context, project: _project);
              if (restored != null && mounted) {
                setState(() {
                  _project = restored;
                  if (_timeline.clips.isNotEmpty) {
                    _selectedClipId = _timeline.clips.first.id;
                    _loadClipForPreview(0);
                  }
                });
              }
            },
          ),
          IconButton(
            tooltip: 'Undo',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: const Icon(Icons.undo_rounded, size: 18),
            onPressed: _history.canUndo ? _handleUndo : null,
          ),
          IconButton(
            tooltip: 'Redo',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: const Icon(Icons.redo_rounded, size: 18),
            onPressed: _history.canRedo ? _handleRedo : null,
          ),
          const SizedBox(width: 4),

          // CapCut Diamond Pro Icon
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.diamond_rounded, color: Color(0xFFA78BFA), size: 14),
          ),
          const SizedBox(width: 4),

          // UHD AI Pill Button
          Container(
            height: 26,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('UHD AI', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                Icon(Icons.arrow_drop_down_rounded, color: Colors.white70, size: 15),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // CapCut Cyan "Ekspor" Button
          if (hasClips && !_isProcessing)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: const Size(0, 28),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: _exportTimelineVideo,
                child: const Text('Ekspor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
        ],
      ),
      body: _isProcessing
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A26),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LinearProgressIndicator(
                        value: _exportProgress,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                        color: const Color(0xFF8B5CF6),
                        backgroundColor: Colors.white12,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _statusMessage,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFF87171),
                          side: const BorderSide(color: Color(0xFFF87171)),
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF1E1E2D),
                              title: const Text('Batalkan Ekspor?', style: TextStyle(color: Colors.white)),
                              content: const Text(
                                'Proses rendering video saat ini sedang berjalan. Yakin ingin membatalkan?',
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Lanjutkan Ekspor', style: TextStyle(color: Color(0xFF8B5CF6))),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Ya, Batalkan', style: TextStyle(color: Color(0xFFF87171))),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await _engine.cancelSession();
                            if (mounted) {
                              setState(() => _isProcessing = false);
                            }
                          }
                        },
                        child: const Text('Batalkan Ekspor'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Column(
              children: [
                // Area Video Preview (Dominan di Tengah)
                Expanded(
                  child: Container(
                    color: Colors.black,
                    alignment: Alignment.center,
                    child: hasClips && _videoPlayerController != null && selectedClip != null
                        ? RepaintBoundary(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ValueListenableBuilder<double>(
                                  valueListenable: _globalPositionNotifier,
                                  builder: (context, globalPos, _) {
                                    return TransformablePreview(
                                      controller: _videoPlayerController!,
                                      transform: selectedClip.transform,
                                      adjustment: selectedClip.adjustment,
                                      effect: selectedClip.effect,
                                      animation: selectedClip.animation,
                                      keyframes: selectedClip.keyframes,
                                      currentClipSeconds: _getCurrentClipRelativeTime(),
                                      totalClipSeconds: selectedClip.timelineDuration,
                                    );
                                  },
                                ),
                                ValueListenableBuilder<double>(
                                  valueListenable: _globalPositionNotifier,
                                  builder: (context, globalPos, _) {
                                    return InteractiveOverlayLayer(
                                      overlays: _timeline.overlays,
                                      currentGlobalTime: globalPos,
                                      selectedOverlayId: _selectedOverlayId,
                                      onSelectOverlay: (id) async {
                                        setState(() => _selectedOverlayId = id);
                                        final target = _timeline.overlays.firstWhere((o) => o.id == id);
                                        await OverlayControlsBottomSheet.show(
                                          context,
                                          overlay: target,
                                          onOverlayChanged: (updated) {
                                            setState(() {
                                              _timeline = _timeline.updateOverlay(updated);
                                            });
                                          },
                                          onDelete: _deleteSelectedOverlay,
                                        );
                                      },
                                      onDragOverlay: _handleDragOverlay,
                                    );
                                  },
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.video_collection_outlined,
                                  size: 64,
                                  color: Color(0xFF8B5CF6),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Mulai Proyek Video Anda',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Pilih video dari galeri untuk mulai mengedit',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B5CF6),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                ),
                                onPressed: _pickVideo,
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Pilih Video'),
                              ),
                            ],
                          ),
                  ),
                ),

                // Baris 1: Toolbar Transformasi & Rasio Kanvas (Bisa ditoggle dari tombol Rasio / Edit)
                if (hasClips && selectedClip != null && _showTransformToolbar)
                  TransformToolbar(
                    currentTransform: selectedClip.transform,
                    onTransformChanged: _updateClipTransform,
                    onOpenAdvancedRatioSheet: _openAspectRatioDialog,
                  ),

                // Baris 2: Timeline Multi-Track CapCut Style
                if (hasClips)
                  MultiClipTimelineView(
                    timeline: _timeline,
                    selectedClipId: _selectedClipId,
                    currentPosition: _currentGlobalPosition,
                    positionNotifier: _globalPositionNotifier,
                    isPlaying: isPlaying,
                    isMuted: _isMuted,
                    hasKeyframeAtCurrentPosition: _hasKeyframeAtCurrentPosition(),
                    onToggleKeyframe: _handleToggleKeyframe,
                    onPrevKeyframe: _handlePrevKeyframe,
                    onNextKeyframe: _handleNextKeyframe,
                    onSelectClip: (id) {
                      setState(() {
                        _selectedClipId = id;
                        _isEditSubmenuOpen = true; // Langsung buka sub-toolbar edit klip lengkap ala CapCut saat klip diklik
                      });
                    },
                    onSeek: _seekGlobal,
                    onReorder: (oldIdx, newIdx) {
                      _history.recordState(_timeline);
                      setState(() {
                        _timeline = _timeline.reorderClip(oldIdx, newIdx);
                      });
                    },
                    onAddVideoTap: _pickVideo,
                    onAddAudioTap: _handlePickExternalAudio,
                    onAddTextTap: () => _openAddOrEditTextDialog(),
                    onPlayPauseTap: _togglePlayPause,
                    onToggleFullscreen: () {
                      setState(() {
                        _showTransformToolbar = !_showTransformToolbar;
                      });
                    },
                    onMuteToggle: () {
                      setState(() {
                        _isMuted = !_isMuted;
                        _videoPlayerController?.setVolume(_isMuted ? 0.0 : 1.0);
                      });
                    },
                    onDuplicateSelectedClip: _duplicateSelectedClip,
                    onSplitClip: _splitClipAtPlayhead,
                    onDeleteSelectedClip: _deleteSelectedClip,
                    onReplaceClip: (clipId) => _replaceClipWithNewVideo(clipId),
                    onTrimClip: _handleTrimClip,
                  ),

                // Baris 3: Bottom Action Tools (CapCut-Style Bottom Bar)
                if (hasClips)
                  QuickClipBottomBar(
                    isEditMode: _isEditSubmenuOpen,
                    onBackTap: () {
                      setState(() {
                        _isEditSubmenuOpen = false;
                      });
                    },
                    onEditTap: () {
                      setState(() {
                        _isEditSubmenuOpen = true;
                      });
                    },
                    onAudioTap: _handlePickExternalAudio,
                    onTextTap: () => _openAddOrEditTextDialog(),
                    onEffectTap: _openEffectDialog,
                    onOverlayTap: _openOverlayPickerBottomSheet,
                    onFilterTap: _openFilterDialog,
                    onTransformTap: () async {
                      final clip = _currentSelectedClip;
                      if (clip == null) return;
                      final naturalRatio = _videoPlayerController != null && _videoPlayerController!.value.isInitialized
                          ? _videoPlayerController!.value.aspectRatio
                          : 16.0 / 9.0;
                      final res = await CropTransformStudioBottomSheet.show(
                        context,
                        initialTransform: clip.transform,
                        videoNaturalAspectRatio: naturalRatio,
                        onApply: (updated) => _updateClipTransform(updated),
                      );
                      if (res != null) {
                        _updateClipTransform(res);
                      }
                    },
                    onSpeedTap: _openSpeedDialog,
                    onVolumeTap: _openVolumeDialog,
                    onDuplicateTap: _duplicateSelectedClip,
                    onSplitTap: _splitClipAtPlayhead,
                    onDeleteLeftTap: _deleteLeftAtPlayhead,
                    onDeleteRightTap: _deleteRightAtPlayhead,
                    onRotateTap: _rotateSelectedClip,
                    onFlipHorizontalTap: _flipSelectedClipHorizontal,
                    onFlipVerticalTap: _flipSelectedClipVertical,
                    onDeleteTap: _deleteSelectedClip,
                    hasSelectedOverlay: _selectedOverlayId != null,
                    onDeleteOverlayTap: _deleteSelectedOverlay,
                    onRetouchTap: _openRetouchDialog,
                    onAudioStudioTap: _openAudioStudioDialog,
                    onAnimationTap: _openAnimationStudioDialog,
                    onRhythmTap: _openRhythmDialog,
                    onQualityTap: _openQualityEnhancementDialog,
                  ),
              ],
            ),
    ),
    );
  }
}
