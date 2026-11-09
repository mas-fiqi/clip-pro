import 'dart:io';
import '../engine/ffmpeg_processing_engine.dart';
import '../engine/video_processing_engine.dart';
import '../models/clip_model.dart';

/// Adapter kompatibilitas agar kode eksisting (VideoClipperScreen) tetap berjalan mulus
class FFmpegService {
  final VideoProcessingEngine _engine;

  FFmpegService({VideoProcessingEngine? engine})
      : _engine = engine ?? FFmpegProcessingEngine();

  /// API lama yang tetap kompatibel
  Future<File?> trimVideo({
    required String inputPath,
    required double startSeconds,
    required double endSeconds,
    void Function(String)? onLog,
  }) async {
    final clip = ClipModel(
      id: 'legacy_${DateTime.now().millisecondsSinceEpoch}',
      sourcePath: inputPath,
      startSource: startSeconds,
      endSource: endSeconds,
    );

    return _engine.trimClip(
      clip: clip,
      onLog: onLog,
    );
  }

  /// Membatalkan proses jika diperlukan
  Future<void> cancel() async {
    await _engine.cancelSession();
  }
}
