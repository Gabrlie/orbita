import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/widgets/orbita_forui.dart';

PreferredSizeWidget compactPageAppBar(
  BuildContext context, {
  required String title,
  List<Widget> actions = const [],
  String? fallbackLocation,
  VoidCallback? onBack,
}) {
  final theme = Theme.of(context);
  return AppBar(
    toolbarHeight: 48,
    leading: IconButton(
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      icon: const Icon(Ionicons.chevron_back_outline, size: 20),
      onPressed:
          onBack ??
          () {
            final navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.pop();
            } else if (fallbackLocation != null) {
              context.go(fallbackLocation);
            }
          },
    ),
    title: Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    ),
    actions: actions,
  );
}

/// Reusable section header for grouped lists (e.g., settings page).
class SectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.fromLTRB(16, 24, 16, 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

/// Empty state placeholder with icon, title, and optional subtitle.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 52, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 18),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tonal background for scrollable lists so surface cards stand apart.
class TonalListBackground extends StatelessWidget {
  final Widget child;

  const TonalListBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }
}

Color tonalItemColor(BuildContext context) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final tintAlpha = theme.brightness == Brightness.dark ? 22 : 12;
  return Color.alphaBlend(
    colorScheme.primary.withAlpha(tintAlpha),
    colorScheme.surfaceContainerLow,
  );
}

/// Confirmation dialog helper. Returns true if user confirmed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  String? confirmLabel,
  String? cancelLabel,
  bool destructive = false,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final result = await showOrbitaDialog<bool>(
    context: context,
    builder: (context, animation) => OrbitaDialog(
      animation: animation,
      title: title,
      actions: [
        OrbitaDialogAction(
          label: cancelLabel ?? l10n.commonCancel,
          variant: FButtonVariant.outline,
          onPress: () => Navigator.of(context).pop(false),
        ),
        OrbitaDialogAction(
          label: confirmLabel ?? l10n.commonConfirm,
          variant: destructive
              ? FButtonVariant.destructive
              : FButtonVariant.primary,
          onPress: () => Navigator.of(context).pop(true),
        ),
      ],
      child: Text(content),
    ),
  );
  return result ?? false;
}

/// Simple info dialog with a single OK button.
Future<void> showInfoDialog(
  BuildContext context, {
  required String title,
  required String content,
}) async {
  final l10n = AppLocalizations.of(context)!;
  await showOrbitaDialog<void>(
    context: context,
    builder: (context, animation) => OrbitaDialog(
      animation: animation,
      title: title,
      actions: [
        OrbitaDialogAction(
          label: l10n.commonOk,
          onPress: () => Navigator.of(context).pop(),
        ),
      ],
      child: Text(content),
    ),
  );
}
