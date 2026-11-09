import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/clip_model.dart';
import 'package:video_clipper_app/core/models/clip_transform_model.dart';
import 'package:video_clipper_app/core/models/color_adjustment_model.dart';
import 'package:video_clipper_app/core/models/overlay_model.dart';
import 'package:video_clipper_app/core/models/timeline_model.dart';
import 'package:video_clipper_app/core/models/video_effect_model.dart';

void main() {
  group('Phase 2 — Duplicate & Replace Comprehensive Tests', () {
    late ClipModel testClip;
    late TimelineModel timeline;

    setUp(() {
      testClip = ClipModel(
        id: 'clip_original',
        sourcePath: '/path/video1.mp4',
        startSource: 1.0,
        endSource: 6.0,
        transform: const ClipTransformModel(
          rotationDegrees: 90.0,
          canvasRatio: CanvasRatioMode.ratio9x16,
          cropLeft: 0.1,
          cropRight: 0.9,
        ),
        adjustment: const ColorAdjustmentModel(
          preset: FilterPreset.tealAndOrange,
          filterIntensity: 0.8,
        ),
        effect: const VideoEffectModel(type: EffectType.letterbox),
      );

      timeline = TimelineModel(clips: [testClip]);
    });

    test('1. Duplicate After: Menaruh salinan klip tepat setelah klip asli pada track utama', () {
      final updated = timeline.duplicateClip(testClip.id);

      expect(updated.clips.length, 2);
      expect(updated.clips[0].id, 'clip_original');
      expect(updated.clips[1].id, isNot('clip_original'));
      expect(updated.clips[1].id.startsWith('clip_original_dup_'), isTrue);

      // Pastikan atribut identik tetapi merupakan instance terpisah
      expect(updated.clips[1].sourcePath, testClip.sourcePath);
      expect(updated.clips[1].startSource, testClip.startSource);
      expect(updated.clips[1].endSource, testClip.endSource);
      expect(updated.clips[1].transform.rotationDegrees, 90.0);
      expect(updated.clips[1].adjustment.preset, FilterPreset.tealAndOrange);

      // Durasi total timeline bertambah
      expect(updated.totalDuration, testClip.timelineDuration * 2);
    });

    test('2. Duplicate Multiple: Menghasilkan beberapa salinan berurutan tanpa merusak klip pertama', () {
      var t = timeline;
      for (int i = 0; i < 3; i++) {
        t = t.duplicateClip(testClip.id);
      }

      expect(t.clips.length, 4);
      expect(t.totalDuration, testClip.timelineDuration * 4);
    });

    test('3. Duplicate to Overlay: Membuat track Picture-in-Picture di atas video utama', () {
      final overlay = OverlayModel(
        id: 'overlay_pip_1',
        type: OverlayType.video,
        content: testClip.sourcePath,
        startTime: 0.0,
        endTime: testClip.timelineDuration,
        normalizedX: 0.5,
        normalizedY: 0.5,
        scale: 0.85,
      );

      final withOverlay = timeline.addOverlay(overlay);
      expect(withOverlay.overlays.length, 1);
      expect(withOverlay.overlays.first.type, OverlayType.video);
      expect(withOverlay.overlays.first.content, testClip.sourcePath);
      // Timeline klip utama tidak bertambah panjang
      expect(withOverlay.clips.length, 1);
      expect(withOverlay.totalDuration, testClip.timelineDuration);
    });

    test('4. Copy & Paste Attributes: Mentransfer filter, transform, dan efek ke klip baru', () {
      final targetClip = ClipModel(
        id: 'clip_target',
        sourcePath: '/path/video2.mp4',
        startSource: 0.0,
        endSource: 4.0,
      );

      // Paste atribut dari testClip ke targetClip
      final pastedClip = targetClip.copyWith(
        transform: testClip.transform,
        adjustment: testClip.adjustment,
        effect: testClip.effect,
      );

      expect(pastedClip.id, 'clip_target');
      expect(pastedClip.sourcePath, '/path/video2.mp4');
      // Nilai atribut yang dipaste
      expect(pastedClip.transform.rotationDegrees, 90.0);
      expect(pastedClip.transform.cropLeft, 0.1);
      expect(pastedClip.adjustment.preset, FilterPreset.tealAndOrange);
      expect(pastedClip.effect.type, EffectType.letterbox);
    });

    test('5. Replace Media: Mempertahankan pengaturan transformasi dan efek saat sumber diganti', () {
      const newSourcePath = '/gallery/replacement_video.mp4';
      const newDuration = 12.0;

      // Mode: Keep Duration (tetap durasi lama)
      final replacedKeepDuration = testClip.copyWith(
        sourcePath: newSourcePath,
        startSource: 0.0,
        endSource: testClip.sourceDuration,
      );

      expect(replacedKeepDuration.sourcePath, newSourcePath);
      expect(replacedKeepDuration.sourceDuration, testClip.sourceDuration);
      expect(replacedKeepDuration.transform.rotationDegrees, 90.0);
      expect(replacedKeepDuration.adjustment.preset, FilterPreset.tealAndOrange);

      // Mode: Fit New Duration (mengikuti durasi video pengganti baru)
      final replacedNewDuration = testClip.copyWith(
        sourcePath: newSourcePath,
        startSource: 0.0,
        endSource: newDuration,
      );

      expect(replacedNewDuration.sourcePath, newSourcePath);
      expect(replacedNewDuration.sourceDuration, newDuration);
      expect(replacedNewDuration.transform.cropLeft, 0.1);
    });

    test('6. Undo/Redo pada operasi Duplikasi dan Penggantian', () {
      final history = TimelineHistory();
      history.recordState(timeline);

      // 1. Duplikasi
      final dupTimeline = timeline.duplicateClip(testClip.id);
      expect(dupTimeline.clips.length, 2);

      // 2. Undo duplikasi
      final undone = history.undo(dupTimeline);
      expect(undone, isNotNull);
      expect(undone!.clips.length, 1);
      expect(undone.clips.first.id, 'clip_original');

      // 3. Redo duplikasi
      final redone = history.redo(undone);
      expect(redone, isNotNull);
      expect(redone!.clips.length, 2);
    });
  });
}

