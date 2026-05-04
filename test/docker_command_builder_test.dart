import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/models/docker_models.dart';
import 'package:orbita/services/docker_command_builder.dart';

void main() {
  test('container actions build mutually exclusive lifecycle commands', () {
    expect(
      dockerContainerActionCommand('abc123', DockerContainerAction.start),
      "docker start 'abc123'",
    );
    expect(
      dockerContainerActionCommand('abc123', DockerContainerAction.stop),
      "docker stop 'abc123'",
    );
    expect(
      dockerContainerActionCommand('abc123', DockerContainerAction.remove),
      "docker rm -f 'abc123'",
    );
  });

  test('compose actions prefer the provided compose command and project name', () {
    expect(
      dockerComposeActionCommand(
        'docker compose',
        '/opt/app/compose.yaml',
        DockerComposeAction.start,
        projectName: 'orbita',
      ),
      "docker compose -p 'orbita' -f '/opt/app/compose.yaml' up -d",
    );
    expect(
      dockerComposeActionCommand(
        'docker-compose',
        '/opt/app/compose.yaml',
        DockerComposeAction.down,
      ),
      "docker-compose -f '/opt/app/compose.yaml' down",
    );
  });

  test('logs and exec commands quote container and shell names', () {
    expect(
      dockerLogsCommand('web app'),
      "docker logs --tail 200 -f 'web app'",
    );
    expect(
      dockerExecCommand('web app', 'bash'),
      "docker exec -it 'web app' 'bash'",
    );
  });
}
