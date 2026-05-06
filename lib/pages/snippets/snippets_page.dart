import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/command_snippet.dart';
import 'package:orbita/providers/command_snippet_provider.dart';
import 'package:orbita/widgets/common.dart';

class SnippetsPage extends ConsumerStatefulWidget {
  const SnippetsPage({super.key});

  @override
  ConsumerState<SnippetsPage> createState() => _SnippetsPageState();
}

class _SnippetsPageState extends ConsumerState<SnippetsPage> {
  final _search = TextEditingController();
  var _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final snippets = filterCommandSnippets(
      ref.watch(commandSnippetProvider),
      _query,
    );

    return Scaffold(
      appBar: compactPageAppBar(
        context,
        title: l10n.snippetsTitle,
        fallbackLocation: '/settings',
      ),
      body: TonalListBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: l10n.commandSnippetSearchHint,
                  prefixIcon: const Icon(Ionicons.search_outline),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: snippets.isEmpty
                  ? EmptyState(
                      icon: Ionicons.flash_outline,
                      title: l10n.commandSnippetEmpty,
                      subtitle: l10n.settingsSnippetsDesc,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                      itemCount: snippets.length,
                      itemBuilder: (context, index) =>
                          _SnippetTile(
                            snippet: snippets[index],
                            onEdit: () => _editSnippet(
                              context,
                              snippet: snippets[index],
                            ),
                          ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editSnippet(context),
        child: const Icon(Ionicons.add),
      ),
    );
  }

  Future<void> _editSnippet(
    BuildContext context, {
    CommandSnippet? snippet,
  }) async {
    final result = await showDialog<_SnippetFormResult>(
      context: context,
      builder: (context) => _SnippetEditorDialog(snippet: snippet),
    );
    if (result == null) return;
    final notifier = ref.read(commandSnippetProvider.notifier);
    if (snippet == null) {
      await notifier.add(name: result.name, command: result.command);
    } else {
      await notifier.update(
        snippet.copyWith(name: result.name, command: result.command),
      );
    }
  }
}

class _SnippetTile extends ConsumerWidget {
  final CommandSnippet snippet;
  final VoidCallback onEdit;

  const _SnippetTile({required this.snippet, required this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: tonalItemColor(context),
      surfaceTintColor: Colors.transparent,
      child: ListTile(
        leading: Icon(Ionicons.flash_outline, color: theme.colorScheme.primary),
        title: Text(snippet.name),
        subtitle: Text(
          snippet.command,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
        ),
        trailing: IconButton(
          tooltip: l10n.commonDelete,
          icon: Icon(Ionicons.trash_outline, color: theme.colorScheme.error),
          onPressed: () => _delete(context, ref),
        ),
        onTap: onEdit,
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.commandSnippetDeleteTitle,
      content: l10n.commandSnippetDeleteContent(snippet.name),
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (confirmed) {
      await ref.read(commandSnippetProvider.notifier).delete(snippet.id);
    }
  }
}

class _SnippetEditorDialog extends StatefulWidget {
  final CommandSnippet? snippet;

  const _SnippetEditorDialog({this.snippet});

  @override
  State<_SnippetEditorDialog> createState() => _SnippetEditorDialogState();
}

class _SnippetEditorDialogState extends State<_SnippetEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _command;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.snippet?.name ?? '');
    _command = TextEditingController(text: widget.snippet?.command ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _command.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final editing = widget.snippet != null;
    return AlertDialog(
      title: Text(
        editing ? l10n.commandSnippetEdit : l10n.commandSnippetAdd,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.commandSnippetName),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _command,
              decoration: InputDecoration(
                labelText: l10n.commandSnippetCommand,
                alignLabelWithHint: true,
              ),
              minLines: 3,
              maxLines: 6,
              validator: _required,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.validationRequired;
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      _SnippetFormResult(_name.text.trim(), _command.text.trimRight()),
    );
  }
}

class _SnippetFormResult {
  final String name;
  final String command;

  const _SnippetFormResult(this.name, this.command);
}
