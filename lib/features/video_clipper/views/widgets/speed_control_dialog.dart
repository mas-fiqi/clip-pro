import 'package:flutter/material.dart';
import '../../../../core/models/speed_config_model.dart';
import 'speed_curve_interactive_canvas.dart';

/// BottomSheet Pengaturan Kecepatan Profesional ala CapCut Pro:
/// Memiliki Tab:
/// 1. Standar (Normal) 0.1x - 100x dengan Keep Pitch Audio
/// 2. Kurva (Curve) dengan Grafik Bézier Interaktif, Control Points, & 10 Template Kecepatan
class SpeedControlBottomSheet extends StatefulWidget {
  final SpeedConfigModel initialConfig;
  final double clipDuration;
  final ValueChanged<SpeedConfigModel> onApply;

  const SpeedControlBottomSheet({
    super.key,
    required this.initialConfig,
    required this.clipDuration,
    required this.onApply,
  });

  static Future<SpeedConfigModel?> show(
    BuildContext context, {
    required SpeedConfigModel initialConfig,
    required double clipDuration,
    required ValueChanged<SpeedConfigModel> onApply,
  }) {
    return showModalBottomSheet<SpeedConfigModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SpeedControlBottomSheet(
        initialConfig: initialConfig,
        clipDuration: clipDuration,
        onApply: onApply,
      ),
    );
  }

  @override
  State<SpeedControlBottomSheet> createState() => _SpeedControlBottomSheetState();
}

class _SpeedControlBottomSheetState extends State<SpeedControlBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SpeedConfigModel _currentConfig;

  static const List<double> _normalPresets = [
    0.1, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0, 5.0, 10.0, 50.0, 100.0
  ];

  static const List<Map<String, String>> _curveTemplates = [
    {'id': 'custom', 'name': 'Custom'},
    {'id': 'montage', 'name': 'Montage'},
    {'id': 'hero', 'name': 'Hero'},
    {'id': 'bullet', 'name': 'Bullet'},
    {'id': 'jump_cut', 'name': 'Jump Cut'},
    {'id': 'flash_in', 'name': 'Flash In'},
    {'id': 'flash_out', 'name': 'Flash Out'},
    {'id': 'action', 'name': 'Action'},
    {'id': 'slow_mo', 'name': 'Slow Motion'},
    {'id': 'fast_mo', 'name': 'Fast Motion'},
    {'id': 'cinematic', 'name': 'Cinematic'},
  ];

  @override
  void initState() {
    super.initState();
    _currentConfig = widget.initialConfig;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _currentConfig.isCurveMode ? 1 : 0,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentConfig = _currentConfig.copyWith(isCurveMode: _tabController.index == 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSpeed = _currentConfig.effectiveSpeed;
    final resultingDuration = widget.clipDuration / (effectiveSpeed > 0 ? effectiveSpeed : 1.0);

    final sheetHeight = MediaQuery.of(context).size.height * 0.72;

    return Container(
      height: sheetHeight.clamp(520.0, 680.0),
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
              margin: const EdgeInsets.only(top: 10, bottom: 6),
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
                const Icon(Icons.speed_rounded, color: Color(0xFF00E5FF), size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Pengaturan Kecepatan Video',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context, _currentConfig),
                ),
              ],
            ),
          ),

          // Tab Selector: Standar (Normal) vs Kurva (Speed Curve)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F2E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: const Color(0xFF00E5FF),
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              tabs: const [
                Tab(text: 'Standar / Normal'),
                Tab(text: 'Kurva Kecepatan (Curve)'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNormalSpeedTab(),
                _buildCurveSpeedTab(),
              ],
            ),
          ),

          // Durasi Perubahan & Keep Pitch Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF161622),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ESTIMASI DURASI KLIP', style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 1),
                    Text(
                      '${widget.clipDuration.toStringAsFixed(1)}s ➔ ${resultingDuration.toStringAsFixed(1)}s',
                      style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                  ],
                ),
                const Spacer(),
                // Keep Pitch Audio Toggle
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentConfig = _currentConfig.copyWith(keepPitch: !_currentConfig.keepPitch);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _currentConfig.keepPitch ? const Color(0xFF00E5FF).withValues(alpha: 0.15) : const Color(0xFF222230),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _currentConfig.keepPitch ? const Color(0xFF00E5FF) : Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.mic_none_rounded, size: 14, color: _currentConfig.keepPitch ? const Color(0xFF00E5FF) : Colors.white54),
                        const SizedBox(width: 4),
                        Text(
                          'Kunci Nada (Pitch)',
                          style: TextStyle(
                            color: _currentConfig.keepPitch ? const Color(0xFF00E5FF) : Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Bar: Selesai & Terapkan
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF0E0E16),
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        _currentConfig = const SpeedConfigModel();
                      });
                      widget.onApply(_currentConfig);
                    },
                    child: const Text('Reset 1.0x'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      widget.onApply(_currentConfig);
                      Navigator.pop(context, _currentConfig);
                    },
                    child: const Text('Terapkan Kecepatan', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalSpeedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Besar Nilai Speed Display
          Center(
            child: Text(
              '${_currentConfig.normalSpeed.toStringAsFixed(2)}x',
              style: const TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),

          // Slider Kecepatan Normal
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              activeTrackColor: const Color(0xFF00E5FF),
              inactiveTrackColor: Colors.white12,
              thumbColor: const Color(0xFF00E5FF),
            ),
            child: Slider(
              value: _currentConfig.normalSpeed.clamp(0.1, 10.0),
              min: 0.1,
              max: 10.0,
              divisions: 99,
              onChanged: (val) {
                setState(() {
                  _currentConfig = _currentConfig.copyWith(
                    normalSpeed: val,
                    isCurveMode: false,
                  );
                });
                widget.onApply(_currentConfig);
              },
            ),
          ),

          const SizedBox(height: 8),

          // Preset Chips Cepat (0.1x s/d 100x)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: _normalPresets.map((speed) {
              final isSelected = (_currentConfig.normalSpeed - speed).abs() < 0.01;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentConfig = _currentConfig.copyWith(
                      normalSpeed: speed,
                      isCurveMode: false,
                    );
                  });
                  widget.onApply(_currentConfig);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF00E5FF) : const Color(0xFF222230),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isSelected ? const Color(0xFF00E5FF) : Colors.white12),
                  ),
                  child: Text(
                    '${speed}x',
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 11,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurveSpeedTab() {
    return Column(
      children: [
        // Horizontal Template Curve Chips (Montage, Hero, Bullet, Flash, etc.)
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _curveTemplates.length,
            itemBuilder: (context, index) {
              final tmpl = _curveTemplates[index];
              final isSel = _currentConfig.curveTemplateId == tmpl['id'];
              return GestureDetector(
                onTap: () {
                  final newConfig = SpeedConfigModel.getTemplate(tmpl['id']!);
                  setState(() {
                    _currentConfig = newConfig.copyWith(keepPitch: _currentConfig.keepPitch);
                  });
                  widget.onApply(_currentConfig);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFF00E5FF).withValues(alpha: 0.2) : const Color(0xFF1E1E2B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSel ? const Color(0xFF00E5FF) : Colors.white12),
                  ),
                  child: Center(
                    child: Text(
                      tmpl['name']!,
                      style: TextStyle(
                        color: isSel ? const Color(0xFF00E5FF) : Colors.white70,
                        fontSize: 11,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 4),

        // Interactive Bézier Curve Canvas
        Expanded(
          child: SpeedCurveInteractiveCanvas(
            speedConfig: _currentConfig,
            onConfigChanged: (updated) {
              setState(() => _currentConfig = updated);
              widget.onApply(_currentConfig);
            },
          ),
        ),
      ],
    );
  }
}
