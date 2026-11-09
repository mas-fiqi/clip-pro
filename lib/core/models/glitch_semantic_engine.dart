import 'dart:math' as math;
import 'animation_model.dart';

/// Semantic Glitch Kinematic Engine
/// Menghitung transformasi fisik murni untuk 30 efek Glitch Batch 1
class GlitchSemanticEngine {
  static AnimationTransformResult evaluate(
    String id,
    double t,
    double intensity,
    AnimationApplicationType type,
  ) {
    final clampedT = t.clamp(0.0, 1.0);

    switch (id) {
      // 1. RGB Split (Kanal RGB terpisah horizontal stabil)
      case 'rgb_split':
        return AnimationTransformResult(
          chromaticAberration: 0.08 * intensity,
          scale: 1.01,
        );

      // 2. Digital Glitch (Blok rectangular corruption acak)
      case 'digital_glitch':
        final step = (clampedT * 12.0).floor();
        final isJitter = step % 3 == 0;
        final jx = isJitter ? (step % 2 == 0 ? 0.03 : -0.03) * intensity : 0.0;
        return AnimationTransformResult(
          positionX: jx,
          chromaticAberration: isJitter ? 0.05 * intensity : 0.01,
          scale: 1.02,
        );

      // 3. VHS Tape Glitch (Distorsi analog pita, tracking noise)
      case 'vhs_glitch':
        final wobbleY = math.sin(clampedT * math.pi * 8.0) * 0.02 * intensity;
        final jitterX = math.sin(clampedT * math.pi * 16.0) * 0.015 * intensity;
        return AnimationTransformResult(
          positionX: jitterX,
          positionY: wobbleY,
          scanlineIntensity: 0.5 * intensity,
          chromaticAberration: 0.03 * intensity,
        );

      // 4. Retro Scanlines (Garis CRT horizontal)
      case 'scanlines':
        return AnimationTransformResult(
          scanlineIntensity: 0.85 * intensity,
          scale: 1.0,
        );

      // 5. Pixel Sort Down (Piksel meleleh ke bawah)
      case 'pixel_sort_down':
        final dropY = (clampedT * 0.04) * intensity;
        return AnimationTransformResult(
          positionY: -dropY,
          chromaticAberration: 0.03 * intensity,
          scale: 1.02,
        );

      // 6. Pixel Sort Horizontal (Piksel tersapu ke samping)
      case 'pixel_sort_horizontal':
        final sweepX = (clampedT * 0.05) * intensity;
        return AnimationTransformResult(
          positionX: sweepX,
          chromaticAberration: 0.03 * intensity,
          scale: 1.02,
        );

      // 7. Color Channel Offset (Displacement RGB jauh lebih lebar & offset)
      case 'color_channel_offset':
        final offset = (0.12 + math.sin(clampedT * math.pi * 3.0).abs() * 0.06) * intensity;
        return AnimationTransformResult(
          chromaticAberration: offset,
          scale: 1.03,
        );

      // 8. Block Displacement Glitch (Frame terbagi blok bergeser)
      case 'block_displacement':
        final step = (clampedT * 8.0).floor();
        final shift = (step % 2 == 0 ? 0.04 : -0.04) * intensity;
        return AnimationTransformResult(
          positionX: shift,
          scale: 1.02,
        );

      // 9. Datamosh Compression Glitch (Motion dragging & temporal smear)
      case 'data_moshing':
        final smearX = math.sin(clampedT * math.pi * 3.0) * 0.04 * intensity;
        return AnimationTransformResult(
          positionX: smearX,
          chromaticAberration: 0.06 * intensity,
          scale: 1.02,
        );

      // 10. Frame Drop Stutter (Normal -> Freeze -> Jump)
      case 'frame_drop_glitch':
        final step = (clampedT * 6.0).floor() / 6.0;
        final jump = (step * 0.05) * intensity;
        return AnimationTransformResult(
          positionY: jump,
          scale: 1.01,
        );

      // 11. VHS Tracking Noise (Pita noise tebal berjalan dari bawah)
      case 'vhs_tracking_noise':
        final roll = math.sin(clampedT * math.pi * 4.0) * 0.015 * intensity;
        return AnimationTransformResult(
          positionY: roll,
          scanlineIntensity: 0.65 * intensity,
        );

      // 12. Static TV Snow Noise (Titik semut salju putih/abu)
      case 'static_snow_noise':
        final microX = math.sin(clampedT * math.pi * 40.0) * 0.008 * intensity;
        final microY = math.cos(clampedT * math.pi * 38.0) * 0.008 * intensity;
        return AnimationTransformResult(
          positionX: microX,
          positionY: microY,
          scanlineIntensity: 0.3 * intensity,
        );

      // 13. Analog Signal Dropout (Hilang sinyal abu-abu)
      case 'analog_signal_drop':
        double opac = 1.0;
        if (clampedT > 0.35 && clampedT < 0.65) {
          opac = 0.4;
        }
        return AnimationTransformResult(
          opacity: opac,
          scanlineIntensity: 0.7 * intensity,
        );

      // 14. Interlaced Video Tear (Sisir bergigi horizontal)
      case 'interlaced_tear':
        final tearX = (math.sin(clampedT * math.pi * 8.0) * 0.025) * intensity;
        return AnimationTransformResult(
          positionX: tearX,
          chromaticAberration: 0.04 * intensity,
        );

      // 15. Corrupted RAM Artifacts (Blok memori magenta/hijau)
      case 'corrupted_ram':
        final step = (clampedT * 9.0).floor();
        final rx = (step % 3 == 0 ? 0.035 : -0.02) * intensity;
        return AnimationTransformResult(
          positionX: rx,
          chromaticAberration: 0.07 * intensity,
          scale: 1.02,
        );

      // 16. Chromatic Jitter Shake (Aberasi kroma getar cepat)
      case 'chromatic_jitter':
        final jx = math.sin(clampedT * math.pi * 24.0) * 0.03 * intensity;
        final jy = math.cos(clampedT * math.pi * 20.0) * 0.02 * intensity;
        final split = 0.08 * (math.sin(clampedT * math.pi * 12.0).abs() + 0.5) * intensity;
        return AnimationTransformResult(
          positionX: jx,
          positionY: jy,
          chromaticAberration: split,
        );

      // 17. Glitch Flash In (Transisi Masuk: Distorted -> Flash -> Normal)
      case 'glitch_flash_in':
        final p = clampedT < 0.4 ? (1.0 - clampedT / 0.4) : 0.0;
        return AnimationTransformResult(
          positionX: p * 0.06 * intensity,
          flashOpacity: p * 0.8 * intensity,
          chromaticAberration: p * 0.08 * intensity,
          opacity: (clampedT * 2.5).clamp(0.0, 1.0),
        );

      // 18. Glitch Flash Out (Transisi Keluar: Normal -> Glitch -> Disappear)
      case 'glitch_flash_out':
        final p = clampedT > 0.6 ? (clampedT - 0.6) / 0.4 : 0.0;
        return AnimationTransformResult(
          positionX: -p * 0.07 * intensity,
          flashOpacity: p * 0.85 * intensity,
          chromaticAberration: p * 0.09 * intensity,
          opacity: (1.0 - p).clamp(0.0, 1.0),
        );

      // 19. Horizontal Slice Tear (Frame terbelah horizontal kiri & kanan)
      case 'horizontal_slice_tear':
        final sliceShift = (math.sin(clampedT * math.pi * 6.0) * 0.04) * intensity;
        return AnimationTransformResult(
          positionX: sliceShift,
          chromaticAberration: 0.05 * intensity,
          scale: 1.02,
        );

      // 20. Vertical Sync Roll (Gambar bergulir vertikal terus-menerus ala V-Hold)
      case 'vertical_sync_roll':
        final rollY = (clampedT * 2.0) % 1.0;
        return AnimationTransformResult(
          positionY: (rollY - 0.5) * 0.4 * intensity,
          scanlineIntensity: 0.5 * intensity,
        );

      // 21. Ghosting Antenna Signal (1-2 bayangan transparan tertinggal)
      case 'bad_antenna_ghost':
        return AnimationTransformResult(
          positionX: 0.02 * intensity,
          opacity: 0.95,
          scale: 1.01,
        );

      // 22. Low Bitrate 8-Bit Macro (Makroblok pikselasi kasar)
      case 'low_bitrate_chunky':
        final step = (clampedT * 5.0).floor() / 5.0;
        final sx = (step * 0.02) * intensity;
        return AnimationTransformResult(
          positionX: sx,
          scale: 1.02,
        );

      // 23. Cyber Matrix Corruption (Aliran biner hijau matriks)
      case 'cyber_matrix_corruption':
        final rollY = math.sin(clampedT * math.pi * 3.0) * 0.015 * intensity;
        return AnimationTransformResult(
          positionY: rollY,
          scale: 1.01,
        );

      // 24. Tape Rewind Scan (Garis kecepatan horizontal ala Rewind)
      case 'tape_rewind_artifact':
        final rewindX = -((clampedT * 3.0) % 1.0) * 0.08 * intensity;
        return AnimationTransformResult(
          positionX: rewindX,
          scanlineIntensity: 0.6 * intensity,
        );

      // 25. Broken Codec Stutter (Sebagian frame freeze)
      case 'bad_codec_stutter':
        final freezeStep = (clampedT * 4.0).floor() % 2 == 0;
        final bx = freezeStep ? 0.035 * intensity : 0.0;
        return AnimationTransformResult(
          positionX: bx,
          chromaticAberration: freezeStep ? 0.06 * intensity : 0.01,
        );

      // 26. Radial RGB Dispersion (Pemisahan kanal melingkar dari tengah)
      case 'glitch_rgb_radial':
        final rPulse = math.sin(clampedT * math.pi * 3.0).abs() * 0.05 * intensity;
        return AnimationTransformResult(
          scale: 1.0 + rPulse,
          chromaticAberration: 0.07 * intensity,
        );

      // 27. AV Sync Jitter Spike (Spike 1-frame maju-mundur mendadak)
      case 'audio_sync_glitch':
        final step = (clampedT * 12.0).floor();
        final isSpike = (step % 5 == 0);
        return AnimationTransformResult(
          positionX: isSpike ? 0.045 * intensity : 0.0,
          positionY: isSpike ? -0.025 * intensity : 0.0,
        );

      // 28. Neon Glitch Slice (Irisan neon cyan & pink berpendar)
      case 'neon_glitch_slice':
        final sliceY = math.sin(clampedT * math.pi * 4.0) * 0.03 * intensity;
        return AnimationTransformResult(
          positionY: sliceY,
          flashOpacity: 0.25 * intensity,
          chromaticAberration: 0.05 * intensity,
        );

      // 29. Quantization Error Noise (Derau matematis granular)
      case 'quantization_noise':
        final qx = math.sin(clampedT * math.pi * 30.0) * 0.01 * intensity;
        return AnimationTransformResult(
          positionX: qx,
          scale: 1.01,
        );

      // 30. Color Invert Spike (Invert negatif 2-frame)
      case 'color_negative_glitch':
        final step = (clampedT * 8.0).floor();
        final isInvert = (step % 4 == 0);
        return AnimationTransformResult(
          flashOpacity: isInvert ? 0.6 * intensity : 0.0,
          chromaticAberration: isInvert ? 0.08 * intensity : 0.0,
        );

      // =======================================================================
      // BATCH 2: EFFECTS 31 - 60
      // =======================================================================

      // 31. 60Hz AC Screen Flicker (Kedipan kecerahan cepat ritmik 60Hz)
      case 'screen_flicker_60hz':
        final flick = (math.sin(clampedT * math.pi * 60.0) > 0.0 ? 0.28 : 0.0) * intensity;
        return AnimationTransformResult(
          flashOpacity: flick,
          opacity: 1.0 - (flick * 0.4),
        );

      // 32. Tape Pause Wobble (Goncangan vertikal & horizontal distorsi jeda pita)
      case 'tape_pause_wobble':
        final tpY = math.sin(clampedT * math.pi * 6.0) * 0.035 * intensity;
        final tpX = math.sin(clampedT * math.pi * 18.0) * 0.018 * intensity;
        return AnimationTransformResult(
          positionX: tpX,
          positionY: tpY,
          scanlineIntensity: 0.5 * intensity,
        );

      // 33. Glitch Particle Dissolve (Pecah menjadi debu partikel digital)
      case 'glitch_dissolve':
        final dP = clampedT;
        return AnimationTransformResult(
          scale: 1.0 + (dP * 0.08 * intensity),
          opacity: (1.0 - dP * 0.7).clamp(0.2, 1.0),
          chromaticAberration: dP * 0.07 * intensity,
        );

      // 34. Hologram Breakdown (Medan proyeksi biru transparan goyah)
      case 'hologram_breakdown':
        final hFlick = math.sin(clampedT * math.pi * 14.0) * 0.02 * intensity;
        return AnimationTransformResult(
          positionX: hFlick,
          opacity: 0.85 + (math.sin(clampedT * math.pi * 8.0) * 0.15),
          scanlineIntensity: 0.6 * intensity,
          chromaticAberration: 0.05 * intensity,
        );

      // 35. Satellite Feed Loss (Blok beku abu-abu & interupsi sinyal satelit)
      case 'satellite_feed_loss':
        final sLoss = (clampedT > 0.3 && clampedT < 0.7);
        return AnimationTransformResult(
          positionX: sLoss ? 0.03 * intensity : 0.0,
          opacity: sLoss ? 0.6 : 1.0,
          chromaticAberration: sLoss ? 0.07 * intensity : 0.0,
        );

      // 36. Glitch Zoom Pop (Hentakan zoom mendadak dipadu pecahan piksel)
      case 'glitch_zoom_pop':
        final popScale = 1.0 + (math.pow(math.sin(clampedT * math.pi * 2.0).abs(), 4.0) * 0.28 * intensity);
        final popJitter = (math.sin(clampedT * math.pi * 16.0) * 0.02) * intensity;
        return AnimationTransformResult(
          scale: popScale,
          positionX: popJitter,
          chromaticAberration: (popScale - 1.0) * 0.2,
        );

      // 37. RGB Strobe Jitter (Strobo bergantian Red -> Green -> Blue)
      case 'rgb_strobe_jitter':
        final sStep = (clampedT * 18.0).floor() % 3;
        final sx = (sStep == 0 ? 0.025 : (sStep == 1 ? -0.025 : 0.0)) * intensity;
        final sy = (sStep == 2 ? 0.02 : -0.01) * intensity;
        return AnimationTransformResult(
          positionX: sx,
          positionY: sy,
          chromaticAberration: 0.09 * intensity,
        );

      // 38. Digital Banding Gradient (Pita kuantisasi warna berundak kasar)
      case 'digital_banding':
        final bStep = (clampedT * 4.0).floor() / 4.0;
        return AnimationTransformResult(
          scale: 1.01 + (bStep * 0.02 * intensity),
        );

      // 39. Glitch Waveform Warp (Deformasi gelombang meliuk sinusoidal)
      case 'glitch_wave_warp':
        final wX = math.sin(clampedT * math.pi * 5.0) * 0.045 * intensity;
        final wRot = math.cos(clampedT * math.pi * 5.0) * 2.5 * intensity;
        return AnimationTransformResult(
          positionX: wX,
          rotationDegrees: wRot,
          scale: 1.03,
        );

      // 40. Tape Head Clog Dust (Debu hitam/putih kotor menyumbat head pita)
      case 'tape_head_clog':
        final cY = math.sin(clampedT * math.pi * 8.0) * 0.015 * intensity;
        return AnimationTransformResult(
          positionY: cY,
          scanlineIntensity: 0.45 * intensity,
          opacity: 0.92,
        );

      // 41. Quantum Entanglement Tear (Sobekan dimensi spasial terbelah non-linear)
      case 'quantum_entangle_glitch':
        final qTear = (math.sin(clampedT * math.pi * 4.0) * 0.05) * intensity;
        final qRot = (math.cos(clampedT * math.pi * 4.0) * 3.0) * intensity;
        return AnimationTransformResult(
          positionX: qTear,
          rotationDegrees: qRot,
          chromaticAberration: 0.08 * intensity,
          scale: 1.04,
        );

      // 42. Circuit Short Spark (Letupan korsleting sirkuit putih-oranye)
      case 'circuit_short_spark':
        final sparkF = (math.sin(clampedT * math.pi * 20.0) > 0.8) ? 0.7 * intensity : 0.0;
        return AnimationTransformResult(
          flashOpacity: sparkF,
          positionX: (sparkF > 0 ? 0.02 : 0.0) * intensity,
        );

      // 43. Dead Pixel Cluster Wave (Gugusan titik piksel mati bergerak)
      case 'lcd_pixel_dead':
        final pWaveX = math.sin(clampedT * math.pi * 2.0) * 0.01 * intensity;
        return AnimationTransformResult(
          positionX: pWaveX,
          scale: 1.0,
        );

      // 44. Buffer Overflow Dump (Limpahan heksadesimal acak)
      case 'buffer_overflow_junk':
        final junkStep = (clampedT * 6.0).floor() % 2 == 0;
        return AnimationTransformResult(
          positionX: junkStep ? 0.025 * intensity : 0.0,
          scale: 1.01,
        );

      // 45. VHS Chrominance Bleed (Warna bleber keluar dari garis batas objek)
      case 'vhs_color_bleed':
        final bleed = (math.sin(clampedT * math.pi * 2.0).abs() * 0.06 + 0.04) * intensity;
        return AnimationTransformResult(
          chromaticAberration: bleed,
          scanlineIntensity: 0.35 * intensity,
        );

      // 46. Raster Beam Skew (Kemiringan trapesium berkas elektron CRT)
      case 'raster_beam_skew':
        final skewRot = math.sin(clampedT * math.pi * 6.0) * 4.5 * intensity;
        return AnimationTransformResult(
          rotationDegrees: skewRot,
          scaleX: 1.0 + (math.sin(clampedT * math.pi * 6.0).abs() * 0.06 * intensity),
          scanlineIntensity: 0.6 * intensity,
        );

      // 47. Deep Fried Color Crush (Saturasi kontras ekstrem meledak ala meme)
      case 'deep_fried_meme':
        final crushScale = 1.0 + (math.sin(clampedT * math.pi * 4.0).abs() * 0.06 * intensity);
        return AnimationTransformResult(
          scale: crushScale,
          flashOpacity: 0.3 * intensity,
          chromaticAberration: 0.07 * intensity,
        );

      // 48. Glitch Bounce In (Transisi Masuk: Memantul sambil robek pecahan piksel)
      case 'glitch_bounce_in':
        final bProg = clampedT < 0.5 ? clampedT / 0.5 : 1.0;
        final bounceScale = 0.6 + math.sin(bProg * math.pi * 0.5) * 0.45;
        final bJitter = (1.0 - bProg) * 0.05 * intensity;
        return AnimationTransformResult(
          scale: bounceScale,
          positionX: bJitter,
          chromaticAberration: (1.0 - bProg) * 0.08 * intensity,
          opacity: bProg.clamp(0.0, 1.0),
        );

      // 49. Glitch Drop Out (Transisi Keluar: Gambar anjlok ke bawah & robek pudar)
      case 'glitch_drop_out':
        final dProg = clampedT > 0.5 ? (clampedT - 0.5) / 0.5 : 0.0;
        final dropY = -dProg * 0.35 * intensity;
        return AnimationTransformResult(
          positionY: dropY,
          chromaticAberration: dProg * 0.09 * intensity,
          scanlineIntensity: dProg * 0.8 * intensity,
          opacity: (1.0 - dProg).clamp(0.0, 1.0),
        );

      // 50. Wireframe Mesh Tear (Jaring poligon 3D terpelintir di atas frame)
      case 'wireframe_wire_tear':
        final wRot = math.sin(clampedT * math.pi * 3.0) * 3.0 * intensity;
        return AnimationTransformResult(
          rotationDegrees: wRot,
          scale: 1.03,
        );

      // 51. Glitch Scanline Sweep (Berkas sapuan tebal bergerak atas ke bawah)
      case 'glitch_scan_sweep':
        final sweepY = (clampedT * 2.0) % 1.0;
        return AnimationTransformResult(
          positionY: (sweepY - 0.5) * 0.06 * intensity,
          scanlineIntensity: 0.75 * intensity,
        );

      // 52. Sensor Overheat Noise (Derau bintik panas ungu pada sensor kamera)
      case 'sensor_overheat_noise':
        final oJitter = math.sin(clampedT * math.pi * 32.0) * 0.01 * intensity;
        return AnimationTransformResult(
          positionX: oJitter,
          chromaticAberration: 0.04 * intensity,
        );

      // 53. Bad HDMI Sparkle Salt (Bintik salju garam digital transmisi rusak)
      case 'broken_hdmi_sparkle':
        final spFlash = (math.sin(clampedT * math.pi * 14.0) > 0.7) ? 0.25 * intensity : 0.0;
        return AnimationTransformResult(
          flashOpacity: spFlash,
        );

      // 54. Packet Loss Frame Drop (Bingkai beku patah akibat koneksi streaming putus)
      case 'packet_loss_drop':
        final isDrop = (clampedT > 0.4 && clampedT < 0.7);
        return AnimationTransformResult(
          positionX: isDrop ? 0.02 * intensity : 0.0,
          scale: 1.01,
        );

      // 55. Neon Distortion Fuzz (Pendaran neon kabur bergetar di pinggiran)
      case 'neon_distortion_fuzz':
        final fuzScale = 1.02 + math.sin(clampedT * math.pi * 8.0) * 0.02 * intensity;
        return AnimationTransformResult(
          scale: fuzScale,
          chromaticAberration: 0.05 * intensity,
          flashOpacity: 0.2 * intensity,
        );

      // 56. Phosphor Persistence Trail (Jejak fosfor hijau tersisa lambat di belakang)
      case 'phosphor_ghost_trail':
        final trailX = math.sin(clampedT * math.pi * 2.0) * 0.03 * intensity;
        return AnimationTransformResult(
          positionX: trailX,
          opacity: 0.9,
          scale: 1.02,
        );

      // 57. Anamorphic Flare Tear (Garis kilau horizontal biru retak berkedip)
      case 'anamorphic_glitch_streak':
        final aPulse = math.sin(clampedT * math.pi * 10.0) * 0.015 * intensity;
        return AnimationTransformResult(
          positionY: aPulse,
          chromaticAberration: 0.05 * intensity,
        );

      // 58. Cyber Stutter Step (Langkah gerak patah-patah 4-step robotik)
      case 'cyber_stutter_step':
        final cStep = (clampedT * 4.0).floor() / 4.0;
        final stepX = (cStep * 0.06 - 0.03) * intensity;
        return AnimationTransformResult(
          positionX: stepX,
          scale: 1.01,
        );

      // 59. Frost Glitch Freeze (Kristal es membekukan gambar rusak sebelum pecah)
      case 'sub_zero_freeze_glitch':
        final isFreeze = clampedT > 0.3 && clampedT < 0.75;
        return AnimationTransformResult(
          scale: isFreeze ? 1.04 : 1.0,
          flashOpacity: isFreeze ? 0.25 * intensity : 0.0,
        );

      // 60. RF Moiré Interference (Pola melingkar konsentris radio liar)
      case 'rf_interference_moiré':
        final mPulse = math.sin(clampedT * math.pi * 6.0) * 0.02 * intensity;
        return AnimationTransformResult(
          scale: 1.02 + mPulse,
          scanlineIntensity: 0.5 * intensity,
        );

      // =======================================================================
      // BATCH 3: EFFECTS 61 - 100
      // =======================================================================

      // 61. Hologram Reboot Cycle (OFF -> Scan -> Flicker -> Hologram ON -> Glitch -> OFF)
      case 'hologram_reboot_cycle':
        final double rebootOpac;
        final double rebootScan;
        if (clampedT < 0.15) {
          rebootOpac = 0.05;
          rebootScan = 0.0;
        } else if (clampedT < 0.35) {
          rebootOpac = (clampedT - 0.15) / 0.2;
          rebootScan = 0.8 * intensity;
        } else if (clampedT < 0.75) {
          final flick = math.sin(clampedT * math.pi * 20.0).abs();
          rebootOpac = 0.85 + (flick * 0.15);
          rebootScan = 0.5 * intensity;
        } else if (clampedT < 0.9) {
          rebootOpac = (math.sin(clampedT * math.pi * 30.0) > 0.0 ? 0.9 : 0.2);
          rebootScan = 0.9 * intensity;
        } else {
          rebootOpac = (1.0 - ((clampedT - 0.9) / 0.1)).clamp(0.0, 1.0);
          rebootScan = 0.0;
        }
        return AnimationTransformResult(
          opacity: rebootOpac,
          scanlineIntensity: rebootScan,
          chromaticAberration: 0.04 * intensity,
        );

      // 62. Chroma Phase Shift (Warna bergeser hijau/ungu, luma relatif stabil)
      case 'chroma_phase_shift':
        final cPhase = math.sin(clampedT * math.pi * 4.0) * 0.06 * intensity;
        return AnimationTransformResult(
          chromaticAberration: cPhase.abs(),
          positionX: cPhase * 0.3,
        );

      // 63. Scan Frequency Drift (Osilator drift horizontal miring/terlipat progresif)
      case 'scan_frequency_drift':
        final driftSkew = math.tan(clampedT * 1.2) * 0.04 * intensity;
        final driftRot = math.sin(clampedT * math.pi * 2.0) * 2.0 * intensity;
        return AnimationTransformResult(
          positionX: driftSkew,
          rotationDegrees: driftRot,
          scanlineIntensity: 0.6 * intensity,
        );

      // 64. Fast Micro Digital Jitter (Micro displacement sangat cepat frekuensi tinggi)
      case 'digital_jitter_fast':
        final jx = math.sin(clampedT * math.pi * 70.0) * 0.009 * intensity;
        final jy = math.cos(clampedT * math.pi * 65.0) * 0.007 * intensity;
        return AnimationTransformResult(
          positionX: jx,
          positionY: jy,
        );

      // 65. Horizontal Split Shudder (Frame terbelah tengah atas/bawah bergetar shudder)
      case 'glitch_split_horiz':
        final sShudder = math.sin(clampedT * math.pi * 24.0) * 0.03 * intensity;
        return AnimationTransformResult(
          positionX: sShudder,
          scale: 1.02,
        );

      // 66. Tape Crinkle Wrinkle (Kerutan pita magnetik melengkung & deformasi irregular)
      case 'tape_crinkle_wrinkle':
        final crinkleY = math.sin(clampedT * math.pi * 6.0) * 0.025 * intensity;
        final crinkleRot = math.sin(clampedT * math.pi * 3.0) * 1.8 * intensity;
        return AnimationTransformResult(
          positionY: crinkleY,
          rotationDegrees: crinkleRot,
          scanlineIntensity: 0.4 * intensity,
        );

      // 67. Glitch Teleport In (Partikel kompresi memadat membentuk gambar)
      case 'glitch_teleport_in':
        final tpIn = (1.0 - clampedT);
        return AnimationTransformResult(
          scale: 0.5 + (clampedT * 0.5),
          opacity: clampedT.clamp(0.0, 1.0),
          chromaticAberration: tpIn * 0.09 * intensity,
          flashOpacity: (tpIn * 0.5 * intensity).clamp(0.0, 1.0),
        );

      // 68. Glitch Teleport Out (Gambar terfragmentasi melesat vertikal lenyap)
      case 'glitch_teleport_out':
        final tpOut = clampedT;
        final outY = -tpOut * 0.25 * intensity;
        return AnimationTransformResult(
          scale: 1.0 + (tpOut * 0.3 * intensity),
          positionY: outY,
          opacity: (1.0 - tpOut).clamp(0.0, 1.0),
          chromaticAberration: tpOut * 0.1 * intensity,
        );

      // 69. Neural Network Error Warp (Distorsi halusinasi non-linear warping)
      case 'neural_corrupt_warp':
        final nScale = 1.0 + math.sin(clampedT * math.pi * 5.0) * 0.07 * intensity;
        final nRot = math.cos(clampedT * math.pi * 3.0) * 3.5 * intensity;
        return AnimationTransformResult(
          scale: nScale,
          rotationDegrees: nRot,
          chromaticAberration: 0.05 * intensity,
        );

      // 70. Static Burst Finale (Normal -> meningkat pesat static -> Full burst)
      case 'final_static_burst':
        final burstProg = math.pow(clampedT, 3.0).toDouble();
        return AnimationTransformResult(
          scanlineIntensity: burstProg * intensity,
          flashOpacity: burstProg * 0.7 * intensity,
          scale: 1.0 + (burstProg * 0.08 * intensity),
          opacity: (1.0 - burstProg * 0.4).clamp(0.0, 1.0),
        );

      // 71. GPU Driver Crash Freeze (Kerusakan poligon/segitiga render freeze)
      case 'glitch_gpu_driver_crash':
        final isCrash = clampedT > 0.4;
        return AnimationTransformResult(
          positionX: isCrash ? 0.02 * intensity : 0.0,
          scale: isCrash ? 1.02 : 1.0,
          chromaticAberration: isCrash ? 0.08 * intensity : 0.0,
        );

      // 72. Buffer Overflow Smear (Smear piksel horizontal jejak panjang membentang)
      case 'glitch_buffer_overflow_smear':
        final smearX = (math.sin(clampedT * math.pi * 2.0) * 0.06 + 0.03) * intensity;
        return AnimationTransformResult(
          positionX: smearX,
          scaleX: 1.0 + (smearX * 1.5).abs(),
        );

      // 73. Sync Pulse Drop Jitter (Lompatan vertikal berulang hilangnya sinyal sinkronisasi)
      case 'glitch_sync_pulse_drop':
        final pulseCycle = (clampedT * 6.0) % 1.0;
        final syncJump = pulseCycle > 0.8 ? -0.12 * intensity : 0.0;
        return AnimationTransformResult(
          positionY: syncJump,
          scanlineIntensity: 0.45 * intensity,
        );

      // 74. H.264 Macroblock Loss (Blok kompresi persegi hijau/abu-abu diskrit)
      case 'glitch_h264_macroblock_loss':
        final isLoss = (clampedT > 0.3 && clampedT < 0.75);
        return AnimationTransformResult(
          positionX: isLoss ? 0.015 * intensity : 0.0,
          scale: 1.01,
        );

      // 75. Matrix Rain Tear (Sobekan horizontal menembus kode digital hijau)
      case 'glitch_matrix_digital_rain_tear':
        final tearX = math.sin(clampedT * math.pi * 4.0) * 0.03 * intensity;
        return AnimationTransformResult(
          positionX: tearX,
          scale: 1.02,
        );

      // 76. VRAM Artifact Corruption (Kotak catur memori merah/ungu terisolir)
      case 'glitch_vram_memory_leak_artifact':
        final vStep = (clampedT * 8.0).floor() % 2 == 0;
        return AnimationTransformResult(
          positionX: vStep ? 0.02 * intensity : -0.01 * intensity,
          chromaticAberration: 0.06 * intensity,
        );

      // 77. Analog Demodulator Noise (Garis gelombang interferensi hum frekuensi rendah lambat)
      case 'glitch_analog_demodulator_hum':
        final humY = math.sin(clampedT * math.pi * 2.0) * 0.03 * intensity;
        return AnimationTransformResult(
          positionY: humY,
          scanlineIntensity: 0.5 * intensity,
        );

      // 78. Quantum Decoherence Shift (Pemisahan bidang spasial multi-layer non-linear)
      case 'glitch_quantum_decoherence':
        final qX = math.sin(clampedT * math.pi * 4.0) * 0.05 * intensity;
        final qY = math.cos(clampedT * math.pi * 3.0) * 0.03 * intensity;
        final qRot = math.sin(clampedT * math.pi * 2.0) * 2.5 * intensity;
        return AnimationTransformResult(
          positionX: qX,
          positionY: qY,
          rotationDegrees: qRot,
          chromaticAberration: 0.07 * intensity,
        );

      // 79. JPEG Spectral Quantization (Blok 8x8 DCT artefak spektral bergeser)
      case 'glitch_jpeg_spectral_artifact':
        final jStep = (clampedT * 5.0).floor() / 5.0;
        return AnimationTransformResult(
          scale: 1.0 + (jStep * 0.03 * intensity),
          chromaticAberration: 0.05 * intensity,
        );

      // 80. Cracked LCD Bleed (Retakan fisik kaca hitam & rembesan kroma pelangi)
      case 'glitch_cracked_lcd_screen_bleed':
        final bleedWobble = math.sin(clampedT * math.pi * 2.0) * 0.01 * intensity;
        return AnimationTransformResult(
          positionX: bleedWobble,
          scale: 1.01,
        );

      // 81. Parity Check Stutter (Pengulangan frame 2-3 kali patah mendadak)
      case 'glitch_parity_check_error':
        final cycle = (clampedT * 4.0).floor() % 4;
        final isHold = (cycle == 1 || cycle == 2);
        return AnimationTransformResult(
          positionX: isHold ? 0.02 * intensity : 0.0,
          scale: 1.0,
        );

      // 82. YUV Chroma Subsample Drop (Pemisahan kanal warna kroma dari bidang luma)
      case 'glitch_yuv_chroma_subsample_drop':
        final yuvOffset = math.sin(clampedT * math.pi * 3.0) * 0.07 * intensity;
        return AnimationTransformResult(
          chromaticAberration: yuvOffset.abs(),
          positionX: yuvOffset * 0.4,
        );

      // 83. HDMI Handshake Intermittent (Video -> Blackout -> Snow -> Video)
      case 'glitch_hdmi_handshake_failure':
        final double hOpac;
        final double hFlash;
        if (clampedT > 0.35 && clampedT < 0.55) {
          hOpac = 0.0;
          hFlash = 0.0;
        } else if (clampedT >= 0.55 && clampedT < 0.70) {
          hOpac = 0.8;
          hFlash = 0.5 * intensity;
        } else {
          hOpac = 1.0;
          hFlash = 0.0;
        }
        return AnimationTransformResult(
          opacity: hOpac,
          flashOpacity: hFlash,
          scanlineIntensity: (clampedT >= 0.55 && clampedT < 0.70) ? 0.8 * intensity : 0.0,
        );

      // 84. Satellite Uplink Drop (Transmisi satelit terputus & pemulihan bertahap)
      case 'glitch_satellite_uplink_loss':
        final isDrop = clampedT > 0.3 && clampedT < 0.7;
        return AnimationTransformResult(
          opacity: isDrop ? 0.5 : 1.0,
          positionX: isDrop ? 0.03 * intensity : 0.0,
          chromaticAberration: isDrop ? 0.08 * intensity : 0.0,
        );

      // 85. Corrupted NVRAM Boot (Teks heksadesimal BIOS/NVRAM berkedip cepat)
      case 'glitch_corrupted_nvram_boot':
        final bootFlick = (math.sin(clampedT * math.pi * 16.0) > 0.0 ? 0.15 : 0.0) * intensity;
        return AnimationTransformResult(
          flashOpacity: bootFlick,
          scale: 1.01,
        );

      // 86. CRT Degauss Coil Wobble (Goncangan elastis melingkar kumparan degauss CRT)
      case 'glitch_crt_degauss_coil_wobble':
        final coilDecay = math.exp(-clampedT * 3.5);
        final coilScale = 1.0 + (math.sin(clampedT * math.pi * 14.0) * 0.12 * coilDecay * intensity);
        final coilRot = math.sin(clampedT * math.pi * 12.0) * 4.0 * coilDecay * intensity;
        return AnimationTransformResult(
          scale: coilScale,
          rotationDegrees: coilRot,
          chromaticAberration: coilDecay * 0.06 * intensity,
        );

      // 87. RF Cross Modulation (Kanal hantu siluet kedua mengambang transparan di belakang)
      case 'glitch_rf_signal_cross_modulation':
        final ghostX = math.sin(clampedT * math.pi * 2.0) * 0.04 * intensity;
        return AnimationTransformResult(
          positionX: ghostX,
          scale: 1.02,
        );

      // 88. MPEG-2 Transport Stream Tear (Sobekan data tebal paket transport MPEG-2)
      case 'glitch_mpeg2_transport_stream_tear':
        final tearPos = math.sin(clampedT * math.pi * 5.0) * 0.04 * intensity;
        return AnimationTransformResult(
          positionX: tearPos,
          scanlineIntensity: 0.4 * intensity,
        );

      // 89. Digital Ghosting Echo (3 siluet bayangan berulang menurun opasitasnya)
      case 'glitch_digital_ghosting_echo':
        final echoX = math.sin(clampedT * math.pi * 2.0) * 0.04 * intensity;
        return AnimationTransformResult(
          positionX: echoX,
          scale: 1.02,
          opacity: 0.95,
        );

      // 90. Interlaced Comb Teeth (Gerigi sisir horizontal bersilangan saat gerak cepat)
      case 'glitch_interlaced_comb_artifact':
        final combJitter = math.sin(clampedT * math.pi * 30.0) * 0.015 * intensity;
        return AnimationTransformResult(
          positionX: combJitter,
          scanlineIntensity: 0.85 * intensity,
        );

      // 91. Defective CCD Sensor Line (1 garis vertikal piksel mati menetap)
      case 'glitch_defective_ccd_sensor_line':
        return AnimationTransformResult(
          scale: 1.0,
        );

      // 92. Rolling Shutter Jello (Peregangan lentur seperti agar-agar atas-bawah asinkron)
      case 'glitch_rolling_shutter_wobble':
        final jelloX = math.sin(clampedT * math.pi * 4.0) * 0.04 * intensity;
        final jelloRot = math.sin(clampedT * math.pi * 4.0) * 2.2 * intensity;
        return AnimationTransformResult(
          positionX: jelloX,
          rotationDegrees: jelloRot,
          scaleY: 1.0 + (math.cos(clampedT * math.pi * 4.0) * 0.03 * intensity),
        );

      // 93. Static Discharge Spark (Bunga api listrik statis putih berkelebat tak teratur)
      case 'glitch_static_discharge_spark':
        final isDischarge = math.sin(clampedT * math.pi * 26.0) > 0.8;
        return AnimationTransformResult(
          flashOpacity: isDischarge ? 0.6 * intensity : 0.0,
          positionX: isDischarge ? 0.02 * intensity : 0.0,
        );

      // 94. A/V Desync Flutter (Getaran temporal 1-frame maju-mundur berulang ritmis)
      case 'glitch_audio_video_desync_flutter':
        final flutterStep = (clampedT * 12.0).floor() % 2;
        return AnimationTransformResult(
          positionX: (flutterStep == 0 ? 0.015 : -0.015) * intensity,
          scale: 1.01,
        );

      // 95. Magnetic Bit Rot Decay (Pita membusuk bintik karat & artefak pudar bertahap)
      case 'glitch_bit_rot_decay':
        final rotOpac = (1.0 - clampedT * 0.25).clamp(0.6, 1.0);
        return AnimationTransformResult(
          opacity: rotOpac,
          chromaticAberration: clampedT * 0.05 * intensity,
          scanlineIntensity: clampedT * 0.5 * intensity,
        );

      // 96. Analog Tape Crease Pop (Garis lipatan putih tebal meloncat tiba-tiba)
      case 'glitch_analog_tape_crease':
        final creaseJump = (clampedT * 4.0) % 1.0 > 0.85 ? -0.05 * intensity : 0.0;
        return AnimationTransformResult(
          positionY: creaseJump,
          scanlineIntensity: 0.55 * intensity,
        );

      // 97. Laserdisc Dropout Snow (Titik dropout horizontal pendek & jarang khas optik)
      case 'glitch_laserdisc_dropout_snow':
        final ldJitter = math.sin(clampedT * math.pi * 18.0) * 0.008 * intensity;
        return AnimationTransformResult(
          positionX: ldJitter,
          scale: 1.0,
        );

      // 98. Raster Beam Collapse (Full image -> collapse vertikal -> garis putih horizontal -> Black)
      case 'glitch_raster_beam_collapse':
        final double rScaleY;
        final double rOpac;
        final double rFlash;
        if (clampedT < 0.6) {
          rScaleY = 1.0 - (clampedT / 0.6) * 0.95; // menyusut tipis ke tengah
          rOpac = 1.0;
          rFlash = 0.0;
        } else if (clampedT < 0.8) {
          rScaleY = 0.02; // garis horizontal ultra terang
          rOpac = 1.0;
          rFlash = 0.9 * intensity;
        } else {
          rScaleY = 0.0; // padam / black
          rOpac = 0.0;
          rFlash = 0.0;
        }
        return AnimationTransformResult(
          scaleY: rScaleY,
          opacity: rOpac,
          flashOpacity: rFlash,
        );

      // 99. Color Burst Phase Jitter (Magenta -> Cyan -> Yellow osilator warna liar)
      case 'glitch_color_burst_phase_jitter':
        final burstX = math.sin(clampedT * math.pi * 10.0) * 0.02 * intensity;
        return AnimationTransformResult(
          positionX: burstX,
          chromaticAberration: 0.09 * intensity,
        );

      // 100. Cyber Breach Data Glitch (Pelanggaran keamanan cyber data biner & blok merah)
      case 'glitch_zero_day_malware_glitch':
        final breachJitter = (math.sin(clampedT * math.pi * 22.0) * 0.035) * intensity;
        final breachScale = 1.02 + math.sin(clampedT * math.pi * 14.0).abs() * 0.04 * intensity;
        return AnimationTransformResult(
          positionX: breachJitter,
          scale: breachScale,
          chromaticAberration: 0.08 * intensity,
          flashOpacity: (clampedT > 0.7 ? 0.35 : 0.0) * intensity,
        );

      default:
        return const AnimationTransformResult();
    }
  }
}

