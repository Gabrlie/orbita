import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/remote_script.dart';
import 'package:orbita/pages/scripts/remote_script_runner.dart';
import 'package:orbita/providers/remote_script_provider.dart';
import 'package:orbita/services/linux_mirror_script_builder.dart';
import 'package:orbita/widgets/common.dart';

class ScriptsLibraryPage extends ConsumerWidget {
  const ScriptsLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final systemScripts = _systemScripts(context, ref);
    final userScripts = ref.watch(userScriptsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scriptsTitle),
        actions: [
          IconButton(
            tooltip: l10n.scriptAdd,
            icon: const Icon(Ionicons.add),
            onPressed: () => context.go('/settings/scripts/add'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SectionHeader(
            title: l10n.scriptSystemSection,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          ),
          for (final script in systemScripts) _ScriptTile(script: script),
          SectionHeader(
            title: l10n.scriptUserSection,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          ),
          if (userScripts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                l10n.scriptUserEmpty,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            for (final script in userScripts) _ScriptTile(script: script),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/settings/scripts/add'),
        icon: const Icon(Ionicons.add),
        label: Text(l10n.scriptAdd),
      ),
    );
  }

  List<RemoteScript> _systemScripts(BuildContext context, WidgetRef ref) {
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
}

class _ScriptTile extends ConsumerWidget {
  final RemoteScript script;

  const _ScriptTile({required this.script});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(_iconForScript(script.id)),
      title: Text(script.name),
      subtitle: Text(script.description),
      trailing: Wrap(
        spacing: 4,
        children: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.scriptRun,
            icon: const Icon(Ionicons.play_outline),
            onPressed: () => runRemoteScriptFromContext(context, ref, script),
          ),
          IconButton(
            tooltip: script.isSystem
                ? AppLocalizations.of(context)!.scriptViewTitle
                : AppLocalizations.of(context)!.scriptEditTitle,
            icon: Icon(
              script.isSystem ? Ionicons.eye_outline : Ionicons.create_outline,
            ),
            onPressed: () => context.go('/settings/scripts/${script.id}'),
          ),
        ],
      ),
      onTap: () => context.go('/settings/scripts/${script.id}'),
    );
  }
}

IconData _iconForScript(String id) {
  return switch (id) {
    linuxMirrorScriptId => Ionicons.swap_horizontal_outline,
    'install-docker' => Ionicons.cube_outline,
    'install-tmux' => Ionicons.layers_outline,
    _ => Ionicons.archive_outline,
  };
}
