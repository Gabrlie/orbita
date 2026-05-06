part of 'server_metric_sections.dart';

class _ActionGrid extends StatelessWidget {
  final List<_ActionSpec> actions;

  const _ActionGrid({required this.actions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Panel(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            SizedBox(
              height: 42,
              child: ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                leading: _IconBadge(icon: actions[i].icon),
                minLeadingWidth: 0,
                horizontalTitleGap: 10,
                title: Text(
                  actions[i].label,
                  style: theme.textTheme.labelLarge,
                ),
                onTap: actions[i].onTap,
              ),
            ),
            if (i != actions.length - 1) const Divider(height: 1),
          ],
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

class _CollapsibleMetricSection extends StatelessWidget {
  final String title;
  final Widget icon;
  final bool collapsed;
  final VoidCallback onTap;
  final Widget child;

  const _CollapsibleMetricSection({
    required this.title,
    required this.icon,
    required this.collapsed,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2, 8, 2, 10),
              child: Row(
                children: [
                  IconTheme(
                    data: IconThemeData(
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                    child: icon,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    collapsed
                        ? Ionicons.chevron_down_outline
                        : Ionicons.chevron_up_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: collapsed
                ? const SizedBox(width: double.infinity)
                : Padding(padding: const EdgeInsets.only(top: 2), child: child),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;
  final bool surface;
  final EdgeInsetsGeometry padding;

  const _Panel({
    required this.child,
    this.surface = false,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: surface ? colorScheme.surface : tonalItemColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(150)),
      ),
      surfaceTintColor: Colors.transparent,
      child: Padding(padding: padding, child: child),
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
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ValueChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final double? width;

  const _ValueChip(this.label, this.value, {this.color, this.width = 118.0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 5, right: 6),
            decoration: BoxDecoration(
              color: color ?? theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
    );
    if (width == null) return child;
    return SizedBox(width: width, child: child);
  }
}

class _ValueGrid extends StatelessWidget {
  final List<Widget> children;

  const _ValueGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row < children.length; row += 2) ...[
          Row(
            children: [
              Expanded(child: children[row]),
              const SizedBox(width: 12),
              Expanded(
                child: row + 1 < children.length
                    ? children[row + 1]
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          if (row + 2 < children.length) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double percent;

  const _ProgressRow({required this.label, required this.percent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: Text(label, style: theme.textTheme.labelSmall),
          ),
          Expanded(child: LinearProgressIndicator(value: percent.clamp(0, 1))),
          const SizedBox(width: 8),
          Text(
            '${(percent * 100).toStringAsFixed(1)}%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
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
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;

  const _IconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha(150),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: colorScheme.primary),
    );
  }
}

class _InterfaceCard extends StatelessWidget {
  final NetworkInterfaceStatus iface;

  const _InterfaceCard({required this.iface});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 150,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withAlpha(120),
          border: Border.all(color: theme.colorScheme.outlineVariant),
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
              const SizedBox(height: 4),
              Text(
                '${formatBytes(iface.txTotal)} / ${formatBytes(iface.rxTotal)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
