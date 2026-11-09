import 'audio_clip_model.dart';
import 'clip_model.dart';
import 'overlay_model.dart';

/// Riwayat snapshot state timeline untuk fitur Undo & Redo
class TimelineHistory {
  final List<TimelineModel> _undoStack = [];
  final List<TimelineModel> _redoStack = [];
  final int maxHistory;

  TimelineHistory({this.maxHistory = 20});

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void recordState(TimelineModel current) {
    _undoStack.add(current);
    if (_undoStack.length > maxHistory) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }

  TimelineModel? undo(TimelineModel current) {
    if (!canUndo) return null;
    _redoStack.add(current);
    return _undoStack.removeLast();
  }

  TimelineModel? redo(TimelineModel current) {
    if (!canRedo) return null;
    _undoStack.add(current);
    return _redoStack.removeLast();
  }

  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }
}

/// Representasi urutan track video, audio track, dan multi-layer overlay
class TimelineModel {
  final List<ClipModel> clips;
  final List<OverlayModel> overlays;
  final List<AudioClipModel> audioClips;

  TimelineModel({
    List<ClipModel>? clips,
    List<OverlayModel>? overlays,
    List<AudioClipModel>? audioClips,
  })  : clips = List.unmodifiable(clips ?? []),
        overlays = List.unmodifiable(overlays ?? []),
        audioClips = List.unmodifiable(audioClips ?? []);

  /// Total durasi timeline (dalam detik)
  double get totalDuration {
    return clips.fold(0.0, (acc, clip) => acc + clip.timelineDuration);
  }

  // --- Operasi Klip Video ---

  TimelineModel addClip(ClipModel clip) {
    final updated = List<ClipModel>.from(clips)..add(clip);
    return TimelineModel(clips: updated, overlays: overlays, audioClips: audioClips);
  }

  TimelineModel removeClip(String clipId) {
    final updated = clips.where((c) => c.id != clipId).toList();
    return TimelineModel(clips: updated, overlays: overlays, audioClips: audioClips);
  }

  TimelineModel updateClip(ClipModel updatedClip) {
    final updated = clips.map((c) => c.id == updatedClip.id ? updatedClip : c).toList();
    return TimelineModel(clips: updated, overlays: overlays, audioClips: audioClips);
  }

  TimelineModel reorderClip(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= clips.length) return this;
    if (newIndex < 0 || newIndex > clips.length) return this;

    final updated = List<ClipModel>.from(clips);
    var targetIndex = newIndex;
    if (oldIndex < targetIndex) {
      targetIndex -= 1;
    }
    final item = updated.removeAt(oldIndex);
    updated.insert(targetIndex, item);
    return TimelineModel(clips: updated, overlays: overlays, audioClips: audioClips);
  }

  TimelineModel duplicateClip(String clipId) {
    final index = clips.indexWhere((c) => c.id == clipId);
    if (index == -1) return this;

    final original = clips[index];
    final duplicated = original.copyWith(
      id: '${original.id}_dup_${DateTime.now().millisecondsSinceEpoch}',
    );

    final updated = List<ClipModel>.from(clips)..insert(index + 1, duplicated);
    return TimelineModel(clips: updated, overlays: overlays, audioClips: audioClips);
  }

  TimelineModel? splitAt(double globalTime, {double minDuration = 0.1}) {
    if (globalTime <= 0 || globalTime >= totalDuration) return null;

    double accumulated = 0.0;
    for (int i = 0; i < clips.length; i++) {
      final clip = clips[i];
      final clipStart = accumulated;
      final clipEnd = accumulated + clip.timelineDuration;

      if (globalTime > clipStart && globalTime < clipEnd) {
        final offsetFromClipStart = globalTime - clipStart;
        final sourceOffset = offsetFromClipStart * clip.speed;
        final splitSourceTime = clip.startSource + sourceOffset;

        if (offsetFromClipStart < minDuration || (clipEnd - globalTime) < minDuration) {
          return null;
        }

        final leftClip = clip.copyWith(
          id: '${clip.id}_part1_${DateTime.now().millisecondsSinceEpoch}',
          endSource: splitSourceTime,
        );

        final rightClip = clip.copyWith(
          id: '${clip.id}_part2_${DateTime.now().millisecondsSinceEpoch + 1}',
          startSource: splitSourceTime,
        );

        final updated = List<ClipModel>.from(clips)
          ..removeAt(i)
          ..insert(i, leftClip)
          ..insert(i + 1, rightClip);

        return TimelineModel(clips: updated, overlays: overlays, audioClips: audioClips);
      }

      accumulated += clip.timelineDuration;
    }

    return null;
  }

  /// Delete Left: Memotong pada globalTime dan menghapus bagian klip di sebelah kiri
  TimelineModel? deleteLeftAt(double globalTime, {double minDuration = 0.1}) {
    if (globalTime <= 0 || globalTime >= totalDuration) return null;

    double accumulated = 0.0;
    for (int i = 0; i < clips.length; i++) {
      final clip = clips[i];
      final clipStart = accumulated;
      final clipEnd = accumulated + clip.timelineDuration;

      if (globalTime > clipStart && globalTime < clipEnd) {
        final offsetFromClipStart = globalTime - clipStart;
        final sourceOffset = offsetFromClipStart * clip.speed;
        final splitSourceTime = clip.startSource + sourceOffset;

        if ((clipEnd - globalTime) < minDuration) {
          return null;
        }

        final remainingRightClip = clip.copyWith(
          id: '${clip.id}_delLeft_${DateTime.now().millisecondsSinceEpoch}',
          startSource: splitSourceTime,
        );

        final updated = List<ClipModel>.from(clips)
          ..removeAt(i)
          ..insert(i, remainingRightClip);

        return TimelineModel(clips: updated, overlays: overlays, audioClips: audioClips);
      }

      accumulated += clip.timelineDuration;
    }
    return null;
  }

  /// Delete Right: Memotong pada globalTime dan menghapus bagian klip di sebelah kanan
  TimelineModel? deleteRightAt(double globalTime, {double minDuration = 0.1}) {
    if (globalTime <= 0 || globalTime >= totalDuration) return null;

    double accumulated = 0.0;
    for (int i = 0; i < clips.length; i++) {
      final clip = clips[i];
      final clipStart = accumulated;
      final clipEnd = accumulated + clip.timelineDuration;

      if (globalTime > clipStart && globalTime < clipEnd) {
        final offsetFromClipStart = globalTime - clipStart;
        final sourceOffset = offsetFromClipStart * clip.speed;
        final splitSourceTime = clip.startSource + sourceOffset;

        if (offsetFromClipStart < minDuration) {
          return null;
        }

        final remainingLeftClip = clip.copyWith(
          id: '${clip.id}_delRight_${DateTime.now().millisecondsSinceEpoch}',
          endSource: splitSourceTime,
        );

        final updated = List<ClipModel>.from(clips)
          ..removeAt(i)
          ..insert(i, remainingLeftClip);

        return TimelineModel(clips: updated, overlays: overlays, audioClips: audioClips);
      }

      accumulated += clip.timelineDuration;
    }
    return null;
  }

  /// Trim klip dengan validasi batas rentang durasi
  TimelineModel trimClip(String clipId, double newStartSource, double newEndSource, {double minDuration = 0.2}) {
    final index = clips.indexWhere((c) => c.id == clipId);
    if (index == -1) return this;

    final original = clips[index];
    if (newEndSource - newStartSource < minDuration) return this;
    if (newStartSource < 0) return this;

    final trimmed = original.copyWith(
      startSource: newStartSource,
      endSource: newEndSource,
    );

    final updated = List<ClipModel>.from(clips)..[index] = trimmed;
    return TimelineModel(clips: updated, overlays: overlays, audioClips: audioClips);
  }

  // --- Operasi Overlay ---

  TimelineModel addOverlay(OverlayModel overlay) {
    final updated = List<OverlayModel>.from(overlays)..add(overlay);
    return TimelineModel(clips: clips, overlays: updated, audioClips: audioClips);
  }

  TimelineModel removeOverlay(String overlayId) {
    final updated = overlays.where((o) => o.id != overlayId).toList();
    return TimelineModel(clips: clips, overlays: updated, audioClips: audioClips);
  }

  TimelineModel updateOverlay(OverlayModel updatedOverlay) {
    final updated = overlays.map((o) => o.id == updatedOverlay.id ? updatedOverlay : o).toList();
    return TimelineModel(clips: clips, overlays: updated, audioClips: audioClips);
  }

  // --- Operasi Audio Tracks (Fase 6) ---

  TimelineModel addAudioClip(AudioClipModel audioClip) {
    final updated = List<AudioClipModel>.from(audioClips)..add(audioClip);
    return TimelineModel(clips: clips, overlays: overlays, audioClips: updated);
  }

  TimelineModel removeAudioClip(String audioClipId) {
    final updated = audioClips.where((a) => a.id != audioClipId).toList();
    return TimelineModel(clips: clips, overlays: overlays, audioClips: updated);
  }

  TimelineModel updateAudioClip(AudioClipModel updatedAudioClip) {
    final updated = audioClips.map((a) => a.id == updatedAudioClip.id ? updatedAudioClip : a).toList();
    return TimelineModel(clips: clips, overlays: overlays, audioClips: updated);
  }

  Map<String, dynamic> toJson() {
    return {
      'clips': clips.map((c) => c.toJson()).toList(),
      'overlays': overlays.map((o) => o.toJson()).toList(),
      'audioClips': audioClips.map((a) => a.toJson()).toList(),
    };
  }

  factory TimelineModel.fromJson(Map<String, dynamic> json) {
    final clipList = (json['clips'] as List<dynamic>?)
            ?.map((e) => ClipModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final overlayList = (json['overlays'] as List<dynamic>?)
            ?.map((e) => OverlayModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final audioList = (json['audioClips'] as List<dynamic>?)
            ?.map((e) => AudioClipModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return TimelineModel(clips: clipList, overlays: overlayList, audioClips: audioList);
  }
}
