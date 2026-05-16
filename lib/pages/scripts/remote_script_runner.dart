import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/remote_script.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/server_group.dart';
import 'package:orbita/providers/remote_script_provider.dart';
import 'package:orbita/providers/server_group_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/services/orbita_script_syntax.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/orbita_forui.dart';
import 'package:orbita/widgets/os_icon.dart';
import 'package:orbita/widgets/remote_script_output_dialog.dart';

Future<void> runRemoteScriptFromContext(
  BuildContext context,
  WidgetRef ref,
  RemoteScript script,
) async {
  final l10n = AppLocalizations.of(context)!;
  final servers = ref.read(serverListProvider).value ?? const <Server>[];
  final groupState = ref.read(serverGroupProvider);
  if (servers.isEmpty) {
    await showInfoDialog(
      context,
      title: l10n.noServersTitle,
      content: l10n.noServersSubtitle,
    );
    return;
  }

  final server = await _selectServer(context, servers, groupState);
  if (server == null || !context.mounted) return;

  final runnableScript = await _prepareScript(context, script);
  if (runnableScript == null || !context.mounted) return;

  final key = await resolveRemoteScriptKey(ref, server);
  if (!context.mounted) return;
  await showOrbitaDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context, animation) => RemoteScriptOutputDialog(
      title: l10n.scriptRunningOn(runnableScript.name, server.name),
      successMessage: l10n.scriptRunSucceeded,
      failureMessage: l10n.scriptRunFailed,
      onRun: (onOutput) => ref
          .read(remoteScriptServiceProvider)
          .run(server, script: runnableScript, key: key, onOutput: onOutput),
      animation: animation,
    ),
  );
}

Future<Server?> _selectServer(
  BuildContext context,
  List<Server> servers,
  ServerGroupState groupState,
) {
  final l10n = AppLocalizations.of(context)!;
  final buckets = groupServersForDisplay(
    servers: servers,
    groupState: groupState,
    unnamedGroupName: l10n.serverGroupUnnamed,
  ).where((bucket) => bucket.servers.isNotEmpty).toList();
  final showHeaders = shouldShowServerGroupHeaders(buckets);
  return showOrbitaDialog<Server>(
    context: context,
    builder: (context, animation) => OrbitaDialog(
      animation: animation,
      title: l10n.scriptSelectServer,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final bucket in buckets) ...[
            if (showHeaders)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    bucket.name,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ),
            for (final server in bucket.servers)
              FItem(
                prefix: OsIcon(type: server.osType, size: 20),
                title: Text(server.name),
                subtitle: Text(server.displayEndpoint),
                onPress: () => Navigator.of(context).pop(server),
              ),
          ],
        ],
      ),
    ),
  );
}

Future<RemoteScript?> _prepareScript(
  BuildContext context,
  RemoteScript script,
) async {
  final template = parseOrbitaScript(script.command);
  if (!template.hasInputs) return script;

  final values = <String, String>{};
  for (final select in template.selects) {
    final value = await _selectScriptOption(context, select);
    if (value == null || !context.mounted) return null;
    values[select.name] = value;
  }
  return script.copyWith(command: renderOrbitaScript(template, values));
}

Future<String?> _selectScriptOption(
  BuildContext context,
  OrbitaScriptSelect select,
) {
  return showOrbitaDialog<String>(
    context: context,
    builder: (context, animation) => OrbitaDialog(
      animation: animation,
      title: select.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in select.options)
            FItem(
              title: Text(option.label),
              onPress: () => Navigator.of(context).pop(option.value),
            ),
        ],
      ),
    ),
  );
}
