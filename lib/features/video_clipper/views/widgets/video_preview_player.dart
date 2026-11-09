import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewPlayer extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoPreviewPlayer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(controller),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (controller.value.isPlaying) {
                controller.pause();
              } else {
                controller.play();
              }
            },
            child: AnimatedOpacity(
              opacity: controller.value.isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.play_arrow,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

