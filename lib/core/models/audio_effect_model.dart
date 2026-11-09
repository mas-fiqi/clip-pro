/// Preset Efek Suara (Voice Effects)
enum VoiceEffectType {
  none,
  robot,
  deepVoice,
  chipmunk,
  echo,
  reverb,
  telephone,
  radio,
  megaphone,
  monster,
  reverse,
  pitchUp,
  pitchDown,
}

/// Preset Equalizer
enum EqualizerPreset {
  normal,
  bassBoost,
  vocal,
  podcast,
  music,
  treble,
  custom,
}

/// Model Pengaturan Audio Studio & Voice Enhancement per Klip Video / Audio
class AudioEffectModel {
  // A. Voice Effects
  final VoiceEffectType voiceEffect;
  final double voiceEffectIntensity; // 0.0 s/d 1.0 (default 1.0)

  // B. Voice Enhancement
  final bool noiseReduction;         // Pengurangan kebisingan latar
  final double noiseReductionAmount; // 0.0 s/d 1.0 (intensitas nr)
  final bool voiceClarity;           // Peningkatan kejelasan vokal (high-mid presence)
  final bool deEcho;                 // Peredam pantulan gema ruangan
  final bool audioNormalization;     // Penyesuaian volume standar EBU R128 (-16 LUFS)
  final bool compressor;             // Kontrol dinamika rentang suara
  final bool limiter;                // Mencegah distorsi & clipping puncak suara

  // C. Audio Adjustment
  final double volume;               // 0.0 s/d 2.0 (default 1.0 = 100%)
  final double pitch;                // 0.5 s/d 2.0 (default 1.0)
  final double speed;                // 0.5 s/d 2.0 (default 1.0)
  final double bass;                 // -10.0 dB s/d +10.0 dB (default 0.0)
  final double treble;               // -10.0 dB s/d +10.0 dB (default 0.0)
  final double fadeInSeconds;        // Durasi fade in awal (detik)
  final double fadeOutSeconds;       // Durasi fade out akhir (detik)
  final double stereoBalance;        // -1.0 (Kiri murni) s/d +1.0 (Kanan murni), default 0.0 (Tengah)
  final EqualizerPreset eqPreset;    // Preset EQ pilihan

  const AudioEffectModel({
    this.voiceEffect = VoiceEffectType.none,
    this.voiceEffectIntensity = 1.0,
    this.noiseReduction = false,
    this.noiseReductionAmount = 0.5,
    this.voiceClarity = false,
    this.deEcho = false,
    this.audioNormalization = false,
    this.compressor = false,
    this.limiter = false,
    this.volume = 1.0,
    this.pitch = 1.0,
    this.speed = 1.0,
    this.bass = 0.0,
    this.treble = 0.0,
    this.fadeInSeconds = 0.0,
    this.fadeOutSeconds = 0.0,
    this.stereoBalance = 0.0,
    this.eqPreset = EqualizerPreset.normal,
  });

  bool get hasActiveEffects =>
      voiceEffect != VoiceEffectType.none ||
      noiseReduction ||
      voiceClarity ||
      deEcho ||
      audioNormalization ||
      compressor ||
      limiter ||
      volume != 1.0 ||
      pitch != 1.0 ||
      speed != 1.0 ||
      bass != 0.0 ||
      treble != 0.0 ||
      fadeInSeconds > 0.0 ||
      fadeOutSeconds > 0.0 ||
      stereoBalance != 0.0 ||
      eqPreset != EqualizerPreset.normal;

  /// Membangun rantai filter FFmpeg audio (-af)
  String buildFFmpegAudioFilters({double clipDuration = 0.0}) {
    final List<String> filters = [];

    // 1. Voice Effects
    switch (voiceEffect) {
      case VoiceEffectType.robot:
        // Flanger & vibrato ring modulasi robotik
        filters.add('flanger=delay=5:depth=2:regen=50:width=70:speed=0.5');
        break;
      case VoiceEffectType.deepVoice:
        // Pitch turun 0.7x + perkuat bass
        filters.add('asetrate=44100*0.75,atempo=1.333,equalizer=f=120:width_type=h:width=100:g=6');
        break;
      case VoiceEffectType.chipmunk:
        // Pitch naik 1.4x suara tupai kartun
        filters.add('asetrate=44100*1.4,atempo=0.714');
        break;
      case VoiceEffectType.echo:
        // Echo berulang 500ms
        filters.add('aecho=0.8:0.88:400:0.4');
        break;
      case VoiceEffectType.reverb:
        // Reverb ruang konser luas
        filters.add('aecho=0.8:0.9:1000:0.3');
        break;
      case VoiceEffectType.telephone:
        // Bandpass frekuensi telepon 300Hz - 3400Hz
        filters.add('highpass=f=300,lowpass=f=3400');
        break;
      case VoiceEffectType.radio:
        // Radio vintage AM/FM dengan kompresi frekuensi sempit
        filters.add('highpass=f=400,lowpass=f=4500,acrusher=bits=12:mode=lin');
        break;
      case VoiceEffectType.megaphone:
        // Suara toa pengeras suara beresonansi
        filters.add('highpass=f=500,lowpass=f=3000,volume=1.8,alimiter=limit=0.9');
        break;
      case VoiceEffectType.monster:
        // Suara monster seram sangat berat
        filters.add('asetrate=44100*0.65,atempo=1.538,equalizer=f=80:width_type=h:width=80:g=8');
        break;
      case VoiceEffectType.reverse:
        // Membalikkan audio (mundur)
        filters.add('areverse');
        break;
      case VoiceEffectType.pitchUp:
        filters.add('asetrate=44100*1.25,atempo=0.8');
        break;
      case VoiceEffectType.pitchDown:
        filters.add('asetrate=44100*0.85,atempo=1.176');
        break;
      case VoiceEffectType.none:
        break;
    }

    // 2. Voice Enhancement
    if (noiseReduction) {
      // Highpass membuang hum frekuensi rendah (di bawah 120Hz) dan lowpass desis (di atas 10kHz)
      final lp = (12000 - (noiseReductionAmount * 4000)).toInt();
      filters.add('highpass=f=120,lowpass=f=$lp,afftdn=nf=-25');
    }

    if (voiceClarity) {
      // Dongkrak presence pita vokal manusia di 3kHz sebesar 4dB
      filters.add('equalizer=f=3000:width_type=h:width=1200:g=4');
    }

    if (deEcho) {
      // Mengurangi pantulan dengung ruangan via gate dinamis
      filters.add('agate=threshold=0.08:range=0.1:decay=150');
    }

    // 3. Equalizer & Tone
    switch (eqPreset) {
      case EqualizerPreset.bassBoost:
        filters.add('equalizer=f=80:width_type=h:width=80:g=6');
        break;
      case EqualizerPreset.vocal:
        filters.add('equalizer=f=1000:width_type=h:width=800:g=3,equalizer=f=3200:width_type=h:width=1000:g=4');
        break;
      case EqualizerPreset.podcast:
        filters.add('highpass=f=80,equalizer=f=2500:width_type=h:width=1000:g=3');
        break;
      case EqualizerPreset.music:
        filters.add('equalizer=f=60:width_type=h:width=60:g=3,equalizer=f=12000:width_type=h:width=4000:g=3');
        break;
      case EqualizerPreset.treble:
        filters.add('equalizer=f=8000:width_type=h:width=3000:g=6');
        break;
      case EqualizerPreset.custom:
        if (bass != 0.0) filters.add('equalizer=f=100:width_type=h:width=100:g=$bass');
        if (treble != 0.0) filters.add('equalizer=f=8000:width_type=h:width=3000:g=$treble');
        break;
      case EqualizerPreset.normal:
        if (bass != 0.0) filters.add('equalizer=f=100:width_type=h:width=100:g=$bass');
        if (treble != 0.0) filters.add('equalizer=f=8000:width_type=h:width=3000:g=$treble');
        break;
    }

    // 4. Compressor & Dynamic Limiter
    if (compressor) {
      filters.add('acompressor=threshold=0.125:ratio=4:attack=20:release=250');
    }

    if (limiter) {
      filters.add('alimiter=limit=0.95:level=true');
    }

    // 5. Volume & Normalisasi
    if (audioNormalization) {
      // EBU R128 loudness standard
      filters.add('loudnorm=I=-16:TP=-1.5:LRA=11');
    } else if (volume != 1.0) {
      filters.add('volume=$volume');
    }

    // 6. Stereo Balance
    if (stereoBalance != 0.0) {
      final leftGain = (1.0 - stereoBalance).clamp(0.0, 1.0);
      final rightGain = (1.0 + stereoBalance).clamp(0.0, 1.0);
      filters.add('pan=stereo|c0=$leftGain*c0|c1=$rightGain*c1');
    }

    // 7. Fade In & Fade Out
    if (fadeInSeconds > 0.0) {
      filters.add('afade=t=in:ss=0:d=$fadeInSeconds');
    }
    if (fadeOutSeconds > 0.0 && clipDuration > fadeOutSeconds) {
      final startFadeOut = clipDuration - fadeOutSeconds;
      filters.add('afade=t=out:st=$startFadeOut:d=$fadeOutSeconds');
    }

    return filters.join(',');
  }

  AudioEffectModel copyWith({
    VoiceEffectType? voiceEffect,
    double? voiceEffectIntensity,
    bool? noiseReduction,
    double? noiseReductionAmount,
    bool? voiceClarity,
    bool? deEcho,
    bool? audioNormalization,
    bool? compressor,
    bool? limiter,
    double? volume,
    double? pitch,
    double? speed,
    double? bass,
    double? treble,
    double? fadeInSeconds,
    double? fadeOutSeconds,
    double? stereoBalance,
    EqualizerPreset? eqPreset,
  }) {
    return AudioEffectModel(
      voiceEffect: voiceEffect ?? this.voiceEffect,
      voiceEffectIntensity: voiceEffectIntensity ?? this.voiceEffectIntensity,
      noiseReduction: noiseReduction ?? this.noiseReduction,
      noiseReductionAmount: noiseReductionAmount ?? this.noiseReductionAmount,
      voiceClarity: voiceClarity ?? this.voiceClarity,
      deEcho: deEcho ?? this.deEcho,
      audioNormalization: audioNormalization ?? this.audioNormalization,
      compressor: compressor ?? this.compressor,
      limiter: limiter ?? this.limiter,
      volume: volume ?? this.volume,
      pitch: pitch ?? this.pitch,
      speed: speed ?? this.speed,
      bass: bass ?? this.bass,
      treble: treble ?? this.treble,
      fadeInSeconds: fadeInSeconds ?? this.fadeInSeconds,
      fadeOutSeconds: fadeOutSeconds ?? this.fadeOutSeconds,
      stereoBalance: stereoBalance ?? this.stereoBalance,
      eqPreset: eqPreset ?? this.eqPreset,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voiceEffect': voiceEffect.name,
      'voiceEffectIntensity': voiceEffectIntensity,
      'noiseReduction': noiseReduction,
      'noiseReductionAmount': noiseReductionAmount,
      'voiceClarity': voiceClarity,
      'deEcho': deEcho,
      'audioNormalization': audioNormalization,
      'compressor': compressor,
      'limiter': limiter,
      'volume': volume,
      'pitch': pitch,
      'speed': speed,
      'bass': bass,
      'treble': treble,
      'fadeInSeconds': fadeInSeconds,
      'fadeOutSeconds': fadeOutSeconds,
      'stereoBalance': stereoBalance,
      'eqPreset': eqPreset.name,
    };
  }

  factory AudioEffectModel.fromJson(Map<String, dynamic> json) {
    return AudioEffectModel(
      voiceEffect: VoiceEffectType.values.firstWhere(
        (e) => e.name == json['voiceEffect'],
        orElse: () => VoiceEffectType.none,
      ),
      voiceEffectIntensity: (json['voiceEffectIntensity'] as num?)?.toDouble() ?? 1.0,
      noiseReduction: json['noiseReduction'] as bool? ?? false,
      noiseReductionAmount: (json['noiseReductionAmount'] as num?)?.toDouble() ?? 0.5,
      voiceClarity: json['voiceClarity'] as bool? ?? false,
      deEcho: json['deEcho'] as bool? ?? false,
      audioNormalization: json['audioNormalization'] as bool? ?? false,
      compressor: json['compressor'] as bool? ?? false,
      limiter: json['limiter'] as bool? ?? false,
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      pitch: (json['pitch'] as num?)?.toDouble() ?? 1.0,
      speed: (json['speed'] as num?)?.toDouble() ?? 1.0,
      bass: (json['bass'] as num?)?.toDouble() ?? 0.0,
      treble: (json['treble'] as num?)?.toDouble() ?? 0.0,
      fadeInSeconds: (json['fadeInSeconds'] as num?)?.toDouble() ?? 0.0,
      fadeOutSeconds: (json['fadeOutSeconds'] as num?)?.toDouble() ?? 0.0,
      stereoBalance: (json['stereoBalance'] as num?)?.toDouble() ?? 0.0,
      eqPreset: EqualizerPreset.values.firstWhere(
        (e) => e.name == json['eqPreset'],
        orElse: () => EqualizerPreset.normal,
      ),
    );
  }
}
