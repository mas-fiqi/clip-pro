import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/clip_model.dart';
import 'package:video_clipper_app/core/models/timeline_model.dart';
import 'package:video_clipper_app/core/models/project_model.dart';
import 'package:video_clipper_app/core/utils/time_formatter.dart';

void main() {
  group('ClipModel Unit Tests', () {
    test('Validasi kalkulasi durasi klip normal dan speed', () {
      final clip = ClipModel(
        id: 'clip_1',
        sourcePath: '/path/video.mp4',
        startSource: 2.0,
        endSource: 10.0,
        speed: 2.0,
      );

      expect(clip.sourceDuration, 8.0);
      expect(clip.timelineDuration, 4.0); // 8.0 / 2.0 = 4.0
    });

    test('Validasi assertion waktu negatif atau end <= start', () {
      expect(
        () => ClipModel(
          id: 'clip_err',
          sourcePath: '/path/video.mp4',
          startSource: 10.0,
          endSource: 5.0,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => ClipModel(
          id: 'clip_err2',
          sourcePath: '/path/video.mp4',
          startSource: -1.0,
          endSource: 5.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('Validasi copyWith dan serialisasi JSON', () {
      final clip = ClipModel(
        id: 'c1',
        sourcePath: '/test.mp4',
        startSource: 0.0,
        endSource: 5.0,
      );
      final copied = clip.copyWith(endSource: 8.0, speed: 0.5);

      expect(copied.sourceDuration, 8.0);
      expect(copied.timelineDuration, 16.0);

      final json = copied.toJson();
      final fromJson = ClipModel.fromJson(json);
      expect(fromJson.id, 'c1');
      expect(fromJson.sourceDuration, 8.0);
    });
  });

  group('TimelineModel Unit Tests', () {
    test('Kalkulasi total durasi timeline multi-clip', () {
      final clip1 = ClipModel(
        id: 'c1',
        sourcePath: '/v1.mp4',
        startSource: 0.0,
        endSource: 5.0,
      );
      final clip2 = ClipModel(
        id: 'c2',
        sourcePath: '/v2.mp4',
        startSource: 1.0,
        endSource: 6.0,
        speed: 2.0, // 5 / 2 = 2.5
      );

      var timeline = TimelineModel().addClip(clip1).addClip(clip2);
      expect(timeline.clips.length, 2);
      expect(timeline.totalDuration, 7.5); // 5.0 + 2.5 = 7.5

      timeline = timeline.removeClip('c1');
      expect(timeline.clips.length, 1);
      expect(timeline.totalDuration, 2.5);
    });

    test('Reorder klip dalam timeline', () {
      final clip1 = ClipModel(id: 'c1', sourcePath: '/v1.mp4', startSource: 0, endSource: 2);
      final clip2 = ClipModel(id: 'c2', sourcePath: '/v2.mp4', startSource: 0, endSource: 3);
      final clip3 = ClipModel(id: 'c3', sourcePath: '/v3.mp4', startSource: 0, endSource: 4);

      var timeline = TimelineModel(clips: [clip1, clip2, clip3]);
      expect(timeline.clips.map((c) => c.id).toList(), ['c1', 'c2', 'c3']);

      // Pindahkan c3 ke awal
      timeline = timeline.reorderClip(2, 0);
      expect(timeline.clips.map((c) => c.id).toList(), ['c3', 'c1', 'c2']);
    });
  });

  group('ProjectModel Unit Tests', () {
    test('Serialisasi ProjectModel', () {
      final clip = ClipModel(id: 'c1', sourcePath: '/v.mp4', startSource: 0, endSource: 10);
      final project = ProjectModel(
        id: 'proj_1',
        name: 'Video TikTok',
        aspectRatio: CanvasAspectRatio.ratio9x16,
        timeline: TimelineModel(clips: [clip]),
      );

      final json = project.toJson();
      final restored = ProjectModel.fromJson(json);

      expect(restored.id, 'proj_1');
      expect(restored.name, 'Video TikTok');
      expect(restored.aspectRatio, CanvasAspectRatio.ratio9x16);
      expect(restored.timeline.clips.length, 1);
      expect(restored.timeline.totalDuration, 10.0);
    });
  });

  group('TimeFormatter Unit Tests', () {
    test('Format timestamp FFmpeg yang akurat', () {
      expect(TimeFormatter.toFFmpegTimestamp(65.5), '00:01:05.500');
      expect(TimeFormatter.toFFmpegTimestamp(3661.123), '01:01:01.123');
    });

    test('Format display duration', () {
      expect(TimeFormatter.formatSeconds(125), '02:05');
      expect(TimeFormatter.formatSeconds(3725), '1:02:05');
    });
  });
}

