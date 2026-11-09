import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'export_config_model.dart';

/// Catatan hasil benchmark lokal per sesi
class BenchmarkRecord {
  final String encoder; // 'h264_mediacodec' / 'libx264'
  final ExportResolutionPreset resolution;
  final int fps;
  final double sampleDurationSeconds;
  final int executionTimeMs;
  final int outputSizeBytes;
  final bool isSuccess;
  final DateTime timestamp;
  final String? errorMessage;

  const BenchmarkRecord({
    required this.encoder,
    required this.resolution,
    required this.fps,
    required this.sampleDurationSeconds,
    required this.executionTimeMs,
    required this.outputSizeBytes,
    required this.isSuccess,
    required this.timestamp,
    this.errorMessage,
  });

  /// Rasio kecepatan relatif (Waktu ekspor per detik video)
  double get speedFactor {
    if (sampleDurationSeconds <= 0) return 0;
    return (executionTimeMs / 1000.0) / sampleDurationSeconds;
  }

  Map<String, dynamic> toJson() {
    return {
      'encoder': encoder,
      'resolution': resolution.name,
      'fps': fps,
      'sampleDurationSeconds': sampleDurationSeconds,
      'executionTimeMs': executionTimeMs,
      'outputSizeBytes': outputSizeBytes,
      'isSuccess': isSuccess,
      'timestamp': timestamp.toIso8601String(),
      'errorMessage': errorMessage,
    };
  }

  factory BenchmarkRecord.fromJson(Map<String, dynamic> json) {
    return BenchmarkRecord(
      encoder: json['encoder'] as String? ?? 'unknown',
      resolution: ExportResolutionPreset.values.firstWhere(
        (e) => e.name == json['resolution'],
        orElse: () => ExportResolutionPreset.res720p,
      ),
      fps: json['fps'] as int? ?? 30,
      sampleDurationSeconds: (json['sampleDurationSeconds'] as num?)?.toDouble() ?? 5.0,
      executionTimeMs: json['executionTimeMs'] as int? ?? 0,
      outputSizeBytes: json['outputSizeBytes'] as int? ?? 0,
      isSuccess: json['isSuccess'] as bool? ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      errorMessage: json['errorMessage'] as String?,
    );
  }
}

/// Profil kumpulan benchmark lokal perangkat
class BenchmarkProfile {
  static const String fileName = 'quickclip_benchmark_profile.json';
  final List<BenchmarkRecord> records;

  BenchmarkProfile({List<BenchmarkRecord>? records}) : records = records ?? [];

  void addRecord(BenchmarkRecord record) {
    records.removeWhere((r) =>
        r.encoder == record.encoder &&
        r.resolution == record.resolution &&
        r.fps == record.fps);
    records.add(record);
  }

  BenchmarkRecord? getRecord({
    required String encoder,
    required ExportResolutionPreset resolution,
    required int fps,
  }) {
    try {
      return records.firstWhere((r) =>
          r.encoder == encoder &&
          r.resolution == resolution &&
          r.fps == fps &&
          r.isSuccess);
    } catch (_) {
      return null;
    }
  }

  /// Menentukan apakah software atau hardware lebih cepat untuk resolusi tertentu
  /// Mengembalikan: 'software', 'hardware', atau null (jika belum ada data komparatif)
  String? getFasterEncoder({
    required ExportResolutionPreset resolution,
    required int fps,
  }) {
    final hw = getRecord(encoder: 'h264_mediacodec', resolution: resolution, fps: fps);
    final sw = getRecord(encoder: 'libx264', resolution: resolution, fps: fps);

    if (hw == null || sw == null) return null;
    return (sw.executionTimeMs <= hw.executionTimeMs) ? 'software' : 'hardware';
  }

  Map<String, dynamic> toJson() {
    return {
      'records': records.map((e) => e.toJson()).toList(),
    };
  }

  factory BenchmarkProfile.fromJson(Map<String, dynamic> json) {
    final list = json['records'] as List<dynamic>? ?? [];
    return BenchmarkProfile(
      records: list.map((e) => BenchmarkRecord.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    );
  }

  /// Membaca profil dari penyimpanan lokal
  static Future<BenchmarkProfile> load() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        return BenchmarkProfile.fromJson(json);
      }
    } catch (_) {}
    return BenchmarkProfile();
  }

  /// Menyimpan profil ke file lokal
  Future<void> save() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      final content = jsonEncode(toJson());
      await file.writeAsString(content);
    } catch (_) {}
  }

  /// Menghapus data profil
  Future<void> clear() async {
    records.clear();
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}

