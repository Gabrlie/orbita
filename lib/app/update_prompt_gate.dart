import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/models/app_update.dart';
import 'package:orbita/providers/update_provider.dart';

class UpdatePromptGate extends ConsumerStatefulWidget {
  final Widget child;

  const UpdatePromptGate({super.key, required this.child});

  @override
  ConsumerState<UpdatePromptGate> createState() => _UpdatePromptGateState();
}

class _UpdatePromptGateState extends ConsumerState<UpdatePromptGate> {
  String? _promptedVersion;
  bool _dialogOpen = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<UpdateState>>(appUpdateProvider, (_, next) {
      final info = next.value?.info;
      if (info == null || !info.hasUpdate) return;
      _showPromptAfterFrame(info);
    });
    ref.watch(appUpdateProvider);
    return widget.child;
  }

  void _showPromptAfterFrame(UpdateInfo info) {
    if (_dialogOpen || _promptedVersion == info.remoteVersion) return;
    _promptedVersion = info.remoteVersion;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showPrompt(info);
    });
  }

  Future<void> _showPrompt(UpdateInfo info) async {
    _dialogOpen = true;
    final action = await showDialog<_UpdatePromptAction>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _UpdatePromptDialog(info: info),
    );
    _dialogOpen = false;
    if (!mounted || action == null) return;
    final notifier = ref.read(appUpdateProvider.notifier);
    switch (action) {
      case _UpdatePromptAction.download:
        await notifier.downloadMatchedAsset();
      case _UpdatePromptAction.skip:
        await notifier.skipCurrentVersion();
      case _UpdatePromptAction.later:
        break;
    }
  }
}

enum _UpdatePromptAction { download, skip, later }

class _UpdatePromptDialog extends StatelessWidget {
  final UpdateInfo info;

  const _UpdatePromptDialog({required this.info});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notes = info.releaseNotes.trim().isEmpty
        ? l10n.updateNoReleaseNotes
        : info.releaseNotes.trim();
    return AlertDialog(
      title: Text(l10n.updateAvailable(info.remoteVersion)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(child: SelectableText(notes)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_UpdatePromptAction.skip),
          child: Text(l10n.updateSkip),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_UpdatePromptAction.later),
          child: Text(l10n.updateLater),
        ),
        FilledButton(
          onPressed: info.matchedAsset == null
              ? null
              : () => Navigator.of(context).pop(_UpdatePromptAction.download),
          child: Text(
            info.matchedAsset == null
                ? l10n.updateNoAsset
                : l10n.updateDownload,
          ),
        ),
      ],
    );
  }
}
