import 'package:flutter/material.dart';
import '../../../../core/models/benchmark_profile_model.dart';
import '../../../../core/models/device_capability_model.dart';
import '../../../../core/models/export_config_model.dart';
import '../../../../core/services/device_capability_service.dart';
import '../../../../core/services/smart_export_advisor.dart';
import '../../../../core/theme/app_theme.dart';

class ExportSettingsBottomSheet extends StatefulWidget {
  final double totalDurationSeconds;

  const ExportSettingsBottomSheet({
    super.key,
    required this.totalDurationSeconds,
  });

  static Future<ExportConfigModel?> show(
    BuildContext context, {
    required double totalDurationSeconds,
  }) {
    return showModalBottomSheet<ExportConfigModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExportSettingsBottomSheet(
        totalDurationSeconds: totalDurationSeconds,
      ),
    );
  }

  @override
  State<ExportSettingsBottomSheet> createState() => _ExportSettingsBottomSheetState();
}

class _ExportSettingsBottomSheetState extends State<ExportSettingsBottomSheet> {
  ExportResolutionPreset _resolution = ExportResolutionPreset.res720p;
  ExportFps _fps = ExportFps.fps30;
  ExportBitrateQuality _bitrate = ExportBitrateQuality.standard;
  ExportEncoderMode _encoderMode = ExportEncoderMode.auto;
  bool _includeAudio = true;

  final DeviceCapabilityService _capabilityService = DeviceCapabilityServiceImpl();
  DeviceCapabilityModel _capabilities = const DeviceCapabilityModel();
  StorageAndThermalInfo _storageThermal = const StorageAndThermalInfo();
  BenchmarkProfile? _benchmarkProfile;

  @override
  void initState() {
    super.initState();
    _loadCapabilities();
  }

  Future<void> _loadCapabilities() async {
    try {
      final caps = await _capabilityService.getDeviceCapabilities();
      final st = await _capabilityService.getStorageAndThermalInfo();
      final bp = await BenchmarkProfile.load();
      if (mounted) {
        setState(() {
          _capabilities = caps;
          _storageThermal = st;
          _benchmarkProfile = bp;
        });
      }
    } catch (_) {}
  }

  void _applyQuickPreset(String preset) {
    final cfg = SmartExportAdvisor.getPresetRecommendation(
      presetName: preset,
      capabilities: _capabilities,
    );
    setState(() {
      _resolution = cfg.resolution;
      _fps = cfg.fps;
      _bitrate = cfg.bitrateQuality;
      _encoderMode = cfg.encoderMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentConfig = ExportConfigModel(
      resolution: _resolution,
      fps: _fps,
      bitrateQuality: _bitrate,
      encoderMode: _encoderMode,
      includeAudio: _includeAudio,
    );
    final estimatedMB = currentConfig.estimateFileSizeMB(widget.totalDurationSeconds);
    final storageRisk = _storageThermal.evaluateStorageRisk(estimatedMB);
    final thermalWarning = _storageThermal.thermalStatus;
    final compatLevel = SmartExportAdvisor.evaluateCompatibility(
      config: currentConfig,
      capabilities: _capabilities,
    );
    final estimatedTime = SmartExportAdvisor.estimateExportDurationText(
      totalDurationSeconds: widget.totalDurationSeconds,
      config: currentConfig,
      benchmarkProfile: _benchmarkProfile,
    );
    final autoResolvedEncoder = SmartExportAdvisor.resolveAutoEncoder(
      config: currentConfig,
      capabilities: _capabilities,
      benchmarkProfile: _benchmarkProfile,
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLarge)),
        border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tune, color: AppTheme.primary, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Smart Export & Rendering',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: AppTheme.divider, height: 1),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Banner Rekomendasi Cepat (Draft, Standard, High Quality)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              side: const BorderSide(color: AppTheme.border),
                            ),
                            onPressed: () => _applyQuickPreset('draft'),
                            child: const Text('Draft (480p)', style: TextStyle(fontSize: 11)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              side: const BorderSide(color: AppTheme.primary),
                            ),
                            onPressed: () => _applyQuickPreset('standard'),
                            child: const Text('⭐ Standard (720p)', style: TextStyle(fontSize: 11, color: AppTheme.primary)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              side: const BorderSide(color: AppTheme.border),
                            ),
                            onPressed: () => _applyQuickPreset('high'),
                            child: const Text('High Quality', style: TextStyle(fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Card Ringkasan & Estimasi Ukuran File + Waktu
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.video_file_outlined, color: AppTheme.primary, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Estimasi Ukuran File',
                                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '~${estimatedMB.toStringAsFixed(1)} MB',
                                      style: const TextStyle(
                                        color: AppTheme.success,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    estimatedTime,
                                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _storageThermal.availableStorageMB != null
                                        ? 'Sisa disk: ~${(_storageThermal.availableStorageMB! / 1024).toStringAsFixed(1)} GB'
                                        : 'Sisa disk: memadai',
                                    style: TextStyle(
                                      color: storageRisk == StorageRiskStatus.critical
                                          ? AppTheme.error
                                          : AppTheme.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Warning Storage jika kritis / peringatan
                          if (storageRisk == StorageRiskStatus.warning || storageRisk == StorageRiskStatus.critical) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: (storageRisk == StorageRiskStatus.critical ? AppTheme.error : Colors.amber).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: 16,
                                    color: storageRisk == StorageRiskStatus.critical ? AppTheme.error : Colors.amber,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      storageRisk == StorageRiskStatus.critical
                                          ? 'Kapasitas penyimpanan hampir habis! Kosongkan ruang sebelum ekspor.'
                                          : 'Penyimpanan terbatas untuk file sementara rendering.',
                                      style: TextStyle(
                                        color: storageRisk == StorageRiskStatus.critical ? AppTheme.error : Colors.amber,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Warning Thermal jika perangkat hangat/panas
                          if (thermalWarning == ThermalWarningStatus.hot || thermalWarning == ThermalWarningStatus.warm) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: (thermalWarning == ThermalWarningStatus.hot ? AppTheme.error : Colors.orange).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.thermostat,
                                    size: 16,
                                    color: thermalWarning == ThermalWarningStatus.hot ? AppTheme.error : Colors.orange,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      thermalWarning == ThermalWarningStatus.hot
                                          ? 'Suhu perangkat tinggi (~${_storageThermal.batteryTemperatureCelsius?.toStringAsFixed(1)}°C). Ekspor mungkin memakan waktu lebih lama.'
                                          : 'Suhu perangkat hangat (~${_storageThermal.batteryTemperatureCelsius?.toStringAsFixed(1)}°C).',
                                      style: TextStyle(
                                        color: thermalWarning == ThermalWarningStatus.hot ? AppTheme.error : Colors.orange,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Status Kompatibilitas Perangkat
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            compatLevel == CompatibilityLevel.recommended
                                ? Icons.verified
                                : (compatLevel == CompatibilityLevel.limited ? Icons.info_outline : Icons.check_circle_outline),
                            size: 16,
                            color: compatLevel == CompatibilityLevel.recommended
                                ? AppTheme.success
                                : (compatLevel == CompatibilityLevel.limited ? Colors.amber : AppTheme.textSecondary),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              SmartExportAdvisor.getCompatibilityDescription(
                                config: currentConfig,
                                capabilities: _capabilities,
                              ),
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 1. Pilihan Resolusi
                    _buildSectionHeader('RESOLUSI VIDEO', 'Pilih resolusi yang sesuai dengan kebutuhan'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChoiceChip(
                          label: '360p',
                          value: ExportResolutionPreset.res360p,
                          groupValue: _resolution,
                          onSelected: (val) => setState(() => _resolution = val),
                        ),
                        _buildChoiceChip(
                          label: '480p (SD)',
                          value: ExportResolutionPreset.res480p,
                          groupValue: _resolution,
                          onSelected: (val) => setState(() => _resolution = val),
                        ),
                        _buildChoiceChip(
                          label: '720p (HD)',
                          value: ExportResolutionPreset.res720p,
                          groupValue: _resolution,
                          onSelected: (val) => setState(() => _resolution = val),
                        ),
                        _buildChoiceChip(
                          label: '1080p (FHD)',
                          value: ExportResolutionPreset.res1080p,
                          groupValue: _resolution,
                          onSelected: (val) => setState(() => _resolution = val),
                        ),
                        _buildChoiceChip(
                          label: '1440p (2K)',
                          value: ExportResolutionPreset.res1440p,
                          groupValue: _resolution,
                          onSelected: (val) => setState(() => _resolution = val),
                        ),
                        _buildChoiceChip(
                          label: '4K UHD (2160p)',
                          value: ExportResolutionPreset.res4k,
                          groupValue: _resolution,
                          onSelected: (val) => setState(() => _resolution = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // 2. Pilihan Frame Rate (FPS)
                    _buildSectionHeader('FRAME RATE (FPS)', 'Kehalusan gerak video'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildChoiceChip(
                          label: '24 FPS',
                          value: ExportFps.fps24,
                          groupValue: _fps,
                          onSelected: (val) => setState(() => _fps = val),
                        ),
                        _buildChoiceChip(
                          label: '25 FPS',
                          value: ExportFps.fps25,
                          groupValue: _fps,
                          onSelected: (val) => setState(() => _fps = val),
                        ),
                        _buildChoiceChip(
                          label: '30 FPS',
                          value: ExportFps.fps30,
                          groupValue: _fps,
                          onSelected: (val) => setState(() => _fps = val),
                        ),
                        _buildChoiceChip(
                          label: '50 FPS',
                          value: ExportFps.fps50,
                          groupValue: _fps,
                          onSelected: (val) => setState(() => _fps = val),
                        ),
                        _buildChoiceChip(
                          label: '60 FPS',
                          value: ExportFps.fps60,
                          groupValue: _fps,
                          onSelected: (val) => setState(() => _fps = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // 3. Kualitas Bitrate
                    _buildSectionHeader('KUALITAS BITRATE', 'Mempengaruhi kejernihan dan ukuran file'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildChoiceChip(
                          label: 'Hemat Ruang',
                          value: ExportBitrateQuality.low,
                          groupValue: _bitrate,
                          onSelected: (val) => setState(() => _bitrate = val),
                        ),
                        _buildChoiceChip(
                          label: 'Standar (~${currentConfig.videoBitrateKbps} kbps)',
                          value: ExportBitrateQuality.standard,
                          groupValue: _bitrate,
                          onSelected: (val) => setState(() => _bitrate = val),
                        ),
                        _buildChoiceChip(
                          label: 'Kualitas Tinggi',
                          value: ExportBitrateQuality.high,
                          groupValue: _bitrate,
                          onSelected: (val) => setState(() => _bitrate = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // 4. Mode Akselerasi Hardware (Encoder)
                    _buildSectionHeader(
                      'AKSELERASI HARDWARE (ENCODER)',
                      _encoderMode == ExportEncoderMode.auto
                          ? 'Auto memilih: ${autoResolvedEncoder == 'hardware' ? "🚀 Hardware (MediaCodec)" : "💻 Software (libx264)"}'
                          : 'Pilihan encoder manual aktif',
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildChoiceChip(
                          label: '⚡ Auto (Cerdas)',
                          value: ExportEncoderMode.auto,
                          groupValue: _encoderMode,
                          onSelected: (val) => setState(() => _encoderMode = val),
                        ),
                        _buildChoiceChip(
                          label: '🚀 Hardware (MediaCodec)',
                          value: ExportEncoderMode.hardware,
                          groupValue: _encoderMode,
                          onSelected: (val) => setState(() => _encoderMode = val),
                        ),
                        _buildChoiceChip(
                          label: '💻 Software (libx264)',
                          value: ExportEncoderMode.software,
                          groupValue: _encoderMode,
                          onSelected: (val) => setState(() => _encoderMode = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 5. Toggle Audio
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Sertakan Audio',
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          _includeAudio ? 'Audio asli & multi-track di-render' : 'Video diekspor tanpa suara',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                        value: _includeAudio,
                        activeThumbColor: AppTheme.primary,
                        onChanged: (val) => setState(() => _includeAudio = val),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.file_upload_outlined, size: 20),
                      label: const Text('Mulai Ekspor'),
                      onPressed: () {
                        Navigator.pop(context, currentConfig);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildChoiceChip<T>({
    required String label,
    required T value,
    required T groupValue,
    required ValueChanged<T> onSelected,
  }) {
    final isSelected = value == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primary,
      backgroundColor: AppTheme.surfaceLight,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        side: BorderSide(
          color: isSelected ? AppTheme.primary : AppTheme.border,
          width: 1,
        ),
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (val) {
        if (val) onSelected(value);
      },
    );
  }
}
