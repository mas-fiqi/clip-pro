/// Tipe sumber audio
enum AudioSourceType {
  local,
  onlineFree,
  soundEffect,
  recording,
  extracted,
}

/// Metadata item audio untuk Library & SFX
class AudioAssetItem {
  final String id;
  final String title;
  final String artist;
  final double durationSeconds;
  final String category;
  final String license; // misal "Creative Commons CC0", "CC-BY 4.0", "Public Domain"
  final String sourceUrlOrPath;
  final AudioSourceType sourceType;
  final String? iconName;
  final bool isDownloaded;

  const AudioAssetItem({
    required this.id,
    required this.title,
    this.artist = 'QuickClip Audio Library',
    required this.durationSeconds,
    required this.category,
    this.license = 'Creative Commons CC0',
    required this.sourceUrlOrPath,
    required this.sourceType,
    this.iconName,
    this.isDownloaded = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'durationSeconds': durationSeconds,
      'category': category,
      'license': license,
      'sourceUrlOrPath': sourceUrlOrPath,
      'sourceType': sourceType.name,
      'iconName': iconName,
      'isDownloaded': isDownloaded,
    };
  }

  factory AudioAssetItem.fromJson(Map<String, dynamic> json) {
    return AudioAssetItem(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String? ?? 'QuickClip Audio Library',
      durationSeconds: (json['durationSeconds'] as num).toDouble(),
      category: json['category'] as String,
      license: json['license'] as String? ?? 'Creative Commons CC0',
      sourceUrlOrPath: json['sourceUrlOrPath'] as String,
      sourceType: AudioSourceType.values.firstWhere(
        (e) => e.name == json['sourceType'],
        orElse: () => AudioSourceType.local,
      ),
      iconName: json['iconName'] as String?,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
    );
  }
}

