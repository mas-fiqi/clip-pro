import 'package:gal/gal.dart';

class GallerySaverService {
  /// Memeriksa izin penyimpanan
  Future<bool> checkPermission() async {
    return await Gal.hasAccess();
  }

  /// Meminta izin akses galeri
  Future<bool> requestPermission() async {
    return await Gal.requestAccess();
  }

  /// Menyimpan video ke galeri HP
  Future<bool> saveVideoToGallery(String filePath, {String? album}) async {
    try {
      final hasAccess = await checkPermission();
      if (!hasAccess) {
        final granted = await requestPermission();
        if (!granted) return false;
      }

      await Gal.putVideo(filePath, album: album);
      return true;
    } catch (e) {
      return false;
    }
  }
}

