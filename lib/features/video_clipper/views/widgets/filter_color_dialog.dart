import 'package:flutter/material.dart';
import '../../../../core/models/color_adjustment_model.dart';

class FilterColorDialog extends StatefulWidget {
  final ColorAdjustmentModel initialAdjustment;

  const FilterColorDialog({super.key, required this.initialAdjustment});

  @override
  State<FilterColorDialog> createState() => _FilterColorDialogState();
}

class _FilterColorDialogState extends State<FilterColorDialog> {
  late FilterPreset _selectedPreset;
  late double _brightness;
  late double _contrast;
  late double _saturation;
  late double _vignette;

  @override
  void initState() {
    super.initState();
    _selectedPreset = widget.initialAdjustment.preset;
    _brightness = widget.initialAdjustment.brightness;
    _contrast = widget.initialAdjustment.contrast;
    _saturation = widget.initialAdjustment.saturation;
    _vignette = widget.initialAdjustment.vignette;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E2C),
      title: const Text('Filter & Color Grading', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Grid Pilihan Preset Filter
            const Text('Preset Filter:', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FilterPreset.values.map((preset) {
                final isSelected = _selectedPreset == preset;
                return ChoiceChip(
                  label: Text(_getPresetName(preset)),
                  selected: isSelected,
                  selectedColor: Colors.deepPurpleAccent,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade300,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (val) {
                    setState(() => _selectedPreset = preset);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),

            // Slider Brightness
            _buildSlider(
              label: 'Brightness: ${(_brightness * 100).toInt()}%',
              value: _brightness,
              min: -1.0,
              max: 1.0,
              onChanged: (val) => setState(() => _brightness = val),
            ),

            // Slider Contrast
            _buildSlider(
              label: 'Contrast: ${(_contrast * 100).toInt()}%',
              value: _contrast,
              min: -1.0,
              max: 1.0,
              onChanged: (val) => setState(() => _contrast = val),
            ),

            // Slider Saturation
            _buildSlider(
              label: 'Saturation: ${(_saturation * 100).toInt()}%',
              value: _saturation,
              min: -1.0,
              max: 1.0,
              onChanged: (val) => setState(() => _saturation = val),
            ),

            // Slider Vignette
            _buildSlider(
              label: 'Vignette: ${(_vignette * 100).toInt()}%',
              value: _vignette,
              min: 0.0,
              max: 1.0,
              onChanged: (val) => setState(() => _vignette = val),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Reset ke default
            setState(() {
              _selectedPreset = FilterPreset.normal;
              _brightness = 0.0;
              _contrast = 0.0;
              _saturation = 0.0;
              _vignette = 0.0;
            });
          },
          child: const Text('Reset', style: TextStyle(color: Colors.redAccent)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
          onPressed: () {
            final result = ColorAdjustmentModel(
              preset: _selectedPreset,
              brightness: _brightness,
              contrast: _contrast,
              saturation: _saturation,
              vignette: _vignette,
            );
            Navigator.pop(context, result);
          },
          child: const Text('Terapkan', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            thumbColor: Colors.deepPurpleAccent,
            activeTrackColor: Colors.deepPurpleAccent,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  String _getPresetName(FilterPreset preset) {
    switch (preset) {
      case FilterPreset.normal:
        return 'Normal';
      case FilterPreset.warm:
        return 'Warm';
      case FilterPreset.cool:
        return 'Cool';
      case FilterPreset.vintage:
        return 'Vintage';
      case FilterPreset.cinematic:
        return 'Cinematic';
      case FilterPreset.grayscale:
        return 'B&W (Grayscale)';
      case FilterPreset.sepia:
        return 'Sepia';
      case FilterPreset.vivid:
        return 'Vivid';
      case FilterPreset.faded:
        return 'Faded';
      case FilterPreset.monoContrast:
        return 'Mono Contrast';
      case FilterPreset.retroRolling:
        return 'Retro Rolling 🎞️';
      default:
        return preset.name;
    }
  }
}

