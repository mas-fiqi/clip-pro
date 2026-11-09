import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/audio_clip_model.dart';
import 'package:video_clipper_app/core/models/clip_model.dart';
import 'package:video_clipper_app/core/models/rhythm_model.dart';
import 'package:video_clipper_app/core/models/speed_config_model.dart';

void main() {
  group('SpeedConfigModel & Speed Curve Tests', () {
    test('Default SpeedConfigModel is 1.0x normal speed', () {
      const config = SpeedConfigModel();
      expect(config.normalSpeed, equals(1.0));
      expect(config.isCurveMode, isFalse);
      expect(config.effectiveSpeed, equals(1.0));
      expect(config.keepPitch, isTrue);
    });

    test('Montage template produces dynamic curve evaluation', () {
      final montage = SpeedConfigModel.getTemplate('montage');
      expect(montage.isCurveMode, isTrue);
      expect(montage.curveTemplateId, equals('montage'));
      expect(montage.curvePoints.length, greaterThanOrEqualTo(4));

      // Fast at start, slower in middle
      final speedStart = montage.evaluateSpeedAt(0.0);
      final speedMid = montage.evaluateSpeedAt(0.25);
      expect(speedStart, greaterThan(2.0));
      expect(speedMid, lessThan(1.0));

      // Effective average speed calculation
      expect(montage.effectiveSpeed, greaterThan(0.5));
    });

    test('Hero and Bullet templates load correct points', () {
      final hero = SpeedConfigModel.getTemplate('hero');
      expect(hero.curvePoints.isNotEmpty, isTrue);

      final bullet = SpeedConfigModel.getTemplate('bullet');
      expect(bullet.curvePoints.isNotEmpty, isTrue);
    });

    test('ClipModel integrates SpeedConfigModel and calculates timelineDuration correctly', () {
      final clip = ClipModel(
        id: 'c_speed',
        sourcePath: '/path/test.mp4',
        startSource: 0.0,
        endSource: 10.0,
        speed: 2.0,
        speedConfig: const SpeedConfigModel(normalSpeed: 2.0),
      );

      expect(clip.sourceDuration, equals(10.0));
      expect(clip.timelineDuration, equals(5.0));

      final json = clip.toJson();
      final restored = ClipModel.fromJson(json);
      expect(restored.speedConfig.normalSpeed, equals(2.0));
    });
  });

  group('RhythmModel & Beat Detection Tests', () {
    test('generateBeatsFromBpm generates correct beat intervals', () {
      // 120 BPM = 2 beats per second = interval 0.5s
      final beats = RhythmModel.generateBeatsFromBpm(
        bpm: 120.0,
        durationSeconds: 4.0,
        sensitivity: BeatSensitivity.medium,
      );

      expect(beats.length, greaterThanOrEqualTo(8));
      expect(beats.first.timestampSeconds, equals(0.0));
      expect(beats[1].timestampSeconds, closeTo(0.5, 0.01));
      expect(beats.first.isStrongBeat, isTrue);
    });

    test('AudioClipModel stores RhythmModel and serializes JSON', () {
      final audio = AudioClipModel(
        id: 'a1',
        sourcePath: '/path/audio.mp3',
        title: 'Song Beat',
        startTimeline: 0.0,
        duration: 30.0,
        rhythm: const RhythmModel(
          estimatedBpm: 128.0,
          sensitivity: BeatSensitivity.high,
          isSnapEnabled: true,
        ),
      );

      final json = audio.toJson();
      final restored = AudioClipModel.fromJson(json);

      expect(restored.rhythm.estimatedBpm, equals(128.0));
      expect(restored.rhythm.sensitivity, equals(BeatSensitivity.high));
      expect(restored.rhythm.isSnapEnabled, isTrue);
    });
  });
}

