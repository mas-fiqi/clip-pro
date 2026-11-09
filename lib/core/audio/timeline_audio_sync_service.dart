import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import '../models/audio_clip_model.dart';

/// Single audio track player instance for timeline playback
class _ActiveAudioTrack {
  final AudioClipModel model;
  final VideoPlayerController controller;
  bool isPlaying = false;

  _ActiveAudioTrack({
    required this.model,
    required this.controller,
  });
}

/// Service untuk memutar semua trek audio eksternal secara tersinkronisasi
/// dengan playhead timeline QuickClip Pro
class TimelineAudioSyncService {
  static final TimelineAudioSyncService _instance = TimelineAudioSyncService._internal();
  factory TimelineAudioSyncService() => _instance;
  TimelineAudioSyncService._internal();

  final Map<String, _ActiveAudioTrack> _tracks = {};
  bool _isDisposed = false;

  /// Helper resolve source path (baik asset lokal, file di disk, atau online URL)
  static Future<String> resolveAudioPath(String path) async {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (path.startsWith('assets/')) {
      // Ekstrak asset ke local temp file agar VideoPlayer file player dapat membacanya langsung tanpa lag
      try {
        final tempDir = await getTemporaryDirectory();
        final fileName = path.replaceAll('/', '_');
        final targetFile = File('${tempDir.path}/$fileName');
        if (!await targetFile.exists()) {
          final byteData = await rootBundle.load(path);
          await targetFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
        }
        return targetFile.path;
      } catch (e) {
        debugPrint('Error extracting audio asset $path: $e');
        return path;
      }
    }
    return path;
  }

  /// Sinkronisasi daftar audio clips dengan controller yang sedang aktif
  Future<void> syncAudioClips(List<AudioClipModel> clips) async {
    if (_isDisposed) return;

    final currentIds = clips.map((c) => c.id).toSet();

    // Hapus track yang sudah tidak ada di timeline
    final idsToRemove = _tracks.keys.where((id) => !currentIds.contains(id)).toList();
    for (final id in idsToRemove) {
      await _tracks[id]?.controller.pause();
      await _tracks[id]?.controller.dispose();
      _tracks.remove(id);
    }

    // Inisialisasi controller untuk audio yang baru
    for (final clip in clips) {
      if (!_tracks.containsKey(clip.id)) {
        try {
          final resolvedPath = await resolveAudioPath(clip.sourcePath);
          VideoPlayerController controller;
          if (resolvedPath.startsWith('http')) {
            controller = VideoPlayerController.networkUrl(Uri.parse(resolvedPath));
          } else if (resolvedPath.startsWith('assets/')) {
            controller = VideoPlayerController.asset(resolvedPath);
          } else {
            controller = VideoPlayerController.file(File(resolvedPath));
          }

          await controller.initialize();
          await controller.setVolume(clip.isMuted ? 0.0 : clip.volume.clamp(0.0, 1.0));

          _tracks[clip.id] = _ActiveAudioTrack(
            model: clip,
            controller: controller,
          );
        } catch (e) {
          debugPrint('Gagal inisialisasi track audio ${clip.title}: $e');
        }
      } else {
        // Update volume jika ada perubahan
        final existing = _tracks[clip.id]!;
        if (existing.model.volume != clip.volume || existing.model.isMuted != clip.isMuted) {
          existing.controller.setVolume(clip.isMuted ? 0.0 : clip.volume.clamp(0.0, 1.0));
        }
      }
    }
  }

  /// Sinkronisasi posisi waktu playhead dan status pemutaran
  void onTimelineTick({
    required double currentGlobalPosition,
    required bool isVideoPlaying,
  }) {
    if (_tracks.isEmpty) return;

    for (final track in _tracks.values) {
      final clip = track.model;
      final controller = track.controller;
      if (!controller.value.isInitialized) continue;

      final start = clip.startTimeline;
      final end = clip.endTimeline;

      final isInRange = currentGlobalPosition >= start && currentGlobalPosition < end;

      if (isInRange && isVideoPlaying && !clip.isMuted) {
        // Audio harus berbunyi
        final targetOffset = currentGlobalPosition - start + clip.startSource;
        final currentAudioPos = controller.value.position.inMilliseconds / 1000.0;

        // Jika desinkronisasi lebih dari 80ms, sesuaikan seekTo
        if ((currentAudioPos - targetOffset).abs() > 0.12) {
          controller.seekTo(Duration(milliseconds: (targetOffset * 1000).toInt()));
        }

        if (!controller.value.isPlaying) {
          controller.play();
          track.isPlaying = true;
        }
      } else {
        // Di luar range atau video di-pause / di-mute
        if (controller.value.isPlaying) {
          controller.pause();
          track.isPlaying = false;
        }
      }
    }
  }

  /// Hentikan semua pemutaran audio
  void pauseAll() {
    for (final track in _tracks.values) {
      if (track.controller.value.isPlaying) {
        track.controller.pause();
        track.isPlaying = false;
      }
    }
  }

  /// Seek semua audio saat playhead digeser secara manual
  void seekAll(double globalPosition) {
    for (final track in _tracks.values) {
      final clip = track.model;
      final controller = track.controller;
      if (!controller.value.isInitialized) continue;

      final start = clip.startTimeline;
      final end = clip.endTimeline;

      if (globalPosition >= start && globalPosition < end) {
        final offset = globalPosition - start + clip.startSource;
        controller.seekTo(Duration(milliseconds: (offset * 1000).toInt()));
      } else {
        controller.pause();
        track.isPlaying = false;
      }
    }
  }

  /// Bersihkan resource
  void dispose() {
    _isDisposed = true;
    for (final track in _tracks.values) {
      track.controller.dispose();
    }
    _tracks.clear();
  }
}
