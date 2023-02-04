import 'package:flutter/material.dart';

class CustomTabIndicator extends Decoration {
  final BoxPainter _painter;

  CustomTabIndicator({
    required Color color,
    required double radius,
    required double rectangleWidth,
    required double rectangleHeight,
    required double verticalOffset,
  }) : _painter = _RRectPainter(
            color, radius, rectangleWidth, rectangleHeight, verticalOffset);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _RRectPainter extends BoxPainter {
  final Paint _paint;
  final double radius;
  final double rectangleWidth;
  final double rectangleHeight;
  final double verticalOffset;

  _RRectPainter(
    Color color,
    this.radius,
    this.rectangleWidth,
    this.rectangleHeight,
    this.verticalOffset,
  ) : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final rectangleCenterCoordinates = offset +
        Offset(
          cfg.size!.width / 2,
          cfg.size!.height - verticalOffset,
        );

    final Rect rect = Rect.fromCenter(
      center: rectangleCenterCoordinates,
      width: rectangleWidth,
      height: rectangleHeight,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        Radius.circular(radius),
      ),
      _paint,
    );
  }
}
