// Audit parity preview -> export untuk seluruh preset animasi.
//
// Jalankan: dart run tool/audit_export_parity.dart
// Output : tool/export_parity_report.csv
//
// Skrip ini TIDAK mengubah data apa pun. Ia hanya memanggil
// ClipAnimationModel.buildFFmpegFilter() untuk setiap preset, lalu
// mengklasifikasikan hasilnya menjadi:
//   full        -> punya filter ekspor eksplisit
//   approximate -> memakai filter fallback per keluarga animasi
//   previewOnly -> tidak punya padanan FFmpeg yang wajar
import 'dart:io';

import 'package:video_clipper_app/core/models/animation_model.dart';
import 'package:video_clipper_app/core/services/animation_builtin_presets_data.dart';
import 'package:video_clipper_app/core/services/animation_export_support.dart';
import 'package:video_clipper_app/core/services/animation_presets_data.dart';

void main() {
  final buffer = StringBuffer()
    ..writeln('id,name,category,type,source,mode,filter');

  final counts = <AnimationExportMode, int>{};
  final byCategory = <String, Map<AnimationExportMode, int>>{};

  final catalog = <String, AnimationPresetModel>{
    for (final preset in AnimationBuiltinPresetsData.allPresets)
      'builtin:${preset.id}': preset,
    for (final preset in AnimationPresetsData.allPresets)
      'library:${preset.id}': preset,
  };

  for (final entry in catalog.entries) {
    final source = entry.key.split(':').first;
    final preset = entry.value;
    final animation = ClipAnimationModel(
      presetId: preset.id,
      type: preset.type,
      duration: 1.0,
    );
    final support = AnimationExportSupportService.resolve(preset);
    final filter = support.mode == AnimationExportMode.previewOnly
        ? ''
        : AnimationExportSupportService.buildExportFilter(
            animation,
            preset: preset,
            clipDuration: 5.0,
          );

    counts[support.mode] = (counts[support.mode] ?? 0) + 1;
    byCategory
        .putIfAbsent(preset.category.name, () => {})
        .update(support.mode, (v) => v + 1, ifAbsent: () => 1);

    final safeFilter = filter.replaceAll('"', '""');
    buffer.writeln(
      '${preset.id},${preset.name},${preset.category.name},'
      '${preset.type.name},$source,${support.mode.name},"$safeFilter"',
    );
  }

  final file = File('tool/export_parity_report.csv');
  file.writeAsStringSync(buffer.toString());

  final total = catalog.length;
  stdout.writeln('Total preset: $total');
  for (final mode in AnimationExportMode.values) {
    final count = counts[mode] ?? 0;
    final percent = total == 0 ? 0 : (count * 100 / total).round();
    stdout.writeln('  ${mode.name.padRight(12)}: $count ($percent%)');
  }
  stdout.writeln('\nPer kategori:');
  final categories = byCategory.keys.toList()..sort();
  for (final category in categories) {
    final row = byCategory[category]!;
    final parts = AnimationExportMode.values
        .map((m) => '${m.name}=${row[m] ?? 0}')
        .join(', ');
    stdout.writeln('  ${category.padRight(10)}: $parts');
  }
  stdout.writeln('\nLaporan CSV: ${file.path}');

  final markdown = StringBuffer()
    ..writeln('# Laporan Parity Ekspor Animasi')
    ..writeln()
    ..writeln('Dibuat otomatis oleh `dart run tool/audit_export_parity.dart`.')
    ..writeln()
    ..writeln('| Mode | Jumlah | Persentase |')
    ..writeln('| --- | ---: | ---: |');
  for (final mode in AnimationExportMode.values) {
    final count = counts[mode] ?? 0;
    final percent = total == 0 ? 0 : (count * 100 / total).round();
    markdown.writeln('| ${mode.name} | $count | $percent% |');
  }

  markdown
    ..writeln()
    ..writeln('## Per kategori')
    ..writeln()
    ..writeln('| Kategori | full | approximate | previewOnly |')
    ..writeln('| --- | ---: | ---: | ---: |');
  for (final category in categories) {
    final row = byCategory[category]!;
    markdown.writeln(
      '| $category | ${row[AnimationExportMode.full] ?? 0} | '
      '${row[AnimationExportMode.approximate] ?? 0} | '
      '${row[AnimationExportMode.previewOnly] ?? 0} |',
    );
  }

  final previewOnly =
      catalog.values
          .where(
            (p) =>
                AnimationExportSupportService.resolve(p).mode ==
                AnimationExportMode.previewOnly,
          )
          .toList()
        ..sort((a, b) => a.category.name.compareTo(b.category.name));

  markdown
    ..writeln()
    ..writeln('## Preset yang hanya tampil di preview (${previewOnly.length})')
    ..writeln()
    ..writeln('Preset berikut ditandai di UI dan tidak dirender saat ekspor:')
    ..writeln();
  for (final preset in previewOnly) {
    markdown.writeln('- `${preset.id}` (${preset.category.name})');
  }

  final markdownFile = File('tool/export_parity_report.md');
  markdownFile.writeAsStringSync(markdown.toString());
  stdout.writeln('Laporan MD : ${markdownFile.path}');
}
