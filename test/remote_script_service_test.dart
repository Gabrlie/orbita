import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/services/linux_mirror_script_builder.dart';
import 'package:orbita/services/orbita_script_syntax.dart';
import 'package:orbita/services/remote_script_service.dart';

void main() {
  test('docker install command supports common package managers', () {
    final command = buildInstallDockerCommand();

    expect(command, contains('apt-get install -y docker.io'));
    expect(command, contains('dnf install -y docker docker-compose-plugin'));
    expect(command, contains('yum install -y docker docker-compose-plugin'));
    expect(command, contains('pacman -Sy --noconfirm docker docker-compose'));
    expect(command, contains('apk add docker docker-cli-compose'));
    expect(command, contains('zypper --non-interactive install docker'));
    expect(command, contains('systemctl enable --now docker'));
  });

  test('linux mirror command supports common distributions and versions', () {
    final command = buildLinuxMirrorCommand(
      selectTitle: '选择镜像源',
      tunaLabel: '清华大学 TUNA',
      ustcLabel: '中国科学技术大学 USTC',
      aliyunLabel: '阿里云',
      tencentLabel: '腾讯云',
      huaweiLabel: '华为云',
    );

    expect(command, contains('orbita:select name=MIRROR'));
    expect(command, contains('orbita:option name=MIRROR'));
    expect(command, contains('MIRROR={{MIRROR}}'));
    expect(command, contains('ubuntu)'));
    expect(command, contains('debian)'));
    expect(command, contains('centos)'));
    expect(command, contains('rocky|almalinux|fedora|openEuler|openeuler)'));
    expect(command, contains('alpine)'));
    expect(command, contains('arch)'));
    expect(command, contains('opensuse-*|sles)'));
    expect(command, contains('non-free-firmware'));
    expect(command, contains('centos-vault'));
    expect(command, contains('centos-stream'));
  });

  test('orbita script syntax parses select options and renders values', () {
    final template = parseOrbitaScript('''
# orbita:select name=MIRROR title="选择镜像源"
# orbita:option name=MIRROR label="清华大学 TUNA" value="https://mirrors.tuna.tsinghua.edu.cn"
MIRROR={{MIRROR}}
RAW={{MIRROR|raw}}
''');

    expect(template.selects, hasLength(1));
    expect(template.selects.single.title, '选择镜像源');
    expect(template.selects.single.options.single.label, '清华大学 TUNA');

    final command = renderOrbitaScript(template, {
      'MIRROR': 'https://example.com/repo',
    });

    expect(command, isNot(contains('orbita:select')));
    expect(command, contains("MIRROR='https://example.com/repo'"));
    expect(command, contains('RAW=https://example.com/repo'));
  });
}
