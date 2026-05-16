import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/providers/key_provider.dart';
import 'package:orbita/widgets/orbita_forui.dart';
import 'package:uuid/uuid.dart';

void showKeyListAddOptions(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context)!;
  final theme = Theme.of(context);
  showOrbitaDialog<void>(
    context: context,
    builder: (ctx, animation) => OrbitaDialog(
      animation: animation,
      title: l10n.keyListTitle,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FItem(
            prefix: Icon(
              Ionicons.download_outline,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            title: Text(
              l10n.importKey,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            onPress: () {
              Navigator.pop(ctx);
              context.go('/settings/keys/import');
            },
          ),
          if (Platform.isWindows || Platform.isMacOS)
            FItem(
              prefix: Icon(
                Ionicons.folder_open_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              title: Text(
                l10n.keyImportLocal,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPress: () {
                Navigator.pop(ctx);
                _importLocalKeys(context, ref);
              },
            ),
          FItem(
            prefix: Icon(
              Ionicons.sparkles_outline,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            title: Text(
              l10n.generateKey,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            onPress: () {
              Navigator.pop(ctx);
              context.go('/settings/keys/generate');
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> _importLocalKeys(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context)!;
  final home = Platform.environment[Platform.isWindows ? 'USERPROFILE' : 'HOME'];
  if (home == null || home.trim().isEmpty) {
    _showImportResult(context, l10n.keyImportLocalNone);
    return;
  }

  final sshDir = Directory('$home${Platform.pathSeparator}.ssh');
  if (!await sshDir.exists()) {
    if (!context.mounted) return;
    _showImportResult(context, l10n.keyImportLocalNone);
    return;
  }

  final existing = await ref.read(keyListProvider.future);
  if (!context.mounted) return;
  final existingPem = existing.map((key) => key.privateKeyPem.trim()).toSet();
  final imports = <SshKey>[];
  for (final name in const ['id_ed25519', 'id_rsa']) {
    final file = File('${sshDir.path}${Platform.pathSeparator}$name');
    if (!await file.exists()) continue;
    final pem = (await file.readAsString()).trim();
    if (pem.isEmpty || existingPem.contains(pem)) continue;
    final publicFile = File('${file.path}.pub');
    final publicKey = await publicFile.exists()
        ? (await publicFile.readAsString()).trim()
        : KeyListNotifier.derivePublicKey(pem);
    imports.add(
      SshKey(
        id: const Uuid().v4(),
        name: name,
        keyType: name.contains('rsa') ? SshKeyType.rsa : SshKeyType.ed25519,
        privateKeyPem: pem,
        publicKey: publicKey == null || publicKey.isEmpty ? null : publicKey,
        createdAt: DateTime.now(),
      ),
    );
    existingPem.add(pem);
  }

  final notifier = ref.read(keyListProvider.notifier);
  for (final key in imports) {
    await notifier.addKey(key);
  }
  if (!context.mounted) return;
  _showImportResult(
    context,
    imports.isEmpty
        ? l10n.keyImportLocalNone
        : l10n.keyImportLocalResult(imports.length),
  );
}

void _showImportResult(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
