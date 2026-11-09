import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/audio_clip_model.dart';
import 'package:video_clipper_app/core/models/clip_model.dart';
import 'package:video_clipper_app/core/models/overlay_model.dart';
import 'package:video_clipper_app/core/models/project_model.dart';
import 'package:video_clipper_app/core/models/timeline_model.dart';
import 'package:video_clipper_app/core/services/project_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late ProjectStorageService storageService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('qcp_test_');
    storageService = ProjectStorageService();
    await storageService.initialize(customBaseDir: tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  ProjectModel createDummyProject({String id = 'proj_1', String name = 'Test Proj'}) {
    final clip = ClipModel(
      id: 'c1',
      sourcePath: '${tempDir.path}/fake_video.mp4',
      startSource: 0.0,
      endSource: 5.0,
    );
    final audio = AudioClipModel(
      id: 'a1',
      sourcePath: '${tempDir.path}/fake_audio.mp3',
      title: 'BGM',
      startTimeline: 0.0,
      duration: 5.0,
    );
    final overlay = const OverlayModel(
      id: 't1',
      type: OverlayType.text,
      content: 'Hello World',
      startTime: 0.0,
      endTime: 3.0,
    );
    final timeline = TimelineModel(
      clips: [clip],
      audioClips: [audio],
      overlays: [overlay],
    );
    return ProjectModel(
      id: id,
      name: name,
      timeline: timeline,
    );
  }

  group('Phase 5: Project Management & Persistence Tests', () {
    test('1. Create, Save and Load Project atomically', () async {
      final project = createDummyProject(id: 'proj_save_1', name: 'My First Video');
      final saved = await storageService.saveProjectAtomic(project);
      expect(saved, isTrue);

      final loaded = await storageService.loadProject('proj_save_1');
      expect(loaded, isNotNull);
      expect(loaded!.id, equals('proj_save_1'));
      expect(loaded.name, equals('My First Video'));
      expect(loaded.timeline.clips.length, equals(1));
      expect(loaded.timeline.audioClips.length, equals(1));
      expect(loaded.timeline.overlays.length, equals(1));
      expect(loaded.schemaVersion, equals(kCurrentProjectSchemaVersion));
    });

    test('2. Atomic Save verification & backup (.bak) creation', () async {
      final project1 = createDummyProject(id: 'proj_bak', name: 'Version 1');
      await storageService.saveProjectAtomic(project1);

      // Save version 2
      final project2 = project1.copyWith(name: 'Version 2 Updated');
      await storageService.saveProjectAtomic(project2);

      final loaded = await storageService.loadProject('proj_bak');
      expect(loaded!.name, equals('Version 2 Updated'));

      // File .bak harus ada berisi version 1
      final bakFile = File('${tempDir.path}/quickclip_projects/proj_bak.qcp.bak');
      expect(await bakFile.exists(), isTrue);
    });

    test('3. Rename Project', () async {
      final project = createDummyProject(id: 'proj_rename', name: 'Old Name');
      await storageService.saveProjectAtomic(project);

      final renamed = await storageService.renameProject('proj_rename', 'Brand New Name');
      expect(renamed, isNotNull);
      expect(renamed!.name, equals('Brand New Name'));

      final loaded = await storageService.loadProject('proj_rename');
      expect(loaded!.name, equals('Brand New Name'));
    });

    test('4. Duplicate Project creates isolated copy', () async {
      final project = createDummyProject(id: 'proj_orig', name: 'Original Movie');
      await storageService.saveProjectAtomic(project);

      final duplicate = await storageService.duplicateProject('proj_orig');
      expect(duplicate, isNotNull);
      expect(duplicate!.id, isNot(equals('proj_orig')));
      expect(duplicate.name, equals('Original Movie (Copy)'));
      expect(duplicate.timeline.clips.length, equals(1));

      // Memastikan kedua proyek ada di list
      final all = await storageService.getAllProjects();
      expect(all.length, equals(2));
    });

    test('5. Delete Project safely (leaves media intact)', () async {
      final mediaFile = File('${tempDir.path}/fake_video.mp4');
      await mediaFile.writeAsString('fake video content');

      final project = createDummyProject(id: 'proj_del', name: 'To Delete');
      await storageService.saveProjectAtomic(project);

      final deleted = await storageService.deleteProject('proj_del');
      expect(deleted, isTrue);

      final loaded = await storageService.loadProject('proj_del');
      expect(loaded, isNull);

      // File media asli TIDAK boleh terhapus
      expect(await mediaFile.exists(), isTrue);
    });

    test('6. Auto-Save with Debounce & Flush', () async {
      final project = createDummyProject(id: 'proj_autosave', name: 'Live Edit');
      await storageService.saveProjectAtomic(project);

      final updated = project.copyWith(name: 'Edited in Live Session');
      storageService.scheduleAutoSave(updated, delay: const Duration(milliseconds: 50));

      expect(storageService.autoSaveStatusNotifier.value, equals(AutoSaveStatus.unsavedChanges));

      // Flush segera (seperti saat lifecycle paused)
      await storageService.flushAutoSave();
      expect(storageService.autoSaveStatusNotifier.value, equals(AutoSaveStatus.saved));

      final loaded = await storageService.loadProject('proj_autosave');
      expect(loaded!.name, equals('Edited in Live Session'));
    });

    test('7. Crash Recovery: Record snapshot and recover session', () async {
      final crashProject = createDummyProject(id: 'proj_crash', name: 'Before Sudden Crash');
      await storageService.saveProjectAtomic(crashProject);

      final recoveryData = await storageService.checkRecoveryData();
      expect(recoveryData, isNotNull);
      final recovered = recoveryData!['project'] as ProjectModel;
      expect(recovered.id, equals('proj_crash'));
      expect(recovered.name, equals('Before Sudden Crash'));

      // Clear recovery
      await storageService.clearRecoveryData();
      final emptyRecovery = await storageService.checkRecoveryData();
      expect(emptyRecovery, isNull);
    });

    test('8. Crash Recovery corrupted journal fallback', () async {
      // Tulis file recovery korup
      final recFile = File('${tempDir.path}/quickclip_recovery/recovery_session.qcp');
      await recFile.writeAsString('{ "corrupted": true, broken ');

      final recovery = await storageService.checkRecoveryData();
      expect(recovery, isNull); // Corrupted data must not crash the app
    });

    test('9. Project Backup & Restore', () async {
      final project = createDummyProject(id: 'proj_bak_test', name: 'Important Edit');
      await storageService.saveProjectAtomic(project);

      final backupFile = await storageService.createProjectBackup(project);
      expect(backupFile, isNotNull);
      expect(await backupFile!.exists(), isTrue);

      final backups = await storageService.getBackupsForProject('proj_bak_test');
      expect(backups.length, equals(1));

      // Ubah project utama
      await storageService.renameProject('proj_bak_test', 'Accidentally Altered');

      // Restore dari backup
      final restored = await storageService.restoreProjectBackup(backupFile);
      expect(restored, isNotNull);
      expect(restored!.name, equals('Important Edit'));
    });

    test('10. Schema Migration from legacy format (v0 to v1)', () {
      final legacyJson = {
        'id': 'legacy_1',
        'name': 'Old Legacy Project',
        'aspectRatio': 'ratio16x9',
        'resolution': 'res720p',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        // No schemaVersion and null timeline
      };

      final migrated = ProjectModel.fromJson(legacyJson);
      expect(migrated.schemaVersion, equals(1));
      expect(migrated.name, equals('Old Legacy Project'));
      expect(migrated.timeline.clips, isEmpty);
    });

    test('11. Missing Media Detection & Relinking', () async {
      final project = createDummyProject(id: 'proj_media', name: 'Media Check');
      // File media belum dibuat, sehingga harus terdeteksi missing
      final missing = await storageService.checkMissingMedia(project);
      expect(missing.length, equals(2)); // 1 video + 1 audio

      // Buat file baru untuk relink
      final newVideo = File('${tempDir.path}/new_restored_video.mp4');
      await newVideo.writeAsString('new video');

      final relinkedProject = storageService.relinkMedia(
        project: project,
        oldPath: '${tempDir.path}/fake_video.mp4',
        newPath: newVideo.path,
      );

      expect(relinkedProject.timeline.clips.first.sourcePath, equals(newVideo.path));
    });

    test('12. Timeline History Undo / Redo with new edits', () {
      final history = TimelineHistory(maxHistory: 5);
      var timeline = TimelineModel();

      final clip1 = ClipModel(id: 'c1', sourcePath: 'p1.mp4', startSource: 0, endSource: 4);
      final clip2 = ClipModel(id: 'c2', sourcePath: 'p2.mp4', startSource: 0, endSource: 3);

      history.recordState(timeline);
      timeline = timeline.addClip(clip1);

      history.recordState(timeline);
      timeline = timeline.addClip(clip2);
      expect(timeline.clips.length, equals(2));

      // Undo
      final undone = history.undo(timeline);
      expect(undone, isNotNull);
      timeline = undone!;
      expect(timeline.clips.length, equals(1));

      // Redo
      final redone = history.redo(timeline);
      expect(redone, isNotNull);
      timeline = redone!;
      expect(timeline.clips.length, equals(2));

      // Undo again, then make new edit (redo history should clear)
      timeline = history.undo(timeline)!;
      final clip3 = ClipModel(id: 'c3', sourcePath: 'p3.mp4', startSource: 0, endSource: 2);
      history.recordState(timeline);
      timeline = timeline.addClip(clip3);

      expect(history.canRedo, isFalse); // Redo stack invalidated
    });
  });
}

