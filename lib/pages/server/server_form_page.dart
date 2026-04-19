import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/pages/server/server_key_picker.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/widgets/os_icon.dart';

class ServerFormPage extends ConsumerStatefulWidget {
  final String? serverId;
  const ServerFormPage({super.key, this.serverId});

  @override
  ConsumerState<ServerFormPage> createState() => _ServerFormPageState();
}

class _ServerFormPageState extends ConsumerState<ServerFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _host;
  late final TextEditingController _port;
  late final TextEditingController _username;
  late final TextEditingController _password;
  late final TextEditingController _tags;
  AuthType _authType = AuthType.password;
  String? _selectedKeyId;

  OsType _existingOsType = OsType.unknown;

  bool get _isEdit => widget.serverId != null;

  @override
  void initState() {
    super.initState();
    final server = _isEdit
        ? ref.read(serverByIdProvider(widget.serverId!))
        : null;

    _name = TextEditingController(text: server?.name ?? '');
    _host = TextEditingController(text: server?.host ?? '');
    _port = TextEditingController(text: '${server?.port ?? 22}');
    _username = TextEditingController(text: server?.username ?? 'root');
    _password = TextEditingController(text: server?.password ?? '');
    _tags = TextEditingController(text: server?.tags.join(', ') ?? '');
    _authType = server?.authType ?? AuthType.password;
    _existingOsType = server?.osType ?? OsType.unknown;
    _selectedKeyId = server?.keyId;
  }

  @override
  void dispose() {
    _name.dispose();
    _host.dispose();
    _port.dispose();
    _username.dispose();
    _password.dispose();
    _tags.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.editServer : l10n.addServer),
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
                labelText: l10n.serverName,
                border: const OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? l10n.validationRequired
                  : null,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _host,
                    decoration: InputDecoration(
                      labelText: l10n.serverHost,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.validationRequired;
                      }
                      if (v.contains(' ')) return l10n.validationInvalidHost;
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _port,
                    decoration: InputDecoration(
                      labelText: l10n.serverPort,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final p = int.tryParse(v ?? '');
                      if (p == null || p < 1 || p > 65535) {
                        return l10n.validationInvalidPort;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _username,
              decoration: InputDecoration(
                labelText: l10n.serverUsername,
                border: const OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? l10n.validationRequired
                  : null,
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.serverAuthType,
                style: theme.textTheme.titleSmall,
              ),
            ),
            SegmentedButton<AuthType>(
              segments: [
                ButtonSegment(
                  value: AuthType.password,
                  label: Text(l10n.authPassword),
                ),
                ButtonSegment(
                  value: AuthType.key,
                  label: Text(l10n.authPrivateKey),
                ),
              ],
              selected: {_authType},
              onSelectionChanged: (s) => setState(() => _authType = s.first),
            ),
            const SizedBox(height: 16),

            if (_authType == AuthType.password)
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.authPassword,
                  border: const OutlineInputBorder(),
                ),
              )
            else
              ServerKeyPicker(
                selectedKeyId: _selectedKeyId,
                onSelected: (id) => setState(() => _selectedKeyId = id),
              ),

            const SizedBox(height: 16),
            TextFormField(
              controller: _tags,
              decoration: InputDecoration(
                labelText: l10n.serverTags,
                hintText: l10n.serverTagsHint,
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

    final tags = _tags.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final server = Server(
      id: widget.serverId ?? const Uuid().v4(),
      name: _name.text.trim(),
      host: _host.text.trim(),
      port: int.parse(_port.text),
      username: _username.text.trim(),
      authType: _authType,
      password: _authType == AuthType.password ? _password.text : null,
      keyId: _authType == AuthType.key ? _selectedKeyId : null,
      osType: _existingOsType,
      tags: tags,
    );

    final notifier = ref.read(serverListProvider.notifier);
    if (_isEdit) {
      notifier.updateServer(server);
    } else {
      notifier.addServer(server);
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }
}
