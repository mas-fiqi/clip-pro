import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/models/overlay_model.dart';

class InteractiveOverlayLayer extends StatelessWidget {
  final List<OverlayModel> overlays;
  final double currentGlobalTime;
  final String? selectedOverlayId;
  final ValueChanged<String> onSelectOverlay;
  final void Function(String overlayId, double deltaNormX, double deltaNormY) onDragOverlay;

  const InteractiveOverlayLayer({
    super.key,
    required this.overlays,
    required this.currentGlobalTime,
    required this.selectedOverlayId,
    required this.onSelectOverlay,
    required this.onDragOverlay,
  });

  @override
  Widget build(BuildContext context) {
    final activeOverlays = overlays.where((o) => o.isActiveAt(currentGlobalTime)).toList()
      ..sort((a, b) => a.layerOrder.compareTo(b.layerOrder));

    if (activeOverlays.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          fit: StackFit.expand,
          children: activeOverlays.map((overlay) {
            final posX = (overlay.normalizedX * w).clamp(0.0, w);
            final posY = (overlay.normalizedY * h).clamp(0.0, h);
            final isSelected = overlay.id == selectedOverlayId;

            Widget contentWidget;

            if (overlay.type == OverlayType.image) {
              final file = File(overlay.content);
              contentWidget = file.existsSync()
                  ? Image.file(
                      file,
                      width: 140 * overlay.scale,
                      height: 140 * overlay.scale,
                      fit: BoxFit.contain,
                    )
                  : Container(
                      width: 100,
                      height: 100,
                      color: Colors.white24,
                      child: const Icon(Icons.broken_image_rounded, color: Colors.white),
                    );
            } else if (overlay.type == OverlayType.video) {
              final file = File(overlay.content);
              contentWidget = Container(
                width: 160 * overlay.scale,
                height: 100 * overlay.scale,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.videocam_rounded, color: Color(0xFF00E5FF), size: 36),
                    Positioned(
                      bottom: 4,
                      left: 6,
                      right: 6,
                      child: Text(
                        file.uri.pathSegments.last,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Teks, Stiker, atau Subtitle
              contentWidget = Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: overlay.backgroundColorHex != null
                      ? Color(int.parse('FF${overlay.backgroundColorHex}', radix: 16)).withValues(alpha: overlay.opacity)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  overlay.content,
                  style: TextStyle(
                    fontSize: overlay.fontSize,
                    fontWeight: overlay.presetStyle == TextPresetStyle.bold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(int.parse('FF${overlay.textColorHex}', radix: 16))
                        .withValues(alpha: overlay.opacity),
                    shadows: overlay.presetStyle == TextPresetStyle.shadow
                        ? const [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 4,
                              color: Colors.black,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }

            return Positioned(
              left: posX,
              top: posY,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Transform.rotate(
                  angle: (overlay.rotationDegrees * 3.141592653589793) / 180.0,
                  child: Opacity(
                    opacity: overlay.opacity.clamp(0.0, 1.0),
                    child: GestureDetector(
                      onTap: () => onSelectOverlay(overlay.id),
                      onPanUpdate: (details) {
                        final deltaNormX = details.delta.dx / w;
                        final deltaNormY = details.delta.dy / h;
                        onDragOverlay(overlay.id, deltaNormX, deltaNormY);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border.all(color: const Color(0xFF00E5FF), width: 2)
                              : null,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: contentWidget,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
