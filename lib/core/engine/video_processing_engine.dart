import 'dart:io';
import '../models/clip_model.dart';
import '../models/export_config_model.dart';
import '../models/overlay_model.dart';
import '../models/timeline_model.dart';

typedef ProgressCallback = void Function(double progressFraction);
typedef LogCallback = void Function(String logMessage);

/// Antarmuka standar (Interface) untuk mesin pemrosesan video lokal
abstract class VideoProcessingEngine {
  Future<File?> trimClip({
    required ClipModel clip,
    List<OverlayModel>? overlays,
    ExportConfigModel? exportConfig,
    ProgressCallback? onProgress,
    LogCallback? onLog,
  });

  Future<File?> exportTimeline({
    required TimelineModel timeline,
    ExportConfigModel? exportConfig,
    ProgressCallback? onProgress,
    LogCallback? onLog,
  });

  Future<void> cancelSession();
}
