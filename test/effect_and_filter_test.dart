import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/color_adjustment_model.dart';
import 'package:video_clipper_app/core/models/filter_catalog.dart';
import 'package:video_clipper_app/core/models/video_effect_model.dart';

void main() {
  group('FilterCatalog & VideoEffectModel Tests (Phase 7 - Bagian 7 & 8)', () {
    test('FilterCatalog mencakup seluruh kategori filter wajib', () {
      final categories = FilterCategory.values;
      for (final cat in categories) {
        final matches = FilterCatalog.items.where((i) => i.category == cat).toList();
        expect(matches.isNotEmpty, true, reason: 'Kategori $cat harus memiliki item filter nyata');
      }
    });

    test('FilterCatalog menghasilkan matrix interpolasi proporsional terhadap intensitas', () {
      final matrix0 = FilterCatalog.getBlendedMatrix(FilterPreset.cinematic, 0.0);
      final matrix100 = FilterCatalog.getBlendedMatrix(FilterPreset.cinematic, 1.0);
      final matrix50 = FilterCatalog.getBlendedMatrix(FilterPreset.cinematic, 0.5);

      // Pada intensitas 0.0, matrix harus identity (1.0 pada diagonal)
      expect(matrix0[0], 1.0);
      expect(matrix0[6], 1.0);
      expect(matrix0[12], 1.0);
      expect(matrix0[18], 1.0);

      // Pada intensitas 0.5, nilai harus berada di antara matrix0 dan matrix100
      expect(matrix50[0], (matrix0[0] + matrix100[0]) / 2);
    });

    test('VideoEffectModel mendukung 12 kategori dan serialisasi JSON', () {
      const effect = VideoEffectModel(
        type: EffectType.oldFilmGrain,
        intensity: 0.85,
        durationSeconds: 4.5,
        isFavorite: true,
      );

      expect(effect.hasEffect, true);
      expect(effect.intensity, 0.85);

      final json = effect.toJson();
      final restored = VideoEffectModel.fromJson(json);

      expect(restored.type, EffectType.oldFilmGrain);
      expect(restored.intensity, 0.85);
      expect(restored.durationSeconds, 4.5);
      expect(restored.isFavorite, true);
    });

    test('EffectCatalog mencakup seluruh 12 kategori efek dan memiliki FFmpeg filter nyata', () {
      for (final cat in EffectCategory.values) {
        final items = EffectCatalog.items.where((e) => e.category == cat).toList();
        expect(items.isNotEmpty, true, reason: 'Kategori efek $cat harus ada dalam katalog');
        for (final item in items) {
          expect(item.ffmpegFilterPattern.isNotEmpty, true);
          expect(item.name.isNotEmpty, true);
        }
      }
    });
  });
}

