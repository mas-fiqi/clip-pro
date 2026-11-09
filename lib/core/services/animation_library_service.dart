import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/animation_model.dart';
import 'animation_builtin_presets_data.dart';
import 'animation_presets_data.dart';

/// Service Katalog & Download Manager Animasi (Built-in + Free Online Library)
class AnimationLibraryService {
  static final AnimationLibraryService _instance =
      AnimationLibraryService._internal();
  factory AnimationLibraryService() => _instance;
  AnimationLibraryService._internal();

  final Set<String> _favoritePresetIds = {};
  final List<String> _recentlyUsedPresetIds = [];
  final Map<String, AnimationPresetModel> _downloadedPresets = {};
  final Set<String> _activeDownloadingIds = {};
  final Map<String, double> _downloadProgress = {};

  /// Built-in Presets (Offline, siap pakai seketika, bebas royalti & open-source MIT)
  static final List<AnimationPresetModel> _builtInPresets =
      AnimationBuiltinPresetsData.allPresets;

  // Katalog online (5 preset komunitas) dihapus dari kode karena seluruh
  // URL asetnya mengembalikan 404 per 9 Nov 2026. Tambahkan kembali setelah
  // aset benar-benar dipublikasikan dan diverifikasi.

  /// Mengambil semua preset (Built-in + Online Catalog + Downloaded + 520 Extended Presets)
  List<AnimationPresetModel> getAllPresets() {
    final list = <AnimationPresetModel>[];
    list.addAll(_builtInPresets);
    list.addAll(AnimationPresetsData.allPresets);

    // Katalog online sengaja tidak ditampilkan sampai asetnya benar-benar
    // dipublikasikan: seluruh URL di _onlineCatalogPresets mengembalikan 404
    // (audit 9 Nov 2026), sehingga preset tersebut hanya akan mengecewakan
    // pengguna saat diunduh. Aktifkan kembali loop berikut setelah aset siap.
    //
    // for (final online in _onlineCatalogPresets) {
    //   list.add(_downloadedPresets[online.id] ?? online);
    // }
    return list;
  }

  /// Filter preset berdasarkan kategori, pencarian teks, dan tipe (In/Out/Combo)
  List<AnimationPresetModel> filterPresets({
    AnimationCategory? category,
    AnimationApplicationType? type,
    String searchQuery = '',
    bool favoritesOnly = false,
  }) {
    var rawList = getAllPresets();

    if (category != null) {
      rawList = rawList.where((p) => p.category == category).toList();
    }

    if (favoritesOnly) {
      rawList = rawList
          .where((p) => _favoritePresetIds.contains(p.id))
          .toList();
    }

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      rawList = rawList
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                p.description.toLowerCase().contains(q) ||
                p.category.name.toLowerCase().contains(q),
          )
          .toList();
    }

    // Adaptasikan preset agar seluruh koleksi animasi dapat langsung digunakan pada mode IN, OUT, maupun COMBO!
    if (type != null) {
      return rawList.map((p) => p.copyWith(type: type)).toList();
    }

    return rawList;
  }

  /// Cek status favorit
  bool isFavorite(String presetId) => _favoritePresetIds.contains(presetId);

  /// Toggle favorit
  void toggleFavorite(String presetId) {
    if (_favoritePresetIds.contains(presetId)) {
      _favoritePresetIds.remove(presetId);
    } else {
      _favoritePresetIds.add(presetId);
    }
  }

  /// Catat pemakaian preset
  void recordRecentlyUsed(String presetId) {
    _recentlyUsedPresetIds.remove(presetId);
    _recentlyUsedPresetIds.insert(0, presetId);
    if (_recentlyUsedPresetIds.length > 20) {
      _recentlyUsedPresetIds.removeLast();
    }
  }

  List<String> get recentlyUsedIds => List.unmodifiable(_recentlyUsedPresetIds);

  /// Status download preset online
  bool isDownloading(String presetId) =>
      _activeDownloadingIds.contains(presetId);
  double getProgress(String presetId) => _downloadProgress[presetId] ?? 0.0;
  bool isPresetDownloaded(String presetId) {
    if (_builtInPresets.any((p) => p.id == presetId)) return true;
    return _downloadedPresets.containsKey(presetId);
  }

  /// Download preset online ke penyimpanan lokal aman.
  ///
  /// Sebelumnya metode ini hanya menunggu 600 ms lalu menulis metadata lokal
  /// tanpa menyentuh jaringan (selalu "berhasil"). Sekarang manifest benar-
  /// benar diunduh dan kegagalan HTTP dikembalikan sebagai false.
  Future<bool> downloadPreset(
    AnimationPresetModel preset, {
    void Function(double)? onProgress,
  }) async {
    if (isPresetDownloaded(preset.id)) return true;

    final downloadUrl = preset.downloadUrl;
    if (downloadUrl == null || downloadUrl.isEmpty) return false;

    _activeDownloadingIds.add(preset.id);
    _downloadProgress[preset.id] = 0.0;

    try {
      onProgress?.call(0.1);
      final response = await http
          .get(Uri.parse(downloadUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        debugPrint(
          'Gagal mengunduh preset ${preset.id}: HTTP ${response.statusCode}',
        );
        return false;
      }

      final manifest = jsonDecode(response.body);
      if (manifest is! Map<String, dynamic>) {
        debugPrint('Manifest preset ${preset.id} tidak valid');
        return false;
      }

      _downloadProgress[preset.id] = 0.8;
      onProgress?.call(0.8);

      final appDir = await getApplicationDocumentsDirectory();
      final animDir = Directory('${appDir.path}/animations_library');
      if (!await animDir.exists()) {
        await animDir.create(recursive: true);
      }

      final downloadedModel = preset.copyWith(
        isDownloaded: true,
        isOnline: false,
      );
      final file = File('${animDir.path}/${preset.id}.json');
      await file.writeAsString(jsonEncode(downloadedModel.toJson()));

      _downloadedPresets[preset.id] = downloadedModel;
      _downloadProgress[preset.id] = 1.0;
      onProgress?.call(1.0);
      return true;
    } catch (e) {
      debugPrint('Gagal mengunduh preset animasi: $e');
      return false;
    } finally {
      _activeDownloadingIds.remove(preset.id);
      _downloadProgress.remove(preset.id);
    }
  }

  /// Hapus preset yang diunduh
  Future<void> deleteDownloadedPreset(String presetId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/animations_library/$presetId.json');
      if (await file.exists()) {
        await file.delete();
      }
      _downloadedPresets.remove(presetId);
    } catch (_) {}
  }
}
