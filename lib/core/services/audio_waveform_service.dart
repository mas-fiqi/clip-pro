import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/editor_performance_profile.dart';

/// Service generator audio waveform nyata berbasis ekstraksi byte / PCM atau simulasi deterministik
class AudioWaveformService {
  static final AudioWaveformService _instance = AudioWaveformService._internal();
  factory AudioWaveformService() => _instance;
  AudioWaveformService._internal();

  EditorPerformanceConfig _config = EditorPerformanceConfig.balanced();
  final LinkedHashMap<String, List<double>> _waveformCache = LinkedHashMap();

  void applyConfig(EditorPerformanceConfig config) {
    _config = config;
    _enforceCacheLimit();
  }

  /// Menghasilkan sample amplitudo normalized (0.08 s/d 1.0) untuk visualisasi waveform
  List<double> getWaveformSamples({
    required String key,
    required double durationSeconds,
    int sampleCount = 50,
    double volume = 1.0,
    String? filePath,
  }) {
    if (sampleCount <= 0) sampleCount = 50;
    final cacheKey = '${key}_$sampleCount';
    if (_waveformCache.containsKey(cacheKey)) {
      final cached = _waveformCache.remove(cacheKey)!;
      _waveformCache[cacheKey] = cached;
      return cached.map((v) => (v * volume).clamp(0.08, 1.0)).toList();
    }

    // Ekstraksi data waveform nyata dari file jika file ada di storage lokal
    List<double>? extractedSamples;
    if (filePath != null && filePath.isNotEmpty) {
      try {
        final file = File(filePath);
        if (file.existsSync()) {
          final length = file.lengthSync();
          if (length > 1024) {
            extractedSamples = _extractRawAmplitudes(file, sampleCount);
          }
        }
      } catch (e) {
        debugPrint('AudioWaveformService extraction error: $e');
      }
    }

    // Jika file tidak dapat dibaca langsung, gunakan algoritma akustik deterministik berbasis audio profile
    extractedSamples ??= _generateAcousticProfile(key, sampleCount, durationSeconds);

    _waveformCache[cacheKey] = extractedSamples;
    _enforceCacheLimit();
    return extractedSamples.map((v) => (v * volume).clamp(0.08, 1.0)).toList();
  }

  void _enforceCacheLimit() {
    final maxLimit = _config.maxCachedWaveforms;
    while (_waveformCache.length > maxLimit && _waveformCache.isNotEmpty) {
      final oldestKey = _waveformCache.keys.first;
      _waveformCache.remove(oldestKey);
    }
  }

  /// Ekstraksi level amplitudo dari raw data chunks file audio
  List<double> _extractRawAmplitudes(File file, int sampleCount) {
    final bytes = file.readAsBytesSync();
    final totalBytes = bytes.length;
    // Lewati audio header (misal WAV/MP3 ID3 tag ~ 1024 byte)
    final dataStart = min(1024, totalBytes ~/ 4);
    final dataLength = totalBytes - dataStart;
    final chunkSize = max(1, dataLength ~/ sampleCount);

    final samples = <double>[];
    for (int i = 0; i < sampleCount; i++) {
      final offset = dataStart + (i * chunkSize);
      int sum = 0;
      int count = 0;
      final end = min(offset + min(chunkSize, 256), totalBytes);
      for (int j = offset; j < end; j += 2) {
        final sampleVal = (bytes[j] - 128).abs();
        sum += sampleVal;
        count++;
      }
      final avg = count > 0 ? (sum / (count * 128.0)) : 0.2;
      samples.add(avg.clamp(0.12, 0.98));
    }
    return samples;
  }

  /// Generator profil akustik dengan irama musik realistis (beat, drops, decay)
  List<double> _generateAcousticProfile(String key, int sampleCount, double duration) {
    final samples = <double>[];
    int hash = key.codeUnits.fold(0, (acc, c) => acc + c);
    final random = Random(hash);

    for (int i = 0; i < sampleCount; i++) {
      final progress = i / sampleCount;
      // Ritme beat berulang khas musik (4/4 time signature)
      final beat = (sin(progress * pi * 8.0).abs() * 0.45);
      final harmonic = (cos(progress * pi * 16.0).abs() * 0.25);
      final noise = random.nextDouble() * 0.3;
      final amp = (beat + harmonic + noise).clamp(0.12, 0.95);
      samples.add(amp);
    }
    return samples;
  }

  void clearCache() {
    _waveformCache.clear();
  }
}
