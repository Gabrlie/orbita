import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/pages/settings/keys/key_list_add_actions.dart';
import 'package:orbita/providers/key_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/orbita_forui.dart';
import 'package:orbita/widgets/settings_tiles.dart';

class KeyListPage extends ConsumerWidget {
  const KeyListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final keysAsync = ref.watch(keyListProvider);
    final servers = ref.watch(serverListProvider).value ?? const [];
    return Scaffold(
      appBar: compactPageAppBar(
        context,
        title: l10n.keyListTitle,
        fallbackLocation: '/settings',
      ),
      body: TonalListBackground(
        child: keysAsync.when(
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
                    final usageCount = servers
                        .where((server) => server.keyId == k.id)
                        .length;
                    final card = OrbitaSettingsTileGroup(
                      padding: const EdgeInsets.only(bottom: 8),
                      children: [
                        orbitaSettingsTile(
                          context,
                          icon: k.keyType == SshKeyType.rsa
                              ? Ionicons.shield_checkmark_outline
                              : Ionicons.key_outline,
                          title: k.name,
                          subtitle:
                              '${k.keyType.name.toUpperCase()} · ${_formatDate(k.createdAt)} · ${l10n.keyUsedByServerCount(usageCount)}',
                          suffix: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (k.publicKey != null)
                                Tooltip(
                                  message: l10n.keyPublic,
                                  child: FButton.icon(
                                    size: FButtonSizeVariant.sm,
                                    onPress: () {
                                      Clipboard.setData(
                                        ClipboardData(text: k.publicKey!),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(l10n.keyCopied)),
                                      );
                                    },
                                    child: const Icon(Ionicons.copy_outline),
                                  ),
                                ),
                              const SizedBox(width: 6),
                              const Icon(
                                Ionicons.chevron_forward_outline,
                                size: 18,
                              ),
                            ],
                          ),
                          onPress: () =>
                              context.go('/settings/keys/${k.id}/edit'),
                        ),
                      ],
                    );
                    return OrbitaLongPressMenu<String>(
                      actions: [
                        OrbitaMenuAction(
                          value: 'edit',
                          icon: Ionicons.create_outline,
                          label: l10n.commonEdit,
                        ),
                        OrbitaMenuAction(
                          value: 'delete',
                          icon: Ionicons.trash_outline,
                          label: l10n.commonDelete,
                          destructive: true,
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          context.go('/settings/keys/${k.id}/edit');
                        } else {
                          _confirmDelete(context, ref, k);
                        }
                      },
                      child: card,
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showKeyListAddOptions(context, ref),
        child: const Icon(Ionicons.add),
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
      try {
        await ref.read(keyListProvider.notifier).deleteKey(key.id);
      } on KeyInUseException catch (error) {
        if (!context.mounted) return;
        final serverNames = error.servers
            .map((server) => server.name)
            .join('\n');
        showInfoDialog(
          context,
          title: l10n.deleteKeyInUseTitle,
          content: l10n.deleteKeyInUseContent(key.name, serverNames),
        );
      }
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
