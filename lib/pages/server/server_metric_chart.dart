part of 'server_metric_sections.dart';

class _TrendLine extends StatelessWidget {
  final List<double> values;

  const _TrendLine({required this.values});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: CustomPaint(
        painter: _TrendPainter(
          values: values,
          color: Theme.of(context).colorScheme.primary,
          trackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final Color trackColor;

  const _TrendPainter({
    required this.values,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = trackColor
      ..strokeWidth = 1;
    for (final y in [0.25, 0.5, 0.75]) {
      canvas.drawLine(
        Offset(0, size.height * y),
        Offset(size.width, size.height * y),
        grid,
      );
    }
    if (values.length < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i * size.width / (values.length - 1);
      final y = size.height * (1 - values[i].clamp(0, 1));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}

String _part(List<String> parts, int index) {
  return index < parts.length && parts[index].isNotEmpty ? parts[index] : '-';
}

List<double> _trend(double value) {
  return [value.clamp(0, 1).toDouble(), value.clamp(0, 1).toDouble()];
}

List<double> _metricTrend(
  List<ServerStatus> history,
  double Function(ServerStatus status) read,
  double fallback,
) {
  final values = [
    for (final status in history) read(status).clamp(0, 1).toDouble(),
  ];
  return values.length >= 2 ? values : _trend(fallback);
}

List<double> _networkTrend(List<ServerStatus> history, ServerStatus? current) {
  final samples = history.isNotEmpty
      ? history
      : current == null
      ? const <ServerStatus>[]
      : [current];
  final max = [
    for (final status in samples) status.netDownRate + status.netUpRate,
    1.0,
  ].reduce((a, b) => a > b ? a : b);
  final values = [
    for (final status in samples)
      ((status.netDownRate + status.netUpRate) / max).clamp(0, 1).toDouble(),
  ];
  return values.length >= 2
      ? values
      : _trend(values.isEmpty ? 0 : values.first);
}
