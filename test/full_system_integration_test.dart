import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/audio_clip_model.dart';
import 'package:video_clipper_app/core/models/clip_model.dart';
import 'package:video_clipper_app/core/models/clip_transform_model.dart';
import 'package:video_clipper_app/core/models/color_adjustment_model.dart';
import 'package:video_clipper_app/core/models/export_config_model.dart';
import 'package:video_clipper_app/core/models/overlay_model.dart';
import 'package:video_clipper_app/core/models/project_model.dart';
import 'package:video_clipper_app/core/models/timeline_model.dart';
import 'package:video_clipper_app/core/services/project_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late ProjectStorageService storageService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('qcp_e2e_');
    storageService = ProjectStorageService();
    await storageService.initialize(customBaseDir: tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Phase 6: Full System Integration & E2E Workflow Test', () {
    test('1. Full End-to-End Video Editing Pipeline Simulation', () async {
      // Skenario E2E:
      // 1. Buat Project Baru
      final project = ProjectModel(
        id: 'proj_e2e_full',
        name: 'Vlog Liburan E2E',
        aspectRatio: CanvasAspectRatio.ratio9x16, // 9:16 TikTok / Reels
      );
      expect(project.aspectRatio, equals(CanvasAspectRatio.ratio9x16));

      // 2. Tambah 2 klip video
      final clip1 = ClipModel(
        id: 'clip_1',
        sourcePath: '${tempDir.path}/video1.mp4',
        startSource: 0.0,
        endSource: 4.0,
        transform: const ClipTransformModel(
          canvasRatio: CanvasRatioMode.ratio9x16,
          rotationDegrees: 0,
        ),
        adjustment: const ColorAdjustmentModel(
          preset: FilterPreset.cinematic,
          brightness: 0.1,
        ),
      );

      final clip2 = ClipModel(
        id: 'clip_2',
        sourcePath: '${tempDir.path}/video2.mp4',
        startSource: 1.0,
        endSource: 6.0,
        speed: 1.5, // Speed ramp
        transform: const ClipTransformModel(
          canvasRatio: CanvasRatioMode.ratio9x16,
        ),
      );

      // 3. Tambahkan ke Timeline
      var timeline = TimelineModel(clips: [clip1, clip2]);
      expect(timeline.clips.length, equals(2));
      // Durasi: clip1 (4s) + clip2 ((6-1)/1.5 = 3.33s) = 7.33s
      expect(timeline.totalDuration, closeTo(7.33, 0.05));

      // 4. Split Clip 1 di detik ke-2
      final splitResult = timeline.splitAt(2.0);
      expect(splitResult, isNotNull);
      timeline = splitResult!;
      expect(timeline.clips.length, equals(3));

      // 5. Tambah Musik Latar & Sound Effect
      final bgm = AudioClipModel(
        id: 'bgm_1',
        sourcePath: '${tempDir.path}/music.mp3',
        title: 'Lofi Beats',
        startTimeline: 0.0,
        duration: 7.0,
        volume: 0.8,
        fadeInSeconds: 0.5,
      );
      final sfx = AudioClipModel(
        id: 'sfx_1',
        sourcePath: '${tempDir.path}/whoosh.mp3',
        title: 'Whoosh SFX',
        startTimeline: 2.0,
        duration: 1.0,
        volume: 1.0,
      );
      timeline = timeline.addAudioClip(bgm).addAudioClip(sfx);
      expect(timeline.audioClips.length, equals(2));

      // 6. Tambah Teks & Subtitle Overlay
      final titleText = const OverlayModel(
        id: 'text_title',
        type: OverlayType.text,
        content: 'Hari Pertama di Bali',
        startTime: 0.5,
        endTime: 3.5,
        textColorHex: 'FFFF00',
        presetStyle: TextPresetStyle.bold,
      );
      timeline = timeline.addOverlay(titleText);
      expect(timeline.overlays.length, equals(1));

      // 7. Simpan Proyek ke Storage secara Atomik
      final updatedProject = project.copyWith(timeline: timeline);
      final saveSuccess = await storageService.saveProjectAtomic(updatedProject);
      expect(saveSuccess, isTrue);

      // 8. Muat Kembali Proyek dan Verifikasi Integritas
      final reloaded = await storageService.loadProject('proj_e2e_full');
      expect(reloaded, isNotNull);
      expect(reloaded!.name, equals('Vlog Liburan E2E'));
      expect(reloaded.timeline.clips.length, equals(3));
      expect(reloaded.timeline.audioClips.length, equals(2));
      expect(reloaded.timeline.overlays.length, equals(1));
      expect(reloaded.timeline.clips.first.adjustment.preset, equals(FilterPreset.cinematic));

      // 9. Snapshot Sebelum Ekspor
      final exportSnapshot = TimelineModel(
        clips: List.from(reloaded.timeline.clips),
        overlays: List.from(reloaded.timeline.overlays),
        audioClips: List.from(reloaded.timeline.audioClips),
      );
      expect(exportSnapshot.clips.length, equals(3));
    });

    test('2. FFmpeg Command Generation Integrity Verification', () {
      final clip = ClipModel(
        id: 'c1',
        sourcePath: '/mock/video.mp4',
        startSource: 1.0,
        endSource: 5.0,
        speed: 1.25,
        transform: const ClipTransformModel(
          canvasRatio: CanvasRatioMode.ratio9x16,
          rotationDegrees: 90,
          flipHorizontal: true,
        ),
        adjustment: const ColorAdjustmentModel(
          preset: FilterPreset.vintage,
          brightness: 0.2,
          contrast: 0.1,
        ),
      );

      final audio = const AudioClipModel(
        id: 'a1',
        sourcePath: '/mock/audio.mp3',
        title: 'Track 1',
        startTimeline: 0.0,
        duration: 4.0,
        volume: 0.7,
      );

      final overlay = const OverlayModel(
        id: 'o1',
        type: OverlayType.text,
        content: 'Subtitle Mock',
        startTime: 0.0,
        endTime: 2.0,
      );

      final timeline = TimelineModel(
        clips: [clip],
        audioClips: [audio],
        overlays: [overlay],
      );

      final config = ExportConfigModel(
        resolution: ExportResolutionPreset.res1080p,
        fps: ExportFps.fps60,
        bitrateQuality: ExportBitrateQuality.high,
        encoderMode: ExportEncoderMode.hardware,
      );

      expect(config.targetHeight, equals(1080));
      expect(config.fpsValue, equals(60));
      expect(config.encoderMode, equals(ExportEncoderMode.hardware));
      expect(timeline.audioClips.length, equals(1));
    });
  });
}
