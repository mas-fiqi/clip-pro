import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../core/models/project_model.dart';
import '../../../../core/services/project_storage_service.dart';
import '../../../../core/services/video_picker_service.dart';

/// Dialog untuk meninjau media proyek yang hilang dan opsi relink file lokal
class MissingMediaDialog extends StatefulWidget {
  final ProjectModel project;
  final List<MissingMediaInfo> missingList;

  const MissingMediaDialog({
    super.key,
    required this.project,
    required this.missingList,
  });

  static Future<ProjectModel?> show(
    BuildContext context, {
    required ProjectModel project,
    required List<MissingMediaInfo> missingList,
  }) {
    return showDialog<ProjectModel>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MissingMediaDialog(
        project: project,
        missingList: missingList,
      ),
    );
  }

  @override
  State<MissingMediaDialog> createState() => _MissingMediaDialogState();
}

class _MissingMediaDialogState extends State<MissingMediaDialog> {
  late ProjectModel _currentProject;
  late List<MissingMediaInfo> _currentMissingList;
  final VideoPickerService _picker = VideoPickerService();

  @override
  void initState() {
    super.initState();
    _currentProject = widget.project;
    _currentMissingList = List.from(widget.missingList);
  }

  Future<void> _handleRelink(MissingMediaInfo missing) async {
    final pickedFile = await _picker.pickVideoFromGallery();
    if (pickedFile == null) return;

    if (!await File(pickedFile.path).exists()) return;

    setState(() {
      _currentProject = ProjectStorageService().relinkMedia(
        project: _currentProject,
        oldPath: missing.path,
        newPath: pickedFile.path,
      );
      _currentMissingList.removeWhere((item) => item.path == missing.path);
    });

    // Simpan perubahan relink
    await ProjectStorageService().saveProjectAtomic(_currentProject);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil menghubungkan: ${missing.name}'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Media Sumber Tidak Ditemukan',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Beberapa file media mungkin telah dipindahkan atau dihapus dari penyimpanan perangkat:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _currentMissingList.length,
                separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                itemBuilder: (context, index) {
                  final item = _currentMissingList[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      item.isVideo ? Icons.movie_outlined : Icons.audiotrack_outlined,
                      color: item.isVideo ? const Color(0xFF6366F1) : const Color(0xFF06B6D4),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      item.path,
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF8B5CF6),
                        side: const BorderSide(color: Color(0xFF8B5CF6)),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _handleRelink(item),
                      child: const Text('Relink', style: TextStyle(fontSize: 12)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null), // Batalkan buka proyek
          child: const Text('Batal', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Navigator.of(context).pop(_currentProject), // Lanjut buka proyek
          child: const Text('Lanjutkan Buka', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
