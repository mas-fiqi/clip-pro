import 'package:flutter/material.dart';
import '../../../../core/models/quality_enhancement_model.dart';

/// Bottom Sheet Studio Peningkatan Kualitas Video (Video Quality Enhancement) ala CapCut Pro:
/// - Auto Enhance (Optimalisasi kontras & kecerahan lokal otomatis)
/// - Target Quality Profiles (Standard 720p, High 1080p, Ultra 4K)
/// - Noise Reduction (Pengurangan bintik/noise video via filter hqdn3d)
/// - Deflicker (Peredam kedipan fluktuasi cahaya antar-frame)
/// - Camera Stabilization (Peredam guncangan kamera via filter deshake)
class QualityEnhancementBottomSheet extends StatefulWidget {
  final QualityEnhancementModel initialQuality;
  final ValueChanged<QualityEnhancementModel> onApply;

  const QualityEnhancementBottomSheet({
    super.key,
    required this.initialQuality,
    required this.onApply,
  });

  static Future<QualityEnhancementModel?> show(
    BuildContext context, {
    required QualityEnhancementModel initialQuality,
    required ValueChanged<QualityEnhancementModel> onApply,
  }) {
    return showModalBottomSheet<QualityEnhancementModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QualityEnhancementBottomSheet(
        initialQuality: initialQuality,
        onApply: onApply,
      ),
    );
  }

  @override
  State<QualityEnhancementBottomSheet> createState() => _QualityEnhancementBottomSheetState();
}

class _QualityEnhancementBottomSheetState extends State<QualityEnhancementBottomSheet> {
  late QualityEnhancementModel _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialQuality;
  }

  void _update(QualityEnhancementModel updated) {
    setState(() => _current = updated);
    widget.onApply(_current);
  }

  void _reset() {
    setState(() => _current = const QualityEnhancementModel());
    widget.onApply(_current);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF14141E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black87, blurRadius: 20, offset: Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Header Bar
              Row(
                children: [
                  const Icon(Icons.auto_fix_high_rounded, color: Color(0xFF00E5FF), size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'Peningkatan Kualitas Video',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _reset,
                    child: const Text('Reset', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(context, _current),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 1. Auto Enhance Card
              _buildSwitchCard(
                title: 'Otomatisasi Kualitas (Auto Enhance)',
                subtitle: 'Menyesuaikan kontras, dynamic range, dan kecerahan secara cerdas',
                icon: Icons.flash_on_rounded,
                value: _current.autoEnhance,
                onChanged: (val) => _update(_current.copyWith(autoEnhance: val)),
              ),

              const SizedBox(height: 8),

              // 2. Target Quality Selector Chips
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.high_quality_rounded, color: Color(0xFF00E5FF), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Profil Target Kualitas',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildQualityChip(TargetQualityProfile.standard, 'Standard (720p)'),
                        const SizedBox(width: 6),
                        _buildQualityChip(TargetQualityProfile.high, 'High (1080p)'),
                        const SizedBox(width: 6),
                        _buildQualityChip(TargetQualityProfile.ultra, 'Ultra (4K Look)'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // 3. Noise Reduction (Pengurang Bintik/Noise)
              _buildFeatureGroup(
                title: 'Peredam Noise (Noise Reduction)',
                subtitle: 'Membersihkan bintik ISO tanpa mengaburkan detail utama',
                icon: Icons.grain_rounded,
                enabled: _current.noiseReduction,
                onToggle: (v) => _update(_current.copyWith(noiseReduction: v)),
                intensity: _current.noiseIntensity,
                onIntensityChanged: (v) => _update(_current.copyWith(noiseIntensity: v)),
              ),

              const SizedBox(height: 8),

              // 4. Deflicker (Peredam Kedipan Cahaya)
              _buildFeatureGroup(
                title: 'Peredam Kedipan (Deflicker)',
                subtitle: 'Menstabilkan fluktuasi kedipan cahaya lampu / frame timelapse',
                icon: Icons.lightbulb_outline_rounded,
                enabled: _current.deflicker,
                onToggle: (v) => _update(_current.copyWith(deflicker: v)),
                intensity: _current.deflickerSize,
                onIntensityChanged: (v) => _update(_current.copyWith(deflickerSize: v)),
              ),

              const SizedBox(height: 8),

              // 5. Stabilisasi Kamera (Deshake)
              _buildFeatureGroup(
                title: 'Stabilisasi Guncangan (Stabilization)',
                subtitle: 'Mengurangi getaran gerakan kamera tangan agar mulus',
                icon: Icons.video_stable_rounded,
                enabled: _current.stabilization,
                onToggle: (v) => _update(_current.copyWith(stabilization: v)),
                intensity: _current.stabilizationStrength,
                onIntensityChanged: (v) => _update(_current.copyWith(stabilizationStrength: v)),
              ),

              const SizedBox(height: 14),

              // Action Apply Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  widget.onApply(_current);
                  Navigator.pop(context, _current);
                },
                child: const Text('Terapkan Kualitas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value ? const Color(0xFF00E5FF) : Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: value ? const Color(0xFF00E5FF) : Colors.white54, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: const Color(0xFF00E5FF),
            activeTrackColor: const Color(0xFF00E5FF).withValues(alpha: 0.3),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildQualityChip(TargetQualityProfile profile, String label) {
    final isSel = _current.targetQuality == profile;
    return Expanded(
      child: GestureDetector(
        onTap: () => _update(_current.copyWith(targetQuality: profile)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFF00E5FF) : const Color(0xFF14141E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSel ? const Color(0xFF00E5FF) : Colors.white12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSel ? Colors.black : Colors.white70,
              fontSize: 10,
              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureGroup({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool enabled,
    required ValueChanged<bool> onToggle,
    required double intensity,
    required ValueChanged<double> onIntensityChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: enabled ? const Color(0xFF00E5FF) : Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: enabled ? const Color(0xFF00E5FF) : Colors.white54, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                activeThumbColor: const Color(0xFF00E5FF),
                activeTrackColor: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                onChanged: onToggle,
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Intensitas:', style: TextStyle(color: Colors.white54, fontSize: 10)),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      activeTrackColor: const Color(0xFF00E5FF),
                      inactiveTrackColor: Colors.white12,
                      thumbColor: const Color(0xFF00E5FF),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                    ),
                    child: Slider(
                      value: intensity.clamp(0.0, 1.0),
                      min: 0.0,
                      max: 1.0,
                      onChanged: onIntensityChanged,
                    ),
                  ),
                ),
                Text('${(intensity * 100).toInt()}%', style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

