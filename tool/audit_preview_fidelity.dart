// Audit kesesuaian preview animasi dengan nama efek.
//
// Jalankan: dart run tool/audit_preview_fidelity.dart
//
// Tool ini mengevaluasi setiap preset pada beberapa titik waktu, lalu:
// 1. menghitung berapa preset yang punya logika preview eksplisit vs generik;
// 2. mendeteksi preset yang preview-nya tidak bergerak sama sekali;
// 3. membandingkan kata kunci nama/ID dengan sinyal transformasi yang muncul;
// 4. menghitung jumlah "gaya preview" unik (behavioral fingerprint);
// 5. memeriksa duplikasi ID/nama dan cakupan kategori.
import 'dart:io';

import 'package:video_clipper_app/core/models/animation_model.dart';
import 'package:video_clipper_app/core/services/animation_builtin_presets_data.dart';
import 'package:video_clipper_app/core/services/animation_presets_data.dart';

const _samples = <double>[0.08, 0.2, 0.35, 0.5, 0.65, 0.8, 0.95];

class _Result {
  _Result(this.preset);

  final AnimationPresetModel preset;
  final List<AnimationTransformResult> frames = [];
  final List<String> mismatches = [];
  bool explicitCase = false;
  String fingerprint = '';
  bool allDefault = false;
}

void main() {
  final builtin = AnimationBuiltinPresetsData.allPresets;
  final library = AnimationPresetsData.allPresets;
  final all = <AnimationPresetModel>[...builtin, ...library];

  final explicitIds = _readExplicitPreviewIds();
  final idCounts = <String, int>{};
  final nameCounts = <String, int>{};
  for (final preset in all) {
    idCounts[preset.id] = (idCounts[preset.id] ?? 0) + 1;
    nameCounts[preset.name] = (nameCounts[preset.name] ?? 0) + 1;
  }

  final results = <_Result>[];
  for (final preset in all) {
    final r = _Result(preset)..explicitCase = explicitIds.contains(preset.id);
    for (final t in _samples) {
      final model = ClipAnimationModel(
        presetId: preset.id,
        type: preset.type,
        duration: 1.0,
        intensity: 1.0,
      );
      r.frames.add(model.evaluate(timeInClip: t, totalClipDuration: 1.0));
    }
    r.allDefault = r.frames.every(_isDefault);
    r.fingerprint = _fingerprint(r.frames);
    r.mismatches.addAll(_checkSemantics(preset, r.frames));
    results.add(r);
  }

  final explicit = results.where((r) => r.explicitCase).length;
  final fallback = results.length - explicit;
  final allDefault = results.where((r) => r.allDefault).toList();
  final mismatched = results.where((r) => r.mismatches.isNotEmpty).toList();

  final groups = <String, List<String>>{};
  for (final r in results) {
    groups.putIfAbsent(r.fingerprint, () => []).add(r.preset.id);
  }
  final sortedGroups = groups.entries.toList()
    ..sort((a, b) => b.value.length.compareTo(a.value.length));

  final duplicateIds = idCounts.entries.where((e) => e.value > 1).toList();
  final duplicateNames = nameCounts.entries.where((e) => e.value > 1).toList();

  final byCategory = <String, int>{};
  final byType = <String, int>{};
  for (final p in all) {
    byCategory[p.category.name] = (byCategory[p.category.name] ?? 0) + 1;
    byType[p.type.name] = (byType[p.type.name] ?? 0) + 1;
  }

  final buffer = StringBuffer()
    ..writeln('# Audit Fidelity Preview Animasi')
    ..writeln()
    ..writeln('Dibuat: ${DateTime.now().toIso8601String()}')
    ..writeln()
    ..writeln('## Ringkasan')
    ..writeln()
    ..writeln('| Metrik | Nilai |')
    ..writeln('|---|---:|')
    ..writeln('| Total preset | ${all.length} |')
    ..writeln('| Preset built-in | ${builtin.length} |')
    ..writeln('| Preset library | ${library.length} |')
    ..writeln('| ID unik | ${idCounts.length} |')
    ..writeln('| Nama unik | ${nameCounts.length} |')
    ..writeln('| Preview eksplisit (case khusus) | $explicit |')
    ..writeln('| Preview generik (fallback kategori) | $fallback |')
    ..writeln('| Transformasi statis (di luar overlay painter) | ${allDefault.length} |')
    ..writeln('| Kandidat nama vs preview tidak cocok (heuristik) | ${mismatched.length} |')
    ..writeln('| Gaya preview unik (fingerprint) | ${groups.length} |')
    ..writeln('| ID duplikat | ${duplicateIds.length} |')
    ..writeln('| Nama duplikat | ${duplicateNames.length} |')
    ..writeln()
    ..writeln('## Distribusi kategori & tipe')
    ..writeln()
    ..writeln('| Kategori | Jumlah |')
    ..writeln('|---|---:|');
  for (final e in byCategory.entries) {
    buffer.writeln('| ${e.key} | ${e.value} |');
  }
  buffer
    ..writeln()
    ..writeln('| Tipe deklarasi | Jumlah |')
    ..writeln('|---|---:|');
  for (final e in byType.entries) {
    buffer.writeln('| ${e.key} | ${e.value} |');
  }

  buffer
    ..writeln()
    ..writeln('## Preset dengan transformasi statis (${allDefault.length})')
    ..writeln()
    ..writeln(
      'Catatan: widget preview juga menggambar overlay `TrendingVisualEffectPainter` '
      'dan `GlitchVisualEffectPainter`, sehingga transformasi statis belum tentu '
      'berarti preview benar-benar diam.',
    )
    ..writeln();
  if (allDefault.isEmpty) {
    buffer.writeln('Tidak ada.');
  } else {
    for (final r in allDefault) {
      buffer.writeln('- `${r.preset.id}` — ${r.preset.name}');
    }
  }

  buffer
    ..writeln()
    ..writeln('## Kandidat nama vs preview tidak cocok (${mismatched.length})')
    ..writeln()
    ..writeln(
      'Heuristik kata kunci pada ID/nama versus sinyal transformasi. Angka ini '
      'adalah kandidat untuk dicek visual, bukan vonis otomatis.',
    )
    ..writeln()
    ..writeln('Format: `id` — nama — sinyal yang diharapkan tetapi tidak muncul.');
  for (final r in mismatched.take(120)) {
    buffer.writeln(
      '- `${r.preset.id}` — ${r.preset.name} — ${r.mismatches.join(', ')}',
    );
  }
  if (mismatched.length > 120) {
    buffer.writeln('- ... dan ${mismatched.length - 120} lainnya (lihat CSV)');
  }

  buffer
    ..writeln()
    ..writeln('## Gaya preview paling banyak dipakai bersama')
    ..writeln()
    ..writeln('| Jumlah preset | Contoh ID |')
    ..writeln('|---:|---|');
  for (final e in sortedGroups.take(15)) {
    buffer.writeln('| ${e.value.length} | `${e.value.take(6).join('`, `')}` |');
  }

  buffer
    ..writeln()
    ..writeln('## Duplikasi')
    ..writeln();
  if (duplicateIds.isEmpty) {
    buffer.writeln('ID duplikat: tidak ada.');
  } else {
    for (final e in duplicateIds) {
      buffer.writeln('- ID `${e.key}` muncul ${e.value} kali');
    }
  }
  if (duplicateNames.isEmpty) {
    buffer.writeln('Nama duplikat: tidak ada.');
  } else {
    buffer.writeln();
    for (final e in duplicateNames) {
      buffer.writeln('- Nama "${e.key}" muncul ${e.value} kali');
    }
  }

  final csv = StringBuffer()
    ..writeln('id,name,category,type,explicit,all_default,fingerprint,mismatch');
  for (final r in results) {
    csv.writeln(
      [
        r.preset.id,
        r.preset.name,
        r.preset.category.name,
        r.preset.type.name,
        r.explicitCase,
        r.allDefault,
        r.fingerprint,
        r.mismatches.join('|'),
      ].map(_csv).join(','),
    );
  }

  File('tool/preview_fidelity_report.md').writeAsStringSync(buffer.toString());
  File('tool/preview_fidelity_report.csv').writeAsStringSync(csv.toString());

  stdout
    ..writeln('Total: ${all.length}')
    ..writeln('Eksplisit: $explicit | Generik: $fallback')
    ..writeln('Transformasi statis: ${allDefault.length}')
    ..writeln('Kandidat mismatch nama: ${mismatched.length}')
    ..writeln('Gaya unik: ${groups.length}')
    ..writeln('ID duplikat: ${duplicateIds.length} | Nama duplikat: ${duplicateNames.length}');
  stdout.writeln('Laporan: tool/preview_fidelity_report.md');
}

Set<String> _readExplicitPreviewIds() {
  final source = File('lib/core/models/animation_model.dart').readAsStringSync();
  final start = source.indexOf('static AnimationTransformResult _computePresetTransform');
  final end = source.indexOf(
    'static AnimationTransformResult _evaluateDynamicPresetByCategory',
  );
  if (start < 0 || end < 0 || end <= start) {
    throw StateError('Blok evaluator preview tidak ditemukan.');
  }
  final block = source.substring(start, end);
  return RegExp(r"case '([^']+)'")
      .allMatches(block)
      .map((m) => m.group(1)!)
      .toSet();
}

String _fingerprint(List<AnimationTransformResult> frames) {
  final flags = <String>[];
  for (final r in frames) {
    flags
      ..add((r.scale - 1).abs() > 0.02 ? 'S' : '-')
      ..add(r.positionX.abs() > 0.01 ? 'X' : '-')
      ..add(r.positionY.abs() > 0.01 ? 'Y' : '-')
      ..add(r.rotationDegrees.abs() > 1 ? 'R' : '-')
      ..add(r.rotateXDegrees.abs() > 1 ? 'P' : '-')
      ..add(r.rotateYDegrees.abs() > 1 ? 'W' : '-')
      ..add(r.opacity < 0.97 ? 'O' : '-')
      ..add(r.blurRadius > 0.2 ? 'B' : '-')
      ..add(r.flashOpacity > 0.02 ? 'F' : '-')
      ..add(r.colorOverlayOpacity > 0.02 ? 'C' : '-')
      ..add(r.chromaticAberration > 0.005 ? 'A' : '-')
      ..add(r.scanlineIntensity > 0.02 ? 'L' : '-')
      ..add(r.clipShape == AnimationClipShape.none ? '-' : 'K');
  }
  return flags.join('|');
}

bool _isDefault(AnimationTransformResult r) =>
    (r.scale - 1).abs() < 0.001 &&
    (r.scaleX - 1).abs() < 0.001 &&
    (r.scaleY - 1).abs() < 0.001 &&
    r.positionX.abs() < 0.001 &&
    r.positionY.abs() < 0.001 &&
    r.rotationDegrees.abs() < 0.001 &&
    r.rotateXDegrees.abs() < 0.001 &&
    r.rotateYDegrees.abs() < 0.001 &&
    (r.opacity - 1).abs() < 0.001 &&
    r.blurRadius < 0.001 &&
    r.flashOpacity < 0.001 &&
    r.colorOverlayOpacity < 0.001 &&
    r.chromaticAberration < 0.001 &&
    r.scanlineIntensity < 0.001 &&
    r.clipShape == AnimationClipShape.none;

bool _has(List<AnimationTransformResult> frames, bool Function(AnimationTransformResult) test) =>
    frames.any(test);

List<String> _checkSemantics(
  AnimationPresetModel preset,
  List<AnimationTransformResult> frames,
) {
  final haystack = '${preset.id} ${preset.name}'.toLowerCase();
  final out = <String>[];

  bool hasAny(String keys) {
    for (final key in keys.split('|')) {
      if (key.isEmpty) continue;
      // Kata pendek seperti "pan", "3d", dan "crt" harus cocok sebagai kata,
      // bukan substring (mis. "Letupan" bukan "pan").
      if (key.length <= 3) {
        final pattern = RegExp(
          '(^|[^a-z])${RegExp.escape(key)}([^a-z]|\$)',
        );
        if (pattern.hasMatch(haystack)) return true;
      } else if (haystack.contains(key)) {
        return true;
      }
    }
    return false;
  }

  final scaleChanged = _has(
    frames,
    (r) =>
        (r.scale - 1).abs() > 0.02 ||
        (r.scaleX - 1).abs() > 0.02 ||
        (r.scaleY - 1).abs() > 0.02,
  );
  final moved = _has(frames, (r) => r.positionX.abs() > 0.01 || r.positionY.abs() > 0.01);
  final rotated = _has(
    frames,
    (r) =>
        r.rotationDegrees.abs() > 1 ||
        r.rotateXDegrees.abs() > 1 ||
        r.rotateYDegrees.abs() > 1,
  );
  final faded = _has(
    frames,
    (r) => r.opacity < 0.97 || r.colorOverlayOpacity > 0.02,
  );
  final blurred = _has(frames, (r) => r.blurRadius > 0.2);
  final clipped = _has(frames, (r) => r.clipShape != AnimationClipShape.none);
  final glitched = _has(
    frames,
    (r) => r.chromaticAberration > 0.005 || r.scanlineIntensity > 0.02,
  );
  final flashed = _has(
    frames,
    (r) => r.flashOpacity > 0.02 || r.colorOverlayOpacity > 0.02,
  );
  final depth3d = _has(
    frames,
    (r) =>
        r.rotateXDegrees.abs() > 1 ||
        r.rotateYDegrees.abs() > 1 ||
        (r.perspective - 0.0015).abs() > 0.0001,
  );
  final retro = _has(
    frames,
    (r) => r.scanlineIntensity > 0.02 || (r.opacity - 1).abs() > 0.02,
  );

  if (hasAny('zoom|scale|skala|pembesaran|perbesar|membesar') && !scaleChanged) {
    out.add('zoom/scale');
  }
  if (hasAny('shake|getar|goyang|guncang|gemetar|jolt|rumble') &&
      !(moved || rotated)) {
    out.add('shake');
  }
  if (hasAny('rotate|rotasi|spin|putar|berputar') && !rotated) {
    out.add('rotate');
  }
  if (hasAny('slide|geser|meluncur|whip|sweep|pan') && !(moved || clipped)) {
    out.add('slide/pan');
  }
  if (hasAny('fade|pudar|memudar') && !faded) {
    out.add('fade');
  }
  if (hasAny('blur|buram') && !blurred) {
    out.add('blur');
  }
  // "RGB split" / "chromatic split" adalah pemisahan warna, bukan clipping.
  final rgbStyle = hasAny('rgb|chroma');
  if (hasAny('wipe|iris|sapuan|curtain|tirai|split|blinds|checker|mask') &&
      !clipped &&
      !rgbStyle) {
    out.add('mask/wipe');
  }
  if (hasAny('glitch|rgb|scanline|noise|pixel|corrupt|datamosh') &&
      !(glitched || moved)) {
    out.add('glitch');
  }
  if (hasAny('flash|kilat|cahaya|glow|flare|leak|strobe|lightning') &&
      !flashed) {
    out.add('flash/light');
  }
  if (hasAny('3d|kubus|cube|perspective|perspektif|depth|kedalaman') &&
      !depth3d) {
    out.add('3d/depth');
  }
  if (hasAny('retro|vintage|vhs|film|8mm|16mm|crt|tape') && !retro) {
    out.add('retro/vhs');
  }
  return out;
}

String _csv(Object? value) {
  final text = '${value ?? ''}';
  if (!text.contains(',') && !text.contains('"') && !text.contains('\n')) {
    return text;
  }
  return '"${text.replaceAll('"', '""')}"';
}
