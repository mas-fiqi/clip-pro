import 'package:flutter/material.dart';
import '../../../../core/utils/time_formatter.dart';

class TrimRangeSlider extends StatelessWidget {
  final double duration;
  final RangeValues currentRange;
  final ValueChanged<RangeValues> onChanged;
  final ValueChanged<RangeValues>? onChangeEnd;

  const TrimRangeSlider({
    super.key,
    required this.duration,
    required this.currentRange,
    required this.onChanged,
    this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    if (duration <= 0) return const SizedBox.shrink();

    final clipDuration = currentRange.end - currentRange.start;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mulai: ${TimeFormatter.formatSeconds(currentRange.start)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Durasi: ${TimeFormatter.formatSeconds(clipDuration)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
              Text(
                'Selesai: ${TimeFormatter.formatSeconds(currentRange.end)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        RangeSlider(
          values: currentRange,
          min: 0.0,
          max: duration,
          divisions: duration > 1 ? duration.toInt() : 1,
          labels: RangeLabels(
            TimeFormatter.formatSeconds(currentRange.start),
            TimeFormatter.formatSeconds(currentRange.end),
          ),
          onChanged: (newRange) {
            // Beri batas minimal potong misal 1 detik
            if (newRange.end - newRange.start >= 1.0) {
              onChanged(newRange);
            }
          },
          onChangeEnd: onChangeEnd,
        ),
      ],
    );
  }
}

