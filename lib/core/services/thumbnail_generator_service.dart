import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';
import '../models/editor_performance_profile.dart';

/// Service generator thumbnail video dengan bounded LRU memory cache dan disk caching
class ThumbnailGeneratorService {
  // Singleton pattern
  static final ThumbnailGeneratorService _instance = ThumbnailGeneratorService._internal();
  factory ThumbnailGeneratorService() => _instance;
  ThumbnailGeneratorService._internal();

  EditorPerformanceConfig _config = EditorPerformanceConfig.balanced();

  // LRU Cache (LinkedHashMap preserves insertion/access order)
  final LinkedHashMap<String, Uint8List> _memoryCache = LinkedHashMap();
  final Set<String> _pendingTasks = {};

  EditorPerformanceConfig get config => _config;

  void applyConfig(EditorPerformanceConfig config) {
    _config = config;
    _enforceCacheLimit();
  }

  String _buildKey(String path, double timestamp) {
    return '${path}_${timestamp.toStringAsFixed(1)}';
  }

  /// Mengambil thumbnail dari cache jika tersedia
  Uint8List? getCachedThumbnail(String videoPath, double timestampSeconds) {
    final key = _buildKey(videoPath, timestampSeconds);
    if (_memoryCache.containsKey(key)) {
      // Refresh order pada LRU cache
      final val = _memoryCache.remove(key)!;
      _memoryCache[key] = val;
      return val;
    }
    return null;
  }

  /// Menghasilkan thumbnail untuk posisi waktu tertentu secara asynchronous
  Future<Uint8List?> generateThumbnail({
    required String videoPath,
    required double timestampSeconds,
    int? width,
  }) async {
    final key = _buildKey(videoPath, timestampSeconds);
    if (_memoryCache.containsKey(key)) {
      final val = _memoryCache.remove(key)!;
      _memoryCache[key] = val;
      return val;
    }

    if (_pendingTasks.contains(key)) {
      return null; // Sedang diproses task lain
    }
    _pendingTasks.add(key);

    try {
      final tempDir = await getTemporaryDirectory();
      final hash = key.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final thumbFile = File('${tempDir.path}/thumb_$hash.jpg');

      if (await thumbFile.exists()) {
        final bytes = await thumbFile.readAsBytes();
        _putCache(key, bytes);
        return bytes;
      }

      final targetWidth = width ?? _config.thumbnailWidth;
      final targetQuality = _config.thumbnailQuality;

      // Format FFmpeg seek timestamp
      final ss = timestampSeconds.toStringAsFixed(2);
      final cmd = '-ss $ss -i "$videoPath" -vframes 1 -vf "scale=$targetWidth:-1" -q:v $targetQuality -y "${thumbFile.path}"';
      final session = await FFmpegKit.execute(cmd);
      final rc = await session.getReturnCode();

      if (ReturnCode.isSuccess(rc) && await thumbFile.exists()) {
        final bytes = await thumbFile.readAsBytes();
        _putCache(key, bytes);
        return bytes;
      }
    } catch (_) {
      // Ignored
    } finally {
      _pendingTasks.remove(key);
    }
    return null;
  }

  void _putCache(String key, Uint8List bytes) {
    _memoryCache[key] = bytes;
    _enforceCacheLimit();
  }

  void _enforceCacheLimit() {
    final maxLimit = _config.maxCachedThumbnails;
    while (_memoryCache.length > maxLimit && _memoryCache.isNotEmpty) {
      final oldestKey = _memoryCache.keys.first;
      _memoryCache.remove(oldestKey);
    }
  }

  /// Membersihkan cache thumbnail
  void clearMemoryCache() {
    _memoryCache.clear();
  }
}
