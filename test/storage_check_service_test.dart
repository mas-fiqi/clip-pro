import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/device_capability_model.dart';
import 'package:video_clipper_app/core/services/device_capability_service.dart';
import 'package:video_clipper_app/core/services/storage_check_service.dart';

class MockDeviceCapabilityService implements DeviceCapabilityService {
  final StorageAndThermalInfo Function() infoProvider;

  MockDeviceCapabilityService(this.infoProvider);

  @override
  Future<DeviceCapabilityModel> getDeviceCapabilities() async {
    return const DeviceCapabilityModel();
  }

  @override
  Future<StorageAndThermalInfo> getStorageAndThermalInfo() async {
    return infoProvider();
  }
}

void main() {
  group('P1-01 StorageCheckService Unit Tests', () {
    test('1. Sufficient storage available -> returns isSufficient = true (SAFE)', () async {
      final mock = MockDeviceCapabilityService(() => const StorageAndThermalInfo(
            availableStorageMB: 5000,
            totalStorageMB: 64000,
          ));
      final service = StorageCheckService(capabilityService: mock);

      final result = await service.checkStorageSufficiency(100.0);

      expect(result.isSufficient, isTrue);
      expect(result.status, StorageRiskStatus.safe);
      expect(result.availableMB, 5000.0);
    });

    test('2. Insufficient storage available (below estimated MB) -> returns isSufficient = false (CRITICAL)', () async {
      final mock = MockDeviceCapabilityService(() => const StorageAndThermalInfo(
            availableStorageMB: 30, // Hanya 30 MB tersisa
            totalStorageMB: 64000,
          ));
      final service = StorageCheckService(capabilityService: mock);

      final result = await service.checkStorageSufficiency(150.0);

      expect(result.isSufficient, isFalse);
      expect(result.status, StorageRiskStatus.critical);
      expect(result.availableMB, 30.0);
      expect(result.message, contains('tidak mencukupi'));
    });

    test('3. Warning storage available (above estimated but below safe buffer 2x+100) -> returns isSufficient = true with warning', () async {
      // Dibutuhkan: 100 MB. Safe buffer = 100 * 2 + 100 = 300 MB.
      // Tersedia: 150 MB (Cukup untuk file final, tapi sempit)
      final mock = MockDeviceCapabilityService(() => const StorageAndThermalInfo(
            availableStorageMB: 150,
            totalStorageMB: 64000,
          ));
      final service = StorageCheckService(capabilityService: mock);

      final result = await service.checkStorageSufficiency(100.0);

      expect(result.isSufficient, isTrue);
      expect(result.status, StorageRiskStatus.warning);
      expect(result.message, contains('Penyimpanan menipis'));
    });

    test('4. Unknown/unavailable storage info (non-Android / platform error) -> safe fallback behavior', () async {
      final mock = MockDeviceCapabilityService(() => const StorageAndThermalInfo(
            availableStorageMB: null,
            totalStorageMB: null,
          ));
      final service = StorageCheckService(capabilityService: mock);

      final result = await service.checkStorageSufficiency(100.0);

      expect(result.isSufficient, isTrue);
      expect(result.status, StorageRiskStatus.unknown);
      expect(result.availableMB, isNull);
    });
  });
}

