/// Log entry for SSH operations on a specific server.
class SshLogEntry {
  final DateTime timestamp;
  final SshLogLevel level;
  final String message;
  final String? detail;

  const SshLogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.detail,
  });

  factory SshLogEntry.info(String message) => SshLogEntry(
        timestamp: DateTime.now(),
        level: SshLogLevel.info,
        message: message,
      );

  factory SshLogEntry.error(String message, [String? detail]) => SshLogEntry(
        timestamp: DateTime.now(),
        level: SshLogLevel.error,
        message: message,
        detail: detail,
      );

  factory SshLogEntry.command(String cmd, String output) => SshLogEntry(
        timestamp: DateTime.now(),
        level: SshLogLevel.command,
        message: cmd,
        detail: output,
      );
}

enum SshLogLevel { info, error, command }
