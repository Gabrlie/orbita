import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/settings_tiles.dart';

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
            OrbitaSettingsTileGroup(
              title: l10n.transferToolSection,
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              children: [
                _toolTile(
                  context,
                  value: TransferToolPreference.auto,
                  groupValue: settings.toolPreference,
                  title: l10n.transferToolAuto,
                  subtitle: l10n.transferToolAutoDesc,
                  onChanged: (value) =>
                      notifier.set(settings.copyWith(toolPreference: value)),
                ),
                _toolTile(
                  context,
                  value: TransferToolPreference.rsync,
                  groupValue: settings.toolPreference,
                  title: l10n.transferToolRsync,
                  subtitle: l10n.transferToolRsyncDesc,
                  onChanged: (value) =>
                      notifier.set(settings.copyWith(toolPreference: value)),
                ),
                _toolTile(
                  context,
                  value: TransferToolPreference.localRelay,
                  groupValue: settings.toolPreference,
                  title: l10n.transferToolLocalRelay,
                  subtitle: l10n.transferToolLocalRelayDesc,
                  onChanged: (value) =>
                      notifier.set(settings.copyWith(toolPreference: value)),
                ),
              ],
            ),
            OrbitaSettingsTileGroup(
              title: l10n.transferDuplicateSection,
              children: [
                _duplicateTile(
                  context,
                  value: TransferDuplicateAction.ask,
                  groupValue: settings.duplicateAction,
                  title: l10n.transferDuplicateAsk,
                  onChanged: (value) =>
                      notifier.set(settings.copyWith(duplicateAction: value)),
                ),
                _duplicateTile(
                  context,
                  value: TransferDuplicateAction.overwrite,
                  groupValue: settings.duplicateAction,
                  title: l10n.fileOverwrite,
                  onChanged: (value) =>
                      notifier.set(settings.copyWith(duplicateAction: value)),
                ),
                _duplicateTile(
                  context,
                  value: TransferDuplicateAction.keepBoth,
                  groupValue: settings.duplicateAction,
                  title: l10n.fileKeepBoth,
                  onChanged: (value) =>
                      notifier.set(settings.copyWith(duplicateAction: value)),
                ),
                _duplicateTile(
                  context,
                  value: TransferDuplicateAction.cancel,
                  groupValue: settings.duplicateAction,
                  title: l10n.commonCancel,
                  onChanged: (value) =>
                      notifier.set(settings.copyWith(duplicateAction: value)),
                ),
              ],
            ),
            OrbitaSettingsTileGroup(
              title: l10n.transferDownloadSection,
              children: [
                orbitaSettingsTile(
                  context,
                  icon: Ionicons.folder_open_outline,
                  title: l10n.transferDownloadDirectory,
                  subtitle: settings.downloadDirectory.isEmpty
                      ? l10n.transferDownloadDefaultDirectory
                      : settings.downloadDirectory,
                  suffix: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: l10n.transferDownloadChooseDirectory,
                        child: FButton.icon(
                          size: FButtonSizeVariant.sm,
                          onPress: () =>
                              _chooseDirectory(context, settings, notifier),
                          child: const Icon(Ionicons.folder_outline),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Tooltip(
                        message: l10n.transferDownloadClearDirectory,
                        child: FButton.icon(
                          size: FButtonSizeVariant.sm,
                          onPress: settings.downloadDirectory.isEmpty
                              ? null
                              : () => notifier.set(
                                  settings.copyWith(downloadDirectory: ''),
                                ),
                          child: const Icon(Ionicons.close_outline),
                        ),
                      ),
                    ],
                  ),
                ),
                orbitaSettingsSwitchTile(
                  context,
                  icon: Ionicons.download_outline,
                  title: l10n.transferAskDownloadLocation,
                  subtitle: l10n.transferAskDownloadLocationDesc,
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

FTile _duplicateTile(
  BuildContext context, {
  required TransferDuplicateAction value,
  required TransferDuplicateAction groupValue,
  required String title,
  required ValueChanged<TransferDuplicateAction> onChanged,
}) {
  return orbitaSettingsSelectableTile(
    context,
    icon: Ionicons.copy_outline,
    title: title,
    value: value,
    groupValue: groupValue,
    onChanged: onChanged,
  );
}

FTile _toolTile(
  BuildContext context, {
  required TransferToolPreference value,
  required TransferToolPreference groupValue,
  required String title,
  required String subtitle,
  required ValueChanged<TransferToolPreference> onChanged,
}) {
  return orbitaSettingsSelectableTile(
    context,
    icon: Ionicons.swap_horizontal_outline,
    title: title,
    subtitle: subtitle,
    value: value,
    groupValue: groupValue,
    onChanged: onChanged,
  );
}
