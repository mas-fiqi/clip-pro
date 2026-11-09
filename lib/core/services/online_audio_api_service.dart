import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/audio_asset_item.dart';

/// Service untuk memanggil API musik gratis (iTunes Apple Search API)
/// dan API Efek Suara Viral (MyInstants Meme & Sound FX API)
class OnlineAudioApiService {
  static final OnlineAudioApiService _instance = OnlineAudioApiService._internal();
  factory OnlineAudioApiService() => _instance;
  OnlineAudioApiService._internal();

  /// 1. Cari musik secara real-time dari jutaan katalog musik gratis (iTunes Search API)
  /// Mendukung pencarian lagu viral Indo, artis ternama, lagu barat, k-pop, vlog, dll.
  Future<List<AudioAssetItem>> searchMusic({
    required String query,
    int limit = 30,
  }) async {
    final searchTerm = query.trim().isEmpty ? 'indonesia viral' : query.trim();
    final url = Uri.parse(
      'https://itunes.apple.com/search?term=${Uri.encodeComponent(searchTerm)}&entity=song&limit=$limit',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];

        final items = <AudioAssetItem>[];
        for (final r in results) {
          final previewUrl = r['previewUrl'] as String?;
          if (previewUrl == null || previewUrl.isEmpty) continue;

          final trackName = r['trackName'] as String? ?? 'Musik Tanpa Judul';
          final artistName = r['artistName'] as String? ?? 'Artis';
          final primaryGenre = r['primaryGenreName'] as String? ?? 'Pop';
          final millis = r['trackTimeMillis'] as int? ?? 180000;
          final durationSecs = (millis / 1000.0).clamp(15.0, 360.0);

          items.add(
            AudioAssetItem(
              id: 'itunes_${r['trackId'] ?? DateTime.now().millisecondsSinceEpoch}',
              title: trackName,
              artist: '$artistName • $primaryGenre',
              durationSeconds: durationSecs,
              category: primaryGenre,
              license: 'Free Stream Preview',
              sourceUrlOrPath: previewUrl,
              sourceType: AudioSourceType.onlineFree,
              iconName: 'music_note_rounded',
            ),
          );
        }
        return items;
      }
    } catch (e) {
      debugPrint('Online Music Search Error: $e');
    }
    return [];
  }

  /// 2. Cari sound effect & shout viral langsung dari Web API (MyInstants API)
  /// Menyediakan suara asli meme, shout viral ("Saya akan lawan", basuri, anime wow, vine boom, dll.)
  Future<List<AudioAssetItem>> searchViralSounds({
    required String query,
  }) async {
    final searchParam = query.trim().isEmpty ? 'indonesia' : query.trim();
    final url = Uri.parse(
      'https://www.myinstants.com/api/v1/instants/?name=${Uri.encodeComponent(searchParam)}',
    );

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];

        final items = <AudioAssetItem>[];
        for (final r in results) {
          final soundUrl = r['sound'] as String?;
          if (soundUrl == null || soundUrl.isEmpty) continue;

          final name = r['name'] as String? ?? 'Sound Effect';

          items.add(
            AudioAssetItem(
              id: 'viral_sound_${r['slug'] ?? DateTime.now().millisecondsSinceEpoch}',
              title: name,
              artist: 'Web Viral Sound • MyInstants',
              durationSeconds: 3.0,
              category: 'Viral Web',
              license: 'Public Sound FX',
              sourceUrlOrPath: soundUrl,
              sourceType: AudioSourceType.soundEffect,
              iconName: 'campaign_rounded',
            ),
          );
        }
        return items;
      }
    } catch (e) {
      debugPrint('Online Viral Sound Search Error: $e');
    }
    return [];
  }
}
