import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

/// Service Singleton untuk me-manage Video Player Preview secara hemat memori (Redmi Note 8 Ready)
/// - Membatasi maksimal 2 controller aktif secara simultan (LRU pool)
/// - Menghindari memory leak dengan automatic dispose
/// - Mute audio secara default
/// - Looping otomatis 2-4 detik
class EffectPreviewPlayerManager {
  static final EffectPreviewPlayerManager _instance = EffectPreviewPlayerManager._internal();
  factory EffectPreviewPlayerManager() => _instance;
  EffectPreviewPlayerManager._internal();

  // Max video controller aktif dalam satu waktu untuk mencegah OOM pada ponsel RAM 3GB/4GB
  static const int maxConcurrentControllers = 2;

  final Map<String, VideoPlayerController> _activeControllers = {};
  final List<String> _lruOrder = [];

  /// Dapatkan atau inisialisasi controller untuk asset video tertentu
  Future<VideoPlayerController?> getOrCreateController(String assetPath) async {
    if (_activeControllers.containsKey(assetPath)) {
      _touch(assetPath);
      final c = _activeControllers[assetPath]!;
      if (!c.value.isInitialized) {
        try {
          await c.initialize();
        } catch (_) {}
      }
      return c;
    }

    // Jika melebihi batas, dispose yang paling lama tidak digunakan (LRU)
    while (_activeControllers.length >= maxConcurrentControllers) {
      final oldest = _lruOrder.removeAt(0);
      final controllerToDispose = _activeControllers.remove(oldest);
      try {
        await controllerToDispose?.pause();
        await controllerToDispose?.dispose();
      } catch (e) {
        debugPrint('Error disposing preview player: $e');
      }
    }

    try {
      final controller = VideoPlayerController.asset(assetPath);
      await controller.initialize();
      await controller.setVolume(0.0); // Wajib mute tanpa audio
      await controller.setLooping(true); // Loop otomatis
      _activeControllers[assetPath] = controller;
      _lruOrder.add(assetPath);
      return controller;
    } catch (e) {
      debugPrint('Failed to initialize asset video: $assetPath - $e');
      return null;
    }
  }

  void _touch(String assetPath) {
    _lruOrder.remove(assetPath);
    _lruOrder.add(assetPath);
  }

  /// Pause semua controller yang sedang berjalan saat scrolling atau background
  void pauseAll() {
    for (final controller in _activeControllers.values) {
      try {
        if (controller.value.isPlaying) {
          controller.pause();
        }
      } catch (_) {}
    }
  }

  /// Bersihkan seluruh resource video player
  void disposeAll() {
    for (final controller in _activeControllers.values) {
      try {
        controller.pause();
        controller.dispose();
      } catch (_) {}
    }
    _activeControllers.clear();
    _lruOrder.clear();
  }
}

