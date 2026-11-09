import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/animation_model.dart';
import 'package:video_clipper_app/core/services/animation_library_service.dart';

void main() {
  group('Glitch Effects Batch 3 (61-100) Semantic Visual Differentiation Suite', () {
    final library = AnimationLibraryService();
    final allGlitches = library.filterPresets(category: AnimationCategory.glitch);

    final batch3Ids = [
      'hologram_reboot_cycle',
      'chroma_phase_shift',
      'scan_frequency_drift',
      'digital_jitter_fast',
      'glitch_split_horiz',
      'tape_crinkle_wrinkle',
      'glitch_teleport_in',
      'glitch_teleport_out',
      'neural_corrupt_warp',
      'final_static_burst',
      'glitch_gpu_driver_crash',
      'glitch_buffer_overflow_smear',
      'glitch_sync_pulse_drop',
      'glitch_h264_macroblock_loss',
      'glitch_matrix_digital_rain_tear',
      'glitch_vram_memory_leak_artifact',
      'glitch_analog_demodulator_hum',
      'glitch_quantum_decoherence',
      'glitch_jpeg_spectral_artifact',
      'glitch_cracked_lcd_screen_bleed',
      'glitch_parity_check_error',
      'glitch_yuv_chroma_subsample_drop',
      'glitch_hdmi_handshake_failure',
      'glitch_satellite_uplink_loss',
      'glitch_corrupted_nvram_boot',
      'glitch_crt_degauss_coil_wobble',
      'glitch_rf_signal_cross_modulation',
      'glitch_mpeg2_transport_stream_tear',
      'glitch_digital_ghosting_echo',
      'glitch_interlaced_comb_artifact',
      'glitch_defective_ccd_sensor_line',
      'glitch_rolling_shutter_wobble',
      'glitch_static_discharge_spark',
      'glitch_audio_video_desync_flutter',
      'glitch_bit_rot_decay',
      'glitch_analog_tape_crease',
      'glitch_laserdisc_dropout_snow',
      'glitch_raster_beam_collapse',
      'glitch_color_burst_phase_jitter',
      'glitch_zero_day_malware_glitch',
    ];

    test('1. Catalog Integrity: All 40 Batch 3 Presets Exist in Catalog', () {
      expect(batch3Ids.length, equals(40));
      for (final id in batch3Ids) {
        final found = allGlitches.any((p) => p.id == id);
        expect(found, isTrue, reason: 'Preset ID $id must exist in catalog');
      }
    });

    test('2. Hologram Reboot Cycle (OFF -> Scan -> ON -> Glitch -> OFF) Temporal Phases', () {
      const anim = ClipAnimationModel(
        presetId: 'hologram_reboot_cycle',
        duration: 1.0,
        type: AnimationApplicationType.comboAnimation,
        easing: AnimationEasingCurve.linear,
      );
      final offEarly = anim.evaluate(timeInClip: 0.05, totalClipDuration: 1.0);
      final scanPhase = anim.evaluate(timeInClip: 0.25, totalClipDuration: 1.0);
      final onPhase = anim.evaluate(timeInClip: 0.55, totalClipDuration: 1.0);
      final offLate = anim.evaluate(timeInClip: 0.98, totalClipDuration: 1.0);

      expect(offEarly.opacity, lessThan(0.2));
      expect(scanPhase.scanlineIntensity, greaterThan(0.5));
      expect(onPhase.opacity, greaterThan(0.8));
      expect(offLate.opacity, lessThan(0.3));
    });

    test('3. Glitch Teleport In vs Glitch Teleport Out Inversion', () {
      const tpIn = ClipAnimationModel(presetId: 'glitch_teleport_in', duration: 1.0);
      const tpOut = ClipAnimationModel(presetId: 'glitch_teleport_out', duration: 1.0);

      // In: starts smaller, expands, opacity increases
      final rInEarly = tpIn.evaluate(timeInClip: 0.1, totalClipDuration: 1.0);
      final rInLate = tpIn.evaluate(timeInClip: 0.9, totalClipDuration: 1.0);
      expect(rInLate.opacity, greaterThan(rInEarly.opacity));
      expect(rInLate.scale, greaterThan(rInEarly.scale));

      // Out: starts normal, fragments, moves upward (negative Y) and disappears
      final rOutEarly = tpOut.evaluate(timeInClip: 0.1, totalClipDuration: 1.0);
      final rOutLate = tpOut.evaluate(timeInClip: 0.9, totalClipDuration: 1.0);
      expect(rOutLate.opacity, lessThan(rOutEarly.opacity));
      expect(rOutLate.positionY, lessThan(rOutEarly.positionY));
    });

    test('4. Raster Beam Collapse Vertical Squeeze to Center & Line Flash', () {
      const beam = ClipAnimationModel(
        presetId: 'glitch_raster_beam_collapse',
        duration: 1.0,
        type: AnimationApplicationType.comboAnimation,
        easing: AnimationEasingCurve.linear,
      );
      final early = beam.evaluate(timeInClip: 0.2, totalClipDuration: 1.0);
      final linePhase = beam.evaluate(timeInClip: 0.7, totalClipDuration: 1.0);
      final blackPhase = beam.evaluate(timeInClip: 0.9, totalClipDuration: 1.0);

      expect(early.scaleY, greaterThan(0.5));
      expect(linePhase.scaleY, lessThanOrEqualTo(0.05));
      expect(linePhase.flashOpacity, greaterThan(0.5));
      expect(blackPhase.opacity, equals(0.0));
    });

    test('5. Defective CCD Sensor Line vs Interlaced Comb Teeth', () {
      const ccd = ClipAnimationModel(presetId: 'glitch_defective_ccd_sensor_line', duration: 1.0);
      const comb = ClipAnimationModel(presetId: 'glitch_interlaced_comb_artifact', duration: 1.0);

      final rCcd = ccd.evaluate(timeInClip: 0.5, totalClipDuration: 1.0);
      final rComb = comb.evaluate(timeInClip: 0.5, totalClipDuration: 1.0);

      expect(rComb.scanlineIntensity, greaterThan(0.7));
      expect(rCcd.scanlineIntensity, equals(0.0));
      expect(rComb.positionX.abs(), greaterThan(0.0));
      expect(rCcd.positionX, equals(0.0));
    });

    test('6. Static Burst Finale Cumulative Crescendo', () {
      const burst = ClipAnimationModel(presetId: 'final_static_burst', duration: 1.0);
      final early = burst.evaluate(timeInClip: 0.1, totalClipDuration: 1.0);
      final late = burst.evaluate(timeInClip: 0.95, totalClipDuration: 1.0);

      expect(late.scanlineIntensity, greaterThan(early.scanlineIntensity));
      expect(late.flashOpacity, greaterThan(early.flashOpacity));
    });

    test('7. Batch 3 Pairwise Uniqueness (No Two Presets Have Identical Kinematic Vector)', () {
      final sampleTimes = [0.08, 0.25, 0.5, 0.75, 0.92];
      final identicalPairs = <String>[];

      for (int i = 0; i < batch3Ids.length; i++) {
        for (int j = i + 1; j < batch3Ids.length; j++) {
          final idA = batch3Ids[i];
          final idB = batch3Ids[j];

          final animA = ClipAnimationModel(presetId: idA, duration: 1.0);
          final animB = ClipAnimationModel(presetId: idB, duration: 1.0);

          double totalDifference = 0.0;

          for (final t in sampleTimes) {
            final resA = animA.evaluate(timeInClip: t, totalClipDuration: 1.0);
            final resB = animB.evaluate(timeInClip: t, totalClipDuration: 1.0);

            final dScale = (resA.scale - resB.scale).abs();
            final dScaleY = (resA.scaleY - resB.scaleY).abs();
            final dX = (resA.positionX - resB.positionX).abs();
            final dY = (resA.positionY - resB.positionY).abs();
            final dRot = (resA.rotationDegrees - resB.rotationDegrees).abs();
            final dChrom = (resA.chromaticAberration - resB.chromaticAberration).abs();
            final dScan = (resA.scanlineIntensity - resB.scanlineIntensity).abs();
            final dFlash = (resA.flashOpacity - resB.flashOpacity).abs();
            final dOpac = (resA.opacity - resB.opacity).abs();

            totalDifference += dScale + dScaleY + dX + dY + (dRot / 10.0) + dChrom + dScan + dFlash + dOpac;
          }

          if (totalDifference < 0.005) {
            identicalPairs.add('$idA <==> $idB (diff: ${totalDifference.toStringAsFixed(4)})');
          }
        }
      }

      expect(
        identicalPairs,
        isEmpty,
        reason: 'All 40 Batch 3 effects must have unique kinematic trajectories. Found duplicates: $identicalPairs',
      );
    });

    test('8. FFmpeg Filter Export Coverage for Batch 3 Key Presets', () {
      final keyExportFilters = [
        'glitch_static_discharge_spark',
        'final_static_burst',
        'chroma_phase_shift',
        'glitch_color_burst_phase_jitter',
        'glitch_raster_beam_collapse',
        'glitch_matrix_digital_rain_tear',
        'glitch_zero_day_malware_glitch',
        'glitch_interlaced_comb_artifact',
      ];

      for (final id in keyExportFilters) {
        final anim = ClipAnimationModel(presetId: id, duration: 1.0);
        final filter = anim.buildFFmpegFilter(clipDuration: 3.0);
        expect(filter.isNotEmpty, isTrue, reason: 'Preset $id must generate non-empty FFmpeg export filter');
      }
    });
  });
}
