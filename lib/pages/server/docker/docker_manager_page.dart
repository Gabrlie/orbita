import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/docker_models.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/pages/server/docker/docker_logs_page.dart';
import 'package:orbita/pages/server/files/file_text_editor_page.dart';
import 'package:orbita/providers/docker_provider.dart';
import 'package:orbita/providers/remote_script_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/services/docker_command_builder.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/orbita_forui.dart';
import 'package:orbita/widgets/remote_script_output_dialog.dart';

enum _DockerSection { overview, containers, compose, images, volumes }

class DockerManagerPage extends ConsumerStatefulWidget {
  final String serverId;
  final bool showAppBar;

  const DockerManagerPage({
    super.key,
    required this.serverId,
    this.showAppBar = true,
  });

  @override
  ConsumerState<DockerManagerPage> createState() => _DockerManagerPageState();
}

class _DockerManagerPageState extends ConsumerState<DockerManagerPage> {
  var _section = _DockerSection.overview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final server = ref.watch(serverByIdProvider(widget.serverId));
    final snapshotAsync = ref.watch(dockerSnapshotProvider(widget.serverId));

    if (server == null) {
      return EmptyState(
        icon: Ionicons.warning_outline,
        title: l10n.fileServerMissing,
        subtitle: l10n.fileServerMissingSubtitle,
      );
    }

    final body = snapshotAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyState(
        icon: Ionicons.warning_outline,
        title: l10n.dockerLoadFailed,
        subtitle: '$error',
      ),
      data: (snapshot) => _DockerManagerBody(
        server: server,
        snapshot: snapshot,
        section: _section,
        onSectionChanged: (section) => setState(() => _section = section),
        onRefresh: _refresh,
        onInstallDocker: () => _installDocker(server),
        onAction: _runAction,
      ),
    );

    if (!widget.showAppBar) return body;

    return Scaffold(
      appBar: AppBar(
        title: Text(server.name),
        actions: [
          IconButton(
            tooltip: l10n.commonRefresh,
            icon: const Icon(Ionicons.refresh_outline),
            onPressed: _refresh,
          ),
        ],
      ),
      body: body,
    );
  }

  void _refresh() {
    ref.read(dockerRefreshProvider(widget.serverId).notifier).refresh();
  }

  Future<void> _runAction(
    Future<void> Function(Server server) action, {
    bool refresh = true,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final server = ref.read(serverByIdProvider(widget.serverId));
    if (server == null) return;
    try {
      await action(server);
      if (refresh) _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.dockerActionDone)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.dockerActionFailed}: $error')),
      );
    }
  }

  Future<void> _installDocker(Server server) async {
    final l10n = AppLocalizations.of(context)!;
    final service = ref.read(remoteScriptServiceProvider);
    final script = service
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
        )
        .firstWhere((script) => script.id == 'install-docker');
    final key = await resolveRemoteScriptKey(ref, server);
    if (!mounted) return;
    final success = await showOrbitaDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context, animation) => RemoteScriptOutputDialog(
        title: l10n.scriptRunningOn(script.name, server.name),
        successMessage: l10n.scriptRunSucceeded,
        failureMessage: l10n.scriptRunFailed,
        onRun: (onOutput) =>
            service.run(server, script: script, key: key, onOutput: onOutput),
        animation: animation,
      ),
    );
    if (success == true) _refresh();
  }
}

class _DockerManagerBody extends ConsumerWidget {
  final Server server;
  final DockerSnapshot snapshot;
  final _DockerSection section;
  final ValueChanged<_DockerSection> onSectionChanged;
  final VoidCallback onRefresh;
  final VoidCallback onInstallDocker;
  final Future<void> Function(
    Future<void> Function(Server server) action, {
    bool refresh,
  })
  onAction;

  const _DockerManagerBody({
    required this.server,
    required this.snapshot,
    required this.section,
    required this.onSectionChanged,
    required this.onRefresh,
    required this.onInstallDocker,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!snapshot.availability.isAvailable) {
      return _DockerAvailabilityView(
        snapshot: snapshot,
        onRefresh: onRefresh,
        onInstallDocker: onInstallDocker,
      );
    }

    return Column(
      children: [
        _DockerSectionBar(selected: section, onChanged: onSectionChanged),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => onRefresh(),
            child: switch (section) {
              _DockerSection.overview => _DockerOverviewView(
                snapshot: snapshot,
              ),
              _DockerSection.containers => _DockerContainerView(
                server: server,
                snapshot: snapshot,
                onAction: onAction,
              ),
              _DockerSection.compose => _DockerComposeView(
                server: server,
                snapshot: snapshot,
                onAction: onAction,
              ),
              _DockerSection.images => _DockerImageView(
                server: server,
                snapshot: snapshot,
                onAction: onAction,
              ),
              _DockerSection.volumes => _DockerVolumeView(
                server: server,
                snapshot: snapshot,
                onAction: onAction,
              ),
            },
          ),
        ),
      ],
    );
  }
}

class _DockerSectionBar extends StatelessWidget {
  final _DockerSection selected;
  final ValueChanged<_DockerSection> onChanged;

  const _DockerSectionBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (context, index) {
          final section = _DockerSection.values[index];
          final active = selected == section;
          return ChoiceChip(
            selected: active,
            showCheckmark: false,
            avatar: Icon(
              _iconForSection(section),
              size: 17,
              color: active
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
            ),
            label: Text(_labelForSection(l10n, section)),
            onSelected: (_) => onChanged(section),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: _DockerSection.values.length,
      ),
    );
  }
}

class _DockerAvailabilityView extends StatelessWidget {
  final DockerSnapshot snapshot;
  final VoidCallback onRefresh;
  final VoidCallback onInstallDocker;

  const _DockerAvailabilityView({
    required this.snapshot,
    required this.onRefresh,
    required this.onInstallDocker,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final availability = snapshot.availability;
    final title = switch (availability.state) {
      DockerAvailabilityState.missing => l10n.dockerMissing,
      DockerAvailabilityState.permissionDenied => l10n.dockerPermissionDenied,
      DockerAvailabilityState.available => l10n.navDocker,
      DockerAvailabilityState.error => l10n.dockerUnavailable,
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmptyState(
              icon: Ionicons.cube_outline,
              title: title,
              subtitle: availability.message,
            ),
            if (availability.state == DockerAvailabilityState.missing) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onInstallDocker,
                icon: const Icon(Ionicons.download_outline),
                label: Text(l10n.scriptInstallDocker),
              ),
            ],
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Ionicons.refresh_outline),
              label: Text(l10n.commonRefresh),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockerOverviewView extends StatelessWidget {
  final DockerSnapshot snapshot;

  const _DockerOverviewView({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final info = snapshot.info;
    final running = snapshot.containers.where((item) => item.isRunning).length;
    final stopped = snapshot.containers.length - running;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _CountCard(
              icon: Ionicons.apps_outline,
              label: l10n.dockerTotalContainers,
              value: '${snapshot.containers.length}',
            ),
            _CountCard(
              icon: Ionicons.play_circle_outline,
              label: l10n.dockerRunningContainers,
              value: '$running',
            ),
            _CountCard(
              icon: Ionicons.stop_circle_outline,
              label: l10n.dockerStoppedContainers,
              value: '$stopped',
            ),
            _CountCard(
              icon: Ionicons.layers_outline,
              label: l10n.dockerComposeProjects,
              value: '${snapshot.composeProjects.length}',
            ),
            _CountCard(
              icon: Ionicons.albums_outline,
              label: l10n.dockerImageCount,
              value: '${snapshot.images.length}',
            ),
            _CountCard(
              icon: Ionicons.archive_outline,
              label: l10n.dockerVolumeCount,
              value: '${snapshot.volumes.length}',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _DetailCard(
          children: [
            _InfoRow(l10n.dockerVersion, info?.serverVersion ?? '-'),
            _InfoRow(l10n.dockerComposeVersion, info?.composeVersion ?? '-'),
            _InfoRow(l10n.dockerStorageDriver, info?.storageDriver ?? '-'),
            _InfoRow(l10n.dockerRootDir, info?.rootDir ?? '-'),
            _InfoRow(l10n.dockerArchitecture, info?.architecture ?? '-'),
            _InfoRow(l10n.dockerCpuMemory, _cpuMemory(info)),
          ],
        ),
      ],
    );
  }

  String _cpuMemory(DockerInfo? info) {
    if (info == null) return '-';
    final gb = info.memoryBytes / 1024 / 1024 / 1024;
    return '${info.cpus} CPU · ${gb.toStringAsFixed(1)} GB';
  }
}

class _DockerContainerView extends ConsumerWidget {
  final Server server;
  final DockerSnapshot snapshot;
  final Future<void> Function(
    Future<void> Function(Server server) action, {
    bool refresh,
  })
  onAction;

  const _DockerContainerView({
    required this.server,
    required this.snapshot,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    if (snapshot.containers.isEmpty) {
      return EmptyState(
        icon: Ionicons.apps_outline,
        title: l10n.dockerNoContainers,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: snapshot.containers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final container = snapshot.containers[index];
        return _DockerCard(
          icon: container.isRunning
              ? Ionicons.play_circle_outline
              : Ionicons.stop_circle_outline,
          title: container.displayName,
          subtitle: container.image,
          meta: [
            container.status,
            if (container.ports.isNotEmpty) container.ports,
            if (container.composeProject.isNotEmpty) container.composeProject,
          ],
          trailing: OrbitaIconMenuButton<String>(
            icon: Ionicons.ellipsis_horizontal,
            title: container.displayName,
            onSelected: (value) => _handleMenu(context, ref, container, value),
            actions: [
              if (container.isRunning)
                _menuItem('stop', Ionicons.stop_outline, l10n.dockerStop)
              else
                _menuItem('start', Ionicons.play_outline, l10n.dockerStart),
              if (container.isRunning)
                _menuItem(
                  'restart',
                  Ionicons.refresh_outline,
                  l10n.dockerRestart,
                ),
              _menuItem(
                'logs',
                Ionicons.document_text_outline,
                l10n.dockerLogs,
              ),
              _menuItem('exec', Ionicons.terminal_outline, l10n.dockerExec),
              _menuItem(
                'details',
                Ionicons.information_circle_outline,
                l10n.dockerDetails,
              ),
              if (!container.isRunning)
                _menuItem(
                  'remove',
                  Ionicons.trash_outline,
                  l10n.commonDelete,
                  destructive: true,
                  dividerBefore: true,
                ),
            ],
          ),
        );
      },
    );
  }

  void _handleMenu(
    BuildContext context,
    WidgetRef ref,
    DockerContainer container,
    String value,
  ) {
    switch (value) {
      case 'start':
        _containerAction(ref, container, DockerContainerAction.start);
      case 'stop':
        _containerAction(ref, container, DockerContainerAction.stop);
      case 'restart':
        _containerAction(ref, container, DockerContainerAction.restart);
      case 'remove':
        _confirmRemove(context, ref, container);
      case 'details':
        _showInspect(context, ref, container.id);
      case 'logs':
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DockerLogsPage(
              serverId: server.id,
              title: container.displayName,
              command: dockerLogsCommand(container.id),
            ),
          ),
        );
      case 'exec':
        _showExecShells(context, container);
    }
  }

  void _containerAction(
    WidgetRef ref,
    DockerContainer container,
    DockerContainerAction action,
  ) {
    onAction((server) async {
      final key = await resolveDockerKey(ref, server);
      await ref
          .read(dockerServiceProvider)
          .containerAction(server, id: container.id, action: action, key: key);
    });
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    DockerContainer container,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.dockerDeleteContainerTitle,
      content: l10n.dockerDeleteContainerContent(container.displayName),
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;
    _containerAction(ref, container, DockerContainerAction.remove);
  }

  Future<void> _showInspect(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final key = await resolveDockerKey(ref, server);
      final output = await ref
          .read(dockerServiceProvider)
          .inspect(server, id, key: key);
      if (!context.mounted) return;
      await _showOutputDialog(context, l10n.dockerDetails, output);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.dockerActionFailed}: $error')),
      );
    }
  }

  Future<void> _showExecShells(
    BuildContext context,
    DockerContainer container,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final shell = await showOrbitaDialog<String>(
      context: context,
      builder: (context, animation) => OrbitaDialog(
        animation: animation,
        title: l10n.dockerExecShell,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final shell in const ['bash', 'sh', 'ash'])
              FItem(
                title: Text(shell),
                onPress: () => Navigator.of(context).pop(shell),
              ),
          ],
        ),
      ),
    );
    if (shell == null || !context.mounted) return;
    final command = dockerExecCommand(container.id, shell);
    final encoded = base64Url.encode(utf8.encode(command));
    final uri = Uri(
      path: '/terminal/${server.id}',
      queryParameters: {
        'initial': encoded,
        'title': 'docker exec ${container.displayName}',
      },
    );
    context.go(uri.toString());
  }
}

class _DockerComposeView extends ConsumerWidget {
  final Server server;
  final DockerSnapshot snapshot;
  final Future<void> Function(
    Future<void> Function(Server server) action, {
    bool refresh,
  })
  onAction;

  const _DockerComposeView({
    required this.server,
    required this.snapshot,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: snapshot.composeProjects.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return FilledButton.icon(
            onPressed: () => _createCompose(context, ref),
            icon: const Icon(Ionicons.add_outline),
            label: Text(l10n.dockerCreateCompose),
          );
        }
        final project = snapshot.composeProjects[index - 1];
        return _DockerCard(
          icon: Ionicons.layers_outline,
          title: project.name,
          subtitle: project.configPath,
          meta: [
            _composeStateLabel(l10n, project.state),
            if (project.containers.isNotEmpty)
              '${project.containers.length} ${l10n.dockerContainers}',
          ],
          trailing: OrbitaIconMenuButton<String>(
            icon: Ionicons.ellipsis_horizontal,
            title: project.name,
            onSelected: (value) => _handleMenu(context, ref, project, value),
            actions: [
              if (project.state != DockerComposeState.running)
                _menuItem('start', Ionicons.play_outline, l10n.dockerStart),
              if (project.state != DockerComposeState.stopped)
                _menuItem('stop', Ionicons.stop_outline, l10n.dockerStop),
              _menuItem(
                'restart',
                Ionicons.refresh_outline,
                l10n.dockerRestart,
              ),
              _menuItem('down', Ionicons.layers_outline, l10n.dockerDown),
              _menuItem('edit', Ionicons.create_outline, l10n.dockerEditYaml),
              _menuItem(
                'details',
                Ionicons.information_circle_outline,
                l10n.dockerDetails,
              ),
              _menuItem(
                'delete',
                Ionicons.trash_outline,
                l10n.commonDelete,
                destructive: true,
                dividerBefore: true,
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleMenu(
    BuildContext context,
    WidgetRef ref,
    DockerComposeProject project,
    String value,
  ) {
    switch (value) {
      case 'start':
        _composeAction(ref, project, DockerComposeAction.start);
      case 'stop':
        _composeAction(ref, project, DockerComposeAction.stop);
      case 'restart':
        _composeAction(ref, project, DockerComposeAction.restart);
      case 'down':
        _composeAction(ref, project, DockerComposeAction.down);
      case 'delete':
        _confirmDelete(context, ref, project);
      case 'edit':
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FileTextEditorPage(
              serverId: server.id,
              path: project.configPath,
              fileName: project.configPath.split('/').last,
            ),
          ),
        );
      case 'details':
        _showOutputDialog(
          context,
          AppLocalizations.of(context)!.dockerDetails,
          project.containers
              .map(
                (container) => '${container.displayName}  ${container.status}',
              )
              .join('\n'),
        );
    }
  }

  void _composeAction(
    WidgetRef ref,
    DockerComposeProject project,
    DockerComposeAction action,
  ) {
    onAction((server) async {
      final key = await resolveDockerKey(ref, server);
      await ref
          .read(dockerServiceProvider)
          .composeAction(
            server,
            project: project,
            action: action,
            composeCommand: snapshot.availability.composeCommand ?? '',
            key: key,
          );
    });
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    DockerComposeProject project,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.dockerDeleteComposeTitle,
      content: l10n.dockerDeleteComposeContent(project.name),
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;
    _composeAction(ref, project, DockerComposeAction.delete);
  }

  Future<void> _createCompose(BuildContext context, WidgetRef ref) async {
    final draft = await _showComposeDialog(context);
    if (draft == null) return;
    await onAction((server) async {
      final key = await resolveDockerKey(ref, server);
      await ref
          .read(dockerServiceProvider)
          .createCompose(
            server,
            projectName: draft.name,
            directory: draft.directory,
            yaml: draft.yaml,
            upAfterCreate: draft.upAfterCreate,
            composeCommand: snapshot.availability.composeCommand ?? '',
            key: key,
          );
    });
  }
}

class _DockerImageView extends ConsumerWidget {
  final Server server;
  final DockerSnapshot snapshot;
  final Future<void> Function(
    Future<void> Function(Server server) action, {
    bool refresh,
  })
  onAction;

  const _DockerImageView({
    required this.server,
    required this.snapshot,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    if (snapshot.images.isEmpty) {
      return EmptyState(
        icon: Ionicons.albums_outline,
        title: l10n.dockerNoImages,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: snapshot.images.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final image = snapshot.images[index];
        return _DockerCard(
          icon: Ionicons.albums_outline,
          title: image.reference,
          subtitle: image.id,
          meta: [
            image.size,
            if (image.containers.isNotEmpty)
              '${image.containers.length} ${l10n.dockerContainers}',
          ],
          trailing: OrbitaIconMenuButton<String>(
            icon: Ionicons.ellipsis_horizontal,
            title: image.reference,
            onSelected: (value) => _handleMenu(context, ref, image, value),
            actions: [
              _menuItem(
                'pull',
                Ionicons.cloud_download_outline,
                l10n.dockerPull,
              ),
              _menuItem(
                'details',
                Ionicons.information_circle_outline,
                l10n.dockerDetails,
              ),
              _menuItem(
                'remove',
                Ionicons.trash_outline,
                l10n.commonDelete,
                destructive: true,
                dividerBefore: true,
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleMenu(
    BuildContext context,
    WidgetRef ref,
    DockerImage image,
    String value,
  ) {
    switch (value) {
      case 'pull':
        _pullImage(context, ref, image);
      case 'remove':
        _confirmRemove(context, ref, image);
      case 'details':
        _showOutputDialog(
          context,
          AppLocalizations.of(context)!.dockerDetails,
          image.containers
              .map(
                (container) => '${container.displayName}  ${container.status}',
              )
              .join('\n'),
        );
    }
  }

  Future<void> _pullImage(
    BuildContext context,
    WidgetRef ref,
    DockerImage image,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final running = image.containers.where((item) => item.isRunning).length;
    if (running > 0) {
      final confirmed = await showConfirmDialog(
        context,
        title: l10n.dockerUpdateImage,
        content: l10n.dockerRunningContainersWarning(running),
      );
      if (!confirmed) return;
    }
    _imageAction(ref, image, DockerImageAction.pull);
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    DockerImage image,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.dockerDeleteImageTitle,
      content: l10n.dockerDeleteImageContent(image.reference),
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;
    _imageAction(ref, image, DockerImageAction.remove);
  }

  void _imageAction(
    WidgetRef ref,
    DockerImage image,
    DockerImageAction action,
  ) {
    onAction((server) async {
      final key = await resolveDockerKey(ref, server);
      await ref
          .read(dockerServiceProvider)
          .imageAction(
            server,
            reference: image.reference,
            action: action,
            key: key,
          );
    });
  }
}

class _DockerVolumeView extends ConsumerWidget {
  final Server server;
  final DockerSnapshot snapshot;
  final Future<void> Function(
    Future<void> Function(Server server) action, {
    bool refresh,
  })
  onAction;

  const _DockerVolumeView({
    required this.server,
    required this.snapshot,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    if (snapshot.volumes.isEmpty) {
      return EmptyState(
        icon: Ionicons.archive_outline,
        title: l10n.dockerNoVolumes,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: snapshot.volumes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final volume = snapshot.volumes[index];
        return _DockerCard(
          icon: Ionicons.archive_outline,
          title: volume.name,
          subtitle: volume.mountpoint,
          meta: [
            volume.driver,
            if (volume.containers.isNotEmpty)
              '${volume.containers.length} ${l10n.dockerContainers}',
          ],
          trailing: OrbitaIconMenuButton<String>(
            icon: Ionicons.ellipsis_horizontal,
            title: volume.name,
            onSelected: (value) => _handleMenu(context, ref, volume, value),
            actions: [
              _menuItem(
                'details',
                Ionicons.information_circle_outline,
                l10n.dockerDetails,
              ),
              _menuItem(
                'remove',
                Ionicons.trash_outline,
                l10n.commonDelete,
                destructive: true,
                dividerBefore: true,
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleMenu(
    BuildContext context,
    WidgetRef ref,
    DockerVolume volume,
    String value,
  ) {
    switch (value) {
      case 'details':
        _showOutputDialog(
          context,
          AppLocalizations.of(context)!.dockerDetails,
          [
            volume.mountpoint,
            for (final container in volume.containers)
              '${container.displayName}  ${container.status}',
          ].join('\n'),
        );
      case 'remove':
        _confirmRemove(context, ref, volume);
    }
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    DockerVolume volume,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    if (volume.containers.any((item) => item.isRunning)) {
      await showInfoDialog(
        context,
        title: l10n.dockerVolumeInUse,
        content: volume.containers.map((item) => item.displayName).join('\n'),
      );
      return;
    }
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.dockerDeleteVolumeTitle,
      content: l10n.dockerDeleteVolumeContent(volume.name),
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;
    await onAction((server) async {
      final key = await resolveDockerKey(ref, server);
      await ref
          .read(dockerServiceProvider)
          .volumeAction(
            server,
            name: volume.name,
            action: DockerVolumeAction.remove,
            key: key,
          );
    });
  }
}

class _DockerCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> meta;
  final Widget trailing;

  const _DockerCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withAlpha(24),
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (meta.where((item) => item.isNotEmpty).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final item in meta.where(
                          (item) => item.isNotEmpty,
                        ))
                          _MetaChip(label: item),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CountCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 156,
      child: Card(
        elevation: 2,
        shadowColor: theme.colorScheme.shadow.withAlpha(24),
        surfaceTintColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(value, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final List<Widget> children;

  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(children: children),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;

  const _MetaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

OrbitaMenuAction<String> _menuItem(
  String value,
  IconData icon,
  String label, {
  bool destructive = false,
  bool dividerBefore = false,
}) {
  return OrbitaMenuAction(
    value: value,
    icon: icon,
    label: label,
    destructive: destructive,
    dividerBefore: dividerBefore,
  );
}

IconData _iconForSection(_DockerSection section) {
  return switch (section) {
    _DockerSection.overview => Ionicons.speedometer_outline,
    _DockerSection.containers => Ionicons.apps_outline,
    _DockerSection.compose => Ionicons.layers_outline,
    _DockerSection.images => Ionicons.albums_outline,
    _DockerSection.volumes => Ionicons.archive_outline,
  };
}

String _labelForSection(AppLocalizations l10n, _DockerSection section) {
  return switch (section) {
    _DockerSection.overview => l10n.dockerOverview,
    _DockerSection.containers => l10n.dockerContainers,
    _DockerSection.compose => l10n.dockerCompose,
    _DockerSection.images => l10n.dockerImages,
    _DockerSection.volumes => l10n.dockerVolumes,
  };
}

String _composeStateLabel(AppLocalizations l10n, DockerComposeState state) {
  return switch (state) {
    DockerComposeState.running => l10n.dockerRunning,
    DockerComposeState.stopped => l10n.dockerStopped,
    DockerComposeState.mixed => l10n.dockerMixed,
    DockerComposeState.unknown => l10n.dockerUnknown,
  };
}

Future<void> _showOutputDialog(
  BuildContext context,
  String title,
  String output,
) async {
  await showOrbitaDialog<void>(
    context: context,
    builder: (context, animation) => OrbitaDialog(
      animation: animation,
      title: title,
      actions: [
        OrbitaDialogAction(
          label: AppLocalizations.of(context)!.dockerCopyOutput,
          variant: FButtonVariant.outline,
          onPress: () {
            Clipboard.setData(ClipboardData(text: output));
            Navigator.of(context).pop();
          },
        ),
        OrbitaDialogAction(
          label: AppLocalizations.of(context)!.commonOk,
          onPress: () => Navigator.of(context).pop(),
        ),
      ],
      child: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: SelectableText(output.isEmpty ? '-' : output),
        ),
      ),
    ),
  );
}

Future<_ComposeDraft?> _showComposeDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final nameController = TextEditingController();
  final directoryController = TextEditingController();
  final yamlController = TextEditingController(
    text:
        'services:\n  app:\n    image: nginx:latest\n    restart: unless-stopped\n',
  );
  var upAfterCreate = true;
  final formKey = GlobalKey<FormState>();
  final result = await showOrbitaDialog<_ComposeDraft>(
    context: context,
    builder: (context, animation) => StatefulBuilder(
      builder: (context, setState) => OrbitaDialog(
        animation: animation,
        title: l10n.dockerCreateCompose,
        actions: [
          OrbitaDialogAction(
            label: l10n.commonCancel,
            variant: FButtonVariant.outline,
            onPress: () => Navigator.of(context).pop(),
          ),
          OrbitaDialogAction(
            label: l10n.commonSave,
            onPress: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(context).pop(
                _ComposeDraft(
                  name: nameController.text.trim(),
                  directory: directoryController.text.trim(),
                  yaml: yamlController.text,
                  upAfterCreate: upAfterCreate,
                ),
              );
            },
          ),
        ],
        child: SizedBox(
          width: 560,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FTextFormField(
                    control: FTextFieldControl.managed(
                      controller: nameController,
                    ),
                    label: Text(l10n.dockerProjectName),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? l10n.validationRequired
                        : null,
                  ),
                  const SizedBox(height: 12),
                  FTextFormField(
                    control: FTextFieldControl.managed(
                      controller: directoryController,
                    ),
                    label: Text(l10n.dockerRemoteDirectory),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? l10n.validationRequired
                        : null,
                  ),
                  const SizedBox(height: 12),
                  FTextFormField.multiline(
                    control: FTextFieldControl.managed(
                      controller: yamlController,
                    ),
                    label: Text(l10n.dockerComposeYaml),
                    minLines: 8,
                    maxLines: 14,
                  ),
                  FSwitch(
                    value: upAfterCreate,
                    onChange: (value) => setState(() => upAfterCreate = value),
                    label: Text(l10n.dockerDeployNow),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  nameController.dispose();
  directoryController.dispose();
  yamlController.dispose();
  return result;
}

class _ComposeDraft {
  final String name;
  final String directory;
  final String yaml;
  final bool upAfterCreate;

  const _ComposeDraft({
    required this.name,
    required this.directory,
    required this.yaml,
    required this.upAfterCreate,
  });
}
