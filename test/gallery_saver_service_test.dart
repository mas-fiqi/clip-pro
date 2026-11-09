import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/services/gallery_saver_service.dart';

void main() {
  group('P1-05 GallerySaverService Unit Tests', () {
    test('1. Non-existent file path returns failure with fileNotFound reason', () async {
      final service = GallerySaverService();
      final result = await service.saveVideoToGalleryWithResult('/path/that/does/not/exist/video_123.mp4');

      expect(result.isSuccess, isFalse);
      expect(result.failureReason, GallerySaveFailureReason.fileNotFound);
      expect(result.userMessage, contains('tidak ditemukan'));
    });

    test('2. Backward compatibility saveVideoToGallery returns boolean false on missing file', () async {
      final service = GallerySaverService();
      final isSaved = await service.saveVideoToGallery('/path/that/does/not/exist/video_123.mp4');

      expect(isSaved, isFalse);
    });

    test('3. GallerySaveResult factory constructors produce correct structures', () {
      final success = GallerySaveResult.success();
      expect(success.isSuccess, isTrue);
      expect(success.failureReason, isNull);
      expect(success.userMessage, contains('berhasil'));

      final failStorage = GallerySaveResult.failure(
        GallerySaveFailureReason.insufficientStorage,
        'Ruang tidak cukup',
      );
      expect(failStorage.isSuccess, isFalse);
      expect(failStorage.failureReason, GallerySaveFailureReason.insufficientStorage);
      expect(failStorage.userMessage, 'Ruang tidak cukup');
    });
  });
}

