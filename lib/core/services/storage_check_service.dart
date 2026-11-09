import '../models/device_capability_model.dart';
import 'device_capability_service.dart';

/// Service untuk memverifikasi kapasitas penyimpanan sebelum ekspor video
class StorageCheckService {
  final DeviceCapabilityService _capabilityService;

  StorageCheckService({DeviceCapabilityService? capabilityService})
      : _capabilityService = capabilityService ?? DeviceCapabilityServiceImpl();

  /// Memeriksa apakah penyimpanan mencukupi untuk file video dengan estimasi [estimatedOutputMB].
  ///
  /// Menggunakan [DeviceCapabilityService] yang membaca StatFs riil Android jika tersedia.
  /// Bila bukan Android atau StatFs gagal, menggunakan fallback safe behavior (tidak memblokir false-positive).
  Future<StorageCheckResult> checkStorageSufficiency(double estimatedOutputMB) async {
    try {
      final info = await _capabilityService.getStorageAndThermalInfo();
      final availableMb = info.availableStorageMB;

      if (availableMb == null) {
        // Platform non-Android / Storage info unavailable
        return StorageCheckResult(
          status: StorageRiskStatus.unknown,
          availableMB: null,
          requiredMB: estimatedOutputMB,
          isSufficient: true,
          message: 'Status penyimpanan perangkat tidak dapat dideteksi secara langsung. Melanjutkan ekspor dengan pemantauan aman.',
        );
      }

      final risk = info.evaluateStorageRisk(estimatedOutputMB);

      if (risk == StorageRiskStatus.critical) {
        return StorageCheckResult(
          status: StorageRiskStatus.critical,
          availableMB: availableMb.toDouble(),
          requiredMB: estimatedOutputMB,
          isSufficient: false,
          message: 'Penyimpanan perangkat tidak mencukupi (Tersedia: $availableMb MB, Dibutuhkan: ${estimatedOutputMB.toStringAsFixed(1)} MB). Kosongkan ruang sebelum mengekspor.',
        );
      }

      if (risk == StorageRiskStatus.warning) {
        return StorageCheckResult(
          status: StorageRiskStatus.warning,
          availableMB: availableMb.toDouble(),
          requiredMB: estimatedOutputMB,
          isSufficient: true,
          message: 'Penyimpanan menipis (Tersedia: $availableMb MB). Ekspor tetap dapat dilakukan tetapi disarankan menyisakan ruang lebih.',
        );
      }

      return StorageCheckResult(
        status: StorageRiskStatus.safe,
        availableMB: availableMb.toDouble(),
        requiredMB: estimatedOutputMB,
        isSufficient: true,
        message: 'Kapasitas penyimpanan mencukupi.',
      );
    } catch (e) {
      return StorageCheckResult(
        status: StorageRiskStatus.unknown,
        availableMB: null,
        requiredMB: estimatedOutputMB,
        isSufficient: true,
        message: 'Gagal memeriksa penyimpanan ($e). Melanjutkan ekspor dengan aman.',
      );
    }
  }
}

class StorageCheckResult {
  final StorageRiskStatus status;
  final double? availableMB;
  final double requiredMB;
  final bool isSufficient;
  final String message;

  const StorageCheckResult({
    required this.status,
    required this.availableMB,
    required this.requiredMB,
    required this.isSufficient,
    required this.message,
  });
}
