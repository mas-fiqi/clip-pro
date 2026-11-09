import 'package:flutter/material.dart';

enum DuplicateActionType {
  afterCurrent,    // Duplikat Tepat Setelah Klip Asli (Same Track)
  toOverlay,       // Duplikat Menjadi Lapisan Overlay PiP (Overlay Track)
  multiple,        // Duplikat Berkali-kali (2x, 3x, 5x)
  copyAttributes,  // Salin Semua Atribut (Filter, Efek, Speed, Transform)
  pasteAttributes, // Terapkan Atribut yang Disalin ke Klip Ini
}

/// Bottom Sheet Pilihan Duplikasi & Atribut ala CapCut Pro
class DuplicateOptionsBottomSheet extends StatelessWidget {
  final bool hasCopiedAttributes;
  final ValueChanged<DuplicateActionType> onSelectAction;

  const DuplicateOptionsBottomSheet({
    super.key,
    required this.hasCopiedAttributes,
    required this.onSelectAction,
  });

  static Future<DuplicateActionType?> show(
    BuildContext context, {
    required bool hasCopiedAttributes,
  }) {
    return showModalBottomSheet<DuplicateActionType>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DuplicateOptionsBottomSheet(
        hasCopiedAttributes: hasCopiedAttributes,
        onSelectAction: (action) => Navigator.pop(ctx, action),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF14141E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black87, blurRadius: 20, offset: Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Header Bar
              Row(
                children: [
                  const Icon(Icons.copy_all_rounded, color: Color(0xFF00E5FF), size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'Pilihan Duplikasi & Atribut',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 1. Duplikat Setelah Klip Asli (Default CapCut)
              _buildTile(
                icon: Icons.control_point_duplicate_rounded,
                title: 'Duplikat Setelah Klip (Track yang Sama)',
                subtitle: 'Menaruh salinan klip tepat di sebelah kanannya pada timeline utama',
                highlight: true,
                onTap: () => onSelectAction(DuplicateActionType.afterCurrent),
              ),

              // 2. Duplikat ke Overlay Track (PiP)
              _buildTile(
                icon: Icons.layers_rounded,
                title: 'Duplikat ke Overlay (Picture-in-Picture)',
                subtitle: 'Menaruh klip sejajar sebagai lapisan overlay di atas video utama',
                onTap: () => onSelectAction(DuplicateActionType.toOverlay),
              ),

              // 3. Duplikat Jamak (Multiple)
              _buildTile(
                icon: Icons.auto_awesome_motion_rounded,
                title: 'Duplikat Jamak (3x Salinan)',
                subtitle: 'Menggandakan klip 3 kali berurutan sekaligus',
                onTap: () => onSelectAction(DuplicateActionType.multiple),
              ),

              const Divider(color: Colors.white10, height: 16),

              // 4. Salin Atribut
              _buildTile(
                icon: Icons.content_copy_rounded,
                title: 'Salin Atribut Klip',
                subtitle: 'Menyalin efek, filter, kecepatan, rotasi, dan retouch',
                onTap: () => onSelectAction(DuplicateActionType.copyAttributes),
              ),

              // 5. Tempel Atribut
              _buildTile(
                icon: Icons.content_paste_go_rounded,
                title: 'Tempel Atribut Klip',
                subtitle: hasCopiedAttributes
                    ? 'Terapkan filter, kecepatan, dan efek yang telah disalin'
                    : 'Belum ada atribut yang disalin',
                enabled: hasCopiedAttributes,
                onTap: () => onSelectAction(DuplicateActionType.pasteAttributes),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool highlight = false,
    bool enabled = true,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: highlight ? const Color(0xFF00E5FF).withValues(alpha: 0.12) : const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: highlight ? const Color(0xFF00E5FF).withValues(alpha: 0.5) : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: enabled
                    ? (highlight ? const Color(0xFF00E5FF) : Colors.white12)
                    : Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: enabled ? (highlight ? Colors.black : Colors.white) : Colors.white24,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: enabled ? Colors.white : Colors.white38,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: enabled ? Colors.white60 : Colors.white24,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: enabled ? Colors.white38 : Colors.white10),
          ],
        ),
      ),
    );
  }
}

