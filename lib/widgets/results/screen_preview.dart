import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../models/configuration_result.dart';
import '../../models/product.dart';

class ScreenPreview extends StatelessWidget {
  final ConfigurationResult result;
  final Product? selectedProduct;
  final Product? selectedProduct2;
  final bool isComparing;
  final ConfigurationResult? result2;
  final ui.Image? screenBackgroundImage;
  final ui.Image? maleImage;
  final ui.Image? femaleImage;
  final double viewportHeight;

  const ScreenPreview({
    super.key,
    required this.result,
    required this.isComparing,
    this.selectedProduct,
    this.selectedProduct2,
    this.result2,
    this.screenBackgroundImage,
    this.maleImage,
    this.femaleImage,
    this.viewportHeight = 250.0,
  });

  @override
  Widget build(BuildContext context) {
    if (result.tilesHorizontal <= 0 || result.tilesVertical <= 0) {
      return const SizedBox.shrink();
    }

    final activeProduct = (isComparing && result2 == result) ? selectedProduct2 : selectedProduct;
    if (activeProduct == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidthMeters = result.width;
        final double screenHeightMeters = result.height;
        const double figureHeightMeters = 1.8;
        const double figureAspectRatio = 0.4;

        final viewportWidth = constraints.maxWidth;
        const double padding = 16.0;

        return Column(
          children: [
            Container(
              height: viewportHeight,
              width: viewportWidth,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.hardEdge,
              child: Padding(
                padding: const EdgeInsets.all(padding),
                child: LayoutBuilder(
                  builder: (context, paddedConstraints) {
                    final double availableWidth = paddedConstraints.maxWidth;
                    final double availableHeight = paddedConstraints.maxHeight;

                    final double maxSceneHeightMeters = max(screenHeightMeters, figureHeightMeters);
                    final double figureWidthMeters = figureHeightMeters * figureAspectRatio;
                    final double totalSceneWidthMeters = screenWidthMeters + (2 * figureWidthMeters);

                    final double scaleByHeight = availableHeight / maxSceneHeightMeters;
                    final double scaleByWidth = availableWidth / totalSceneWidthMeters;
                    final double pixelsPerMeter = min(scaleByHeight, scaleByWidth);

                    final double screenPreviewHeight = screenHeightMeters * pixelsPerMeter;
                    final double screenPreviewWidth = screenWidthMeters * pixelsPerMeter;
                    final double figureHeightPixels = figureHeightMeters * pixelsPerMeter;

                    final screenWidget = SizedBox(
                      width: screenPreviewWidth,
                      height: screenPreviewHeight,
                      child: CustomPaint(
                        painter: _GridPainter(
                          tilesHorizontal: result.tilesHorizontal,
                          tilesVertical: result.tilesVertical,
                          backgroundImage: screenBackgroundImage,
                        ),
                      ),
                    );

                    final figureWidget = (ui.Image? image) => image != null
                        ? RawImage(
                            image: image,
                            height: figureHeightPixels,
                            fit: BoxFit.contain,
                          )
                        : SizedBox(height: figureHeightPixels);

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        figureWidget(femaleImage),
                        screenWidget,
                        figureWidget(maleImage),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Text('Horizontal: ${result.tilesHorizontal} tiles'),
                Text('Vertical: ${result.tilesVertical} tiles'),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  final int tilesHorizontal;
  final int tilesVertical;
  final ui.Image? backgroundImage;
  final Paint gridPaint;

  _GridPainter({
    required this.tilesHorizontal,
    required this.tilesVertical,
    this.backgroundImage,
  }) : gridPaint = Paint()
          ..color = Colors.orange.withOpacity(0.5)
          ..strokeWidth = 0.5;

  @override
  void paint(Canvas canvas, Size size) {
    if (tilesHorizontal <= 0 || tilesVertical <= 0) return;

    if (backgroundImage != null) {
      final imgWidth = backgroundImage!.width.toDouble();
      final imgHeight = backgroundImage!.height.toDouble();
      final imgRatio = imgWidth / imgHeight;
      final canvasRatio = size.width / size.height;

      Rect srcRect;
      Rect dstRect = Rect.fromLTWH(0, 0, size.width, size.height);

      if (imgRatio > canvasRatio) {
        final newWidth = imgHeight * canvasRatio;
        srcRect = Rect.fromLTWH((imgWidth - newWidth) / 2, 0, newWidth, imgHeight);
      } else {
        final newHeight = imgWidth / canvasRatio;
        srcRect = Rect.fromLTWH(0, (imgHeight - newHeight) / 2, imgWidth, newHeight);
      }

      canvas.drawImageRect(backgroundImage!, srcRect, dstRect, Paint());
    }

    final double tileWidth = size.width / tilesHorizontal;
    final double tileHeight = size.height / tilesVertical;

    for (int i = 0; i < tilesHorizontal; i++) {
      for (int j = 0; j < tilesVertical; j++) {
        final rect = Rect.fromLTWH(
          i * tileWidth,
          j * tileHeight,
          tileWidth,
          tileHeight,
        );
        canvas.drawRect(rect, gridPaint..style = PaintingStyle.stroke);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) {
    return oldDelegate.tilesHorizontal != tilesHorizontal ||
           oldDelegate.tilesVertical != tilesVertical ||
           oldDelegate.backgroundImage != backgroundImage;
  }
  
  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) => false;
} 