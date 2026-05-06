import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:orbita/widgets/common.dart';

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
            SectionHeader(
              title: l10n.metricPollingSection,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            ),
            _SettingsPanel(
              children: [
                _SecondsTile(
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
            SectionHeader(
              title: l10n.metricConnectionSection,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            ),
            _SettingsPanel(
              children: [
                _SecondsTile(
                  icon: Ionicons.flash_outline,
                  title: l10n.metricSshConnectTimeout,
                  value: settings.sshConnectTimeoutSeconds,
                  min: 3,
                  max: 60,
                  onChanged: (value) => notifier.set(
                    settings.copyWith(sshConnectTimeoutSeconds: value),
                  ),
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _SecondsTile(
                  icon: Ionicons.pulse_outline,
                  title: l10n.metricKeepAliveInterval,
                  value: settings.keepAliveIntervalSeconds,
                  min: 5,
                  max: 120,
                  onChanged: (value) => notifier.set(
                    settings.copyWith(keepAliveIntervalSeconds: value),
                  ),
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                SwitchListTile(
                  secondary: const Icon(Ionicons.repeat_outline, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  title: Text(l10n.metricAutoReconnect),
                  subtitle: Text(l10n.metricAutoReconnectDesc),
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

class _SettingsPanel extends StatelessWidget {
  final List<Widget> children;

  const _SettingsPanel({required this.children});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tonalItemColor(context),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _SecondsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _SecondsTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, size: 20, color: theme.colorScheme.primary),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: '-',
            icon: const Icon(Ionicons.remove_outline, size: 18),
            onPressed: value <= min ? null : () => onChanged(value - 1),
          ),
          SizedBox(
            width: 64,
            child: Text(
              l10n.metricSecondsValue(value),
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: '+',
            icon: const Icon(Ionicons.add_outline, size: 18),
            onPressed: value >= max ? null : () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}
