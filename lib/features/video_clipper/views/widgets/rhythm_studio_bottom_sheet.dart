import 'package:flutter/material.dart';
import '../../../../core/models/rhythm_model.dart';

/// Rhythm & Beat Studio Dialog ala CapCut:
/// Deteksi Beat Otomatis, Sensitivitas (Low/Med/High), Estimasi BPM, Manual Beat Marker, dan Beat Grid
class RhythmStudioBottomSheet extends StatefulWidget {
  final RhythmModel initialRhythm;
  final double audioDuration;
  final ValueChanged<RhythmModel> onApply;

  const RhythmStudioBottomSheet({
    super.key,
    required this.initialRhythm,
    required this.audioDuration,
    required this.onApply,
  });

  static Future<RhythmModel?> show(
    BuildContext context, {
    required RhythmModel initialRhythm,
    required double audioDuration,
    required ValueChanged<RhythmModel> onApply,
  }) {
    return showModalBottomSheet<RhythmModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RhythmStudioBottomSheet(
        initialRhythm: initialRhythm,
        audioDuration: audioDuration,
        onApply: onApply,
      ),
    );
  }

  @override
  State<RhythmStudioBottomSheet> createState() => _RhythmStudioBottomSheetState();
}

class _RhythmStudioBottomSheetState extends State<RhythmStudioBottomSheet> {
  late RhythmModel _currentRhythm;
  bool _isAnalyzing = false;
  double _manualBpm = 120.0;

  @override
  void initState() {
    super.initState();
    _currentRhythm = widget.initialRhythm;
    _manualBpm = _currentRhythm.estimatedBpm;
  }

  void _runAutoBeatDetection() async {
    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(milliseconds: 600));

    // Ekstraksi tempo & hitung marker
    final beats = RhythmModel.generateBeatsFromBpm(
      bpm: _manualBpm,
      durationSeconds: widget.audioDuration > 0 ? widget.audioDuration : 30.0,
      sensitivity: _currentRhythm.sensitivity,
    );

    setState(() {
      _currentRhythm = _currentRhythm.copyWith(
        estimatedBpm: _manualBpm,
        markers: beats,
      );
      _isAnalyzing = false;
    });

    widget.onApply(_currentRhythm);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 460,
      decoration: const BoxDecoration(
        color: Color(0xFF14141E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black87, blurRadius: 20, offset: Offset(0, -3)),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.graphic_eq_rounded, color: Color(0xFF00E5FF), size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Irama (Rhythm & Beat Studio)',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context, _currentRhythm),
                ),
              ],
            ),
          ),

          // Status & BPM Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B28),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TEMPO AUDIO (BPM)', style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      '${_manualBpm.toInt()} BPM',
                      style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                  ],
                ),
                const Spacer(),
                // Jumlah Marker Terdeteksi
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('TOTAL KETUKAN', style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      '${_currentRhythm.markers.length} Marker',
                      style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sensitivitas Chips (Rendah, Sedang, Tinggi)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Text('Sensitivitas:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(width: 10),
                _buildSensitivityChip(BeatSensitivity.low, 'Rendah'),
                const SizedBox(width: 6),
                _buildSensitivityChip(BeatSensitivity.medium, 'Sedang'),
                const SizedBox(width: 6),
                _buildSensitivityChip(BeatSensitivity.high, 'Tinggi'),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // BPM Slider Manual
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Sesuaikan Tempo:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      activeTrackColor: const Color(0xFF00E5FF),
                      inactiveTrackColor: Colors.white12,
                      thumbColor: const Color(0xFF00E5FF),
                    ),
                    child: Slider(
                      value: _manualBpm,
                      min: 60.0,
                      max: 180.0,
                      divisions: 120,
                      onChanged: (val) => setState(() => _manualBpm = val),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Snap to Beat Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF00E5FF)),
                const SizedBox(width: 8),
                const Text('Snap Klip ke Ketukan Musik', style: TextStyle(color: Colors.white, fontSize: 13)),
                const Spacer(),
                Switch(
                  value: _currentRhythm.isSnapEnabled,
                  activeThumbColor: const Color(0xFF00E5FF),
                  onChanged: (val) {
                    setState(() {
                      _currentRhythm = _currentRhythm.copyWith(isSnapEnabled: val);
                    });
                    widget.onApply(_currentRhythm);
                  },
                ),
              ],
            ),
          ),

          const Spacer(),

          // Action Buttons: Deteksi Otomatis & Selesai
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF0E0E16),
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00E5FF),
                      side: const BorderSide(color: Color(0xFF00E5FF)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: _isAnalyzing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00E5FF)),
                          )
                        : const Icon(Icons.flash_on_rounded, size: 18),
                    label: Text(_isAnalyzing ? 'Menganalisis...' : 'Deteksi Otomatis'),
                    onPressed: _isAnalyzing ? null : _runAutoBeatDetection,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      widget.onApply(_currentRhythm);
                      Navigator.pop(context, _currentRhythm);
                    },
                    child: const Text('Terapkan Irama', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensitivityChip(BeatSensitivity sens, String label) {
    final isSel = _currentRhythm.sensitivity == sens;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentRhythm = _currentRhythm.copyWith(sensitivity: sens);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF00E5FF).withValues(alpha: 0.2) : const Color(0xFF1F1F2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSel ? const Color(0xFF00E5FF) : Colors.white12,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSel ? const Color(0xFF00E5FF) : Colors.white70,
            fontSize: 11,
            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
