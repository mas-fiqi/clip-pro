import 'dart:io';
import 'package:flutter/services.dart';
import '../models/device_capability_model.dart';

/// Abstraksi Device Capability Service agar dapat diuji tanpa bergantung platform asli
abstract class DeviceCapabilityService {
  Future<DeviceCapabilityModel> getDeviceCapabilities();
  Future<StorageAndThermalInfo> getStorageAndThermalInfo();
}

/// Implementasi nyata menggunakan MethodChannel ke Android MainActivity
class DeviceCapabilityServiceImpl implements DeviceCapabilityService {
  static const MethodChannel _channel =
      MethodChannel('id.cakfi.quickclippro/device_capabilities');

  DeviceCapabilityModel? _cachedCapabilities;

  @override
  Future<DeviceCapabilityModel> getDeviceCapabilities() async {
    if (_cachedCapabilities != null) {
      return _cachedCapabilities!;
    }

    if (!Platform.isAndroid) {
      _cachedCapabilities = const DeviceCapabilityModel(
        deviceModel: 'Non-Android Host',
        androidVersion: 'N/A',
      );
      return _cachedCapabilities!;
    }

    try {
      final res = await _channel.invokeMethod<Map<dynamic, dynamic>>('getDeviceCapabilities');
      if (res != null) {
        final map = Map<String, dynamic>.from(res);
        _cachedCapabilities = DeviceCapabilityModel.fromJson(map);
        return _cachedCapabilities!;
      }
    } catch (_) {}

    _cachedCapabilities = const DeviceCapabilityModel();
    return _cachedCapabilities!;
  }

  @override
  Future<StorageAndThermalInfo> getStorageAndThermalInfo() async {
    if (!Platform.isAndroid) {
      return const StorageAndThermalInfo();
    }

    try {
      final res = await _channel.invokeMethod<Map<dynamic, dynamic>>('getStorageAndThermalInfo');
      if (res != null) {
        final map = Map<String, dynamic>.from(res);
        return StorageAndThermalInfo.fromJson(map);
      }
    } catch (_) {}

    return const StorageAndThermalInfo();
  }
}

