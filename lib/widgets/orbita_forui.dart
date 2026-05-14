import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

class OrbitaForuiPage extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;
  final String? fallbackLocation;
  final VoidCallback? onBack;
  final bool childPad;

  const OrbitaForuiPage({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
    this.fallbackLocation,
    this.onBack,
    this.childPad = false,
  });

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      childPad: childPad,
      header: FHeader.nested(
        title: Text(title),
        prefixes: [
          FHeaderAction.back(
            semanticsLabel: MaterialLocalizations.of(context).backButtonTooltip,
            onPress: onBack ?? () => _navigateBack(context),
          ),
        ],
        suffixes: actions,
      ),
      child: child,
    );
  }

  void _navigateBack(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else if (fallbackLocation != null) {
      context.go(fallbackLocation!);
    }
  }
}
