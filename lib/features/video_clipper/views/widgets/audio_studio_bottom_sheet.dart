import 'package:flutter/material.dart';
import '../../../../core/models/audio_effect_model.dart';
import '../../../../core/models/clip_model.dart';
import '../../../../core/theme/app_design_tokens.dart';

class AudioStudioBottomSheet extends StatefulWidget {
  final ClipModel clip;

  const AudioStudioBottomSheet({super.key, required this.clip});

  static Future<AudioEffectModel?> show(BuildContext context, {required ClipModel clip}) {
    return showModalBottomSheet<AudioEffectModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AudioStudioBottomSheet(clip: clip),
    );
  }

  @override
  State<AudioStudioBottomSheet> createState() => _AudioStudioBottomSheetState();
}

class _AudioStudioBottomSheetState extends State<AudioStudioBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AudioEffectModel _audioEffect;
  bool _isPlayingPreview = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _audioEffect = widget.clip.audioEffect;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _resetAll() {
    setState(() {
      _audioEffect = const AudioEffectModel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: AppDesignTokens.surfacePrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDesignTokens.radiusL)),
        border: Border.all(color: AppDesignTokens.borderSubtle, width: 1),
        boxShadow: AppDesignTokens.softShadow,
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header Navigation Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppDesignTokens.textSecondary, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Audio Studio & Voice FX',
                        style: TextStyle(
                          color: AppDesignTokens.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      Text(
                        'Voice Filters, DSP Enhancement, Equalizer & Tone',
                        style: TextStyle(
                          color: AppDesignTokens.textMuted,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Preview Quick Toggle
                InkWell(
                  onTap: () {
                    setState(() => _isPlayingPreview = !_isPlayingPreview);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isPlayingPreview ? '▶️ Memutar preview audio...' : '⏸️ Preview dihentikan'),
                        duration: const Duration(milliseconds: 700),
                        backgroundColor: AppDesignTokens.surfaceSecondary,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(AppDesignTokens.radiusM),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isPlayingPreview
                          ? AppDesignTokens.cyanAccent.withValues(alpha: 0.2)
                          : AppDesignTokens.surfaceSecondary,
                      borderRadius: BorderRadius.circular(AppDesignTokens.radiusM),
                      border: Border.all(
                        color: _isPlayingPreview ? AppDesignTokens.cyanAccent : AppDesignTokens.borderGlass,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isPlayingPreview ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 15,
                          color: _isPlayingPreview ? AppDesignTokens.cyanAccent : Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isPlayingPreview ? 'Putar' : 'Tes',
                          style: TextStyle(
                            color: _isPlayingPreview ? AppDesignTokens.cyanAccent : Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Reset Action
                TextButton(
                  onPressed: _resetAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('Reset', style: TextStyle(color: AppDesignTokens.redAccent, fontSize: 12)),
                ),
                const SizedBox(width: 6),

                // Terapkan Gradient Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDesignTokens.cyanAccent,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDesignTokens.radiusS)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(_audioEffect);
                  },
                  child: const Text('Terapkan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 4-Module Segmented Navigation
          Container(
            height: 38,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppDesignTokens.surfaceSecondary,
              borderRadius: BorderRadius.circular(AppDesignTokens.radiusM),
              border: Border.all(color: AppDesignTokens.borderGlass, width: 1),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: AppDesignTokens.primaryGradient,
                borderRadius: BorderRadius.circular(AppDesignTokens.radiusM - 3),
                boxShadow: AppDesignTokens.glowShadow(AppDesignTokens.cyanAccent),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.black,
              unselectedLabelColor: AppDesignTokens.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11.5),
              tabs: const [
                Tab(text: 'Voice FX'),
                Tab(text: 'Enhance'),
                Tab(text: 'Equalizer'),
                Tab(text: 'Adjust'),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVoiceEffectsTab(),
                _buildEnhanceVoiceTab(),
                _buildEqualizerTab(),
                _buildAdjustTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 1: VOICE EFFECTS ---
  Widget _buildVoiceEffectsTab() {
    final effects = [
      {'type': VoiceEffectType.none, 'name': 'Asli', 'desc': 'Suara normal tanpa efek', 'icon': Icons.mic_rounded},
      {'type': VoiceEffectType.robot, 'name': 'Robot', 'desc': 'Modulasi flanger mekanis', 'icon': Icons.smart_toy_rounded},
      {'type': VoiceEffectType.deepVoice, 'name': 'Deep Voice', 'desc': 'Suara berat & berwibawa', 'icon': Icons.record_voice_over_rounded},
      {'type': VoiceEffectType.chipmunk, 'name': 'Chipmunk', 'desc': 'Suara tupai tinggi kartun', 'icon': Icons.cruelty_free_rounded},
      {'type': VoiceEffectType.echo, 'name': 'Echo', 'desc': 'Gema pantulan berulang', 'icon': Icons.surround_sound_rounded},
      {'type': VoiceEffectType.reverb, 'name': 'Reverb', 'desc': 'Akustik ruang aula konser', 'icon': Icons.stadium_rounded},
      {'type': VoiceEffectType.telephone, 'name': 'Telephone', 'desc': 'Frekuensi telepon jadul', 'icon': Icons.phone_in_talk_rounded},
      {'type': VoiceEffectType.radio, 'name': 'Radio', 'desc': 'Siaran radio analog vintage', 'icon': Icons.radio_rounded},
      {'type': VoiceEffectType.megaphone, 'name': 'Megaphone', 'desc': 'Toa pengeras suara jalan', 'icon': Icons.campaign_rounded},
      {'type': VoiceEffectType.monster, 'name': 'Monster', 'desc': 'Suara monster gelap seram', 'icon': Icons.pest_control_rodent_rounded},
      {'type': VoiceEffectType.reverse, 'name': 'Reverse', 'desc': 'Putar balik suara ke belakang', 'icon': Icons.fast_rewind_rounded},
      {'type': VoiceEffectType.pitchUp, 'name': 'Pitch Up', 'desc': 'Nada dinaikkan +25%', 'icon': Icons.trending_up_rounded},
      {'type': VoiceEffectType.pitchDown, 'name': 'Pitch Down', 'desc': 'Nada diturunkan -20%', 'icon': Icons.trending_down_rounded},
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        if (_audioEffect.voiceEffect != VoiceEffectType.none) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppDesignTokens.surfaceSecondary,
              borderRadius: BorderRadius.circular(AppDesignTokens.radiusM),
              border: Border.all(color: AppDesignTokens.cyanAccent.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Text('Intensitas Efek:', style: TextStyle(color: AppDesignTokens.textSecondary, fontSize: 12)),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppDesignTokens.cyanAccent,
                      inactiveTrackColor: Colors.white12,
                      thumbColor: Colors.white,
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: _audioEffect.voiceEffectIntensity,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (v) => setState(() => _audioEffect = _audioEffect.copyWith(voiceEffectIntensity: v)),
                    ),
                  ),
                ),
                Text(
                  '${(_audioEffect.voiceEffectIntensity * 100).toInt()}%',
                  style: const TextStyle(color: AppDesignTokens.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.96,
          ),
          itemCount: effects.length,
          itemBuilder: (context, index) {
            final item = effects[index];
            final type = item['type'] as VoiceEffectType;
            final isSel = _audioEffect.voiceEffect == type;

            return InkWell(
              onTap: () => setState(() => _audioEffect = _audioEffect.copyWith(voiceEffect: type)),
              borderRadius: BorderRadius.circular(AppDesignTokens.radiusM),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSel ? AppDesignTokens.surfaceElevated : AppDesignTokens.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppDesignTokens.radiusM),
                  border: Border.all(
                    color: isSel ? AppDesignTokens.cyanAccent : AppDesignTokens.borderGlass,
                    width: isSel ? 1.5 : 1,
                  ),
                  boxShadow: isSel ? AppDesignTokens.glowShadow(AppDesignTokens.cyanAccent) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSel ? AppDesignTokens.cyanAccent.withValues(alpha: 0.2) : const Color(0xFF222638),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        size: 22,
                        color: isSel ? AppDesignTokens.cyanAccent : Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['name'] as String,
                      style: TextStyle(
                        color: isSel ? AppDesignTokens.cyanAccent : Colors.white,
                        fontSize: 11.5,
                        fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['desc'] as String,
                      style: TextStyle(color: AppDesignTokens.textMuted, fontSize: 8.5),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // --- TAB 2: VOICE ENHANCEMENT ---
  Widget _buildEnhanceVoiceTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        _buildEnhanceToggle(
          title: 'Noise Reduction (Peredam Bising)',
          subtitle: 'Menghilangkan suara gemuruh kipas, hembusan angin, & desis mic',
          icon: Icons.noise_aware_rounded,
          value: _audioEffect.noiseReduction,
          onChanged: (v) => setState(() => _audioEffect = _audioEffect.copyWith(noiseReduction: v)),
        ),
        if (_audioEffect.noiseReduction)
          Padding(
            padding: const EdgeInsets.only(left: 48, right: 12, bottom: 8),
            child: Row(
              children: [
                const Text('Level:', style: TextStyle(color: AppDesignTokens.textSecondary, fontSize: 11)),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppDesignTokens.cyanAccent,
                      inactiveTrackColor: Colors.white12,
                      thumbColor: Colors.white,
                      trackHeight: 2.5,
                    ),
                    child: Slider(
                      value: _audioEffect.noiseReductionAmount,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (v) => setState(() => _audioEffect = _audioEffect.copyWith(noiseReductionAmount: v)),
                    ),
                  ),
                ),
                Text(
                  '${(_audioEffect.noiseReductionAmount * 100).toInt()}%',
                  style: const TextStyle(color: AppDesignTokens.cyanAccent, fontSize: 11, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        _buildEnhanceToggle(
          title: 'Voice Clarity (Kejelasan Vokal)',
          subtitle: 'Meningkatkan frekuensi artikulasi ucapan agar terdengar tajam & jernih',
          icon: Icons.graphic_eq_rounded,
          value: _audioEffect.voiceClarity,
          onChanged: (v) => setState(() => _audioEffect = _audioEffect.copyWith(voiceClarity: v)),
        ),
        const SizedBox(height: 8),
        _buildEnhanceToggle(
          title: 'De-Echo (Peredam Dengung Ruangan)',
          subtitle: 'Mengurangi pantulan gema ruangan kosong pada rekaman suara vokal',
          icon: Icons.hearing_rounded,
          value: _audioEffect.deEcho,
          onChanged: (v) => setState(() => _audioEffect = _audioEffect.copyWith(deEcho: v)),
        ),
        const SizedBox(height: 8),
        _buildEnhanceToggle(
          title: 'Audio Normalization (EBU R128)',
          subtitle: 'Menyeimbangkan tingkatan dinamika desibel standar broadcast siaran',
          icon: Icons.volume_up_rounded,
          value: _audioEffect.audioNormalization,
          onChanged: (v) => setState(() => _audioEffect = _audioEffect.copyWith(audioNormalization: v)),
        ),
        const SizedBox(height: 8),
        _buildEnhanceToggle(
          title: 'Dynamic Compressor',
          subtitle: 'Merapikan rentang perbedaan volume lembut & keras agar konsisten',
          icon: Icons.compress_rounded,
          value: _audioEffect.compressor,
          onChanged: (v) => setState(() => _audioEffect = _audioEffect.copyWith(compressor: v)),
        ),
        const SizedBox(height: 8),
        _buildEnhanceToggle(
          title: 'Peak Limiter',
          subtitle: 'Mencegah suara pecah/distorsi digital saat terjadi teriakkan mendadak',
          icon: Icons.shield_rounded,
          value: _audioEffect.limiter,
          onChanged: (v) => setState(() => _audioEffect = _audioEffect.copyWith(limiter: v)),
        ),
      ],
    );
  }

  Widget _buildEnhanceToggle({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: value ? AppDesignTokens.surfaceElevated : AppDesignTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusM),
        border: Border.all(
          color: value ? AppDesignTokens.cyanAccent.withValues(alpha: 0.4) : AppDesignTokens.borderGlass,
          width: 1,
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: value ? AppDesignTokens.cyanAccent.withValues(alpha: 0.15) : const Color(0xFF222638),
            borderRadius: BorderRadius.circular(AppDesignTokens.radiusS),
          ),
          child: Icon(icon, color: value ? AppDesignTokens.cyanAccent : Colors.white70, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(color: AppDesignTokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle, style: TextStyle(color: AppDesignTokens.textMuted, fontSize: 10.5)),
        value: value,
        activeTrackColor: AppDesignTokens.cyanAccent,
        activeThumbColor: Colors.black,
        inactiveTrackColor: Colors.white12,
        onChanged: onChanged,
      ),
    );
  }

  // --- TAB 3: EQUALIZER ---
  Widget _buildEqualizerTab() {
    final presets = [
      {'preset': EqualizerPreset.normal, 'label': 'Normal'},
      {'preset': EqualizerPreset.bassBoost, 'label': 'Bass Boost'},
      {'preset': EqualizerPreset.vocal, 'label': 'Vokal'},
      {'preset': EqualizerPreset.podcast, 'label': 'Podcast'},
      {'preset': EqualizerPreset.music, 'label': 'Musik'},
      {'preset': EqualizerPreset.treble, 'label': 'Treble'},
      {'preset': EqualizerPreset.custom, 'label': 'Kustom'},
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        const Text(
          'Preset Karakter Suara:',
          style: TextStyle(color: AppDesignTokens.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: presets.map((p) {
              final pr = p['preset'] as EqualizerPreset;
              final isSel = _audioEffect.eqPreset == pr;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => setState(() => _audioEffect = _audioEffect.copyWith(eqPreset: pr)),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? AppDesignTokens.cyanAccent : AppDesignTokens.surfaceSecondary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSel ? AppDesignTokens.cyanAccent : AppDesignTokens.borderGlass,
                        width: 1,
                      ),
                      boxShadow: isSel ? AppDesignTokens.glowShadow(AppDesignTokens.cyanAccent) : null,
                    ),
                    child: Text(
                      p['label'] as String,
                      style: TextStyle(
                        color: isSel ? Colors.black : AppDesignTokens.textSecondary,
                        fontSize: 11,
                        fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        // Slider Bass (-10 dB s/d +10 dB)
        _buildSliderCard(
          label: 'Bass (Low Freq / Dentuman)',
          value: _audioEffect.bass,
          min: -10.0,
          max: 10.0,
          unit: 'dB',
          onChanged: (v) => setState(() => _audioEffect = _audioEffect.copyWith(bass: v, eqPreset: EqualizerPreset.custom)),
        ),
        const SizedBox(height: 12),

        // Slider Treble (-10 dB s/d +10 dB)
        _buildSliderCard(
          label: 'Treble (High Freq / Kejernihan)',
          value: _audioEffect.treble,
          min: -10.0,
          max: 10.0,
          unit: 'dB',
          onChanged: (v) => setState(() => _audioEffect = _audioEffect.copyWith(treble: v, eqPreset: EqualizerPreset.custom)),
        ),
      ],
    );
  }

  // --- TAB 4: ADJUST ---
  Widget _buildAdjustTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        _buildSliderCard(
          label: 'Volume Audio Output',
          value: _audioEffect.volume,
          min: 0.0,
          max: 2.0,
          unit: '%',
          multiplier: 100,
          onChanged: (v) => setState(() => _audioEffect = _audioEffect.copyWith(volume: v)),
        ),
        const SizedBox(height: 10),
        _buildSliderCard(
          label: 'Nada Vokal (Pitch Shifter)',
          value: _audioEffect.pitch,
          min: 0.5,
          max: 2.0,
          unit: 'x',
          onChanged: (v) => setState(() => _audioEffect = _audioEffect.copyWith(pitch: v)),
        ),
        const SizedBox(height: 10),
        _buildSliderCard(
          label: 'Kecepatan Tempo Audio (Speed)',
          value: _audioEffect.speed,
          min: 0.5,
          max: 2.0,
          unit: 'x',
          onChanged: (v) => setState(() => _audioEffect = _audioEffect.copyWith(speed: v)),
        ),
        const SizedBox(height: 10),
        _buildSliderCard(
          label: 'Fade In Awal (Pudar Masuk)',
          value: _audioEffect.fadeInSeconds,
          min: 0.0,
          max: 5.0,
          unit: 's',
          onChanged: (v) => setState(() => _audioEffect = _audioEffect.copyWith(fadeInSeconds: v)),
        ),
        const SizedBox(height: 10),
        _buildSliderCard(
          label: 'Fade Out Akhir (Pudar Keluar)',
          value: _audioEffect.fadeOutSeconds,
          min: 0.0,
          max: 5.0,
          unit: 's',
          onChanged: (v) => setState(() => _audioEffect = _audioEffect.copyWith(fadeOutSeconds: v)),
        ),
        const SizedBox(height: 10),
        _buildSliderCard(
          label: 'Stereo Balance (Pan Kiri - Kanan)',
          value: _audioEffect.stereoBalance,
          min: -1.0,
          max: 1.0,
          unit: '',
          onChanged: (v) => setState(() => _audioEffect = _audioEffect.copyWith(stereoBalance: v)),
        ),
      ],
    );
  }

  Widget _buildSliderCard({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    double multiplier = 1.0,
    required ValueChanged<double> onChanged,
  }) {
    final displayVal = (value * multiplier).toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppDesignTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusM),
        border: Border.all(color: AppDesignTokens.borderGlass, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: AppDesignTokens.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppDesignTokens.cyanAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$displayVal $unit',
                  style: const TextStyle(
                    color: AppDesignTokens.cyanAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppDesignTokens.cyanAccent,
              inactiveTrackColor: Colors.white12,
              thumbColor: Colors.white,
              trackHeight: 3.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
