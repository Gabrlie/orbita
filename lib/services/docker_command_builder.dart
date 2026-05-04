import 'dart:convert';

import 'package:orbita/models/docker_models.dart';
import 'package:orbita/services/remote_file_command_builder.dart';

String dockerAvailabilityCommand() {
  return '''
if ! command -v docker >/dev/null 2>&1; then
  printf '__ORBITA_DOCKER_MISSING__'
  exit 0
fi
docker info --format '{{json .}}' 2>&1
''';
}

String dockerComposeCommandProbe() {
  return '''
if docker compose version >/dev/null 2>&1; then
  printf 'docker compose'
elif command -v docker-compose >/dev/null 2>&1; then
  printf 'docker-compose'
fi
''';
}

String dockerSnapshotCommand(String composeCommand) {
  final compose = composeCommand.isEmpty ? 'docker compose' : composeCommand;
  return '''
printf '__ORBITA_INFO__\\n'
docker info --format '{{json .}}' 2>/dev/null || true
printf '\\n__ORBITA_DOCKER_VERSION__\\n'
docker version --format '{{.Server.Version}}' 2>/dev/null || true
printf '\\n__ORBITA_INFO_FLAT__\\n'
docker info --format 'Driver={{.Driver}}
DockerRootDir={{.DockerRootDir}}
Architecture={{.Architecture}}
NCPU={{.NCPU}}
MemTotal={{.MemTotal}}' 2>/dev/null || true
printf '\\n__ORBITA_COMPOSE_VERSION__\\n'
$compose version --short 2>/dev/null || true
printf '\\n__ORBITA_CONTAINERS__\\n'
docker ps -a --format '{{json .}}' 2>/dev/null || true
printf '\\n__ORBITA_CONTAINER_INSPECT__\\n'
docker inspect \$(docker ps -aq) 2>/dev/null || true
printf '\\n__ORBITA_IMAGES__\\n'
docker images --format '{{json .}}' 2>/dev/null || true
printf '\\n__ORBITA_VOLUMES__\\n'
docker volume ls --format '{{json .}}' 2>/dev/null || true
printf '\\n__ORBITA_VOLUME_INSPECT__\\n'
docker volume inspect \$(docker volume ls -q) 2>/dev/null || true
printf '\\n__ORBITA_COMPOSE_FILES__\\n'
find /opt /srv /var/www "\$HOME" -maxdepth 4 \\( -name compose.yaml -o -name compose.yml -o -name docker-compose.yml -o -name docker-compose.yaml \\) 2>/dev/null || true
''';
}

String dockerInspectCommand(String id) {
  return 'docker inspect ${shellQuote(id)}';
}

String dockerContainerActionCommand(String id, DockerContainerAction action) {
  final target = shellQuote(id);
  return switch (action) {
    DockerContainerAction.start => 'docker start $target',
    DockerContainerAction.stop => 'docker stop $target',
    DockerContainerAction.restart => 'docker restart $target',
    DockerContainerAction.remove => 'docker rm -f $target',
  };
}

String dockerLogsCommand(String id) {
  return 'docker logs --tail 200 -f ${shellQuote(id)}';
}

String dockerExecCommand(String id, String shell) {
  return 'docker exec -it ${shellQuote(id)} ${shellQuote(shell)}';
}

String dockerComposeActionCommand(
  String composeCommand,
  String configPath,
  DockerComposeAction action, {
  String? projectName,
}) {
  final command = composeCommand.isEmpty ? 'docker compose' : composeCommand;
  final project = projectName == null || projectName.isEmpty
      ? ''
      : '-p ${shellQuote(projectName)} ';
  final file = shellQuote(configPath);
  return switch (action) {
    DockerComposeAction.start => '$command $project-f $file up -d',
    DockerComposeAction.stop => '$command $project-f $file stop',
    DockerComposeAction.restart => '$command $project-f $file restart',
    DockerComposeAction.down => '$command $project-f $file down',
    DockerComposeAction.delete => 'rm -f -- $file',
  };
}

String dockerImageActionCommand(String reference, DockerImageAction action) {
  final image = shellQuote(reference);
  return switch (action) {
    DockerImageAction.remove => 'docker rmi $image',
    DockerImageAction.pull => 'docker pull $image',
  };
}

String dockerVolumeActionCommand(String name, DockerVolumeAction action) {
  final volume = shellQuote(name);
  return switch (action) {
    DockerVolumeAction.remove => 'docker volume rm $volume',
  };
}

String dockerWriteComposeCommand({
  required String directory,
  required String yaml,
}) {
  final encoded = base64.encode(utf8.encode(yaml));
  final dir = shellQuote(directory);
  final file = shellQuote('$directory/compose.yaml');
  return '''
mkdir -p -- $dir
printf %s ${shellQuote(encoded)} | base64 -d > $file
''';
}
