import 'package:flutter/material.dart';
import '../../../../core/models/clip_model.dart';
import '../../../../core/theme/app_design_tokens.dart';

class AudioVolumeBottomSheet extends StatefulWidget {
  final ClipModel clip;

  const AudioVolumeBottomSheet({super.key, required this.clip});

  static Future<double?> show(BuildContext context, {required ClipModel clip}) {
    return showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AudioVolumeBottomSheet(clip: clip),
    );
  }

  @override
  State<AudioVolumeBottomSheet> createState() => _AudioVolumeBottomSheetState();
}

class _AudioVolumeBottomSheetState extends State<AudioVolumeBottomSheet> {
  late double _volume;

  static const List<double> _volumePresets = [0.0, 0.25, 0.5, 0.75, 1.0, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _volume = widget.clip.volume;
  }

  @override
  Widget build(BuildContext context) {
    final percent = (_volume * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: AppDesignTokens.surfacePrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDesignTokens.radiusL)),
        border: Border.all(color: AppDesignTokens.borderSubtle, width: 1),
        boxShadow: AppDesignTokens.softShadow,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              const SizedBox(height: 14),

              // Header: Judul, Batal & Simpan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppDesignTokens.textSecondary, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Level Volume Audio',
                    style: TextStyle(
                      color: AppDesignTokens.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppDesignTokens.cyanAccent,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDesignTokens.radiusS)),
                    ),
                    onPressed: () => Navigator.pop(context, _volume),
                    child: const Text('Terapkan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Hero Display Card Persentase Volume
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                decoration: BoxDecoration(
                  color: AppDesignTokens.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppDesignTokens.radiusM),
                  border: Border.all(color: AppDesignTokens.borderGlass, width: 1),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _volume = _volume == 0.0 ? 1.0 : 0.0;
                            });
                          },
                          child: Icon(
                            _volume == 0.0
                                ? Icons.volume_off_rounded
                                : _volume < 0.5
                                    ? Icons.volume_mute_rounded
                                    : _volume <= 1.0
                                        ? Icons.volume_down_rounded
                                        : Icons.volume_up_rounded,
                            color: _volume == 0.0 ? AppDesignTokens.redAccent : AppDesignTokens.cyanAccent,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          '$percent',
                          style: TextStyle(
                            color: _volume > 1.0
                                ? AppDesignTokens.amberAccent
                                : _volume == 0.0
                                    ? AppDesignTokens.textMuted
                                    : AppDesignTokens.textPrimary,
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '%',
                          style: TextStyle(
                            color: _volume > 1.0 ? AppDesignTokens.amberAccent : AppDesignTokens.textSecondary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _volume == 0.0
                          ? 'Suara Dimatikan (Muted)'
                          : _volume > 1.0
                              ? 'Amplifikasi Booster (+${percent - 100}%)'
                              : 'Tingkat Standar',
                      style: TextStyle(
                        color: _volume == 0.0 ? AppDesignTokens.redAccent : AppDesignTokens.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Slider Volume
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _volume > 1.0 ? AppDesignTokens.amberAccent : AppDesignTokens.cyanAccent,
                  inactiveTrackColor: Colors.white12,
                  thumbColor: Colors.white,
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                ),
                child: Slider(
                  value: _volume.clamp(0.0, 2.0),
                  min: 0.0,
                  max: 2.0,
                  onChanged: (v) => setState(() => _volume = v),
                ),
              ),
              const SizedBox(height: 12),

              // Quick Presets Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _volumePresets.map((preset) {
                  final pPercent = (preset * 100).toInt();
                  final isSelected = (_volume * 100).round() == pPercent;
                  return InkWell(
                    onTap: () => setState(() => _volume = preset),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? AppDesignTokens.cyanAccent : AppDesignTokens.surfaceSecondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? AppDesignTokens.cyanAccent : AppDesignTokens.borderGlass,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$pPercent%',
                        style: TextStyle(
                          color: isSelected ? Colors.black : AppDesignTokens.textSecondary,
                          fontSize: 10.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
