import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/providers/key_provider.dart';

class ServerKeyPicker extends ConsumerWidget {
  final String? selectedKeyId;
  final ValueChanged<String> onSelected;

  const ServerKeyPicker({
    super.key,
    required this.selectedKeyId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final keys = ref.watch(keyListProvider).value ?? [];
    final selected = selectedKeyId != null
        ? ref.watch(keyByIdProvider(selectedKeyId!))
        : null;

    return FCard.raw(
      child: FItem(
        prefix: Icon(
          selected != null
              ? Ionicons.key_outline
              : Ionicons.close_circle_outline,
          color: selected != null
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
        ),
        title: Text(l10n.authSelectKey),
        subtitle: Text(selected?.name ?? l10n.authNoKey),
        suffix: const Icon(Ionicons.chevron_forward),
        onPress: () => _showKeyPicker(context, keys, l10n),
      ),
    );
  }

  Future<void> _showKeyPicker(
    BuildContext context,
    List<SshKey> keys,
    AppLocalizations l10n,
  ) {
    return showFSheet<void>(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: null,
      useSafeArea: true,
      builder: (sheetContext) => _KeyPickerSheet(
        keys: keys,
        selectedKeyId: selectedKeyId,
        onSelected: (id) {
          onSelected(id);
          Navigator.of(sheetContext).pop();
        },
        onAdd: () {
          Navigator.of(sheetContext).pop();
          context.go('/settings/keys');
        },
      ),
    );
  }
}

class _KeyPickerSheet extends StatelessWidget {
  final List<SshKey> keys;
  final String? selectedKeyId;
  final ValueChanged<String> onSelected;
  final VoidCallback onAdd;

  const _KeyPickerSheet({
    required this.keys,
    required this.selectedKeyId,
    required this.onSelected,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Text(
            l10n.selectKey,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (keys.isEmpty)
          FItem(
            prefix: const Icon(Ionicons.information_circle_outline),
            title: Text(l10n.noKeys),
            subtitle: Text(l10n.noKeysSubtitle),
          ),
        for (final key in keys)
          FItem(
            prefix: Icon(
              key.keyType == SshKeyType.rsa
                  ? Ionicons.shield_checkmark_outline
                  : Ionicons.key_outline,
              color: theme.colorScheme.primary,
            ),
            title: Text(key.name),
            subtitle: Text(key.keyType.name.toUpperCase()),
            suffix: selectedKeyId == key.id
                ? Icon(
                    Ionicons.checkmark_circle_outline,
                    color: theme.colorScheme.primary,
                  )
                : null,
            onPress: () => onSelected(key.id),
          ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: FDivider(),
        ),
        FItem(
          prefix: const Icon(Ionicons.add),
          title: Text(l10n.addKey),
          onPress: onAdd,
        ),
      ],
    );
  }
}
