import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class OrbitaBottomSheetSurface extends StatelessWidget {
  final Widget child;

  const OrbitaBottomSheetSurface({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: child,
      ),
    );
  }
}

Future<T?> showOrbitaBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  bool draggable = true,
  double? mainAxisMaxRatio,
}) {
  return showFSheet<T>(
    context: context,
    side: FLayout.btt,
    useSafeArea: true,
    barrierDismissible: barrierDismissible,
    draggable: draggable,
    mainAxisMaxRatio: mainAxisMaxRatio,
    builder: (context) => OrbitaBottomSheetSurface(child: builder(context)),
  );
}
