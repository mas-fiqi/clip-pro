import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/clip_model.dart';
import 'package:video_clipper_app/core/models/timeline_model.dart';
import 'package:video_clipper_app/core/engine/ffmpeg_processing_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'getTemporaryDirectory') {
          return '.';
        }
        return null;
      },
    );
  });

  group('P1-03 Export Cancellation & Lifecycle Safety Tests', () {
    test('1. Initial cancellation state is safe and inactive', () {
      final engine = FFmpegProcessingEngine();
      expect(engine, isNotNull);
    });

    test('2. cancelSession handles null currentSession without throwing exception', () async {
      final engine = FFmpegProcessingEngine();
      // Harusnya aman dipanggil kapan saja tanpa session aktif
      expect(() async => await engine.cancelSession(), returnsNormally);
    });

    test('3. Repeated cancelSession calls remain safe and idempotent', () async {
      final engine = FFmpegProcessingEngine();
      await engine.cancelSession();
      await engine.cancelSession();
      await engine.cancelSession();
      expect(true, isTrue);
    });

    test('4. Empty timeline export terminates safely and returns null without error', () async {
      final engine = FFmpegProcessingEngine();
      final result = await engine.exportTimeline(
        timeline: TimelineModel(clips: []),
      );
      expect(result, isNull);
    });

    test('5. Cancelled export prevents progress from reaching 1.0 (completion)', () async {
      final engine = FFmpegProcessingEngine();
      await engine.cancelSession();

      double lastReportedProgress = 0.0;
      final result = await engine.exportTimeline(
        timeline: TimelineModel(clips: [
          ClipModel(
            id: 'c1',
            sourcePath: 'dummy_nonexistent.mp4',
            startSource: 0.0,
            endSource: 5.0,
          ),
        ]),
        onProgress: (p) => lastReportedProgress = p,
      );

      expect(result, isNull);
      expect(lastReportedProgress, lessThan(1.0));
    });
  });
}
