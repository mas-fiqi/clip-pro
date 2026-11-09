import 'dart:io';
import 'package:gal/gal.dart';

enum GallerySaveFailureReason {
  permissionDenied,
  insufficientStorage,
  fileNotFound,
  unsupportedFormat,
  ioError,
  unknown,
}

class GallerySaveResult {
  final bool isSuccess;
  final GallerySaveFailureReason? failureReason;
  final String userMessage;

  const GallerySaveResult({
    required this.isSuccess,
    this.failureReason,
    required this.userMessage,
  });

  factory GallerySaveResult.success() {
    return const GallerySaveResult(
      isSuccess: true,
      userMessage: 'Video berhasil disimpan ke Galeri perangkat.',
    );
  }

  factory GallerySaveResult.failure(GallerySaveFailureReason reason, String message) {
    return GallerySaveResult(
      isSuccess: false,
      failureReason: reason,
      userMessage: message,
    );
  }
}

class GallerySaverService {
  /// Memeriksa izin penyimpanan
  Future<bool> checkPermission() async {
    return await Gal.hasAccess();
  }

  /// Meminta izin akses galeri
  Future<bool> requestPermission() async {
    return await Gal.requestAccess();
  }

  /// Menyimpan video ke galeri HP dengan error handling dan klasifikasi alasan yang bermakna
  Future<GallerySaveResult> saveVideoToGalleryWithResult(String filePath, {String? album}) async {
    // 1. Validasi keberadaan file lokal
    final file = File(filePath);
    if (!await file.exists()) {
      return GallerySaveResult.failure(
        GallerySaveFailureReason.fileNotFound,
        'File video tidak ditemukan di penyimpanan sementara.',
      );
    }

    // 2. Periksa dan minta izin akses jika belum ada
    try {
      final hasAccess = await checkPermission();
      if (!hasAccess) {
        final granted = await requestPermission();
        if (!granted) {
          return GallerySaveResult.failure(
            GallerySaveFailureReason.permissionDenied,
            'Izin akses galeri/penyimpanan ditolak. Aktifkan izin pada Pengaturan aplikasi.',
          );
        }
      }

      // 3. Simpan video menggunakan Gal
      await Gal.putVideo(filePath, album: album);
      return GallerySaveResult.success();
    } on GalException catch (e) {
      switch (e.type) {
        case GalExceptionType.accessDenied:
          return GallerySaveResult.failure(
            GallerySaveFailureReason.permissionDenied,
            'Izin akses galeri ditolak oleh sistem perangkat.',
          );
        case GalExceptionType.notEnoughSpace:
          return GallerySaveResult.failure(
            GallerySaveFailureReason.insufficientStorage,
            'Ruang penyimpanan perangkat tidak mencukupi untuk menyimpan video ke Galeri.',
          );
        case GalExceptionType.notSupportedFormat:
          return GallerySaveResult.failure(
            GallerySaveFailureReason.unsupportedFormat,
            'Format video tidak didukung oleh galeri bawaan perangkat.',
          );
        case GalExceptionType.unexpected:
          return GallerySaveResult.failure(
            GallerySaveFailureReason.unknown,
            'Terjadi kesalahan tak terduga saat menyimpan ke Galeri: ${e.type.code}',
          );
      }
    } on FileSystemException catch (e) {
      return GallerySaveResult.failure(
        GallerySaveFailureReason.ioError,
        'Gagal membaca/menulis file video: ${e.message}',
      );
    } catch (e) {
      return GallerySaveResult.failure(
        GallerySaveFailureReason.unknown,
        'Gagal menyimpan video ke galeri: $e',
      );
    }
  }

  /// Backward-compatible wrapper untuk kode existing
  Future<bool> saveVideoToGallery(String filePath, {String? album}) async {
    final result = await saveVideoToGalleryWithResult(filePath, album: album);
    return result.isSuccess;
  }
}
