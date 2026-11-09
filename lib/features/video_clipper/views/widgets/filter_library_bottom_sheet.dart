import 'package:flutter/material.dart';
import '../../../../core/models/color_adjustment_model.dart';
import '../../../../core/models/filter_catalog.dart';

/// CapCut-Style Filter Library Bottom Sheet
/// Menampilkan filter dengan visual model nyata potret, tab horizontal, search bar, slider intensitas, dan layout 4 kolom
class FilterLibraryBottomSheet extends StatefulWidget {
  final ColorAdjustmentModel initialAdjustment;

  const FilterLibraryBottomSheet({super.key, required this.initialAdjustment});

  static Future<ColorAdjustmentModel?> show(
    BuildContext context, {
    required ColorAdjustmentModel initialAdjustment,
  }) {
    return showModalBottomSheet<ColorAdjustmentModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FilterLibraryBottomSheet(initialAdjustment: initialAdjustment),
    );
  }

  @override
  State<FilterLibraryBottomSheet> createState() => _FilterLibraryBottomSheetState();
}

class _FilterLibraryBottomSheetState extends State<FilterLibraryBottomSheet> {
  late FilterPreset _selectedPreset;
  late double _intensity;
  late double _brightness;
  late double _contrast;
  late double _saturation;
  late double _vignette;
  late double _blur;

  FilterCategory _activeCategory = FilterCategory.original;
  String _searchQuery = '';
  bool _isComparingBeforeAfter = false;

  @override
  void initState() {
    super.initState();
    _selectedPreset = widget.initialAdjustment.preset;
    _intensity = widget.initialAdjustment.filterIntensity;
    _brightness = widget.initialAdjustment.brightness;
    _contrast = widget.initialAdjustment.contrast;
    _saturation = widget.initialAdjustment.saturation;
    _vignette = widget.initialAdjustment.vignette;
    _blur = widget.initialAdjustment.blur;

    final item = FilterCatalog.getItem(_selectedPreset);
    _activeCategory = item.category;
  }

  ColorAdjustmentModel _buildCurrentAdjustment() {
    return widget.initialAdjustment.copyWith(
      preset: _selectedPreset,
      filterIntensity: _intensity,
      brightness: _brightness,
      contrast: _contrast,
      saturation: _saturation,
      vignette: _vignette,
      blur: _blur,
    );
  }

  void _resetToOriginal() {
    setState(() {
      _selectedPreset = FilterPreset.normal;
      _intensity = 1.0;
      _activeCategory = FilterCategory.original;
    });
  }

  // Pilih foto potret model realistis untuk filter preview
  String _selectModelImage(FilterPreset preset, FilterCategory cat) {
    if (cat == FilterCategory.vintage || cat == FilterCategory.film) {
      return 'assets/images/effect_previews/retro_vintage.jpg';
    }
    if (cat == FilterCategory.warm || preset == FilterPreset.goldenHour || preset == FilterPreset.sunset) {
      return 'assets/images/effect_previews/woman_portrait.jpg';
    }
    if (preset == FilterPreset.cyberpunk || cat == FilterCategory.gaming) {
      return 'assets/images/effect_previews/cinematic_neon.jpg';
    }
    if (cat == FilterCategory.portrait || preset == FilterPreset.softSkin || preset == FilterPreset.glowPortrait) {
      return 'assets/images/effect_previews/portrait_glamour.jpg';
    }
    if (cat == FilterCategory.cool || preset == FilterPreset.arctic || preset == FilterPreset.deepOcean) {
      return 'assets/images/effect_previews/cool_boy.jpg';
    }
    return 'assets/images/effect_previews/portrait_girl.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = FilterCatalog.items.where((item) {
      if (_searchQuery.isNotEmpty) {
        return item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      if (_activeCategory == FilterCategory.original) {
        return true; // Sedang tren / semua
      }
      return item.category == _activeCategory;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Color(0xFF141416), // Solid deep charcoal black ala CapCut
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          // Drag Handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Header Search Bar & Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                // Minimalist Search Bar ala CapCut
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22242A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: Colors.white54, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: 'Cari filter (Sinematik, Film, Cerah...)',
                              hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (val) => setState(() => _searchQuery = val),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () => setState(() => _searchQuery = ''),
                            child: const Icon(Icons.close_rounded, size: 16, color: Colors.white54),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Tombol Tahan Bandingkan (Before / After)
                GestureDetector(
                  onTapDown: (_) => setState(() => _isComparingBeforeAfter = true),
                  onTapUp: (_) => setState(() => _isComparingBeforeAfter = false),
                  onTapCancel: () => setState(() => _isComparingBeforeAfter = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: _isComparingBeforeAfter ? const Color(0xFF23D2E2) : const Color(0xFF22242A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.compare_rounded,
                          size: 14,
                          color: _isComparingBeforeAfter ? Colors.black : Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isComparingBeforeAfter ? 'Ori' : 'Bandingkan',
                          style: TextStyle(
                            color: _isComparingBeforeAfter ? Colors.black : Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Reset jika bukan normal
                if (_selectedPreset != FilterPreset.normal) ...[
                  IconButton(
                    icon: const Icon(Icons.restart_alt_rounded, color: Colors.white60, size: 22),
                    tooltip: 'Reset Filter',
                    onPressed: _resetToOriginal,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                  const SizedBox(width: 4),
                ],

                // Checkmark Confirm Button ala CapCut
                InkWell(
                  onTap: () => Navigator.of(context).pop(_buildCurrentAdjustment()),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 26),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Horizontal Category Tabs ala CapCut
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                _buildFilterTab(
                  label: 'Sedang tren 🔥',
                  isSelected: _activeCategory == FilterCategory.original && _searchQuery.isEmpty,
                  onTap: () => setState(() {
                    _activeCategory = FilterCategory.original;
                    _searchQuery = '';
                  }),
                ),
                _buildFilterTab(
                  label: 'Sinematik 🎬',
                  isSelected: _activeCategory == FilterCategory.cinematic,
                  onTap: () => setState(() {
                    _activeCategory = FilterCategory.cinematic;
                    _searchQuery = '';
                  }),
                ),
                _buildFilterTab(
                  label: 'Potret Wajah 👤',
                  isSelected: _activeCategory == FilterCategory.portrait,
                  onTap: () => setState(() {
                    _activeCategory = FilterCategory.portrait;
                    _searchQuery = '';
                  }),
                ),
                _buildFilterTab(
                  label: 'Vintage Film 🎞️',
                  isSelected: _activeCategory == FilterCategory.vintage,
                  onTap: () => setState(() {
                    _activeCategory = FilterCategory.vintage;
                    _searchQuery = '';
                  }),
                ),
                _buildFilterTab(
                  label: 'Hangat (Warm) ☀️',
                  isSelected: _activeCategory == FilterCategory.warm,
                  onTap: () => setState(() {
                    _activeCategory = FilterCategory.warm;
                    _searchQuery = '';
                  }),
                ),
                _buildFilterTab(
                  label: 'Dingin (Cool) ❄️',
                  isSelected: _activeCategory == FilterCategory.cool,
                  onTap: () => setState(() {
                    _activeCategory = FilterCategory.cool;
                    _searchQuery = '';
                  }),
                ),
                _buildFilterTab(
                  label: 'Film Klasik 📽️',
                  isSelected: _activeCategory == FilterCategory.film,
                  onTap: () => setState(() {
                    _activeCategory = FilterCategory.film;
                    _searchQuery = '';
                  }),
                ),
                _buildFilterTab(
                  label: 'Hitam Putih 🖤',
                  isSelected: _activeCategory == FilterCategory.blackAndWhite,
                  onTap: () => setState(() {
                    _activeCategory = FilterCategory.blackAndWhite;
                    _searchQuery = '';
                  }),
                ),
                _buildFilterTab(
                  label: 'Dramatis ⚡',
                  isSelected: _activeCategory == FilterCategory.dramatic,
                  onTap: () => setState(() {
                    _activeCategory = FilterCategory.dramatic;
                    _searchQuery = '';
                  }),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white10, height: 1, thickness: 1),

          // Slider Intensitas jika filter dipilih
          if (_selectedPreset != FilterPreset.normal)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: const Color(0xFF191B20),
              child: Row(
                children: [
                  Text(
                    FilterCatalog.getItem(_selectedPreset).name,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF23D2E2),
                        inactiveTrackColor: Colors.white12,
                        thumbColor: Colors.white,
                        trackHeight: 2.5,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: _intensity,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (val) => setState(() => _intensity = val),
                      ),
                    ),
                  ),
                  Text(
                    '${(_intensity * 100).toInt()}%',
                    style: const TextStyle(color: Color(0xFF23D2E2), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          // 4-Column CapCut Grid Tampilan Filter Realistis
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 4 kolom ala CapCut
                crossAxisSpacing: 10,
                mainAxisSpacing: 14,
                childAspectRatio: 0.72, // Potret rasio CapCut
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final isSelected = _selectedPreset == item.preset;
                final modelAsset = _selectModelImage(item.preset, item.category);

                // Buat matrix interpolasi sesuai intensitas jika terpilih
                final currentMatrix = isSelected && !_isComparingBeforeAfter
                    ? FilterCatalog.getBlendedMatrix(item.preset, _intensity)
                    : item.matrix;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPreset = item.preset;
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Thumbnail Card Persegi Membulat Potret
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF23D2E2) : Colors.white10,
                              width: isSelected ? 2.2 : 0.8,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Foto Model Asli dengan ColorFiltered Matrix Filter
                              ColorFiltered(
                                colorFilter: ColorFilter.matrix(currentMatrix),
                                child: Image.asset(
                                  modelAsset,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFF2A2D35),
                                    child: const Icon(Icons.photo_filter, color: Colors.white24),
                                  ),
                                ),
                              ),

                              // Diamond Pro Badge CapCut
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF16C2D5).withValues(alpha: 0.85),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.diamond_rounded,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              // Selection Halo Overlay
                              if (isSelected)
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFF23D2E2), width: 2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Nama Filter di Bawah Kartu
                      Text(
                        item.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF23D2E2) : Colors.white70,
                          fontSize: 10.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              width: isSelected ? 22 : 0,
              decoration: BoxDecoration(
                color: const Color(0xFF23D2E2),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
