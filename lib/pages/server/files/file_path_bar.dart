import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/models/remote_file_entry.dart';

class FilePathBar extends StatelessWidget {
  final String path;
  final ValueChanged<String>? onTapPath;
  final Color? backgroundColor;

  const FilePathBar({
    super.key,
    required this.path,
    this.onTapPath,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breadcrumbs = remotePathBreadcrumbs(path);
    final current = breadcrumbs.last;

    return Material(
      color: backgroundColor ?? theme.colorScheme.surface,
      child: SizedBox(
        height: 48,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FPopoverMenu(
              maxHeight: 360,
              menuAnchor: Alignment.topLeft,
              childAnchor: Alignment.bottomLeft,
              menuBuilder: (context, controller, _) => [
                FItemGroup(
                  children: [
                    for (final (index, breadcrumb) in breadcrumbs.indexed)
                      FItem(
                        prefix: Icon(
                          index == breadcrumbs.length - 1
                              ? Ionicons.checkmark_outline
                              : Ionicons.folder_open_outline,
                        ),
                        title: Text(breadcrumb.label),
                        subtitle: Text(breadcrumb.path),
                        selected: index == breadcrumbs.length - 1,
                        onPress: () {
                          controller.hide();
                          if (index != breadcrumbs.length - 1) {
                            onTapPath?.call(breadcrumb.path);
                          }
                        },
                      ),
                  ],
                ),
              ],
              builder: (context, controller, _) => FButton(
                variant: FButtonVariant.ghost,
                onPress: controller.toggle,
                prefix: const Icon(Ionicons.folder_open_outline),
                suffix: const Icon(Ionicons.chevron_down_outline, size: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: Text(
                    current.path,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
