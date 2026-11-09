import 'dart:math' as math;
import 'animation_model.dart';

/// Semantic Shake Definition & Kinematic Waveform Evaluator
/// Memberikan kepastian visual 1:1 antara nama efek dengan perilaku fisika riil.
class ShakeSemanticEngine {
  /// Evaluasi transformasi shake matematis untuk seluruh 100 preset guncangan.
  static AnimationTransformResult evaluate(
    String id,
    double t,
    double intensity,
    AnimationApplicationType type,
  ) {
    // Normalisasi waktu t (0.0 sampai 1.0)
    final clampedT = t.clamp(0.0, 1.0);

    switch (id) {
      // =========================================================================
      // 1. KELUARGA KAMERA NATURAL & HANDHELD (1-5)
      // =========================================================================
      case 'camera_shake':
        // Guncangan kamera aksi alami: X & Y frekuensi sedang, rotasi halus, skala kompensasi
        final sx = (math.sin(clampedT * math.pi * 12.0) * 0.035 + math.sin(clampedT * math.pi * 5.0) * 0.015) * intensity;
        final sy = (math.cos(clampedT * math.pi * 10.0) * 0.025 + math.cos(clampedT * math.pi * 7.0) * 0.01) * intensity;
        final rot = math.sin(clampedT * math.pi * 6.0) * 1.8 * intensity;
        return AnimationTransformResult(positionX: sx, positionY: sy, rotationDegrees: rot, scale: 1.02);

      case 'handheld_camera':
        // Vlog genggam: micro drift lambat + nafas alami + rotasi sangat halus
        final sx = (math.sin(clampedT * math.pi * 2.5) * 0.02 + math.cos(clampedT * math.pi * 5.0) * 0.008) * intensity;
        final sy = (math.cos(clampedT * math.pi * 2.0) * 0.025 + math.sin(clampedT * math.pi * 4.0) * 0.006) * intensity;
        final rot = math.sin(clampedT * math.pi * 1.5) * 1.0 * intensity;
        return AnimationTransformResult(positionX: sx, positionY: sy, rotationDegrees: rot, scale: 1.015);

      case 'slight_sway':
        // Ayunan tenang lembut: pendulum kiri -> tengah -> kanan -> tengah, rotasi lembut
        final sx = math.sin(clampedT * math.pi * 2.0) * 0.04 * intensity;
        final rot = math.sin(clampedT * math.pi * 2.0) * 2.5 * intensity;
        return AnimationTransformResult(positionX: sx, rotationDegrees: rot);

      case 'shake_handheld_walk_steady':
        // Langkah jalan santai stabilisator: pola ritmik langkah kaki (puncak vertikal dua kali tiap langkah)
        final stepCycle = clampedT * 4.0;
        final stepPhase = stepCycle - stepCycle.floor();
        final sy = -math.sin(stepPhase * math.pi) * 0.035 * intensity;
        final sx = math.sin(clampedT * math.pi * 2.0) * 0.018 * intensity;
        final rot = math.sin(clampedT * math.pi * 2.0) * 1.2 * intensity;
        return AnimationTransformResult(positionX: sx, positionY: sy, rotationDegrees: rot, scale: 1.02);

      case 'shake_handheld_run_sprint':
        // Juru kamera lari cepat: hentakan vertikal keras bergantian miring kiri-kanan
        final runCycle = clampedT * 8.0;
        final runPhase = runCycle - runCycle.floor();
        final sy = -math.sin(runPhase * math.pi).abs() * 0.08 * intensity;
        final sx = math.sin(clampedT * math.pi * 4.0) * 0.045 * intensity;
        final rot = math.sin(clampedT * math.pi * 4.0) * 4.5 * intensity;
        return AnimationTransformResult(positionX: sx, positionY: sy, rotationDegrees: rot, scale: 1.05);

      // =========================================================================
      // 2. DIRECTIONAL STRICT AXIS (6-8)
      // =========================================================================
      case 'horizontal_shake':
        // Murni horizontal kiri-kanan osilasi tajam, Y = 0
        final hx = math.sin(clampedT * math.pi * 18.0) * 0.06 * intensity;
        return AnimationTransformResult(positionX: hx, positionY: 0.0, scale: 1.02);

      case 'vertical_shake':
        // Murni vertikal atas-bawah osilasi tajam, X = 0
        final vy = math.sin(clampedT * math.pi * 18.0) * 0.06 * intensity;
        return AnimationTransformResult(positionX: 0.0, positionY: vy, scale: 1.02);

      case 'speed_wobble':
        // Skateboard / motor ngebut: goyangan amplitudo membesar secara eksponensial (wobble)
        final wobbleAmp = (0.01 + clampedT * 0.06) * intensity;
        final wx = math.sin(clampedT * math.pi * (14.0 + clampedT * 10.0)) * wobbleAmp;
        final wRot = math.sin(clampedT * math.pi * (14.0 + clampedT * 10.0)) * (wobbleAmp * 80.0);
        return AnimationTransformResult(positionX: wx, rotationDegrees: wRot, scale: 1.03);

      // =========================================================================
      // 3. SEISMIC, GEOLOGICAL & TECTONIC (9-14)
      // =========================================================================
      case 'earthquake':
        // Gempa bumi: perpaduan frekuensi tinggi tektonik + retakan gelombang transversal
        final eqX = (math.sin(clampedT * math.pi * 22.0) * 0.05 + math.sin(clampedT * math.pi * 9.0) * 0.03) * intensity;
        final eqY = (math.cos(clampedT * math.pi * 19.0) * 0.05 + math.cos(clampedT * math.pi * 7.0) * 0.03) * intensity;
        final eqRot = math.sin(clampedT * math.pi * 15.0) * 3.0 * intensity;
        return AnimationTransformResult(positionX: eqX, positionY: eqY, rotationDegrees: eqRot, scale: 1.05);

      case 'cinematic_quake':
        // Gempa sinematik bioskop: guncangan megah lambat tapi dalam disertai hentakan sub-seismik
        final cqX = (math.sin(clampedT * math.pi * 10.0) * 0.07 + math.sin(clampedT * math.pi * 2.5) * 0.05) * intensity;
        final cqY = (math.cos(clampedT * math.pi * 8.0) * 0.06 + math.sin(clampedT * math.pi * 2.0) * 0.04) * intensity;
        final cqRot = math.sin(clampedT * math.pi * 5.0) * 4.0 * intensity;
        final cqScale = 1.03 + math.sin(clampedT * math.pi * 4.0).abs() * 0.04 * intensity;
        return AnimationTransformResult(positionX: cqX, positionY: cqY, rotationDegrees: cqRot, scale: cqScale);

      case 'shake_aftershock_rumble':
        // Gempa susulan: osilasi berulang dengan decay bertahap
        final decay = math.exp(-clampedT * 2.8);
        final ax = math.sin(clampedT * math.pi * 16.0) * 0.065 * intensity * decay;
        final ay = math.cos(clampedT * math.pi * 13.0) * 0.05 * intensity * decay;
        return AnimationTransformResult(positionX: ax, positionY: ay, scale: 1.02);

      case 'shake_seismic_wave_jolt':
        // Gelombang seismik P-wave & S-wave: gelombang longitudinal vertikal tiba-tiba lalu S-wave horizontal
        final pWave = (clampedT < 0.25) ? math.sin(clampedT * 4.0 * math.pi * 4.0) * 0.08 * (1.0 - clampedT * 4.0) : 0.0;
        final sWave = (clampedT >= 0.25) ? math.sin((clampedT - 0.25) * math.pi * 12.0) * 0.06 * math.exp(-(clampedT - 0.25) * 3.0) : 0.0;
        return AnimationTransformResult(positionX: sWave * intensity, positionY: pWave * intensity, scale: 1.03);

      case 'shake_volcanic_tremor_pulse':
        // Tremor magma gunung api: denyutan getar terus-menerus harmonik dalam tanah
        final harmonic = math.sin(clampedT * math.pi * 14.0) * 0.035 + math.sin(clampedT * math.pi * 28.0) * 0.015;
        final pulseScale = 1.02 + math.sin(clampedT * math.pi * 6.0) * 0.025 * intensity;
        return AnimationTransformResult(positionX: harmonic * intensity, positionY: (math.cos(clampedT * math.pi * 12.0) * 0.02) * intensity, scale: pulseScale);

      case 'shake_deep_mine_cave_in':
        // Guguran langit tambang runtuh: hentakan vertikal bawah mendadak + getaran debu gemuruh
        final caveImpact = (clampedT < 0.3) ? (math.sin(clampedT / 0.3 * math.pi) * 0.1) : 0.0;
        final rubbleX = math.sin(clampedT * math.pi * 24.0) * 0.035 * intensity;
        final rubbleY = (caveImpact + math.cos(clampedT * math.pi * 20.0) * 0.03) * intensity;
        return AnimationTransformResult(positionX: rubbleX, positionY: rubbleY, scale: 1.04);

      // =========================================================================
      // 4. HEARTBEAT & BIOLOGICAL PULSE (15-17)
      // =========================================================================
      case 'heartbeat':
        // Detak jantung klasik: lub-dub ganda teratur (kontraksi -> jeda relaksasi)
        final cycle = (clampedT * 2.0); // 2 detak per siklus
        final phase = cycle - cycle.floor();
        double pScale = 0.0;
        if (phase < 0.15) {
          pScale = math.sin(phase / 0.15 * math.pi) * 0.12; // Lub
        } else if (phase > 0.22 && phase < 0.40) {
          pScale = math.sin((phase - 0.22) / 0.18 * math.pi) * 0.08; // Dub
        }
        return AnimationTransformResult(scale: 1.0 + pScale * intensity);

      case 'shake_heartbeat_panic_thump':
        // Detak jantung panik berkejaran: 4 ketukan sangat cepat, pergeseran skala + vignette getar
        final cycleP = (clampedT * 4.0);
        final phaseP = cycleP - cycleP.floor();
        double thump = 0.0;
        if (phaseP < 0.20) {
          thump = math.sin(phaseP / 0.20 * math.pi) * 0.16;
        }
        final tremor = math.sin(clampedT * math.pi * 30.0) * 0.015;
        return AnimationTransformResult(scale: 1.0 + thump * intensity, positionX: tremor * intensity, positionY: tremor * 0.5 * intensity);

      case 'adrenaline_twitch':
        // Kedutan adrenalin menegangkan: sentakan kejut mikro tak beraturan (spike tajam)
        final spike = (math.sin(clampedT * math.pi * 16.0) > 0.75) ? ((clampedT * 37.0) % 0.05) - 0.025 : 0.0;
        final rotSpike = (math.cos(clampedT * math.pi * 14.0) > 0.7) ? 2.5 : -1.5;
        return AnimationTransformResult(positionX: spike * 1.5 * intensity, positionY: -spike * intensity, rotationDegrees: rotSpike * intensity, scale: 1.02);

      // =========================================================================
      // 5. COMBAT, PUNCH & MARTIAL ARTS IMPACT (18-23)
      // =========================================================================
      case 'punch_impact':
        // Hantaman pukulan telak: 0.00 diam -> 0.10 terdorong keras ke samping kiri -> 0.25 sentakan recoil -> 0.45 redam -> diam
        double px = 0.0;
        double py = 0.0;
        double rot = 0.0;
        if (clampedT < 0.12) {
          final prog = clampedT / 0.12;
          px = -math.sin(prog * math.pi * 0.5) * 0.12;
          rot = -3.5 * prog;
        } else if (clampedT < 0.45) {
          final prog = (clampedT - 0.12) / 0.33;
          final d = math.exp(-prog * 4.0);
          px = (-0.12 + 0.12 * prog) * d + math.sin(prog * math.pi * 8.0) * 0.03 * d;
          rot = -3.5 * (1.0 - prog) * d;
        }
        final flash = (clampedT < 0.15) ? (1.0 - clampedT / 0.15) * 0.4 : 0.0;
        return AnimationTransformResult(positionX: px * intensity, positionY: py * intensity, rotationDegrees: rot * intensity, flashOpacity: flash * intensity, scale: 1.04);

      case 'shake_boxing_cross_hit':
        // Pukulan silang rahang: sentakan rotasi keras ke kanan + pergeseran X mendadak
        double bx = 0.0;
        double bRot = 0.0;
        if (clampedT < 0.15) {
          final p = clampedT / 0.15;
          bx = math.sin(p * math.pi * 0.5) * 0.14;
          bRot = 5.0 * p;
        } else {
          final p = (clampedT - 0.15) / 0.85;
          final d = math.exp(-p * 5.0);
          bx = 0.14 * d * math.cos(p * math.pi * 6.0);
          bRot = 5.0 * d * math.cos(p * math.pi * 6.0);
        }
        return AnimationTransformResult(positionX: bx * intensity, rotationDegrees: bRot * intensity, scale: 1.03);

      case 'shake_karate_chop_break':
        // Hantaman karate chop ke bawah: gerakan tebasan vertikal tajam dari atas ke bawah
        double ky = 0.0;
        if (clampedT < 0.10) {
          ky = -(clampedT / 0.10) * 0.15; // Hentakan ke bawah drastis
        } else {
          final p = (clampedT - 0.10) / 0.90;
          ky = -0.15 * math.exp(-p * 6.0) * math.cos(p * math.pi * 10.0);
        }
        return AnimationTransformResult(positionY: ky * intensity, scale: 1.03);

      case 'shake_wrestling_body_slam':
        // Tubuh terbanting ke ring: bantingan besar ke bawah + memantul dua kali di atas kanvas pegas
        double wy = 0.0;
        if (clampedT < 0.18) {
          wy = -(clampedT / 0.18) * 0.16;
        } else {
          final p = (clampedT - 0.18) / 0.82;
          wy = -0.16 * math.exp(-p * 4.5) * math.cos(p * math.pi * 5.0);
        }
        final wScale = 1.0 + (wy.abs() * 0.4);
        return AnimationTransformResult(positionY: wy * intensity, scale: wScale);

      case 'action_stumble':
        // Tersandung hilang keseimbangan: miring limbung ke kanan, lalu goyang pulih ke tengah
        final stX = math.sin(clampedT * math.pi * 2.5) * 0.08 * (1.0 - clampedT * 0.7);
        final stRot = math.sin(clampedT * math.pi * 2.0) * 6.0 * (1.0 - clampedT * 0.6);
        return AnimationTransformResult(positionX: stX * intensity, rotationDegrees: stRot * intensity, scale: 1.03);

      case 'shake_stumble_trip_fall':
        // Terperosok jatuh: anjlok ke bawah dengan putaran sudut tajam
        double fy = 0.0;
        double fRot = 0.0;
        if (clampedT < 0.35) {
          final p = clampedT / 0.35;
          fy = -0.18 * (p * p);
          fRot = 7.0 * p;
        } else {
          final p = (clampedT - 0.35) / 0.65;
          final d = math.exp(-p * 4.0);
          fy = -0.18 * d + math.sin(p * math.pi * 6.0) * 0.03 * d;
          fRot = 7.0 * d;
        }
        return AnimationTransformResult(positionY: fy * intensity, rotationDegrees: fRot * intensity, scale: 1.04);

      // =========================================================================
      // 6. EXPLOSIONS, ARTILLERY & SHOCKWAVES (24-30)
      // =========================================================================
      case 'impact_shake':
        // Sentakan keras seketika dengan decay halus
        final damp = math.exp(-clampedT * 4.5);
        final ix = (math.sin(clampedT * math.pi * 18.0) * 0.09 * intensity * damp);
        final iy = (math.cos(clampedT * math.pi * 15.0) * 0.07 * intensity * damp);
        return AnimationTransformResult(positionX: ix, positionY: iy, scale: 1.0 + (0.05 * damp * intensity));

      case 'explosion_shockwave':
        // Gelombang kejut ledakan dahsyat: flash kilat putih seketika + zoom kejut + goncangan multi-arah
        final expDamp = math.exp(-clampedT * 3.8);
        final exX = math.sin(clampedT * math.pi * 26.0) * 0.12 * expDamp * intensity;
        final exY = math.cos(clampedT * math.pi * 22.0) * 0.10 * expDamp * intensity;
        final exRot = math.sin(clampedT * math.pi * 16.0) * 5.0 * expDamp * intensity;
        final exScale = 1.0 + (0.15 * expDamp * intensity);
        final exFlash = (clampedT < 0.20) ? (1.0 - clampedT / 0.20) * 0.7 * intensity : 0.0;
        return AnimationTransformResult(positionX: exX, positionY: exY, rotationDegrees: exRot, scale: exScale, flashOpacity: exFlash);

      case 'shake_grenade_blast_concussion':
        // Ledakan granat dekat: goncangan tajam frekuensi sangat tinggi + deselerasi tekanan
        final gDamp = math.exp(-clampedT * 4.2);
        final gx = math.sin(clampedT * math.pi * 32.0) * 0.10 * gDamp * intensity;
        final gy = math.cos(clampedT * math.pi * 28.0) * 0.08 * gDamp * intensity;
        final gFlash = (clampedT < 0.12) ? (1.0 - clampedT / 0.12) * 0.5 * intensity : 0.0;
        return AnimationTransformResult(positionX: gx, positionY: gy, flashOpacity: gFlash, scale: 1.03);

      case 'shake_artillery_cannon_thud':
        // Dentuman meriam artileri medan: hentakan sentakan ke belakang (zoom punch) lalu getaran bergemuruh
        final artDamp = math.exp(-clampedT * 3.5);
        final artScale = 1.0 + (math.sin(clampedT * math.pi * 8.0) * 0.12 * artDamp * intensity);
        final artY = (math.sin(clampedT * math.pi * 14.0) * 0.07 * artDamp * intensity);
        return AnimationTransformResult(positionY: artY, scale: artScale);

      case 'shake_sonic_boom_shockwave':
        // Dentuman sonik pesawat supersonik: diam tenang -> dentuman sonik kompresi tiba-tiba di t = 0.35 -> getaran udara
        double sbX = 0.0;
        double sbScale = 1.0;
        if (clampedT >= 0.25) {
          final p = (clampedT - 0.25) / 0.75;
          final d = math.exp(-p * 4.0);
          sbX = math.sin(p * math.pi * 20.0) * 0.11 * d * intensity;
          sbScale = 1.0 + math.cos(p * math.pi * 10.0) * 0.08 * d * intensity;
        }
        return AnimationTransformResult(positionX: sbX, scale: sbScale);

      case 'shake_sub_depth_charge_blast':
        // Ledakan bom kedalaman laut: gelombang hidrolik air menghantam lambung -> ayunan air bergulung
        final chargeDamp = math.exp(-clampedT * 2.5);
        final cx = math.sin(clampedT * math.pi * 12.0) * 0.09 * chargeDamp * intensity;
        final cy = math.cos(clampedT * math.pi * 8.0) * 0.07 * chargeDamp * intensity;
        final cRot = math.sin(clampedT * math.pi * 6.0) * 3.5 * chargeDamp * intensity;
        return AnimationTransformResult(positionX: cx, positionY: cy, rotationDegrees: cRot, scale: 1.03);

      case 'shake_thunder_crack_bump':
        // Petir menyambar: kilat flash instan + 2x dentuman guntur menggelegar
        final flashT = (clampedT < 0.18) ? (1.0 - clampedT / 0.18) * 0.8 : 0.0;
        final tcY = (math.sin(clampedT * math.pi * 16.0) * 0.08 * math.exp(-clampedT * 3.5)) * intensity;
        final tcX = (math.cos(clampedT * math.pi * 12.0) * 0.04 * math.exp(-clampedT * 3.5)) * intensity;
        return AnimationTransformResult(positionX: tcX, positionY: tcY, flashOpacity: flashT * intensity, scale: 1.03);

      // =========================================================================
      // 7. FIREARMS, WEAPONS & RECOIL (31-34)
      // =========================================================================
      case 'gunfire_recoil':
        // Tembakan otomatis bertubi-tubi: 5x hentakan ke atas (muzzle climb) dengan recoil cepat
        final shotCycle = (clampedT * 5.0);
        final shotPhase = shotCycle - shotCycle.floor();
        double recoilY = 0.0;
        if (shotPhase < 0.25) {
          recoilY = (shotPhase / 0.25) * 0.07; // Sentakan ke atas
        } else {
          recoilY = 0.07 * (1.0 - (shotPhase - 0.25) / 0.75); // Turun kembali
        }
        final recoilX = math.sin(clampedT * math.pi * 10.0) * 0.015;
        return AnimationTransformResult(positionX: recoilX * intensity, positionY: -recoilY * intensity, scale: 1.02);

      case 'shake_shotgun_kickback_recoil':
        // Senapan shotgun: tolak balik raksasa satu kali mendadak ke belakang dan atas, rotasi laras mendongak
        double sgY = 0.0;
        double sgRot = 0.0;
        if (clampedT < 0.15) {
          final p = clampedT / 0.15;
          sgY = 0.14 * p;
          sgRot = -5.0 * p;
        } else {
          final p = (clampedT - 0.15) / 0.85;
          final d = math.exp(-p * 4.0);
          sgY = 0.14 * d;
          sgRot = -5.0 * d;
        }
        return AnimationTransformResult(positionY: -sgY * intensity, rotationDegrees: sgRot * intensity, scale: 1.04);

      case 'shake_sniper_single_jolt':
        // Senapan sniper presisi: hentakan tunggal tajam kilat di awal t < 0.08 lalu stabil membeku
        double snY = 0.0;
        if (clampedT < 0.08) {
          snY = (clampedT / 0.08) * 0.15;
        } else {
          final p = (clampedT - 0.08) / 0.92;
          snY = 0.15 * math.exp(-p * 7.0);
        }
        return AnimationTransformResult(positionY: -snY * intensity, scale: 1.03);

      case 'extreme_jolt':
        // Sentakan sengatan listrik kejut ekstrem: jitter patah-patah acak tajam
        final joltStep = (clampedT * 25.0).floor();
        final jx = (((joltStep * 17) % 11) - 5) / 50.0;
        final jy = (((joltStep * 23) % 11) - 5) / 50.0;
        final jRot = (((joltStep * 19) % 7) - 3) * 1.5;
        return AnimationTransformResult(positionX: jx * intensity, positionY: jy * intensity, rotationDegrees: jRot * intensity, scale: 1.04);

      // =========================================================================
      // 8. HEAVY IMPACTS, COLLISIONS & DROPS (35-43)
      // =========================================================================
      case 'drop_impact':
        // Pendaratan jatuh bebas: diam jatuh -> tumbukan lantai keras di t = 0.3 -> kompresi pegas
        double dy = 0.0;
        if (clampedT < 0.30) {
          dy = -(clampedT / 0.30) * 0.08;
        } else {
          final p = (clampedT - 0.30) / 0.70;
          final d = math.exp(-p * 5.0);
          dy = 0.12 * d * math.cos(p * math.pi * 8.0);
        }
        return AnimationTransformResult(positionY: dy * intensity, scale: 1.0 + (dy.abs() * 0.5));

      case 'shake_skate_drop_impact':
        // Pendaratan papan skateboard di beton: hentakan ganda (roda belakang lalu roda depan)
        double skY = 0.0;
        if (clampedT > 0.20 && clampedT < 0.40) {
          skY = -math.sin((clampedT - 0.20) / 0.20 * math.pi) * 0.09;
        } else if (clampedT >= 0.40 && clampedT < 0.60) {
          skY = -math.sin((clampedT - 0.40) / 0.20 * math.pi) * 0.05;
        }
        return AnimationTransformResult(positionY: skY * intensity, scale: 1.02);

      case 'shake_car_crash_whiplash':
        // Tabrakan mobil frontal: perlambatan drastis membanting ke depan lalu recoil ke belakang
        double whiplashX = 0.0;
        double whiplashScale = 1.0;
        if (clampedT < 0.20) {
          whiplashX = -(clampedT / 0.20) * 0.16;
          whiplashScale = 1.0 + (clampedT / 0.20) * 0.10;
        } else {
          final p = (clampedT - 0.20) / 0.80;
          final d = math.exp(-p * 4.0);
          whiplashX = (-0.16 * d) + math.sin(p * math.pi * 6.0) * 0.06 * d;
          whiplashScale = 1.0 + 0.10 * d * math.cos(p * math.pi * 4.0);
        }
        return AnimationTransformResult(positionX: whiplashX * intensity, scale: whiplashScale);

      case 'shake_heavy_club_drop':
        // Balok kayu raksasa jatuh debuk: hentakan berat di bawah tanpa pantulan banyak
        double cy = 0.0;
        if (clampedT < 0.25) {
          cy = -(clampedT / 0.25) * 0.13;
        } else {
          final p = (clampedT - 0.25) / 0.75;
          cy = -0.13 * math.exp(-p * 6.0) * math.cos(p * math.pi * 4.0);
        }
        return AnimationTransformResult(positionY: cy * intensity, scale: 1.03);

      case 'shake_sledgehammer_strike':
        // Palu godam memukul dinding: hentakan diagonal keras membentur media padat
        double smX = 0.0;
        double smY = 0.0;
        if (clampedT < 0.18) {
          smX = (clampedT / 0.18) * 0.11;
          smY = -(clampedT / 0.18) * 0.11;
        } else {
          final p = (clampedT - 0.18) / 0.82;
          final d = math.exp(-p * 5.0);
          smX = 0.11 * d * math.cos(p * math.pi * 8.0);
          smY = -0.11 * d * math.cos(p * math.pi * 8.0);
        }
        return AnimationTransformResult(positionX: smX * intensity, positionY: smY * intensity, scale: 1.03);

      case 'shake_anvil_hammer_strike':
        // Palu pandai besi di landasan baja: dentang tajam frekuensi tinggi + getaran logam
        final anDamp = math.exp(-clampedT * 4.5);
        final anX = math.sin(clampedT * math.pi * 28.0) * 0.07 * anDamp * intensity;
        final anY = -0.09 * anDamp * (clampedT < 0.15 ? (clampedT / 0.15) : 1.0) * intensity;
        return AnimationTransformResult(positionX: anX, positionY: anY, scale: 1.02);

      case 'shake_bowling_strike_impact':
        // Bola boling menabrak 10 pin: hentakan sentral diiringi getaran hamburan pin ke segala penjuru
        final bDamp = math.exp(-clampedT * 3.5);
        final bx = math.sin(clampedT * math.pi * 20.0) * 0.08 * bDamp * intensity;
        final by = math.cos(clampedT * math.pi * 24.0) * 0.06 * bDamp * intensity;
        return AnimationTransformResult(positionX: bx, positionY: by, scale: 1.0 + 0.04 * bDamp);

      case 'shake_heavy_vault_door_slam':
        // Pintu brankas bank menutup rapat berdentum: gerak lambat menutup -> BENTURAN KERAS -> hening kaku
        double slamY = 0.0;
        if (clampedT < 0.40) {
          slamY = (clampedT / 0.40) * 0.02; // Penutupan pelan
        } else {
          final p = (clampedT - 0.40) / 0.60;
          slamY = -0.14 * math.exp(-p * 6.5) * math.cos(p * math.pi * 10.0);
        }
        return AnimationTransformResult(positionY: slamY * intensity, scale: 1.03);

      case 'shake_heavy_iron_gate_clang':
        // Gerbang besi benteng menutup terbanting: getaran logam berat berdenting
        final clDamp = math.exp(-clampedT * 4.0);
        final clX = math.sin(clampedT * math.pi * 26.0) * 0.075 * clDamp * intensity;
        final clRot = math.sin(clampedT * math.pi * 22.0) * 2.8 * clDamp * intensity;
        return AnimationTransformResult(positionX: clX, rotationDegrees: clRot, scale: 1.02);

      case 'shake_battering_ram_strike':
        // Kayu pendobrak mendobrak pintu: dorongan maju besar -> BENTURAN -> mundur recoil
        double ramX = 0.0;
        if (clampedT < 0.25) {
          ramX = (clampedT / 0.25) * 0.14; // Menghantam ke depan
        } else {
          final p = (clampedT - 0.25) / 0.75;
          ramX = 0.14 * math.exp(-p * 4.5) * math.cos(p * math.pi * 6.0);
        }
        return AnimationTransformResult(positionX: ramX * intensity, scale: 1.04);

      // =========================================================================
      // 9. HIGH FREQUENCY MECHANICAL & CONSTRUCTION TOOLS (44-50)
      // =========================================================================
      case 'micro_jitter':
        // Getaran mikro halus frekuensi sangat tinggi (50Hz vibe)
        final mjX = math.sin(clampedT * math.pi * 50.0) * 0.018 * intensity;
        final mjY = math.cos(clampedT * math.pi * 46.0) * 0.018 * intensity;
        return AnimationTransformResult(positionX: mjX, positionY: mjY, scale: 1.01);

      case 'shake_jackhammer_rattle':
        // Bor jackhammer konstruksi: getaran vertikal frekuensi tinggi bertubi-tubi + sentakan ke bawah
        final jhStep = (clampedT * 18.0);
        final jhPhase = jhStep - jhStep.floor();
        final jhY = -math.sin(jhPhase * math.pi) * 0.05 * intensity;
        final jhX = (math.sin(clampedT * math.pi * 36.0) * 0.015) * intensity;
        return AnimationTransformResult(positionX: jhX, positionY: jhY, scale: 1.02);

      case 'shake_pneumatic_drill_burst':
        // Bor pneumatik udara: rentetan burst 3 pukulan cepat -> jeda -> rentetan burst 3 pukulan
        final burstCycle = (clampedT * 3.0);
        final bPhase = burstCycle - burstCycle.floor();
        double drillY = 0.0;
        if (bPhase < 0.6) {
          drillY = math.sin(bPhase / 0.6 * math.pi * 6.0) * 0.045;
        }
        return AnimationTransformResult(positionY: drillY * intensity, scale: 1.02);

      case 'shake_diesel_generator_hum':
        // Generator diesel stasioner: getaran konstan mantap dengan amplitudo teratur
        final genX = math.sin(clampedT * math.pi * 24.0) * 0.025 * intensity;
        final genY = math.cos(clampedT * math.pi * 24.0) * 0.015 * intensity;
        return AnimationTransformResult(positionX: genX, positionY: genY, scale: 1.015);

      case 'shake_hydraulic_press_crush':
        // Tekanan mesin hidrolik: gerakan lambat menekan ke bawah -> tahan getar maksimum saat memipihkan
        double pressY = 0.0;
        double pressScale = 1.0;
        if (clampedT < 0.50) {
          pressY = -(clampedT / 0.50) * 0.06;
        } else {
          final crushTremor = math.sin((clampedT - 0.50) * math.pi * 30.0) * 0.02;
          pressY = -0.06 + crushTremor;
          pressScale = 1.0 - (clampedT - 0.50) * 0.06;
        }
        return AnimationTransformResult(positionY: pressY * intensity, scale: pressScale);

      case 'shake_pile_driver_slam':
        // Mesin tiang pancang: beban diangkat lambat -> dijatuhkan DENTUMAN -> diam
        double pdY = 0.0;
        final pdCycle = (clampedT * 2.0);
        final pdPhase = pdCycle - pdCycle.floor();
        if (pdPhase < 0.70) {
          pdY = (pdPhase / 0.70) * 0.03; // Beban diangkat pelan ke atas
        } else {
          final hitP = (pdPhase - 0.70) / 0.30;
          pdY = -0.12 * math.exp(-hitP * 5.0) * math.cos(hitP * math.pi * 6.0);
        }
        return AnimationTransformResult(positionY: pdY * intensity, scale: 1.03);

      case 'shake_demolition_wrecking_ball':
        // Bola besi peremuk bangunan: ayunan bandul lebar -> TABRAKAN HANCUR di tengah -> ayunan terpental
        double wbX = 0.0;
        if (clampedT < 0.40) {
          wbX = math.sin(clampedT / 0.40 * math.pi * 0.5) * 0.15;
        } else {
          final p = (clampedT - 0.40) / 0.60;
          wbX = 0.15 * math.exp(-p * 4.0) * math.cos(p * math.pi * 6.0);
        }
        return AnimationTransformResult(positionX: wbX * intensity, scale: 1.03);

      // =========================================================================
      // 10. VEHICLES, TRAINS & ENGINES (51-60)
      // =========================================================================
      case 'vehicle_engine_vibe':
        // Mesin mobil sport revving: getaran RPM naik dari frekuensi 16Hz ke 32Hz
        final vFreq = 16.0 + clampedT * 20.0;
        final vx = math.sin(clampedT * math.pi * vFreq) * 0.025 * intensity;
        final vy = math.cos(clampedT * math.pi * vFreq) * 0.02 * intensity;
        return AnimationTransformResult(positionX: vx, positionY: vy, scale: 1.02);

      case 'shake_motorcycle_engine_idle':
        // Motor silinder besar posisi idle: pola deg-deg-deg berjarak (V-twin thumping)
        final idleCycle = (clampedT * 5.0);
        final idlePhase = idleCycle - idleCycle.floor();
        final idleY = (idlePhase < 0.25) ? math.sin(idlePhase / 0.25 * math.pi) * 0.04 : 0.0;
        final idleRot = (idlePhase < 0.25) ? math.sin(idlePhase / 0.25 * math.pi) * 1.5 : 0.0;
        return AnimationTransformResult(positionY: idleY * intensity, rotationDegrees: idleRot * intensity, scale: 1.02);

      case 'shake_heavy_tank_tread':
        // Rantai roda tank tempur: hentakan berat baja menabrak tanah secara berulang (clank-clank)
        final tankStep = (clampedT * 6.0);
        final tankPhase = tankStep - tankStep.floor();
        final tankY = -math.sin(tankPhase * math.pi) * 0.05 * intensity;
        final tankX = (math.sin(clampedT * math.pi * 12.0) * 0.02) * intensity;
        final tankRot = math.sin(clampedT * math.pi * 6.0) * 2.0 * intensity;
        return AnimationTransformResult(positionX: tankX, positionY: tankY, rotationDegrees: tankRot, scale: 1.03);

      case 'rough_offroad':
        // Mobil offroad di bebatuan: guncangan acak multi-arah dengan roll kemiringan tajam
        final offX = (math.sin(clampedT * math.pi * 14.0) * 0.05 + math.sin(clampedT * math.pi * 6.0) * 0.03) * intensity;
        final offY = (math.cos(clampedT * math.pi * 12.0) * 0.06 + math.cos(clampedT * math.pi * 4.0) * 0.04) * intensity;
        final offRot = math.sin(clampedT * math.pi * 8.0) * 4.5 * intensity;
        return AnimationTransformResult(positionX: offX, positionY: offY, rotationDegrees: offRot, scale: 1.04);

      case 'shake_subway_rail_click_clack':
        // Kereta melintasi celah rel: ritme khas klik-klak klik-klak ganda
        final railCycle = (clampedT * 3.0);
        final rPhase = railCycle - railCycle.floor();
        double rY = 0.0;
        if (rPhase < 0.15) {
          rY = math.sin(rPhase / 0.15 * math.pi) * 0.04;
        } else if (rPhase > 0.20 && rPhase < 0.35) {
          rY = math.sin((rPhase - 0.20) / 0.15 * math.pi) * 0.035;
        }
        return AnimationTransformResult(positionY: -rY * intensity, scale: 1.02);

      case 'shake_formula_one_curb_hop':
        // F1 melibas kerb tikungan: getaran vertikal frekuensi tinggi 40Hz saat ban menyentuh kerb bergerigi
        final curbY = math.sin(clampedT * math.pi * 44.0) * 0.045 * intensity;
        final curbRot = math.sin(clampedT * math.pi * 22.0) * 2.2 * intensity;
        return AnimationTransformResult(positionY: curbY, rotationDegrees: curbRot, scale: 1.02);

      case 'shake_speed_bump_hit_hard':
        // Mobil menghantam polisi tidur kencang: hentakan naik mendadak -> suspensi terlempar -> mantul redam
        double sbY = 0.0;
        if (clampedT < 0.20) {
          sbY = (clampedT / 0.20) * 0.14; // Terlempar naik
        } else {
          final p = (clampedT - 0.20) / 0.80;
          sbY = 0.14 * math.exp(-p * 4.5) * math.cos(p * math.pi * 6.0);
        }
        return AnimationTransformResult(positionY: sbY * intensity, scale: 1.03);

      case 'shake_train_derail_tumbler':
        // Gerbong kereta anjlok berguling: rotasi ekstrem bertubi-tubi + goncangan dahsyat
        final drX = math.sin(clampedT * math.pi * 10.0) * 0.09 * intensity;
        final drY = math.cos(clampedT * math.pi * 12.0) * 0.09 * intensity;
        final drRot = math.sin(clampedT * math.pi * 4.0) * 12.0 * intensity;
        return AnimationTransformResult(positionX: drX, positionY: drY, rotationDegrees: drRot, scale: 1.06);

      case 'shake_maglev_speed_pass':
        // Kereta maglev 500 km/j melintas: desakan angin kencang membelokkan kamera ke samping seketika
        final maglevX = math.sin(clampedT * math.pi * 3.0) * 0.10 * (1.0 - clampedT) * intensity;
        final maglevTremor = math.sin(clampedT * math.pi * 36.0) * 0.02 * intensity;
        return AnimationTransformResult(positionX: (maglevX + maglevTremor), scale: 1.03);

      case 'shake_jet_engine_reverse_thrust':
        // Pembalik daya mesin jet turbofan saat mendarat: getaran gemuruh intensitas tinggi konstan
        final jetX = math.sin(clampedT * math.pi * 28.0) * 0.035 * intensity;
        final jetY = math.cos(clampedT * math.pi * 32.0) * 0.03 * intensity;
        final jetScale = 1.02 + math.sin(clampedT * math.pi * 10.0) * 0.015 * intensity;
        return AnimationTransformResult(positionX: jetX, positionY: jetY, scale: jetScale);

      // =========================================================================
      // 11. AERONAUTICS, TURBULENCE & MARINE (61-68)
      // =========================================================================
      case 'turbulence_bump':
        // Turbulensi pesawat: anjlok kantung udara vertikal tiba-tiba lalu kembali tenang
        final turbY = (math.sin(clampedT * math.pi * 3.5) * 0.08 * (1.0 - clampedT * 0.5)) * intensity;
        final turbRot = math.sin(clampedT * math.pi * 2.5) * 3.5 * intensity;
        return AnimationTransformResult(positionY: turbY, rotationDegrees: turbRot, scale: 1.02);

      case 'shake_helicopter_rotor_wash':
        // Angin baling-baling helikopter: getaran ritmik 4-blade chopper + hembusan pusaran angin
        final chopY = math.sin(clampedT * math.pi * 24.0) * 0.035 * intensity;
        final chopX = math.cos(clampedT * math.pi * 12.0) * 0.04 * intensity;
        final chopRot = math.sin(clampedT * math.pi * 6.0) * 3.0 * intensity;
        return AnimationTransformResult(positionX: chopX, positionY: chopY, rotationDegrees: chopRot, scale: 1.03);

      case 'shake_speedboat_wake_bounce':
        // Speedboat membelah ombak: loncatan-loncatan beruntun terhempas ke atas lalu menghantam air
        final boatHop = (clampedT * 4.0);
        final bHopPhase = boatHop - boatHop.floor();
        final hopY = math.sin(bHopPhase * math.pi) * 0.065 * intensity;
        return AnimationTransformResult(positionY: -hopY, scale: 1.02);

      case 'shake_boat_stormy_seas':
        // Kapal di badai samudra: ayunan gelombang laut raksasa roll kemiringan lambat & dalam
        final waveRoll = math.sin(clampedT * math.pi * 1.5) * 8.5 * intensity;
        final wavePitch = math.cos(clampedT * math.pi * 1.2) * 0.06 * intensity;
        final waveSway = math.sin(clampedT * math.pi * 1.5) * 0.05 * intensity;
        return AnimationTransformResult(positionX: waveSway, positionY: wavePitch, rotationDegrees: waveRoll, scale: 1.04);

      case 'shake_paraglider_turbulence':
        // Parasut paralayang tertiup angin termal: goyangan mengapung seperti bandul melayang
        final paraRot = math.sin(clampedT * math.pi * 2.0) * 5.0 * intensity;
        final paraX = math.sin(clampedT * math.pi * 2.0) * 0.04 * intensity;
        return AnimationTransformResult(positionX: paraX, rotationDegrees: paraRot, scale: 1.02);

      case 'shake_aircraft_carrier_catapult':
        // Ketapel peluncur jet kapal induk: deselerasi diam -> tarikan percepatan G-force ekstrem ke depan
        double catX = 0.0;
        if (clampedT < 0.20) {
          catX = -(clampedT / 0.20) * 0.16;
        } else {
          final p = (clampedT - 0.20) / 0.80;
          catX = -0.16 * math.exp(-p * 3.5);
        }
        return AnimationTransformResult(positionX: catX * intensity, scale: 1.04);

      case 'shake_wind_gust_buffet':
        // Hempasan angin ribut tiba-tiba: dorongan lateral horizontal kuat lalu goyang tertahan
        final gust = math.sin(clampedT * math.pi * 4.0) * 0.07 * math.exp(-clampedT * 2.0);
        final gustRot = math.sin(clampedT * math.pi * 3.0) * 3.0 * math.exp(-clampedT * 2.0);
        return AnimationTransformResult(positionX: gust * intensity, rotationDegrees: gustRot * intensity, scale: 1.02);

      case 'shake_parachute_canopy_pop':
        // Parasut mengembang (opening shock): sentakan deselerasi vertikal ke atas sangat kuat
        double popY = 0.0;
        if (clampedT < 0.15) {
          popY = (clampedT / 0.15) * 0.15;
        } else {
          final p = (clampedT - 0.15) / 0.85;
          popY = 0.15 * math.exp(-p * 4.0) * math.cos(p * math.pi * 6.0);
        }
        return AnimationTransformResult(positionY: popY * intensity, scale: 1.03);

      // =========================================================================
      // 12. BASS, AUDIO SUBWOOFER & ACOUSTICS (69-72)
      // =========================================================================
      case 'heavy_rumble':
        // Gemuruh bass getaran berat frekuensi rendah (sub-bass 25Hz)
        final rx = math.sin(clampedT * math.pi * 14.0) * 0.045 * intensity;
        final ry = math.cos(clampedT * math.pi * 11.0) * 0.045 * intensity;
        final rScale = 1.03 + math.sin(clampedT * math.pi * 8.0) * 0.02 * intensity;
        return AnimationTransformResult(positionX: rx, positionY: ry, scale: rScale);

      case 'bass_boom_shake':
        // Dentuman subwoofer bass klub malam: ekspansi skala radial kuat + getaran X & Y
        final boomCycle = (clampedT * 3.0);
        final boomPhase = boomCycle - boomCycle.floor();
        final boomScale = 1.0 + (math.sin(boomPhase * math.pi) * 0.09 * intensity);
        final boomY = math.cos(clampedT * math.pi * 16.0) * 0.025 * intensity;
        return AnimationTransformResult(positionY: boomY, scale: boomScale);

      case 'shake_subwoofer_heavy_pulse':
        // Membran speaker subwoofer 20Hz: denyutan maju-mundur membran speaker (skala dinamis)
        final pulseS = 1.0 + (math.sin(clampedT * math.pi * 12.0) * 0.075 * intensity);
        return AnimationTransformResult(scale: pulseS);

      case 'shake_heavy_bass_kick_drum':
        // Hentakan ketukan kick drum pedal konser musik: 4x punch ketukan berulang
        final kickCycle = (clampedT * 4.0);
        final kPhase = kickCycle - kickCycle.floor();
        final kickScale = 1.0 + (math.sin(kPhase * math.pi) * 0.08 * (1.0 - kPhase) * intensity);
        final kickY = -math.sin(kPhase * math.pi) * 0.03 * intensity;
        return AnimationTransformResult(positionY: kickY, scale: kickScale);

      case 'shake_gong_deep_reverberation':
        // Resonansi gong perunggu raksasa: dentuman awal -> dengungan gelombang suara harmonik meluas
        final gongDamp = math.exp(-clampedT * 1.8);
        final gongScale = 1.0 + math.sin(clampedT * math.pi * 10.0) * 0.06 * gongDamp * intensity;
        final gongX = math.sin(clampedT * math.pi * 18.0) * 0.03 * gongDamp * intensity;
        return AnimationTransformResult(positionX: gongX, scale: gongScale);

      // =========================================================================
      // 13. CHAOTIC, CREATURE & STAMPEDE (73-77)
      // =========================================================================
      case 'footstep_thud':
        // Langkah kaki raksasa: interval langkah berat mengguncang tanah tiap 0.5 durasi
        final fCycle = (clampedT * 2.0);
        final fPhase = fCycle - fCycle.floor();
        final fThud = (fPhase < 0.20) ? -math.sin(fPhase / 0.20 * math.pi) * 0.10 : 0.0;
        return AnimationTransformResult(positionY: fThud * intensity, scale: 1.0 + (fThud.abs() * 0.4));

      case 'shake_giant_robot_footstep':
        // Hentakan robot mecha raksasa: langkah robot logam berat + getaran sekunder mekanik
        final mechaCycle = (clampedT * 2.0);
        final mPhase = mechaCycle - mechaCycle.floor();
        double mechaY = 0.0;
        if (mPhase < 0.25) {
          mechaY = -math.sin(mPhase / 0.25 * math.pi) * 0.12;
        } else {
          final p = (mPhase - 0.25) / 0.75;
          mechaY = -0.04 * math.exp(-p * 4.0) * math.cos(p * math.pi * 8.0);
        }
        return AnimationTransformResult(positionY: mechaY * intensity, scale: 1.04);

      case 'shake_rhino_charge_impact':
        // Serudukan badak bertanduk: tubrukan horizontal brutal langsung ke samping
        double rhinoX = 0.0;
        if (clampedT < 0.16) {
          rhinoX = (clampedT / 0.16) * 0.15;
        } else {
          final p = (clampedT - 0.16) / 0.84;
          rhinoX = 0.15 * math.exp(-p * 5.0) * math.cos(p * math.pi * 6.0);
        }
        return AnimationTransformResult(positionX: rhinoX * intensity, scale: 1.04);

      case 'shake_stampede_ground_rumble':
        // Ribuan hewan liar melintasi savana: getaran tanah tak beraturan frekuensi tinggi terus-menerus
        final stmpX = (math.sin(clampedT * math.pi * 22.0) * 0.04 + math.cos(clampedT * math.pi * 15.0) * 0.02) * intensity;
        final stmpY = (math.cos(clampedT * math.pi * 25.0) * 0.05 + math.sin(clampedT * math.pi * 11.0) * 0.02) * intensity;
        return AnimationTransformResult(positionX: stmpX, positionY: stmpY, scale: 1.03);

      case 'shake_avalanche_tumble':
        // Longsor salju bergulir: guncangan acak ke arah bawah dengan rotasi miring
        final avY = -(clampedT * 0.05) + math.sin(clampedT * math.pi * 16.0) * 0.04 * intensity;
        final avX = math.cos(clampedT * math.pi * 14.0) * 0.035 * intensity;
        final avRot = math.sin(clampedT * math.pi * 8.0) * 3.5 * intensity;
        return AnimationTransformResult(positionX: avX, positionY: avY, rotationDegrees: avRot, scale: 1.03);

      // =========================================================================
      // 14. SCI-FI, SPACE & COSMIC (78-83)
      // =========================================================================
      case 'shake_space_rocket_launch':
        // Peluncuran roket luar angkasa: getaran mesin roket dahsyat menggelegar dari frekuensi sedang ke tinggi
        final rocketFreq = 18.0 + clampedT * 18.0;
        final rkX = math.sin(clampedT * math.pi * rocketFreq) * 0.045 * intensity;
        final rkY = math.cos(clampedT * math.pi * rocketFreq) * 0.05 * intensity;
        return AnimationTransformResult(positionX: rkX, positionY: rkY, scale: 1.03);

      case 'shake_warp_drive_shudder':
        // Mesin warp loncat antariksa: getar frekuensi super tinggi + penyempitan ekspansi ruang
        final warpTremor = math.sin(clampedT * math.pi * 48.0) * 0.025 * intensity;
        final warpScale = 1.0 + math.sin(clampedT * math.pi * 4.0) * 0.08 * intensity;
        return AnimationTransformResult(positionX: warpTremor, scale: warpScale);

      case 'shake_meteor_entry_buffeting':
        // Meteor masuk atmosfer bumi: turbulensi gesekan udara panas bergejolak hebat
        final metX = math.sin(clampedT * math.pi * 20.0) * 0.055 * intensity;
        final metY = math.cos(clampedT * math.pi * 18.0) * 0.06 * intensity;
        final metRot = math.sin(clampedT * math.pi * 10.0) * 4.0 * intensity;
        return AnimationTransformResult(positionX: metX, positionY: metY, rotationDegrees: metRot, scale: 1.04);

      case 'shake_asteroid_crater_impact':
        // Tumbukan asteroid ke planet: kehancuran global benturan terdalam, guncangan berskala kolosal
        final astDamp = math.exp(-clampedT * 2.8);
        final astX = math.sin(clampedT * math.pi * 14.0) * 0.14 * astDamp * intensity;
        final astY = math.cos(clampedT * math.pi * 12.0) * 0.12 * astDamp * intensity;
        final astScale = 1.0 + (0.16 * astDamp * intensity);
        final astFlash = (clampedT < 0.25) ? (1.0 - clampedT / 0.25) * 0.8 * intensity : 0.0;
        return AnimationTransformResult(positionX: astX, positionY: astY, scale: astScale, flashOpacity: astFlash);

      case 'shake_elevator_cable_snap':
        // Kabel lift putus terperosok: jatuh bebas mendadak lalu cengkeraman rem darurat menyentak keras
        double elY = 0.0;
        if (clampedT < 0.35) {
          elY = -(clampedT / 0.35) * 0.18; // Terperosok jatuh
        } else {
          final p = (clampedT - 0.35) / 0.65;
          elY = -0.18 * math.exp(-p * 6.0) * math.cos(p * math.pi * 8.0); // Rem darurat mencengkeram
        }
        return AnimationTransformResult(positionY: elY * intensity, scale: 1.04);

      case 'shake_bungee_cord_snapback':
        // Pantulan tali bungee lentur: hentakan elastis osilasi pegas sinusoidal bolak-balik
        final bgY = math.sin(clampedT * math.pi * 6.0) * 0.12 * math.exp(-clampedT * 3.0) * intensity;
        return AnimationTransformResult(positionY: bgY, scale: 1.0 + (bgY.abs() * 0.3));

      // =========================================================================
      // 15. WATER, OCEAN & FLUID DYNAMICS (84-86)
      // =========================================================================
      case 'shake_tsunami_surge_push':
        // Gelombang tsunami menghantam: dorongan massa air raksasa ke depan terus-menerus
        final tsuX = math.sin(clampedT * math.pi * 2.0) * 0.11 * intensity;
        final tsuY = math.cos(clampedT * math.pi * 1.5) * 0.05 * intensity;
        return AnimationTransformResult(positionX: tsuX, positionY: tsuY, scale: 1.05);

      case 'shake_glacier_calving_splash':
        // Runtuhan es gletser ke laut: debukan vertikal besar lalu gelombang air bergulir
        final splashDamp = math.exp(-clampedT * 3.0);
        final glY = -math.sin(clampedT * math.pi * 8.0) * 0.10 * splashDamp * intensity;
        final glX = math.cos(clampedT * math.pi * 6.0) * 0.06 * splashDamp * intensity;
        return AnimationTransformResult(positionX: glX, positionY: glY, scale: 1.03);

      case 'shake_water_canon_blast':
        // Semburan meriam air ribuan psi: hentakan dorongan berkelanjutan ke arah belakang
        final wcTremor = math.sin(clampedT * math.pi * 28.0) * 0.03 * intensity;
        final wcX = -0.06 * intensity + wcTremor;
        return AnimationTransformResult(positionX: wcX, scale: 1.02);

      case 'shake_icebreaker_hull_ram':
        // Kapal pemecah es menabrak bongkahan es: dorongan naik melindas es -> es pecah terperosok ke bawah
        final iceCycle = (clampedT * 2.5);
        final icePhase = iceCycle - iceCycle.floor();
        final iceY = math.sin(icePhase * math.pi * 2.0) * 0.065 * intensity;
        final iceRot = math.cos(icePhase * math.pi * 2.0) * 2.5 * intensity;
        return AnimationTransformResult(positionY: iceY, rotationDegrees: iceRot, scale: 1.03);

      // =========================================================================
      // 16. AMUSEMENT, ROLLERCOASTER & COLLAPSE (87-90)
      // =========================================================================
      case 'shake_rollercoaster_wooden_rattle':
        // Rollercoaster kayu: getaran sambungan balok kayu frekuensi tinggi berguncang kasar
        final rcX = math.sin(clampedT * math.pi * 26.0) * 0.045 * intensity;
        final rcY = math.cos(clampedT * math.pi * 22.0) * 0.05 * intensity;
        final rcRot = math.sin(clampedT * math.pi * 12.0) * 3.0 * intensity;
        return AnimationTransformResult(positionX: rcX, positionY: rcY, rotationDegrees: rcRot, scale: 1.03);

      case 'shake_bridge_cable_sway':
        // Kabel jembatan gantung tertiup badai: ayunan resonansi harmonik lambat (Tacoma Narrows sway)
        final brRot = math.sin(clampedT * math.pi * 2.5) * 6.5 * intensity;
        final brY = math.sin(clampedT * math.pi * 2.5) * 0.045 * intensity;
        return AnimationTransformResult(positionY: brY, rotationDegrees: brRot, scale: 1.02);

      case 'shake_monument_topple_crash':
        // Patung monumen roboh ke tanah: miring jatuh lambat -> HANTAMAN TANAH BERGETAR
        double mnRot = 0.0;
        double mnY = 0.0;
        if (clampedT < 0.45) {
          final p = clampedT / 0.45;
          mnRot = 8.0 * (p * p);
        } else {
          final p = (clampedT - 0.45) / 0.55;
          final d = math.exp(-p * 5.0);
          mnRot = 8.0 * d;
          mnY = -0.12 * d * math.cos(p * math.pi * 8.0);
        }
        return AnimationTransformResult(positionY: mnY * intensity, rotationDegrees: mnRot * intensity, scale: 1.04);

      case 'shake_wrecking_crane_lurch':
        // Derek kabel baja tersentak beban: tarikan kabel tegang menyentak vertikal bolak-balik
        final craneY = math.sin(clampedT * math.pi * 7.0) * 0.08 * math.exp(-clampedT * 2.5) * intensity;
        return AnimationTransformResult(positionY: craneY, scale: 1.02);

      case 'shake_jackpot_coin_avalanche':
        // Koin jackpot kasino berhamburan: ketukan koin logam frekuensi tinggi tak beraturan
        final jpStep = (clampedT * 20.0).floor();
        final jpX = (((jpStep * 13) % 9) - 4) / 90.0 * intensity;
        final jpY = (((jpStep * 29) % 9) - 4) / 90.0 * intensity;
        return AnimationTransformResult(positionX: jpX, positionY: jpY, scale: 1.02);

      // =========================================================================
      // 17. RHYTHMIC, HORROR, WAVE & DRIFT (91-100)
      // =========================================================================
      case 'subtle_drift_shake':
        // Goyangan melayang halus: gerakan lissajous mengapung santai
        final drX = math.sin(clampedT * math.pi * 1.5) * 0.025 * intensity;
        final drY = math.cos(clampedT * math.pi * 2.0) * 0.02 * intensity;
        return AnimationTransformResult(positionX: drX, positionY: drY, scale: 1.01);

      case 'glitch_shiver':
        // Getar glitch patah: pergeseran horizontal diskrit stepped step-hold
        final gStep = (clampedT * 12.0).floor();
        final gx = (gStep % 2 == 0 ? 0.04 : -0.04) * intensity;
        final gSplit = (gStep % 3 == 0) ? 0.03 * intensity : 0.0;
        return AnimationTransformResult(positionX: gx, chromaticAberration: gSplit, scale: 1.02);

      case 'staccato_bounce':
        // Hentakan staccato patah-patah ritmik: langkah tangga berdetak
        final staccato = math.sin((clampedT * 8.0).floor() * math.pi * 0.5) * 0.04 * intensity;
        return AnimationTransformResult(positionY: staccato, scale: 1.02);

      case 'wobble_wave':
        // Gelombang goyang mengayun: gelombang sinus ganda berfase geser
        final wwX = math.sin(clampedT * math.pi * 4.0) * 0.05 * intensity;
        final wwRot = math.cos(clampedT * math.pi * 4.0) * 3.5 * intensity;
        return AnimationTransformResult(positionX: wwX, rotationDegrees: wwRot, scale: 1.02);

      case 'pulse_jitter':
        // Denyut getar teratur memicu ketegangan: getaran berdenyut mengecil-membesar
        final envelope = (math.sin(clampedT * math.pi * 4.0).abs());
        final pjX = math.sin(clampedT * math.pi * 32.0) * 0.04 * envelope * intensity;
        return AnimationTransformResult(positionX: pjX, scale: 1.0 + envelope * 0.03);

      case 'tremble_horror':
        // Getaran panik horor: gemetar halus frekuensi tinggi dengan amplitude gelisah
        final hX = math.sin(clampedT * math.pi * 38.0) * 0.025 * intensity;
        final hY = math.cos(clampedT * math.pi * 34.0) * 0.02 * intensity;
        final hRot = math.sin(clampedT * math.pi * 26.0) * 1.5 * intensity;
        return AnimationTransformResult(positionX: hX, positionY: hY, rotationDegrees: hRot, scale: 1.02);

      // Fallback spesifik jika ada ID variasi baru
      default:
        // Gunakan parameter turunan berbasis karakter ID tanpa rumus fallback acak datar
        final isVertical = id.contains('vert') || id.contains('drop') || id.contains('thud') || id.contains('slam');
        final isImpact = id.contains('hit') || id.contains('strike') || id.contains('crash') || id.contains('blast');
        final d = isImpact ? math.exp(-clampedT * 4.0) : 1.0;
        final freq = 16.0;
        final val = math.sin(clampedT * math.pi * freq) * 0.05 * d * intensity;
        return isVertical
            ? AnimationTransformResult(positionY: val, scale: 1.02)
            : AnimationTransformResult(positionX: val, scale: 1.02);
    }
  }
}

