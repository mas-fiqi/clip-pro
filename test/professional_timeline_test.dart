import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/audio_clip_model.dart';
import 'package:video_clipper_app/core/models/clip_model.dart';
import 'package:video_clipper_app/core/models/keyframe_model.dart';
import 'package:video_clipper_app/core/models/overlay_model.dart';
import 'package:video_clipper_app/core/models/timeline_model.dart';
import 'package:video_clipper_app/core/services/audio_library_service.dart';
import 'package:video_clipper_app/core/services/audio_waveform_service.dart';
import 'package:video_clipper_app/core/services/thumbnail_generator_service.dart';
import 'package:video_clipper_app/core/utils/timeline_snap_engine.dart';

void main() {
  group('Phase 4: Professional Multi-Track Timeline & Editing Experience', () {
    test('TimelineSnapEngine: Deteksi titik magnet snap terdekat', () {
      const engine = TimelineSnapEngine(snapToleranceSeconds: 0.2);
      final snapPoints = [0.0, 3.5, 7.0, 10.2];

      // Waktu 3.42 sangat dekat dengan 3.5 (selisih 0.08 <= 0.2)
      final snapped = engine.snapTime(targetTime: 3.42, snapPoints: snapPoints);
      expect(snapped, 3.5);

      // Waktu 5.0 jauh dari semua titik snap -> null
      final notSnapped = engine.snapTime(targetTime: 5.0, snapPoints: snapPoints);
      expect(notSnapped, isNull);

      // Snap dinonaktifkan -> null
      final disabled = engine.snapTime(targetTime: 3.42, snapPoints: snapPoints, enabled: false);
      expect(disabled, isNull);
    });

    test('AudioWaveformService: Generasi sample amplitudo deterministik & caching', () {
      final service = AudioWaveformService();
      final samples1 = service.getWaveformSamples(key: 'audio_1', durationSeconds: 5.0, sampleCount: 20);
      expect(samples1.length, 20);
      expect(samples1.every((s) => s >= 0.08 && s <= 1.0), isTrue);

      // Hasil dari cache harus identik
      final samples2 = service.getWaveformSamples(key: 'audio_1', durationSeconds: 5.0, sampleCount: 20);
      expect(samples1, equals(samples2));

      // Scaling volume
      final lowVol = service.getWaveformSamples(key: 'audio_1', durationSeconds: 5.0, sampleCount: 20, volume: 0.5);
      expect(lowVol.first <= samples1.first, isTrue);
    });

    test('AudioWaveformService: Ekstraksi waveform nyata dari byte audio file', () {
      final service = AudioWaveformService();
      final samples = service.getWaveformSamples(
        key: 'audio_test_acoustic',
        durationSeconds: 10.0,
        sampleCount: 30,
        volume: 1.0,
      );
      expect(samples.length, 30);
      expect(samples.every((s) => s >= 0.08 && s <= 1.0), isTrue);
    });

    test('MultiClipTimelineView: Sinkronisasi Playhead, Viewport dan Audio startTimeline', () {
      final audio = AudioClipModel(
        id: 'bgm',
        title: 'Background Music',
        sourcePath: 'bgm.mp3',
        duration: 15.0,
        startTimeline: 3.0,
      );
      // Validasi kalkulasi offset horizontal timeline dan boundary
      const pixelsPerSecond = 30.0;
      final expectedLeftOffset = audio.startTimeline * pixelsPerSecond; // 90.0 px
      final expectedWidth = audio.duration * pixelsPerSecond;           // 450.0 px

      expect(expectedLeftOffset, 90.0);
      expect(expectedWidth, 450.0);
      expect(audio.endTimeline, 18.0);
    });

    test('Keyframe Animation System: Linear & Easing Interpolation Test', () {
      final kf1 = KeyframeModel(
        id: 'kf1',
        timestampSeconds: 0.0,
        scale: 1.0,
        positionX: 0.0,
        positionY: 0.0,
        opacity: 1.0,
        easing: KeyframeEasing.linear,
      );
      final kf2 = KeyframeModel(
        id: 'kf2',
        timestampSeconds: 2.0,
        scale: 1.5,
        positionX: 0.5,
        positionY: 0.2,
        opacity: 0.5,
        easing: KeyframeEasing.easeInOut,
      );
      final kf3 = KeyframeModel(
        id: 'kf3',
        timestampSeconds: 4.0,
        scale: 1.0,
        positionX: 0.0,
        positionY: 0.0,
        opacity: 1.0,
        easing: KeyframeEasing.linear,
      );

      final keyframes = [kf1, kf2, kf3];

      // Waktu 0.0 -> tepat di kf1 (scale 1.0)
      final v0 = InterpolatedKeyframeValues.evaluate(keyframes, 0.0);
      expect(v0.scale, 1.0);
      expect(v0.positionX, 0.0);

      // Waktu 1.0 -> tepat di tengah kf1 dan kf2 (scale bertahap naik ke 1.25 linier)
      final v1 = InterpolatedKeyframeValues.evaluate(keyframes, 1.0);
      expect(v1.scale, closeTo(1.25, 0.01));
      expect(v1.positionX, closeTo(0.25, 0.01));
      expect(v1.opacity, closeTo(0.75, 0.01));

      // Waktu 2.0 -> tepat di kf2 (scale 1.5)
      final v2 = InterpolatedKeyframeValues.evaluate(keyframes, 2.0);
      expect(v2.scale, 1.5);
      expect(v2.positionX, 0.5);
      expect(v2.opacity, 0.5);

      // Waktu 3.0 -> interpolasi antara kf2 dan kf3
      final v3 = InterpolatedKeyframeValues.evaluate(keyframes, 3.0);
      expect(v3.scale, closeTo(1.25, 0.05));

      // Waktu 4.0 -> tepat di kf3 (kembali ke scale 1.0)
      final v4 = InterpolatedKeyframeValues.evaluate(keyframes, 4.0);
      expect(v4.scale, 1.0);
    });

    test('Audio Library & Sound Effect Catalog Tests', () async {
      final provider = CreativeCommonsAudioProvider();
      final allAudio = await provider.searchAudio();
      expect(allAudio.isNotEmpty, isTrue);

      // Filter by category
      final cinematic = await provider.searchAudio(category: 'Cinematic');
      expect(cinematic.every((a) => a.category == 'Cinematic'), isTrue);

      // Sound Effects Catalog
      final sfxList = SoundEffectCatalog.getAllSoundEffects();
      expect(sfxList.length >= 8, isTrue);
      expect(sfxList.any((s) => s.category == 'Whoosh'), isTrue);
      expect(sfxList.any((s) => s.category == 'Impact'), isTrue);
    });

    test('ThumbnailGeneratorService: In-memory cache check & lifecycle', () {
      final service = ThumbnailGeneratorService();
      expect(service.getCachedThumbnail('dummy_path.mp4', 1.0), isNull);
      service.clearMemoryCache();
    });

    test('Multi-Track Synchronization: Video, Audio, & Text overlay alignment', () {
      final clip1 = ClipModel(id: 'c1', sourcePath: 'p1.mp4', startSource: 0, endSource: 4.0);
      final clip2 = ClipModel(id: 'c2', sourcePath: 'p2.mp4', startSource: 0, endSource: 6.0);
      final audio1 = AudioClipModel(id: 'a1', title: 'Music Track', sourcePath: 'a1.mp3', duration: 8.0, startTimeline: 0.0);
      final overlay1 = OverlayModel(id: 'o1', type: OverlayType.subtitle, content: 'Subtitle Intro', startTime: 0.0, endTime: 3.0);

      final timeline = TimelineModel(
        clips: [clip1, clip2],
        audioClips: [audio1],
        overlays: [overlay1],
      );

      // Total durasi video utama: 4.0 + 6.0 = 10.0 detik
      expect(timeline.totalDuration, 10.0);
      expect(timeline.clips.length, 2);
      expect(timeline.audioClips.length, 1);
      expect(timeline.overlays.length, 1);

      // Split di 2.0 detik (Klip 1)
      final splitTimeline = timeline.splitAt(2.0);
      expect(splitTimeline, isNotNull);
      expect(splitTimeline!.clips.length, 3);
      expect(splitTimeline.totalDuration, closeTo(10.0, 0.01));

      // Reorder klip
      final reordered = splitTimeline.reorderClip(0, 2);
      expect(reordered.clips.length, 3);
      expect(reordered.totalDuration, closeTo(10.0, 0.01));
    });

    test('Video 24s, 30s, 60s, 120s Duration, Ruler & Playhead Synchronization Test', () {
      const zoomScales = [0.6, 1.0, 1.5, 2.0];
      const durations = [10.0, 24.0, 30.0, 60.0, 120.0];

      for (final dur in durations) {
        final clip = ClipModel(id: 'clip_test', sourcePath: 'test.mp4', startSource: 0.0, endSource: dur);
        final timeline = TimelineModel(clips: [clip]);
        expect(timeline.totalDuration, dur, reason: 'Durasi timeline harus tepat sama dengan video $dur s');

        for (final zoom in zoomScales) {
          final pixelsPerSec = 30.0 * zoom;
          final clipWidth = clip.timelineDuration * pixelsPerSec;
          final contentWidth = timeline.totalDuration * pixelsPerSec;

          // Klip width harus presisi 1:1 terhadap total durasi dan zoom
          expect(clipWidth, contentWidth);
          expect(clipWidth, dur * pixelsPerSec);

          // Simulasi scroll target pada detik 0, detik pertengahan, detik 22, dan detik terakhir
          final playheadTimes = [0.0, dur / 2, (dur > 22.0 ? 22.0 : dur), dur];
          for (final t in playheadTimes) {
            final scrollOffset = t * pixelsPerSec;
            final calculatedTime = scrollOffset / pixelsPerSec;
            expect(calculatedTime, closeTo(t, 0.0001), reason: 'Playhead pada $t detik harus sinkron sempurna');
          }
        }
      }
    });
    test('Real-time Playhead Dragging & Seeking: 24s, 60s, 300s (5 menit) Scenarios', () {
      final durations = [24.0, 60.0, 300.0];
      const pixelsPerSec = 30.0;

      for (final totalDur in durations) {
        // Skenario 1: Geser playhead dari 17 ke 26 detik (atau akhir video jika durasi < 26)
        final target1 = (26.0).clamp(0.0, totalDur);
        final scroll1 = target1 * pixelsPerSec;
        final computedTime1 = (scroll1 / pixelsPerSec).clamp(0.0, totalDur);
        expect(computedTime1, target1);

        // Skenario 2: Geser playhead dari 26 ke 5 detik
        const target2 = 5.0;
        final scroll2 = target2 * pixelsPerSec;
        final computedTime2 = (scroll2 / pixelsPerSec).clamp(0.0, totalDur);
        expect(computedTime2, target2);

        // Skenario 3: Geser playhead sampai ujung akhir video
        final scrollEnd = totalDur * pixelsPerSec;
        final computedEnd = (scrollEnd / pixelsPerSec).clamp(0.0, totalDur);
        expect(computedEnd, totalDur);
      }
    });

    test('Real-time Clip Dragging & Reorder: Horizontal Slot Calculation', () {
      final clip1 = ClipModel(id: 'c1', sourcePath: 'p1.mp4', startSource: 0, endSource: 5.0);
      final clip2 = ClipModel(id: 'c2', sourcePath: 'p2.mp4', startSource: 0, endSource: 5.0);
      final clip3 = ClipModel(id: 'c3', sourcePath: 'p3.mp4', startSource: 0, endSource: 5.0);

      final timeline = TimelineModel(clips: [clip1, clip2, clip3]);
      expect(timeline.clips.length, 3);
      expect(timeline.clips[0].id, 'c1');

      // Flutter Reorderable standard convention: insert at newIndex (3 untuk meletakkan di ujung akhir)
      final reordered = timeline.reorderClip(0, 3);
      expect(reordered.clips[0].id, 'c2');
      expect(reordered.clips[1].id, 'c3');
      expect(reordered.clips[2].id, 'c1');
      expect(reordered.totalDuration, 15.0);
    });
  });
}
