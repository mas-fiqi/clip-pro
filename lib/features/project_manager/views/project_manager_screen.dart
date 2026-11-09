import 'package:flutter/material.dart';

import '../../../core/models/project_model.dart';
import '../../../core/services/project_storage_service.dart';
import '../../../core/utils/time_formatter.dart';
import '../../video_clipper/views/video_clipper_screen.dart';
import '../../video_clipper/views/widgets/missing_media_dialog.dart';

enum ProjectSortOption {
  recent,
  name,
  duration,
}

/// Layar Manajer Proyek QuickClip Pro: Menampilkan daftar draft, pencarian, pengurutan, duplikasi, rename, delete
class ProjectManagerScreen extends StatefulWidget {
  const ProjectManagerScreen({super.key});

  @override
  State<ProjectManagerScreen> createState() => _ProjectManagerScreenState();
}

class _ProjectManagerScreenState extends State<ProjectManagerScreen> {
  final ProjectStorageService _storage = ProjectStorageService();
  List<ProjectModel> _allProjects = [];
  List<ProjectModel> _filteredProjects = [];
  bool _isLoading = true;
  String _searchQuery = '';
  ProjectSortOption _sortOption = ProjectSortOption.recent;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final list = await _storage.getAllProjects();
    if (mounted) {
      setState(() {
        _allProjects = list;
        _applyFilterAndSort();
        _isLoading = false;
      });
    }
  }

  void _applyFilterAndSort() {
    var result = List<ProjectModel>.from(_allProjects);

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((p) => p.name.toLowerCase().contains(q)).toList();
    }

    switch (_sortOption) {
      case ProjectSortOption.recent:
        result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case ProjectSortOption.name:
        result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case ProjectSortOption.duration:
        result.sort((a, b) => b.totalDurationSeconds.compareTo(a.totalDurationSeconds));
        break;
    }

    _filteredProjects = result;
  }

  Future<void> _openProject(ProjectModel project) async {
    // 1. Cek media missing
    final missing = await _storage.checkMissingMedia(project);
    ProjectModel targetProject = project;

    if (missing.isNotEmpty && mounted) {
      final relinked = await MissingMediaDialog.show(
        context,
        project: project,
        missingList: missing,
      );
      if (relinked == null) return; // Dibatalkan oleh pengguna
      targetProject = relinked;
    }

    if (mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VideoClipperScreen(initialProject: targetProject),
        ),
      );
      _loadProjects();
    }
  }

  Future<void> _createNewProject() async {
    final newId = 'project_${DateTime.now().millisecondsSinceEpoch}';
    final newProject = ProjectModel(
      id: newId,
      name: 'Proyek Baru ${DateTime.now().day}/${DateTime.now().month}',
    );

    await _storage.saveProjectAtomic(newProject);
    if (mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VideoClipperScreen(initialProject: newProject),
        ),
      );
      _loadProjects();
    }
  }

  Future<void> _handleRename(ProjectModel project) async {
    final textController = TextEditingController(text: project.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF262626),
        title: const Text('Ganti Nama Proyek', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Nama proyek',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF6366F1))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            onPressed: () => Navigator.of(ctx).pop(textController.text),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (newName != null && newName.trim().isNotEmpty) {
      await _storage.renameProject(project.id, newName);
      _loadProjects();
    }
  }

  Future<void> _handleDuplicate(ProjectModel project) async {
    await _storage.duplicateProject(project.id);
    _loadProjects();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proyek berhasil digandakan!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  Future<void> _handleDelete(ProjectModel project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF262626),
        title: const Text('Hapus Proyek?', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${project.name}"? Media asli di galeri Anda tidak akan terhapus.',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.deleteProject(project.id);
      _loadProjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.movie_creation_outlined, color: Color(0xFFA78BFA), size: 24),
            SizedBox(width: 8),
            Text(
              'QuickClip Pro',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // Pilihan Pengurutan
          PopupMenuButton<ProjectSortOption>(
            icon: const Icon(Icons.sort_rounded, color: Colors.white70),
            color: const Color(0xFF262626),
            onSelected: (opt) {
              setState(() {
                _sortOption = opt;
                _applyFilterAndSort();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ProjectSortOption.recent,
                child: Text('Terbaru Diperbarui', style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
              const PopupMenuItem(
                value: ProjectSortOption.name,
                child: Text('Urutkan Nama (A-Z)', style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
              const PopupMenuItem(
                value: ProjectSortOption.duration,
                child: Text('Durasi Terlama', style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Bilah Pencarian & Tombol Buat Proyek
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: Colors.white38, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: 'Cari proyek...',
                              hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                                _applyFilterAndSort();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _createNewProject,
                  icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  label: const Text(
                    'Proyek Baru',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Daftar Proyek atau Empty State
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProjects.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _filteredProjects.length,
                        itemBuilder: (context, index) {
                          final project = _filteredProjects[index];
                          return _buildProjectCard(project);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.video_library_outlined, size: 48, color: Color(0xFF818CF8)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Proyek',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mulai membuat kreasi video menakjubkan dengan mengetuk tombol Proyek Baru di atas.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(ProjectModel project) {
    final durStr = TimeFormatter.formatDisplayDuration(project.totalDurationSeconds);
    final dateStr = '${project.updatedAt.day}/${project.updatedAt.month}/${project.updatedAt.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openProject(project),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail preview box
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.movie_rounded, color: Colors.white24, size: 30),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            durStr,
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Detail Proyek
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              project.aspectRatio.name.replaceAll('ratio', '').replaceAll('x', ':'),
                              style: const TextStyle(color: Color(0xFF818CF8), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${project.timeline.clips.length} klip',
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                          if (project.timeline.audioClips.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            const Text('•', style: TextStyle(color: Colors.white38, fontSize: 11)),
                            const SizedBox(width: 4),
                            Text(
                              '${project.timeline.audioClips.length} audio',
                              style: const TextStyle(color: Color(0xFF06B6D4), fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Diedit: $dateStr',
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),

                // Menu Opsi Proyek (Rename, Duplicate, Delete)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white54),
                  color: const Color(0xFF262626),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (action) {
                    switch (action) {
                      case 'rename':
                        _handleRename(project);
                        break;
                      case 'duplicate':
                        _handleDuplicate(project);
                        break;
                      case 'delete':
                        _handleDelete(project);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'rename',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
                          SizedBox(width: 8),
                          Text('Ganti Nama', style: TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Row(
                        children: [
                          Icon(Icons.copy_rounded, color: Colors.white70, size: 18),
                          SizedBox(width: 8),
                          Text('Duplikasi', style: TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
