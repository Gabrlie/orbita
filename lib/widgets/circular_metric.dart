import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Circular progress ring with percentage label and subtitle.
class CircularMetric extends StatelessWidget {
  final String label;
  final double percent;
  final String subtitle;
  final double size;

  const CircularMetric({
    super.key,
    required this.label,
    required this.percent,
    required this.subtitle,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorForPercent(percent, theme);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
        const SizedBox(height: 6),
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(
              percent: percent,
              color: color,
              trackColor: theme.colorScheme.surfaceContainerHighest,
            ),
            child: Center(
              child: Text(
                '${(percent * 100).round()}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
            )),
      ],
    );
  }

  Color _colorForPercent(double p, ThemeData theme) {
    if (p > 0.9) return theme.colorScheme.error;
    if (p > 0.75) return Colors.deepOrange;
    if (p > 0.6) return Colors.orange;
    if (p > 0.4) return Colors.amber.shade700;
    if (p > 0.2) return theme.colorScheme.primary;
    return theme.colorScheme.tertiary;
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final Color color;
  final Color trackColor;

  _RingPainter({
    required this.percent,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - 6) / 2;
    const strokeWidth = 4.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * percent.clamp(0, 1),
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.percent != percent || old.color != color;
}
