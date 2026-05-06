import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/server_group.dart';
import 'package:orbita/pages/settings/server_groups_widgets.dart';
import 'package:orbita/providers/server_group_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/widgets/common.dart';

class ServerGroupsPage extends ConsumerWidget {
  const ServerGroupsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final serversAsync = ref.watch(serverListProvider);
    final groupState = ref.watch(serverGroupProvider);

    return Scaffold(
      appBar: compactPageAppBar(
        context,
        title: l10n.settingsGroups,
        fallbackLocation: '/settings',
      ),
      body: TonalListBackground(
        child: serversAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('$error')),
          data: (servers) {
            final buckets = groupServersForDisplay(
              servers: servers,
              groupState: groupState,
              unnamedGroupName: l10n.serverGroupUnnamed,
            );
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                for (final bucket in buckets)
                  GroupDropSection(
                    bucket: bucket,
                    groups: groupState.groups,
                    onEdit: (group) => _editGroup(context, ref, group: group),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editGroup(context, ref),
        icon: const Icon(Ionicons.add),
        label: Text(l10n.serverGroupAdd),
      ),
    );
  }

  Future<void> _editGroup(
    BuildContext context,
    WidgetRef ref, {
    ServerGroup? group,
  }) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _GroupNameDialog(group: group),
    );
    if (name == null || name.trim().isEmpty) return;
    final notifier = ref.read(serverGroupProvider.notifier);
    if (group == null) {
      await notifier.addGroup(name);
    } else {
      await notifier.renameGroup(group.id, name);
    }
  }
}

class _GroupNameDialog extends StatefulWidget {
  final ServerGroup? group;

  const _GroupNameDialog({this.group});

  @override
  State<_GroupNameDialog> createState() => _GroupNameDialogState();
}

class _GroupNameDialogState extends State<_GroupNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.group?.name ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(
        widget.group == null ? l10n.serverGroupAdd : l10n.serverGroupEdit,
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(labelText: l10n.serverGroupName),
          validator: (value) => value == null || value.trim().isEmpty
              ? l10n.validationRequired
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(_controller.text.trim());
          },
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
