import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/app_update.dart';
import 'package:orbita/providers/update_provider.dart';
import 'package:orbita/widgets/common.dart';

class AboutUpdatePanel extends ConsumerWidget {
  const AboutUpdatePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(appUpdateProvider);
    return state.when(
      loading: () => _Panel(
        children: [
          ListTile(
            leading: const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            title: Text(l10n.updateChecking),
          ),
        ],
      ),
      error: (error, _) => _Panel(
        children: [
          ListTile(
            leading: const Icon(Ionicons.warning_outline),
            title: Text(l10n.updateFailed('$error')),
          ),
        ],
      ),
      data: (update) => _Panel(
        children: [
          SwitchListTile(
            secondary: const Icon(Ionicons.notifications_outline),
            title: Text(l10n.updateAutoCheck),
            value: update.autoCheckEnabled,
            onChanged: (enabled) {
              ref.read(appUpdateProvider.notifier).setAutoCheckEnabled(enabled);
            },
          ),
          ListTile(
            leading: update.checking
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Ionicons.cloud_download_outline),
            title: Text(_statusText(l10n, update)),
            subtitle: _subtitle(l10n, update),
            trailing: TextButton(
              onPressed: update.checking
                  ? null
                  : () => ref.read(appUpdateProvider.notifier).check(),
              child: Text(l10n.updateCheck),
            ),
          ),
          if (update.info?.hasUpdate == true)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      ref.read(appUpdateProvider.notifier).skipCurrentVersion();
                    },
                    child: Text(l10n.updateSkip),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: update.info?.matchedAsset == null
                          ? null
                          : () {
                              ref
                                  .read(appUpdateProvider.notifier)
                                  .downloadMatchedAsset();
                            },
                      child: Text(
                        update.info?.matchedAsset == null
                            ? l10n.updateNoAsset
                            : l10n.updateDownload,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget? _subtitle(AppLocalizations l10n, UpdateState update) {
    final progress = update.download;
    if (progress.status == UpdateDownloadStatus.downloading) {
      return Text(l10n.updateDownloadProgress(progress.progress));
    }
    if (progress.status == UpdateDownloadStatus.installing) {
      return Text(l10n.updateInstalling);
    }
    if (progress.status == UpdateDownloadStatus.completed) {
      return Text(l10n.updateCompleted);
    }
    if (progress.status == UpdateDownloadStatus.error) {
      return Text(l10n.updateFailed(progress.error ?? 'unknown'));
    }
    final info = update.info;
    if (info?.matchedAsset != null) {
      return Text(l10n.updateAsset(info!.matchedAsset!.architecture));
    }
    if (info?.hasUpdate == true) return Text(l10n.updateNoAsset);
    return null;
  }

  String _statusText(AppLocalizations l10n, UpdateState update) {
    if (update.checking) return l10n.updateChecking;
    if (update.error != null) return l10n.updateFailed(update.error!);
    final info = update.info;
    if (info == null) return l10n.updateCheckNow;
    if (info.hasUpdate) return l10n.updateAvailable(info.remoteVersion);
    if (info.isSkipped) return l10n.updateSkipped(info.remoteVersion);
    return l10n.updateLatest;
  }
}

class _Panel extends StatelessWidget {
  final List<Widget> children;

  const _Panel({required this.children});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tonalItemColor(context),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 20, endIndent: 20),
            children[i],
          ],
        ],
      ),
    );
  }
}
