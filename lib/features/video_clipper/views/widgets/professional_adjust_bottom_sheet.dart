import 'package:flutter/material.dart';
import '../../../../core/models/advanced_color_model.dart';
import '../../../../core/models/color_adjustment_model.dart';
import '../../../../core/models/filter_catalog.dart';
import 'filter_preview_scene_widget.dart';

/// Studio Penyesuaian Visual Profesional ala CapCut Pro:
/// - Tab 1: Filter Presets (Kategori Popular, Cinematic, Nature, Portrait, dll.) & My Presets (Simpan Preset Kustom)
/// - Tab 2: Adjust Parameter (Brightness, Contrast, Saturation, Exposure, Sharpen, Clarity, Highlights, Shadows, Temp, Tint, Vignette)
/// - Tab 3: HSL 8-Warna (Merah, Jingga, Kuning, Hijau, Cyan, Biru, Ungu, Magenta)
/// - Tab 4: Tonal Color Wheels (Shadows, Midtones, Highlights)
class ProfessionalAdjustBottomSheet extends StatefulWidget {
  final ColorAdjustmentModel initialAdjustment;
  final ValueChanged<ColorAdjustmentModel> onApply;

  const ProfessionalAdjustBottomSheet({
    super.key,
    required this.initialAdjustment,
    required this.onApply,
  });

  static Future<ColorAdjustmentModel?> show(
    BuildContext context, {
    required ColorAdjustmentModel initialAdjustment,
    required ValueChanged<ColorAdjustmentModel> onApply,
  }) {
    return showModalBottomSheet<ColorAdjustmentModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfessionalAdjustBottomSheet(
        initialAdjustment: initialAdjustment,
        onApply: onApply,
      ),
    );
  }

  @override
  State<ProfessionalAdjustBottomSheet> createState() => _ProfessionalAdjustBottomSheetState();
}

class _ProfessionalAdjustBottomSheetState extends State<ProfessionalAdjustBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ColorAdjustmentModel _currentAdj;

  FilterCategory _filterCategory = FilterCategory.original;
  final String _searchFilter = '';
  bool _isComparingOriginal = false;

  // Custom User Presets (disimpan dalam memory session dan storage)
  final List<Map<String, dynamic>> _myPresets = [
    {'name': 'Moody Vintage', 'model': const ColorAdjustmentModel(preset: FilterPreset.vintage, contrast: 0.2, temperature: 0.15, vignette: 0.25)},
    {'name': 'Golden Summer', 'model': const ColorAdjustmentModel(preset: FilterPreset.goldenHour, brightness: 0.1, saturation: 0.25, temperature: 0.3)},
    {'name': 'Clean Portrait', 'model': const ColorAdjustmentModel(preset: FilterPreset.softSkin, brightness: 0.08, contrast: -0.05, clarity: 0.15)},
  ];

  int _selectedHslIndex = 0; // 0=Red, 1=Orange, 2=Yellow, 3=Green, 4=Cyan, 5=Blue, 6=Purple, 7=Magenta

  @override
  void initState() {
    super.initState();
    _currentAdj = widget.initialAdjustment;
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateAdjustment(ColorAdjustmentModel updated) {
    setState(() => _currentAdj = updated);
    widget.onApply(_currentAdj);
  }

  void _resetAll() {
    setState(() => _currentAdj = const ColorAdjustmentModel());
    widget.onApply(_currentAdj);
  }

  void _saveCurrentAsPreset() {
    final textCtrl = TextEditingController(text: 'Preset Saya ${_myPresets.length + 1}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14141E),
        title: const Text('Simpan Preset Baru', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: textCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Nama Preset',
            labelStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E5FF))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Colors.white60))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), foregroundColor: Colors.black),
            onPressed: () {
              if (textCtrl.text.isNotEmpty) {
                setState(() {
                  _myPresets.add({
                    'name': textCtrl.text,
                    'model': _currentAdj,
                  });
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 560,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(
              children: [
                const Icon(Icons.tune_rounded, color: Color(0xFF00E5FF), size: 20),
                const SizedBox(width: 6),
                const Flexible(
                  child: Text(
                    'Color Studio',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                // Tombol Tahan Before/After
                GestureDetector(
                  onTapDown: (_) {
                    setState(() => _isComparingOriginal = true);
                    widget.onApply(const ColorAdjustmentModel());
                  },
                  onTapUp: (_) {
                    setState(() => _isComparingOriginal = false);
                    widget.onApply(_currentAdj);
                  },
                  onTapCancel: () {
                    setState(() => _isComparingOriginal = false);
                    widget.onApply(_currentAdj);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isComparingOriginal ? const Color(0xFF00E5FF) : const Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _isComparingOriginal ? const Color(0xFF00E5FF) : Colors.white12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.compare_rounded, size: 12, color: _isComparingOriginal ? Colors.black : Colors.white70),
                        const SizedBox(width: 3),
                        Text(
                          _isComparingOriginal ? 'Original' : 'Bandingkan',
                          style: TextStyle(color: _isComparingOriginal ? Colors.black : Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: _resetAll,
                  child: const Text('Reset', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                ),
                IconButton(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                  onPressed: () => Navigator.pop(context, _currentAdj),
                ),
              ],
            ),
          ),

          // 4-Tab Navigation: 1. Filter & Presets | 2. Sesuaikan (Adjust) | 3. HSL | 4. Color Wheels
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              tabs: const [
                Tab(text: 'Filter & Presets'),
                Tab(text: 'Sesuaikan'),
                Tab(text: 'HSL Warna'),
                Tab(text: 'Color Wheels'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFilterAndPresetsTab(),
                _buildAdjustSlidersTab(),
                _buildHslColorsTab(),
                _buildColorWheelsTab(),
              ],
            ),
          ),

          // Action Bottom Bar
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
                    onPressed: _saveCurrentAsPreset,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_add_outlined, size: 16),
                        SizedBox(width: 6),
                        Text('Simpan Preset', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                      widget.onApply(_currentAdj);
                      Navigator.pop(context, _currentAdj);
                    },
                    child: const Text('Terapkan Warna', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 1: Filter & Presets ---
  Widget _buildFilterAndPresetsTab() {
    final filtered = FilterCatalog.items.where((i) {
      if (_searchFilter.isNotEmpty) {
        return i.name.toLowerCase().contains(_searchFilter.toLowerCase());
      }
      if (_filterCategory == FilterCategory.original) return true;
      return i.category == _filterCategory;
    }).toList();

    return Column(
      children: [
        // Category Chips
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: [
              _buildCategoryChip(FilterCategory.original, 'Semua'),
              _buildCategoryChip(FilterCategory.popular, 'Popular'),
              _buildCategoryChip(FilterCategory.cinematic, 'Cinematic'),
              _buildCategoryChip(FilterCategory.natural, 'Alami'),
              _buildCategoryChip(FilterCategory.portrait, 'Portrait'),
              _buildCategoryChip(FilterCategory.vintage, 'Vintage'),
              _buildCategoryChip(FilterCategory.landscape, 'Nature'),
              _buildCategoryChip(FilterCategory.film, 'Film'),
              _buildCategoryChip(FilterCategory.custom, 'My Presets (${_myPresets.length})'),
            ],
          ),
        ),

        // Grid Preset Filters
        Expanded(
          child: _filterCategory == FilterCategory.custom
              ? _buildMyPresetsList()
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, idx) {
                    final item = filtered[idx];
                    final isSel = _currentAdj.preset == item.preset;
                    return GestureDetector(
                      onTap: () => _updateAdjustment(_currentAdj.copyWith(preset: item.preset)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isSel ? const Color(0xFF00E5FF) : Colors.white12, width: isSel ? 2 : 1),
                          color: const Color(0xFF1E1E2C),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: FilterPreviewSceneWidget(matrix: item.matrix),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              color: isSel ? const Color(0xFF00E5FF) : const Color(0xFF161622),
                              child: Text(
                                item.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSel ? Colors.black : Colors.white,
                                  fontSize: 10,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(FilterCategory cat, String label) {
    final isSel = _filterCategory == cat;
    return GestureDetector(
      onTap: () => setState(() => _filterCategory = cat),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF00E5FF) : const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSel ? const Color(0xFF00E5FF) : Colors.white10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSel ? Colors.black : Colors.white70,
              fontSize: 11,
              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyPresetsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _myPresets.length,
      itemBuilder: (context, idx) {
        final p = _myPresets[idx];
        final model = p['model'] as ColorAdjustmentModel;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              const Icon(Icons.palette_rounded, color: Color(0xFF00E5FF), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('Filter: ${model.preset.name} • Contrast: ${(model.contrast * 100).toInt()}%', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(0, 30),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: () => _updateAdjustment(model),
                child: const Text('Gunakan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 2: Professional Adjust Sliders ---
  Widget _buildAdjustSlidersTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        _buildSliderRow('Kecerahan (Brightness)', _currentAdj.brightness, -1.0, 1.0, (v) => _updateAdjustment(_currentAdj.copyWith(brightness: v))),
        _buildSliderRow('Kontras (Contrast)', _currentAdj.contrast, -1.0, 1.0, (v) => _updateAdjustment(_currentAdj.copyWith(contrast: v))),
        _buildSliderRow('Saturasi (Saturation)', _currentAdj.saturation, -1.0, 1.0, (v) => _updateAdjustment(_currentAdj.copyWith(saturation: v))),
        _buildSliderRow('Eksposur (Exposure)', _currentAdj.exposure, -1.0, 1.0, (v) => _updateAdjustment(_currentAdj.copyWith(exposure: v))),
        _buildSliderRow('Suhu Warna (Temp)', _currentAdj.temperature, -1.0, 1.0, (v) => _updateAdjustment(_currentAdj.copyWith(temperature: v))),
        _buildSliderRow('Rona (Tint)', _currentAdj.tint, -1.0, 1.0, (v) => _updateAdjustment(_currentAdj.copyWith(tint: v))),
        _buildSliderRow('Ketajaman (Sharpen)', _currentAdj.sharpen, 0.0, 1.0, (v) => _updateAdjustment(_currentAdj.copyWith(sharpen: v))),
        _buildSliderRow('Kejelasan (Clarity)', _currentAdj.clarity, 0.0, 1.0, (v) => _updateAdjustment(_currentAdj.copyWith(clarity: v))),
        _buildSliderRow('Sorotan (Highlights)', _currentAdj.highlights, -1.0, 1.0, (v) => _updateAdjustment(_currentAdj.copyWith(highlights: v))),
        _buildSliderRow('Bayangan (Shadows)', _currentAdj.shadows, -1.0, 1.0, (v) => _updateAdjustment(_currentAdj.copyWith(shadows: v))),
        _buildSliderRow('Vignette', _currentAdj.vignette, 0.0, 1.0, (v) => _updateAdjustment(_currentAdj.copyWith(vignette: v))),
      ],
    );
  }

  Widget _buildSliderRow(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text('${(value * 100).toInt()}%', style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              activeTrackColor: const Color(0xFF00E5FF),
              inactiveTrackColor: Colors.white12,
              thumbColor: const Color(0xFF00E5FF),
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

  // --- TAB 3: HSL 8-Warna ---
  Widget _buildHslColorsTab() {
    final colors = [
      {'name': 'Merah', 'color': const Color(0xFFEF4444)},
      {'name': 'Jingga', 'color': const Color(0xFFF97316)},
      {'name': 'Kuning', 'color': const Color(0xFFEAB308)},
      {'name': 'Hijau', 'color': const Color(0xFF22C55E)},
      {'name': 'Cyan', 'color': const Color(0xFF06B6D4)},
      {'name': 'Biru', 'color': const Color(0xFF3B82F6)},
      {'name': 'Ungu', 'color': const Color(0xFFA855F7)},
      {'name': 'Magenta', 'color': const Color(0xFFEC4899)},
    ];

    HslColorAdjustment activeHsl;
    switch (_selectedHslIndex) {
      case 0: activeHsl = _currentAdj.hsl.red; break;
      case 1: activeHsl = _currentAdj.hsl.orange; break;
      case 2: activeHsl = _currentAdj.hsl.yellow; break;
      case 3: activeHsl = _currentAdj.hsl.green; break;
      case 4: activeHsl = _currentAdj.hsl.cyan; break;
      case 5: activeHsl = _currentAdj.hsl.blue; break;
      case 6: activeHsl = _currentAdj.hsl.purple; break;
      default: activeHsl = _currentAdj.hsl.magenta; break;
    }

    return Column(
      children: [
        // 8 Color Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(colors.length, (idx) {
              final isSel = _selectedHslIndex == idx;
              return GestureDetector(
                onTap: () => setState(() => _selectedHslIndex = idx),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors[idx]['color'] as Color,
                    shape: BoxShape.circle,
                    border: Border.all(color: isSel ? Colors.white : Colors.transparent, width: 2.5),
                    boxShadow: isSel ? [BoxShadow(color: (colors[idx]['color'] as Color).withValues(alpha: 0.6), blurRadius: 8)] : null,
                  ),
                ),
              );
            }),
          ),
        ),

        const Divider(color: Colors.white10),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _buildSliderRow(
                'Hue (Corak Derajat)',
                activeHsl.hue / 180.0,
                -1.0,
                1.0,
                (v) => _updateHslForActive(activeHsl.copyWith(hue: v * 180.0)),
              ),
              _buildSliderRow(
                'Saturasi (Kejenuhan)',
                activeHsl.saturation,
                -1.0,
                1.0,
                (v) => _updateHslForActive(activeHsl.copyWith(saturation: v)),
              ),
              _buildSliderRow(
                'Luminansi (Kecerahan Warna)',
                activeHsl.luminance,
                -1.0,
                1.0,
                (v) => _updateHslForActive(activeHsl.copyWith(luminance: v)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateHslForActive(HslColorAdjustment updated) {
    HslChannelsModel newHsl;
    switch (_selectedHslIndex) {
      case 0: newHsl = _currentAdj.hsl.copyWith(red: updated); break;
      case 1: newHsl = _currentAdj.hsl.copyWith(orange: updated); break;
      case 2: newHsl = _currentAdj.hsl.copyWith(yellow: updated); break;
      case 3: newHsl = _currentAdj.hsl.copyWith(green: updated); break;
      case 4: newHsl = _currentAdj.hsl.copyWith(cyan: updated); break;
      case 5: newHsl = _currentAdj.hsl.copyWith(blue: updated); break;
      case 6: newHsl = _currentAdj.hsl.copyWith(purple: updated); break;
      default: newHsl = _currentAdj.hsl.copyWith(magenta: updated); break;
    }
    _updateAdjustment(_currentAdj.copyWith(hsl: newHsl));
  }

  // --- TAB 4: Color Wheels (Shadows, Midtones, Highlights) ---
  Widget _buildColorWheelsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMiniWheel('Shadows', _currentAdj.colorWheels.shadows, (w) {
            _updateAdjustment(_currentAdj.copyWith(colorWheels: _currentAdj.colorWheels.copyWith(shadows: w)));
          }),
          _buildMiniWheel('Midtones', _currentAdj.colorWheels.midtones, (w) {
            _updateAdjustment(_currentAdj.copyWith(colorWheels: _currentAdj.colorWheels.copyWith(midtones: w)));
          }),
          _buildMiniWheel('Highlights', _currentAdj.colorWheels.highlights, (w) {
            _updateAdjustment(_currentAdj.copyWith(colorWheels: _currentAdj.colorWheels.copyWith(highlights: w)));
          }),
        ],
      ),
    );
  }

  Widget _buildMiniWheel(String label, ColorWheelValue value, ValueChanged<ColorWheelValue> onChanged) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [Colors.red, Colors.yellow, Colors.green, Colors.cyan, Colors.blue, Colors.purple, Colors.red],
            ),
            border: Border.all(color: Colors.white30, width: 2),
          ),
          child: Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 4)],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text('Tint: ${(value.intensity * 100).toInt()}%', style: const TextStyle(color: Colors.white54, fontSize: 9)),
      ],
    );
  }
}
