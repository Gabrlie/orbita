import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:uuid/uuid.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/tailnet_models.dart';
import 'package:orbita/pages/server/server_form_fields.dart';
import 'package:orbita/pages/server/server_key_picker.dart';
import 'package:orbita/pages/server/server_network_section.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/orbita_forui.dart';
import 'package:orbita/widgets/os_icon.dart';

class ServerFormPage extends ConsumerStatefulWidget {
  final String? serverId;
  final String returnPath;

  const ServerFormPage({super.key, this.serverId, this.returnPath = '/home'});

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
  ServerConnectionMode _connectionMode = ServerConnectionMode.direct;
  String? _tailscalePeerId;
  String? _tailscalePeerName;
  String? _tailscaleDnsName;
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
    _connectionMode = server?.connectionMode ?? ServerConnectionMode.direct;
    _tailscalePeerId = server?.tailscalePeerId;
    _tailscalePeerName = server?.tailscalePeerName;
    _tailscaleDnsName = server?.tailscaleDnsName;
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

    return OrbitaForuiPage(
      title: _isEdit ? l10n.editServer : l10n.addServer,
      fallbackLocation: widget.returnPath,
      actions: [
        FHeaderAction(
          semanticsLabel: l10n.commonSave,
          icon: const Icon(Ionicons.checkmark_outline),
          onPress: _save,
        ),
      ],
      child: TonalListBackground(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FTextFormField(
                control: FTextFieldControl.managed(controller: _name),
                label: Text(l10n.serverName),
                validator: (v) => v == null || v.trim().isEmpty
                    ? l10n.validationRequired
                    : null,
              ),
              const SizedBox(height: 16),
              ServerNetworkSection(
                connectionMode: _connectionMode,
                onConnectionModeChanged: (mode) {
                  setState(() => _connectionMode = mode);
                },
                selectedPeerName: _tailscalePeerName,
                selectedPeerDnsName: _tailscaleDnsName,
                onPeerChanged: _setTailnetPeer,
              ),
              const SizedBox(height: 16),
              if (_connectionMode == ServerConnectionMode.direct)
                ServerDirectEndpointFields(
                  hostController: _host,
                  portController: _port,
                )
              else
                ServerPortField(controller: _port),
              const SizedBox(height: 16),
              FTextFormField(
                control: FTextFieldControl.managed(controller: _username),
                label: Text(l10n.serverUsername),
                validator: (v) => v == null || v.trim().isEmpty
                    ? l10n.validationRequired
                    : null,
              ),
              const SizedBox(height: 16),
              FSelectTileGroup<AuthType>(
                label: Text(l10n.serverAuthType),
                control: FMultiValueControl.managedRadio(
                  initial: _authType,
                  onChange: (selection) {
                    if (selection.isEmpty) return;
                    setState(() => _authType = selection.first);
                  },
                ),
                children: [
                  FSelectTile.suffix(
                    value: AuthType.password,
                    prefix: const Icon(Ionicons.lock_closed_outline),
                    title: Text(l10n.authPassword),
                  ),
                  FSelectTile.suffix(
                    value: AuthType.key,
                    prefix: const Icon(Ionicons.key_outline),
                    title: Text(l10n.authPrivateKey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_authType == AuthType.password)
                FTextFormField.password(
                  control: FTextFieldControl.managed(controller: _password),
                  label: Text(l10n.authPassword),
                )
              else
                ServerKeyPicker(
                  selectedKeyId: _selectedKeyId,
                  onSelected: (id) => setState(() => _selectedKeyId = id),
                ),
              const SizedBox(height: 16),
              FTextFormField(
                control: FTextFieldControl.managed(controller: _tags),
                label: Text(l10n.serverTags),
                hint: l10n.serverTagsHint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    final tags = _tags.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (_connectionMode == ServerConnectionMode.tailscale &&
        (_tailscaleDnsName == null || _tailscaleDnsName!.trim().isEmpty) &&
        (_tailscalePeerName == null || _tailscalePeerName!.trim().isEmpty) &&
        (_tailscalePeerId == null || _tailscalePeerId!.trim().isEmpty)) {
      unawaited(
        showInfoDialog(
          context,
          title: l10n.tailnetPeerPickerTitle,
          content: l10n.tailnetPeerRequired,
        ),
      );
      return;
    }

    final server = Server(
      id: widget.serverId ?? const Uuid().v4(),
      name: _name.text.trim(),
      host: _connectionMode == ServerConnectionMode.direct
          ? _host.text.trim()
          : '',
      port: int.parse(_port.text),
      username: _username.text.trim(),
      authType: _authType,
      password: _authType == AuthType.password ? _password.text : null,
      keyId: _authType == AuthType.key ? _selectedKeyId : null,
      osType: _existingOsType,
      tags: tags,
      connectionMode: _connectionMode,
      tailscalePeerId: _connectionMode == ServerConnectionMode.tailscale
          ? _tailscalePeerId
          : null,
      tailscalePeerName: _connectionMode == ServerConnectionMode.tailscale
          ? _tailscalePeerName
          : null,
      tailscaleDnsName: _connectionMode == ServerConnectionMode.tailscale
          ? _tailscaleDnsName
          : null,
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
      context.go(widget.returnPath);
    }
  }

  void _setTailnetPeer(TailnetPeer? peer) {
    setState(() {
      _tailscalePeerId = peer?.id;
      _tailscalePeerName = peer?.hostName;
      _tailscaleDnsName = peer?.dnsNameWithoutTrailingDot;
    });
  }
}
