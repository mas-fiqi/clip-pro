import 'package:flutter/material.dart';
import '../../../../core/models/retouch_model.dart';

class RetouchBottomSheet extends StatefulWidget {
  final RetouchModel initialRetouch;

  const RetouchBottomSheet({super.key, required this.initialRetouch});

  static Future<RetouchModel?> show(BuildContext context, {required RetouchModel initialRetouch}) {
    return showModalBottomSheet<RetouchModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RetouchBottomSheet(initialRetouch: initialRetouch),
    );
  }

  @override
  State<RetouchBottomSheet> createState() => _RetouchBottomSheetState();
}

class _RetouchBottomSheetState extends State<RetouchBottomSheet> {
  late RetouchModel _retouch;
  RetouchCategory _activeCategory = RetouchCategory.skin;
  bool _isComparingBeforeAfter = false;

  @override
  void initState() {
    super.initState();
    _retouch = widget.initialRetouch;
  }

  void _resetAll() {
    setState(() {
      _retouch = const RetouchModel();
    });
  }

  void _applyBeautyPreset(String preset) {
    setState(() {
      switch (preset) {
        case 'natural':
          _retouch = _retouch.copyWith(
            smoothSkin: 0.35,
            brightenSkin: 0.25,
            blemishRemoval: 0.4,
            eyeBrighten: 0.2,
            teethWhitening: 0.3,
            lipstick: 0.2,
          );
          break;
        case 'soft':
          _retouch = _retouch.copyWith(
            smoothSkin: 0.6,
            brightenSkin: 0.45,
            blemishRemoval: 0.7,
            faceSlim: 0.25,
            cheekbones: 0.2,
            eyeBrighten: 0.4,
            blush: 0.35,
            lipstick: 0.4,
          );
          break;
        case 'glamour':
          _retouch = _retouch.copyWith(
            smoothSkin: 0.8,
            brightenSkin: 0.6,
            blemishRemoval: 0.9,
            faceSlim: 0.5,
            jawline: 0.45,
            eyeSize: 0.35,
            eyeBrighten: 0.6,
            eyebrow: 0.4,
            lipstick: 0.65,
            blush: 0.5,
            teethWhitening: 0.7,
            eyeDetail: 0.5,
          );
          break;
      }
    });
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
          // Drag Handle & Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Beauty Retouch & Wajah',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Modul Wajah, Kulit, Mata, Riasan & Tubuh',
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),

                  // Tombol Tahan Bandingkan Before/After
                  GestureDetector(
                    onTapDown: (_) => setState(() => _isComparingBeforeAfter = true),
                    onTapUp: (_) => setState(() => _isComparingBeforeAfter = false),
                    onTapCancel: () => setState(() => _isComparingBeforeAfter = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _isComparingBeforeAfter ? const Color(0xFF00E5FF) : Colors.white12,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.compare_rounded,
                            size: 14,
                            color: _isComparingBeforeAfter ? Colors.black : Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isComparingBeforeAfter ? 'Asli (Before)' : 'Bandingkan',
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

                  // Tombol Reset
                  TextButton(
                    onPressed: _resetAll,
                    child: const Text('Reset', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),

                  // Tombol Terapkan
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(_retouch);
                    },
                    child: const Text('Terapkan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),

          // Kategori Tab Bar (Skin, Face, Eyes, Makeup, Details, Body, Beauty Presets)
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: [
                _buildCategoryTab(RetouchCategory.skin, 'Kulit (Skin)', Icons.face_retouching_natural_rounded),
                _buildCategoryTab(RetouchCategory.face, 'Bentuk Wajah', Icons.face_rounded),
                _buildCategoryTab(RetouchCategory.eyes, 'Mata (Eyes)', Icons.remove_red_eye_rounded),
                _buildCategoryTab(RetouchCategory.makeup, 'Riasan (Makeup)', Icons.brush_rounded),
                _buildCategoryTab(RetouchCategory.details, 'Gigi & Detail', Icons.sentiment_very_satisfied_rounded),
                _buildCategoryTab(RetouchCategory.body, 'Tubuh (Body)', Icons.accessibility_new_rounded),
                _buildCategoryTab(RetouchCategory.beauty, 'Preset Alami', Icons.auto_awesome_rounded),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),

          // Kontrol Slider Berdasarkan Kategori yang Dipilih
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: _buildCategorySliders(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(RetouchCategory cat, String title, IconData icon) {
    final isSelected = _activeCategory == cat;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        avatar: Icon(icon, size: 14, color: isSelected ? Colors.black : Colors.white70),
        label: Text(title),
        selected: isSelected,
        selectedColor: const Color(0xFF00E5FF),
        backgroundColor: const Color(0xFF1E1E2C),
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white70,
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (_) => setState(() => _activeCategory = cat),
      ),
    );
  }

  Widget _buildCategorySliders() {
    switch (_activeCategory) {
      case RetouchCategory.skin:
        return Column(
          children: [
            _buildSliderRow('Haluskan Kulit (Smooth Skin)', _retouch.smoothSkin, (v) => setState(() => _retouch = _retouch.copyWith(smoothSkin: v))),
            _buildSliderRow('Mencerahkan Kulit (Brighten)', _retouch.brightenSkin, (v) => setState(() => _retouch = _retouch.copyWith(brightenSkin: v))),
            _buildSliderRow('Hilangkan Noda/Jerawat (Blemish)', _retouch.blemishRemoval, (v) => setState(() => _retouch = _retouch.copyWith(blemishRemoval: v))),
          ],
        );
      case RetouchCategory.face:
        return Column(
          children: [
            _buildSliderRow('Tiruskan Wajah (Face Slim)', _retouch.faceSlim, (v) => setState(() => _retouch = _retouch.copyWith(faceSlim: v))),
            _buildSliderRow('Garis Rahang (Jawline)', _retouch.jawline, (v) => setState(() => _retouch = _retouch.copyWith(jawline: v))),
            _buildSliderRow('Pipi Tirus (Cheekbones)', _retouch.cheekbones, (v) => setState(() => _retouch = _retouch.copyWith(cheekbones: v))),
          ],
        );
      case RetouchCategory.eyes:
        return Column(
          children: [
            _buildSliderRow('Mencerahkan Mata (Eye Brighten)', _retouch.eyeBrighten, (v) => setState(() => _retouch = _retouch.copyWith(eyeBrighten: v))),
            _buildSliderRow('Ukuran Mata (Eye Size)', _retouch.eyeSize, (v) => setState(() => _retouch = _retouch.copyWith(eyeSize: v))),
          ],
        );
      case RetouchCategory.makeup:
        return Column(
          children: [
            _buildSliderRow('Rona Bibir (Lipstick)', _retouch.lipstick, (v) => setState(() => _retouch = _retouch.copyWith(lipstick: v))),
            _buildSliderRow('Perona Pipi (Blush)', _retouch.blush, (v) => setState(() => _retouch = _retouch.copyWith(blush: v))),
            _buildSliderRow('Ketegasan Alis (Eyebrow)', _retouch.eyebrow, (v) => setState(() => _retouch = _retouch.copyWith(eyebrow: v))),
          ],
        );
      case RetouchCategory.details:
        return Column(
          children: [
            _buildSliderRow('Pemutih Gigi (Teeth Whitening)', _retouch.teethWhitening, (v) => setState(() => _retouch = _retouch.copyWith(teethWhitening: v))),
            _buildSliderRow('Detail Iris Mata (Eye Detail)', _retouch.eyeDetail, (v) => setState(() => _retouch = _retouch.copyWith(eyeDetail: v))),
          ],
        );
      case RetouchCategory.body:
        return Column(
          children: [
            _buildSliderRow('Rampingkan Tubuh (Body Slim)', _retouch.bodySlim, (v) => setState(() => _retouch = _retouch.copyWith(bodySlim: v))),
            _buildSliderRow('Bentuk Postur (Body Shape)', _retouch.bodyShape, (v) => setState(() => _retouch = _retouch.copyWith(bodyShape: v))),
          ],
        );
      case RetouchCategory.beauty:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Preset Kecantikan Instan (AI Beauty One-Tap)',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPresetCard('Alami', 'Natural Glow', Icons.spa_rounded, () => _applyBeautyPreset('natural')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPresetCard('Lembut', 'Soft Pastel', Icons.favorite_rounded, () => _applyBeautyPreset('soft')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPresetCard('Glamor', 'Pro Glamour', Icons.diamond_rounded, () => _applyBeautyPreset('glamour')),
                ),
              ],
            ),
          ],
        );
    }
  }

  Widget _buildPresetCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00E5FF), size: 24),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderRow(String title, double value, ValueChanged<double> onChanged) {
    final percent = (value * 100).toInt();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
              Text('$percent%', style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF00E5FF),
              inactiveTrackColor: Colors.white12,
              thumbColor: Colors.white,
              trackHeight: 3.5,
            ),
            child: Slider(
              value: value.clamp(0.0, 1.0),
              min: 0.0,
              max: 1.0,
              divisions: 100,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

