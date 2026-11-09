import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/project_model.dart';
import '../models/timeline_model.dart';

/// Status penyimpanan auto-save
enum AutoSaveStatus {
  idle,
  saving,
  saved,
  unsavedChanges,
  failed,
}

/// Informasi detail media yang hilang
class MissingMediaInfo {
  final String path;
  final bool isVideo;
  final String name;

  MissingMediaInfo({
    required this.path,
    required this.isVideo,
    required this.name,
  });
}

/// Service manajemen proyek: CRUD, atomic save, auto-save debounce, backup/restore, crash recovery & media relinking
class ProjectStorageService {
  static final ProjectStorageService _instance = ProjectStorageService._internal();
  factory ProjectStorageService() => _instance;
  ProjectStorageService._internal();

  Directory? _baseProjectsDir;
  Directory? _backupsDir;
  Directory? _recoveryDir;

  Timer? _autoSaveDebounceTimer;
  ProjectModel? _pendingSaveProject;
  
  final ValueNotifier<AutoSaveStatus> autoSaveStatusNotifier =
      ValueNotifier<AutoSaveStatus>(AutoSaveStatus.idle);

  /// Inisialisasi direktori penyimpanan lokal aplikasi
  Future<void> initialize({Directory? customBaseDir}) async {
    final root = customBaseDir ?? await getApplicationDocumentsDirectory();
    _baseProjectsDir = Directory(p.join(root.path, 'quickclip_projects'));
    _backupsDir = Directory(p.join(root.path, 'quickclip_backups'));
    _recoveryDir = Directory(p.join(root.path, 'quickclip_recovery'));

    if (!await _baseProjectsDir!.exists()) {
      await _baseProjectsDir!.create(recursive: true);
    }
    if (!await _backupsDir!.exists()) {
      await _backupsDir!.create(recursive: true);
    }
    if (!await _recoveryDir!.exists()) {
      await _recoveryDir!.create(recursive: true);
    }
  }

  Directory get projectsDir => _baseProjectsDir!;
  Directory get backupsDir => _backupsDir!;
  Directory get recoveryDir => _recoveryDir!;

  File _getProjectFile(String projectId) {
    return File(p.join(_baseProjectsDir!.path, '$projectId.qcp'));
  }

  File _getRecoveryFile() {
    return File(p.join(_recoveryDir!.path, 'recovery_session.qcp'));
  }

  // ==========================================
  // CRUD & ATOMIC SAVE
  // ==========================================

  /// Simpan proyek secara ATOMIK: Tulis ke file temporer, validasi JSON, lalu rename ke file utama
  Future<bool> saveProjectAtomic(ProjectModel project) async {
    if (_baseProjectsDir == null) await initialize();
    autoSaveStatusNotifier.value = AutoSaveStatus.saving;

    try {
      final targetFile = _getProjectFile(project.id);
      final tempFile = File('${targetFile.path}.tmp');

      final updatedProject = project.copyWith(updatedAt: DateTime.now());
      final jsonString = updatedProject.toRawJson();

      // 1. Tulis ke file temp
      await tempFile.writeAsString(jsonString, flush: true);

      // 2. Validasi integritas
      final readBack = await tempFile.readAsString();
      final decoded = jsonDecode(readBack);
      if (decoded is! Map<String, dynamic> || decoded['id'] != project.id) {
        throw Exception('Data integrity verification failed for temp project file.');
      }

      // 3. Cadangkan salinan terakhir jika file target sudah ada sebelumnya
      if (await targetFile.exists()) {
        final bakFile = File('${targetFile.path}.bak');
        await targetFile.copy(bakFile.path);
      }

      // 4. Atomic Rename / Replace
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await tempFile.rename(targetFile.path);

      // 5. Update recovery snapshot journal
      await _updateRecoverySnapshot(updatedProject);

      autoSaveStatusNotifier.value = AutoSaveStatus.saved;
      return true;
    } catch (e, stack) {
      debugPrint('Error saving project ${project.id} atomically: $e\n$stack');
      autoSaveStatusNotifier.value = AutoSaveStatus.failed;
      return false;
    }
  }

  /// Ambil daftar seluruh proyek yang tersimpan
  Future<List<ProjectModel>> getAllProjects() async {
    if (_baseProjectsDir == null) await initialize();
    final list = <ProjectModel>[];

    try {
      final entities = _baseProjectsDir!.listSync();
      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.qcp')) {
          try {
            final content = await entity.readAsString();
            final project = ProjectModel.fromRawJson(content);
            list.add(project);
          } catch (e) {
            debugPrint('Failed to parse project file ${entity.path}: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error listing projects: $e');
    }

    // Default urutkan dari yang paling baru diperbarui
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  /// Buka satu proyek berdasarkan ID
  Future<ProjectModel?> loadProject(String projectId) async {
    if (_baseProjectsDir == null) await initialize();
    try {
      final file = _getProjectFile(projectId);
      if (!await file.exists()) {
        // Coba buka backup .bak jika file utama hilang/rusak
        final bakFile = File('${file.path}.bak');
        if (await bakFile.exists()) {
          final content = await bakFile.readAsString();
          return ProjectModel.fromRawJson(content);
        }
        return null;
      }
      final content = await file.readAsString();
      return ProjectModel.fromRawJson(content);
    } catch (e) {
      debugPrint('Error loading project $projectId: $e');
      // Fallback baca .bak jika file utama corrupt
      final bakFile = File('${_getProjectFile(projectId).path}.bak');
      if (await bakFile.exists()) {
        try {
          final content = await bakFile.readAsString();
          return ProjectModel.fromRawJson(content);
        } catch (_) {}
      }
      return null;
    }
  }

  /// Hapus proyek (hanya menghapus metadata proyek, TIDAK menghapus file media asli pengguna)
  Future<bool> deleteProject(String projectId) async {
    if (_baseProjectsDir == null) await initialize();
    try {
      final file = _getProjectFile(projectId);
      if (await file.exists()) {
        await file.delete();
      }
      final bak = File('${file.path}.bak');
      if (await bak.exists()) {
        await bak.delete();
      }
      final tmp = File('${file.path}.tmp');
      if (await tmp.exists()) {
        await tmp.delete();
      }
      return true;
    } catch (e) {
      debugPrint('Error deleting project $projectId: $e');
      return false;
    }
  }

  /// Duplikasi proyek dengan ID baru & nama "(Copy)"
  Future<ProjectModel?> duplicateProject(String projectId) async {
    final original = await loadProject(projectId);
    if (original == null) return null;

    final newId = 'project_${DateTime.now().millisecondsSinceEpoch}';
    final duplicated = original.copyWith(
      id: newId,
      name: '${original.name} (Copy)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await saveProjectAtomic(duplicated);
    return success ? duplicated : null;
  }

  /// Ubah nama proyek
  Future<ProjectModel?> renameProject(String projectId, String newName) async {
    final project = await loadProject(projectId);
    if (project == null) return null;

    final updated = project.copyWith(name: newName.trim());
    final success = await saveProjectAtomic(updated);
    return success ? updated : null;
  }

  // ==========================================
  // AUTO-SAVE SYSTEM WITH DEBOUNCE
  // ==========================================

  /// Jadwalkan auto-save setelah perubahan dengan debounce (default 1.5 detik)
  void scheduleAutoSave(ProjectModel project, {Duration delay = const Duration(milliseconds: 1500)}) {
    _pendingSaveProject = project;
    autoSaveStatusNotifier.value = AutoSaveStatus.unsavedChanges;
    _autoSaveDebounceTimer?.cancel();
    _autoSaveDebounceTimer = Timer(delay, () async {
      if (_pendingSaveProject != null) {
        final toSave = _pendingSaveProject!;
        _pendingSaveProject = null;
        await saveProjectAtomic(toSave);
      }
    });
  }

  /// Eksekusi langsung auto-save seketika (misal saat app lifecycle pause / exit editor)
  Future<void> flushAutoSave() async {
    _autoSaveDebounceTimer?.cancel();
    if (_pendingSaveProject != null) {
      final toSave = _pendingSaveProject!;
      _pendingSaveProject = null;
      await saveProjectAtomic(toSave);
    }
  }

  // ==========================================
  // CRASH RECOVERY
  // ==========================================

  Future<void> _updateRecoverySnapshot(ProjectModel project) async {
    try {
      final file = _getRecoveryFile();
      final data = {
        'timestamp': DateTime.now().toIso8601String(),
        'project': project.toJson(),
      };
      await file.writeAsString(jsonEncode(data), flush: true);
    } catch (e) {
      debugPrint('Failed to update recovery snapshot: $e');
    }
  }

  /// Periksa apakah ada snapshot recovery sesi sebelumnya yang belum disimpan
  Future<Map<String, dynamic>?> checkRecoveryData() async {
    if (_recoveryDir == null) await initialize();
    try {
      final file = _getRecoveryFile();
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final timestampStr = decoded['timestamp'] as String;
      final projectJson = decoded['project'] as Map<String, dynamic>;

      final recoveredProject = ProjectModel.fromJson(projectJson);
      final lastTime = DateTime.parse(timestampStr);

      return {
        'timestamp': lastTime,
        'project': recoveredProject,
      };
    } catch (e) {
      debugPrint('Recovery snapshot corrupted or invalid: $e');
      return null;
    }
  }

  /// Bersihkan data recovery setelah pengguna memutuskan restore atau discard
  Future<void> clearRecoveryData() async {
    try {
      final file = _getRecoveryFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error clearing recovery data: $e');
    }
  }

  // ==========================================
  // BACKUP & RESTORE
  // ==========================================

  /// Buat file backup lokal (.qcpbak) untuk proyek
  Future<File?> createProjectBackup(ProjectModel project) async {
    if (_backupsDir == null) await initialize();
    try {
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = '${project.id}_backup_$timestamp.qcpbak';
      final backupFile = File(p.join(_backupsDir!.path, fileName));

      final backupData = {
        'backupVersion': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'project': project.toJson(),
      };

      await backupFile.writeAsString(jsonEncode(backupData), flush: true);
      return backupFile;
    } catch (e) {
      debugPrint('Failed to create backup for ${project.id}: $e');
      return null;
    }
  }

  /// Ambil daftar backup yang tersedia
  Future<List<File>> getBackupsForProject(String projectId) async {
    if (_backupsDir == null) await initialize();
    final list = <File>[];
    try {
      final entities = _backupsDir!.listSync();
      for (final entity in entities) {
        if (entity is File &&
            p.basename(entity.path).startsWith('${projectId}_backup_') &&
            entity.path.endsWith('.qcpbak')) {
          list.add(entity);
        }
      }
      list.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    } catch (e) {
      debugPrint('Error getting backups: $e');
    }
    return list;
  }

  /// Pulihkan proyek dari file backup
  Future<ProjectModel?> restoreProjectBackup(File backupFile) async {
    try {
      if (!await backupFile.exists()) return null;
      final content = await backupFile.readAsString();
      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final projectJson = decoded['project'] as Map<String, dynamic>;
      final project = ProjectModel.fromJson(projectJson);

      // Simpan kembali secara atomik ke daftar proyek aktif
      await saveProjectAtomic(project);
      return project;
    } catch (e) {
      debugPrint('Failed to restore backup from ${backupFile.path}: $e');
      return null;
    }
  }

  // ==========================================
  // MISSING MEDIA & RELINKING
  // ==========================================

  /// Periksa ketersediaan seluruh file media sumber pada proyek
  Future<List<MissingMediaInfo>> checkMissingMedia(ProjectModel project) async {
    final missing = <MissingMediaInfo>[];

    for (final clip in project.timeline.clips) {
      if (clip.sourcePath.isNotEmpty && !await File(clip.sourcePath).exists()) {
        missing.add(MissingMediaInfo(
          path: clip.sourcePath,
          isVideo: true,
          name: p.basename(clip.sourcePath),
        ));
      }
    }

    for (final audio in project.timeline.audioClips) {
      if (audio.sourcePath.isNotEmpty && !await File(audio.sourcePath).exists()) {
        missing.add(MissingMediaInfo(
          path: audio.sourcePath,
          isVideo: false,
          name: p.basename(audio.sourcePath),
        ));
      }
    }

    return missing;
  }

  /// Perbarui referensi path media yang hilang dengan file baru yang valid
  ProjectModel relinkMedia({
    required ProjectModel project,
    required String oldPath,
    required String newPath,
  }) {
    final updatedClips = project.timeline.clips.map((clip) {
      if (clip.sourcePath == oldPath) {
        return clip.copyWith(sourcePath: newPath);
      }
      return clip;
    }).toList();

    final updatedAudio = project.timeline.audioClips.map((audio) {
      if (audio.sourcePath == oldPath) {
        return audio.copyWith(sourcePath: newPath);
      }
      return audio;
    }).toList();

    final updatedTimeline = TimelineModel(
      clips: updatedClips,
      overlays: project.timeline.overlays,
      audioClips: updatedAudio,
    );

    return project.copyWith(timeline: updatedTimeline);
  }
}
