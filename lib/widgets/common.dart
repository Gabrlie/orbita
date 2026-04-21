import 'package:flutter/material.dart';
import 'package:orbita/l10n/app_localizations.dart';

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
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        content: Text(content),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel ?? l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  )
                : null,
            child: Text(confirmLabel ?? l10n.commonConfirm),
          ),
        ],
      );
    },
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
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      content: Text(content),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonOk),
        ),
      ],
    ),
  );
}
