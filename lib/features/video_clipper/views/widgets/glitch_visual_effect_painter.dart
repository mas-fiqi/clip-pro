import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Semantic Glitch Visual Effect Painter
/// Melukis efek visual glitch nyata sesuai semantik spesifik dari masing-masing efek
/// untuk Mini Preview, Main Preview, dan Player Timeline.
class GlitchVisualEffectPainter extends CustomPainter {
  final String effectId;
  final double progress; // 0.0 - 1.0 (loop)
  final double intensity;

  GlitchVisualEffectPainter({
    required this.effectId,
    required this.progress,
    this.intensity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.clamp(0.0, 1.0);

    switch (effectId) {
      // -----------------------------------------------------------------------
      // 1. RGB Split (Kanal RGB terpisah horizontal tegas & stabil)
      // -----------------------------------------------------------------------
      case 'rgb_split':
        _paintRgbSplit(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 2. Digital Glitch (Blok rectangular corruption acak muncul/hilang)
      // -----------------------------------------------------------------------
      case 'digital_glitch':
        _paintDigitalGlitch(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 3. VHS Tape Glitch (Distorsi pita magnetik, tracking band, jitter analog)
      // -----------------------------------------------------------------------
      case 'vhs_glitch':
        _paintVhsGlitch(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 4. Retro Scanlines (Garis tipis CRT horizontal berdenyut konsisten)
      // -----------------------------------------------------------------------
      case 'scanlines':
        _paintScanlines(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 5. Pixel Sort Down (Piksel meleleh vertikal ke BAWAH)
      // -----------------------------------------------------------------------
      case 'pixel_sort_down':
        _paintPixelSortDown(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 6. Pixel Sort Horizontal (Piksel tersapu memanjang ke SAMPING)
      // -----------------------------------------------------------------------
      case 'pixel_sort_horizontal':
        _paintPixelSortHorizontal(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 7. Color Channel Offset (Displacement RGB jauh lebih lebar & beda sudut)
      // -----------------------------------------------------------------------
      case 'color_channel_offset':
        _paintColorChannelOffset(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 8. Block Displacement Glitch (Frame terbagi rectangular blocks bergeser)
      // -----------------------------------------------------------------------
      case 'block_displacement':
        _paintBlockDisplacement(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 9. Datamosh Compression Glitch (Motion dragging smear, temporal smear)
      // -----------------------------------------------------------------------
      case 'data_moshing':
        _paintDatamoshing(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 10. Frame Drop Stutter (Normal -> Freeze -> Jump -> Freeze)
      // -----------------------------------------------------------------------
      case 'frame_drop_glitch':
        _paintFrameDrop(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 11. VHS Tracking Noise (Pita noise tebal berjalan dari bawah ke atas)
      // -----------------------------------------------------------------------
      case 'vhs_tracking_noise':
        _paintVhsTrackingNoise(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 12. Static TV Snow Noise (Ribuan titik semut salju putih/abu padat)
      // -----------------------------------------------------------------------
      case 'static_snow_noise':
        _paintStaticSnow(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 13. Analog Signal Dropout (Normal -> Hilang sinyal abu-abu -> Distorsi -> Pulih)
      // -----------------------------------------------------------------------
      case 'analog_signal_drop':
        _paintAnalogSignalDrop(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 14. Interlaced Video Tear (Gigi sisir interlacing 50i/60i garis ganjil-genap)
      // -----------------------------------------------------------------------
      case 'interlaced_tear':
        _paintInterlacedTear(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 15. Corrupted RAM Artifacts (Blok memori magenta/hijau & kode hex acak)
      // -----------------------------------------------------------------------
      case 'corrupted_ram':
        _paintCorruptedRam(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 16. Chromatic Jitter Shake (Aberasi kroma yang bergetar frekuensi tinggi)
      // -----------------------------------------------------------------------
      case 'chromatic_jitter':
        _paintChromaticJitter(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 17. Glitch Flash In (Distorted -> Flash -> Glitch Fragments -> Normal)
      // -----------------------------------------------------------------------
      case 'glitch_flash_in':
        _paintGlitchFlashIn(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 18. Glitch Flash Out (Normal -> Glitch -> Fragments -> Flash -> Disappear)
      // -----------------------------------------------------------------------
      case 'glitch_flash_out':
        _paintGlitchFlashOut(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 19. Horizontal Slice Tear (Frame terbelah slice horizontal kiri & kanan)
      // -----------------------------------------------------------------------
      case 'horizontal_slice_tear':
        _paintHorizontalSliceTear(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 20. Vertical Sync Roll (Gambar bergulir vertikal terus-menerus ala V-Hold)
      // -----------------------------------------------------------------------
      case 'vertical_sync_roll':
        _paintVerticalSyncRoll(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 21. Ghosting Antenna Signal (1-2 bayangan transparan tertinggal di samping)
      // -----------------------------------------------------------------------
      case 'bad_antenna_ghost':
        _paintAntennaGhost(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 22. Low Bitrate 8-Bit Macro (Makroblok pikselasi kotak besar kasar)
      // -----------------------------------------------------------------------
      case 'low_bitrate_chunky':
        _paintLowBitrateMacro(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 23. Cyber Matrix Corruption (Aliran kode biner dan karakter hijau matriks)
      // -----------------------------------------------------------------------
      case 'cyber_matrix_corruption':
        _paintCyberMatrix(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 24. Tape Rewind Scan (Garis kecepatan tinggi melesat ala tombol Rewind)
      // -----------------------------------------------------------------------
      case 'tape_rewind_artifact':
        _paintTapeRewind(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 25. Broken Codec Stutter (Sebagian frame freeze dan bagian lain jalan)
      // -----------------------------------------------------------------------
      case 'bad_codec_stutter':
        _paintBrokenCodec(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 26. Radial RGB Dispersion (Pemisahan kanal menyebar melingkar dari tengah)
      // -----------------------------------------------------------------------
      case 'glitch_rgb_radial':
        _paintRadialRgb(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 27. AV Sync Jitter Spike (Spike 1-frame maju-mundur tiba-tiba)
      // -----------------------------------------------------------------------
      case 'audio_sync_glitch':
        _paintAvSyncJitter(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 28. Neon Glitch Slice (Irisan neon cyan & pink berpendar menyala terang)
      // -----------------------------------------------------------------------
      case 'neon_glitch_slice':
        _paintNeonSlice(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 29. Quantization Error Noise (Derau matematis granular & pita warna kasar)
      // -----------------------------------------------------------------------
      case 'quantization_noise':
        _paintQuantizationNoise(canvas, size, t);
        break;

      // -----------------------------------------------------------------------
      // 30. Color Invert Spike (Pembalikan warna negatif seketika selama 2 frame)
      // -----------------------------------------------------------------------
      case 'color_negative_glitch':
        _paintColorNegativeSpike(canvas, size, t);
        break;

      // =======================================================================
      // BATCH 2: EFFECTS 31 - 60
      // =======================================================================

      // 31. 60Hz AC Screen Flicker
      case 'screen_flicker_60hz':
        _paint60HzFlicker(canvas, size, t);
        break;

      // 32. Tape Pause Wobble
      case 'tape_pause_wobble':
        _paintTapePauseWobble(canvas, size, t);
        break;

      // 33. Glitch Particle Dissolve
      case 'glitch_dissolve':
        _paintGlitchDissolve(canvas, size, t);
        break;

      // 34. Hologram Breakdown
      case 'hologram_breakdown':
        _paintHologramBreakdown(canvas, size, t);
        break;

      // 35. Satellite Feed Loss
      case 'satellite_feed_loss':
        _paintSatelliteFeedLoss(canvas, size, t);
        break;

      // 36. Glitch Zoom Pop
      case 'glitch_zoom_pop':
        _paintGlitchZoomPop(canvas, size, t);
        break;

      // 37. RGB Strobe Jitter
      case 'rgb_strobe_jitter':
        _paintRgbStrobeJitter(canvas, size, t);
        break;

      // 38. Digital Banding Gradient
      case 'digital_banding':
        _paintDigitalBanding(canvas, size, t);
        break;

      // 39. Glitch Waveform Warp
      case 'glitch_wave_warp':
        _paintGlitchWaveWarp(canvas, size, t);
        break;

      // 40. Tape Head Clog Dust
      case 'tape_head_clog':
        _paintTapeHeadClog(canvas, size, t);
        break;

      // 41. Quantum Entanglement Tear
      case 'quantum_entangle_glitch':
        _paintQuantumEntanglement(canvas, size, t);
        break;

      // 42. Circuit Short Spark
      case 'circuit_short_spark':
        _paintCircuitShortSpark(canvas, size, t);
        break;

      // 43. Dead Pixel Cluster Wave
      case 'lcd_pixel_dead':
        _paintLcdPixelDead(canvas, size, t);
        break;

      // 44. Buffer Overflow Dump
      case 'buffer_overflow_junk':
        _paintBufferOverflowJunk(canvas, size, t);
        break;

      // 45. VHS Chrominance Bleed
      case 'vhs_color_bleed':
        _paintVhsColorBleed(canvas, size, t);
        break;

      // 46. Raster Beam Skew
      case 'raster_beam_skew':
        _paintRasterBeamSkew(canvas, size, t);
        break;

      // 47. Deep Fried Color Crush
      case 'deep_fried_meme':
        _paintDeepFriedMeme(canvas, size, t);
        break;

      // 48. Glitch Bounce In
      case 'glitch_bounce_in':
        _paintGlitchBounceIn(canvas, size, t);
        break;

      // 49. Glitch Drop Out
      case 'glitch_drop_out':
        _paintGlitchDropOut(canvas, size, t);
        break;

      // 50. Wireframe Mesh Tear
      case 'wireframe_wire_tear':
        _paintWireframeWireTear(canvas, size, t);
        break;

      // 51. Glitch Scanline Sweep
      case 'glitch_scan_sweep':
        _paintGlitchScanSweep(canvas, size, t);
        break;

      // 52. Sensor Overheat Noise
      case 'sensor_overheat_noise':
        _paintSensorOverheatNoise(canvas, size, t);
        break;

      // 53. Bad HDMI Sparkle Salt
      case 'broken_hdmi_sparkle':
        _paintBrokenHdmiSparkle(canvas, size, t);
        break;

      // 54. Packet Loss Frame Drop
      case 'packet_loss_drop':
        _paintPacketLossDrop(canvas, size, t);
        break;

      // 55. Neon Distortion Fuzz
      case 'neon_distortion_fuzz':
        _paintNeonDistortionFuzz(canvas, size, t);
        break;

      // 56. Phosphor Persistence Trail
      case 'phosphor_ghost_trail':
        _paintPhosphorGhostTrail(canvas, size, t);
        break;

      // 57. Anamorphic Flare Tear
      case 'anamorphic_glitch_streak':
        _paintAnamorphicGlitchStreak(canvas, size, t);
        break;

      // 58. Cyber Stutter Step
      case 'cyber_stutter_step':
        _paintCyberStutterStep(canvas, size, t);
        break;

      // 59. Frost Glitch Freeze
      case 'sub_zero_freeze_glitch':
        _paintSubZeroFreezeGlitch(canvas, size, t);
        break;

      // 60. RF Moiré Interference
      case 'rf_interference_moiré':
        _paintRfInterferenceMoire(canvas, size, t);
        break;

      // =======================================================================
      // BATCH 3: EFFECTS 61 - 100
      // =======================================================================

      // 61. Hologram Reboot Cycle
      case 'hologram_reboot_cycle':
        _paintHologramRebootCycle(canvas, size, t);
        break;

      // 62. Chroma Phase Shift
      case 'chroma_phase_shift':
        _paintChromaPhaseShift(canvas, size, t);
        break;

      // 63. Scan Frequency Drift
      case 'scan_frequency_drift':
        _paintScanFrequencyDrift(canvas, size, t);
        break;

      // 64. Fast Micro Digital Jitter
      case 'digital_jitter_fast':
        _paintFastMicroDigitalJitter(canvas, size, t);
        break;

      // 65. Horizontal Split Shudder
      case 'glitch_split_horiz':
        _paintHorizontalSplitShudder(canvas, size, t);
        break;

      // 66. Tape Crinkle Wrinkle
      case 'tape_crinkle_wrinkle':
        _paintTapeCrinkleWrinkle(canvas, size, t);
        break;

      // 67. Glitch Teleport In
      case 'glitch_teleport_in':
        _paintGlitchTeleportIn(canvas, size, t);
        break;

      // 68. Glitch Teleport Out
      case 'glitch_teleport_out':
        _paintGlitchTeleportOut(canvas, size, t);
        break;

      // 69. Neural Network Error Warp
      case 'neural_corrupt_warp':
        _paintNeuralCorruptWarp(canvas, size, t);
        break;

      // 70. Static Burst Finale
      case 'final_static_burst':
        _paintFinalStaticBurst(canvas, size, t);
        break;

      // 71. GPU Driver Crash Freeze
      case 'glitch_gpu_driver_crash':
        _paintGpuDriverCrash(canvas, size, t);
        break;

      // 72. Buffer Overflow Smear
      case 'glitch_buffer_overflow_smear':
        _paintBufferOverflowSmear(canvas, size, t);
        break;

      // 73. Sync Pulse Drop Jitter
      case 'glitch_sync_pulse_drop':
        _paintSyncPulseDropJitter(canvas, size, t);
        break;

      // 74. H.264 Macroblock Loss
      case 'glitch_h264_macroblock_loss':
        _paintH264MacroblockLoss(canvas, size, t);
        break;

      // 75. Matrix Rain Tear
      case 'glitch_matrix_digital_rain_tear':
        _paintMatrixRainTear(canvas, size, t);
        break;

      // 76. VRAM Artifact Corruption
      case 'glitch_vram_memory_leak_artifact':
        _paintVramArtifactCorruption(canvas, size, t);
        break;

      // 77. Analog Demodulator Noise
      case 'glitch_analog_demodulator_hum':
        _paintAnalogDemodulatorNoise(canvas, size, t);
        break;

      // 78. Quantum Decoherence Shift
      case 'glitch_quantum_decoherence':
        _paintQuantumDecoherenceShift(canvas, size, t);
        break;

      // 79. JPEG Spectral Quantization
      case 'glitch_jpeg_spectral_artifact':
        _paintJpegSpectralQuantization(canvas, size, t);
        break;

      // 80. Cracked LCD Bleed
      case 'glitch_cracked_lcd_screen_bleed':
        _paintCrackedLcdBleed(canvas, size, t);
        break;

      // 81. Parity Check Stutter
      case 'glitch_parity_check_error':
        _paintParityCheckStutter(canvas, size, t);
        break;

      // 82. YUV Chroma Subsample Drop
      case 'glitch_yuv_chroma_subsample_drop':
        _paintYuvChromaSubsampleDrop(canvas, size, t);
        break;

      // 83. HDMI Handshake Intermittent
      case 'glitch_hdmi_handshake_failure':
        _paintHdmiHandshakeFailure(canvas, size, t);
        break;

      // 84. Satellite Uplink Drop
      case 'glitch_satellite_uplink_loss':
        _paintSatelliteUplinkDrop(canvas, size, t);
        break;

      // 85. Corrupted NVRAM Boot
      case 'glitch_corrupted_nvram_boot':
        _paintCorruptedNvramBoot(canvas, size, t);
        break;

      // 86. CRT Degauss Coil Wobble
      case 'glitch_crt_degauss_coil_wobble':
        _paintCrtDegaussCoilWobble(canvas, size, t);
        break;

      // 87. RF Cross Modulation
      case 'glitch_rf_signal_cross_modulation':
        _paintRfCrossModulation(canvas, size, t);
        break;

      // 88. MPEG-2 Transport Stream Tear
      case 'glitch_mpeg2_transport_stream_tear':
        _paintMpeg2TransportStreamTear(canvas, size, t);
        break;

      // 89. Digital Ghosting Echo
      case 'glitch_digital_ghosting_echo':
        _paintDigitalGhostingEcho(canvas, size, t);
        break;

      // 90. Interlaced Comb Teeth
      case 'glitch_interlaced_comb_artifact':
        _paintInterlacedCombTeeth(canvas, size, t);
        break;

      // 91. Defective CCD Sensor Line
      case 'glitch_defective_ccd_sensor_line':
        _paintDefectiveCcdSensorLine(canvas, size, t);
        break;

      // 92. Rolling Shutter Jello
      case 'glitch_rolling_shutter_wobble':
        _paintRollingShutterJello(canvas, size, t);
        break;

      // 93. Static Discharge Spark
      case 'glitch_static_discharge_spark':
        _paintStaticDischargeSpark(canvas, size, t);
        break;

      // 94. A/V Desync Flutter
      case 'glitch_audio_video_desync_flutter':
        _paintAvDesyncFlutter(canvas, size, t);
        break;

      // 95. Magnetic Bit Rot Decay
      case 'glitch_bit_rot_decay':
        _paintMagneticBitRotDecay(canvas, size, t);
        break;

      // 96. Analog Tape Crease Pop
      case 'glitch_analog_tape_crease':
        _paintAnalogTapeCreasePop(canvas, size, t);
        break;

      // 97. Laserdisc Dropout Snow
      case 'glitch_laserdisc_dropout_snow':
        _paintLaserdiscDropoutSnow(canvas, size, t);
        break;

      // 98. Raster Beam Collapse
      case 'glitch_raster_beam_collapse':
        _paintRasterBeamCollapse(canvas, size, t);
        break;

      // 99. Color Burst Phase Jitter
      case 'glitch_color_burst_phase_jitter':
        _paintColorBurstPhaseJitter(canvas, size, t);
        break;

      // 100. Cyber Breach Data Glitch
      case 'glitch_zero_day_malware_glitch':
        _paintCyberBreachDataGlitch(canvas, size, t);
        break;

      default:
        break;
    }
  }

  // ===========================================================================
  // IMPLEMENTASI MENDALAM TIAP EFEK KINEMATIK
  // ===========================================================================

  void _paintRgbSplit(Canvas canvas, Size size, double t) {
    // Red dan Cyan offset horizontal stabil dan terukur
    final offset = (math.sin(t * math.pi * 4.0) * 8.0 + 10.0) * intensity;
    final rPaint = Paint()
      ..color = const Color(0xFFFF0055).withValues(alpha: 0.35 * intensity)
      ..blendMode = BlendMode.screen;
    final cPaint = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.35 * intensity)
      ..blendMode = BlendMode.screen;

    canvas.drawRect(Rect.fromLTWH(offset, 0, size.width, size.height), rPaint);
    canvas.drawRect(Rect.fromLTWH(-offset, 0, size.width, size.height), cPaint);
  }

  void _paintDigitalGlitch(Canvas canvas, Size size, double t) {
    final step = (t * 15.0).floor();
    final rand = math.Random(step * 31);
    final count = rand.nextInt(4) + 3;

    for (int i = 0; i < count; i++) {
      final bx = rand.nextDouble() * size.width * 0.7;
      final by = rand.nextDouble() * size.height * 0.8;
      final bw = rand.nextDouble() * (size.width * 0.4) + 20;
      final bh = rand.nextDouble() * 18.0 + 6.0;
      final shift = (rand.nextBool() ? 12.0 : -12.0) * intensity;

      final p = Paint()
        ..color = (rand.nextBool() ? const Color(0xFF00FFEA) : const Color(0xFFFF0077))
            .withValues(alpha: 0.45 * intensity);
      canvas.drawRect(Rect.fromLTWH(bx + shift, by, bw, bh), p);

      final border = Paint()
        ..color = Colors.white.withValues(alpha: 0.6 * intensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawRect(Rect.fromLTWH(bx + shift, by, bw, bh), border);
    }
  }

  void _paintVhsGlitch(Canvas canvas, Size size, double t) {
    // Jitter vertikal + distorsi gelombang pita horizontal
    final waveY = ((t * 2.0) % 1.0) * size.height;
    final pDistort = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFF00FFFF).withValues(alpha: 0.3 * intensity),
          Colors.white.withValues(alpha: 0.5 * intensity),
          const Color(0xFFFF0055).withValues(alpha: 0.3 * intensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, waveY - 15, size.width, 30));

    canvas.drawRect(Rect.fromLTWH(0, waveY - 15, size.width, 30), pDistort);

    // Garis noise tipis di bagian bawah pita
    final pNoise = Paint()..color = Colors.white.withValues(alpha: 0.4 * intensity);
    canvas.drawRect(Rect.fromLTWH(0, size.height - 8, size.width, 3), pNoise);
  }

  void _paintScanlines(Canvas canvas, Size size, double t) {
    // Garis CRT berjarak 3px, berdenyut halus bergerak perlahan ke bawah
    final rollOffset = (t * 20.0) % 3.0;
    final linePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.40 * intensity)
      ..strokeWidth = 1.2;

    for (double y = rollOffset; y < size.height; y += 3.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  void _paintPixelSortDown(Canvas canvas, Size size, double t) {
    // Lelehan vertikal ke bawah mengikuti alur progres
    final meltProgress = (t * 1.5) % 1.0;
    final sortPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.55 * intensity),
          const Color(0xFF00FFCC).withValues(alpha: 0.7 * intensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    const cols = 9;
    final colW = size.width / cols;
    for (int i = 0; i < cols; i++) {
      final seed = (i * 37) % 100 / 100.0;
      final startY = (meltProgress + seed) % 1.0 * (size.height * 0.7);
      final len = size.height * (0.35 + seed * 0.25);
      canvas.drawRect(Rect.fromLTWH(i * colW + 2, startY, colW - 3, len), sortPaint);
    }
  }

  void _paintPixelSortHorizontal(Canvas canvas, Size size, double t) {
    // Lelehan / tersapu horizontal ke kanan
    final sweepProgress = (t * 1.6) % 1.0;
    final sortPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.55 * intensity),
          const Color(0xFFFF0077).withValues(alpha: 0.7 * intensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    const rows = 8;
    final rowH = size.height / rows;
    for (int i = 0; i < rows; i++) {
      final seed = (i * 43) % 100 / 100.0;
      final startX = (sweepProgress + seed) % 1.0 * (size.width * 0.6);
      final len = size.width * (0.4 + seed * 0.3);
      canvas.drawRect(Rect.fromLTWH(startX, i * rowH + 2, len, rowH - 3), sortPaint);
    }
  }

  void _paintColorChannelOffset(Canvas canvas, Size size, double t) {
    // Displacement besar, arah diagonal memencar (Anaglyph kuat)
    final dist = (math.sin(t * math.pi * 3.0).abs() * 14.0 + 8.0) * intensity;
    final redP = Paint()
      ..color = const Color(0xFFFF0000).withValues(alpha: 0.40 * intensity)
      ..blendMode = BlendMode.screen;
    final greenP = Paint()
      ..color = const Color(0xFF00FF00).withValues(alpha: 0.35 * intensity)
      ..blendMode = BlendMode.screen;
    final blueP = Paint()
      ..color = const Color(0xFF0000FF).withValues(alpha: 0.40 * intensity)
      ..blendMode = BlendMode.screen;

    canvas.drawRect(Rect.fromLTWH(dist, dist * 0.5, size.width, size.height), redP);
    canvas.drawRect(Rect.fromLTWH(-dist * 0.5, -dist * 0.5, size.width, size.height), greenP);
    canvas.drawRect(Rect.fromLTWH(-dist, dist * 0.5, size.width, size.height), blueP);
  }

  void _paintBlockDisplacement(Canvas canvas, Size size, double t) {
    // Grid kotak tergeser acak tanpa menggeser kanvas utuh
    final step = (t * 8.0).floor();
    final rand = math.Random(step * 19);

    final pCyan = Paint()..color = const Color(0xFF00F0FF).withValues(alpha: 0.35 * intensity);
    final pMag = Paint()..color = const Color(0xFFFF0055).withValues(alpha: 0.35 * intensity);

    const rows = 5;
    final rH = size.height / rows;
    for (int r = 0; r < rows; r++) {
      if (rand.nextBool()) {
        final shift = (rand.nextDouble() * 20.0 - 10.0) * intensity;
        final p = (r % 2 == 0) ? pCyan : pMag;
        canvas.drawRect(Rect.fromLTWH(shift, r * rH, size.width, rH - 2), p);
      }
    }
  }

  void _paintDatamoshing(Canvas canvas, Size size, double t) {
    // Motion persistence & lumuran piksel dragging horizontal
    final p1 = Paint()..color = const Color(0x6600E5FF);
    final p2 = Paint()..color = const Color(0x66FF1744);
    final step = (t * 6.0).floor();

    for (int i = 0; i < 4; i++) {
      final y = ((step + i * 2) % 6) * (size.height / 6.0);
      final offset = (math.sin(i * 1.5 + t * 8.0) * 16.0) * intensity;
      final w = size.width * (0.35 + (i * 0.12));
      final h = size.height / 6.5;

      canvas.drawRect(Rect.fromLTWH(offset, y, w, h), (i % 2 == 0) ? p1 : p2);
    }
  }

  void _paintFrameDrop(Canvas canvas, Size size, double t) {
    // Normal -> Freeze -> Jump (Garis freeze flash indikator)
    final phase = (t * 6.0) % 1.0;
    final isStutter = phase > 0.65;

    if (isStutter) {
      final freezeTint = Paint()
        ..color = const Color(0x44FFFFFF);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), freezeTint);

      final lineP = Paint()
        ..color = Colors.white.withValues(alpha: 0.8 * intensity)
        ..strokeWidth = 2.0;
      canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), lineP);
    }
  }

  void _paintVhsTrackingNoise(Canvas canvas, Size size, double t) {
    // Pita tebal noise bergulir dari bawah ke atas layar
    final trackY = ((1.0 - t) * size.height * 1.25) - (size.height * 0.15);
    final bandH = 18.0;

    final pBand = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.75 * intensity),
          const Color(0xFF00E5FF).withValues(alpha: 0.45 * intensity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, trackY, size.width, bandH));

    canvas.drawRect(Rect.fromLTWH(0, trackY, size.width, bandH), pBand);

    // Titik titik derau tracking di dalam pita
    final rand = math.Random((t * 500).toInt());
    final dotP = Paint()..color = Colors.white.withValues(alpha: 0.9 * intensity);
    for (int i = 0; i < 40; i++) {
      final dx = rand.nextDouble() * size.width;
      final dy = trackY + (rand.nextDouble() * bandH);
      canvas.drawRect(Rect.fromLTWH(dx, dy, rand.nextDouble() * 6.0 + 2.0, 1.2), dotP);
    }
  }

  void _paintStaticSnow(Canvas canvas, Size size, double t) {
    // Semut TV salju acak frekuensi sangat tinggi (120 bintik)
    final rand = math.Random((t * 2000).toInt());
    final pDot = Paint()..color = Colors.white.withValues(alpha: 0.65 * intensity);
    final pDark = Paint()..color = Colors.black.withValues(alpha: 0.5 * intensity);

    for (int i = 0; i < 110; i++) {
      final dx = rand.nextDouble() * size.width;
      final dy = rand.nextDouble() * size.height;
      final w = rand.nextDouble() * 3.0 + 1.0;
      canvas.drawRect(Rect.fromLTWH(dx, dy, w, 1.2), rand.nextBool() ? pDot : pDark);
    }
  }

  void _paintAnalogSignalDrop(Canvas canvas, Size size, double t) {
    // Siklus: Normal -> Layar drop abu-abu -> Distorsi garis -> Pulih
    double dropAlpha = 0.0;
    if (t > 0.35 && t < 0.70) {
      dropAlpha = ((t - 0.35) / 0.15).clamp(0.0, 1.0);
      if (t > 0.55) {
        dropAlpha = (1.0 - (t - 0.55) / 0.15).clamp(0.0, 1.0);
      }
    }

    if (dropAlpha > 0.0) {
      final grayP = Paint()..color = Color.fromRGBO(30, 30, 35, dropAlpha * 0.85 * intensity);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), grayP);

      // Garis horizontal hilang transmisi
      final lineP = Paint()
        ..color = Colors.white.withValues(alpha: dropAlpha * 0.9 * intensity)
        ..strokeWidth = 2.0;
      canvas.drawLine(Offset(0, size.height * 0.48), Offset(size.width, size.height * 0.48), lineP);
    }
  }

  void _paintInterlacedTear(Canvas canvas, Size size, double t) {
    // Sisir bergigi horizontal interlaced 50i/60i
    final combShift = (math.sin(t * math.pi * 6.0) * 7.0 + 6.0) * intensity;
    final pEven = Paint()..color = const Color(0xFF00FFEA).withValues(alpha: 0.35 * intensity);

    for (double y = 0; y < size.height; y += 4.0) {
      // Garis genap bergeser ke kanan
      canvas.drawRect(Rect.fromLTWH(combShift, y, size.width, 2.0), pEven);
    }
  }

  void _paintCorruptedRam(Canvas canvas, Size size, double t) {
    // Blok memori GPU rusak warna magenta & hijau tajam bertebaran
    final step = (t * 10.0).floor();
    final rand = math.Random(step * 47);

    final pMag = Paint()..color = const Color(0xFFFF007F).withValues(alpha: 0.65 * intensity);
    final pGrn = Paint()..color = const Color(0xFF00FF66).withValues(alpha: 0.65 * intensity);

    for (int i = 0; i < 6; i++) {
      final rx = (rand.nextDouble() * size.width * 0.8);
      final ry = (rand.nextDouble() * size.height * 0.8);
      final rw = rand.nextDouble() * 24.0 + 10.0;
      final rh = rand.nextDouble() * 12.0 + 6.0;
      canvas.drawRect(Rect.fromLTWH(rx, ry, rw, rh), i % 2 == 0 ? pMag : pGrn);
    }
  }

  void _paintChromaticJitter(Canvas canvas, Size size, double t) {
    // Jitter kroma bergerak liar frekuensi 24Hz
    final jx = (math.sin(t * math.pi * 24.0) * 11.0) * intensity;
    final jy = (math.cos(t * math.pi * 20.0) * 6.0) * intensity;

    final pRed = Paint()
      ..color = const Color(0xFFFF1744).withValues(alpha: 0.4 * intensity)
      ..blendMode = BlendMode.screen;
    final pBlue = Paint()
      ..color = const Color(0xFF2979FF).withValues(alpha: 0.4 * intensity)
      ..blendMode = BlendMode.screen;

    canvas.drawRect(Rect.fromLTWH(jx, jy, size.width, size.height), pRed);
    canvas.drawRect(Rect.fromLTWH(-jx, -jy, size.width, size.height), pBlue);
  }

  void _paintGlitchFlashIn(Canvas canvas, Size size, double t) {
    // DISTORTED -> FLASH -> GLITCH FRAGMENTS -> NORMAL
    if (t < 0.45) {
      final p = t / 0.45;
      final flashAlpha = (1.0 - p) * 0.85 * intensity;
      final pFlash = Paint()..color = Colors.white.withValues(alpha: flashAlpha);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), pFlash);

      // Fragmen blok
      final pFrag = Paint()..color = const Color(0xFF00E5FF).withValues(alpha: (1.0 - p) * 0.6 * intensity);
      canvas.drawRect(Rect.fromLTWH((1.0 - p) * 20.0, size.height * 0.3, size.width * 0.6, 12), pFrag);
    }
  }

  void _paintGlitchFlashOut(Canvas canvas, Size size, double t) {
    // NORMAL -> GLITCH -> FRAGMENT -> FLASH/NOISE -> DISAPPEAR
    if (t > 0.55) {
      final p = (t - 0.55) / 0.45;
      final flashAlpha = (p * 0.9 * intensity).clamp(0.0, 1.0);
      final pFlash = Paint()..color = Colors.white.withValues(alpha: flashAlpha);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), pFlash);

      // Fragmen blok
      final pFrag = Paint()..color = const Color(0xFFFF0055).withValues(alpha: p * 0.7 * intensity);
      canvas.drawRect(Rect.fromLTWH(-p * 25.0, size.height * 0.6, size.width * 0.7, 14), pFrag);
    }
  }

  void _paintHorizontalSliceTear(Canvas canvas, Size size, double t) {
    // Belahan slice horizontal: slice atas ke kiri, slice tengah ke kanan, slice bawah ke kiri
    final shift = (math.sin(t * math.pi * 5.0) * 16.0) * intensity;
    final pCyan = Paint()..color = const Color(0xFF00F0FF).withValues(alpha: 0.35 * intensity);
    final pRed = Paint()..color = const Color(0xFFFF0055).withValues(alpha: 0.35 * intensity);

    final h3 = size.height / 3.0;
    // Slice 1 (Top) geser kiri
    canvas.drawRect(Rect.fromLTWH(-shift, 0, size.width, h3), pCyan);
    // Slice 2 (Mid) geser kanan
    canvas.drawRect(Rect.fromLTWH(shift, h3, size.width, h3), pRed);
    // Slice 3 (Bot) geser kiri
    canvas.drawRect(Rect.fromLTWH(-shift * 0.8, h3 * 2, size.width, h3), pCyan);
  }

  void _paintVerticalSyncRoll(Canvas canvas, Size size, double t) {
    // Gambar bergulir vertikal terus-menerus (V-Hold bar hitam melintas)
    final rollY = (t * size.height * 2.0) % size.height;
    final vBarPaint = Paint()..color = Colors.black.withValues(alpha: 0.85 * intensity);

    canvas.drawRect(Rect.fromLTWH(0, rollY, size.width, 16.0), vBarPaint);

    final lineP = Paint()
      ..color = Colors.white.withValues(alpha: 0.7 * intensity)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, rollY), Offset(size.width, rollY), lineP);
    canvas.drawLine(Offset(0, rollY + 16.0), Offset(size.width, rollY + 16.0), lineP);
  }

  void _paintAntennaGhost(Canvas canvas, Size size, double t) {
    // 2 Bayangan transparan tertinggal di sebelah kanan subject
    final g1Paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28 * intensity)
      ..blendMode = BlendMode.screen;
    final g2Paint = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.20 * intensity)
      ..blendMode = BlendMode.screen;

    canvas.drawRect(Rect.fromLTWH(18.0 * intensity, 0, size.width, size.height), g1Paint);
    canvas.drawRect(Rect.fromLTWH(34.0 * intensity, 0, size.width, size.height), g2Paint);
  }

  void _paintLowBitrateMacro(Canvas canvas, Size size, double t) {
    // Grid kotak makroblok 8x8 besar kasar
    final pBox = Paint()
      ..color = Colors.black.withValues(alpha: 0.32 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const blockSize = 20.0;
    for (double x = 0; x < size.width; x += blockSize) {
      for (double y = 0; y < size.height; y += blockSize) {
        canvas.drawRect(Rect.fromLTWH(x, y, blockSize, blockSize), pBox);
      }
    }
  }

  void _paintCyberMatrix(Canvas canvas, Size size, double t) {
    // Aliran biner / karakter digital hijau meluncur vertikal
    final greenPaint = Paint()
      ..color = const Color(0xFF00FF41).withValues(alpha: 0.75 * intensity)
      ..strokeWidth = 1.5;

    const cols = 8;
    final colW = size.width / cols;
    for (int i = 0; i < cols; i++) {
      final seed = (i * 29) % 100 / 100.0;
      final startY = ((t * 1.8 + seed) % 1.0) * size.height;
      for (int k = 0; k < 4; k++) {
        final dotY = (startY + k * 8.0) % size.height;
        canvas.drawCircle(Offset(i * colW + colW * 0.5, dotY), 1.8, greenPaint);
      }
    }
  }

  void _paintTapeRewind(Canvas canvas, Size size, double t) {
    // Garis kecepatan horizontal melesat cepat ke kiri ala Rewind
    final streakProgress = (1.0 - t * 3.5) % 1.0;
    final pStreak = Paint()
      ..color = Colors.white.withValues(alpha: 0.65 * intensity)
      ..strokeWidth = 2.0;

    for (int i = 0; i < 4; i++) {
      final y = size.height * (0.2 + i * 0.2);
      final x = streakProgress * size.width;
      canvas.drawLine(Offset(x, y), Offset((x + size.width * 0.5) % size.width, y), pStreak);
    }
  }

  void _paintBrokenCodec(Canvas canvas, Size size, double t) {
    // Setengah layar (kiri) freeze, setengah layar (kanan) bergeser distorsi
    final pFrozen = Paint()..color = const Color(0x33000000);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * 0.5, size.height), pFrozen);

    final shiftRight = (math.sin(t * math.pi * 4.0) * 12.0) * intensity;
    final pGlitch = Paint()..color = const Color(0x44FF0055);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.5 + shiftRight, size.height * 0.3, size.width * 0.5, size.height * 0.4), pGlitch);
  }

  void _paintRadialRgb(Canvas canvas, Size size, double t) {
    // Pemisahan warna memancar radial dari tengah keluar
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final r = (math.sin(t * math.pi * 3.0).abs() * 25.0 + 15.0) * intensity;

    final ringR = Paint()
      ..color = const Color(0xFFFF0055).withValues(alpha: 0.35 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    final ringB = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.35 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    canvas.drawCircle(center, r + 8, ringR);
    canvas.drawCircle(center, r, ringB);
  }

  void _paintAvSyncJitter(Canvas canvas, Size size, double t) {
    // Spike lompatan 1-frame diskrit tajam
    final step = (t * 12.0).floor();
    final isSpike = (step % 5 == 0);

    if (isSpike) {
      final pSpike = Paint()..color = const Color(0x66FF0055);
      canvas.drawRect(Rect.fromLTWH(10.0 * intensity, -6.0 * intensity, size.width, size.height), pSpike);
    }
  }

  void _paintNeonSlice(Canvas canvas, Size size, double t) {
    // Irisan neon cyan & pink berpendar menyala terang
    final sliceY = ((t * 1.5) % 1.0) * size.height;
    final pGlow = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF00F0FF).withValues(alpha: 0.85 * intensity),
          const Color(0xFFFF007F).withValues(alpha: 0.85 * intensity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, sliceY - 6, size.width, 12));

    canvas.drawRect(Rect.fromLTWH(0, sliceY - 6, size.width, 12), pGlow);

    final pCore = Paint()
      ..color = Colors.white.withValues(alpha: 0.95 * intensity)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, sliceY), Offset(size.width, sliceY), pCore);
  }

  void _paintQuantizationNoise(Canvas canvas, Size size, double t) {
    // Granular digital stepping & derau matematis
    final rand = math.Random((t * 800).toInt());
    final pStep = Paint()..color = const Color(0xFF00FFCC).withValues(alpha: 0.3 * intensity);

    for (int i = 0; i < 30; i++) {
      final x = (rand.nextInt(10) / 10.0) * size.width;
      final y = (rand.nextInt(10) / 10.0) * size.height;
      canvas.drawRect(Rect.fromLTWH(x, y, 12, 12), pStep);
    }
  }

  void _paintColorNegativeSpike(Canvas canvas, Size size, double t) {
    // Invert warna 2-frame: Normal -> Negatif -> Normal
    final step = (t * 8.0).floor();
    final isInvert = (step % 4 == 0);

    if (isInvert) {
      final pInvert = Paint()
        ..color = Colors.white
        ..blendMode = BlendMode.difference;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), pInvert);
    }
  }

  // ===========================================================================
  // BATCH 2 IMPLEMENTATIONS (EFFECTS 31 - 60)
  // ===========================================================================

  void _paint60HzFlicker(Canvas canvas, Size size, double t) {
    // 31. 60Hz AC Screen Flicker: Garis fluktuasi kecerahan AC bergantian cepat
    final cycle = (t * 60.0).floor() % 2;
    if (cycle == 0) {
      final pDark = Paint()
        ..color = Colors.black.withValues(alpha: 0.18 * intensity);
      // Garis interlaced cepat khas AC
      for (double y = 0; y < size.height; y += 4.0) {
        canvas.drawRect(Rect.fromLTWH(0, y, size.width, 2.0), pDark);
      }
    } else {
      final pBright = Paint()
        ..color = Colors.white.withValues(alpha: 0.12 * intensity)
        ..blendMode = BlendMode.screen;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), pBright);
    }
  }

  void _paintTapePauseWobble(Canvas canvas, Size size, double t) {
    // 32. Tape Pause Wobble: Garis distorsi jeda pita magnetik di tengah dengan getaran vertikal
    final bandY = size.height * 0.48 + math.sin(t * math.pi * 12.0) * (size.height * 0.05);
    final pNoise = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.65 * intensity),
          const Color(0xFF00E5FF).withValues(alpha: 0.5 * intensity),
          Colors.black.withValues(alpha: 0.8 * intensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, bandY - 14, size.width, 28));

    canvas.drawRect(Rect.fromLTWH(0, bandY - 14, size.width, 28), pNoise);

    // Titik-titik static khas pause tape
    final rand = math.Random((t * 200).toInt());
    final pStatic = Paint()..color = Colors.white.withValues(alpha: 0.8 * intensity);
    for (int i = 0; i < 20; i++) {
      final sx = rand.nextDouble() * size.width;
      final sw = 4.0 + rand.nextDouble() * 16.0;
      canvas.drawRect(Rect.fromLTWH(sx, bandY - 4 + rand.nextDouble() * 8, sw, 1.5), pStatic);
    }
  }

  void _paintGlitchDissolve(Canvas canvas, Size size, double t) {
    // 33. Glitch Particle Dissolve: Subject pecah berhamburan menjadi partikel debu digital
    final rand = math.Random(1337);
    final pParticle = Paint();
    final count = (40 + (t * 80).toInt()).clamp(40, 120);

    for (int i = 0; i < count; i++) {
      final origX = rand.nextDouble() * size.width;
      final origY = rand.nextDouble() * size.height;
      // Berpencar keluar
      final angle = rand.nextDouble() * math.pi * 2;
      final dist = (t * 28.0 + rand.nextDouble() * 12.0) * intensity;
      final px = (origX + math.cos(angle) * dist) % size.width;
      final py = (origY + math.sin(angle) * dist) % size.height;
      final pSize = 1.5 + rand.nextDouble() * 3.5;

      pParticle.color = (i % 3 == 0
              ? const Color(0xFF00FFFF)
              : (i % 3 == 1 ? const Color(0xFFFF0055) : Colors.white))
          .withValues(alpha: (1.0 - t * 0.6) * 0.75 * intensity);

      canvas.drawRect(Rect.fromLTWH(px, py, pSize, pSize), pParticle);
    }
  }

  void _paintHologramBreakdown(Canvas canvas, Size size, double t) {
    // 34. Hologram Breakdown: Kisi hologram biru transparan goyah & rusak
    final pMesh = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: (0.25 + math.sin(t * math.pi * 10.0).abs() * 0.25) * intensity)
      ..strokeWidth = 1.0;

    // Garis horizontal kisi hologram
    for (double y = 0; y < size.height; y += 6.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), pMesh);
    }

    // Distorsi proyeksi hologram
    final hSkew = math.sin(t * math.pi * 8.0) * 12.0 * intensity;
    final pHoloGlow = Paint()
      ..color = const Color(0xFF0077FF).withValues(alpha: 0.2 * intensity)
      ..blendMode = BlendMode.screen;
    canvas.drawRect(Rect.fromLTWH(hSkew, 0, size.width, size.height), pHoloGlow);
  }

  void _paintSatelliteFeedLoss(Canvas canvas, Size size, double t) {
    // 35. Satellite Feed Loss: Blok beku abu-abu & hilangnya frame transmisi
    final isLoss = (t > 0.28 && t < 0.72);
    if (!isLoss) return;

    final rand = math.Random((t * 24).toInt());
    final pBlock = Paint();

    for (int i = 0; i < 8; i++) {
      final bx = rand.nextInt(4) * (size.width / 4);
      final by = rand.nextInt(5) * (size.height / 5);
      final bw = size.width / 4;
      final bh = size.height / 5;

      pBlock.color = (i % 2 == 0 ? const Color(0xFF7A8A99) : const Color(0xFF4A5568))
          .withValues(alpha: 0.85 * intensity);
      canvas.drawRect(Rect.fromLTWH(bx, by, bw, bh), pBlock);

      // Garis transmisi terputus
      final pLine = Paint()..color = Colors.white.withValues(alpha: 0.6 * intensity);
      canvas.drawLine(Offset(bx, by + bh / 2), Offset(bx + bw, by + bh / 2), pLine);
    }
  }

  void _paintGlitchZoomPop(Canvas canvas, Size size, double t) {
    // 36. Glitch Zoom Pop: Hentakan sudut pecahan radial saat zoom meledak
    final popPhase = math.pow(math.sin(t * math.pi * 2.0).abs(), 4.0).toDouble();
    if (popPhase < 0.15) return;

    final center = Offset(size.width / 2, size.height / 2);
    final pPop = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = const Color(0xFFFF3366).withValues(alpha: popPhase * 0.8 * intensity);

    for (int r = 1; r <= 3; r++) {
      final radius = (popPhase * (size.width * 0.4) * (r / 3.0));
      canvas.drawCircle(center, radius, pPop);
    }

    // Irisan sudut pop
    final pCorner = Paint()..color = const Color(0xFF00FFCC).withValues(alpha: popPhase * 0.5 * intensity);
    canvas.drawRect(Rect.fromLTWH(0, 0, 18 * intensity, 18 * intensity), pCorner);
    canvas.drawRect(Rect.fromLTWH(size.width - 18 * intensity, size.height - 18 * intensity, 18 * intensity, 18 * intensity), pCorner);
  }

  void _paintRgbStrobeJitter(Canvas canvas, Size size, double t) {
    // 37. RGB Strobe Jitter: Strobo temporal warna Red -> Green -> Blue bergantian agresif
    final s = (t * 24.0).floor() % 3;
    final Color strobeColor;
    if (s == 0) {
      strobeColor = const Color(0xFFFF0033);
    } else if (s == 1) {
      strobeColor = const Color(0xFF00FF44);
    } else {
      strobeColor = const Color(0xFF0044FF);
    }

    final pStrobe = Paint()
      ..color = strobeColor.withValues(alpha: 0.32 * intensity)
      ..blendMode = BlendMode.screen;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), pStrobe);

    // Micro jitter bar
    final pBar = Paint()..color = Colors.white.withValues(alpha: 0.45 * intensity);
    final barY = ((t * 4.0) % 1.0) * size.height;
    canvas.drawRect(Rect.fromLTWH(0, barY, size.width, 3), pBar);
  }

  void _paintDigitalBanding(Canvas canvas, Size size, double t) {
    // 38. Digital Banding Gradient: Kuantisasi bertingkat berundak gelap ke terang
    final bands = 7;
    final bandH = size.height / bands;
    final pBand = Paint()..blendMode = BlendMode.multiply;

    for (int i = 0; i < bands; i++) {
      final shade = ((i / bands) + (t * 0.2)) % 1.0;
      final alpha = (0.15 + (shade * 0.35)) * intensity;
      pBand.color = Color.fromARGB((alpha * 255).toInt(), 10, 25, 45);
      canvas.drawRect(Rect.fromLTWH(0, i * bandH, size.width, bandH - 1.0), pBand);
    }
  }

  void _paintGlitchWaveWarp(Canvas canvas, Size size, double t) {
    // 39. Glitch Waveform Warp: Meliuk sinusoidal horizontal kontinu
    final pWave = Paint()
      ..color = const Color(0xFF00FFAA).withValues(alpha: 0.35 * intensity)
      ..blendMode = BlendMode.screen;

    final slices = 12;
    final sliceH = size.height / slices;
    for (int i = 0; i < slices; i++) {
      final shift = math.sin((t * 6.0) + (i * 0.8)) * 14.0 * intensity;
      canvas.drawRect(Rect.fromLTWH(shift, i * sliceH, size.width, sliceH * 0.8), pWave);
    }
  }

  void _paintTapeHeadClog(Canvas canvas, Size size, double t) {
    // 40. Tape Head Clog Dust: Kotoran debu serat tebal menyumbat pembaca pita
    final rand = math.Random(4040);
    final pDust = Paint()..color = const Color(0xDD111111);
    final pWhiteDust = Paint()..color = Colors.white.withValues(alpha: 0.7 * intensity);

    // Serat vertikal kotor menetap di head
    for (int i = 0; i < 6; i++) {
      final dx = (rand.nextDouble() * size.width + math.sin(t * math.pi * 4.0 + i) * 3.0) % size.width;
      final dy = rand.nextDouble() * (size.height * 0.4);
      final len = 20.0 + rand.nextDouble() * 50.0;
      canvas.drawRect(Rect.fromLTWH(dx, dy, 2.5, len), i % 2 == 0 ? pDust : pWhiteDust);
    }

    // Sapuan abu-abu kotoran magnetik
    final clogY = size.height * 0.65;
    final pSmudge = Paint()
      ..shader = LinearGradient(
        colors: [Colors.black.withValues(alpha: 0.45 * intensity), Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, clogY, size.width, 24));
    canvas.drawRect(Rect.fromLTWH(0, clogY, size.width, 24), pSmudge);
  }

  void _paintQuantumEntanglement(Canvas canvas, Size size, double t) {
    // 41. Quantum Entanglement Tear: Sobekan dimensi siluet ganda terbelah non-linear
    final tearY = size.height * 0.5 + math.sin(t * math.pi * 4.0) * 20.0;
    final pTear = Paint()
      ..color = const Color(0xFFD600FF).withValues(alpha: 0.45 * intensity)
      ..blendMode = BlendMode.difference;

    final path = Path()
      ..moveTo(0, tearY - 10)
      ..lineTo(size.width * 0.35, tearY + 15)
      ..lineTo(size.width * 0.65, tearY - 20)
      ..lineTo(size.width, tearY + 5)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, pTear);

    // Garis singularity
    final pLine = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.8 * intensity)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(0, tearY), Offset(size.width, tearY), pLine);
  }

  void _paintCircuitShortSpark(Canvas canvas, Size size, double t) {
    // 42. Circuit Short Spark: Bunga api korsleting listrik tajam dan terang
    final isSpark = math.sin(t * math.pi * 20.0) > 0.65;
    if (!isSpark) return;

    final rand = math.Random((t * 999).toInt());
    final origin = Offset(size.width * (0.2 + rand.nextDouble() * 0.6), size.height * (0.3 + rand.nextDouble() * 0.4));

    final pSpark = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final pGlow = Paint()
      ..color = const Color(0xFFFF9900).withValues(alpha: 0.85 * intensity)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final angle = (i / 8.0) * math.pi * 2 + (rand.nextDouble() - 0.5);
      final len = 12.0 + rand.nextDouble() * 22.0 * intensity;
      final end = Offset(origin.dx + math.cos(angle) * len, origin.dy + math.sin(angle) * len);
      canvas.drawLine(origin, end, pGlow);
      canvas.drawLine(origin, end, pSpark);
    }
  }

  void _paintLcdPixelDead(Canvas canvas, Size size, double t) {
    // 43. Dead Pixel Cluster Wave: Gugusan bintik piksel mati (subpixel merah/hijau/biru macet)
    final rand = math.Random(4343);
    final clusters = [
      Offset(size.width * 0.25, size.height * 0.3),
      Offset(size.width * 0.68, size.height * 0.62),
      Offset(size.width * 0.45, size.height * 0.78),
    ];

    for (final cluster in clusters) {
      for (int i = 0; i < 12; i++) {
        final px = cluster.dx + (rand.nextDouble() - 0.5) * 16.0;
        final py = cluster.dy + (rand.nextDouble() - 0.5) * 16.0;
        final pPixel = Paint()
          ..color = (i % 3 == 0 ? const Color(0xFFFF0033) : (i % 3 == 1 ? const Color(0xFF00FF00) : const Color(0xFF0044FF)))
              .withValues(alpha: 0.9 * intensity);
        canvas.drawRect(Rect.fromLTWH(px, py, 2.0, 2.0), pPixel);
      }
    }
  }

  void _paintBufferOverflowJunk(Canvas canvas, Size size, double t) {
    // 44. Buffer Overflow Dump: String heksadesimal mentah meluap ke layar
    final rand = math.Random((t * 15).toInt());
    final hexTokens = ['0xDEAD', '0xBEEF', '0x8048', '0x7FFF', 'SEG_V', 'NULL', '0x00FF', 'ERR_44'];

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int row = 0; row < 5; row++) {
      final y = size.height * (0.2 + row * 0.14);
      final hexStr = '${hexTokens[rand.nextInt(hexTokens.length)]} ${hexTokens[rand.nextInt(hexTokens.length)]}';
      textPainter.text = TextSpan(
        text: hexStr,
        style: TextStyle(
          color: const Color(0xFF00FF66).withValues(alpha: 0.75 * intensity),
          fontFamily: 'monospace',
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.black.withValues(alpha: 0.6),
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width * 0.15 + (rand.nextDouble() * 10.0), y));
    }
  }

  void _paintVhsColorBleed(Canvas canvas, Size size, double t) {
    // 45. VHS Chrominance Bleed: Warna kroma merah & oranye meluber melebar ke samping
    final bleedDist = (8.0 + math.sin(t * math.pi * 4.0).abs() * 14.0) * intensity;
    final pRedHalo = Paint()
      ..color = const Color(0xFFFF2200).withValues(alpha: 0.35 * intensity)
      ..blendMode = BlendMode.screen;
    final pCyanHalo = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.25 * intensity)
      ..blendMode = BlendMode.screen;

    canvas.drawRect(Rect.fromLTWH(bleedDist, 0, size.width, size.height), pRedHalo);
    canvas.drawRect(Rect.fromLTWH(-bleedDist * 0.6, 0, size.width, size.height), pCyanHalo);
  }

  void _paintRasterBeamSkew(Canvas canvas, Size size, double t) {
    // 46. Raster Beam Skew: Garis berkas elektron miring trapesium
    final skewAngle = math.sin(t * math.pi * 6.0) * 16.0 * intensity;
    final pBeam = Paint()
      ..color = Colors.white.withValues(alpha: 0.3 * intensity)
      ..strokeWidth = 2.0;

    for (double y = 0; y < size.height; y += 8.0) {
      final slant = (y / size.height) * skewAngle;
      canvas.drawLine(Offset(0, y), Offset(size.width + slant, y), pBeam);
    }
  }

  void _paintDeepFriedMeme(Canvas canvas, Size size, double t) {
    // 47. Deep Fried Color Crush: Saturasi ekstrem kuning terbakar & pendaran kontras
    final pFried = Paint()
      ..color = const Color(0xFFFFCC00).withValues(alpha: 0.4 * intensity)
      ..blendMode = BlendMode.colorDodge;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), pFried);

    final pRedHot = Paint()
      ..color = const Color(0xFFFF0033).withValues(alpha: 0.25 * intensity)
      ..blendMode = BlendMode.overlay;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), pRedHot);
  }

  void _paintGlitchBounceIn(Canvas canvas, Size size, double t) {
    // 48. Glitch Bounce In: Potongan blok horizontal yang menyatu memantul ke tengah
    if (t > 0.8) return; // selesai masuk
    final rand = math.Random(48);
    final pSlice = Paint()..color = const Color(0xFF00F0FF).withValues(alpha: (1.0 - t) * 0.6 * intensity);

    final slices = 6;
    final h = size.height / slices;
    for (int i = 0; i < slices; i++) {
      final jitter = (rand.nextDouble() - 0.5) * 10.0;
      final dir = (i % 2 == 0 ? 1.0 : -1.0);
      final offset = (dir * (1.0 - t) * 40.0 + jitter) * intensity;
      canvas.drawRect(Rect.fromLTWH(offset, i * h, size.width, h - 2), pSlice);
    }
  }

  void _paintGlitchDropOut(Canvas canvas, Size size, double t) {
    // 49. Glitch Drop Out: Potongan runtuh ke bawah diiringi garis statik sinyal hilang
    if (t < 0.3) return; // mulai jatuh
    final prog = (t - 0.3) / 0.7;
    final pDrop = Paint()..color = Colors.black.withValues(alpha: prog * 0.75 * intensity);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * prog), pDrop);

    final pStatic = Paint()..color = Colors.white.withValues(alpha: 0.6 * intensity);
    final dropLine = size.height * prog;
    canvas.drawLine(Offset(0, dropLine), Offset(size.width, dropLine), pStatic);
  }

  void _paintWireframeWireTear(Canvas canvas, Size size, double t) {
    // 50. Wireframe Mesh Tear: Garis jaring 3D terdistorsi robek di layar
    final pWire = Paint()
      ..color = const Color(0xFF39FF14).withValues(alpha: 0.6 * intensity)
      ..strokeWidth = 1.0;

    final cols = 6;
    final rows = 6;
    final colW = size.width / cols;
    final rowH = size.height / rows;

    for (int r = 0; r <= rows; r++) {
      final tearOffset = (r == 3) ? math.sin(t * math.pi * 8.0) * 15.0 * intensity : 0.0;
      canvas.drawLine(Offset(0, r * rowH + tearOffset), Offset(size.width, r * rowH - tearOffset), pWire);
    }
    for (int c = 0; c <= cols; c++) {
      canvas.drawLine(Offset(c * colW, 0), Offset(c * colW, size.height), pWire);
    }
  }

  void _paintGlitchScanSweep(Canvas canvas, Size size, double t) {
    // 51. Glitch Scanline Sweep: Bar pemindai tebal bergerak menurun secara teratur
    final sweepY = ((t * 1.5) % 1.0) * size.height;
    final pSweep = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFF00FFCC).withValues(alpha: 0.75 * intensity),
          Colors.white.withValues(alpha: 0.9 * intensity),
          const Color(0xFF00FFCC).withValues(alpha: 0.75 * intensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, sweepY - 15, size.width, 30));

    canvas.drawRect(Rect.fromLTWH(0, sweepY - 15, size.width, 30), pSweep);
  }

  void _paintSensorOverheatNoise(Canvas canvas, Size size, double t) {
    // 52. Sensor Overheat Noise: Titik derau panas ungu/magenta di sensor kamera
    final rand = math.Random((t * 50).toInt());
    final pNoise = Paint()
      ..color = const Color(0xFFFF00AA).withValues(alpha: 0.38 * intensity)
      ..blendMode = BlendMode.screen;

    // Titik terkonsentrasi di tengah sensor
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 40; i++) {
      final rad = rand.nextDouble() * (size.width * 0.35);
      final ang = rand.nextDouble() * math.pi * 2;
      final px = center.dx + math.cos(ang) * rad;
      final py = center.dy + math.sin(ang) * rad;
      canvas.drawRect(Rect.fromLTWH(px, py, 3.0, 3.0), pNoise);
    }
  }

  void _paintBrokenHdmiSparkle(Canvas canvas, Size size, double t) {
    // 53. Bad HDMI Sparkle Salt: Bintik salju garam piksel putih tunggal akibat kabel rusak
    final rand = math.Random((t * 120).toInt());
    final pSparkle = Paint()..color = Colors.white.withValues(alpha: 0.95 * intensity);

    for (int i = 0; i < 50; i++) {
      final px = rand.nextDouble() * size.width;
      final py = rand.nextDouble() * size.height;
      canvas.drawRect(Rect.fromLTWH(px, py, 1.5, 1.5), pSparkle);
    }
  }

  void _paintPacketLossDrop(Canvas canvas, Size size, double t) {
    // 54. Packet Loss Frame Drop: Blok patah horizontal membeku saat packet stream hilang
    final isLoss = (t > 0.35 && t < 0.7);
    if (!isLoss) return;

    final pDrop = Paint()..color = const Color(0xFF223344).withValues(alpha: 0.8 * intensity);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.3, size.width, size.height * 0.25), pDrop);

    final pRedText = Paint()..color = const Color(0xFFFF0055).withValues(alpha: 0.9 * intensity);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.1, size.height * 0.35, 30, 4), pRedText);
  }

  void _paintNeonDistortionFuzz(Canvas canvas, Size size, double t) {
    // 55. Neon Distortion Fuzz: Getaran fuzzy aura neon cyan-magenta berpendar tebal di tepi
    final pBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.65 * intensity)
      ..blendMode = BlendMode.screen;

    canvas.drawRect(Rect.fromLTWH(2, 2, size.width - 4, size.height - 4), pBorder);

    final pFuzz = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = const Color(0xFFFF007F).withValues(alpha: (0.4 + math.sin(t * math.pi * 12.0).abs() * 0.3) * intensity)
      ..blendMode = BlendMode.screen;

    canvas.drawRect(Rect.fromLTWH(4, 4, size.width - 8, size.height - 8), pFuzz);
  }

  void _paintPhosphorGhostTrail(Canvas canvas, Size size, double t) {
    // 56. Phosphor Persistence Trail: Siluet bayangan fosfor hijau tertinggal di belakang
    final pGhost = Paint()
      ..color = const Color(0xFF00FF44).withValues(alpha: 0.35 * intensity)
      ..blendMode = BlendMode.screen;

    final trailOffset = math.sin(t * math.pi * 3.0) * 12.0 * intensity;
    canvas.drawRect(Rect.fromLTWH(trailOffset, 0, size.width, size.height), pGhost);

    // Jejak pendaran kedua yang lebih tipis
    final pGhost2 = Paint()
      ..color = const Color(0xFF008822).withValues(alpha: 0.2 * intensity)
      ..blendMode = BlendMode.screen;
    canvas.drawRect(Rect.fromLTWH(trailOffset * 1.6, 0, size.width, size.height), pGhost2);
  }

  void _paintAnamorphicGlitchStreak(Canvas canvas, Size size, double t) {
    // 57. Anamorphic Flare Tear: Garis pendaran biru sinematik horizontal retak-retak
    final streakY = size.height * 0.5 + math.sin(t * math.pi * 2.0) * 8.0;
    final pStreak = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF0099FF).withValues(alpha: 0.85 * intensity),
          Colors.white,
          const Color(0xFF0099FF).withValues(alpha: 0.85 * intensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, streakY - 3, size.width, 6));

    canvas.drawRect(Rect.fromLTWH(0, streakY - 3, size.width, 6), pStreak);

    // Retakan micro gap di dalam streak
    final pGap = Paint()..color = Colors.black.withValues(alpha: 0.9);
    final gapX = ((t * 3.0) % 1.0) * size.width;
    canvas.drawRect(Rect.fromLTWH(gapX, streakY - 4, 10, 8), pGap);
  }

  void _paintCyberStutterStep(Canvas canvas, Size size, double t) {
    // 58. Cyber Stutter Step: 4 ketukan patah-patah mekanik kotak grid
    final step = (t * 4.0).floor() % 4;
    final pStep = Paint()
      ..color = const Color(0xFF00FFAA).withValues(alpha: 0.35 * intensity)
      ..blendMode = BlendMode.screen;

    final stepW = size.width / 4;
    canvas.drawRect(Rect.fromLTWH(step * stepW, 0, stepW, size.height), pStep);

    // Reticle penanda ketukan
    final pReticle = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.8 * intensity);
    canvas.drawRect(Rect.fromLTWH(step * stepW + 4, 4, stepW - 8, size.height - 8), pReticle);
  }

  void _paintSubZeroFreezeGlitch(Canvas canvas, Size size, double t) {
    // 59. Frost Glitch Freeze: Retakan kristal es membeku di atas visual sebelum pecah
    final isFreeze = (t > 0.25 && t < 0.8);
    if (!isFreeze) return;

    final pFrost = Paint()
      ..color = const Color(0xFFCCFFFF).withValues(alpha: 0.35 * intensity)
      ..blendMode = BlendMode.screen;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), pFrost);

    // Pola kristal es / retakan tajam
    final pCrack = Paint()
      ..color = Colors.white.withValues(alpha: 0.8 * intensity)
      ..strokeWidth = 1.5;

    final center = Offset(size.width * 0.5, size.height * 0.45);
    for (int i = 0; i < 6; i++) {
      final ang = (i / 6.0) * math.pi * 2;
      final rad = size.width * 0.35;
      final end = Offset(center.dx + math.cos(ang) * rad, center.dy + math.sin(ang) * rad);
      canvas.drawLine(center, end, pCrack);
      // Cabang es
      final mid = Offset(center.dx + math.cos(ang) * rad * 0.5, center.dy + math.sin(ang) * rad * 0.5);
      final branch = Offset(mid.dx + math.cos(ang + 0.6) * 15.0, mid.dy + math.sin(ang + 0.6) * 15.0);
      canvas.drawLine(mid, branch, pCrack);
    }
  }

  void _paintRfInterferenceMoire(Canvas canvas, Size size, double t) {
    // 60. RF Moiré Interference: Lingkaran konsentris interferensi gelombang radio
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final pMoire = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF00FF66).withValues(alpha: 0.45 * intensity);

    final rings = 7;
    final maxR = size.width * 0.55;
    for (int i = 1; i <= rings; i++) {
      final r = (i * (maxR / rings) + (t * 20.0)) % maxR;
      canvas.drawCircle(center, r, pMoire);
    }
  }

  // ===========================================================================
  // BATCH 3 IMPLEMENTATIONS (EFFECTS 61 - 100)
  // ===========================================================================

  void _paintHologramRebootCycle(Canvas canvas, Size size, double t) {
    // 61. OFF -> horizontal scan -> flicker -> hologram ON -> glitch -> OFF
    if (t < 0.15 || t > 0.95) return;

    if (t < 0.35) {
      // Horizontal boot scanline beam
      final scanY = ((t - 0.15) / 0.2) * size.height;
      final pBeam = Paint()
        ..color = const Color(0xFF00FFFF).withValues(alpha: 0.9 * intensity)
        ..strokeWidth = 3.0;
      canvas.drawLine(Offset(0, scanY), Offset(size.width, scanY), pBeam);
    } else {
      // Holographic cyan mesh & flicker
      final pHolo = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.25 * intensity)
        ..strokeWidth = 1.0;
      for (double y = 0; y < size.height; y += 8.0) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), pHolo);
      }
      if (t > 0.75 && t < 0.9) {
        // Glitch before shutdown
        final pG = Paint()..color = const Color(0xFFFF0055).withValues(alpha: 0.4 * intensity);
        canvas.drawRect(Rect.fromLTWH(0, size.height * 0.3, size.width, 14), pG);
      }
    }
  }

  void _paintChromaPhaseShift(Canvas canvas, Size size, double t) {
    // 62. Chroma Phase Shift: Pergeseran warna hijau/ungu, luma relatif stabil
    final pGreen = Paint()
      ..color = const Color(0xFF00FF66).withValues(alpha: 0.35 * intensity)
      ..blendMode = BlendMode.screen;
    final pPurple = Paint()
      ..color = const Color(0xFFFF00CC).withValues(alpha: 0.35 * intensity)
      ..blendMode = BlendMode.screen;

    final shift = math.sin(t * math.pi * 4.0) * 12.0 * intensity;
    canvas.drawRect(Rect.fromLTWH(shift, 0, size.width, size.height), pGreen);
    canvas.drawRect(Rect.fromLTWH(-shift, 0, size.width, size.height), pPurple);
  }

  void _paintScanFrequencyDrift(Canvas canvas, Size size, double t) {
    // 63. Scan Frequency Drift: Miring/terlipat horizontal bertahap akibat oscillator drift
    final pDrift = Paint()
      ..color = Colors.white.withValues(alpha: 0.35 * intensity)
      ..strokeWidth = 1.5;

    final slices = 10;
    final h = size.height / slices;
    for (int i = 0; i < slices; i++) {
      final skew = (i / slices) * math.sin(t * math.pi * 2.0) * 20.0 * intensity;
      canvas.drawLine(Offset(skew, i * h), Offset(size.width + skew, i * h), pDrift);
    }
  }

  void _paintFastMicroDigitalJitter(Canvas canvas, Size size, double t) {
    // 64. Fast Micro Digital Jitter: Jitter frekuensi sangat tinggi beberapa piksel
    final rand = math.Random((t * 200).toInt());
    final pJitter = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.25 * intensity)
      ..blendMode = BlendMode.screen;

    final ox = (rand.nextDouble() - 0.5) * 6.0 * intensity;
    final oy = (rand.nextDouble() - 0.5) * 6.0 * intensity;
    canvas.drawRect(Rect.fromLTWH(ox, oy, size.width, size.height), pJitter);
  }

  void _paintHorizontalSplitShudder(Canvas canvas, Size size, double t) {
    // 65. Horizontal Split Shudder: Frame terbelah tengah, atas dan bawah bergetar berlawanan
    final shudder = math.sin(t * math.pi * 24.0) * 10.0 * intensity;
    final halfH = size.height / 2;

    final pTop = Paint()..color = const Color(0xFF00F0FF).withValues(alpha: 0.3 * intensity);
    final pBottom = Paint()..color = const Color(0xFFFF0055).withValues(alpha: 0.3 * intensity);

    canvas.drawRect(Rect.fromLTWH(shudder, 0, size.width, halfH), pTop);
    canvas.drawRect(Rect.fromLTWH(-shudder, halfH, size.width, halfH), pBottom);

    // Garis belahan tengah
    final pLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.8 * intensity)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(0, halfH), Offset(size.width, halfH), pLine);
  }

  void _paintTapeCrinkleWrinkle(Canvas canvas, Size size, double t) {
    // 66. Tape Crinkle Wrinkle: Kerutan pita melengkung & deformasi irregular
    final pWrinkle = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = Colors.white.withValues(alpha: 0.65 * intensity);

    final path = Path();
    final startY = size.height * 0.3;
    path.moveTo(0, startY);
    for (double x = 0; x <= size.width; x += 20.0) {
      final dy = math.sin((x / size.width) * math.pi * 4.0 + t * math.pi * 4.0) * 12.0 * intensity;
      path.lineTo(x, startY + dy);
    }
    canvas.drawPath(path, pWrinkle);

    final path2 = Path();
    final startY2 = size.height * 0.7;
    path2.moveTo(0, startY2);
    for (double x = 0; x <= size.width; x += 20.0) {
      final dy = math.cos((x / size.width) * math.pi * 3.0 + t * math.pi * 4.0) * 10.0 * intensity;
      path2.lineTo(x, startY2 + dy);
    }
    canvas.drawPath(path2, pWrinkle);
  }

  void _paintGlitchTeleportIn(Canvas canvas, Size size, double t) {
    // 67. Glitch Teleport In: Partikel cahaya mengompresi memadat membentuk gambar
    final rand = math.Random(67);
    final pParticle = Paint();
    final count = ((1.0 - t) * 60).toInt();

    for (int i = 0; i < count; i++) {
      final targetX = rand.nextDouble() * size.width;
      final targetY = rand.nextDouble() * size.height;
      final dist = (1.0 - t) * 40.0 * intensity;
      final px = targetX + (rand.nextDouble() - 0.5) * dist;
      final py = targetY + (rand.nextDouble() - 0.5) * dist;

      pParticle.color = const Color(0xFF00FFEA).withValues(alpha: (1.0 - t) * 0.8 * intensity);
      canvas.drawRect(Rect.fromLTWH(px, py, 3, 3), pParticle);
    }
  }

  void _paintGlitchTeleportOut(Canvas canvas, Size size, double t) {
    // 68. Glitch Teleport Out: Gambar terfragmentasi melesat vertikal ke atas lenyap
    final rand = math.Random(68);
    final pParticle = Paint();
    final count = (t * 70).toInt();

    for (int i = 0; i < count; i++) {
      final px = rand.nextDouble() * size.width;
      final origY = rand.nextDouble() * size.height;
      final py = origY - (t * 60.0 * intensity + rand.nextDouble() * 20.0);

      pParticle.color = const Color(0xFFFF0077).withValues(alpha: (1.0 - t * 0.5) * 0.85 * intensity);
      canvas.drawRect(Rect.fromLTWH(px, py % size.height, 2.5, 6.0), pParticle);
    }
  }

  void _paintNeuralCorruptWarp(Canvas canvas, Size size, double t) {
    // 69. Neural Network Error Warp: Halusinasi pembengkokan non-linear AI
    final pBlob = Paint()
      ..color = const Color(0xFFCC00FF).withValues(alpha: 0.35 * intensity)
      ..blendMode = BlendMode.screen;

    final center = Offset(size.width * 0.5, size.height * 0.5);
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final ang = (i / 8.0) * math.pi * 2;
      final rad = (size.width * 0.25) + math.sin(t * math.pi * 4.0 + i) * 20.0 * intensity;
      final pt = Offset(center.dx + math.cos(ang) * rad, center.dy + math.sin(ang) * rad);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    canvas.drawPath(path, pBlob);
  }

  void _paintFinalStaticBurst(Canvas canvas, Size size, double t) {
    // 70. Static Burst Finale: Normal -> meningkat pesat static -> Full static burst
    final burst = math.pow(t, 2.5).toDouble() * intensity;
    if (burst < 0.05) return;

    final rand = math.Random((t * 500).toInt());
    final pSnow = Paint()..color = Colors.white.withValues(alpha: burst.clamp(0.0, 0.95));

    final count = (burst * 120).toInt();
    for (int i = 0; i < count; i++) {
      final px = rand.nextDouble() * size.width;
      final py = rand.nextDouble() * size.height;
      final pw = 2.0 + rand.nextDouble() * 8.0;
      canvas.drawRect(Rect.fromLTWH(px, py, pw, 2.0), pSnow);
    }
  }

  void _paintGpuDriverCrash(Canvas canvas, Size size, double t) {
    // 71. GPU Driver Crash Freeze: Segitiga/poligon artefak warna warni khas rendering gagal
    final isCrash = t > 0.38;
    if (!isCrash) return;

    final rand = math.Random(71);
    final pPoly = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 7; i++) {
      final p1 = Offset(rand.nextDouble() * size.width, rand.nextDouble() * size.height);
      final p2 = Offset(p1.dx + (rand.nextDouble() - 0.5) * 50.0, p1.dy + rand.nextDouble() * 40.0);
      final p3 = Offset(p1.dx + rand.nextDouble() * 40.0, p1.dy + (rand.nextDouble() - 0.5) * 50.0);

      pPoly.color = (i % 3 == 0
              ? const Color(0xFFFF0055)
              : (i % 3 == 1 ? const Color(0xFF00FF66) : const Color(0xFF0099FF)))
          .withValues(alpha: 0.65 * intensity);

      final path = Path()..moveTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy)..close();
      canvas.drawPath(path, pPoly);
    }
  }

  void _paintBufferOverflowSmear(Canvas canvas, Size size, double t) {
    // 72. Buffer Overflow Smear: Smear piksel horizontal jejak panjang membentang
    final smearY = size.height * 0.45;
    final pSmear = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF00FFAA).withValues(alpha: 0.75 * intensity),
          const Color(0xFFFF00AA).withValues(alpha: 0.75 * intensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, smearY, size.width, 22));

    canvas.drawRect(Rect.fromLTWH(0, smearY, size.width, 22), pSmear);
  }

  void _paintSyncPulseDropJitter(Canvas canvas, Size size, double t) {
    // 73. Sync Pulse Drop Jitter: Lompatan vertikal mendadak akibat hilangnya sync pulse
    final cycle = (t * 5.0) % 1.0;
    if (cycle > 0.8) {
      final pBlackBar = Paint()..color = Colors.black.withValues(alpha: 0.85 * intensity);
      canvas.drawRect(Rect.fromLTWH(0, size.height * 0.8, size.width, size.height * 0.2), pBlackBar);
      final pSyncWhite = Paint()..color = Colors.white.withValues(alpha: 0.9 * intensity);
      canvas.drawRect(Rect.fromLTWH(0, size.height * 0.78, size.width, 3), pSyncWhite);
    }
  }

  void _paintH264MacroblockLoss(Canvas canvas, Size size, double t) {
    // 74. H.264 Macroblock Loss: Blok kompresi persegi hijau/abu-abu diskrit
    final isLoss = (t > 0.3 && t < 0.75);
    if (!isLoss) return;

    final rand = math.Random((t * 20).toInt());
    final pBlock = Paint();

    for (int i = 0; i < 10; i++) {
      final bx = rand.nextInt(5) * (size.width / 5);
      final by = rand.nextInt(5) * (size.height / 5);
      final bw = size.width / 5;
      final bh = size.height / 5;

      pBlock.color = (i % 2 == 0 ? const Color(0xFF00FF66) : const Color(0xFF708090))
          .withValues(alpha: 0.8 * intensity);
      canvas.drawRect(Rect.fromLTWH(bx, by, bw, bh), pBlock);
    }
  }

  void _paintMatrixRainTear(Canvas canvas, Size size, double t) {
    // 75. Matrix Rain Tear: Sobekan horizontal menembus kode digital hijau jatuh
    final tearY = size.height * 0.4;
    final tearH = size.height * 0.25;

    final pBack = Paint()..color = Colors.black.withValues(alpha: 0.85 * intensity);
    canvas.drawRect(Rect.fromLTWH(0, tearY, size.width, tearH), pBack);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final glyphs = ['1', '0', 'X', '7', '9', 'Z', 'A', '4'];
    final rand = math.Random((t * 30).toInt());

    for (double x = 10; x < size.width; x += 18.0) {
      final glyph = glyphs[rand.nextInt(glyphs.length)];
      textPainter.text = TextSpan(
        text: glyph,
        style: TextStyle(
          color: const Color(0xFF00FF44).withValues(alpha: 0.9 * intensity),
          fontFamily: 'monospace',
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, tearY + (rand.nextDouble() * (tearH - 14))));
    }
  }

  void _paintVramArtifactCorruption(Canvas canvas, Size size, double t) {
    // 76. VRAM Artifact Corruption: Pola kotak catur memori merah/ungu terisolir
    final pRed = Paint()..color = const Color(0xFFFF0033).withValues(alpha: 0.7 * intensity);
    final pPurple = Paint()..color = const Color(0xFF8800FF).withValues(alpha: 0.7 * intensity);

    final startX = size.width * 0.25;
    final startY = size.height * 0.3;
    final sz = 10.0;

    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 6; c++) {
        final p = (r + c) % 2 == 0 ? pRed : pPurple;
        canvas.drawRect(Rect.fromLTWH(startX + c * sz, startY + r * sz, sz, sz), p);
      }
    }
  }

  void _paintAnalogDemodulatorNoise(Canvas canvas, Size size, double t) {
    // 77. Analog Demodulator Noise: Garis gelombang hum frekuensi rendah bergerak lambat
    final pHum = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = const Color(0xFF00FFCC).withValues(alpha: 0.5 * intensity);

    for (int wave = 0; wave < 3; wave++) {
      final path = Path();
      final baseY = size.height * (0.25 + wave * 0.25);
      path.moveTo(0, baseY);
      for (double x = 0; x <= size.width; x += 15.0) {
        final dy = math.sin((x / size.width) * math.pi * 2.0 + t * math.pi * 2.0 + wave) * 8.0 * intensity;
        path.lineTo(x, baseY + dy);
      }
      canvas.drawPath(path, pHum);
    }
  }

  void _paintQuantumDecoherenceShift(Canvas canvas, Size size, double t) {
    // 78. Quantum Decoherence Shift: Pemisahan bidang multi-layer spasial tak beraturan
    final pLayer1 = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.35 * intensity)
      ..blendMode = BlendMode.screen;
    final pLayer2 = Paint()
      ..color = const Color(0xFFFF0099).withValues(alpha: 0.35 * intensity)
      ..blendMode = BlendMode.screen;

    final d1 = math.sin(t * math.pi * 4.0) * 14.0 * intensity;
    final d2 = math.cos(t * math.pi * 3.0) * 12.0 * intensity;

    canvas.drawRect(Rect.fromLTWH(d1, d2 * 0.5, size.width, size.height), pLayer1);
    canvas.drawRect(Rect.fromLTWH(-d1, -d2 * 0.5, size.width, size.height), pLayer2);
  }

  void _paintJpegSpectralQuantization(Canvas canvas, Size size, double t) {
    // 79. JPEG Spectral Quantization: Blok 8x8 DCT spektral nyata
    final rand = math.Random(79);
    final pBlock = Paint()..blendMode = BlendMode.colorDodge;
    final blockSize = 16.0;

    for (double y = 0; y < size.height; y += blockSize) {
      for (double x = 0; x < size.width; x += blockSize) {
        if (rand.nextDouble() > 0.7) {
          pBlock.color = Color.fromARGB(
            (60 * intensity).toInt(),
            rand.nextInt(255),
            rand.nextInt(255),
            rand.nextInt(255),
          );
          canvas.drawRect(Rect.fromLTWH(x, y, blockSize, blockSize), pBlock);
        }
      }
    }
  }

  void _paintCrackedLcdBleed(Canvas canvas, Size size, double t) {
    // 80. Cracked LCD Bleed: Garis retakan fisik tajam hitam + rembesan kroma pelangi
    final pCrack = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width * 0.45, size.height * 0.4);
    // Garis retakan bercabang
    final r1 = Offset(size.width * 0.1, size.height * 0.15);
    final r2 = Offset(size.width * 0.85, size.height * 0.25);
    final r3 = Offset(size.width * 0.3, size.height * 0.9);
    final r4 = Offset(size.width * 0.75, size.height * 0.8);

    canvas.drawLine(center, r1, pCrack);
    canvas.drawLine(center, r2, pCrack);
    canvas.drawLine(center, r3, pCrack);
    canvas.drawLine(center, r4, pCrack);

    // Rembesan pelangi LCD
    final pBleed = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00FFEA).withValues(alpha: 0.6 * intensity),
          const Color(0xFFFF00EA).withValues(alpha: 0.5 * intensity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 45.0 * intensity));
    canvas.drawCircle(center, 45.0 * intensity, pBleed);
  }

  void _paintParityCheckStutter(Canvas canvas, Size size, double t) {
    // 81. Parity Check Stutter: Penanda stutter frame freeze berulang
    final cycle = (t * 4.0).floor() % 4;
    final isStutter = (cycle == 1 || cycle == 2);
    if (isStutter) {
      final pStutter = Paint()
        ..color = const Color(0xFF00FF66).withValues(alpha: 0.25 * intensity)
        ..blendMode = BlendMode.screen;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), pStutter);

      // Icon penanda frame hold
      final pText = Paint()..color = Colors.white.withValues(alpha: 0.7 * intensity);
      canvas.drawRect(Rect.fromLTWH(12, 12, 10, 10), pText);
    }
  }

  void _paintYuvChromaSubsampleDrop(Canvas canvas, Size size, double t) {
    // 82. YUV Chroma Subsample Drop: Luma tetap tajam, kanal warna kroma tergeser
    final offset = math.sin(t * math.pi * 3.0) * 16.0 * intensity;
    final pChroma = Paint()
      ..color = const Color(0xFF0000FF).withValues(alpha: 0.4 * intensity)
      ..blendMode = BlendMode.screen;
    canvas.drawRect(Rect.fromLTWH(offset, 0, size.width, size.height), pChroma);

    final pYellow = Paint()
      ..color = const Color(0xFFFFFF00).withValues(alpha: 0.35 * intensity)
      ..blendMode = BlendMode.screen;
    canvas.drawRect(Rect.fromLTWH(-offset * 0.7, 0, size.width, size.height), pYellow);
  }

  void _paintHdmiHandshakeFailure(Canvas canvas, Size size, double t) {
    // 83. HDMI Handshake Intermittent: Video -> Blackout -> Snow -> Video
    if (t > 0.35 && t < 0.55) {
      // Blackout
      final pBlack = Paint()..color = Colors.black;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), pBlack);
    } else if (t >= 0.55 && t < 0.70) {
      // Snow
      final rand = math.Random((t * 200).toInt());
      final pSnow = Paint()..color = Colors.white.withValues(alpha: 0.75 * intensity);
      for (int i = 0; i < 40; i++) {
        final px = rand.nextDouble() * size.width;
        final py = rand.nextDouble() * size.height;
        canvas.drawRect(Rect.fromLTWH(px, py, 3, 2), pSnow);
      }
    }
  }

  void _paintSatelliteUplinkDrop(Canvas canvas, Size size, double t) {
    // 84. Satellite Uplink Drop: Mozaik blok beku & korupsi transmisi uplink
    final isDrop = (t > 0.3 && t < 0.7);
    if (!isDrop) return;

    final rand = math.Random(84);
    final pMosaic = Paint()..color = const Color(0xFF334455).withValues(alpha: 0.8 * intensity);

    for (int i = 0; i < 8; i++) {
      final bx = rand.nextInt(4) * (size.width / 4);
      final by = rand.nextInt(4) * (size.height / 4);
      canvas.drawRect(Rect.fromLTWH(bx, by, size.width / 4, size.height / 4), pMosaic);
    }
  }

  void _paintCorruptedNvramBoot(Canvas canvas, Size size, double t) {
    // 85. Corrupted NVRAM Boot: Baris teks heksadesimal BIOS/DOS korup berkedip
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final rand = math.Random((t * 20).toInt());
    final lines = ['NVRAM ERR 0x002F', 'BOOT SECTOR FAULT', 'CRC MISMATCH', 'REBOOTING...'];

    for (int i = 0; i < lines.length; i++) {
      textPainter.text = TextSpan(
        text: lines[i],
        style: TextStyle(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.85 * intensity),
          fontFamily: 'monospace',
          fontSize: 11.0,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.blue.withValues(alpha: 0.7),
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(20.0 + (rand.nextDouble() * 5.0), 30.0 + i * 22.0));
    }
  }

  void _paintCrtDegaussCoilWobble(Canvas canvas, Size size, double t) {
    // 86. CRT Degauss Coil Wobble: Gelombang distorsi magnetik kumparan degauss melingkar
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final decay = math.exp(-t * 3.5);
    final pCoil = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = const Color(0xFF00FFCC).withValues(alpha: decay * 0.7 * intensity);

    for (int i = 1; i <= 4; i++) {
      final r = (i * 25.0 + math.sin(t * math.pi * 10.0) * 10.0) * decay;
      canvas.drawCircle(center, r, pCoil);
    }
  }

  void _paintRfCrossModulation(Canvas canvas, Size size, double t) {
    // 87. RF Cross Modulation: Saluran kedua siluet bayangan mengambang di belakang
    final pGhost = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.25 * intensity)
      ..blendMode = BlendMode.screen;

    final ghostX = math.sin(t * math.pi * 2.0) * 16.0 * intensity;
    canvas.drawRect(Rect.fromLTWH(ghostX, 0, size.width, size.height), pGhost);

    // Garis interferensi frekuensi pembawa
    final pCarrier = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.3 * intensity)
      ..strokeWidth = 1.0;
    for (double y = 0; y < size.height; y += 12.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), pCarrier);
    }
  }

  void _paintMpeg2TransportStreamTear(Canvas canvas, Size size, double t) {
    // 88. MPEG-2 Transport Stream Tear: Sobekan data tebal paket transport MPEG-2
    final tearY = size.height * 0.5 + math.sin(t * math.pi * 4.0) * 20.0;
    final pTear = Paint()..color = const Color(0xFF556677).withValues(alpha: 0.85 * intensity);
    canvas.drawRect(Rect.fromLTWH(0, tearY, size.width, 18), pTear);

    final pData = Paint()..color = const Color(0xFFFFCC00).withValues(alpha: 0.9 * intensity);
    for (double x = 10; x < size.width; x += 15.0) {
      canvas.drawRect(Rect.fromLTWH(x, tearY + 4, 8, 10), pData);
    }
  }

  void _paintDigitalGhostingEcho(Canvas canvas, Size size, double t) {
    // 89. Digital Ghosting Echo: 3 siluet bayangan berulang menurun opasitasnya
    final pEcho1 = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.3 * intensity)
      ..blendMode = BlendMode.screen;
    final pEcho2 = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.18 * intensity)
      ..blendMode = BlendMode.screen;
    final pEcho3 = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.09 * intensity)
      ..blendMode = BlendMode.screen;

    final ox = math.sin(t * math.pi * 2.0) * 15.0 * intensity;
    canvas.drawRect(Rect.fromLTWH(ox, 0, size.width, size.height), pEcho1);
    canvas.drawRect(Rect.fromLTWH(ox * 2.0, 0, size.width, size.height), pEcho2);
    canvas.drawRect(Rect.fromLTWH(ox * 3.0, 0, size.width, size.height), pEcho3);
  }

  void _paintInterlacedCombTeeth(Canvas canvas, Size size, double t) {
    // 90. Interlaced Comb Teeth: Gerigi sisir horizontal bersilangan saat gerak cepat
    final pComb = Paint()..color = Colors.black.withValues(alpha: 0.55 * intensity);
    final toothOffset = math.sin(t * math.pi * 20.0) * 10.0 * intensity;

    for (double y = 0; y < size.height; y += 4.0) {
      final isEven = (y / 4.0).toInt() % 2 == 0;
      if (isEven) {
        canvas.drawRect(Rect.fromLTWH(toothOffset, y, size.width, 2.0), pComb);
      }
    }
  }

  void _paintDefectiveCcdSensorLine(Canvas canvas, Size size, double t) {
    // 91. Defective CCD Sensor Line: TEPAT 1 garis vertikal piksel mati magenta/putih menetap
    final lineX = size.width * 0.62;
    final pLine = Paint()
      ..color = const Color(0xFFFF00FF).withValues(alpha: 0.9 * intensity)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(lineX, 0), Offset(lineX, size.height), pLine);

    final pCore = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(lineX, 0), Offset(lineX, size.height), pCore);
  }

  void _paintRollingShutterJello(Canvas canvas, Size size, double t) {
    // 92. Rolling Shutter Jello: Peregangan lentur agar-agar atas-bawah asinkron
    final pJello = Paint()
      ..color = const Color(0xFF00FFCC).withValues(alpha: 0.25 * intensity)
      ..blendMode = BlendMode.screen;

    final slices = 8;
    final h = size.height / slices;
    for (int i = 0; i < slices; i++) {
      final shift = math.sin(t * math.pi * 4.0 + (i * 0.6)) * 14.0 * intensity;
      canvas.drawRect(Rect.fromLTWH(shift, i * h, size.width, h), pJello);
    }
  }

  void _paintStaticDischargeSpark(Canvas canvas, Size size, double t) {
    // 93. Static Discharge Spark: Percikan lonjakan bunga api listrik statis tajam
    final isSpark = math.sin(t * math.pi * 26.0) > 0.75;
    if (!isSpark) return;

    final rand = math.Random((t * 777).toInt());
    final start = Offset(rand.nextDouble() * size.width, rand.nextDouble() * size.height);
    final pSpark = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;

    final path = Path()..moveTo(start.dx, start.dy);
    var curr = start;
    for (int i = 0; i < 4; i++) {
      curr = Offset(curr.dx + (rand.nextDouble() - 0.5) * 30.0, curr.dy + (rand.nextDouble() - 0.5) * 30.0);
      path.lineTo(curr.dx, curr.dy);
    }
    canvas.drawPath(path, pSpark);
  }

  void _paintAvDesyncFlutter(Canvas canvas, Size size, double t) {
    // 94. A/V Desync Flutter: 1-frame maju mundur berulang ritmis
    final flutter = (t * 12.0).floor() % 2 == 0;
    if (flutter) {
      final pFlutter = Paint()
        ..color = const Color(0xFF00F0FF).withValues(alpha: 0.3 * intensity)
        ..blendMode = BlendMode.difference;
      canvas.drawRect(Rect.fromLTWH(8.0 * intensity, 0, size.width, size.height), pFlutter);
    }
  }

  void _paintMagneticBitRotDecay(Canvas canvas, Size size, double t) {
    // 95. Magnetic Bit Rot Decay: Bintik karat membusuk & pelemahan partikel magnetik
    final rand = math.Random(95);
    final pRust = Paint()..color = const Color(0xFF994422).withValues(alpha: (0.4 + t * 0.4) * intensity);

    for (int i = 0; i < 35; i++) {
      final px = rand.nextDouble() * size.width;
      final py = rand.nextDouble() * size.height;
      canvas.drawCircle(Offset(px, py), 2.5 + rand.nextDouble() * 3.0, pRust);
    }
  }

  void _paintAnalogTapeCreasePop(Canvas canvas, Size size, double t) {
    // 96. Analog Tape Crease Pop: Garis lipatan putih tebal meloncat tiba-tiba
    final isPop = (t * 4.0) % 1.0 > 0.8;
    if (!isPop) return;

    final creaseY = size.height * 0.6;
    final pCrease = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.9 * intensity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, creaseY - 6, size.width, 12));
    canvas.drawRect(Rect.fromLTWH(0, creaseY - 6, size.width, 12), pCrease);
  }

  void _paintLaserdiscDropoutSnow(Canvas canvas, Size size, double t) {
    // 97. Laserdisc Dropout Snow: Garis putih pendek horizontal jarang khas cakram optik
    final rand = math.Random((t * 80).toInt());
    final pDrop = Paint()..color = Colors.white.withValues(alpha: 0.85 * intensity);

    for (int i = 0; i < 12; i++) {
      final px = rand.nextDouble() * size.width;
      final py = rand.nextDouble() * size.height;
      final len = 6.0 + rand.nextDouble() * 14.0;
      canvas.drawRect(Rect.fromLTWH(px, py, len, 1.2), pDrop);
    }
  }

  void _paintRasterBeamCollapse(Canvas canvas, Size size, double t) {
    // 98. Raster Beam Collapse: Gambar runtuh vertikal ke tengah -> 1 garis horizontal ultra terang -> Padam
    if (t < 0.6) {
      // Menyusut vertikal
      final prog = t / 0.6;
      final borderH = (size.height / 2) * prog;
      final pDark = Paint()..color = Colors.black;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, borderH), pDark);
      canvas.drawRect(Rect.fromLTWH(0, size.height - borderH, size.width, borderH), pDark);
    } else if (t < 0.8) {
      // Garis horizontal putih menyala
      final pBlack = Paint()..color = Colors.black;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), pBlack);

      final pLine = Paint()
        ..color = Colors.white
        ..strokeWidth = 3.0;
      canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), pLine);
    } else {
      // Padam / blackout
      final pBlack = Paint()..color = Colors.black;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), pBlack);
    }
  }

  void _paintColorBurstPhaseJitter(Canvas canvas, Size size, double t) {
    // 99. Color Burst Phase Jitter: Perubahan fase warna liar cepat (Magenta, Cyan, Yellow)
    final step = (t * 18.0).floor() % 3;
    final Color c;
    if (step == 0) {
      c = const Color(0xFFFF00CC);
    } else if (step == 1) {
      c = const Color(0xFF00FFCC);
    } else {
      c = const Color(0xFFFFFF00);
    }

    final pBurst = Paint()
      ..color = c.withValues(alpha: 0.35 * intensity)
      ..blendMode = BlendMode.screen;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), pBurst);
  }

  void _paintCyberBreachDataGlitch(Canvas canvas, Size size, double t) {
    // 100. Cyber Breach Data Glitch: Pelanggaran keamanan cyber data biner & blok merah
    final pRedGrid = Paint()
      ..color = const Color(0xFFFF0033).withValues(alpha: 0.3 * intensity)
      ..blendMode = BlendMode.colorDodge;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), pRedGrid);

    // Teks binary breach
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final rand = math.Random((t * 24).toInt());
    final warnings = ['SYSTEM COMPROMISED', 'BREACH 0-DAY', '01101001 01101110', 'SECURITY OVERRIDE'];

    for (int i = 0; i < 3; i++) {
      textPainter.text = TextSpan(
        text: warnings[rand.nextInt(warnings.length)],
        style: TextStyle(
          color: const Color(0xFFFF0033).withValues(alpha: 0.85 * intensity),
          fontFamily: 'monospace',
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.black.withValues(alpha: 0.6),
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width * 0.1, size.height * (0.3 + i * 0.18)));
    }
  }

  @override
  bool shouldRepaint(covariant GlitchVisualEffectPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.effectId != effectId ||
        oldDelegate.intensity != intensity;
  }
}
