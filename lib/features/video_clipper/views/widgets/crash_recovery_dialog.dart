import 'package:flutter/material.dart';
import '../../../../core/models/project_model.dart';
import '../../../../core/utils/time_formatter.dart';

/// Dialog konfirmasi pemulihan sesi proyek (Crash / Unexpected Close Recovery)
class CrashRecoveryDialog extends StatelessWidget {
  final ProjectModel project;
  final DateTime crashTimestamp;

  const CrashRecoveryDialog({
    super.key,
    required this.project,
    required this.crashTimestamp,
  });

  static Future<bool?> show(
    BuildContext context, {
    required ProjectModel project,
    required DateTime crashTimestamp,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CrashRecoveryDialog(
        project: project,
        crashTimestamp: crashTimestamp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = TimeFormatter.formatDisplayDuration(
      DateTime.now().difference(crashTimestamp).inSeconds.toDouble(),
    );

    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.history_toggle_off_rounded, color: Color(0xFFA78BFA), size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Pemulihan Sesi Kerja',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QuickClip Pro mendeteksi sesi editing sebelumnya terhenti atau belum tersimpan secara normal.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Klip: ${project.timeline.clips.length} • Audio: ${project.timeline.audioClips.length} • Teks: ${project.timeline.overlays.length}',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                Text(
                  'Terakhir disimpan: sekitar $timeStr yang lalu (${crashTimestamp.hour.toString().padLeft(2, '0')}:${crashTimestamp.minute.toString().padLeft(2, '0')})',
                  style: const TextStyle(color: Color(0xFFA78BFA), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false), // Discard
          child: const Text('Buang Sesi', style: TextStyle(color: Colors.white38)),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Navigator.of(context).pop(true), // Restore
          icon: const Icon(Icons.restore_rounded, size: 18, color: Colors.white),
          label: const Text('Pulihkan Proyek', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
