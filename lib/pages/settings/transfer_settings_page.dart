import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:orbita/widgets/common.dart';

class TransferSettingsPage extends ConsumerWidget {
  const TransferSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(transferSettingsProvider);
    final notifier = ref.read(transferSettingsProvider.notifier);

    return Scaffold(
      appBar: compactPageAppBar(
        context,
        title: l10n.transferSettingsTitle,
        fallbackLocation: '/settings',
      ),
      body: TonalListBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            SectionHeader(
              title: l10n.transferToolSection,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            ),
            _SettingsPanel(
              children: [
                _ToolTile(
                  value: TransferToolPreference.auto,
                  groupValue: settings.toolPreference,
                  title: l10n.transferToolAuto,
                  subtitle: l10n.transferToolAutoDesc,
                  onChanged: (value) =>
                      notifier.set(settings.copyWith(toolPreference: value)),
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _ToolTile(
                  value: TransferToolPreference.rsync,
                  groupValue: settings.toolPreference,
                  title: l10n.transferToolRsync,
                  subtitle: l10n.transferToolRsyncDesc,
                  onChanged: (value) =>
                      notifier.set(settings.copyWith(toolPreference: value)),
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _ToolTile(
                  value: TransferToolPreference.localRelay,
                  groupValue: settings.toolPreference,
                  title: l10n.transferToolLocalRelay,
                  subtitle: l10n.transferToolLocalRelayDesc,
                  onChanged: (value) =>
                      notifier.set(settings.copyWith(toolPreference: value)),
                ),
              ],
            ),
            SectionHeader(
              title: l10n.transferDuplicateSection,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            ),
            _SettingsPanel(
              children: [
                _DuplicateTile(
                  value: TransferDuplicateAction.ask,
                  groupValue: settings.duplicateAction,
                  title: l10n.transferDuplicateAsk,
                  onChanged: (value) =>
                      notifier.set(settings.copyWith(duplicateAction: value)),
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _DuplicateTile(
                  value: TransferDuplicateAction.overwrite,
                  groupValue: settings.duplicateAction,
                  title: l10n.fileOverwrite,
                  onChanged: (value) =>
                      notifier.set(settings.copyWith(duplicateAction: value)),
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _DuplicateTile(
                  value: TransferDuplicateAction.keepBoth,
                  groupValue: settings.duplicateAction,
                  title: l10n.fileKeepBoth,
                  onChanged: (value) =>
                      notifier.set(settings.copyWith(duplicateAction: value)),
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _DuplicateTile(
                  value: TransferDuplicateAction.cancel,
                  groupValue: settings.duplicateAction,
                  title: l10n.commonCancel,
                  onChanged: (value) =>
                      notifier.set(settings.copyWith(duplicateAction: value)),
                ),
              ],
            ),
            SectionHeader(
              title: l10n.transferDownloadSection,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            ),
            _SettingsPanel(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  leading: const Icon(Ionicons.folder_open_outline, size: 20),
                  title: Text(l10n.transferDownloadDirectory),
                  subtitle: Text(
                    settings.downloadDirectory.isEmpty
                        ? l10n.transferDownloadDefaultDirectory
                        : settings.downloadDirectory,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        tooltip: l10n.transferDownloadChooseDirectory,
                        icon: const Icon(Ionicons.folder_outline),
                        onPressed: () =>
                            _chooseDirectory(context, settings, notifier),
                      ),
                      IconButton(
                        tooltip: l10n.transferDownloadClearDirectory,
                        icon: const Icon(Ionicons.close_outline),
                        onPressed: settings.downloadDirectory.isEmpty
                            ? null
                            : () => notifier.set(
                                settings.copyWith(downloadDirectory: ''),
                              ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                SwitchListTile(
                  secondary: const Icon(Ionicons.download_outline, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  title: Text(l10n.transferAskDownloadLocation),
                  subtitle: Text(l10n.transferAskDownloadLocationDesc),
                  value: settings.askDownloadLocation,
                  onChanged: (value) => notifier.set(
                    settings.copyWith(askDownloadLocation: value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseDirectory(
    BuildContext context,
    TransferSettings settings,
    TransferSettingsNotifier notifier,
  ) async {
    final selected = await FilePicker.getDirectoryPath(
      dialogTitle: AppLocalizations.of(
        context,
      )!.transferDownloadChooseDirectory,
      initialDirectory: settings.downloadDirectory.isEmpty
          ? null
          : settings.downloadDirectory,
    );
    if (selected == null || selected.isEmpty) return;
    await notifier.set(settings.copyWith(downloadDirectory: selected));
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

class _DuplicateTile extends StatelessWidget {
  final TransferDuplicateAction value;
  final TransferDuplicateAction groupValue;
  final String title;
  final ValueChanged<TransferDuplicateAction> onChanged;

  const _DuplicateTile({
    required this.value,
    required this.groupValue,
    required this.title,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: const Icon(Ionicons.copy_outline, size: 20),
      title: Text(title),
      selected: selected,
      trailing: selected ? const Icon(Ionicons.checkmark_outline) : null,
      onTap: () => onChanged(value),
    );
  }
}

class _ToolTile extends StatelessWidget {
  final TransferToolPreference value;
  final TransferToolPreference groupValue;
  final String title;
  final String subtitle;
  final ValueChanged<TransferToolPreference> onChanged;

  const _ToolTile({
    required this.value,
    required this.groupValue,
    required this.title,
    required this.subtitle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: const Icon(Ionicons.swap_horizontal_outline, size: 20),
      title: Text(title),
      subtitle: Text(subtitle),
      selected: selected,
      trailing: selected ? const Icon(Ionicons.checkmark_outline) : null,
      onTap: () => onChanged(value),
    );
  }
}
