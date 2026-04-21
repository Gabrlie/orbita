import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/providers/key_provider.dart';
import 'package:orbita/widgets/common.dart';

class KeyListPage extends ConsumerWidget {
  const KeyListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final keysAsync = ref.watch(keyListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.keyListTitle)),
      body: keysAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (keys) => keys.isEmpty
            ? EmptyState(
                icon: Ionicons.key_outline,
                title: l10n.noKeys,
                subtitle: l10n.noKeysSubtitle,
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                itemCount: keys.length,
                itemBuilder: (context, index) {
                  final k = keys[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      leading: Icon(
                        k.keyType == SshKeyType.rsa
                            ? Ionicons.shield_checkmark_outline
                            : Ionicons.key_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      minLeadingWidth: 24,
                      title: Text(
                        k.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '${k.keyType.name.toUpperCase()} · ${_formatDate(k.createdAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (k.publicKey != null)
                            IconButton(
                              icon: Icon(
                                Ionicons.copy_outline,
                                color: theme.colorScheme.primary,
                                size: 18,
                              ),
                              tooltip: l10n.keyPublic,
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: k.publicKey!),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.keyCopied)),
                                );
                              },
                            ),
                          Icon(
                            Ionicons.chevron_forward,
                            color: theme.colorScheme.outline,
                            size: 18,
                          ),
                        ],
                      ),
                      onTap: () => context.go('/settings/keys/${k.id}/edit'),
                      onLongPress: () => _confirmDelete(context, ref, k),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        child: const Icon(Ionicons.add),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Text(
                l10n.keyListTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(height: 1, indent: 24, endIndent: 24),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: Icon(
                Ionicons.download_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              title: Text(
                l10n.importKey,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                context.go('/settings/keys/import');
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: Icon(
                Ionicons.sparkles_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              title: Text(
                l10n.generateKey,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                context.go('/settings/keys/generate');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, SshKey key) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deleteKeyTitle,
      content: l10n.deleteKeyContent(key.name),
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (confirmed) {
      ref.read(keyListProvider.notifier).deleteKey(key.id);
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
