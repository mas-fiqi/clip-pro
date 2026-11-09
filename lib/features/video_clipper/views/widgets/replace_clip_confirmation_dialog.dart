import 'package:flutter/material.dart';

enum ReplaceFitChoice {
  keepDuration, // Pertahankan durasi klip asli (trim/loop)
  fitNewDuration, // Sesuaikan durasi klip dengan durasi video pengganti baru
}

/// Dialog Konfirmasi dan Pilihan saat Mengganti Media (Replace Video)
class ReplaceClipConfirmationDialog extends StatelessWidget {
  final double oldDuration;
  final double newDuration;
  final bool hasAttributeChanges;
  final ValueChanged<ReplaceFitChoice> onConfirm;

  const ReplaceClipConfirmationDialog({
    super.key,
    required this.oldDuration,
    required this.newDuration,
    required this.hasAttributeChanges,
    required this.onConfirm,
  });

  static Future<ReplaceFitChoice?> show(
    BuildContext context, {
    required double oldDuration,
    required double newDuration,
    required bool hasAttributeChanges,
  }) {
    return showDialog<ReplaceFitChoice>(
      context: context,
      builder: (ctx) => ReplaceClipConfirmationDialog(
        oldDuration: oldDuration,
        newDuration: newDuration,
        hasAttributeChanges: hasAttributeChanges,
        onConfirm: (choice) => Navigator.pop(ctx, choice),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDurationDifferent = (oldDuration - newDuration).abs() > 0.5;

    return AlertDialog(
      backgroundColor: const Color(0xFF14141E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white12),
      ),
      title: const Row(
        children: [
          Icon(Icons.published_with_changes_rounded, color: Color(0xFF00E5FF), size: 22),
          SizedBox(width: 8),
          Text(
            'Ganti Media Klip',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Media baru siap diterapkan. Semua filter, crop, rotasi, dan efek yang ada akan dipertahankan.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Durasi Sebelumnya:', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    Text('${oldDuration.toStringAsFixed(1)}s', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Durasi Media Baru:', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    Text('${newDuration.toStringAsFixed(1)}s', style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  ],
                ),
              ],
            ),
          ),
          if (isDurationDifferent) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFFFBBF24), size: 14),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Durasi media baru berbeda dengan klip sebelumnya. Tentukan pilihan penyesuaian durasi di bawah.',
                    style: TextStyle(color: Color(0xFFFBBF24), fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(color: Colors.white60)),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white24),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          onPressed: () => onConfirm(ReplaceFitChoice.keepDuration),
          child: const Text('Tetap Durasi Lama', style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E5FF),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onPressed: () => onConfirm(ReplaceFitChoice.fitNewDuration),
          child: const Text('Ikuti Durasi Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }
}

