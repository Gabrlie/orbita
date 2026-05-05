part of 'server_metric_sections.dart';

class _ActionGrid extends StatelessWidget {
  final List<_ActionSpec> actions;

  const _ActionGrid({required this.actions});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final action in actions)
            Tooltip(
              message: action.label,
              child: IconButton.filledTonal(
                onPressed: action.onTap,
                icon: Icon(action.icon),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionSpec {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionSpec({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 22, 4, 8),
      child: Row(
        children: [
          const Icon(Ionicons.chevron_down_outline, size: 16),
          const SizedBox(width: 6),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      surfaceTintColor: Colors.transparent,
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }
}

class _TinyMetric extends StatelessWidget {
  final String label;
  final String value;

  const _TinyMetric(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall,
        ),
      ],
    );
  }
}

class _ValueChip extends StatelessWidget {
  final String label;
  final String value;

  const _ValueChip(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Text('$label $value'),
      visualDensity: VisualDensity.compact,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      side: BorderSide.none,
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double percent;

  const _ProgressRow({required this.label, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          SizedBox(width: 52, child: Text(label)),
          Expanded(child: LinearProgressIndicator(value: percent.clamp(0, 1))),
          const SizedBox(width: 8),
          Text('${(percent * 100).round()}%'),
        ],
      ),
    );
  }
}

class _StackBar extends StatelessWidget {
  final List<_StackValue> values;
  final int total;

  const _StackBar({required this.values, required this.total});

  @override
  Widget build(BuildContext context) {
    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.tertiary,
      Theme.of(context).colorScheme.surfaceContainerHighest,
    ];
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              flex: total <= 0
                  ? 1
                  : (values[i].value * 1000 ~/ total).clamp(1, 1000),
              child: Container(height: 12, color: colors[i % colors.length]),
            ),
        ],
      ),
    );
  }
}

class _StackValue {
  final int value;

  const _StackValue(this.value);
}

class _Badge extends StatelessWidget {
  final String label;

  const _Badge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _InterfaceCard extends StatelessWidget {
  final NetworkInterfaceStatus iface;

  const _InterfaceCard({required this.iface});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                iface.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Ionicons.arrow_up_outline, size: 14),
                  const SizedBox(width: 4),
                  Text(formatRate(iface.upRate)),
                ],
              ),
              Row(
                children: [
                  const Icon(Ionicons.arrow_down_outline, size: 14),
                  const SizedBox(width: 4),
                  Text(formatRate(iface.downRate)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
