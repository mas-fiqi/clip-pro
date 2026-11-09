import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/animation_model.dart';
import 'package:video_clipper_app/core/models/clip_model.dart';
import 'package:video_clipper_app/core/services/animation_library_service.dart';

void main() {
  group('AnimationModel & Animation Studio Tests', () {
    test('Default ClipAnimationModel has no active animation', () {
      const anim = ClipAnimationModel();
      expect(anim.hasAnimation, isFalse);
      expect(anim.duration, equals(1.0));
      expect(anim.type, equals(AnimationApplicationType.inAnimation));

      final res = anim.evaluate(timeInClip: 0.5, totalClipDuration: 5.0);
      expect(res.scale, equals(1.0));
      expect(res.opacity, equals(1.0));
    });

    test('Zoom Burst in-animation produces dynamic scale and flash', () {
      const anim = ClipAnimationModel(
        presetId: 'zoom_burst',
        type: AnimationApplicationType.inAnimation,
        duration: 1.0,
        intensity: 1.0,
      );
      expect(anim.hasAnimation, isTrue);

      // At start (time = 0.0)
      final resStart = anim.evaluate(timeInClip: 0.0, totalClipDuration: 4.0);
      expect(resStart.scale, greaterThan(1.0));
      expect(resStart.flashOpacity, greaterThan(0.0));

      // At end of anim duration (time = 1.0)
      final resEnd = anim.evaluate(timeInClip: 1.0, totalClipDuration: 4.0);
      expect(resEnd.scale, closeTo(1.0, 0.05));
    });

    test('Fade Out out-animation calculates correct timeline timing', () {
      const anim = ClipAnimationModel(
        presetId: 'fade_out',
        type: AnimationApplicationType.outAnimation,
        duration: 1.0,
      );

      // Total clip 4s: out-anim starts at 3s
      final resMid = anim.evaluate(timeInClip: 2.0, totalClipDuration: 4.0);
      expect(resMid.opacity, equals(1.0));

      final resEnd = anim.evaluate(timeInClip: 4.0, totalClipDuration: 4.0);
      expect(resEnd.opacity, closeTo(0.0, 0.05));
    });

    test('Camera Shake produces bounded positional offsets', () {
      const anim = ClipAnimationModel(
        presetId: 'camera_shake',
        type: AnimationApplicationType.comboAnimation,
        duration: 2.0,
        intensity: 1.0,
      );

      final res = anim.evaluate(timeInClip: 0.75, totalClipDuration: 5.0);
      expect(res.positionX.abs(), lessThanOrEqualTo(0.1));
      expect(res.positionY.abs(), lessThanOrEqualTo(0.1));
    });

    test('ClipAnimationModel generates valid FFmpeg video filters', () {
      const animIn = ClipAnimationModel(
        presetId: 'fade_in',
        type: AnimationApplicationType.inAnimation,
        duration: 1.2,
      );
      final filterIn = animIn.buildFFmpegFilter(clipDuration: 5.0);
      expect(filterIn, contains('fade=t=in'));
      expect(filterIn, contains('d=1.2'));

      const animOut = ClipAnimationModel(
        presetId: 'fade_out',
        type: AnimationApplicationType.outAnimation,
        duration: 1.0,
      );
      final filterOut = animOut.buildFFmpegFilter(clipDuration: 6.0);
      expect(filterOut, contains('fade=t=out'));
      expect(filterOut, contains('st=5.0'));

      const animShake = ClipAnimationModel(
        presetId: 'camera_shake',
        type: AnimationApplicationType.comboAnimation,
        duration: 1.0,
      );
      final filterShake = animShake.buildFFmpegFilter(clipDuration: 4.0);
      expect(filterShake, contains('crop=w='));
    });

    test('ClipModel serialization preserves animation config', () {
      final clip = ClipModel(
        id: 'c1',
        sourcePath: '/path/test.mp4',
        startSource: 0.0,
        endSource: 5.0,
        animation: const ClipAnimationModel(
          presetId: 'impact_shake',
          type: AnimationApplicationType.inAnimation,
          duration: 0.8,
          intensity: 1.2,
        ),
      );

      final json = clip.toJson();
      final restored = ClipModel.fromJson(json);

      expect(restored.animation.hasAnimation, isTrue);
      expect(restored.animation.presetId, equals('impact_shake'));
      expect(restored.animation.duration, equals(0.8));
      expect(restored.animation.intensity, equals(1.2));
    });
  });

  group('AnimationLibraryService Catalog & Preset Tests', () {
    final service = AnimationLibraryService();

    test(
      'Built-in presets list contains Trending, Basic, Light, Glitch, Shake, 3D',
      () {
        final all = service.getAllPresets();
        expect(all.length, greaterThanOrEqualTo(30));

        final trending = service.filterPresets(
          category: AnimationCategory.trending,
        );
        expect(trending, isNotEmpty);
        expect(trending.any((p) => p.id == 'zoom_burst'), isTrue);

        final shake = service.filterPresets(category: AnimationCategory.shake);
        expect(shake, isNotEmpty);
        expect(shake.any((p) => p.id == 'camera_shake'), isTrue);
      },
    );

    test('Favorite and recently used preset operations', () {
      expect(service.isFavorite('zoom_burst'), isFalse);
      service.toggleFavorite('zoom_burst');
      expect(service.isFavorite('zoom_burst'), isTrue);

      final favs = service.filterPresets(favoritesOnly: true);
      expect(favs.any((p) => p.id == 'zoom_burst'), isTrue);

      service.recordRecentlyUsed('zoom_burst');
      expect(service.recentlyUsedIds.contains('zoom_burst'), isTrue);

      service.toggleFavorite('zoom_burst'); // un-favorite
      expect(service.isFavorite('zoom_burst'), isFalse);
    });

    test('Search filter matches name, category, or description', () {
      final searchBounce = service.filterPresets(searchQuery: 'Bounce');
      expect(searchBounce, isNotEmpty);
      expect(searchBounce.first.name, contains('Bounce'));

      final searchGlitch = service.filterPresets(searchQuery: 'glitch');
      expect(searchGlitch, isNotEmpty);
    });

    test('Preset online yang belum terverifikasi tidak ditampilkan', () {
      // Seluruh URL katalog online masih 404, jadi preset tersebut tidak boleh
      // muncul sebagai pilihan yang bisa diunduh pengguna.
      final all = service.getAllPresets();
      final onlinePresets = all.where((p) => p.isOnline).toList();
      expect(onlinePresets, isEmpty);
    });
  });
}
