import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/widgets/orbita_forui.dart';

class TerminalColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final Animation<double>? animation;

  const TerminalColorPickerDialog({
    super.key,
    required this.initialColor,
    this.animation,
  });

  @override
  State<TerminalColorPickerDialog> createState() =>
      _TerminalColorPickerDialogState();
}

class _TerminalColorPickerDialogState extends State<TerminalColorPickerDialog> {
  late HSVColor _color;

  @override
  void initState() {
    super.initState();
    _color = HSVColor.fromColor(widget.initialColor);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _color.toColor();
    final argb = color.toARGB32();
    final red = (argb >> 16) & 0xff;
    final green = (argb >> 8) & 0xff;
    final blue = argb & 0xff;
    return OrbitaDialog(
      animation: widget.animation,
      title: l10n.terminalColorPicker,
      actions: [
        OrbitaDialogAction(
          label: l10n.commonCancel,
          variant: FButtonVariant.outline,
          onPress: () => Navigator.of(context).pop(),
        ),
        OrbitaDialogAction(
          label: l10n.commonConfirm,
          onPress: () => Navigator.of(context).pop(color),
        ),
      ],
      child: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'RGB $red, $green, $blue',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SaturationValuePicker(
              color: _color,
              onChanged: (color) => setState(() => _color = color),
            ),
            const SizedBox(height: 14),
            _HuePicker(
              hue: _color.hue,
              onChanged: (hue) => setState(() => _color = _color.withHue(hue)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaturationValuePicker extends StatelessWidget {
  final HSVColor color;
  final ValueChanged<HSVColor> onChanged;

  const _SaturationValuePicker({required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.35,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onPanDown: (details) => _update(details.localPosition, constraints),
            onPanUpdate: (details) =>
                _update(details.localPosition, constraints),
            child: CustomPaint(
              painter: _SaturationValuePainter(hue: color.hue),
              foregroundPainter: _PickerHandlePainter(
                position: Offset(
                  color.saturation * constraints.maxWidth,
                  (1 - color.value) * constraints.maxHeight,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _update(Offset offset, BoxConstraints constraints) {
    final saturation = (offset.dx / constraints.maxWidth).clamp(0.0, 1.0);
    final value = (1 - offset.dy / constraints.maxHeight).clamp(0.0, 1.0);
    onChanged(color.withSaturation(saturation).withValue(value));
  }
}

class _HuePicker extends StatelessWidget {
  final double hue;
  final ValueChanged<double> onChanged;

  const _HuePicker({required this.hue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onPanDown: (details) => _update(details.localPosition, constraints),
            onPanUpdate: (details) =>
                _update(details.localPosition, constraints),
            child: CustomPaint(
              painter: _HuePainter(),
              foregroundPainter: _PickerHandlePainter(
                position: Offset(hue / 360 * constraints.maxWidth, 14),
              ),
            ),
          );
        },
      ),
    );
  }

  void _update(Offset offset, BoxConstraints constraints) {
    onChanged((offset.dx / constraints.maxWidth).clamp(0.0, 1.0) * 360);
  }
}

class _SaturationValuePainter extends CustomPainter {
  final double hue;

  const _SaturationValuePainter({required this.hue});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final color = HSVColor.fromAHSV(1, hue, 1, 1).toColor();
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.white, color],
        ).createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _SaturationValuePainter oldDelegate) {
    return oldDelegate.hue != hue;
  }
}

class _HuePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFFF0000),
            Color(0xFFFFFF00),
            Color(0xFF00FF00),
            Color(0xFF00FFFF),
            Color(0xFF0000FF),
            Color(0xFFFF00FF),
            Color(0xFFFF0000),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PickerHandlePainter extends CustomPainter {
  final Offset position;

  const _PickerHandlePainter({required this.position});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      position,
      7,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white,
    );
    canvas.drawCircle(
      position,
      8,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.black.withAlpha(140),
    );
  }

  @override
  bool shouldRepaint(covariant _PickerHandlePainter oldDelegate) {
    return oldDelegate.position != position;
  }
}
