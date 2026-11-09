import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/utils/export_progress_calculator.dart';

void main() {
  group('P1-02 ExportProgressCalculator Unit Tests', () {
    test('1. Initial progress is 0.0', () {
      final prog = ExportProgressCalculator.calculateClipStageProgress(
        accumulatedDuration: 0.0,
        currentClipDuration: 10.0,
        currentClipProgress: 0.0,
        totalDuration: 20.0,
      );
      expect(prog, 0.0);
    });

    test('2. Progress increases proportionally and linearly across clips', () {
      // Total 20s, Klip 1 (10s) pada 50%
      final prog1 = ExportProgressCalculator.calculateClipStageProgress(
        accumulatedDuration: 0.0,
        currentClipDuration: 10.0,
        currentClipProgress: 0.5,
        totalDuration: 20.0,
      );
      // 5s / 20s * 0.85 = 0.2125
      expect(prog1, closeTo(0.2125, 0.001));

      // Klip 2 (10s) pada 50% (accumulated = 10s)
      final prog2 = ExportProgressCalculator.calculateClipStageProgress(
        accumulatedDuration: 10.0,
        currentClipDuration: 10.0,
        currentClipProgress: 0.5,
        totalDuration: 20.0,
      );
      // 15s / 20s * 0.85 = 0.6375
      expect(prog2, closeTo(0.6375, 0.001));
    });

    test('3. Progress clamping bounds to 0.85 during clip intermediate stage', () {
      final progOver = ExportProgressCalculator.calculateClipStageProgress(
        accumulatedDuration: 20.0,
        currentClipDuration: 10.0,
        currentClipProgress: 1.5,
        totalDuration: 20.0,
      );
      expect(progOver, equals(0.85));
    });

    test('4. Single clip statistics calculation is bounded between 0.0 and 1.0', () {
      expect(
        ExportProgressCalculator.calculateSingleClipProgress(timeMillis: 0, totalExpectedMillis: 5000),
        0.0,
      );
      expect(
        ExportProgressCalculator.calculateSingleClipProgress(timeMillis: 2500, totalExpectedMillis: 5000),
        0.5,
      );
      // Over-reporting by FFmpeg statistics does not exceed 1.0
      expect(
        ExportProgressCalculator.calculateSingleClipProgress(timeMillis: 7000, totalExpectedMillis: 5000),
        1.0,
      );
    });

    test('5. clampProgress handles NaN and infinity safely', () {
      expect(ExportProgressCalculator.clampProgress(double.nan), 0.0);
      expect(ExportProgressCalculator.clampProgress(double.infinity), 0.0);
      expect(ExportProgressCalculator.clampProgress(-0.5), 0.0);
      expect(ExportProgressCalculator.clampProgress(1.5), 1.0);
    });
  });
}

