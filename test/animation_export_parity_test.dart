import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/animation_model.dart';
import 'package:video_clipper_app/core/services/animation_builtin_presets_data.dart';
import 'package:video_clipper_app/core/services/animation_export_support.dart';
import 'package:video_clipper_app/core/services/animation_presets_data.dart';

/// Test parity preview -> ekspor.
///
/// Kontrak yang dijaga:
/// 1. Setiap preset punya status ekspor yang jelas (full/approximate/previewOnly).
/// 2. Preset non-preview selalu menghasilkan filter ekspor yang tidak kosong.
/// 3. Filter tidak memakai zoompan (yang memaksa 1280x720 @ 25 fps dan
///    membuat durasi klip melar) atau ekspresi waktu pada gblur.
void main() {
  final catalog = <AnimationPresetModel>[
    ...AnimationBuiltinPresetsData.allPresets,
    ...AnimationPresetsData.allPresets,
  ];

  test('setiap preset punya jalur ekspor yang jelas', () {
    final missingFilters = <String>[];
    final previewOnly = <String>[];
    var full = 0;
    var approximate = 0;

    for (final preset in catalog) {
      final support = AnimationExportSupportService.resolve(preset);
      final animation = ClipAnimationModel(
        presetId: preset.id,
        type: preset.type,
        duration: 1.0,
      );
      final filter = AnimationExportSupportService.buildExportFilter(
        animation,
        preset: preset,
        clipDuration: 5.0,
      );

      switch (support.mode) {
        case AnimationExportMode.full:
          full++;
          if (filter.isEmpty) missingFilters.add(preset.id);
        case AnimationExportMode.approximate:
          approximate++;
          if (filter.isEmpty) missingFilters.add(preset.id);
        case AnimationExportMode.previewOnly:
          previewOnly.add(preset.id);
          expect(
            filter,
            isEmpty,
            reason:
                '${preset.id} ditandai previewOnly tetapi menghasilkan filter',
          );
      }
    }

    expect(
      missingFilters,
      isEmpty,
      reason: 'Preset ini akan kehilangan animasi saat ekspor: $missingFilters',
    );
    expect(full, greaterThan(0));
    expect(approximate, greaterThan(0));
    expect(
      previewOnly.length,
      lessThan(catalog.length),
      reason: 'Tidak boleh seluruh katalog hanya preview',
    );
  });

  test('filter ekspor tidak memakai konstruksi yang bermasalah', () {
    for (final preset in catalog) {
      final animation = ClipAnimationModel(
        presetId: preset.id,
        type: preset.type,
        duration: 1.0,
      );
      final filter = AnimationExportSupportService.buildExportFilter(
        animation,
        preset: preset,
        clipDuration: 5.0,
      );
      if (filter.isEmpty) continue;

      expect(
        filter.contains(r'$'),
        isFalse,
        reason: '${preset.id} menyisakan placeholder variabel Dart',
      );
      expect(
        filter.contains('zoompan'),
        isFalse,
        reason: '${preset.id} memakai zoompan yang mengubah fps/durasi',
      );
      expect(
        RegExp(r"gblur=sigma='[^']*t[^']*'").hasMatch(filter),
        isFalse,
        reason: '${preset.id} memakai ekspresi waktu pada gblur',
      );
    }
  });

  test(
    'preset built-in yang tidak punya filter khusus tetap mendapat fallback',
    () {
      final preset = AnimationBuiltinPresetsData.allPresets.firstWhere(
        (p) => p.id == 'trending_circle_iris_open',
      );
      final support = AnimationExportSupportService.resolve(preset);
      expect(support.mode, AnimationExportMode.previewOnly);

      final cinematic = AnimationPresetsData.allPresets.firstWhere(
        (p) => p.category == AnimationCategory.cinematic,
      );
      final cinematicSupport = AnimationExportSupportService.resolve(cinematic);
      expect(cinematicSupport.mode, AnimationExportMode.approximate);
      expect(
        AnimationExportSupportService.buildExportFilter(
          ClipAnimationModel(presetId: cinematic.id, type: cinematic.type),
          preset: cinematic,
          clipDuration: 5.0,
        ),
        isNotEmpty,
      );
    },
  );
}
