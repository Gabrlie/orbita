import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/providers/key_provider.dart';

/// Import (paste) an existing private key, or edit an existing key.
class KeyImportPage extends ConsumerStatefulWidget {
  final String? keyId;
  const KeyImportPage({super.key, this.keyId});

  @override
  ConsumerState<KeyImportPage> createState() => _KeyImportPageState();
}

class _KeyImportPageState extends ConsumerState<KeyImportPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _privateKey;
  late final TextEditingController _publicKey;
  late final TextEditingController _passphrase;
  SshKeyType _keyType = SshKeyType.ed25519;
  bool _deriving = false;

  bool get _isEdit => widget.keyId != null;

  @override
  void initState() {
    super.initState();
    final existing = _isEdit ? ref.read(keyByIdProvider(widget.keyId!)) : null;
    _name = TextEditingController(text: existing?.name ?? '');
    _privateKey = TextEditingController(text: existing?.privateKeyPem ?? '');
    _publicKey = TextEditingController(text: existing?.publicKey ?? '');
    _passphrase = TextEditingController(text: existing?.passphrase ?? '');
    _keyType = existing?.keyType ?? SshKeyType.ed25519;

    // If editing and no public key, try to derive it
    if (_isEdit && _publicKey.text.isEmpty && _privateKey.text.isNotEmpty) {
      _tryDerivePublicKey();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _privateKey.dispose();
    _publicKey.dispose();
    _passphrase.dispose();
    super.dispose();
  }

  void _tryDerivePublicKey() {
    final pem = _privateKey.text.trim();
    if (pem.isEmpty) return;
    setState(() => _deriving = true);
    // Run in microtask to avoid blocking UI during RSA parsing
    Future(() {
      final passphrase = _passphrase.text.isEmpty ? null : _passphrase.text;
      return KeyListNotifier.derivePublicKey(pem, passphrase);
    }).then((pubKey) {
      if (mounted && pubKey != null) {
        setState(() {
          _publicKey.text = pubKey;
          _deriving = false;
        });
      } else if (mounted) {
        setState(() => _deriving = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.editKey : l10n.importKey),
        actions: [TextButton(onPressed: _save, child: Text(l10n.commonSave))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: InputDecoration(
                labelText: l10n.keyName,
                border: const OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? l10n.validationRequired
                  : null,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l10n.keyType, style: theme.textTheme.titleSmall),
            ),
            SegmentedButton<SshKeyType>(
              segments: const [
                ButtonSegment(
                  value: SshKeyType.ed25519,
                  label: Text('Ed25519'),
                ),
                ButtonSegment(value: SshKeyType.rsa, label: Text('RSA')),
              ],
              selected: {_keyType},
              onSelectionChanged: (s) => setState(() => _keyType = s.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _privateKey,
              maxLines: 8,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              decoration: InputDecoration(
                labelText: l10n.keyPrivate,
                hintText: '-----BEGIN OPENSSH PRIVATE KEY-----',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? l10n.validationRequired
                  : null,
              onChanged: (_) {
                // Clear public key when private key changes, will re-derive on save
                if (_publicKey.text.isNotEmpty) {
                  setState(() => _publicKey.clear());
                }
              },
            ),
            const SizedBox(height: 16),
            // Public key field
            TextFormField(
              controller: _publicKey,
              maxLines: 4,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              decoration: InputDecoration(
                labelText: l10n.keyPublic,
                hintText: 'ssh-ed25519 AAAA...',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
                suffixIcon: _publicKey.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.copy_outlined, size: 18),
                        tooltip: l10n.keyCopyPublicKey,
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: _publicKey.text),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.keyCopied)),
                          );
                        },
                      )
                    : _deriving
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passphrase,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.keyPassphrase,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final pem = _privateKey.text.trim();
    var publicKey = _publicKey.text.trim().isEmpty
        ? null
        : _publicKey.text.trim();

    // If no public key, try to derive from private key before saving
    if (publicKey == null || publicKey.isEmpty) {
      final passphrase = _passphrase.text.isEmpty ? null : _passphrase.text;
      publicKey = KeyListNotifier.derivePublicKey(pem, passphrase);
    }

    final key = SshKey(
      id: widget.keyId ?? const Uuid().v4(),
      name: _name.text.trim(),
      keyType: _keyType,
      privateKeyPem: pem,
      publicKey: publicKey,
      passphrase: _passphrase.text.isEmpty ? null : _passphrase.text,
      createdAt: DateTime.now(),
    );
    final notifier = ref.read(keyListProvider.notifier);
    if (_isEdit) {
      notifier.updateKey(key);
    } else {
      notifier.addKey(key);
    }
    context.go('/settings/keys');
  }
}
