import 'package:flutter/material.dart';
import '../../../../core/models/overlay_model.dart';
import '../../../../core/theme/app_design_tokens.dart';

class OverlayEditorDialog extends StatefulWidget {
  final OverlayModel? initialOverlay;
  final double currentGlobalTime;

  const OverlayEditorDialog({
    super.key,
    this.initialOverlay,
    required this.currentGlobalTime,
  });

  @override
  State<OverlayEditorDialog> createState() => _OverlayEditorDialogState();
}

class _OverlayEditorDialogState extends State<OverlayEditorDialog> {
  late TextEditingController _textController;
  late double _fontSize;
  late String _textColorHex;
  late TextPresetStyle _presetStyle;
  late double _durationSecs;

  final List<String> _quickEmojis = ['🔥', '✨', '❤️', '👏', '🎬', '🚀', '💯', '⭐', '⚡', '🎉'];

  final List<Map<String, dynamic>> _colors = [
    {'hex': 'FFFFFF', 'color': Colors.white, 'name': 'Putih'},
    {'hex': '00E5FF', 'color': const Color(0xFF00E5FF), 'name': 'Cyan'},
    {'hex': 'FFEE58', 'color': const Color(0xFFFFEE58), 'name': 'Kuning'},
    {'hex': 'EF4444', 'color': const Color(0xFFEF4444), 'name': 'Merah'},
    {'hex': '8B5CF6', 'color': const Color(0xFF8B5CF6), 'name': 'Ungu'},
    {'hex': '10B981', 'color': const Color(0xFF10B981), 'name': 'Hijau'},
    {'hex': 'F59E0B', 'color': const Color(0xFFF59E0B), 'name': 'Oranye'},
    {'hex': '111827', 'color': const Color(0xFF111827), 'name': 'Hitam'},
  ];

  @override
  void initState() {
    super.initState();
    final init = widget.initialOverlay;
    _textController = TextEditingController(text: init?.content ?? '');
    _fontSize = init?.fontSize ?? 26.0;
    _textColorHex = init?.textColorHex ?? 'FFFFFF';
    _presetStyle = init?.presetStyle ?? TextPresetStyle.plain;
    _durationSecs = init != null ? (init.endTime - init.startTime) : 3.0;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: AppDesignTokens.surfacePrimary,
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusL),
          border: Border.all(color: AppDesignTokens.borderSubtle, width: 1.2),
          boxShadow: AppDesignTokens.softShadow,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Dialog
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          gradient: AppDesignTokens.accentPurpleGradient,
                          borderRadius: BorderRadius.circular(AppDesignTokens.radiusS),
                        ),
                        child: const Icon(Icons.title_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.initialOverlay == null ? 'Tambah Teks & Subtitle' : 'Edit Hamparan Teks',
                        style: const TextStyle(
                          color: AppDesignTokens.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppDesignTokens.textSecondary, size: 20),
                    splashRadius: 18,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Preview Canvas Mini Teks
              Container(
                height: 80,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppDesignTokens.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppDesignTokens.radiusM),
                  border: Border.all(color: AppDesignTokens.borderGlass, width: 1),
                ),
                child: Center(
                  child: Text(
                    _textController.text.isEmpty ? 'Ketik teks di bawah...' : _textController.text,
                    style: TextStyle(
                      color: Color(int.parse('0xFF$_textColorHex')),
                      fontSize: _fontSize.clamp(14.0, 32.0),
                      fontWeight: _presetStyle == TextPresetStyle.bold ? FontWeight.bold : FontWeight.normal,
                      shadows: _presetStyle == TextPresetStyle.shadow
                          ? [
                              const Shadow(
                                color: Colors.black,
                                blurRadius: 8,
                                offset: Offset(2, 2),
                              ),
                            ]
                          : null,
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Input Teks Modern
              Container(
                decoration: BoxDecoration(
                  color: AppDesignTokens.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppDesignTokens.radiusM),
                  border: Border.all(color: AppDesignTokens.cyanAccent.withValues(alpha: 0.3), width: 1),
                ),
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Tulis kalimat, caption, atau teks keterangan...',
                    hintStyle: TextStyle(color: AppDesignTokens.textMuted, fontSize: 13),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 12),

              // Emoji Bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _quickEmojis.map((emoji) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _textController.text += emoji;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                        child: Text(emoji, style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Preset Gaya Huruf (Plain, Bold, Shadow)
              Row(
                children: [
                  const Text('Gaya:', style: TextStyle(color: AppDesignTokens.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _styleChip(label: 'Plain', style: TextPresetStyle.plain),
                        _styleChip(label: 'Bold', style: TextPresetStyle.bold),
                        _styleChip(label: 'Shadow', style: TextPresetStyle.shadow),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Slider Ukuran Huruf & Durasi
              Row(
                children: [
                  const Text('Ukuran:', style: TextStyle(color: AppDesignTokens.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppDesignTokens.cyanAccent,
                        inactiveTrackColor: Colors.white12,
                        thumbColor: Colors.white,
                        trackHeight: 3,
                      ),
                      child: Slider(
                        value: _fontSize.clamp(14.0, 48.0),
                        min: 14.0,
                        max: 48.0,
                        onChanged: (v) => setState(() => _fontSize = v),
                      ),
                    ),
                  ),
                  Text(
                    '${_fontSize.toInt()}pt',
                    style: const TextStyle(color: AppDesignTokens.cyanAccent, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Palet Warna Teks
              Row(
                children: [
                  const Text('Warna:', style: TextStyle(color: AppDesignTokens.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _colors.map((c) {
                          final hex = c['hex'] as String;
                          final color = c['color'] as Color;
                          final isSel = _textColorHex.toUpperCase() == hex.toUpperCase();

                          return GestureDetector(
                            onTap: () => setState(() => _textColorHex = hex),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSel ? AppDesignTokens.cyanAccent : Colors.white24,
                                  width: isSel ? 2.5 : 1,
                                ),
                                boxShadow: isSel ? AppDesignTokens.glowShadow(color) : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Action Buttons: Batal & Terapkan
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal', style: TextStyle(color: AppDesignTokens.textMuted, fontSize: 13)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppDesignTokens.cyanAccent,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDesignTokens.radiusS)),
                    ),
                    onPressed: () {
                      final text = _textController.text.trim();
                      if (text.isEmpty) return;

                      final start = widget.initialOverlay?.startTime ?? widget.currentGlobalTime;
                      final end = start + _durationSecs;

                      final result = (widget.initialOverlay ??
                              OverlayModel(
                                id: 'overlay_${DateTime.now().millisecondsSinceEpoch}',
                                type: OverlayType.text,
                                content: text,
                                startTime: start,
                                endTime: end,
                              ))
                          .copyWith(
                        content: text,
                        fontSize: _fontSize,
                        textColorHex: _textColorHex,
                        presetStyle: _presetStyle,
                      );

                      Navigator.pop(context, result);
                    },
                    child: const Text('Terapkan Teks', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _styleChip({required String label, required TextPresetStyle style}) {
    final isSel = _presetStyle == style;
    return InkWell(
      onTap: () => setState(() => _presetStyle = style),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? AppDesignTokens.cyanAccent : AppDesignTokens.surfaceSecondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSel ? AppDesignTokens.cyanAccent : AppDesignTokens.borderGlass,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSel ? Colors.black : AppDesignTokens.textSecondary,
            fontSize: 11.5,
            fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
