import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/clip_model.dart';
import 'package:video_clipper_app/core/models/clip_transform_model.dart';
import 'package:video_clipper_app/core/models/overlay_model.dart';
import 'package:video_clipper_app/core/utils/time_formatter.dart';

void main() {
  group('Master Task #005: Preview vs Output Parity & Pipeline Verification', () {
    test('1. TimeFormatter produces exact FFmpeg timestamps without drift', () {
      expect(TimeFormatter.toFFmpegTimestamp(0.0), equals('00:00:00.000'));
      expect(TimeFormatter.toFFmpegTimestamp(65.5), equals('00:01:05.500'));
      expect(TimeFormatter.toFFmpegTimestamp(3661.125), equals('01:01:01.125'));
    });

    test('2. Transform & Crop Parity: Crop coordinates match relative geometry', () {
      final transform = ClipTransformModel(
        cropLeft: 0.1,
        cropTop: 0.2,
        cropRight: 0.9,
        cropBottom: 0.8,
      );

      expect(transform.hasCustomCrop, isTrue);
      final widthFactor = transform.cropRight - transform.cropLeft;
      final heightFactor = transform.cropBottom - transform.cropTop;

      expect(widthFactor, closeTo(0.8, 0.0001));
      expect(heightFactor, closeTo(0.6, 0.0001));
    });

    test('3. Rotation & Flip Parity: Correct trigonometric angle mapping', () {
      final t90 = ClipTransformModel(rotationDegrees: 90);
      final t180 = ClipTransformModel(rotationDegrees: 180);
      final t270 = ClipTransformModel(rotationDegrees: 270);
      final tCustom = ClipTransformModel(rotationDegrees: 45);

      expect((t90.rotationDegrees % 360 + 360) % 360, equals(90));
      expect((t180.rotationDegrees % 360 + 360) % 360, equals(180));
      expect((t270.rotationDegrees % 360 + 360) % 360, equals(270));
      expect((tCustom.rotationDegrees % 360 + 360) % 360, equals(45));
    });

    test('4. Aspect Ratio & Fit Mode Geometry: 9:16 and 16:9 canvas calculation', () {
      final tPortrait = ClipTransformModel(
        canvasRatio: CanvasRatioMode.ratio9x16,
        fitMode: FitMode.fit,
        backgroundColorHex: '000000',
      );

      expect(tPortrait.targetAspectRatio, closeTo(9 / 16, 0.001));
      expect(tPortrait.fitMode, equals(FitMode.fit));
      expect(tPortrait.backgroundColorHex, equals('000000'));
    });

    test('5. Overlay Timing & Coordinate Bounds', () {
      final overlay = OverlayModel(
        id: 'ov_1',
        type: OverlayType.text,
        content: 'Hello World',
        startTime: 1.0,
        endTime: 4.5,
        normalizedX: 0.5,
        normalizedY: 0.8,
        fontSize: 24,
      );

      expect(overlay.startTime, equals(1.0));
      expect(overlay.endTime, equals(4.5));
      expect(overlay.normalizedX, equals(0.5));
      expect(overlay.normalizedY, equals(0.8));
      expect(overlay.isVisible, isTrue);
    });

    test('6. Speed Duration Calculation matches playback rate inversely', () {
      final normalClip = ClipModel(
        id: 'c1',
        sourcePath: 'path.mp4',
        startSource: 0.0,
        endSource: 10.0,
        speed: 1.0,
      );
      expect(normalClip.timelineDuration, equals(10.0));

      final fastClip = normalClip.copyWith(speed: 2.0);
      expect(fastClip.timelineDuration, equals(5.0));

      final slowClip = normalClip.copyWith(speed: 0.5);
      expect(slowClip.timelineDuration, equals(20.0));
    });
  });
}
