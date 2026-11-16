import 'dart:ui';
import 'package:flutter/material.dart';

class MarchingAntsPainter extends CustomPainter {
  final double progress;
  final Color color;

  MarchingAntsPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRect(Rect.fromLTWH(2.0, 2.0, size.width - 4.0, size.height - 4.0));

    const dashWidth = 10.0;
    const dashSpace = 10.0;
    const distance = dashWidth + dashSpace;

    for (PathMetric metric in path.computeMetrics()) {
      double start = progress * distance;

      while (start < metric.length) {
        double end = start + dashWidth;
        double drawEnd = end > metric.length ? metric.length : end;

        canvas.drawPath(metric.extractPath(start, drawEnd), paint);

        if (end > metric.length) {
          canvas.drawPath(metric.extractPath(0.0, end - metric.length), paint);
        }
        start += distance;
      }
    }
  }

  @override
  bool shouldRepaint(covariant MarchingAntsPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
