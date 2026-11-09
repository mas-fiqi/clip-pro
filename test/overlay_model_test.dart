import 'package:flutter_test/flutter_test.dart';
import 'package:video_clipper_app/core/models/overlay_model.dart';
import 'package:video_clipper_app/core/models/timeline_model.dart';
import 'package:video_clipper_app/core/models/clip_model.dart';

void main() {
  group('OverlayModel & Timeline Multi-Layer Tests', () {
    test('Validasi aktivasi overlay berdasarkan rentang waktu global', () {
      const textOverlay = OverlayModel(
        id: 'o1',
        type: OverlayType.text,
        content: 'Judul Video 🔥',
        startTime: 2.0,
        endTime: 6.0,
      );

      expect(textOverlay.isActiveAt(1.0), isFalse); // sebelum
      expect(textOverlay.isActiveAt(2.0), isTrue);  // tepat mulai
      expect(textOverlay.isActiveAt(4.5), isTrue);  // di tengah
      expect(textOverlay.isActiveAt(6.0), isTrue);  // tepat akhir
      expect(textOverlay.isActiveAt(7.0), isFalse); // sesudah
    });

    test('Validasi assertion endTime > startTime', () {
      expect(
        () => OverlayModel(
          id: 'err_overlay',
          type: OverlayType.text,
          content: 'Error',
          startTime: 5.0,
          endTime: 2.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('Manajemen penambahan, pengubahan, dan penghapusan overlay di TimelineModel', () {
      final clip = ClipModel(id: 'c1', sourcePath: '/v.mp4', startSource: 0, endSource: 10);
      const o1 = OverlayModel(
        id: 'text_1',
        type: OverlayType.text,
        content: 'Halo Dunia',
        startTime: 0.0,
        endTime: 4.0,
      );

      var timeline = TimelineModel(clips: [clip]).addOverlay(o1);
      expect(timeline.overlays.length, 1);
      expect(timeline.overlays.first.content, 'Halo Dunia');

      // Update posisi drag
      final updatedO1 = o1.copyWith(normalizedX: 0.25, normalizedY: 0.75);
      timeline = timeline.updateOverlay(updatedO1);
      expect(timeline.overlays.first.normalizedX, 0.25);
      expect(timeline.overlays.first.normalizedY, 0.75);

      // Hapus overlay
      timeline = timeline.removeOverlay('text_1');
      expect(timeline.overlays.isEmpty, isTrue);
    });

    test('Serialisasi dan deserialisasi JSON OverlayModel', () {
      const overlay = OverlayModel(
        id: 'sticker_1',
        type: OverlayType.sticker,
        content: '⭐',
        startTime: 1.0,
        endTime: 5.0,
        presetStyle: TextPresetStyle.bold,
        textColorHex: 'FFEE58',
        backgroundColorHex: '000000',
      );

      final json = overlay.toJson();
      final restored = OverlayModel.fromJson(json);

      expect(restored.id, 'sticker_1');
      expect(restored.type, OverlayType.sticker);
      expect(restored.content, '⭐');
      expect(restored.presetStyle, TextPresetStyle.bold);
      expect(restored.textColorHex, 'FFEE58');
      expect(restored.backgroundColorHex, '000000');
    });
  });
}

