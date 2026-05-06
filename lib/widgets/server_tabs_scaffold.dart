import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';

class ServerTabItem {
  final String title;
  final bool isNew;

  const ServerTabItem({required this.title, this.isNew = false});
}

class ServerTabsScaffold extends StatefulWidget {
  final List<ServerTabItem> tabs;
  final int selectedIndex;
  final Widget body;
  final ValueChanged<int> onSelectTab;
  final ValueChanged<int> onCloseTab;
  final VoidCallback onAddTab;
  final List<Widget> actions;
  final bool hideOnScroll;

  const ServerTabsScaffold({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.body,
    required this.onSelectTab,
    required this.onCloseTab,
    required this.onAddTab,
    this.actions = const [],
    this.hideOnScroll = false,
  });

  @override
  State<ServerTabsScaffold> createState() => _ServerTabsScaffoldState();
}

class _ServerTabsScaffoldState extends State<ServerTabsScaffold> {
  var _tabsVisible = true;

  @override
  void didUpdateWidget(covariant ServerTabsScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldTab = oldWidget.selectedIndex < oldWidget.tabs.length
        ? oldWidget.tabs[oldWidget.selectedIndex]
        : null;
    final currentTab = widget.selectedIndex < widget.tabs.length
        ? widget.tabs[widget.selectedIndex]
        : null;
    final activeTabChanged =
        oldWidget.selectedIndex != widget.selectedIndex ||
        oldTab?.title != currentTab?.title ||
        oldTab?.isNew != currentTab?.isNew ||
        oldWidget.hideOnScroll != widget.hideOnScroll;
    if (activeTabChanged) {
      _tabsVisible = true;
    }
  }

  bool _handleScroll(ScrollNotification notification) {
    if (!widget.hideOnScroll || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    if (notification is UserScrollNotification) {
      if (notification.metrics.maxScrollExtent <= 0) {
        if (!_tabsVisible) setState(() => _tabsVisible = true);
        return false;
      }
      if (notification.direction == ScrollDirection.reverse && _tabsVisible) {
        setState(() => _tabsVisible = false);
      }
      if (notification.direction == ScrollDirection.forward && !_tabsVisible) {
        setState(() => _tabsVisible = true);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final tabsVisible = !widget.hideOnScroll || _tabsVisible;
    final height = tabsVisible ? 52.0 : 0.0;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              height: height,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(),
              child: Material(
                color: colorScheme.surface,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: colorScheme.outlineVariant),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.fromLTRB(8, 7, 8, 0),
                            itemBuilder: (context, index) => _ServerTab(
                              item: widget.tabs[index],
                              selected: index == widget.selectedIndex,
                              showClose:
                                  !(widget.tabs.length == 1 &&
                                      widget.tabs[index].isNew),
                              onTap: () => widget.onSelectTab(index),
                              onClose: () => widget.onCloseTab(index),
                            ),
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 4),
                            itemCount: widget.tabs.length,
                          ),
                        ),
                      ),
                      ...widget.actions,
                      IconButton(
                        tooltip: l10n.openNewTab,
                        icon: const Icon(Ionicons.add),
                        onPressed: widget.onAddTab,
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: _handleScroll,
                child: widget.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServerTab extends StatelessWidget {
  final ServerTabItem item;
  final bool selected;
  final bool showClose;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _ServerTab({
    required this.item,
    required this.selected,
    required this.showClose,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foreground = selected
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;
    final selectedBackground = Color.alphaBlend(
      colorScheme.primary.withAlpha(
        theme.brightness == Brightness.dark ? 54 : 30,
      ),
      colorScheme.surfaceContainerHighest,
    );

    return Container(
      constraints: const BoxConstraints(maxWidth: 168),
      child: Material(
        color: selected ? selectedBackground : colorScheme.surface,
        elevation: selected ? 1 : 0,
        shadowColor: colorScheme.shadow.withAlpha(24),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: showClose ? 4 : 12,
              top: 8,
              bottom: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.isNew ? Ionicons.add_circle_outline : Ionicons.server,
                  size: 16,
                  color: selected ? colorScheme.primary : foreground,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (showClose)
                  IconButton(
                    tooltip: AppLocalizations.of(context)!.closeTab,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 28,
                      height: 28,
                    ),
                    icon: Icon(Ionicons.close, size: 16, color: foreground),
                    onPressed: onClose,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
