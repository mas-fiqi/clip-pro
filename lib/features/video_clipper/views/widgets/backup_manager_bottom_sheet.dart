import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../core/models/project_model.dart';
import '../../../../core/services/project_storage_service.dart';

/// Sheet manajemen backup & riwayat pencadangan proyek lokal
class BackupManagerBottomSheet extends StatefulWidget {
  final ProjectModel project;

  const BackupManagerBottomSheet({super.key, required this.project});

  static Future<ProjectModel?> show(BuildContext context, {required ProjectModel project}) {
    return showModalBottomSheet<ProjectModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => BackupManagerBottomSheet(project: project),
    );
  }

  @override
  State<BackupManagerBottomSheet> createState() => _BackupManagerBottomSheetState();
}

class _BackupManagerBottomSheetState extends State<BackupManagerBottomSheet> {
  final ProjectStorageService _storage = ProjectStorageService();
  List<File> _backups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    final list = await _storage.getBackupsForProject(widget.project.id);
    if (mounted) {
      setState(() {
        _backups = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleCreateBackup() async {
    setState(() => _isLoading = true);
    final file = await _storage.createProjectBackup(widget.project);
    if (file != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadangan proyek berhasil dibuat!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      await _loadBackups();
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRestore(File backupFile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF262626),
        title: const Text('Pulihkan Cadangan?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Timeline saat ini akan digantikan dengan data dari file cadangan terpilih.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Pulihkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final restored = await _storage.restoreProjectBackup(backupFile);
      if (restored != null && mounted) {
        Navigator.of(context).pop(restored);
      }
    }
  }

  Future<void> _handleDeleteBackup(File file) async {
    if (await file.exists()) {
      await file.delete();
      await _loadBackups();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cadangan Proyek (Backup)',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Simpan versi proyek secara berkala',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: _handleCreateBackup,
                icon: const Icon(Icons.add_to_photos_rounded, size: 16, color: Colors.white),
                label: const Text('Cadangkan', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_backups.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.inventory_2_outlined, color: Colors.white24, size: 36),
                  SizedBox(height: 8),
                  Text('Belum ada cadangan untuk proyek ini', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _backups.length,
                separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                itemBuilder: (context, index) {
                  final file = _backups[index];
                  final stat = file.statSync();
                  final sizeKb = (stat.size / 1024).toStringAsFixed(1);
                  final modTime = stat.modified;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.archive_outlined, color: Color(0xFFA78BFA)),
                    title: Text(
                      'Cadangan #${_backups.length - index}',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${modTime.day}/${modTime.month} ${modTime.hour}:${modTime.minute.toString().padLeft(2, '0')} • $sizeKb KB',
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => _handleRestore(file),
                          child: const Text('Pulihkan', style: TextStyle(color: Color(0xFF6366F1), fontSize: 12)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.white38, size: 18),
                          onPressed: () => _handleDeleteBackup(file),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
