import 'animation_model.dart';
import 'audio_effect_model.dart';
import 'clip_transform_model.dart';
import 'color_adjustment_model.dart';
import 'keyframe_model.dart';
import 'quality_enhancement_model.dart';
import 'retouch_model.dart';
import 'speed_config_model.dart';
import 'video_effect_model.dart';

/// Representasi satu potongan klip video dalam proyek.
class ClipModel {
  final String id;
  final String sourcePath;
  final double startSource; // dalam detik
  final double endSource;   // dalam detik
  final double volume;      // 0.0 - 1.0 (default 1.0)
  final double speed;       // faktor kecepatan playback (default 1.0)
  final SpeedConfigModel speedConfig; // konfigurasi kecepatan profesional (Normal & Speed Curve)
  final ClipTransformModel transform; // konfigurasi crop, ratio, rotation, flip
  final ColorAdjustmentModel adjustment; // filter preset, brightness, contrast, vignette
  final VideoEffectModel effect; // efek visual khusus per klip
  final RetouchModel retouch; // modul beauty retouch wajah & tubuh
  final AudioEffectModel audioEffect; // modul audio studio, voice effect & enhancement
  final ClipAnimationModel animation; // modul Animation Studio CapCut Style
  final QualityEnhancementModel quality; // modul peningkatan kualitas (Denoise, Deshake, Deflicker)
  final List<KeyframeModel> keyframes; // Titik keyframe animasi dinamis

  ClipModel({
    required this.id,
    required this.sourcePath,
    required this.startSource,
    required this.endSource,
    this.volume = 1.0,
    this.speed = 1.0,
    this.speedConfig = const SpeedConfigModel(),
    this.transform = const ClipTransformModel(),
    this.adjustment = const ColorAdjustmentModel(),
    this.effect = const VideoEffectModel(),
    this.retouch = const RetouchModel(),
    this.audioEffect = const AudioEffectModel(),
    this.animation = const ClipAnimationModel(),
    this.quality = const QualityEnhancementModel(),
    this.keyframes = const [],
  }) {
    assert(id.isNotEmpty, 'ID klip tidak boleh kosong');
    assert(sourcePath.isNotEmpty, 'sourcePath tidak boleh kosong');
    assert(startSource >= 0, 'startSource tidak boleh negatif');
    assert(endSource > startSource, 'endSource harus lebih besar dari startSource');
    assert(volume >= 0.0 && volume <= 1.0, 'volume harus berada di antara 0.0 dan 1.0');
    assert(speed > 0.0, 'speed harus lebih besar dari 0');
  }

  /// Durasi riil dari segmen sumber yang dipotong (dalam detik)
  double get sourceDuration => endSource - startSource;

  /// Durasi output pada timeline setelah memperhitungkan kecepatan (speed atau kurva)
  double get timelineDuration {
    final effective = speedConfig.isCurveMode ? speedConfig.effectiveSpeed : speed;
    return sourceDuration / (effective > 0 ? effective : 1.0);
  }

  ClipModel copyWith({
    String? id,
    String? sourcePath,
    double? startSource,
    double? endSource,
    double? volume,
    double? speed,
    SpeedConfigModel? speedConfig,
    ClipTransformModel? transform,
    ColorAdjustmentModel? adjustment,
    VideoEffectModel? effect,
    RetouchModel? retouch,
    AudioEffectModel? audioEffect,
    ClipAnimationModel? animation,
    QualityEnhancementModel? quality,
    List<KeyframeModel>? keyframes,
  }) {
    return ClipModel(
      id: id ?? this.id,
      sourcePath: sourcePath ?? this.sourcePath,
      startSource: startSource ?? this.startSource,
      endSource: endSource ?? this.endSource,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
      speedConfig: speedConfig ?? this.speedConfig,
      transform: transform ?? this.transform,
      adjustment: adjustment ?? this.adjustment,
      effect: effect ?? this.effect,
      retouch: retouch ?? this.retouch,
      audioEffect: audioEffect ?? this.audioEffect,
      animation: animation ?? this.animation,
      quality: quality ?? this.quality,
      keyframes: keyframes ?? this.keyframes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourcePath': sourcePath,
      'startSource': startSource,
      'endSource': endSource,
      'volume': volume,
      'speed': speed,
      'speedConfig': speedConfig.toJson(),
      'transform': transform.toJson(),
      'adjustment': adjustment.toJson(),
      'effect': effect.toJson(),
      'retouch': retouch.toJson(),
      'audioEffect': audioEffect.toJson(),
      'animation': animation.toJson(),
      'quality': quality.toJson(),
      'keyframes': keyframes.map((k) => k.toJson()).toList(),
    };
  }

  factory ClipModel.fromJson(Map<String, dynamic> json) {
    return ClipModel(
      id: json['id'] as String,
      sourcePath: json['sourcePath'] as String,
      startSource: (json['startSource'] as num).toDouble(),
      endSource: (json['endSource'] as num).toDouble(),
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      speed: (json['speed'] as num?)?.toDouble() ?? 1.0,
      speedConfig: json['speedConfig'] != null
          ? SpeedConfigModel.fromJson(json['speedConfig'] as Map<String, dynamic>)
          : SpeedConfigModel(normalSpeed: (json['speed'] as num?)?.toDouble() ?? 1.0),
      transform: json['transform'] != null
          ? ClipTransformModel.fromJson(json['transform'] as Map<String, dynamic>)
          : const ClipTransformModel(),
      adjustment: json['adjustment'] != null
          ? ColorAdjustmentModel.fromJson(json['adjustment'] as Map<String, dynamic>)
          : const ColorAdjustmentModel(),
      effect: json['effect'] != null
          ? VideoEffectModel.fromJson(json['effect'] as Map<String, dynamic>)
          : const VideoEffectModel(),
      retouch: json['retouch'] != null
          ? RetouchModel.fromJson(json['retouch'] as Map<String, dynamic>)
          : const RetouchModel(),
      audioEffect: json['audioEffect'] != null
          ? AudioEffectModel.fromJson(json['audioEffect'] as Map<String, dynamic>)
          : const AudioEffectModel(),
      animation: json['animation'] != null
          ? ClipAnimationModel.fromJson(json['animation'] as Map<String, dynamic>)
          : const ClipAnimationModel(),
      quality: json['quality'] != null
          ? QualityEnhancementModel.fromJson(json['quality'] as Map<String, dynamic>)
          : const QualityEnhancementModel(),
      keyframes: json['keyframes'] != null
          ? (json['keyframes'] as List)
              .map((k) => KeyframeModel.fromJson(k as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }
}
