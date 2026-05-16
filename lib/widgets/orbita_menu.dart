import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:orbita/widgets/orbita_sheet.dart';

class OrbitaMenuAction<T> {
  final T value;
  final IconData icon;
  final String label;
  final bool destructive;
  final bool enabled;
  final bool dividerBefore;

  const OrbitaMenuAction({
    required this.value,
    required this.icon,
    required this.label,
    this.destructive = false,
    this.enabled = true,
    this.dividerBefore = false,
  });
}

class OrbitaPopoverMenu<T> extends StatelessWidget {
  final List<OrbitaMenuAction<T>> actions;
  final ValueChanged<T> onSelected;
  final Widget child;
  final AlignmentGeometry menuAnchor;
  final AlignmentGeometry childAnchor;
  final bool tapToOpen;

  const OrbitaPopoverMenu({
    super.key,
    required this.actions,
    required this.onSelected,
    required this.child,
    this.menuAnchor = Alignment.topRight,
    this.childAnchor = Alignment.bottomRight,
    this.tapToOpen = true,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return child;

    return FPopoverMenu(
      maxHeight: 360,
      menuAnchor: menuAnchor,
      childAnchor: childAnchor,
      menuBuilder: (context, controller, _) => _buildPopoverMenuGroups(
        context,
        controller,
        actions,
        onSelected,
      ),
      builder: (context, controller, child) {
        if (!tapToOpen) return child!;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.toggle,
          child: child,
        );
      },
      child: child,
    );
  }
}

class OrbitaLongPressMenu<T> extends StatelessWidget {
  final List<OrbitaMenuAction<T>> actions;
  final ValueChanged<T> onSelected;
  final Widget child;

  const OrbitaLongPressMenu({
    super.key,
    required this.actions,
    required this.onSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return child;

    return FPopoverMenu(
      maxHeight: 360,
      menuAnchor: Alignment.topLeft,
      childAnchor: Alignment.topRight,
      menuBuilder: (context, controller, _) => _buildPopoverMenuGroups(
        context,
        controller,
        actions,
        onSelected,
      ),
      builder: (context, controller, child) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: controller.toggle,
        child: child,
      ),
      child: child,
    );
  }
}

Future<T?> showOrbitaActionMenu<T>(
  BuildContext context, {
  required List<OrbitaMenuAction<T>> actions,
  String? title,
}) {
  return showOrbitaBottomSheet<T>(
    context: context,
    mainAxisMaxRatio: null,
    builder: (context) => _OrbitaActionMenu<T>(title: title, actions: actions),
  );
}

class OrbitaIconMenuButton<T> extends StatelessWidget {
  final IconData icon;
  final String? title;
  final String? tooltip;
  final bool enabled;
  final List<OrbitaMenuAction<T>> actions;
  final ValueChanged<T> onSelected;

  const OrbitaIconMenuButton({
    super.key,
    required this.actions,
    required this.onSelected,
    this.title,
    this.tooltip,
    this.enabled = true,
    this.icon = Icons.more_horiz,
  });

  @override
  Widget build(BuildContext context) {
    final button = FPopoverMenu(
      maxHeight: 360,
      menuAnchor: Alignment.topRight,
      childAnchor: Alignment.bottomRight,
      menuBuilder: (context, controller, _) => _buildPopoverMenuGroups(
        context,
        controller,
        actions,
        onSelected,
      ),
      builder: (context, controller, child) => FButton.icon(
        variant: FButtonVariant.ghost,
        onPress: enabled ? controller.toggle : null,
        child: Icon(icon),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip, child: button);
  }
}

List<FItemGroup> _buildPopoverMenuGroups<T>(
  BuildContext context,
  FPopoverController controller,
  List<OrbitaMenuAction<T>> actions,
  ValueChanged<T> onSelected,
) {
  final theme = Theme.of(context);
  final groups = <List<OrbitaMenuAction<T>>>[<OrbitaMenuAction<T>>[]];

  for (final action in actions) {
    if (action.dividerBefore && groups.last.isNotEmpty) {
      groups.add(<OrbitaMenuAction<T>>[]);
    }
    groups.last.add(action);
  }

  return [
    for (final group in groups.where((group) => group.isNotEmpty))
      FItemGroup(
        children: [
          for (final action in group)
            FItem(
              prefix: Icon(
                action.icon,
                color: action.destructive ? theme.colorScheme.error : null,
              ),
              title: Text(
                action.label,
                style: action.destructive
                    ? TextStyle(color: theme.colorScheme.error)
                    : null,
              ),
              enabled: action.enabled,
              onPress: action.enabled
                  ? () {
                      controller.hide();
                      onSelected(action.value);
                    }
                  : null,
            ),
        ],
      ),
  ];
}

class _OrbitaActionMenu<T> extends StatelessWidget {
  final String? title;
  final List<OrbitaMenuAction<T>> actions;

  const _OrbitaActionMenu({required this.actions, this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Text(
              title!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        for (final action in actions) ...[
          if (action.dividerBefore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: FDivider(),
            ),
          FItem(
            prefix: Icon(
              action.icon,
              color: action.destructive ? theme.colorScheme.error : null,
            ),
            title: Text(
              action.label,
              style: action.destructive
                  ? TextStyle(color: theme.colorScheme.error)
                  : null,
            ),
            enabled: action.enabled,
            onPress: action.enabled
                ? () => Navigator.of(context).pop(action.value)
                : null,
          ),
        ],
      ],
    );
  }
}
