import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/clip_model.dart';
import 'package:video_clipper_app/core/models/timeline_model.dart';

void main() {
  group('TimelineModel Split, Duplicate, & Undo/Redo Tests', () {
    test('Split clip pada posisi aman', () {
      final clip = ClipModel(
        id: 'c1',
        sourcePath: '/video.mp4',
        startSource: 0.0,
        endSource: 10.0,
      );
      final timeline = TimelineModel(clips: [clip]);
      expect(timeline.totalDuration, 10.0);

      // Split di detik ke-4.0
      final splitTimeline = timeline.splitAt(4.0, minDuration: 0.5);
      expect(splitTimeline, isNotNull);
      expect(splitTimeline!.clips.length, 2);

      final clip1 = splitTimeline.clips[0];
      final clip2 = splitTimeline.clips[1];

      expect(clip1.startSource, 0.0);
      expect(clip1.endSource, 4.0);
      expect(clip1.timelineDuration, 4.0);

      expect(clip2.startSource, 4.0);
      expect(clip2.endSource, 10.0);
      expect(clip2.timelineDuration, 6.0);

      expect(splitTimeline.totalDuration, 10.0);
    });

    test('Split clip ditolak jika terlalu dekat ke ujung (minDuration)', () {
      final clip = ClipModel(
        id: 'c1',
        sourcePath: '/video.mp4',
        startSource: 0.0,
        endSource: 10.0,
      );
      final timeline = TimelineModel(clips: [clip]);

      // Split di 0.2 detik (di bawah minDuration 0.5)
      final tooCloseStart = timeline.splitAt(0.2, minDuration: 0.5);
      expect(tooCloseStart, isNull);

      // Split di 9.8 detik (di bawah minDuration 0.5)
      final tooCloseEnd = timeline.splitAt(9.8, minDuration: 0.5);
      expect(tooCloseEnd, isNull);
    });

    test('Duplikasi klip berhasil dan durasi bertambah', () {
      final clip = ClipModel(
        id: 'c1',
        sourcePath: '/video.mp4',
        startSource: 0.0,
        endSource: 5.0,
      );
      final timeline = TimelineModel(clips: [clip]);
      final duplicated = timeline.duplicateClip('c1');

      expect(duplicated.clips.length, 2);
      expect(duplicated.clips[0].id, 'c1');
      expect(duplicated.clips[1].id.startsWith('c1_dup'), isTrue);
      expect(duplicated.totalDuration, 10.0);
    });

    test('Undo dan Redo TimelineHistory', () {
      final history = TimelineHistory();
      final clip1 = ClipModel(id: 'c1', sourcePath: '/v.mp4', startSource: 0, endSource: 5);
      final initialTimeline = TimelineModel(clips: [clip1]);

      // Rekam sebelum aksi
      history.recordState(initialTimeline);
      final splitTimeline = initialTimeline.splitAt(2.5)!;
      expect(splitTimeline.clips.length, 2);

      // Undo
      final undone = history.undo(splitTimeline);
      expect(undone, isNotNull);
      expect(undone!.clips.length, 1);
      expect(undone.totalDuration, 5.0);

      // Redo
      final redone = history.redo(undone);
      expect(redone, isNotNull);
      expect(redone!.clips.length, 2);
    });

    test('Delete Left: Menghapus bagian klip di sebelah kiri playhead', () {
      final clip = ClipModel(id: 'c1', sourcePath: '/v.mp4', startSource: 0.0, endSource: 10.0);
      final timeline = TimelineModel(clips: [clip]);

      // Hapus sebelah kiri playhead pada detik 3.0
      final updated = timeline.deleteLeftAt(3.0);
      expect(updated, isNotNull);
      expect(updated!.clips.length, 1);
      expect(updated.clips.first.startSource, 3.0);
      expect(updated.clips.first.endSource, 10.0);
      expect(updated.totalDuration, 7.0);
    });

    test('Delete Right: Menghapus bagian klip di sebelah kanan playhead', () {
      final clip = ClipModel(id: 'c1', sourcePath: '/v.mp4', startSource: 0.0, endSource: 10.0);
      final timeline = TimelineModel(clips: [clip]);

      // Hapus sebelah kanan playhead pada detik 4.0
      final updated = timeline.deleteRightAt(4.0);
      expect(updated, isNotNull);
      expect(updated!.clips.length, 1);
      expect(updated.clips.first.startSource, 0.0);
      expect(updated.clips.first.endSource, 4.0);
      expect(updated.totalDuration, 4.0);
    });

    test('Trim Clip: Mengubah handle start & end source dengan aman', () {
      final clip = ClipModel(id: 'c1', sourcePath: '/v.mp4', startSource: 0.0, endSource: 10.0);
      final timeline = TimelineModel(clips: [clip]);

      final trimmed = timeline.trimClip('c1', 2.0, 8.0);
      expect(trimmed.clips.first.startSource, 2.0);
      expect(trimmed.clips.first.endSource, 8.0);
      expect(trimmed.totalDuration, 6.0);
    });
  });
}

