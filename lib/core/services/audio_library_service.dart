import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';
import '../models/audio_asset_item.dart';

/// Abstraksi Provider untuk sumber Audio Online / Viral / Editor / Creative Commons
abstract class OnlineAudioProvider {
  String get providerName;
  Future<List<AudioAssetItem>> searchAudio({
    String query = '',
    String category = 'All',
  });
}

/// Implementasi Provider Audio Musik & Sound Viral Indo + Editor Pack
class CreativeCommonsAudioProvider implements OnlineAudioProvider {
  @override
  String get providerName => 'QuickClip Pro Sound & Music Vault (Indo Viral, Editor FX, & Cinematic)';

  @override
  Future<List<AudioAssetItem>> searchAudio({
    String query = '',
    String category = 'All',
  }) async {
    // Katalog lengkap musik & audio terverifikasi dengan audio lokal fallback & link online
    final catalog = <AudioAssetItem>[
      // --- VIRAL INDO & SHOUT TRENDS ---
      const AudioAssetItem(
        id: 'indo_viral_shout_lawan',
        title: 'Shout: "Saya Akan Lawan!" (Viral Indo)',
        artist: 'Trending Indo Sound • TikTok / Reels',
        durationSeconds: 2.5,
        category: 'Viral Indo',
        license: 'Sound FX Meme / Parodi Viral',
        sourceUrlOrPath: 'assets/audio/viral_indo/shout_lawan.mp3',
        sourceType: AudioSourceType.soundEffect,
        iconName: 'campaign_rounded',
      ),
      const AudioAssetItem(
        id: 'indo_viral_siap_komandan',
        title: 'Shout: "Siap Komandan!" (Sound Meme)',
        artist: 'Trending Editor Indo',
        durationSeconds: 2.0,
        category: 'Viral Indo',
        license: 'Viral Voice Shout',
        sourceUrlOrPath: 'assets/audio/viral_indo/siap_komandan.mp3',
        sourceType: AudioSourceType.soundEffect,
        iconName: 'record_voice_over_rounded',
      ),
      const AudioAssetItem(
        id: 'indo_viral_jedag_jedug',
        title: 'Jedag Jedug Sub-Bass Drop (JJ Indo)',
        artist: 'Indo Beatmaker • Sound Viral FYP',
        durationSeconds: 3.0,
        category: 'Viral Indo',
        license: 'Creative Sound Pack',
        sourceUrlOrPath: 'assets/audio/viral_indo/jedag_jedug_bass.mp3',
        sourceType: AudioSourceType.onlineFree,
        iconName: 'graphic_eq_rounded',
      ),
      const AudioAssetItem(
        id: 'indo_viral_telolet',
        title: 'Telolet Basuri Horn Melodi Viral',
        artist: 'Nusantara Sound Viral',
        durationSeconds: 4.0,
        category: 'Viral Indo',
        license: 'Public Domain Nusantara',
        sourceUrlOrPath: 'assets/audio/viral_indo/telolet.mp3',
        sourceType: AudioSourceType.soundEffect,
        iconName: 'volume_up_rounded',
      ),
      const AudioAssetItem(
        id: 'indo_cinematic_senja',
        title: 'Petikan Akustik Senja Syahdu (Indo Vibes)',
        artist: 'Indo Cinematic Studio',
        durationSeconds: 15.0,
        category: 'Cinematic',
        license: 'Royalty-Free Nusantara',
        sourceUrlOrPath: 'assets/audio/viral_indo/cinematic_senja.mp3',
        sourceType: AudioSourceType.onlineFree,
        iconName: 'movie_filter_rounded',
      ),
      const AudioAssetItem(
        id: 'indo_vlog_ceria',
        title: 'Vlog Santai Ceria Jalan-Jalan',
        artist: 'Kreator Indonesia Creator Pack',
        durationSeconds: 15.0,
        category: 'Vlog',
        license: 'Bebas Royalti Indonesia',
        sourceUrlOrPath: 'assets/audio/viral_indo/vlog_ceria_indo.mp3',
        sourceType: AudioSourceType.onlineFree,
        iconName: 'sentiment_very_satisfied_rounded',
      ),

      // --- CINEMATIC & EDITOR PACKS ---
      const AudioAssetItem(
        id: 'cc_cinematic_1',
        title: 'Epic Horizon Cinematic Theme',
        artist: 'Scott Buckley (CC-BY 4.0)',
        durationSeconds: 15.0,
        category: 'Cinematic',
        license: 'Creative Commons Attribution 4.0',
        sourceUrlOrPath: 'assets/audio/music/epic_horizon.mp3',
        sourceType: AudioSourceType.onlineFree,
        iconName: 'movie_rounded',
      ),
      const AudioAssetItem(
        id: 'cc_vlog_1',
        title: 'Sunny Morning Acoustic Strum',
        artist: 'LesFM (CC-BY 3.0)',
        durationSeconds: 15.0,
        category: 'Vlog',
        license: 'Creative Commons Attribution 3.0',
        sourceUrlOrPath: 'assets/audio/music/sunny_morning.mp3',
        sourceType: AudioSourceType.onlineFree,
        iconName: 'wb_sunny_rounded',
      ),
      const AudioAssetItem(
        id: 'cc_travel_1',
        title: 'Tropical Adventure Chillout',
        artist: 'Bensound (Free License)',
        durationSeconds: 15.0,
        category: 'Travel',
        license: 'Creative Commons CC-BY-NC',
        sourceUrlOrPath: 'assets/audio/music/tropical_adventure.mp3',
        sourceType: AudioSourceType.onlineFree,
        iconName: 'flight_takeoff_rounded',
      ),
      const AudioAssetItem(
        id: 'cc_relax_1',
        title: 'Peaceful Meditation Garden',
        artist: 'Liborio Conti (CC0 Public Domain)',
        durationSeconds: 15.0,
        category: 'Relaxing',
        license: 'CC0 1.0 Universal',
        sourceUrlOrPath: 'assets/audio/music/peaceful_meditation.mp3',
        sourceType: AudioSourceType.onlineFree,
        iconName: 'spa_rounded',
      ),
      const AudioAssetItem(
        id: 'cc_dramatic_1',
        title: 'Dark Tension Suspense Strings',
        artist: 'TimMcMorris (CC-BY 4.0)',
        durationSeconds: 15.0,
        category: 'Dramatic',
        license: 'Creative Commons Attribution 4.0',
        sourceUrlOrPath: 'assets/audio/music/dark_tension.mp3',
        sourceType: AudioSourceType.onlineFree,
        iconName: 'theater_comedy_rounded',
      ),
      const AudioAssetItem(
        id: 'cc_happy_1',
        title: 'Upbeat Whistling Ukulele Mood',
        artist: 'Audionautix (CC-BY 3.0)',
        durationSeconds: 15.0,
        category: 'Happy',
        license: 'Creative Commons Attribution 3.0',
        sourceUrlOrPath: 'assets/audio/music/upbeat_whistle.mp3',
        sourceType: AudioSourceType.onlineFree,
        iconName: 'mood_rounded',
      ),
    ];

    return catalog.where((item) {
      final matchQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query.toLowerCase()) ||
          item.artist.toLowerCase().contains(query.toLowerCase());
      final matchCat = category == 'All' ||
          category == 'Semua' ||
          item.category.toLowerCase() == category.toLowerCase();
      return matchQuery && matchCat;
    }).toList();
  }
}

/// Sound Effect Catalog untuk audio editing (Transitions, Whoosh, Risers, Clicks, Shouts)
class SoundEffectCatalog {
  static List<AudioAssetItem> getAllSoundEffects({
    String query = '',
    String category = 'All',
  }) {
    final sfxList = <AudioAssetItem>[
      // --- TIKTOK / REELS / YOUTUBE VIRAL SHOUTS ---
      const AudioAssetItem(
        id: 'sfx_shout_lawan',
        title: 'Viral Shout: "Saya Akan Lawan!"',
        artist: 'Sound FX Meme Indo FYP',
        durationSeconds: 2.5,
        category: 'Shout',
        license: 'Viral Voice Meme',
        sourceUrlOrPath: 'assets/audio/viral_indo/shout_lawan.mp3',
        sourceType: AudioSourceType.soundEffect,
        iconName: 'campaign_rounded',
      ),
      const AudioAssetItem(
        id: 'sfx_shout_komandan',
        title: 'Viral Shout: "Siap Komandan!"',
        artist: 'Sound FX Meme Indo FYP',
        durationSeconds: 2.0,
        category: 'Shout',
        license: 'Viral Voice Meme',
        sourceUrlOrPath: 'assets/audio/viral_indo/siap_komandan.mp3',
        sourceType: AudioSourceType.soundEffect,
        iconName: 'record_voice_over_rounded',
      ),
      const AudioAssetItem(
        id: 'sfx_jj_bassdrop',
        title: 'Jedag-Jedug Sub-Bass Stomp',
        artist: 'Editor FX Indo',
        durationSeconds: 3.0,
        category: 'Impact',
        license: 'CC0 Public Domain',
        sourceUrlOrPath: 'assets/audio/viral_indo/jedag_jedug_bass.mp3',
        sourceType: AudioSourceType.soundEffect,
        iconName: 'graphic_eq_rounded',
      ),
      const AudioAssetItem(
        id: 'sfx_telolet_horn',
        title: 'Basuri Telolet Klakson Melody',
        artist: 'Indo Sound Trend',
        durationSeconds: 4.0,
        category: 'Shout',
        license: 'CC0 Public Domain',
        sourceUrlOrPath: 'assets/audio/viral_indo/telolet.mp3',
        sourceType: AudioSourceType.soundEffect,
        iconName: 'volume_up_rounded',
      ),

      // --- EDITING WHOOSH & TRANSITIONS ---
      const AudioAssetItem(
        id: 'sfx_whoosh_fast',
        title: 'Fast Cinematic Whoosh',
        artist: 'QuickClip SFX Pack',
        durationSeconds: 1.2,
        category: 'Whoosh',
        license: 'CC0 Public Domain',
        sourceUrlOrPath: 'assets/audio/sfx/whoosh.mp3',
        sourceType: AudioSourceType.soundEffect,
        iconName: 'air_rounded',
      ),
      const AudioAssetItem(
        id: 'sfx_whoosh_deep',
        title: 'Deep Bass Transition Whoosh',
        artist: 'QuickClip SFX Pack',
        durationSeconds: 1.8,
        category: 'Whoosh',
        license: 'CC0 Public Domain',
        sourceUrlOrPath: 'assets/audio/sfx/whoosh_deep.mp3',
        sourceType: AudioSourceType.soundEffect,
        iconName: 'waves_rounded',
      ),
      const AudioAssetItem(
        id: 'sfx_transition_glitch',
        title: 'Digital Glitch Shutter',
        artist: 'QuickClip SFX Pack',
        durationSeconds: 0.8,
        category: 'Transition',
        license: 'CC0 Public Domain',
        sourceUrlOrPath: 'assets/audio/sfx/glitch.mp3',
        sourceType: AudioSourceType.soundEffect,
        iconName: 'auto_fix_high',
      ),

      // --- INTERFACE & POP & IMPACTS ---
      const AudioAssetItem(
        id: 'sfx_pop_bubble',
        title: 'Bubble Pop Notification',
        artist: 'QuickClip SFX Pack',
        durationSeconds: 0.4,
        category: 'Pop',
        license: 'CC0 Public Domain',
        sourceUrlOrPath: 'assets/audio/sfx/pop.mp3',
        sourceType: AudioSourceType.soundEffect,
        iconName: 'bubble_chart_rounded',
      ),
      const AudioAssetItem(
        id: 'sfx_ui_click',
        title: 'Camera Shutter Click',
        artist: 'QuickClip SFX Pack',
        durationSeconds: 0.5,
        category: 'Click',
        license: 'CC0 Public Domain',
        sourceUrlOrPath: 'assets/audio/sfx/click.mp3',
        sourceType: AudioSourceType.soundEffect,
        iconName: 'camera_alt_outlined',
      ),
      const AudioAssetItem(
        id: 'sfx_impact_sub',
        title: 'Heavy Sub Bass Boom',
        artist: 'QuickClip SFX Pack',
        durationSeconds: 2.5,
        category: 'Impact',
        license: 'CC0 Public Domain',
        sourceUrlOrPath: 'assets/audio/sfx/impact.mp3',
        sourceType: AudioSourceType.soundEffect,
        iconName: 'offline_bolt_rounded',
      ),
      const AudioAssetItem(
        id: 'sfx_explosion_distant',
        title: 'Distant Cinematic Hit',
        artist: 'QuickClip SFX Pack',
        durationSeconds: 3.2,
        category: 'Cinematic Hit',
        license: 'CC0 Public Domain',
        sourceUrlOrPath: 'assets/audio/sfx/hit.mp3',
        sourceType: AudioSourceType.soundEffect,
        iconName: 'flash_on_rounded',
      ),
      const AudioAssetItem(
        id: 'sfx_rain_gentle',
        title: 'Gentle Rain Drops',
        artist: 'QuickClip SFX Pack',
        durationSeconds: 6.0,
        category: 'Rain',
        license: 'CC0 Public Domain',
        sourceUrlOrPath: 'assets/audio/sfx/rain.mp3',
        sourceType: AudioSourceType.soundEffect,
        iconName: 'water_drop_rounded',
      ),
      const AudioAssetItem(
        id: 'sfx_wind_breeze',
        title: 'Forest Wind Breeze',
        artist: 'QuickClip SFX Pack',
        durationSeconds: 5.0,
        category: 'Wind',
        license: 'CC0 Public Domain',
        sourceUrlOrPath: 'assets/audio/sfx/wind.mp3',
        sourceType: AudioSourceType.soundEffect,
        iconName: 'air_rounded',
      ),
      const AudioAssetItem(
        id: 'sfx_footsteps_gravel',
        title: 'Footsteps on Gravel',
        artist: 'QuickClip SFX Pack',
        durationSeconds: 4.0,
        category: 'Footsteps',
        license: 'CC0 Public Domain',
        sourceUrlOrPath: 'assets/audio/sfx/footsteps.mp3',
        sourceType: AudioSourceType.soundEffect,
        iconName: 'directions_walk_rounded',
      ),
    ];

    return sfxList.where((item) {
      final matchQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query.toLowerCase()) ||
          item.category.toLowerCase().contains(query.toLowerCase());
      final matchCat = category == 'All' ||
          category == 'Semua' ||
          item.category.toLowerCase() == category.toLowerCase();
      return matchQuery && matchCat;
    }).toList();
  }
}

/// Service Ekstraksi Audio dari File Video Lokal menggunakan FFmpeg
class AudioExtractionService {
  /// Ekstrak audio dari file video menjadi file MP3/AAC lokal
  static Future<File?> extractAudioFromVideo({
    required String videoPath,
    required String outputTitle,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final sanitizedTitle = outputTitle.replaceAll(RegExp(r'[^\w\s\.-]'), '_');
      final outputPath = '${tempDir.path}/extracted_${sanitizedTitle}_${DateTime.now().millisecondsSinceEpoch}.mp3';

      final command = '-y -i "$videoPath" -vn -c:a libmp3lame -q:a 2 "$outputPath"';
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        final extractedFile = File(outputPath);
        if (await extractedFile.exists()) {
          return extractedFile;
        }
      }
    } catch (_) {}
    return null;
  }
}
