import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/audio_clip_model.dart';
import 'package:video_clipper_app/core/models/clip_model.dart';
import 'package:video_clipper_app/core/models/timeline_model.dart';

void main() {
  group('AudioClipModel & Speed Control Tests', () {
    test('Perhitungan durasi klip video berdasarkan speed', () {
      final normalClip = ClipModel(
        id: 'c1',
        sourcePath: '/v.mp4',
        startSource: 0.0,
        endSource: 10.0,
        speed: 1.0,
      );
      expect(normalClip.timelineDuration, 10.0);

      // Fast motion 2.0x -> durasi menjadi 5.0s
      final fastClip = normalClip.copyWith(speed: 2.0);
      expect(fastClip.timelineDuration, 5.0);

      // Slow motion 0.5x -> durasi menjadi 20.0s
      final slowClip = normalClip.copyWith(speed: 0.5);
      expect(slowClip.timelineDuration, 20.0);
    });

    test('Validasi model AudioClipModel', () {
      const audio = AudioClipModel(
        id: 'a1',
        sourcePath: '/music.mp3',
        title: 'Background Music',
        startTimeline: 2.0,
        startSource: 0.0,
        duration: 15.0,
        volume: 0.8,
        fadeInSeconds: 1.0,
        fadeOutSeconds: 2.0,
      );

      expect(audio.endTimeline, 17.0);
      expect(audio.volume, 0.8);
      expect(audio.isMuted, isFalse);
      expect(audio.fadeInSeconds, 1.0);
      expect(audio.fadeOutSeconds, 2.0);

      final json = audio.toJson();
      final restored = AudioClipModel.fromJson(json);

      expect(restored.id, 'a1');
      expect(restored.title, 'Background Music');
      expect(restored.duration, 15.0);
      expect(restored.fadeInSeconds, 1.0);
      expect(restored.fadeOutSeconds, 2.0);
    });

    test('Manajemen audio track di TimelineModel', () {
      final clip = ClipModel(id: 'c1', sourcePath: '/v.mp4', startSource: 0, endSource: 5);
      const audio = AudioClipModel(
        id: 'a1',
        sourcePath: '/song.mp3',
        title: 'Song',
        startTimeline: 0.0,
        duration: 5.0,
      );

      var timeline = TimelineModel(clips: [clip]).addAudioClip(audio);
      expect(timeline.audioClips.length, 1);

      // Mute audio
      timeline = timeline.updateAudioClip(audio.copyWith(isMuted: true));
      expect(timeline.audioClips.first.isMuted, isTrue);

      // Hapus audio
      timeline = timeline.removeAudioClip('a1');
      expect(timeline.audioClips.isEmpty, isTrue);
    });

    test('Multi-Track Audio Mixing: Menambah 3 audio track independen', () {
      final clip = ClipModel(id: 'c1', sourcePath: '/v.mp4', startSource: 0, endSource: 30);
      const audio1 = AudioClipModel(
        id: 'a1',
        sourcePath: '/music1.mp3',
        title: 'Intro Music',
        startTimeline: 0.0,
        duration: 10.0,
        volume: 0.8,
      );
      const audio2 = AudioClipModel(
        id: 'a2',
        sourcePath: '/music2.mp3',
        title: 'Body SFX',
        startTimeline: 10.0,
        duration: 12.0,
        volume: 1.0,
      );
      const audio3 = AudioClipModel(
        id: 'a3',
        sourcePath: '/music3.mp3',
        title: 'Outro Music',
        startTimeline: 22.0,
        duration: 8.0,
        volume: 0.6,
      );

      var timeline = TimelineModel(clips: [clip])
          .addAudioClip(audio1)
          .addAudioClip(audio2)
          .addAudioClip(audio3);

      expect(timeline.audioClips.length, 3);
      expect(timeline.audioClips[0].startTimeline, 0.0);
      expect(timeline.audioClips[1].startTimeline, 10.0);
      expect(timeline.audioClips[2].startTimeline, 22.0);
      expect(timeline.audioClips[2].endTimeline, 30.0);
    });
  });
}
