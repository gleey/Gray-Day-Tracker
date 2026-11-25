import 'dart:math';
import 'package:flutter/material.dart';

class CircularProgress extends StatelessWidget {
  final int days;
  final int targetDays;
  final List<Color> gradient;
  final double size;
  final double strokeWidth;

  const CircularProgress({
    super.key,
    required this.days,
    this.targetDays = 30,
    required this.gradient,
    this.size = 90,
    this.strokeWidth = 8,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (days / targetDays).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CircularPainter(
          progress: progress,
          gradient: gradient,
          strokeWidth: strokeWidth,
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$days',
                style: TextStyle(
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w800,
                  color: gradient[0],
                  height: 1.1,
                ),
              ),
              Text(
                'hari',
                style: TextStyle(
                  fontSize: size * 0.13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircularPainter extends CustomPainter {
  final double progress;
  final List<Color> gradient;
  final double strokeWidth;
  final Color backgroundColor;

  _CircularPainter({
    required this.progress,
    required this.gradient,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    // Gradient arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepAngle = 2 * pi * progress;

    final gradientPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: -pi / 2 + sweepAngle,
        colors: [gradient[0], gradient[1], gradient[0]],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -pi / 2, sweepAngle, false, gradientPaint);
  }

  @override
  bool shouldRepaint(covariant _CircularPainter old) =>
      old.progress != progress;
}
