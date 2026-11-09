import 'dart:io';
import 'package:image_picker/image_picker.dart';

class VideoPickerService {
  final ImagePicker _picker = ImagePicker();

  /// Membuka galeri dan mengembalikan File video yang dipilih, atau null jika dibatalkan
  Future<File?> pickVideoFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(hours: 2),
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      // Tangani error izin atau pembatalan
      return null;
    }
    return null;
  }

  /// Membuka galeri dan mengembalikan File foto/gambar/GIF yang dipilih, atau null jika dibatalkan
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}

