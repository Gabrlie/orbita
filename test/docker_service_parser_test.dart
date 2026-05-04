import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/models/docker_models.dart';
import 'package:orbita/services/docker_service.dart';

void main() {
  test('parseDockerSnapshot parses overview and linked resources', () {
    const availability = DockerAvailability(
      state: DockerAvailabilityState.available,
      composeCommand: 'docker compose',
    );

    final snapshot = parseDockerSnapshot(_sampleSnapshot, availability);

    expect(snapshot.info?.serverVersion, '27.0.0');
    expect(snapshot.info?.composeVersion, '2.27.0');
    expect(snapshot.containers, hasLength(2));
    expect(snapshot.images.single.containers.first.displayName, 'web');
    expect(snapshot.volumes.single.containers.single.isRunning, isTrue);
    expect(snapshot.composeProjects.single.name, 'site');
    expect(
      snapshot.composeProjects.single.configPath,
      '/opt/site/compose.yaml',
    );
  });

  test('parseDockerSnapshot tolerates info warnings and flat fallbacks', () {
    const availability = DockerAvailability(
      state: DockerAvailabilityState.available,
      composeCommand: 'docker compose',
    );

    final snapshot = parseDockerSnapshot(_infoFallbackSnapshot, availability);

    expect(snapshot.info?.serverVersion, '28.1.1');
    expect(snapshot.info?.composeVersion, '2.35.1');
    expect(snapshot.info?.storageDriver, 'overlay2');
    expect(snapshot.info?.rootDir, '/var/lib/docker');
    expect(snapshot.info?.architecture, 'x86_64');
    expect(snapshot.info?.cpus, 16);
    expect(snapshot.info?.memoryBytes, 33554432);
  });

  test('DockerContainer lifecycle maps running and stopped states', () {
    final running = _container(state: 'running');
    final exited = _container(state: 'exited');

    expect(running.isRunning, isTrue);
    expect(exited.isRunning, isFalse);
    expect(running.lifecycleState, DockerContainerState.running);
    expect(exited.lifecycleState, DockerContainerState.exited);
  });
}

DockerContainer _container({required String state}) {
  return DockerContainer(
    id: 'abc',
    names: 'web',
    image: 'nginx:latest',
    imageId: 'sha256:image1',
    command: '',
    status: state,
    state: state,
    ports: '',
    createdAt: '',
    composeProject: '',
    composeConfigFiles: '',
  );
}

const _sampleSnapshot = '''
__ORBITA_INFO__
{"ServerVersion":"27.0.0","Driver":"overlay2","DockerRootDir":"/var/lib/docker","Architecture":"x86_64","NCPU":4,"MemTotal":8589934592}
__ORBITA_COMPOSE_VERSION__
2.27.0
__ORBITA_CONTAINERS__
{"ID":"abc123456789","Names":"web","Image":"nginx:latest","ImageID":"sha256:image1","Command":"nginx","Status":"Up 2 minutes","State":"running","Ports":"80/tcp","CreatedAt":"now","Labels":"com.docker.compose.project=site,com.docker.compose.project.config_files=/opt/site/compose.yaml"}
{"ID":"def123456789","Names":"worker","Image":"alpine:latest","ImageID":"sha256:image2","Command":"sh","Status":"Exited","State":"exited","Ports":"","CreatedAt":"now","Labels":"com.docker.compose.project=site,com.docker.compose.project.config_files=/opt/site/compose.yaml"}
__ORBITA_CONTAINER_INSPECT__
[
  {
    "Id":"abc123456789",
    "Name":"/web",
    "Image":"sha256:image1",
    "Config":{"Labels":{"com.docker.compose.project":"site","com.docker.compose.project.config_files":"/opt/site/compose.yaml"}},
    "Mounts":[{"Type":"volume","Name":"data"}]
  },
  {
    "Id":"def123456789",
    "Name":"/worker",
    "Image":"sha256:image2",
    "Config":{"Labels":{"com.docker.compose.project":"site","com.docker.compose.project.config_files":"/opt/site/compose.yaml"}},
    "Mounts":[]
  }
]
__ORBITA_IMAGES__
{"ID":"image1","Repository":"nginx","Tag":"latest","CreatedAt":"now","Size":"80MB"}
__ORBITA_VOLUMES__
{"Name":"data","Driver":"local"}
__ORBITA_VOLUME_INSPECT__
[{"Name":"data","Driver":"local","Mountpoint":"/var/lib/docker/volumes/data/_data"}]
__ORBITA_COMPOSE_FILES__
/opt/site/compose.yaml
''';

const _infoFallbackSnapshot = '''
__ORBITA_INFO__
WARNING: bridge-nf-call-iptables is disabled
{"driver":"","dockerRootDir":"","architecture":"","NCPU":0,"MemTotal":0}
__ORBITA_DOCKER_VERSION__
28.1.1
__ORBITA_INFO_FLAT__
Driver=overlay2
DockerRootDir=/var/lib/docker
Architecture=x86_64
NCPU=16
MemTotal=33554432
__ORBITA_COMPOSE_VERSION__
2.35.1
__ORBITA_CONTAINERS__
__ORBITA_CONTAINER_INSPECT__
[]
__ORBITA_IMAGES__
__ORBITA_VOLUMES__
__ORBITA_VOLUME_INSPECT__
[]
__ORBITA_COMPOSE_FILES__
''';
