import 'package:flutter/material.dart';

class OutlinedText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final bool useOutline;
  final Color outlineColor;
  final double strokeWidth;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  const OutlinedText(
    this.text, {
    super.key,
    required this.style,
    required this.useOutline,
    required this.outlineColor,
    this.strokeWidth = 2.5,
    this.textAlign,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    if (!useOutline) {
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
      );
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Text(
          text,
          textAlign: textAlign,
          overflow: overflow,
          maxLines: maxLines,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..strokeJoin = StrokeJoin.round
              ..color = outlineColor,
            shadows: [],
          ),
        ),
        Text(
          text,
          textAlign: textAlign,
          overflow: overflow,
          maxLines: maxLines,
          style: style.copyWith(shadows: []),
        ),
      ],
    );
  }
}
