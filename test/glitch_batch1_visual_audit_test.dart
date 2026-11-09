import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/animation_model.dart';
import 'package:video_clipper_app/core/services/animation_library_service.dart';

void main() {
  group('Glitch Effects Batch 1 (1-30) Semantic Visual Differentiation Suite', () {
    final library = AnimationLibraryService();
    final allGlitches = library.filterPresets(category: AnimationCategory.glitch);

    test('1. Catalog Integrity: First 30 Glitch Presets Loaded', () {
      expect(allGlitches.length, greaterThanOrEqualTo(30));
      final batch1Ids = [
        'rgb_split', 'digital_glitch', 'vhs_glitch', 'scanlines', 'pixel_sort_down',
        'pixel_sort_horizontal', 'color_channel_offset', 'block_displacement', 'data_moshing',
        'frame_drop_glitch', 'vhs_tracking_noise', 'static_snow_noise', 'analog_signal_drop',
        'interlaced_tear', 'corrupted_ram', 'chromatic_jitter', 'glitch_flash_in', 'glitch_flash_out',
        'horizontal_slice_tear', 'vertical_sync_roll', 'bad_antenna_ghost', 'low_bitrate_chunky',
        'cyber_matrix_corruption', 'tape_rewind_artifact', 'bad_codec_stutter', 'glitch_rgb_radial',
        'audio_sync_glitch', 'neon_glitch_slice', 'quantization_noise', 'color_negative_glitch',
      ];

      for (final id in batch1Ids) {
        final found = allGlitches.any((p) => p.id == id);
        expect(found, isTrue, reason: 'Preset ID $id must exist in catalog');
      }
    });

    test('2. RGB Split vs Color Channel Offset vs Radial RGB Differentiation', () {
      const rgbSplit = ClipAnimationModel(presetId: 'rgb_split', duration: 1.0);
      const colorOffset = ClipAnimationModel(presetId: 'color_channel_offset', duration: 1.0);
      const radialRgb = ClipAnimationModel(presetId: 'glitch_rgb_radial', duration: 1.0);

      final rSplit = rgbSplit.evaluate(timeInClip: 0.5, totalClipDuration: 1.0);
      final rOffset = colorOffset.evaluate(timeInClip: 0.5, totalClipDuration: 1.0);
      final rRadial = radialRgb.evaluate(timeInClip: 0.5, totalClipDuration: 1.0);

      // Color Channel Offset has much larger chromatic displacement than RGB Split
      expect(rOffset.chromaticAberration, greaterThan(rSplit.chromaticAberration));
      // Radial RGB modulates scale pulse alongside chromatic dispersion
      expect(rRadial.scale, isNot(equals(rSplit.scale)));
    });

    test('3. VHS Glitch vs VHS Tracking Noise vs Tape Rewind Differentiation', () {
      const vhsGlitch = ClipAnimationModel(presetId: 'vhs_glitch', duration: 1.0);
      const trackingNoise = ClipAnimationModel(presetId: 'vhs_tracking_noise', duration: 1.0);
      const tapeRewind = ClipAnimationModel(presetId: 'tape_rewind_artifact', duration: 1.0);

      final rVhs = vhsGlitch.evaluate(timeInClip: 0.2, totalClipDuration: 1.0);
      final rTrack = trackingNoise.evaluate(timeInClip: 0.2, totalClipDuration: 1.0);
      final rRewind = tapeRewind.evaluate(timeInClip: 0.2, totalClipDuration: 1.0);

      // VHS Glitch has jitter on X & wobble on Y
      expect(rVhs.positionX.abs(), greaterThan(0.001));
      // Tracking noise is vertical roll band dominant
      expect(rTrack.scanlineIntensity, greaterThan(rVhs.scanlineIntensity));
      // Rewind has rapid negative horizontal sweep
      expect(rRewind.positionX, lessThan(0.0));
    });

    test('4. Pixel Sort Down (Vertical) vs Pixel Sort Horizontal Differentiation', () {
      const sortDown = ClipAnimationModel(presetId: 'pixel_sort_down', duration: 1.0);
      const sortHoriz = ClipAnimationModel(presetId: 'pixel_sort_horizontal', duration: 1.0);

      final rDown = sortDown.evaluate(timeInClip: 0.5, totalClipDuration: 1.0);
      final rHoriz = sortHoriz.evaluate(timeInClip: 0.5, totalClipDuration: 1.0);

      // Pixel Sort Down displaces on Y
      expect(rDown.positionY.abs(), greaterThan(0.001));
      expect(rDown.positionX.abs(), equals(0.0));

      // Pixel Sort Horizontal displaces on X
      expect(rHoriz.positionX.abs(), greaterThan(0.001));
      expect(rHoriz.positionY.abs(), equals(0.0));
    });

    test('5. Static TV Snow vs Quantization Error Noise Differentiation', () {
      const tvSnow = ClipAnimationModel(presetId: 'static_snow_noise', duration: 1.0);
      const quant = ClipAnimationModel(presetId: 'quantization_noise', duration: 1.0);

      final rSnow = tvSnow.evaluate(timeInClip: 0.25, totalClipDuration: 1.0);
      final rQuant = quant.evaluate(timeInClip: 0.25, totalClipDuration: 1.0);

      expect(rSnow.scanlineIntensity, greaterThan(0.0));
      expect(rQuant.scanlineIntensity, equals(0.0));
    });

    test('6. Frame Drop Stutter vs AV Sync Jitter Spike vs Broken Codec', () {
      const frameDrop = ClipAnimationModel(presetId: 'frame_drop_glitch', duration: 1.0);
      const avSync = ClipAnimationModel(presetId: 'audio_sync_glitch', duration: 1.0);
      const brokenCodec = ClipAnimationModel(presetId: 'bad_codec_stutter', duration: 1.0);

      final rDrop = frameDrop.evaluate(timeInClip: 0.3, totalClipDuration: 1.0);
      final rAv = avSync.evaluate(timeInClip: 0.3, totalClipDuration: 1.0);
      final rCodec = brokenCodec.evaluate(timeInClip: 0.3, totalClipDuration: 1.0);

      expect(rDrop.positionY, isNot(equals(rAv.positionY)));
      expect(rCodec.chromaticAberration, greaterThan(0.0));
    });

    test('7. Glitch Flash In vs Glitch Flash Out Temporal Inversion', () {
      const flashIn = ClipAnimationModel(presetId: 'glitch_flash_in', duration: 1.0, easing: AnimationEasingCurve.linear);
      const flashOut = ClipAnimationModel(presetId: 'glitch_flash_out', duration: 1.0, easing: AnimationEasingCurve.linear);

      final rInStart = flashIn.evaluate(timeInClip: 0.1, totalClipDuration: 1.0);
      final rInEnd = flashIn.evaluate(timeInClip: 0.9, totalClipDuration: 1.0);

      final rOutStart = flashOut.evaluate(timeInClip: 0.1, totalClipDuration: 1.0);
      final rOutEnd = flashOut.evaluate(timeInClip: 0.9, totalClipDuration: 1.0);

      // In: High flash at start, 0 at end
      expect(rInStart.flashOpacity, greaterThan(0.5));
      expect(rInEnd.flashOpacity, equals(0.0));

      // Out: 0 at start, high flash at end
      expect(rOutStart.flashOpacity, equals(0.0));
      expect(rOutEnd.flashOpacity, greaterThan(0.5));
    });

    test('8. Automated Trajectory Uniqueness Audit for all 30 Presets in Batch 1', () {
      final batch1Ids = [
        'rgb_split', 'digital_glitch', 'vhs_glitch', 'scanlines', 'pixel_sort_down',
        'pixel_sort_horizontal', 'color_channel_offset', 'block_displacement', 'data_moshing',
        'frame_drop_glitch', 'vhs_tracking_noise', 'static_snow_noise', 'analog_signal_drop',
        'interlaced_tear', 'corrupted_ram', 'chromatic_jitter', 'glitch_flash_in', 'glitch_flash_out',
        'horizontal_slice_tear', 'vertical_sync_roll', 'bad_antenna_ghost', 'low_bitrate_chunky',
        'cyber_matrix_corruption', 'tape_rewind_artifact', 'bad_codec_stutter', 'glitch_rgb_radial',
        'audio_sync_glitch', 'neon_glitch_slice', 'quantization_noise', 'color_negative_glitch',
      ];

      final sampleTimes = [0.05, 0.1, 0.25, 0.5, 0.75, 0.95];
      final Map<String, List<double>> trajectoryMap = {};

      for (final id in batch1Ids) {
        final model = ClipAnimationModel(presetId: id, duration: 1.0, intensity: 1.0, easing: AnimationEasingCurve.linear);
        final List<double> vector = [];
        for (final t in sampleTimes) {
          final res = model.evaluate(timeInClip: t, totalClipDuration: 1.0);
          vector.add(double.parse(res.positionX.toStringAsFixed(4)));
          vector.add(double.parse(res.positionY.toStringAsFixed(4)));
          vector.add(double.parse(res.scale.toStringAsFixed(4)));
          vector.add(double.parse(res.chromaticAberration.toStringAsFixed(4)));
          vector.add(double.parse(res.scanlineIntensity.toStringAsFixed(4)));
          vector.add(double.parse(res.flashOpacity.toStringAsFixed(4)));
        }
        trajectoryMap[id] = vector;
      }

      // Assert zero pairwise duplicate trajectories among all 30 presets
      for (int i = 0; i < batch1Ids.length; i++) {
        for (int j = i + 1; j < batch1Ids.length; j++) {
          final idA = batch1Ids[i];
          final idB = batch1Ids[j];
          final vecA = trajectoryMap[idA]!;
          final vecB = trajectoryMap[idB]!;

          double diff = 0.0;
          for (int k = 0; k < vecA.length; k++) {
            diff += (vecA[k] - vecB[k]).abs();
          }

          expect(
            diff,
            greaterThan(0.005),
            reason: 'Preset [$idA] and [$idB] have identical or near-identical trajectory (diff: $diff)!',
          );
        }
      }
    });
  });
}

