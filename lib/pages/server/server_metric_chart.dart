part of 'server_metric_sections.dart';

class _TrendLine extends StatelessWidget {
  final List<_TrendSample> values;
  final Color? color;

  const _TrendLine({required this.values, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      width: double.infinity,
      child: CustomPaint(
        painter: _TrendPainter(
          samples: values,
          color: color ?? Theme.of(context).colorScheme.primary,
          axisColor: Theme.of(context).colorScheme.onSurfaceVariant,
          gridColor: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }
}

class _NetworkTrendLine extends StatelessWidget {
  final List<_NetworkTrendSample> values;
  final Color uploadColor;
  final Color downloadColor;

  const _NetworkTrendLine({
    required this.values,
    required this.uploadColor,
    required this.downloadColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 164,
      width: double.infinity,
      child: CustomPaint(
        painter: _NetworkTrendPainter(
          samples: values,
          uploadColor: uploadColor,
          downloadColor: downloadColor,
          axisColor: Theme.of(context).colorScheme.onSurfaceVariant,
          gridColor: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }
}

class _TrendSample {
  final DateTime time;
  final double value;

  const _TrendSample({required this.time, required this.value});
}

class _NetworkTrendSample {
  final DateTime time;
  final double uploadRate;
  final double downloadRate;

  const _NetworkTrendSample({
    required this.time,
    required this.uploadRate,
    required this.downloadRate,
  });
}

class _TrendPainter extends CustomPainter {
  final List<_TrendSample> samples;
  final Color color;
  final Color axisColor;
  final Color gridColor;

  const _TrendPainter({
    required this.samples,
    required this.color,
    required this.axisColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const left = 42.0;
    const right = 4.0;
    const top = 4.0;
    const bottom = 18.0;
    final chart = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );
    if (chart.width <= 0 || chart.height <= 0) return;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final axisPaint = Paint()
      ..color = axisColor.withAlpha(120)
      ..strokeWidth = 1;

    for (var i = 0; i <= 5; i++) {
      final y = chart.bottom - chart.height * i / 5;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
      _drawLabel(
        canvas,
        '${i * 20}%',
        Offset(0, y - 6),
        axisColor,
        width: left - 6,
        align: TextAlign.right,
      );
    }
    canvas.drawLine(chart.bottomLeft, chart.topLeft, axisPaint);
    canvas.drawLine(chart.bottomLeft, chart.bottomRight, axisPaint);

    final visible = _visibleSamples(samples);
    if (visible.isEmpty) return;

    for (var i = 0; i < visible.length; i++) {
      final x = _xForIndex(chart, i, visible.length);
      canvas.drawLine(Offset(x, chart.top), Offset(x, chart.bottom), gridPaint);
      _drawLabel(
        canvas,
        _timeLabel(visible[i].time),
        Offset(x - 22, chart.bottom + 4),
        axisColor,
        width: 44,
        align: TextAlign.center,
      );
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    for (var i = 0; i < visible.length; i++) {
      final point = _pointForSample(chart, visible[i], i, visible.length);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    if (visible.length > 1) canvas.drawPath(path, linePaint);
    for (var i = 0; i < visible.length; i++) {
      canvas.drawCircle(
        _pointForSample(chart, visible[i], i, visible.length),
        2.5,
        fillPaint,
      );
    }
  }

  Offset _pointForSample(
    Rect chart,
    _TrendSample sample,
    int index,
    int count,
  ) {
    final x = _xForIndex(chart, index, count);
    final y = chart.bottom - chart.height * sample.value.clamp(0, 1);
    return Offset(x, y);
  }

  double _xForIndex(Rect chart, int index, int count) {
    if (count <= 1) return chart.right;
    return chart.left + chart.width * index / (count - 1);
  }

  List<_TrendSample> _visibleSamples(List<_TrendSample> source) {
    if (source.length <= 6) return source;
    return source.sublist(source.length - 6);
  }

  String _timeLabel(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset offset,
    Color color, {
    required double width,
    required TextAlign align,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 10),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(minWidth: width, maxWidth: width);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.samples != samples ||
        oldDelegate.color != color ||
        oldDelegate.axisColor != axisColor ||
        oldDelegate.gridColor != gridColor;
  }
}

class _NetworkTrendPainter extends CustomPainter {
  final List<_NetworkTrendSample> samples;
  final Color uploadColor;
  final Color downloadColor;
  final Color axisColor;
  final Color gridColor;

  const _NetworkTrendPainter({
    required this.samples,
    required this.uploadColor,
    required this.downloadColor,
    required this.axisColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const left = 42.0;
    const right = 4.0;
    const top = 4.0;
    const bottom = 18.0;
    final chart = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );
    if (chart.width <= 0 || chart.height <= 0) return;

    final visible = _visibleSamples(samples);
    final maxRate = _networkMaxRate(visible);
    final unit = _rateUnitFor(maxRate);
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final axisPaint = Paint()
      ..color = axisColor.withAlpha(120)
      ..strokeWidth = 1;

    for (var i = 0; i <= 5; i++) {
      final y = chart.bottom - chart.height * i / 5;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
      _drawAxisLabel(
        canvas,
        _formatRateAxis(maxRate * i / 5, unit),
        Offset(0, y - 6),
        axisColor,
        width: left - 6,
      );
    }
    canvas.drawLine(chart.bottomLeft, chart.topLeft, axisPaint);
    canvas.drawLine(chart.bottomLeft, chart.bottomRight, axisPaint);

    if (visible.isEmpty) return;

    for (var i = 0; i < visible.length; i++) {
      final x = _xForIndex(chart, i, visible.length);
      canvas.drawLine(Offset(x, chart.top), Offset(x, chart.bottom), gridPaint);
      _drawAxisLabel(
        canvas,
        _timeLabel(visible[i].time),
        Offset(x - 22, chart.bottom + 4),
        axisColor,
        width: 44,
        align: TextAlign.center,
      );
    }

    _drawRatePath(
      canvas,
      chart,
      visible,
      maxRate,
      uploadColor,
      (sample) => sample.uploadRate,
    );
    _drawRatePath(
      canvas,
      chart,
      visible,
      maxRate,
      downloadColor,
      (sample) => sample.downloadRate,
    );
  }

  void _drawRatePath(
    Canvas canvas,
    Rect chart,
    List<_NetworkTrendSample> visible,
    double maxRate,
    Color color,
    double Function(_NetworkTrendSample sample) read,
  ) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fillPaint = Paint()..color = color;
    final path = Path();
    for (var i = 0; i < visible.length; i++) {
      final x = _xForIndex(chart, i, visible.length);
      final value = maxRate <= 0 ? 0.0 : read(visible[i]) / maxRate;
      final y = chart.bottom - chart.height * value.clamp(0, 1);
      final point = Offset(x, y);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    if (visible.length > 1) canvas.drawPath(path, linePaint);
    for (var i = 0; i < visible.length; i++) {
      final x = _xForIndex(chart, i, visible.length);
      final value = maxRate <= 0 ? 0.0 : read(visible[i]) / maxRate;
      final y = chart.bottom - chart.height * value.clamp(0, 1);
      canvas.drawCircle(Offset(x, y), 2.5, fillPaint);
    }
  }

  double _xForIndex(Rect chart, int index, int count) {
    if (count <= 1) return chart.right;
    return chart.left + chart.width * index / (count - 1);
  }

  List<_NetworkTrendSample> _visibleSamples(
    List<_NetworkTrendSample> source,
  ) {
    if (source.length <= 6) return source;
    return source.sublist(source.length - 6);
  }

  String _timeLabel(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _drawAxisLabel(
    Canvas canvas,
    String text,
    Offset offset,
    Color color, {
    required double width,
    TextAlign align = TextAlign.right,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 10),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(minWidth: width, maxWidth: width);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _NetworkTrendPainter oldDelegate) {
    return oldDelegate.samples != samples ||
        oldDelegate.uploadColor != uploadColor ||
        oldDelegate.downloadColor != downloadColor ||
        oldDelegate.axisColor != axisColor ||
        oldDelegate.gridColor != gridColor;
  }
}

String _part(List<String> parts, int index) {
  return index < parts.length && parts[index].isNotEmpty ? parts[index] : '-';
}

List<_TrendSample> _trend(double value) {
  return [
    _TrendSample(time: DateTime.now(), value: value.clamp(0, 1).toDouble()),
  ];
}

List<_TrendSample> _metricTrend(
  List<ServerStatus> history,
  double Function(ServerStatus status) read,
  double fallback,
) {
  final values = [
    for (final status in history)
      _TrendSample(
        time: status.snapshot.timestamp,
        value: read(status).clamp(0, 1).toDouble(),
      ),
  ];
  return values.isNotEmpty ? values : _trend(fallback);
}

List<_NetworkTrendSample> _networkTrendSamples(
  List<ServerStatus> history,
  ServerStatus? current,
) {
  final samples = history.isNotEmpty
      ? history
      : current == null
      ? const <ServerStatus>[]
      : [current];
  final values = [
    for (final status in samples)
      _NetworkTrendSample(
        time: status.snapshot.timestamp,
        uploadRate: status.netUpRate,
        downloadRate: status.netDownRate,
      ),
  ];
  if (values.isEmpty) {
    return [
      _NetworkTrendSample(
        time: DateTime.now(),
        uploadRate: current?.netUpRate ?? 0,
        downloadRate: current?.netDownRate ?? 0,
      ),
    ];
  }
  return values.length <= 6 ? values : values.sublist(values.length - 6);
}

String _networkRateUnitLabel(List<_NetworkTrendSample> samples) {
  return _rateUnitFor(_networkMaxRate(samples)).label;
}

double _networkMaxRate(List<_NetworkTrendSample> samples) {
  final values = [
    for (final sample in samples) sample.uploadRate,
    for (final sample in samples) sample.downloadRate,
    1.0,
  ];
  return values.reduce((a, b) => a > b ? a : b);
}

_RateUnit _rateUnitFor(double bytesPerSecond) {
  const units = [
    _RateUnit(label: 'B/s', scale: 1),
    _RateUnit(label: 'KB/s', scale: 1024),
    _RateUnit(label: 'MB/s', scale: 1048576),
    _RateUnit(label: 'GB/s', scale: 1073741824),
  ];
  var index = 0;
  var value = bytesPerSecond;
  while (value >= 1024 && index < units.length - 1) {
    value /= 1024;
    index += 1;
  }
  return units[index];
}

String _formatRateAxis(double bytesPerSecond, _RateUnit unit) {
  final value = bytesPerSecond / unit.scale;
  if (value <= 0) return '0';
  if (value >= 100) return value.toStringAsFixed(0);
  if (value >= 10) return value.toStringAsFixed(1);
  return value.toStringAsFixed(2);
}

class _RateUnit {
  final String label;
  final double scale;

  const _RateUnit({required this.label, required this.scale});
}
