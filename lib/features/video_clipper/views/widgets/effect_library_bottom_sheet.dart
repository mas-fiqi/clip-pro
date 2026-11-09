import 'package:flutter/material.dart';
import '../../../../core/models/video_effect_model.dart';
import '../../../../core/services/effect_preview_player_manager.dart';
import '../../../../core/services/online_ai_effect_api_service.dart';
import '../../../../core/theme/app_design_tokens.dart';
import 'effect_video_card_preview.dart';

/// CapCut-Style Live Video Effect Studio Bottom Sheet
/// Dilengkapi Video Preview Nyata untuk Setiap Preset, Panel Detail Parameter, & Realtime Live Preview
class EffectLibraryBottomSheet extends StatefulWidget {
  final VideoEffectModel initialEffect;
  final String initialMode; // 'video', 'body', 'photo', 'ai'
  final ValueChanged<VideoEffectModel>? onPreviewEffectChanged; // Live preview pada video pengguna

  const EffectLibraryBottomSheet({
    super.key,
    required this.initialEffect,
    this.initialMode = 'video',
    this.onPreviewEffectChanged,
  });

  static Future<VideoEffectModel?> show(
    BuildContext context, {
    required VideoEffectModel initialEffect,
    String initialMode = 'video',
    ValueChanged<VideoEffectModel>? onPreviewEffectChanged,
  }) {
    return showModalBottomSheet<VideoEffectModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EffectLibraryBottomSheet(
        initialEffect: initialEffect,
        initialMode: initialMode,
        onPreviewEffectChanged: onPreviewEffectChanged,
      ),
    );
  }

  @override
  State<EffectLibraryBottomSheet> createState() => _EffectLibraryBottomSheetState();
}

class _EffectLibraryBottomSheetState extends State<EffectLibraryBottomSheet> {
  late EffectType _selectedType;
  late double _intensity;
  late double _durationSeconds;

  // Nilai Gerak Samar (Motion Blur)
  late double _blurAmount;
  late double _blendAmount;
  late MotionBlurDirection _motionDirection;
  late int _motionTimes;

  // 4 Mode Utama ala CapCut: 'video', 'body', 'photo', 'ai'
  late String _activeEffectMode;

  // Sub-kategori tab horizontal di atas grid
  String _activeTabKey = 'trending';
  String _searchQuery = '';

  // Data efek AI & Cloud API
  List<AiCloudEffectItem> _aiEffects = [];
  bool _isLoadingAi = false;

  // Tampilkan panel detail / fullscreen video demo
  bool _showLargeDemo = true;

  final Set<EffectType> _favorites = {
    EffectType.oldFilmGrain,
    EffectType.rgbSplit,
    EffectType.retroScanline,
    EffectType.letterbox,
  };

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialEffect.type;
    _intensity = widget.initialEffect.intensity;
    _durationSeconds = widget.initialEffect.durationSeconds;
    _blurAmount = widget.initialEffect.blurAmount;
    _blendAmount = widget.initialEffect.blendAmount;
    _motionDirection = widget.initialEffect.motionDirection;
    _motionTimes = widget.initialEffect.motionTimes;
    _activeEffectMode = widget.initialMode;

    _loadAiEffects();
  }

  @override
  void dispose() {
    // Pause video player preview saat dialog ditutup
    EffectPreviewPlayerManager().pauseAll();
    super.dispose();
  }

  Future<void> _loadAiEffects() async {
    setState(() => _isLoadingAi = true);
    try {
      final effects = await OnlineAiEffectApiService().fetchAiEffects();
      if (mounted) {
        setState(() {
          _aiEffects = effects;
          _isLoadingAi = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingAi = false);
      }
    }
  }

  VideoEffectModel _buildCurrentEffect() {
    return VideoEffectModel(
      type: _selectedType,
      intensity: _intensity,
      durationSeconds: _durationSeconds,
      isFavorite: _favorites.contains(_selectedType),
      blurAmount: _blurAmount,
      blendAmount: _blendAmount,
      motionDirection: _motionDirection,
      motionTimes: _motionTimes,
    );
  }

  void _notifyPreviewChanged() {
    if (widget.onPreviewEffectChanged != null) {
      widget.onPreviewEffectChanged!(_buildCurrentEffect());
    }
  }

  void _removeEffect() {
    setState(() {
      _selectedType = EffectType.none;
      _intensity = 1.0;
      _durationSeconds = 0.0;
    });
    _notifyPreviewChanged();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Saring item sesuai _activeEffectMode dan _activeTabKey
    List<_UnifiedEffectDisplayItem> displayList = [];

    if (_activeEffectMode == 'body') {
      var bodyList = _aiEffects.where((e) => e.category == 'Efek tubuh').toList();
      if (_searchQuery.isNotEmpty) {
        bodyList = bodyList
            .where((e) =>
                e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                e.description.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      }
      displayList = bodyList.map((ai) {
        return _UnifiedEffectDisplayItem(
          id: ai.id,
          name: ai.name,
          type: ai.fallbackType,
          description: ai.description,
          previewImageUrl: ai.previewImageUrl,
          isAiEffect: true,
          badgeLabel: 'BODY',
        );
      }).toList();
    } else if (_activeEffectMode == 'photo') {
      var photoList = _aiEffects.where((e) => e.category == 'Efek foto').toList();
      if (_searchQuery.isNotEmpty) {
        photoList = photoList
            .where((e) =>
                e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                e.description.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      }
      displayList = photoList.map((ai) {
        return _UnifiedEffectDisplayItem(
          id: ai.id,
          name: ai.name,
          type: ai.fallbackType,
          description: ai.description,
          previewImageUrl: ai.previewImageUrl,
          isAiEffect: true,
          badgeLabel: 'PHOTO',
        );
      }).toList();
    } else if (_activeEffectMode == 'ai') {
      var aiList = _aiEffects.where((e) => e.category == 'Efek AI').toList();
      if (_searchQuery.isNotEmpty) {
        aiList = aiList
            .where((e) =>
                e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                e.description.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      }
      displayList = aiList.map((ai) {
        return _UnifiedEffectDisplayItem(
          id: ai.id,
          name: ai.name,
          type: ai.fallbackType,
          description: ai.description,
          previewImageUrl: ai.previewImageUrl,
          isAiEffect: true,
          badgeLabel: 'AI',
        );
      }).toList();
    } else {
      // Efek Video (Kategori CapCut Standar & Tema B.Duck/Halloween)
      if (_activeTabKey == 'bduck') {
        final bduck = _aiEffects.where((e) => e.subCategory == 'B.Duck').toList();
        displayList = bduck.map((ai) {
          return _UnifiedEffectDisplayItem(
            id: ai.id,
            name: ai.name,
            type: ai.fallbackType,
            description: ai.description,
            previewImageUrl: ai.previewImageUrl,
            isAiEffect: true,
            badgeLabel: 'DUCK',
          );
        }).toList();
      } else if (_activeTabKey == 'halloween') {
        final hw = _aiEffects.where((e) => e.subCategory == 'Halloween').toList();
        displayList = hw.map((ai) {
          return _UnifiedEffectDisplayItem(
            id: ai.id,
            name: ai.name,
            type: ai.fallbackType,
            description: ai.description,
            previewImageUrl: ai.previewImageUrl,
            isAiEffect: true,
            badgeLabel: 'SPOOKY',
          );
        }).toList();
      } else {
        var catalogFiltered = EffectCatalog.items.where((item) {
          if (_searchQuery.isNotEmpty) {
            return item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                item.description.toLowerCase().contains(_searchQuery.toLowerCase());
          }
          switch (_activeTabKey) {
            case 'trending':
              return true;
            case 'cinematic':
              return item.category == EffectCategory.cinematic;
            case 'retro':
              return item.category == EffectCategory.retro;
            case 'vintage':
              return item.category == EffectCategory.vintage;
            case 'glitch':
              return item.category == EffectCategory.glitch;
            case 'blur':
              return item.category == EffectCategory.blur;
            case 'light':
              return item.category == EffectCategory.light;
            case 'distortion':
              return item.category == EffectCategory.distortion;
            case 'color':
              return item.category == EffectCategory.color;
            case 'motion':
              return item.category == EffectCategory.motion;
            case 'creative':
              return item.category == EffectCategory.creative;
            default:
              return true;
          }
        }).toList();

        displayList = catalogFiltered.map((item) {
          return _UnifiedEffectDisplayItem(
            id: item.type.name,
            name: item.name,
            type: item.type,
            description: item.description,
            previewImageUrl: null,
            isAiEffect: false,
            badgeLabel: null,
          );
        }).toList();
      }
    }

    final selectedItem = EffectCatalog.getItem(_selectedType);

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
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

          // CapCut Search Bar & Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                // Minimalist Search Bar
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
                            decoration: InputDecoration(
                              hintText: _activeEffectMode == 'body'
                                  ? 'Cari efek tubuh (Laser, Sayap, Aura...)'
                                  : _activeEffectMode == 'photo'
                                      ? 'Cari efek foto (3D Zoom, Light Leak...)'
                                      : 'Orang-orang sedang mencari video demo',
                              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
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

                // Reset Button jika ada efek yang aktif
                if (_selectedType != EffectType.none) ...[
                  IconButton(
                    icon: const Icon(Icons.restart_alt_rounded, color: Colors.white60, size: 22),
                    tooltip: 'Hapus Efek',
                    onPressed: _removeEffect,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                  const SizedBox(width: 4),
                ],

                // Checkmark Confirm Button ala CapCut
                InkWell(
                  onTap: () => Navigator.of(context).pop(_buildCurrentEffect()),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF23D2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_rounded, color: Colors.black, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Terapkan',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
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

          const SizedBox(height: 8),

          // Sub-kategori horizontal tabs (Hanya relevan jika di mode 'video')
          if (_activeEffectMode == 'video') ...[
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: [
                  _buildSubCategoryTab(
                    label: 'Sedang tren 🔥',
                    isSelected: _activeTabKey == 'trending',
                    onTap: () => setState(() {
                      _activeTabKey = 'trending';
                      _searchQuery = '';
                    }),
                  ),
                  _buildSubCategoryTab(
                    label: 'B.Duck 🐥',
                    isSelected: _activeTabKey == 'bduck',
                    onTap: () => setState(() {
                      _activeTabKey = 'bduck';
                      _searchQuery = '';
                    }),
                  ),
                  _buildSubCategoryTab(
                    label: 'Halloween 🎃',
                    isSelected: _activeTabKey == 'halloween',
                    onTap: () => setState(() {
                      _activeTabKey = 'halloween';
                      _searchQuery = '';
                    }),
                  ),
                  _buildSubCategoryTab(
                    label: 'Sinematik',
                    isSelected: _activeTabKey == 'cinematic',
                    onTap: () => setState(() {
                      _activeTabKey = 'cinematic';
                      _searchQuery = '';
                    }),
                  ),
                  _buildSubCategoryTab(
                    label: 'Motion FX',
                    isSelected: _activeTabKey == 'motion',
                    onTap: () => setState(() {
                      _activeTabKey = 'motion';
                      _searchQuery = '';
                    }),
                  ),
                  _buildSubCategoryTab(
                    label: 'Retro & CRT',
                    isSelected: _activeTabKey == 'retro',
                    onTap: () => setState(() {
                      _activeTabKey = 'retro';
                      _searchQuery = '';
                    }),
                  ),
                  _buildSubCategoryTab(
                    label: 'Vintage Film',
                    isSelected: _activeTabKey == 'vintage',
                    onTap: () => setState(() {
                      _activeTabKey = 'vintage';
                      _searchQuery = '';
                    }),
                  ),
                  _buildSubCategoryTab(
                    label: 'Glitch FX',
                    isSelected: _activeTabKey == 'glitch',
                    onTap: () => setState(() {
                      _activeTabKey = 'glitch';
                      _searchQuery = '';
                    }),
                  ),
                  _buildSubCategoryTab(
                    label: 'Blur & Samar',
                    isSelected: _activeTabKey == 'blur',
                    onTap: () => setState(() {
                      _activeTabKey = 'blur';
                      _searchQuery = '';
                    }),
                  ),
                  _buildSubCategoryTab(
                    label: 'Cahaya & Glow',
                    isSelected: _activeTabKey == 'light',
                    onTap: () => setState(() {
                      _activeTabKey = 'light';
                      _searchQuery = '';
                    }),
                  ),
                  _buildSubCategoryTab(
                    label: 'Distorsi & Cermin',
                    isSelected: _activeTabKey == 'distortion',
                    onTap: () => setState(() {
                      _activeTabKey = 'distortion';
                      _searchQuery = '';
                    }),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1, thickness: 1),
          ],

          // Panel Detail Video Demonstrasi & Parameter Khusus
          if (_selectedType != EffectType.none && _showLargeDemo) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2026),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF23D2E2).withValues(alpha: 0.35), width: 1),
              ),
              child: Row(
                children: [
                  // Video Demo Ukuran Lebih Besar (3:4 ratio)
                  Container(
                    width: 70,
                    height: 94,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF23D2E2), width: 1.5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: EffectVideoCardPreview(
                      item: selectedItem,
                      isSelected: true,
                      isLargePreview: true,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Detail & Slider Kontrol
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectedItem.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF23D2E2).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${(_intensity * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Color(0xFF23D2E2),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selectedItem.description,
                          style: const TextStyle(color: Colors.white54, fontSize: 10.5),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Slider Intensitas
                        Row(
                          children: [
                            const Text('Intensitas:', style: TextStyle(color: Colors.white70, fontSize: 10)),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: const Color(0xFF23D2E2),
                                  inactiveTrackColor: Colors.white12,
                                  thumbColor: Colors.white,
                                  trackHeight: 2.2,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                                ),
                                child: Slider(
                                  value: _intensity,
                                  min: 0.0,
                                  max: 1.0,
                                  onChanged: (val) {
                                    setState(() => _intensity = val);
                                    _notifyPreviewChanged();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 4-Column CapCut Grid Tampilan Efek dengan Video Preview Nyata
          Expanded(
            child: _isLoadingAi && displayList.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppDesignTokens.cyanAccent, strokeWidth: 2.5),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // 4 kolom ala CapCut
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.70,
                    ),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final item = displayList[index];
                      final isSelected = _selectedType == item.type;
                      final catalogItem = EffectCatalog.getItem(item.type);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedType = item.type;
                            _showLargeDemo = true;
                          });
                          _notifyPreviewChanged();
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Kartu Efek Persegi Potret
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
                                    // Live Video Card Preview (Autoplay 2-4 detik muted)
                                    EffectVideoCardPreview(
                                      item: catalogItem,
                                      isSelected: isSelected,
                                      customImageUrl: item.previewImageUrl,
                                    ),

                                    // CapCut Style Top-Right Badge
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: item.badgeLabel != null
                                              ? const Color(0xFF9C27B0)
                                              : const Color(0xFF16C2D5).withValues(alpha: 0.85),
                                          borderRadius: BorderRadius.circular(item.badgeLabel != null ? 3 : 10),
                                        ),
                                        child: item.badgeLabel != null
                                            ? Text(
                                                item.badgeLabel!,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 7.5,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              )
                                            : const Icon(
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

                            // Nama Efek Minimalis
                            Text(
                              item.name,
                              style: TextStyle(
                                color: isSelected ? const Color(0xFF23D2E2) : Colors.white70,
                                fontSize: 10.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Parameter Gerak Samar (Motion Blur) Khusus jika dipilih
          if (_selectedType == EffectType.motionBlur)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF191B20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gerak Samar (Motion Blur Settings)',
                      style: TextStyle(color: Color(0xFF23D2E2), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('Kabur:', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      Expanded(
                        child: Slider(
                          value: _blurAmount,
                          min: 0.0,
                          max: 100.0,
                          activeColor: const Color(0xFF23D2E2),
                          onChanged: (val) {
                            setState(() => _blurAmount = val);
                            _notifyPreviewChanged();
                          },
                        ),
                      ),
                      Text('${_blurAmount.toInt()}%', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),

          // Bilah 4 Mode Efek Utama di Bagian Bawah
          Container(
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFF101012),
              border: Border(top: BorderSide(color: Colors.white10, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildModeButton(
                  icon: Icons.movie_filter_outlined,
                  activeIcon: Icons.movie_filter_rounded,
                  label: 'Efek video',
                  modeKey: 'video',
                ),
                _buildModeButton(
                  icon: Icons.face_retouching_natural_outlined,
                  activeIcon: Icons.face_retouching_natural_rounded,
                  label: 'Efek tubuh',
                  modeKey: 'body',
                  hasNewBadge: true,
                ),
                _buildModeButton(
                  icon: Icons.crop_original_outlined,
                  activeIcon: Icons.crop_original_rounded,
                  label: 'Efek foto',
                  modeKey: 'photo',
                  hasNewBadge: true,
                ),
                _buildModeButton(
                  icon: Icons.auto_awesome_outlined,
                  activeIcon: Icons.auto_awesome_rounded,
                  label: 'Efek AI',
                  modeKey: 'ai',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String modeKey,
    bool hasNewBadge = false,
  }) {
    final isSel = _activeEffectMode == modeKey;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeEffectMode = modeKey;
          _searchQuery = '';
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                isSel ? activeIcon : icon,
                color: isSel ? const Color(0xFF23D2E2) : Colors.white60,
                size: 21,
              ),
              if (hasNewBadge)
                Positioned(
                  top: -4,
                  right: -14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFF23D2E2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'New',
                      style: TextStyle(color: Colors.black, fontSize: 7, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: isSel ? const Color(0xFF23D2E2) : Colors.white60,
              fontSize: 10,
              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryTab({
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
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              height: 2,
              width: isSelected ? 20 : 0,
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

class _UnifiedEffectDisplayItem {
  final String id;
  final String name;
  final EffectType type;
  final String description;
  final String? previewImageUrl;
  final bool isAiEffect;
  final String? badgeLabel;

  const _UnifiedEffectDisplayItem({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    this.previewImageUrl,
    required this.isAiEffect,
    this.badgeLabel,
  });
}
