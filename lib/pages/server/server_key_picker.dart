import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        selected != null ? Icons.key_outlined : Icons.key_off_outlined,
        color: selected != null
            ? theme.colorScheme.primary
            : theme.colorScheme.outlineVariant,
      ),
      title: Text(l10n.authSelectKey),
      subtitle: Text(selected?.name ?? l10n.authNoKey),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showKeyPicker(context, keys, l10n),
    );
  }

  void _showKeyPicker(
    BuildContext context,
    List<SshKey> keys,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.selectKey,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            if (keys.isEmpty)
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.noKeys),
                subtitle: Text(l10n.noKeysSubtitle),
              ),
            for (final k in keys)
              ListTile(
                leading: Icon(
                  k.keyType == SshKeyType.rsa
                      ? Icons.security_outlined
                      : Icons.enhanced_encryption_outlined,
                  color: Theme.of(ctx).colorScheme.primary,
                ),
                title: Text(k.name),
                subtitle: Text(k.keyType.name.toUpperCase()),
                trailing: selectedKeyId == k.id
                    ? Icon(
                        Icons.check_circle_outline,
                        color: Theme.of(ctx).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  onSelected(k.id);
                  Navigator.pop(ctx);
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add_outlined),
              title: Text(l10n.addKey),
              onTap: () {
                Navigator.pop(ctx);
                context.go('/settings/keys');
              },
            ),
          ],
        ),
      ),
    );
  }
}
