import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/settings_tiles.dart';

class MetricSettingsPage extends ConsumerWidget {
  const MetricSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(metricSettingsProvider);
    final notifier = ref.read(metricSettingsProvider.notifier);

    return Scaffold(
      appBar: compactPageAppBar(
        context,
        title: l10n.metricSettingsTitle,
        fallbackLocation: '/settings',
      ),
      body: TonalListBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            OrbitaSettingsTileGroup(
              title: l10n.metricPollingSection,
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              children: [
                _secondsTile(
                  context,
                  icon: Ionicons.timer_outline,
                  title: l10n.metricRefreshInterval,
                  value: settings.refreshIntervalSeconds,
                  min: 3,
                  max: 120,
                  onChanged: (value) => notifier.set(
                    settings.copyWith(refreshIntervalSeconds: value),
                  ),
                ),
              ],
            ),
            OrbitaSettingsTileGroup(
              title: l10n.metricConnectionSection,
              children: [
                _secondsTile(
                  context,
                  icon: Ionicons.flash_outline,
                  title: l10n.metricSshConnectTimeout,
                  value: settings.sshConnectTimeoutSeconds,
                  min: 5,
                  max: 60,
                  step: 5,
                  onChanged: (value) => notifier.set(
                    settings.copyWith(sshConnectTimeoutSeconds: value),
                  ),
                ),
                _secondsTile(
                  context,
                  icon: Ionicons.pulse_outline,
                  title: l10n.metricKeepAliveInterval,
                  value: settings.keepAliveIntervalSeconds,
                  min: 5,
                  max: 120,
                  onChanged: (value) => notifier.set(
                    settings.copyWith(keepAliveIntervalSeconds: value),
                  ),
                ),
                orbitaSettingsSwitchTile(
                  context,
                  icon: Ionicons.repeat_outline,
                  title: l10n.metricAutoReconnect,
                  subtitle: l10n.metricAutoReconnectDesc,
                  value: settings.autoReconnect,
                  onChanged: (value) => notifier.set(
                    settings.copyWith(autoReconnect: value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

FTile _secondsTile(
  BuildContext context, {
  required IconData icon,
  required String title,
  required int value,
  required int min,
  required int max,
  required ValueChanged<int> onChanged,
  int step = 1,
}) {
  final l10n = AppLocalizations.of(context)!;
  final down = _steppedValue(value, min: min, max: max, step: step, add: false);
  final up = _steppedValue(value, min: min, max: max, step: step, add: true);
  return orbitaSettingsTile(
    context,
    icon: icon,
    title: title,
    suffix: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FButton.icon(
          size: FButtonSizeVariant.sm,
          onPress: value <= min ? null : () => onChanged(down),
          child: const Icon(Ionicons.remove_outline),
        ),
        SizedBox(
          width: 64,
          child: Text(
            l10n.metricSecondsValue(value),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        FButton.icon(
          size: FButtonSizeVariant.sm,
          onPress: value >= max ? null : () => onChanged(up),
          child: const Icon(Ionicons.add_outline),
        ),
      ],
    ),
  );
}

int _steppedValue(
  int value, {
  required int min,
  required int max,
  required int step,
  required bool add,
}) {
  if (step <= 1) {
    return (value + (add ? 1 : -1)).clamp(min, max).toInt();
  }

  final next = add
      ? ((value ~/ step) + 1) * step
      : (((value - 1) ~/ step) * step);
  return next.clamp(min, max).toInt();
}
