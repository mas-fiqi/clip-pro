import 'package:flutter/material.dart';
import '../../../../core/models/animation_model.dart';
import '../../../../core/services/animation_export_support.dart';
import '../../../../core/services/animation_library_service.dart';
import 'mini_animation_preview_widget.dart';

/// BottomSheet Animation Studio Profesional ala CapCut
/// Mendukung tab IN, OUT, COMBO, Kategori, Search, Favorit, Online Download, dan Kontrol Durasi & Intensitas
class AnimationStudioBottomSheet extends StatefulWidget {
  final ClipAnimationModel initialAnimation;
  final double clipDuration;
  final ValueChanged<ClipAnimationModel> onApply;
  final VoidCallback? onTriggerPreviewPlayback;

  const AnimationStudioBottomSheet({
    super.key,
    required this.initialAnimation,
    required this.clipDuration,
    required this.onApply,
    this.onTriggerPreviewPlayback,
  });

  static Future<ClipAnimationModel?> show(
    BuildContext context, {
    required ClipAnimationModel initialAnimation,
    required double clipDuration,
    required ValueChanged<ClipAnimationModel> onApply,
    VoidCallback? onTriggerPreviewPlayback,
  }) {
    return showModalBottomSheet<ClipAnimationModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AnimationStudioBottomSheet(
        initialAnimation: initialAnimation,
        clipDuration: clipDuration,
        onApply: onApply,
        onTriggerPreviewPlayback: onTriggerPreviewPlayback,
      ),
    );
  }

  @override
  State<AnimationStudioBottomSheet> createState() =>
      _AnimationStudioBottomSheetState();
}

class _AnimationStudioBottomSheetState extends State<AnimationStudioBottomSheet>
    with SingleTickerProviderStateMixin {
  final AnimationLibraryService _service = AnimationLibraryService();
  late TabController _tabController;

  late ClipAnimationModel _currentAnim;
  AnimationCategory? _selectedCategory;
  String _searchQuery = '';
  bool _showFavoritesOnly = false;
  final TextEditingController _searchController = TextEditingController();
  final Map<String, AnimationExportMode> _exportModeCache = {};

  @override
  void initState() {
    super.initState();
    _currentAnim = widget.initialAnimation;
    final initialTabIdx = _currentAnim.type.index;
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: initialTabIdx,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentAnim = _currentAnim.copyWith(
            type: AnimationApplicationType.values[_tabController.index],
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final mediaQuery = MediaQuery.of(context);
    final maxSheetHeight = (mediaQuery.size.height * 0.58).clamp(380.0, 460.0);

    return Container(
      height: maxSheetHeight + bottomInset,
      decoration: const BoxDecoration(
        color: Color(0xFF13131A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_motion_rounded,
                      color: Color(0xFF00E5FF),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Animasi Klip',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_currentAnim.hasAnimation)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 15),
                      label: const Text(
                        'Hapus',
                        style: TextStyle(fontSize: 11),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentAnim = const ClipAnimationModel();
                        });
                        widget.onApply(_currentAnim);
                      },
                    ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.pop(context, null),
                  ),
                ],
              ),
            ),

            // Tab Bar CapCut Style: IN | OUT | COMBO
            Container(
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C28),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: const Color(0xFF00E5FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
                tabs: const [
                  Tab(text: 'Masuk'),
                  Tab(text: 'Keluar'),
                  Tab(text: 'Kombinasi'),
                ],
              ),
            ),

            // Search & Filter Toolbar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2C),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            size: 14,
                            color: Colors.white38,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Cari Zoom, Shake, Flash, Glitch...',
                                hintStyle: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (val) {
                                setState(() => _searchQuery = val);
                              },
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white54,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Tombol Favorit
                  InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      setState(() => _showFavoritesOnly = !_showFavoritesOnly);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _showFavoritesOnly
                            ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                            : const Color(0xFF1E1E2C),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: _showFavoritesOnly
                              ? const Color(0xFFEF4444)
                              : Colors.white12,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _showFavoritesOnly
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _showFavoritesOnly
                                ? const Color(0xFFEF4444)
                                : Colors.white60,
                            size: 14,
                          ),
                          if (_showFavoritesOnly) ...[
                            const SizedBox(width: 4),
                            const Text(
                              'Fav',
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Category Chips Bar
            SizedBox(
              height: 28,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildCategoryChip(null, 'Semua'),
                  _buildCategoryChip(AnimationCategory.trending, '🔥 Tren'),
                  _buildCategoryChip(AnimationCategory.basic, 'Dasar'),
                  _buildCategoryChip(AnimationCategory.shake, 'Guncangan'),
                  _buildCategoryChip(AnimationCategory.light, 'Cahaya & Kilat'),
                  _buildCategoryChip(AnimationCategory.glitch, 'Glitch'),
                  _buildCategoryChip(AnimationCategory.threeD, 'Gerak 3D'),
                  _buildCategoryChip(
                    AnimationCategory.motion,
                    'Gerakan Dinamis',
                  ),
                  _buildCategoryChip(AnimationCategory.retro, 'Retro & Lawas'),
                  _buildCategoryChip(AnimationCategory.cinematic, 'Sinematik'),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Preset Grid
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPresetGrid(AnimationApplicationType.inAnimation),
                  _buildPresetGrid(AnimationApplicationType.outAnimation),
                  _buildPresetGrid(AnimationApplicationType.comboAnimation),
                ],
              ),
            ),

            // Controls Slider (Durasi & Intensitas Animasi - Modern Double Slider Row)
            if (_currentAnim.hasAnimation) _buildUnifiedControlsBar(),

            // Bottom Action Bar: Selesai
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF0F0F16),
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentAnim.hasAnimation
                              ? _currentAnim.presetId
                                    .replaceAll('_', ' ')
                                    .toUpperCase()
                              : 'Tanpa Animasi',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_currentAnim.hasAnimation)
                          Text(
                            'Durasi: ${_currentAnim.duration.toStringAsFixed(1)}s • Intensitas: ${(_currentAnim.intensity * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        if (_currentAnim.hasAnimation &&
                            _isPreviewOnlyPresetId(_currentAnim.presetId))
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Text(
                              'Hanya preview • tidak ikut ekspor',
                              style: TextStyle(
                                color: Color(0xFFFFB020),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Tombol Preview Playback langsung pada video
                  if (widget.onTriggerPreviewPlayback != null &&
                      _currentAnim.hasAnimation)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00E5FF),
                          side: const BorderSide(
                            color: Color(0xFF00E5FF),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 16),
                        label: const Text(
                          'Preview',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          widget.onTriggerPreviewPlayback?.call();
                        },
                      ),
                    ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      widget.onApply(_currentAnim);
                      Navigator.pop(context, _currentAnim);
                    },
                    label: const Text(
                      'Terapkan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Status ekspor untuk preset yang sedang dipilih.
  bool _isPreviewOnlyPresetId(String presetId) {
    if (presetId.isEmpty) return false;
    final cached = _exportModeCache[presetId];
    if (cached != null) return cached == AnimationExportMode.previewOnly;

    final preset = AnimationExportSupportService.findPreset(presetId);
    if (preset == null) return false;

    final mode = AnimationExportSupportService.resolve(preset).mode;
    _exportModeCache[presetId] = mode;
    return mode == AnimationExportMode.previewOnly;
  }

  Widget _buildCategoryChip(AnimationCategory? cat, String label) {
    final isSelected = _selectedCategory == cat;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = cat),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00E5FF).withValues(alpha: 0.2)
              : const Color(0xFF1E1E2B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E5FF) : Colors.white12,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF00E5FF) : Colors.white70,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetGrid(AnimationApplicationType type) {
    final presets = _service.filterPresets(
      category: _selectedCategory,
      type: type,
      searchQuery: _searchQuery,
      favoritesOnly: _showFavoritesOnly,
    );

    if (presets.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada animasi yang cocok',
          style: TextStyle(color: Colors.white38, fontSize: 13),
        ),
      );
    }

    final totalCount = _currentAnim.hasAnimation
        ? presets.length + 1
        : presets.length + 1;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        childAspectRatio: 0.76,
      ),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        // Tombol Pertama: "Tidak Ada" ala CapCut
        if (index == 0) {
          final isNoneSelected = !_currentAnim.hasAnimation;
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentAnim = _currentAnim.copyWith(presetId: null);
              });
              widget.onApply(_currentAnim);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isNoneSelected
                          ? const Color(0xFF23D2E2).withValues(alpha: 0.15)
                          : const Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isNoneSelected
                            ? const Color(0xFF23D2E2)
                            : Colors.white12,
                        width: isNoneSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.block_rounded,
                        color: isNoneSelected
                            ? const Color(0xFF23D2E2)
                            : Colors.white54,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Tidak Ada',
                  style: TextStyle(
                    color: isNoneSelected
                        ? const Color(0xFF23D2E2)
                        : Colors.white70,
                    fontSize: 10.5,
                    fontWeight: isNoneSelected
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }

        final preset = presets[index - 1];
        final isSelected = _currentAnim.presetId == preset.id;
        final isDownloaded = _service.isPresetDownloaded(preset.id);
        final exportMode = _exportModeCache.putIfAbsent(
          preset.id,
          () => AnimationExportSupportService.resolve(preset).mode,
        );
        final isPreviewOnly = exportMode == AnimationExportMode.previewOnly;

        return GestureDetector(
          onTap: () async {
            if (preset.isOnline && !isDownloaded) {
              final success = await _service.downloadPreset(
                preset,
                onProgress: (_) => setState(() {}),
              );
              if (!success) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal mengunduh preset online'),
                    ),
                  );
                }
                return;
              }
            }

            setState(() {
              _currentAnim = _currentAnim.copyWith(
                presetId: preset.id,
                type: preset.type,
              );
            });
            _service.recordRecentlyUsed(preset.id);
            widget.onApply(_currentAnim);
            widget.onTriggerPreviewPlayback?.call();

            // Log mode ekspor agar status preview vs render tidak menyesatkan.
            debugPrint('''
[EFFECT DEBUG]
=========================================
Effect: ${preset.name}
Effect ID: ${preset.id}
Category: ${preset.category.name.toUpperCase()}
Export Mode: ${exportMode.name}
Export Filter: ${exportMode == AnimationExportMode.previewOnly ? 'NONE (preview only)' : 'AVAILABLE'}
=========================================
''');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: MiniAnimationPreviewWidget(
                        preset: preset,
                        isSelected: isSelected,
                      ),
                    ),
                    if (isPreviewOnly)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Tooltip(
                          message:
                              'Hanya preview — animasi ini tidak ikut diekspor',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFFFB020),
                                width: 0.8,
                              ),
                            ),
                            child: const Icon(
                              Icons.visibility_outlined,
                              size: 11,
                              color: Color(0xFFFFB020),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                preset.name,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF23D2E2) : Colors.white70,
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnifiedControlsBar() {
    final maxAnimDur = widget.clipDuration > 0 ? widget.clipDuration : 5.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0xFF161622),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Durasi Animasi
          Row(
            children: [
              const SizedBox(
                width: 72,
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 13, color: Colors.white70),
                    SizedBox(width: 4),
                    Text(
                      'Durasi',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 10,
                    ),
                    activeTrackColor: const Color(0xFF00E5FF),
                    inactiveTrackColor: Colors.white12,
                    thumbColor: const Color(0xFF00E5FF),
                  ),
                  child: Slider(
                    value: _currentAnim.duration.clamp(0.1, maxAnimDur),
                    min: 0.1,
                    max: maxAnimDur,
                    onChanged: (val) {
                      setState(() {
                        _currentAnim = _currentAnim.copyWith(duration: val);
                      });
                      widget.onApply(_currentAnim);
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '${_currentAnim.duration.toStringAsFixed(1)}s',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Row 2: Intensitas Animasi
          Row(
            children: [
              const SizedBox(
                width: 72,
                child: Row(
                  children: [
                    Icon(Icons.tune_rounded, size: 13, color: Colors.white70),
                    SizedBox(width: 4),
                    Text(
                      'Intensitas',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 10,
                    ),
                    activeTrackColor: const Color(0xFF00E5FF),
                    inactiveTrackColor: Colors.white12,
                    thumbColor: const Color(0xFF00E5FF),
                  ),
                  child: Slider(
                    value: _currentAnim.intensity.clamp(0.1, 2.0),
                    min: 0.1,
                    max: 2.0,
                    onChanged: (val) {
                      setState(() {
                        _currentAnim = _currentAnim.copyWith(intensity: val);
                      });
                      widget.onApply(_currentAnim);
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '${(_currentAnim.intensity * 100).toInt()}%',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
