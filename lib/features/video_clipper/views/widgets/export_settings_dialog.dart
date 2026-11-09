import 'package:flutter/material.dart';
import '../../../../core/models/export_config_model.dart';

class ExportSettingsDialog extends StatefulWidget {
  final double totalDurationSeconds;

  const ExportSettingsDialog({super.key, required this.totalDurationSeconds});

  @override
  State<ExportSettingsDialog> createState() => _ExportSettingsDialogState();
}

class _ExportSettingsDialogState extends State<ExportSettingsDialog> {
  ExportResolutionPreset _resolution = ExportResolutionPreset.res720p;
  ExportFps _fps = ExportFps.fps30;
  ExportBitrateQuality _bitrate = ExportBitrateQuality.standard;
  bool _includeAudio = true;

  @override
  Widget build(BuildContext context) {
    final currentConfig = ExportConfigModel(
      resolution: _resolution,
      fps: _fps,
      bitrateQuality: _bitrate,
      includeAudio: _includeAudio,
    );
    final estimatedMB = currentConfig.estimateFileSizeMB(widget.totalDurationSeconds);

    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E2C),
      title: const Row(
        children: [
          Icon(Icons.tune, color: Colors.deepPurpleAccent),
          SizedBox(width: 8),
          Text('Pengaturan Ekspor', style: TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Estimasi Ukuran File
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estimasi Ukuran:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Text(
                    '~${estimatedMB.toStringAsFixed(1)} MB',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pilihan Resolusi
            const Text('Resolusi:', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildChoice<ExportResolutionPreset>(
                  label: '480p SD',
                  value: ExportResolutionPreset.res480p,
                  groupValue: _resolution,
                  onSelected: (val) => setState(() => _resolution = val),
                ),
                _buildChoice<ExportResolutionPreset>(
                  label: '720p HD',
                  value: ExportResolutionPreset.res720p,
                  groupValue: _resolution,
                  onSelected: (val) => setState(() => _resolution = val),
                ),
                _buildChoice<ExportResolutionPreset>(
                  label: '1080p FHD',
                  value: ExportResolutionPreset.res1080p,
                  groupValue: _resolution,
                  onSelected: (val) => setState(() => _resolution = val),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pilihan Frame Rate (FPS)
            const Text('Frame Rate:', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                _buildChoice<ExportFps>(
                  label: '24 FPS',
                  value: ExportFps.fps24,
                  groupValue: _fps,
                  onSelected: (val) => setState(() => _fps = val),
                ),
                _buildChoice<ExportFps>(
                  label: '30 FPS',
                  value: ExportFps.fps30,
                  groupValue: _fps,
                  onSelected: (val) => setState(() => _fps = val),
                ),
                _buildChoice<ExportFps>(
                  label: '60 FPS',
                  value: ExportFps.fps60,
                  groupValue: _fps,
                  onSelected: (val) => setState(() => _fps = val),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Kualitas Bitrate
            const Text('Kualitas Bitrate:', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                _buildChoice<ExportBitrateQuality>(
                  label: 'Hemat Ruang',
                  value: ExportBitrateQuality.low,
                  groupValue: _bitrate,
                  onSelected: (val) => setState(() => _bitrate = val),
                ),
                _buildChoice<ExportBitrateQuality>(
                  label: 'Standar',
                  value: ExportBitrateQuality.standard,
                  groupValue: _bitrate,
                  onSelected: (val) => setState(() => _bitrate = val),
                ),
                _buildChoice<ExportBitrateQuality>(
                  label: 'Kualitas Tinggi',
                  value: ExportBitrateQuality.high,
                  groupValue: _bitrate,
                  onSelected: (val) => setState(() => _bitrate = val),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Toggle Audio
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sertakan Audio', style: TextStyle(color: Colors.white, fontSize: 14)),
              value: _includeAudio,
              activeThumbColor: Colors.deepPurpleAccent,
              onChanged: (val) => setState(() => _includeAudio = val),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.file_upload_outlined, size: 18),
          label: const Text('Mulai Ekspor'),
          onPressed: () {
            Navigator.pop(context, currentConfig);
          },
        ),
      ],
    );
  }

  Widget _buildChoice<T>({
    required String label,
    required T value,
    required T groupValue,
    required ValueChanged<T> onSelected,
  }) {
    final isSelected = value == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.deepPurpleAccent,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey.shade300,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (val) {
        if (val) onSelected(value);
      },
    );
  }
}

