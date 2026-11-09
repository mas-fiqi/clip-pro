import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/audio_effect_model.dart';
import 'package:video_clipper_app/core/models/clip_model.dart';

void main() {
  group('AudioEffectModel & Voice Enhancement Tests', () {
    test('Default AudioEffectModel has no active effects', () {
      const model = AudioEffectModel();
      expect(model.hasActiveEffects, isFalse);
      expect(model.voiceEffect, equals(VoiceEffectType.none));
      expect(model.noiseReduction, isFalse);
      expect(model.volume, equals(1.0));
      expect(model.pitch, equals(1.0));
      expect(model.speed, equals(1.0));
      expect(model.bass, equals(0.0));
      expect(model.treble, equals(0.0));
      expect(model.eqPreset, equals(EqualizerPreset.normal));
    });

    test('Voice Effects produce corresponding FFmpeg filters', () {
      // Robot
      const robot = AudioEffectModel(voiceEffect: VoiceEffectType.robot);
      expect(robot.buildFFmpegAudioFilters(), contains('flanger'));

      // Deep Voice
      const deep = AudioEffectModel(voiceEffect: VoiceEffectType.deepVoice);
      expect(deep.buildFFmpegAudioFilters(), contains('asetrate=44100*0.75'));

      // Chipmunk
      const chipmunk = AudioEffectModel(voiceEffect: VoiceEffectType.chipmunk);
      expect(chipmunk.buildFFmpegAudioFilters(), contains('asetrate=44100*1.4'));

      // Echo & Reverb
      const echo = AudioEffectModel(voiceEffect: VoiceEffectType.echo);
      expect(echo.buildFFmpegAudioFilters(), contains('aecho=0.8:0.88:400:0.4'));

      // Reverse
      const reverse = AudioEffectModel(voiceEffect: VoiceEffectType.reverse);
      expect(reverse.buildFFmpegAudioFilters(), contains('areverse'));

      // Telephone & Radio
      const telephone = AudioEffectModel(voiceEffect: VoiceEffectType.telephone);
      expect(telephone.buildFFmpegAudioFilters(), contains('highpass=f=300,lowpass=f=3400'));
    });

    test('Voice Enhancement filters verification', () {
      const enhanced = AudioEffectModel(
        noiseReduction: true,
        noiseReductionAmount: 0.8,
        voiceClarity: true,
        deEcho: true,
        audioNormalization: true,
        compressor: true,
        limiter: true,
      );

      final filterChain = enhanced.buildFFmpegAudioFilters();
      expect(filterChain, contains('afftdn'));
      expect(filterChain, contains('equalizer=f=3000'));
      expect(filterChain, contains('agate=threshold'));
      expect(filterChain, contains('loudnorm=I=-16'));
      expect(filterChain, contains('acompressor'));
      expect(filterChain, contains('alimiter'));
    });

    test('Equalizer and Adjustments verification', () {
      const eqBass = AudioEffectModel(eqPreset: EqualizerPreset.bassBoost);
      expect(eqBass.buildFFmpegAudioFilters(), contains('equalizer=f=80'));

      const adjust = AudioEffectModel(
        stereoBalance: -0.5,
        fadeInSeconds: 1.5,
        fadeOutSeconds: 2.0,
      );
      final chain = adjust.buildFFmpegAudioFilters(clipDuration: 10.0);
      expect(chain, contains('pan=stereo'));
      expect(chain, contains('afade=t=in:ss=0:d=1.5'));
      expect(chain, contains('afade=t=out:st=8.0:d=2.0'));
    });

    test('Serialization and ClipModel integration', () {
      const audioFx = AudioEffectModel(
        voiceEffect: VoiceEffectType.monster,
        noiseReduction: true,
        volume: 1.5,
      );

      final json = audioFx.toJson();
      final restored = AudioEffectModel.fromJson(json);
      expect(restored.voiceEffect, equals(VoiceEffectType.monster));
      expect(restored.noiseReduction, isTrue);
      expect(restored.volume, equals(1.5));

      final clip = ClipModel(
        id: 'clip_fx_1',
        sourcePath: '/path/to/video.mp4',
        startSource: 0.0,
        endSource: 10.0,
        audioEffect: audioFx,
      );

      final clipJson = clip.toJson();
      final clipRestored = ClipModel.fromJson(clipJson);
      expect(clipRestored.audioEffect.voiceEffect, equals(VoiceEffectType.monster));
    });
  });
}

