import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

typedef OrbitaDialogBuilder =
    Widget Function(BuildContext context, Animation<double> animation);

Future<T?> showOrbitaDialog<T>({
  required BuildContext context,
  required OrbitaDialogBuilder builder,
  bool barrierDismissible = true,
}) {
  return showFDialog<T>(
    context: context,
    useSafeArea: true,
    barrierDismissible: barrierDismissible,
    builder: (context, style, animation) => builder(context, animation),
  );
}

class OrbitaDialog extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget child;
  final List<Widget> actions;
  final Animation<double>? animation;
  final EdgeInsetsGeometry padding;
  final BoxConstraints constraints;

  const OrbitaDialog({
    super.key,
    this.title,
    this.titleWidget,
    required this.child,
    this.actions = const [],
    this.animation,
    this.padding = const EdgeInsets.all(20),
    this.constraints = const BoxConstraints(minWidth: 280, maxWidth: 560),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FDialog.raw(
      animation: animation,
      constraints: constraints,
      style: FDialogStyleDelta.delta(
        decoration: DecorationDelta.shapeDelta(
          color: theme.colorScheme.surface,
        ),
      ),
      builder: (context, style) => Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (titleWidget != null || title != null) ...[
              DefaultTextStyle.merge(
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                child: titleWidget ?? Text(title!),
              ),
              const SizedBox(height: 14),
            ],
            child,
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: actions,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class OrbitaDialogAction extends StatelessWidget {
  final String label;
  final VoidCallback? onPress;
  final FButtonVariant variant;

  const OrbitaDialogAction({
    super.key,
    required this.label,
    required this.onPress,
    this.variant = FButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    return FButton(
      variant: variant,
      mainAxisSize: MainAxisSize.min,
      onPress: onPress,
      child: Text(label),
    );
  }
}
