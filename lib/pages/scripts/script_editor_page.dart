import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/remote_script.dart';
import 'package:orbita/pages/scripts/remote_script_runner.dart';
import 'package:orbita/providers/remote_script_provider.dart';
import 'package:orbita/widgets/common.dart';

class ScriptEditorPage extends ConsumerStatefulWidget {
  final String? scriptId;

  const ScriptEditorPage({super.key, this.scriptId});

  @override
  ConsumerState<ScriptEditorPage> createState() => _ScriptEditorPageState();
}

class _ScriptEditorPageState extends ConsumerState<ScriptEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _commandController = TextEditingController();
  String? _loadedId;

  bool get _isNew => widget.scriptId == null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadScriptIfNeeded(ref.read(userScriptsProvider));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _commandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userScripts = ref.watch(userScriptsProvider);
    _loadScriptIfNeeded(userScripts);
    final script = _currentScript(context, userScripts);
    final readOnly = script?.isSystem ?? false;
    final title = _isNew
        ? l10n.scriptNewTitle
        : readOnly
        ? l10n.scriptViewTitle
        : l10n.scriptEditTitle;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (script != null)
            IconButton(
              tooltip: l10n.scriptRun,
              icon: const Icon(Ionicons.play_outline),
              onPressed: () => runRemoteScriptFromContext(context, ref, script),
            ),
          if (!readOnly)
            IconButton(
              tooltip: l10n.commonSave,
              icon: const Icon(Ionicons.save_outline),
              onPressed: _save,
            ),
          if (script != null && !readOnly)
            IconButton(
              tooltip: l10n.commonDelete,
              icon: const Icon(Ionicons.trash_outline),
              onPressed: () => _delete(script),
            ),
        ],
      ),
      body: script == null && !_isNew
          ? EmptyState(
              icon: Ionicons.document_text_outline,
              title: l10n.scriptNotFound,
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  if (readOnly)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        l10n.scriptSystemReadOnly,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  TextFormField(
                    controller: _nameController,
                    readOnly: readOnly,
                    decoration: InputDecoration(labelText: l10n.scriptName),
                    validator: (value) =>
                        _required(value, l10n.validationRequired),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    readOnly: readOnly,
                    minLines: 2,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: l10n.scriptDescription,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _commandController,
                    readOnly: readOnly,
                    minLines: 14,
                    maxLines: 24,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      labelText: l10n.scriptContent,
                    ),
                    validator: (value) =>
                        _required(value, l10n.validationRequired),
                  ),
                ],
              ),
            ),
      floatingActionButton: readOnly
          ? null
          : FloatingActionButton.extended(
              onPressed: _save,
              icon: const Icon(Ionicons.save_outline),
              label: Text(l10n.commonSave),
            ),
    );
  }

  void _loadScriptIfNeeded(List<RemoteScript> userScripts) {
    final script = _currentScript(context, userScripts);
    final id = script?.id ?? '__new__';
    if (_loadedId == id) return;
    _loadedId = id;
    _nameController.text = script?.name ?? '';
    _descriptionController.text = script?.description ?? '';
    _commandController.text = script?.command ?? '';
  }

  RemoteScript? _currentScript(
    BuildContext context,
    List<RemoteScript> userScripts,
  ) {
    final id = widget.scriptId;
    if (id == null) return null;
    final systemScripts = _systemScripts(context);
    for (final script in [...systemScripts, ...userScripts]) {
      if (script.id == id) return script;
    }
    return null;
  }

  List<RemoteScript> _systemScripts(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ref
        .read(remoteScriptServiceProvider)
        .builtInScripts(
          archiveName: l10n.scriptInstallArchiveTools,
          archiveDescription: l10n.scriptInstallArchiveToolsDesc,
          dockerName: l10n.scriptInstallDocker,
          dockerDescription: l10n.scriptInstallDockerDesc,
          tmuxName: l10n.scriptInstallTmux,
          tmuxDescription: l10n.scriptInstallTmuxDesc,
          mirrorName: l10n.scriptChangeMirror,
          mirrorDescription: l10n.scriptChangeMirrorDesc,
          mirrorSelectTitle: l10n.scriptSelectMirror,
          mirrorTunaLabel: l10n.scriptMirrorTuna,
          mirrorUstcLabel: l10n.scriptMirrorUstc,
          mirrorAliyunLabel: l10n.scriptMirrorAliyun,
          mirrorTencentLabel: l10n.scriptMirrorTencent,
          mirrorHuaweiLabel: l10n.scriptMirrorHuawei,
        );
  }

  String? _required(String? value, String message) {
    return value == null || value.trim().isEmpty ? message : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(userScriptsProvider.notifier);
    final existing = _currentScript(context, ref.read(userScriptsProvider));
    if (existing == null) {
      await notifier.add(
        name: _nameController.text,
        description: _descriptionController.text,
        command: _commandController.text,
      );
    } else {
      await notifier.update(
        existing.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          command: _commandController.text.trimRight(),
        ),
      );
    }
    if (mounted) context.go('/settings/scripts');
  }

  Future<void> _delete(RemoteScript script) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.scriptDeleteTitle,
      content: l10n.scriptDeleteContent(script.name),
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await ref.read(userScriptsProvider.notifier).delete(script.id);
    if (mounted) context.go('/settings/scripts');
  }
}
