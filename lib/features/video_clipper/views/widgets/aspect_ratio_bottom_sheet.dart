import 'package:flutter/material.dart';
import '../../../../core/models/clip_transform_model.dart';

class AspectRatioBottomSheet extends StatefulWidget {
  final ClipTransformModel initialTransform;
  final double videoNaturalAspectRatio;

  const AspectRatioBottomSheet({
    super.key,
    required this.initialTransform,
    required this.videoNaturalAspectRatio,
  });

  static Future<ClipTransformModel?> show(
    BuildContext context, {
    required ClipTransformModel initialTransform,
    double videoNaturalAspectRatio = 16.0 / 9.0,
  }) {
    return showModalBottomSheet<ClipTransformModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AspectRatioBottomSheet(
        initialTransform: initialTransform,
        videoNaturalAspectRatio: videoNaturalAspectRatio,
      ),
    );
  }

  @override
  State<AspectRatioBottomSheet> createState() => _AspectRatioBottomSheetState();
}

class _AspectRatioBottomSheetState extends State<AspectRatioBottomSheet> {
  late CanvasRatioMode _selectedRatio;
  late FitMode _selectedFitMode;
  late CanvasBackgroundType _selectedBgType;
  late String _selectedBgColor;
  late double _customRatio;

  final List<String> _presetColors = [
    '000000', // Hitam
    '1E1E2C', // Dark Slate
    'FFFFFF', // Putih
    'EF4444', // Merah
    'F59E0B', // Amber
    '10B981', // Emerald
    '00E5FF', // Cyan CapCut
    '8B5CF6', // Ungu
    'EC4899', // Pink
  ];

  @override
  void initState() {
    super.initState();
    _selectedRatio = widget.initialTransform.canvasRatio;
    _selectedFitMode = widget.initialTransform.fitMode;
    _selectedBgType = widget.initialTransform.backgroundType;
    _selectedBgColor = widget.initialTransform.backgroundColorHex;
    _customRatio = widget.initialTransform.customAspectRatio ?? 1.0;
  }

  ClipTransformModel _buildResult() {
    return widget.initialTransform.copyWith(
      canvasRatio: _selectedRatio,
      fitMode: _selectedFitMode,
      backgroundType: _selectedBgType,
      backgroundColorHex: _selectedBgColor,
      customAspectRatio: _selectedRatio == CanvasRatioMode.custom ? _customRatio : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: Color(0xFF14141E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Format Rasio & Kanvas',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(_buildResult());
                  },
                  child: const Text('Terapkan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ),

          // Rasio Presets Horizontal List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                const Text('PILIHAN ASPEK RASIO', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                const SizedBox(height: 8),

                // Horizontal Ratio Cards
                SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildRatioCard(CanvasRatioMode.original, 'Original', 'Asli'),
                      _buildRatioCard(CanvasRatioMode.ratio9x16, '9:16', 'TikTok / Reels'),
                      _buildRatioCard(CanvasRatioMode.ratio16x9, '16:9', 'YouTube'),
                      _buildRatioCard(CanvasRatioMode.ratio1x1, '1:1', 'Instagram'),
                      _buildRatioCard(CanvasRatioMode.ratio4x5, '4:5', 'Portrait Feed'),
                      _buildRatioCard(CanvasRatioMode.ratio3x4, '3:4', 'Tablet'),
                      _buildRatioCard(CanvasRatioMode.ratio4x3, '4:3', 'Retro TV'),
                      _buildRatioCard(CanvasRatioMode.ratio2x1, '2:1', 'Univisium'),
                      _buildRatioCard(CanvasRatioMode.ratio21x9, '21:9', 'Cinemascope'),
                      _buildRatioCard(CanvasRatioMode.custom, 'Custom', 'Kustom'),
                    ],
                  ),
                ),

                if (_selectedRatio == CanvasRatioMode.custom) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Rasio Kustom:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Expanded(
                        child: Slider(
                          value: _customRatio,
                          min: 0.4,
                          max: 2.5,
                          divisions: 42,
                          activeColor: const Color(0xFF00E5FF),
                          onChanged: (val) => setState(() => _customRatio = val),
                        ),
                      ),
                      Text(_customRatio.toStringAsFixed(2), style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),

                // Mode Fit vs Fill
                const Text('PENYESUAIAN KANVAS (FIT / FILL)', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFitMode = FitMode.fit),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedFitMode == FitMode.fit ? const Color(0xFF00E5FF).withValues(alpha: 0.15) : const Color(0xFF1E1E2C),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _selectedFitMode == FitMode.fit ? const Color(0xFF00E5FF) : Colors.white12,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.fit_screen_rounded, color: _selectedFitMode == FitMode.fit ? const Color(0xFF00E5FF) : Colors.white70, size: 22),
                              const SizedBox(height: 4),
                              Text('Fit (Utuh & Background)', style: TextStyle(color: _selectedFitMode == FitMode.fit ? const Color(0xFF00E5FF) : Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFitMode = FitMode.fill),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedFitMode == FitMode.fill ? const Color(0xFF00E5FF).withValues(alpha: 0.15) : const Color(0xFF1E1E2C),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _selectedFitMode == FitMode.fill ? const Color(0xFF00E5FF) : Colors.white12,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.fullscreen_rounded, color: _selectedFitMode == FitMode.fill ? const Color(0xFF00E5FF) : Colors.white70, size: 22),
                              const SizedBox(height: 4),
                              Text('Fill (Penuhi Layar & Crop)', style: TextStyle(color: _selectedFitMode == FitMode.fill ? const Color(0xFF00E5FF) : Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),

                // Background Style: Solid Color vs Blur
                const Text('LATAR BELAKANG KANVAS (BACKGROUND)', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Warna Solid'),
                      selected: _selectedBgType == CanvasBackgroundType.solidColor,
                      selectedColor: const Color(0xFF8B5CF6),
                      backgroundColor: const Color(0xFF1E1E2C),
                      labelStyle: TextStyle(
                        color: _selectedBgType == CanvasBackgroundType.solidColor ? Colors.white : Colors.white60,
                        fontSize: 12,
                      ),
                      onSelected: (_) => setState(() => _selectedBgType = CanvasBackgroundType.solidColor),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Blur Video Asli'),
                      selected: _selectedBgType == CanvasBackgroundType.blur,
                      selectedColor: const Color(0xFF8B5CF6),
                      backgroundColor: const Color(0xFF1E1E2C),
                      labelStyle: TextStyle(
                        color: _selectedBgType == CanvasBackgroundType.blur ? Colors.white : Colors.white60,
                        fontSize: 12,
                      ),
                      onSelected: (_) => setState(() => _selectedBgType = CanvasBackgroundType.blur),
                    ),
                  ],
                ),

                if (_selectedBgType == CanvasBackgroundType.solidColor) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _presetColors.map((hex) {
                        final isChosen = _selectedBgColor.toUpperCase() == hex.toUpperCase();
                        final color = Color(int.parse('FF$hex', radix: 16));
                        return GestureDetector(
                          onTap: () => setState(() => _selectedBgColor = hex),
                          child: Container(
                            width: 38,
                            height: 38,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isChosen ? const Color(0xFF00E5FF) : Colors.white24,
                                width: isChosen ? 3 : 1,
                              ),
                            ),
                            child: isChosen ? const Icon(Icons.check, size: 18, color: Colors.black) : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatioCard(CanvasRatioMode ratio, String label, String sub) {
    final isSelected = _selectedRatio == ratio;
    return GestureDetector(
      onTap: () => setState(() => _selectedRatio = ratio),
      child: Container(
        width: 76,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00E5FF).withValues(alpha: 0.15) : const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E5FF) : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(color: isSelected ? const Color(0xFF00E5FF) : Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(sub, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white38, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

