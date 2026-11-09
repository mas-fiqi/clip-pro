import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_effect_model.dart';

/// Item Efek AI Cloud / Online
class AiCloudEffectItem {
  final String id;
  final String name;
  final String category; // 'Efek video', 'Efek tubuh', 'Efek foto', 'Efek AI', 'B.Duck', 'Halloween'
  final String subCategory;
  final String description;
  final String previewImageUrl;
  final EffectType fallbackType;
  final String promptStyle;

  const AiCloudEffectItem({
    required this.id,
    required this.name,
    required this.category,
    this.subCategory = 'Umum',
    required this.description,
    required this.previewImageUrl,
    required this.fallbackType,
    required this.promptStyle,
  });
}

/// Service untuk memanggil API AI Video Effect Catalog & Presets
/// Mendukung: Efek video, Efek tubuh (Body FX), Efek foto (Photo FX), dan Efek AI (AI Generative)
class OnlineAiEffectApiService {
  static final OnlineAiEffectApiService _instance = OnlineAiEffectApiService._internal();
  factory OnlineAiEffectApiService() => _instance;
  OnlineAiEffectApiService._internal();

  /// Daftar preset Bawaan Lengkap Berdasarkan Mode CapCut
  static final List<AiCloudEffectItem> defaultAiEffects = [
    // --- 1. EFEK TUBUH (BODY EFFECTS) ---
    const AiCloudEffectItem(
      id: 'body_laser_eyes',
      name: 'Mata Laser Neon',
      category: 'Efek tubuh',
      subCategory: 'Kepala & Mata',
      description: 'Sinar laser menyala dari mata mengikuti gerakan kepala dan pandangan',
      previewImageUrl: 'assets/images/effect_previews/body_laser_eyes.jpg',
      fallbackType: EffectType.cyberpunkGlow,
      promptStyle: 'cyber laser glowing eyes, sci-fi energy beam, body tracking',
    ),
    const AiCloudEffectItem(
      id: 'body_angel_wings',
      name: 'Sayap Malaikat Bercahaya',
      category: 'Efek tubuh',
      subCategory: 'Aura Tubuh',
      description: 'Sayap pendar neon putih lembut melayang di punggung mengikuti pose tubuh',
      previewImageUrl: 'assets/images/effect_previews/body_wings.jpg',
      fallbackType: EffectType.glowAura,
      promptStyle: 'ethereal luminous angel wings, soft feathered glow, full body aura',
    ),
    const AiCloudEffectItem(
      id: 'body_electric_aura',
      name: 'Aura Listrik Kilat',
      category: 'Efek tubuh',
      subCategory: 'Aura Tubuh',
      description: 'Percikan petir listrik biru cyan menyelimuti seluruh siluet tubuh',
      previewImageUrl: 'assets/images/effect_previews/body_light_glow.jpg',
      fallbackType: EffectType.speedLines,
      promptStyle: 'super saiyan blue lightning aura, electric sparks surrounding body',
    ),
    const AiCloudEffectItem(
      id: 'body_slim_silhouette',
      name: 'Kontur Tubuh Estetik',
      category: 'Efek tubuh',
      subCategory: 'Bentuk Tubuh',
      description: 'Penyempurnaan proporsi tubuh ramping & garis lekuk atletis',
      previewImageUrl: 'assets/images/effect_previews/body_slim.jpg',
      fallbackType: EffectType.edgeEnhance,
      promptStyle: 'fit slim aesthetic body contour, flattering soft focus edges',
    ),
    const AiCloudEffectItem(
      id: 'body_neon_trace',
      name: 'Garis Neon Gerak Tubuh',
      category: 'Efek tubuh',
      subCategory: 'Gerakan',
      description: 'Garis cahaya neon animasi mengikuti goyangan tangan dan kaki',
      previewImageUrl: 'assets/images/effect_previews/cool_boy.jpg',
      fallbackType: EffectType.stutterMotion,
      promptStyle: 'neon outline trace dancer, energetic neon body strokes',
    ),

    // --- 2. EFEK FOTO (PHOTO EFFECTS) ---
    const AiCloudEffectItem(
      id: 'photo_3d_zoom',
      name: '3D Zoom Dinamis',
      category: 'Efek foto',
      subCategory: '3D & Parallax',
      description: 'Efek parallax 3D memisahkan objek foto depan dengan latar belakang',
      previewImageUrl: 'assets/images/effect_previews/photo_3d_zoom.jpg',
      fallbackType: EffectType.zoomPulse,
      promptStyle: 'capcut 3d zoom pro, depth map parallax displacement',
    ),
    const AiCloudEffectItem(
      id: 'photo_motion_blur',
      name: 'Gerak Samar Foto Viral',
      category: 'Efek foto',
      subCategory: 'Blur & Gerak',
      description: 'Sapuan kabur halus artistik saat foto bergerak santai',
      previewImageUrl: 'assets/images/effect_previews/photo_motion_blur.jpg',
      fallbackType: EffectType.motionBlur,
      promptStyle: 'aesthetic photography motion blur, shutter drag aesthetic',
    ),
    const AiCloudEffectItem(
      id: 'photo_vintage_leak',
      name: 'Bocoran Cahaya Analog',
      category: 'Efek foto',
      subCategory: 'Retro & Analog',
      description: 'Pendaran cahaya film 35mm klasik di sudut bingkai foto',
      previewImageUrl: 'assets/images/effect_previews/photo_vintage_leak.jpg',
      fallbackType: EffectType.lightLeak,
      promptStyle: 'vintage 35mm film light leak flare, retro disposable camera look',
    ),
    const AiCloudEffectItem(
      id: 'photo_polaroid_frame',
      name: 'Bingkai Polaroid Instan',
      category: 'Efek foto',
      subCategory: 'Retro & Analog',
      description: 'Bingkai cetak foto instan putih dengan nuansa nostalgia hangat',
      previewImageUrl: 'assets/images/effect_previews/retro_vintage.jpg',
      fallbackType: EffectType.sepiaFilm,
      promptStyle: 'polaroid border vintage mood, retro grain fade',
    ),
    const AiCloudEffectItem(
      id: 'photo_flash_freeze',
      name: 'Kilatan Blitz Paparazzi',
      category: 'Efek foto',
      subCategory: 'Sorotan',
      description: 'Kilatan cahaya blitz putih pekat gaya foto majalah mode',
      previewImageUrl: 'assets/images/effect_previews/portrait_glamour.jpg',
      fallbackType: EffectType.zoomPulse,
      promptStyle: 'paparazzi camera flash strobe, high fashion exposure pulse',
    ),

    // --- 3. EFEK AI (AI GENERATIVE EFFECTS) ---
    const AiCloudEffectItem(
      id: 'ai_anime_cyber',
      name: 'AI Anime Cyberpunk',
      category: 'Efek AI',
      subCategory: 'Anime',
      description: 'Transformasi animasi anime Jepang dengan nuansa neon cyberpunk',
      previewImageUrl: 'assets/images/effect_previews/anime_ai.jpg',
      fallbackType: EffectType.cyberpunkGlow,
      promptStyle: 'masterpiece, anime aesthetic, neo tokyo cyberpunk glow',
    ),
    const AiCloudEffectItem(
      id: 'ai_hdr_enhancer',
      name: 'AI Ultra HDR 4K',
      category: 'Efek AI',
      subCategory: 'Restorasi',
      description: 'Restorasi ketajaman mikro & kontras dinamis berbasis neural network',
      previewImageUrl: 'assets/images/effect_previews/woman_portrait.jpg',
      fallbackType: EffectType.sharpen,
      promptStyle: 'photorealistic 8k, extreme detail, neural hdr exposure',
    ),
    const AiCloudEffectItem(
      id: 'ai_fantasy_dream',
      name: 'AI Fantasy Glow',
      category: 'Efek AI',
      subCategory: 'Magis',
      description: 'Pendaran partikel sihir ethereal dengan aura keemasan',
      previewImageUrl: 'assets/images/effect_previews/fantasy_glow.jpg',
      fallbackType: EffectType.dreamyGlow,
      promptStyle: 'ethereal fantasy aura, golden particles bokeh, dreamlike',
    ),
    const AiCloudEffectItem(
      id: 'ai_matrix_code',
      name: 'AI Neural Matrix',
      category: 'Efek AI',
      subCategory: 'Futuristik',
      description: 'Aliran kode matriks digital hijau dan glitch kuantum',
      previewImageUrl: 'assets/images/effect_previews/cyber_future.jpg',
      fallbackType: EffectType.colorGlitch,
      promptStyle: 'matrix binary digital rain, sci-fi hud neural interface',
    ),
    const AiCloudEffectItem(
      id: 'ai_glamour_face',
      name: 'AI Smart Beauty Retouch',
      category: 'Efek AI',
      subCategory: 'Kecantikan',
      description: 'Penyempurnaan tekstur kulit alami & pendar mata berkilau',
      previewImageUrl: 'assets/images/effect_previews/portrait_glamour.jpg',
      fallbackType: EffectType.gaussianSoft,
      promptStyle: 'flawless skin portrait studio lighting, soft glamour beauty',
    ),

    // --- 4. TEMA VIRAL (B.DUCK & HALLOWEEN) ---
    const AiCloudEffectItem(
      id: 'ai_duck_pop',
      name: 'B.Duck Cute Pop',
      category: 'Efek video',
      subCategory: 'B.Duck',
      description: 'Stiker & rona kuning cerah bebek B.Duck animasi menggemaskan',
      previewImageUrl: 'assets/images/effect_previews/cute_duck.jpg',
      fallbackType: EffectType.comicBook,
      promptStyle: 'cute cartoon yellow duck theme, cheerful vibrant pop art',
    ),
    const AiCloudEffectItem(
      id: 'ai_halloween_spooky',
      name: 'Halloween Spooky Fog',
      category: 'Efek video',
      subCategory: 'Halloween',
      description: 'Kabut mistis labu oranye Jack-o-lantern & bayangan ungu pekat',
      previewImageUrl: 'assets/images/effect_previews/halloween_pumpkin.jpg',
      fallbackType: EffectType.vignetteDark,
      promptStyle: 'halloween dark fog, glowing carved pumpkin eyes, mysterious purple',
    ),
  ];

  /// Cari atau ambil katalog efek AI online
  Future<List<AiCloudEffectItem>> fetchAiEffects({String query = '', String? mode}) async {
    try {
      final url = Uri.parse('https://huggingface.co/api/models?search=stable-diffusion-video-effects&limit=10');
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final liveItems = <AiCloudEffectItem>[];

        for (int i = 0; i < data.length && i < 6; i++) {
          final m = data[i];
          final modelId = m['id'] as String? ?? 'ai_model_$i';
          final cleanName = modelId.split('/').last.replaceAll('-', ' ').toUpperCase();

          liveItems.add(
            AiCloudEffectItem(
              id: 'hf_$modelId',
              name: 'AI $cleanName',
              category: 'Efek AI',
              subCategory: 'Cloud Hub',
              description: 'Model efek kecerdasan buatan dari cloud repository $modelId',
              previewImageUrl: 'assets/images/effect_previews/cyber_future.jpg',
              fallbackType: i % 2 == 0 ? EffectType.cyberpunkGlow : EffectType.rgbSplit,
              promptStyle: 'ai generative filter, dynamic video fx',
            ),
          );
        }

        if (liveItems.isNotEmpty) {
          final combined = [...defaultAiEffects, ...liveItems];
          return _filterList(combined, query, mode);
        }
      }
    } catch (_) {
      // Fallback offline
    }

    return _filterList(defaultAiEffects, query, mode);
  }

  List<AiCloudEffectItem> _filterList(List<AiCloudEffectItem> list, String query, String? mode) {
    var result = list;
    if (mode != null && mode.isNotEmpty) {
      result = result.where((e) => e.category.toLowerCase() == mode.toLowerCase()).toList();
    }
    if (query.isNotEmpty) {
      result = result
          .where((e) =>
              e.name.toLowerCase().contains(query.toLowerCase()) ||
              e.description.toLowerCase().contains(query.toLowerCase()) ||
              e.subCategory.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    return result;
  }
}
