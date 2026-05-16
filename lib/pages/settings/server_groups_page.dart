import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/server_group.dart';
import 'package:orbita/pages/settings/server_groups_widgets.dart';
import 'package:orbita/providers/server_group_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/orbita_forui.dart';

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
    final name = await showOrbitaDialog<String>(
      context: context,
      builder: (context, animation) =>
          _GroupNameDialog(group: group, animation: animation),
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
  final Animation<double> animation;

  const _GroupNameDialog({this.group, required this.animation});

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
    return OrbitaDialog(
      animation: widget.animation,
      title: widget.group == null ? l10n.serverGroupAdd : l10n.serverGroupEdit,
      actions: [
        OrbitaDialogAction(
          label: l10n.commonCancel,
          variant: FButtonVariant.outline,
          onPress: () => Navigator.of(context).pop(),
        ),
        OrbitaDialogAction(
          label: l10n.commonSave,
          onPress: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(_controller.text.trim());
          },
        ),
      ],
      child: Form(
        key: _formKey,
        child: FTextFormField(
          control: FTextFieldControl.managed(controller: _controller),
          label: Text(l10n.serverGroupName),
          validator: (value) => value == null || value.trim().isEmpty
              ? l10n.validationRequired
              : null,
        ),
      ),
    );
  }
}
