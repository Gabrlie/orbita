enum DockerAvailabilityState { available, missing, permissionDenied, error }

enum DockerContainerState {
  running,
  stopped,
  exited,
  paused,
  restarting,
  other,
}

enum DockerComposeState { running, stopped, mixed, unknown }

enum DockerContainerAction { start, stop, restart, remove }

enum DockerComposeAction { start, stop, restart, down, delete }

enum DockerImageAction { remove, pull }

enum DockerVolumeAction { remove }

class DockerAvailability {
  final DockerAvailabilityState state;
  final String? message;
  final String? composeCommand;

  const DockerAvailability({
    required this.state,
    this.message,
    this.composeCommand,
  });

  bool get isAvailable => state == DockerAvailabilityState.available;
}

class DockerInfo {
  final String serverVersion;
  final String composeVersion;
  final String storageDriver;
  final String rootDir;
  final String architecture;
  final int cpus;
  final int memoryBytes;

  const DockerInfo({
    required this.serverVersion,
    required this.composeVersion,
    required this.storageDriver,
    required this.rootDir,
    required this.architecture,
    required this.cpus,
    required this.memoryBytes,
  });
}

class DockerContainer {
  final String id;
  final String names;
  final String image;
  final String imageId;
  final String command;
  final String status;
  final String state;
  final String ports;
  final String createdAt;
  final String composeProject;
  final String composeConfigFiles;

  const DockerContainer({
    required this.id,
    required this.names,
    required this.image,
    required this.imageId,
    required this.command,
    required this.status,
    required this.state,
    required this.ports,
    required this.createdAt,
    required this.composeProject,
    required this.composeConfigFiles,
  });

  DockerContainerState get lifecycleState {
    return switch (state.toLowerCase()) {
      'running' => DockerContainerState.running,
      'paused' => DockerContainerState.paused,
      'restarting' => DockerContainerState.restarting,
      'exited' => DockerContainerState.exited,
      'created' || 'dead' || 'removing' => DockerContainerState.stopped,
      _ => DockerContainerState.other,
    };
  }

  bool get isRunning => lifecycleState == DockerContainerState.running;

  String get displayName => names.replaceFirst(RegExp(r'^/+'), '');
}

class DockerImage {
  final String id;
  final String repository;
  final String tag;
  final String createdAt;
  final String size;
  final List<DockerContainer> containers;

  const DockerImage({
    required this.id,
    required this.repository,
    required this.tag,
    required this.createdAt,
    required this.size,
    this.containers = const [],
  });

  String get reference => tag == '<none>' ? repository : '$repository:$tag';
}

class DockerVolume {
  final String name;
  final String driver;
  final String mountpoint;
  final List<DockerContainer> containers;

  const DockerVolume({
    required this.name,
    required this.driver,
    required this.mountpoint,
    this.containers = const [],
  });
}

class DockerComposeProject {
  final String name;
  final String configPath;
  final List<DockerContainer> containers;

  const DockerComposeProject({
    required this.name,
    required this.configPath,
    required this.containers,
  });

  DockerComposeState get state {
    if (containers.isEmpty) return DockerComposeState.unknown;
    final running = containers.where((container) => container.isRunning).length;
    if (running == containers.length) return DockerComposeState.running;
    if (running == 0) return DockerComposeState.stopped;
    return DockerComposeState.mixed;
  }
}

class DockerSnapshot {
  final DockerAvailability availability;
  final DockerInfo? info;
  final List<DockerContainer> containers;
  final List<DockerImage> images;
  final List<DockerVolume> volumes;
  final List<DockerComposeProject> composeProjects;

  const DockerSnapshot({
    required this.availability,
    this.info,
    this.containers = const [],
    this.images = const [],
    this.volumes = const [],
    this.composeProjects = const [],
  });
}
