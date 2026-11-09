import 'package:flutter/material.dart';
import '../../../../core/models/clip_transform_model.dart';
import 'interactive_crop_canvas.dart';

/// Modal Studio Crop & Transform Komprehensif ala CapCut Pro:
/// 1. Rotasi Halus Slider (-180° s/d +180°), Snap ke 0/90/-90/180, Input Angka, Flip H/V
/// 2. Aspek Rasio Lengkap: Original, 9:16, 16:9, 1:1, 4:3, 4:5, 3:4, 1.85:1, 2.35:1, 2.39:1, 21:9, Custom
/// 3. Interactive Crop Editor (8 Handles, Grid Rule of Thirds, Drag/Pan, Snap to Center)
/// 4. Fit & Fill Mode Toggle
class CropTransformStudioBottomSheet extends StatefulWidget {
  final ClipTransformModel initialTransform;
  final double videoNaturalAspectRatio;
  final ValueChanged<ClipTransformModel> onApply;

  const CropTransformStudioBottomSheet({
    super.key,
    required this.initialTransform,
    required this.videoNaturalAspectRatio,
    required this.onApply,
  });

  static Future<ClipTransformModel?> show(
    BuildContext context, {
    required ClipTransformModel initialTransform,
    required double videoNaturalAspectRatio,
    required ValueChanged<ClipTransformModel> onApply,
  }) {
    return showModalBottomSheet<ClipTransformModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CropTransformStudioBottomSheet(
        initialTransform: initialTransform,
        videoNaturalAspectRatio: videoNaturalAspectRatio,
        onApply: onApply,
      ),
    );
  }

  @override
  State<CropTransformStudioBottomSheet> createState() => _CropTransformStudioBottomSheetState();
}

class _CropTransformStudioBottomSheetState extends State<CropTransformStudioBottomSheet>
    with SingleTickerProviderStateMixin {
  late ClipTransformModel _transform;
  late TextEditingController _rotationTextController;
  late TabController _tabController;

  static const List<Map<String, dynamic>> _ratioOptions = [
    {'ratio': CanvasRatioMode.original, 'label': 'Asli', 'sub': 'Free / Original'},
    {'ratio': CanvasRatioMode.ratio9x16, 'label': '9:16', 'sub': 'TikTok / Reels'},
    {'ratio': CanvasRatioMode.ratio16x9, 'label': '16:9', 'sub': 'YouTube / TV'},
    {'ratio': CanvasRatioMode.ratio1x1, 'label': '1:1', 'sub': 'Square Feed'},
    {'ratio': CanvasRatioMode.ratio4x5, 'label': '4:5', 'sub': 'IG Portrait'},
    {'ratio': CanvasRatioMode.ratio3x4, 'label': '3:4', 'sub': 'Portrait'},
    {'ratio': CanvasRatioMode.ratio4x3, 'label': '4:3', 'sub': 'Retro TV'},
    {'ratio': CanvasRatioMode.ratio185x1, 'label': '1.85:1', 'sub': 'Cinema Flat'},
    {'ratio': CanvasRatioMode.ratio235x1, 'label': '2.35:1', 'sub': 'Cinemascope'},
    {'ratio': CanvasRatioMode.ratio239x1, 'label': '2.39:1', 'sub': 'Panavision'},
    {'ratio': CanvasRatioMode.ratio21x9, 'label': '21:9', 'sub': 'Ultra Wide'},
  ];

  @override
  void initState() {
    super.initState();
    _transform = widget.initialTransform;
    _rotationTextController = TextEditingController(
      text: _transform.rotationDegrees.toStringAsFixed(1),
    );
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _rotationTextController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _updateRotation(double deg) {
    // Snap ke 0°, 90°, -90°, 180°, -180° jika berada dalam radius 3 derajat
    var snappedDeg = deg;
    for (final snapPoint in [-180.0, -90.0, 0.0, 90.0, 180.0]) {
      if ((deg - snapPoint).abs() <= 3.0) {
        snappedDeg = snapPoint;
        break;
      }
    }

    setState(() {
      _transform = _transform.copyWith(rotationDegrees: snappedDeg);
      _rotationTextController.text = snappedDeg.toStringAsFixed(1);
    });
    widget.onApply(_transform);
  }

  void _rotateStep(double step) {
    var newRot = _transform.rotationDegrees + step;
    if (newRot > 180.0) newRot -= 360.0;
    if (newRot < -180.0) newRot += 360.0;
    _updateRotation(newRot);
  }

  void _resetAll() {
    setState(() {
      _transform = const ClipTransformModel();
      _rotationTextController.text = '0.0';
    });
    widget.onApply(_transform);
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
          // Drag handle bar
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
                const Icon(Icons.crop_rotate_rounded, color: Color(0xFF00E5FF), size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Pangkas & Transformasi',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _resetAll,
                  child: const Text('Reset', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context, _transform),
                ),
              ],
            ),
          ),

          // Tab Bar: 1. Pangkas (Crop & Rasio) | 2. Rotasi & Cermin
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
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              tabs: const [
                Tab(text: 'Area Pangkas & Rasio'),
                Tab(text: 'Rotasi & Cermin'),
              ],
            ),
          ),

          // Tab View Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCropAndRatioTab(),
                _buildRotationAndMirrorTab(),
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
                    onPressed: () {
                      setState(() {
                        _transform = widget.initialTransform;
                      });
                      widget.onApply(_transform);
                      Navigator.pop(context);
                    },
                    child: const Text('Batal'),
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
                      widget.onApply(_transform);
                      Navigator.pop(context, _transform);
                    },
                    child: const Text('Terapkan Pangkas', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropAndRatioTab() {
    return Column(
      children: [
        // Area Interactive Crop Preview
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF161622),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveCropCanvas(
                initialTransform: _transform,
                videoNaturalAspectRatio: widget.videoNaturalAspectRatio > 0
                    ? widget.videoNaturalAspectRatio
                    : 16 / 9,
                onTransformChanged: (updated) {
                  setState(() => _transform = updated);
                  widget.onApply(_transform);
                },
              ),
            ),
          ),
        ),

        // Rasio Aspek Horizontal Picker
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
          child: Row(
            children: [
              const Text('Rasio Kanvas:', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              const Spacer(),
              // Fit vs Fill Toggle
              GestureDetector(
                onTap: () {
                  setState(() {
                    _transform = _transform.copyWith(
                      fitMode: _transform.fitMode == FitMode.fit ? FitMode.fill : FitMode.fit,
                    );
                  });
                  widget.onApply(_transform);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _transform.fitMode == FitMode.fill ? const Color(0xFF00E5FF) : const Color(0xFF222232),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _transform.fitMode == FitMode.fill ? const Color(0xFF00E5FF) : Colors.white12),
                  ),
                  child: Text(
                    _transform.fitMode == FitMode.fill ? 'Mode Fill' : 'Mode Fit',
                    style: TextStyle(
                      color: _transform.fitMode == FitMode.fill ? Colors.black : Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _ratioOptions.length,
            itemBuilder: (context, index) {
              final opt = _ratioOptions[index];
              final isSel = _transform.canvasRatio == opt['ratio'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _transform = _transform.copyWith(canvasRatio: opt['ratio'] as CanvasRatioMode);
                  });
                  widget.onApply(_transform);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFF00E5FF) : const Color(0xFF1E1E2B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSel ? const Color(0xFF00E5FF) : Colors.white12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        opt['label'] as String,
                        style: TextStyle(
                          color: isSel ? Colors.black : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        opt['sub'] as String,
                        style: TextStyle(
                          color: isSel ? Colors.black87 : Colors.white38,
                          fontSize: 8,
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

  Widget _buildRotationAndMirrorTab() {
    final rotDeg = _transform.rotationDegrees;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nilai Derajat Rotasi & Input Manual
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.rotate_right_rounded, color: Color(0xFF00E5FF), size: 24),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                height: 36,
                child: TextField(
                  controller: _rotationTextController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    suffixText: '°',
                    suffixStyle: const TextStyle(color: Colors.white70, fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFF222232),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (val) {
                    final parsed = double.tryParse(val);
                    if (parsed != null) {
                      _updateRotation(parsed.clamp(-180.0, 180.0));
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.restart_alt_rounded, color: Colors.white54, size: 20),
                tooltip: 'Reset Rotasi 0°',
                onPressed: () => _updateRotation(0.0),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Slider Rotasi Halus (-180° s/d +180°)
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: const Color(0xFF00E5FF),
              inactiveTrackColor: Colors.white12,
              thumbColor: const Color(0xFF00E5FF),
              overlayColor: const Color(0xFF00E5FF).withValues(alpha: 0.2),
            ),
            child: Slider(
              value: rotDeg.clamp(-180.0, 180.0),
              min: -180.0,
              max: 180.0,
              divisions: 360,
              onChanged: _updateRotation,
            ),
          ),

          // Label Penanda Snap Indikator (-180°, -90°, 0°, 90°, 180°)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('-180°', style: TextStyle(color: Colors.white38, fontSize: 9)),
                Text('-90°', style: TextStyle(color: Colors.white38, fontSize: 9)),
                Text('0°', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 9, fontWeight: FontWeight.bold)),
                Text('90°', style: TextStyle(color: Colors.white38, fontSize: 9)),
                Text('180°', style: TextStyle(color: Colors.white38, fontSize: 9)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tombol Cepat: Rotasi 90° Kiri, 90° Kanan, Cermin H, Cermin V
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.rotate_left_rounded,
                  label: '-90° Kiri',
                  onTap: () => _rotateStep(-90.0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.rotate_right_rounded,
                  label: '+90° Kanan',
                  onTap: () => _rotateStep(90.0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.flip_rounded,
                  label: 'Cermin H',
                  isActive: _transform.flipHorizontal,
                  onTap: () {
                    setState(() {
                      _transform = _transform.copyWith(flipHorizontal: !_transform.flipHorizontal);
                    });
                    widget.onApply(_transform);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.flip_camera_android_rounded,
                  label: 'Cermin V',
                  isActive: _transform.flipVertical,
                  onTap: () {
                    setState(() {
                      _transform = _transform.copyWith(flipVertical: !_transform.flipVertical);
                    });
                    widget.onApply(_transform);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00E5FF).withValues(alpha: 0.15) : const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? const Color(0xFF00E5FF) : Colors.white12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isActive ? const Color(0xFF00E5FF) : Colors.white70, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF00E5FF) : Colors.white70,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

