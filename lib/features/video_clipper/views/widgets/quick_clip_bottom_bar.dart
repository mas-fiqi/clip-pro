import 'package:flutter/material.dart';

class QuickClipBottomBar extends StatelessWidget {
  final VoidCallback onEditTap;
  final VoidCallback onAudioTap;
  final VoidCallback onTextTap;
  final VoidCallback onEffectTap;
  final VoidCallback onOverlayTap;
  final VoidCallback onFilterTap;
  final VoidCallback onSpeedTap;
  final VoidCallback onVolumeTap;
  final VoidCallback onDuplicateTap;
  final VoidCallback onSplitTap;
  final VoidCallback onDeleteTap;
  final VoidCallback onTransformTap;
  final bool hasSelectedOverlay;
  final VoidCallback? onDeleteOverlayTap;
  final bool isEditMode;
  final VoidCallback? onBackTap;
  final VoidCallback? onDeleteLeftTap;
  final VoidCallback? onDeleteRightTap;
  final VoidCallback? onRotateTap;
  final VoidCallback? onFlipHorizontalTap;
  final VoidCallback? onFlipVerticalTap;
  final VoidCallback? onFreezeTap;
  final VoidCallback? onReverseTap;

  final VoidCallback? onRetouchTap;
  final VoidCallback? onAudioStudioTap;
  final VoidCallback? onAnimationTap;
  final VoidCallback? onRhythmTap;
  final VoidCallback? onQualityTap;

  const QuickClipBottomBar({
    super.key,
    required this.onEditTap,
    required this.onAudioTap,
    required this.onTextTap,
    required this.onEffectTap,
    required this.onOverlayTap,
    required this.onFilterTap,
    required this.onSpeedTap,
    required this.onVolumeTap,
    required this.onDuplicateTap,
    required this.onSplitTap,
    required this.onDeleteTap,
    required this.onTransformTap,
    this.hasSelectedOverlay = false,
    this.onDeleteOverlayTap,
    this.isEditMode = false,
    this.onBackTap,
    this.onDeleteLeftTap,
    this.onDeleteRightTap,
    this.onRotateTap,
    this.onFlipHorizontalTap,
    this.onFlipVerticalTap,
    this.onFreezeTap,
    this.onReverseTap,
    this.onRetouchTap,
    this.onAudioStudioTap,
    this.onAnimationTap,
    this.onRhythmTap,
    this.onQualityTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: const Color(0xFF10121D),
        border: const Border(
          top: BorderSide(color: Color(0x26FFFFFF), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: isEditMode ? _buildEditSubtools(context) : _buildMainCapCutTools(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMainCapCutTools() {
    return [
      _buildToolItem(
        icon: Icons.content_cut_rounded,
        label: 'Edit',
        onTap: onEditTap,
      ),
      _buildToolItem(
        icon: Icons.music_note_rounded,
        label: 'Audio',
        onTap: onAudioTap,
      ),
      _buildToolItem(
        icon: Icons.title_rounded,
        label: 'Teks',
        onTap: onTextTap,
      ),
      _buildToolItem(
        icon: Icons.star_border_rounded,
        label: 'Efek',
        onTap: onEffectTap,
      ),
      _buildToolItem(
        icon: Icons.layers_outlined,
        label: 'Overlay',
        onTap: onOverlayTap,
      ),
      _buildToolItem(
        icon: Icons.subtitles_outlined,
        label: 'Keterangan',
        onTap: onTextTap,
      ),
      _buildToolItem(
        icon: Icons.filter_vintage_outlined,
        label: 'Filter',
        onTap: onFilterTap,
      ),
      _buildToolItem(
        icon: Icons.aspect_ratio_rounded,
        label: 'Rasio',
        onTap: onTransformTap,
      ),
    ];
  }

  List<Widget> _buildEditSubtools(BuildContext context) {
    return [
      if (onBackTap != null)
        _buildToolItem(
          icon: Icons.chevron_left_rounded,
          label: 'Kembali',
          color: Colors.white70,
          onTap: onBackTap!,
        ),
      _buildToolItem(
        icon: Icons.content_cut_rounded,
        label: 'Bagi',
        onTap: onSplitTap,
      ),
      if (onDeleteLeftTap != null)
        _buildToolItem(
          icon: Icons.keyboard_double_arrow_left_rounded,
          label: 'Hapus Kiri',
          color: const Color(0xFFF87171),
          onTap: onDeleteLeftTap!,
        ),
      if (onDeleteRightTap != null)
        _buildToolItem(
          icon: Icons.keyboard_double_arrow_right_rounded,
          label: 'Hapus Kanan',
          color: const Color(0xFFF87171),
          onTap: onDeleteRightTap!,
        ),
      _buildToolItem(
        icon: Icons.auto_awesome_motion_rounded,
        label: 'Animasi',
        color: const Color(0xFF00E5FF),
        onTap: onAnimationTap ?? () {},
      ),
      _buildToolItem(
        icon: Icons.speed_rounded,
        label: 'Kecepatan',
        onTap: onSpeedTap,
      ),
      _buildToolItem(
        icon: Icons.volume_up_rounded,
        label: 'Volume',
        onTap: onVolumeTap,
      ),
      _buildToolItem(
        icon: Icons.copy_rounded,
        label: 'Duplikasi',
        onTap: onDuplicateTap,
      ),
      if (onRotateTap != null)
        _buildToolItem(
          icon: Icons.rotate_right_rounded,
          label: 'Putar 90°',
          onTap: onRotateTap!,
        ),
      if (onFlipHorizontalTap != null)
        _buildToolItem(
          icon: Icons.flip_rounded,
          label: 'Cermin H',
          onTap: onFlipHorizontalTap!,
        ),
      if (onFlipVerticalTap != null)
        _buildToolItem(
          icon: Icons.swap_vert_rounded,
          label: 'Cermin V',
          onTap: onFlipVerticalTap!,
        ),
      if (onFreezeTap != null)
        _buildToolItem(
          icon: Icons.pause_circle_outline_rounded,
          label: 'Bekukan',
          onTap: onFreezeTap!,
        ),
      if (onReverseTap != null)
        _buildToolItem(
          icon: Icons.fast_rewind_rounded,
          label: 'Mundur',
          onTap: onReverseTap!,
        ),
      if (hasSelectedOverlay && onDeleteOverlayTap != null)
        _buildToolItem(
          icon: Icons.delete_sweep_rounded,
          label: 'Hapus Teks',
          color: const Color(0xFFFB923C),
          onTap: onDeleteOverlayTap!,
        ),
      _buildToolItem(
        icon: Icons.crop_rotate_rounded,
        label: 'Transformasi',
        onTap: onTransformTap,
      ),
      _buildToolItem(
        icon: Icons.filter_vintage_outlined,
        label: 'Filter & Warna',
        onTap: onFilterTap,
      ),
      _buildToolItem(
        icon: Icons.auto_fix_high_rounded,
        label: 'Efek Video',
        onTap: onEffectTap,
      ),
      _buildToolItem(
        icon: Icons.layers_outlined,
        label: 'Overlay',
        onTap: onOverlayTap,
      ),
      _buildToolItem(
        icon: Icons.graphic_eq_rounded,
        label: 'Irama Beat',
        color: const Color(0xFF00E5FF),
        onTap: onRhythmTap ?? () {},
      ),
      _buildToolItem(
        icon: Icons.hd_outlined,
        label: 'Kualitas',
        color: const Color(0xFF10B981),
        onTap: onQualityTap ?? () {},
      ),
      _buildToolItem(
        icon: Icons.face_retouching_natural_rounded,
        label: 'Retouch / Rias',
        onTap: onRetouchTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur Retouch & Beauty Enhancement')),
          );
        },
      ),
      _buildToolItem(
        icon: Icons.graphic_eq_rounded,
        label: 'Efek Suara FX',
        onTap: onAudioStudioTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Audio Studio & Voice Enhancement')),
          );
        },
      ),
      _buildToolItem(
        icon: Icons.person_remove_rounded,
        label: 'Hapus Latar',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hapus Latar Belakang (Smart Cutout / Chroma Key)')),
          );
        },
      ),
      _buildToolItem(
        icon: Icons.vibration_rounded,
        label: 'Stabilkan',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stabilisasi Video Anti-Shake Engine')),
          );
        },
      ),
      _buildToolItem(
        icon: Icons.music_off_rounded,
        label: 'Pisah Suara',
        onTap: onAudioTap,
      ),
      _buildToolItem(
        icon: Icons.delete_outline_rounded,
        label: 'Hapus',
        color: const Color(0xFFF87171),
        onTap: onDeleteTap,
      ),
    ];
  }

  Widget _buildToolItem({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: color == Colors.white ? const Color(0x14FFFFFF) : color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color == Colors.white ? const Color(0xFFB0B7C3) : color,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
