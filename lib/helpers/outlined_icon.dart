import 'package:flutter/material.dart';

class OutlinedIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final bool useOutline;
  final Color outlineColor;
  final double strokeWidth;

  const OutlinedIcon(
    this.icon, {
    super.key,
    required this.size,
    required this.color,
    required this.useOutline,
    required this.outlineColor,
    this.strokeWidth = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    if (!useOutline) {
      return Icon(icon, size: size, color: color);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Text(
          String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: size,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..strokeJoin = StrokeJoin.round
              ..color = outlineColor,
          ),
        ),
        Text(
          String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: size,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
            color: color,
          ),
        ),
      ],
    );
  }
}
