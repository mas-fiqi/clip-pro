import 'dart:convert';
import 'timeline_model.dart';

enum CanvasAspectRatio {
  original,
  ratio16x9,
  ratio9x16,
  ratio1x1,
  ratio4x5,
}

enum ExportResolution {
  res480p,
  res720p,
  res1080p,
  res4k,
}

/// Versi skema penyimpanan proyek lokal saat ini
const int kCurrentProjectSchemaVersion = 1;

/// Model representasi proyek editing QuickClip Pro yang persisten
class ProjectModel {
  final String id;
  final String name;
  final CanvasAspectRatio aspectRatio;
  final ExportResolution resolution;
  final TimelineModel timeline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int schemaVersion;
  final String? customThumbnailPath;

  ProjectModel({
    required this.id,
    required this.name,
    this.aspectRatio = CanvasAspectRatio.ratio16x9,
    this.resolution = ExportResolution.res720p,
    TimelineModel? timeline,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.schemaVersion = kCurrentProjectSchemaVersion,
    this.customThumbnailPath,
  })  : timeline = timeline ?? TimelineModel(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  ProjectModel copyWith({
    String? id,
    String? name,
    CanvasAspectRatio? aspectRatio,
    ExportResolution? resolution,
    TimelineModel? timeline,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? schemaVersion,
    String? customThumbnailPath,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      resolution: resolution ?? this.resolution,
      timeline: timeline ?? this.timeline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      schemaVersion: schemaVersion ?? this.schemaVersion,
      customThumbnailPath: customThumbnailPath ?? this.customThumbnailPath,
    );
  }

  /// Total durasi timeline dalam detik
  double get totalDurationSeconds => timeline.totalDuration;

  /// Hitung daftar file sumber eksternal (video & audio)
  List<String> get referencedMediaPaths {
    final paths = <String>{};
    for (final clip in timeline.clips) {
      if (clip.sourcePath.isNotEmpty) paths.add(clip.sourcePath);
    }
    for (final audio in timeline.audioClips) {
      if (audio.sourcePath.isNotEmpty) paths.add(audio.sourcePath);
    }
    return paths.toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'aspectRatio': aspectRatio.name,
      'resolution': resolution.name,
      'timeline': timeline.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'schemaVersion': schemaVersion,
      if (customThumbnailPath != null) 'customThumbnailPath': customThumbnailPath,
    };
  }

  factory ProjectModel.fromJson(Map<String, dynamic> rawJson) {
    // Migration check & backward compatibility
    final json = ProjectMigration.migrate(rawJson);

    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      aspectRatio: CanvasAspectRatio.values.firstWhere(
        (e) => e.name == json['aspectRatio'],
        orElse: () => CanvasAspectRatio.ratio16x9,
      ),
      resolution: ExportResolution.values.firstWhere(
        (e) => e.name == json['resolution'],
        orElse: () => ExportResolution.res720p,
      ),
      timeline: TimelineModel.fromJson(json['timeline'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
      customThumbnailPath: json['customThumbnailPath'] as String?,
    );
  }

  String toRawJson() => jsonEncode(toJson());

  factory ProjectModel.fromRawJson(String str) =>
      ProjectModel.fromJson(jsonDecode(str) as Map<String, dynamic>);
}

/// Mekanisme migrasi skema proyek jika struktur berubah di masa mendatang
class ProjectMigration {
  static Map<String, dynamic> migrate(Map<String, dynamic> json) {
    final rawVersion = json['schemaVersion'];
    int version = (rawVersion is num) ? rawVersion.toInt() : 0;

    var migrated = Map<String, dynamic>.from(json);

    // Legacy schema version 0 (proyek awal tanpa schemaVersion)
    if (version == 0) {
      migrated['schemaVersion'] = 1;
      // Memastikan struktur timeline tersedia
      if (!migrated.containsKey('timeline') || migrated['timeline'] == null) {
        migrated['timeline'] = {'clips': [], 'overlays': [], 'audioClips': []};
      }
      version = 1;
    }

    return migrated;
  }
}
