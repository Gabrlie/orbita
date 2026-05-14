import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceNameService {
  final DeviceInfoPlugin _deviceInfo;

  DeviceNameService({DeviceInfoPlugin? deviceInfo})
    : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  Future<String> backupDeviceName() async {
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        return _firstNonEmpty([info.name, info.model, info.device]);
      }
      if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        return _firstNonEmpty([info.name, info.modelName, info.model]);
      }
      if (Platform.isMacOS) {
        final info = await _deviceInfo.macOsInfo;
        return _firstNonEmpty([info.computerName, info.hostName, info.model]);
      }
      if (Platform.isWindows) {
        final info = await _deviceInfo.windowsInfo;
        return _firstNonEmpty([info.computerName, info.userName]);
      }
      if (Platform.isLinux) {
        final info = await _deviceInfo.linuxInfo;
        return _firstNonEmpty([info.name, info.prettyName, info.id]);
      }
    } catch (_) {
      // Fall through to the local hostname when platform plugins are unavailable.
    }
    return _firstNonEmpty([Platform.localHostname, 'device']);
  }

  String _firstNonEmpty(Iterable<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    }
    return 'device';
  }
}
