/// Format bytes to human-readable string.
String formatBytes(int bytes, {int decimals = 1}) {
  if (bytes < 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  int i = 0;
  double value = bytes.toDouble();
  while (value >= 1024 && i < units.length - 1) {
    value /= 1024;
    i++;
  }
  if (i == 0) return '${value.toInt()} B';
  return '${value.toStringAsFixed(decimals)} ${units[i]}';
}

/// Format bytes/s rate to human-readable string.
String formatRate(double bytesPerSec) {
  if (bytesPerSec < 0) return '0 B/s';
  const units = ['B/s', 'KB/s', 'MB/s', 'GB/s'];
  int i = 0;
  double value = bytesPerSec;
  while (value >= 1024 && i < units.length - 1) {
    value /= 1024;
    i++;
  }
  if (i == 0) return '${value.toInt()} B/s';
  return '${value.toStringAsFixed(1)} ${units[i]}';
}

/// Format seconds to human-readable uptime string.
String formatUptime(int totalSeconds) {
  if (totalSeconds <= 0) return '0m';
  final days = totalSeconds ~/ 86400;
  final hours = (totalSeconds % 86400) ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  if (days > 0) return '${days}d ${hours}h';
  if (hours > 0) return '${hours}h ${minutes}m';
  return '${minutes}m';
}
