import 'dart:convert';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:orbita/models/docker_models.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/services/docker_command_builder.dart';
import 'package:orbita/services/ssh_connection_manager.dart';
import 'package:orbita/services/ssh_service.dart';

class DockerService {
  final SshConnectionManager _connectionManager;

  const DockerService(this._connectionManager);

  Future<DockerAvailability> checkAvailability(Server server, {SshKey? key}) {
    return _withSsh(server, key: key, _checkAvailability);
  }

  Future<DockerSnapshot> loadSnapshot(Server server, {SshKey? key}) {
    return _withSsh(server, key: key, (ssh) async {
      final availability = await _checkAvailability(ssh);
      if (!availability.isAvailable) {
        return DockerSnapshot(availability: availability);
      }
      final composeCommand = availability.composeCommand ?? 'docker compose';
      final output = await ssh.execute(dockerSnapshotCommand(composeCommand));
      return parseDockerSnapshot(output, availability);
    });
  }

  Future<DockerAvailability> _checkAvailability(SshClientSession ssh) async {
    final output = await ssh.execute(dockerAvailabilityCommand());
    if (output.contains('__ORBITA_DOCKER_MISSING__')) {
      return const DockerAvailability(state: DockerAvailabilityState.missing);
    }
    if (!output.trimLeft().startsWith('{')) {
      final lower = output.toLowerCase();
      return DockerAvailability(
        state: lower.contains('permission denied')
            ? DockerAvailabilityState.permissionDenied
            : DockerAvailabilityState.error,
        message: output.trim(),
      );
    }
    final composeCommand = await _composeCommand(ssh);
    return DockerAvailability(
      state: DockerAvailabilityState.available,
      composeCommand: composeCommand,
    );
  }

  Future<String> inspect(Server server, String id, {SshKey? key}) {
    return _withSsh(
      server,
      key: key,
      (ssh) => _executeChecked(ssh, dockerInspectCommand(id)),
    );
  }

  Future<void> containerAction(
    Server server, {
    required String id,
    required DockerContainerAction action,
    SshKey? key,
  }) {
    return _withSsh(
      server,
      key: key,
      (ssh) => _executeChecked(ssh, dockerContainerActionCommand(id, action)),
    );
  }

  Future<void> composeAction(
    Server server, {
    required DockerComposeProject project,
    required DockerComposeAction action,
    required String composeCommand,
    SshKey? key,
  }) {
    return _withSsh(
      server,
      key: key,
      (ssh) => _executeChecked(
        ssh,
        dockerComposeActionCommand(composeCommand, project.configPath, action),
      ),
    );
  }

  Future<void> imageAction(
    Server server, {
    required String reference,
    required DockerImageAction action,
    SshKey? key,
  }) {
    return _withSsh(
      server,
      key: key,
      (ssh) =>
          _executeChecked(ssh, dockerImageActionCommand(reference, action)),
    );
  }

  Future<void> volumeAction(
    Server server, {
    required String name,
    required DockerVolumeAction action,
    SshKey? key,
  }) {
    return _withSsh(
      server,
      key: key,
      (ssh) => _executeChecked(ssh, dockerVolumeActionCommand(name, action)),
    );
  }

  Future<void> createCompose(
    Server server, {
    required String projectName,
    required String directory,
    required String yaml,
    required bool upAfterCreate,
    required String composeCommand,
    SshKey? key,
  }) {
    return _withSsh(server, key: key, (ssh) async {
      await _executeChecked(
        ssh,
        dockerWriteComposeCommand(directory: directory, yaml: yaml),
      );
      if (upAfterCreate) {
        await _executeChecked(
          ssh,
          dockerComposeActionCommand(
            composeCommand,
            '$directory/compose.yaml',
            DockerComposeAction.start,
            projectName: projectName,
          ),
        );
      }
    });
  }

  Future<void> streamLogs(
    Server server, {
    required String command,
    required void Function(String chunk) onOutput,
    bool Function()? shouldStop,
    SshKey? key,
  }) {
    return _withSsh(
      server,
      key: key,
      (ssh) => ssh.executeStreaming(
        command,
        onOutput: onOutput,
        shouldStop: shouldStop,
      ),
    );
  }

  Future<T> _withSsh<T>(
    Server server,
    Future<T> Function(SshClientSession ssh) action, {
    SshKey? key,
  }) async {
    final lease = await _connectionManager.acquire(server, key: key);
    try {
      return await action(lease.service);
    } catch (error) {
      if (_shouldDropConnection(error)) {
        _connectionManager.markUnhealthy(server.id, lease.service);
      }
      rethrow;
    } finally {
      lease.release();
    }
  }

  Future<String> _composeCommand(SshClientSession ssh) async {
    return (await ssh.execute(dockerComposeCommandProbe())).trim();
  }

  Future<String> _executeChecked(SshClientSession ssh, String command) async {
    final output = await ssh.execute(
      'set -e\n$command\nprintf "\\n__ORBITA_CMD_OK__"',
    );
    if (!output.contains('__ORBITA_CMD_OK__')) {
      throw DockerException(output.trim());
    }
    return output.replaceAll('__ORBITA_CMD_OK__', '').trim();
  }

  bool _shouldDropConnection(Object error) {
    return error is SSHStateError ||
        error is SSHChannelOpenError ||
        error is SocketException ||
        error is StateError;
  }
}

class DockerException implements Exception {
  final String message;

  const DockerException(this.message);

  @override
  String toString() => message.isEmpty ? 'Docker command failed' : message;
}

DockerSnapshot parseDockerSnapshot(
  String output,
  DockerAvailability availability,
) {
  final sections = _splitSections(output);
  final containerInspect = _jsonList(sections['CONTAINER_INSPECT']);
  final containers = _parseContainers(
    sections['CONTAINERS'] ?? '',
    containerInspect,
  );
  final images = _parseImages(sections['IMAGES'] ?? '', containers);
  final volumes = _parseVolumes(
    sections['VOLUMES'] ?? '',
    sections['VOLUME_INSPECT'] ?? '',
    containers,
    containerInspect,
  );
  final projects = _parseComposeProjects(
    containers,
    sections['COMPOSE_FILES'] ?? '',
  );

  return DockerSnapshot(
    availability: availability,
    info: _parseInfo(
      sections['INFO'] ?? '',
      sections['COMPOSE_VERSION']?.trim() ?? '',
      sections['DOCKER_VERSION']?.trim() ?? '',
      sections['INFO_FLAT'] ?? '',
    ),
    containers: containers,
    images: images,
    volumes: volumes,
    composeProjects: projects,
  );
}

Map<String, String> _splitSections(String output) {
  final sections = <String, StringBuffer>{};
  String? current;
  for (final line in output.split('\n')) {
    final match = RegExp(r'^__ORBITA_([A-Z_]+)__$').firstMatch(line.trim());
    if (match != null) {
      current = match.group(1);
      sections.putIfAbsent(current!, StringBuffer.new);
      continue;
    }
    if (current != null) sections[current]!.writeln(line);
  }
  return sections.map((key, value) => MapEntry(key, value.toString()));
}

DockerInfo? _parseInfo(
  String raw,
  String composeVersion,
  String dockerVersion,
  String flatRaw,
) {
  final json = _jsonObject(_firstJsonObject(raw));
  final flat = _keyValues(flatRaw);
  if (json == null && flat.isEmpty && dockerVersion.isEmpty) return null;
  return DockerInfo(
    serverVersion: _firstString([
      dockerVersion,
      _field(json, const ['ServerVersion']),
      _field(json, const ['serverVersion']),
      _field(json, const ['Server', 'Version']),
    ]),
    composeVersion: composeVersion,
    storageDriver: _firstString([
      _field(json, const ['Driver']),
      _field(json, const ['driver']),
      flat['Driver'],
    ]),
    rootDir: _firstString([
      _field(json, const ['DockerRootDir']),
      _field(json, const ['dockerRootDir']),
      _field(json, const ['DockerRootDIR']),
      flat['DockerRootDir'],
    ]),
    architecture: _firstString([
      _field(json, const ['Architecture']),
      _field(json, const ['architecture']),
      _field(json, const ['Server', 'Arch']),
      flat['Architecture'],
    ]),
    cpus: _firstInt([
      _field(json, const ['NCPU']),
      _field(json, const ['Ncpu']),
      _field(json, const ['nCPU']),
      _field(json, const ['cpuCount']),
      flat['NCPU'],
    ]),
    memoryBytes: _firstInt([
      _field(json, const ['MemTotal']),
      _field(json, const ['memTotal']),
      _field(json, const ['memoryTotal']),
      flat['MemTotal'],
    ]),
  );
}

List<DockerContainer> _parseContainers(
  String raw,
  List<Map<String, Object?>> inspect,
) {
  final inspectById = {
    for (final item in inspect)
      '${item['Id'] ?? ''}'.substringSafe(0, 12): item,
  };
  return raw
      .split('\n')
      .map((line) => _jsonObject(line.trim()))
      .whereType<Map<String, Object?>>()
      .map((json) {
        final id = '${json['ID'] ?? json['Id'] ?? ''}';
        final inspected = inspectById[id.substringSafe(0, 12)] ?? const {};
        final labels = _labelsFrom(inspected['Config'])..addAll(_labels(json));
        return DockerContainer(
          id: id,
          names: '${json['Names'] ?? json['Names'] ?? ''}',
          image: '${json['Image'] ?? ''}',
          imageId: '${json['ImageID'] ?? inspected['Image'] ?? ''}',
          command: '${json['Command'] ?? ''}',
          status: '${json['Status'] ?? ''}',
          state: '${json['State'] ?? ''}',
          ports: '${json['Ports'] ?? ''}',
          createdAt: '${json['CreatedAt'] ?? ''}',
          composeProject: labels['com.docker.compose.project'] ?? '',
          composeConfigFiles:
              labels['com.docker.compose.project.config_files'] ?? '',
        );
      })
      .toList();
}

List<DockerImage> _parseImages(String raw, List<DockerContainer> containers) {
  return raw
      .split('\n')
      .map((line) => _jsonObject(line.trim()))
      .whereType<Map<String, Object?>>()
      .map((json) {
        final id = '${json['ID'] ?? json['Id'] ?? ''}';
        final repo = '${json['Repository'] ?? ''}';
        final tag = '${json['Tag'] ?? ''}';
        final ref = tag == '<none>' ? repo : '$repo:$tag';
        final linked = containers
            .where(
              (container) =>
                  container.image == ref ||
                  container.image == repo ||
                  container.imageId.contains(id.replaceFirst('sha256:', '')),
            )
            .toList();
        return DockerImage(
          id: id,
          repository: repo,
          tag: tag,
          createdAt: '${json['CreatedAt'] ?? ''}',
          size: '${json['Size'] ?? ''}',
          containers: linked,
        );
      })
      .toList();
}

List<DockerVolume> _parseVolumes(
  String raw,
  String inspectRaw,
  List<DockerContainer> containers,
  List<Map<String, Object?>> containerInspect,
) {
  final inspected = {
    for (final item in _jsonList(inspectRaw)) '${item['Name'] ?? ''}': item,
  };
  final containerNamesByVolume = <String, List<String>>{};
  for (final container in containerInspect) {
    final name = '${container['Name'] ?? ''}'.replaceFirst(RegExp(r'^/+'), '');
    final mounts = container['Mounts'];
    if (mounts is! List) continue;
    for (final mount in mounts.whereType<Map>()) {
      if (mount['Type'] != 'volume') continue;
      final volumeName = '${mount['Name'] ?? ''}';
      containerNamesByVolume.putIfAbsent(volumeName, () => []).add(name);
    }
  }
  return raw
      .split('\n')
      .map((line) => _jsonObject(line.trim()))
      .whereType<Map<String, Object?>>()
      .map((json) {
        final name = '${json['Name'] ?? ''}';
        final inspect = inspected[name] ?? const {};
        final linkedNames = containerNamesByVolume[name] ?? const <String>[];
        return DockerVolume(
          name: name,
          driver: '${json['Driver'] ?? inspect['Driver'] ?? ''}',
          mountpoint: '${inspect['Mountpoint'] ?? ''}',
          containers: [
            for (final linkedName in linkedNames)
              containers.firstWhere(
                (container) => container.displayName == linkedName,
                orElse: () => DockerContainer(
                  id: '',
                  names: linkedName,
                  image: '',
                  imageId: '',
                  command: '',
                  status: '',
                  state: '',
                  ports: '',
                  createdAt: '',
                  composeProject: '',
                  composeConfigFiles: '',
                ),
              ),
          ],
        );
      })
      .toList();
}

List<DockerComposeProject> _parseComposeProjects(
  List<DockerContainer> containers,
  String composeFilesRaw,
) {
  final groups = <String, List<DockerContainer>>{};
  for (final container in containers) {
    if (container.composeProject.isEmpty) continue;
    groups.putIfAbsent(container.composeProject, () => []).add(container);
  }
  final discoveredFiles = composeFilesRaw
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
  final projects = [
    for (final entry in groups.entries)
      DockerComposeProject(
        name: entry.key,
        configPath: entry.value.first.composeConfigFiles.split(',').first,
        containers: entry.value,
      ),
  ];
  for (final file in discoveredFiles) {
    final name = file.split('/').reversed.skip(1).firstOrNull ?? file;
    if (projects.any((project) => project.configPath == file)) continue;
    projects.add(
      DockerComposeProject(name: name, configPath: file, containers: const []),
    );
  }
  return projects;
}

Map<String, Object?>? _jsonObject(String raw) {
  if (raw.isEmpty) return null;
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map) return Map<String, Object?>.from(decoded);
  } catch (_) {}
  return null;
}

String _firstJsonObject(String raw) {
  final start = raw.indexOf('{');
  final end = raw.lastIndexOf('}');
  if (start < 0 || end < start) return raw.trim();
  return raw.substring(start, end + 1);
}

Map<String, String> _keyValues(String raw) {
  final values = <String, String>{};
  for (final line in raw.split('\n')) {
    final index = line.indexOf('=');
    if (index <= 0) continue;
    final key = line.substring(0, index).trim();
    final value = line.substring(index + 1).trim();
    if (key.isNotEmpty && value.isNotEmpty) values[key] = value;
  }
  return values;
}

Object? _field(Map<String, Object?>? json, List<String> path) {
  Object? current = json;
  for (final key in path) {
    if (current is! Map) return null;
    current = current[key];
  }
  return current;
}

String _firstString(List<Object?> values) {
  for (final value in values) {
    final string = '${value ?? ''}'.trim();
    if (string.isNotEmpty && string != 'null') return string;
  }
  return '';
}

int _firstInt(List<Object?> values) {
  for (final value in values) {
    final parsed = _intValue(value);
    if (parsed > 0) return parsed;
  }
  return 0;
}

List<Map<String, Object?>> _jsonList(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, Object?>.from(item))
          .toList();
    }
  } catch (_) {}
  return const [];
}

Map<String, String> _labelsFrom(Object? config) {
  if (config is Map && config['Labels'] is Map) {
    return Map<String, String>.from(config['Labels'] as Map);
  }
  return {};
}

Map<String, String> _labels(Map<String, Object?> json) {
  final raw = '${json['Labels'] ?? ''}';
  final labels = <String, String>{};
  for (final part in raw.split(',')) {
    final index = part.indexOf('=');
    if (index <= 0) continue;
    labels[part.substring(0, index)] = part.substring(index + 1);
  }
  return labels;
}

int _intValue(Object? value) {
  if (value is int) return value;
  return int.tryParse('$value') ?? 0;
}

extension on String {
  String substringSafe(int start, [int? end]) {
    if (isEmpty || start >= length) return '';
    final safeEnd = end == null || end > length ? length : end;
    return substring(start, safeEnd);
  }
}
