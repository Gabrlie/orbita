part of 'download_center_page.dart';

class _TransferSummary extends StatelessWidget {
  final List<FileTransferTask> tasks;

  const _TransferSummary({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final active = tasks.where((task) => task.isActive).length;
    final uploads = tasks
        .where((task) => task.direction == FileTransferDirection.upload)
        .length;
    final downloads = tasks
        .where((task) => task.direction == FileTransferDirection.download)
        .length;
    final serverTransfers = tasks
        .where((task) => task.direction == FileTransferDirection.server)
        .length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _Metric(label: l10n.fileActiveTransfers, value: '$active'),
          ),
          Expanded(
            child: _Metric(label: l10n.fileUpload, value: '$uploads'),
          ),
          Expanded(
            child: _Metric(label: l10n.fileDownload, value: '$downloads'),
          ),
          Expanded(
            child: _Metric(
              label: l10n.fileTransferCenter,
              value: '$serverTransfers',
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
