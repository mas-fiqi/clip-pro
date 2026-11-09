import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/project_model.dart';
import 'package:video_clipper_app/core/models/timeline_model.dart';
import 'package:video_clipper_app/core/models/clip_model.dart';
import 'package:video_clipper_app/core/models/clip_transform_model.dart';
import 'package:video_clipper_app/core/models/color_adjustment_model.dart';
import 'package:video_clipper_app/core/models/audio_clip_model.dart';
import 'package:video_clipper_app/core/models/overlay_model.dart';
import 'package:video_clipper_app/core/services/project_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MASTER TASK #006: 75 Requirements Integrity & Verification Suite', () {
    late Directory tempTestDir;
    late ProjectStorageService storage;

    setUp(() async {
      tempTestDir = await Directory.systemTemp.createTemp('quickclip_test_006_');
      storage = ProjectStorageService();
      await storage.initialize(customBaseDir: tempTestDir);
    });

    tearDown(() async {
      if (await tempTestDir.exists()) {
        await tempTestDir.delete(recursive: true);
      }
    });

    // ==========================================
    // 1. PROJECT STATE (STATE-001 s/d STATE-010)
    // ==========================================
    test('STATE-001 s/d STATE-010: Project Creation, Naming, Metadata, Timestamps, Duplicate, Delete, Reopen', () async {
      final p1 = ProjectModel(
        id: 'proj_state_001',
        name: 'My Master Project',
        aspectRatio: CanvasAspectRatio.ratio9x16,
        resolution: ExportResolution.res1080p,
      );

      // STATE-001, STATE-002, STATE-003, STATE-004, STATE-005
      expect(p1.id, equals('proj_state_001'));
      expect(p1.name, equals('My Master Project'));
      expect(p1.aspectRatio, equals(CanvasAspectRatio.ratio9x16));
      expect(p1.resolution, equals(ExportResolution.res1080p));
      expect(p1.createdAt, isNotNull);
      expect(p1.updatedAt, isNotNull);

      // Save & Reopen (STATE-006, STATE-007, STATE-010)
      final saved = await storage.saveProjectAtomic(p1);
      expect(saved, isTrue);

      final loaded = await storage.loadProject('proj_state_001');
      expect(loaded, isNotNull);
      expect(loaded!.id, equals(p1.id));
      expect(loaded.name, equals('My Master Project'));
      expect(loaded.aspectRatio, equals(CanvasAspectRatio.ratio9x16));

      // Duplication (STATE-009)
      final dup = await storage.duplicateProject('proj_state_001');
      expect(dup, isNotNull);
      expect(dup!.id, isNot(equals(p1.id)));
      expect(dup.name, contains('(Copy)'));

      // Deletion (STATE-008)
      final deleted = await storage.deleteProject('proj_state_001');
      expect(deleted, isTrue);
      final reloadDeleted = await storage.loadProject('proj_state_001');
      expect(reloadDeleted, isNull);
    });

    // ==========================================
    // 2. TIMELINE STATE (STATE-011 s/d STATE-026)
    // ==========================================
    test('STATE-011 s/d STATE-026: Clip Ordering, IDs, Timings, Duration, Transform, Filter, Text, Audio Persistence', () async {
      final clip1 = ClipModel(
        id: 'c_01',
        sourcePath: 'vid1.mp4',
        startSource: 1.0,
        endSource: 5.0,
        speed: 2.0,
        volume: 0.8,
        transform: const ClipTransformModel(
          rotationDegrees: 90.0,
          flipHorizontal: true,
          cropLeft: 0.1,
          cropRight: 0.9,
        ),
        adjustment: const ColorAdjustmentModel(
          preset: FilterPreset.warm,
          brightness: 0.15,
        ),
      );

      final clip2 = ClipModel(
        id: 'c_02',
        sourcePath: 'vid2.mp4',
        startSource: 0.0,
        endSource: 10.0,
        speed: 1.0,
        volume: 0.0, // Mute
      );

      final overlay = OverlayModel(
        id: 'ov_txt',
        type: OverlayType.text,
        content: 'Persistent Text',
        startTime: 0.5,
        endTime: 4.0,
        normalizedX: 0.5,
        normalizedY: 0.2,
      );

      final audio = AudioClipModel(
        id: 'aud_01',
        title: 'BGM',
        sourcePath: 'bgm.mp3',
        startTimeline: 0.0,
        duration: 8.0,
        volume: 0.6,
      );

      final project = ProjectModel(
        id: 'proj_timeline_state',
        name: 'Timeline State Test',
        timeline: TimelineModel(
          clips: [clip1, clip2],
          overlays: [overlay],
          audioClips: [audio],
        ),
      );

      // Save to storage
      await storage.saveProjectAtomic(project);

      // Reopen and verify complete fidelity
      final reloaded = await storage.loadProject('proj_timeline_state');
      expect(reloaded, isNotNull);
      final tl = reloaded!.timeline;

      // STATE-011, STATE-012, STATE-013, STATE-014, STATE-015, STATE-016
      expect(tl.clips.length, equals(2));
      expect(tl.clips[0].id, equals('c_01'));
      expect(tl.clips[1].id, equals('c_02'));
      expect(tl.clips[0].startSource, equals(1.0));
      expect(tl.clips[0].endSource, equals(5.0));
      expect(tl.clips[0].sourceDuration, equals(4.0));
      expect(tl.clips[0].timelineDuration, equals(2.0)); // 4s @ 2x
      expect(tl.clips[1].timelineDuration, equals(10.0));
      expect(tl.totalDuration, equals(12.0));

      // STATE-017, STATE-018, STATE-019, STATE-020, STATE-021, STATE-022, STATE-023, STATE-024, STATE-025, STATE-026
      expect(tl.clips[0].speed, equals(2.0));
      expect(tl.clips[0].transform.rotationDegrees, equals(90.0));
      expect(tl.clips[0].transform.flipHorizontal, isTrue);
      expect(tl.clips[0].transform.cropLeft, equals(0.1));
      expect(tl.clips[0].adjustment.preset, equals(FilterPreset.warm));
      expect(tl.clips[0].adjustment.brightness, equals(0.15));
      expect(tl.clips[1].volume, equals(0.0));

      expect(tl.overlays.length, equals(1));
      expect(tl.overlays.first.content, equals('Persistent Text'));
      expect(tl.overlays.first.startTime, equals(0.5));

      expect(tl.audioClips.length, equals(1));
      expect(tl.audioClips.first.title, equals('BGM'));
      expect(tl.audioClips.first.volume, equals(0.6));
    });

    // ==========================================
    // 3. UNDO / REDO (STATE-027 s/d STATE-035)
    // ==========================================
    test('STATE-027 s/d STATE-035: Undo, Redo, Multi-Step, Invalidation, Timeline Safety', () {
      final history = TimelineHistory(maxHistory: 5);
      final state0 = TimelineModel(clips: [
        ClipModel(id: 'c1', sourcePath: 'p1.mp4', startSource: 0.0, endSource: 2.0),
      ]);
      final state1 = TimelineModel(clips: [
        ClipModel(id: 'c1', sourcePath: 'p1.mp4', startSource: 0.0, endSource: 2.0),
        ClipModel(id: 'c2', sourcePath: 'p2.mp4', startSource: 0.0, endSource: 3.0),
      ]);
      final state2 = TimelineModel(clips: [
        ClipModel(id: 'c1', sourcePath: 'p1.mp4', startSource: 0.0, endSource: 2.0),
        ClipModel(id: 'c2', sourcePath: 'p2.mp4', startSource: 0.0, endSource: 3.0),
        ClipModel(id: 'c3', sourcePath: 'p3.mp4', startSource: 0.0, endSource: 4.0),
      ]);

      // Push states
      history.recordState(state0);
      history.recordState(state1);

      // STATE-027, STATE-028, STATE-029, STATE-030
      expect(history.canUndo, isTrue);
      final undone1 = history.undo(state2);
      expect(undone1?.clips.length, equals(2)); // Kembali ke state1

      final undone0 = history.undo(undone1!);
      expect(undone0?.clips.length, equals(1)); // Kembali ke state0

      expect(history.canRedo, isTrue);
      final redone1 = history.redo(undone0!);
      expect(redone1?.clips.length, equals(2)); // Maju ke state1

      // STATE-033: Edit baru setelah undo harus membatalkan redo stack
      final stateNew = TimelineModel(clips: [
        ClipModel(id: 'c_branch', sourcePath: 'branch.mp4', startSource: 0.0, endSource: 1.0),
      ]);
      history.recordState(stateNew);
      expect(history.canRedo, isFalse); // Redo stack invalidation
    });

    // ==========================================
    // 4. AUTOSAVE (STATE-036 s/d STATE-043)
    // ==========================================
    test('STATE-036 s/d STATE-043: Autosave Trigger, Debounce, Flush, Latest State, Atomicity', () async {
      final pBase = ProjectModel(id: 'p_auto', name: 'AutoSave Test');

      // Jadwalkan auto save bertubi-tubi (rapid edits)
      storage.scheduleAutoSave(pBase.copyWith(name: 'Edit 1'), delay: const Duration(milliseconds: 50));
      storage.scheduleAutoSave(pBase.copyWith(name: 'Edit 2'), delay: const Duration(milliseconds: 50));
      storage.scheduleAutoSave(pBase.copyWith(name: 'Edit 3 (Final)'), delay: const Duration(milliseconds: 50));

      // Sebelum delay berakhir, file belum tertulis dengan nama final
      expect(storage.autoSaveStatusNotifier.value, equals(AutoSaveStatus.unsavedChanges));

      // Flush paksa seketika (simulasi app background / exit)
      await storage.flushAutoSave();

      expect(storage.autoSaveStatusNotifier.value, equals(AutoSaveStatus.saved));
      final reloaded = await storage.loadProject('p_auto');
      expect(reloaded?.name, equals('Edit 3 (Final)'));
    });

    // ==========================================
    // 5. CRASH RECOVERY (STATE-044 s/d STATE-050)
    // ==========================================
    test('STATE-044 s/d STATE-050: Recovery Snapshot, Detection, Restore, Cleanup', () async {
      final project = ProjectModel(
        id: 'proj_crash',
        name: 'Crash Candidate',
        timeline: TimelineModel(clips: [
          ClipModel(id: 'c_salvaged', sourcePath: 'survivor.mp4', startSource: 0.0, endSource: 5.0),
        ]),
      );

      // Simpan proyek (otomatis mencatat recovery snapshot)
      await storage.saveProjectAtomic(project);

      // Cek recovery data
      final recovery = await storage.checkRecoveryData();
      expect(recovery, isNotNull);
      final recProj = recovery!['project'] as ProjectModel;
      expect(recProj.id, equals('proj_crash'));
      expect(recProj.timeline.clips.first.sourcePath, equals('survivor.mp4'));

      // Bersihkan recovery
      await storage.clearRecoveryData();
      final afterClear = await storage.checkRecoveryData();
      expect(afterClear, isNull);
    });

    // ==========================================
    // 6. MEDIA RELINK (STATE-051 s/d STATE-057)
    // ==========================================
    test('STATE-051 s/d STATE-057: Missing Media Detection, Relink, Preserve Editing State', () async {
      final project = ProjectModel(
        id: 'proj_relink',
        name: 'Relink Test',
        timeline: TimelineModel(clips: [
          ClipModel(
            id: 'c_missing',
            sourcePath: 'ghost_location/missing.mp4',
            startSource: 1.5,
            endSource: 8.0,
            speed: 1.25,
            volume: 0.9,
          ),
        ]),
      );

      // Deteksi media hilang (STATE-051)
      final missing = await storage.checkMissingMedia(project);
      expect(missing.length, equals(1));
      expect(missing.first.path, equals('ghost_location/missing.mp4'));

      // Relink ke file baru yang valid (STATE-053, STATE-055, STATE-056)
      final relinked = storage.relinkMedia(
        project: project,
        oldPath: 'ghost_location/missing.mp4',
        newPath: 'restored_location/found.mp4',
      );

      final relinkedClip = relinked.timeline.clips.first;
      expect(relinkedClip.sourcePath, equals('restored_location/found.mp4'));
      expect(relinkedClip.startSource, equals(1.5));
      expect(relinkedClip.endSource, equals(8.0));
      expect(relinkedClip.speed, equals(1.25));
      expect(relinkedClip.volume, equals(0.9)); // Metadata editan tetap 100% utuh
    });

    // ==========================================
    // 7. FILE INTEGRITY & CORRUPTION (STATE-058 s/d STATE-065)
    // ==========================================
    test('STATE-058 s/d STATE-065: Malformed JSON, Truncated File, Schema Versioning', () async {
      // 1. File kosong / corrupt
      final corruptFile = File(storage.getProjectFileForTesting('corrupt_proj').path);
      await corruptFile.parent.create(recursive: true);
      await corruptFile.writeAsString('{ "id": "corrupt_proj", "name": "Broken JSON... truncated');

      final loadedCorrupt = await storage.loadProject('corrupt_proj');
      expect(loadedCorrupt, isNull); // Tidak crash, mengembalikan null aman

      // 2. Schema Migration: Legacy V0 otomatis dimigrasi ke V1
      final legacyJson = {
        'id': 'legacy_proj',
        'name': 'Old Format V0',
        'aspectRatio': 'ratio16x9',
        'resolution': 'res720p',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      final migrated = ProjectModel.fromJson(legacyJson);
      expect(migrated.schemaVersion, equals(1));
      expect(migrated.timeline.clips, isEmpty);
    });

    // ==========================================
    // 8. LIFECYCLE & ADVERSARIAL (STATE-066 s/d STATE-075)
    // ==========================================
    test('STATE-066 s/d STATE-075: Read-After-Write, Atomic Replacement, Backup Fallback', () async {
      final project = ProjectModel(
        id: 'proj_atomic',
        name: 'Atomic Replacement Test',
        timeline: TimelineModel(clips: [
          ClipModel(id: 'c1', sourcePath: 'v1.mp4', startSource: 0.0, endSource: 3.0),
        ]),
      );

      // Tulis awal
      await storage.saveProjectAtomic(project);
      final targetFile = storage.getProjectFileForTesting('proj_atomic');
      expect(await targetFile.exists(), isTrue);

      // Modifikasi dan simpan ulang (harus membuat .bak)
      final modified = project.copyWith(name: 'Atomic Replacement Modified');
      await storage.saveProjectAtomic(modified);

      final bakFile = File('${targetFile.path}.bak');
      expect(await bakFile.exists(), isTrue);

      // Rusak file utama, buka kembali -> harus fallback ke .bak secara mulus
      await targetFile.writeAsString('CORRUPTED BY CRASH DURING FLUSH');
      final fallbackRecovered = await storage.loadProject('proj_atomic');
      expect(fallbackRecovered, isNotNull);
      expect(fallbackRecovered?.id, equals('proj_atomic'));
    });
  });
}
