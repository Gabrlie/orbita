import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:uuid/uuid.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/providers/key_provider.dart';

/// Generate a new SSH key pair.
class KeyGeneratePage extends ConsumerStatefulWidget {
  const KeyGeneratePage({super.key});

  @override
  ConsumerState<KeyGeneratePage> createState() => _KeyGeneratePageState();
}

class _KeyGeneratePageState extends ConsumerState<KeyGeneratePage> {
  final _nameController = TextEditingController();
  SshKeyType _keyType = SshKeyType.ed25519;
  SshKey? _generated;
  bool _generating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.generateKey),
        actions: [
          if (_generated != null)
            TextButton(onPressed: _saveKey, child: Text(l10n.commonSave)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: l10n.keyName),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.keyType,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          SegmentedButton<SshKeyType>(
            segments: const [
              ButtonSegment(value: SshKeyType.ed25519, label: Text('Ed25519')),
              ButtonSegment(value: SshKeyType.rsa, label: Text('RSA 4096')),
            ],
            selected: {_keyType},
            onSelectionChanged: _generated == null
                ? (s) => setState(() => _keyType = s.first)
                : null,
          ),
          const SizedBox(height: 24),
          if (_generated == null)
            FilledButton.icon(
              onPressed: _generating ? null : _generate,
              icon: _generating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Ionicons.sparkles_outline),
              label: Text(_generating ? l10n.keyGenerating : l10n.generateKey),
            )
          else ...[
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Ionicons.checkmark_circle_outline,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(l10n.keyGenerated, style: theme.textTheme.titleSmall),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Public key
            Text(l10n.keyPublic, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: SelectableText(
                _generated!.publicKey ?? '',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: _generated!.publicKey ?? ''),
                  );
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.keyCopied)));
                },
                icon: const Icon(Ionicons.copy_outline, size: 16),
                label: Text(l10n.keyPublic),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _generate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _nameController.text =
          '${_keyType.name}-${DateTime.now().millisecondsSinceEpoch}';
    }

    setState(() => _generating = true);
    try {
      final key = await ref
          .read(keyListProvider.notifier)
          .generateKey(
            id: const Uuid().v4(),
            name: _nameController.text.trim(),
            keyType: _keyType,
          );
      setState(() {
        _generated = key;
        _generating = false;
      });
    } catch (e) {
      setState(() => _generating = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  void _saveKey() {
    if (_generated == null) return;
    ref.read(keyListProvider.notifier).addKey(_generated!);
    context.go('/settings/keys');
  }
}
