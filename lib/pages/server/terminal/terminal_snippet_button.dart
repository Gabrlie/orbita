import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/providers/command_snippet_provider.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/orbita_forui.dart';

class TerminalSnippetButton extends StatefulWidget {
  final double right;
  final ValueChanged<String> onSelected;

  const TerminalSnippetButton({
    super.key,
    required this.right,
    required this.onSelected,
  });

  @override
  State<TerminalSnippetButton> createState() => _TerminalSnippetButtonState();
}

class _TerminalSnippetButtonState extends State<TerminalSnippetButton> {
  var _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      right: _collapsed ? -2 : widget.right,
      bottom: 16,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _collapsed
            ? () => setState(() => _collapsed = false)
            : () => _showSnippets(context),
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity > 0) setState(() => _collapsed = true);
          if (velocity < 0) setState(() => _collapsed = false);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: _collapsed ? 10 : 54,
          height: 54,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(_collapsed ? 12 : 18),
              right: Radius.circular(_collapsed ? 0 : 18),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withAlpha(48),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: _collapsed
              ? null
              : IconButton(
                  tooltip: AppLocalizations.of(context)!.settingsSnippets,
                  color: theme.colorScheme.onPrimary,
                  icon: const Icon(Ionicons.flash_outline),
                  onPressed: () => _showSnippets(context),
                ),
        ),
      ),
    );
  }

  Future<void> _showSnippets(BuildContext context) async {
    final command = await showOrbitaDialog<String>(
      context: context,
      builder: (context, animation) =>
          _TerminalSnippetDialog(animation: animation),
    );
    if (command != null && mounted) widget.onSelected(command);
  }
}

class _TerminalSnippetDialog extends ConsumerStatefulWidget {
  final Animation<double> animation;

  const _TerminalSnippetDialog({required this.animation});

  @override
  ConsumerState<_TerminalSnippetDialog> createState() =>
      _TerminalSnippetDialogState();
}

class _TerminalSnippetDialogState extends ConsumerState<_TerminalSnippetDialog> {
  final _search = TextEditingController();
  var _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final snippets = filterCommandSnippets(
      ref.watch(commandSnippetProvider),
      _query,
    );

    return OrbitaDialog(
      animation: widget.animation,
      title: l10n.settingsSnippets,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.58,
        width: double.maxFinite,
        child: Column(
          children: [
            FTextField(
              control: FTextFieldControl.managed(
                controller: _search,
                onChange: (value) => setState(() => _query = value.text),
              ),
              hint: l10n.commandSnippetSearchHint,
              prefixBuilder: (context, style, variants) =>
                  const Icon(Ionicons.search_outline),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: snippets.isEmpty
                  ? EmptyState(
                      icon: Ionicons.flash_outline,
                      title: l10n.commandSnippetEmpty,
                      subtitle: l10n.settingsSnippetsDesc,
                    )
                  : ListView.builder(
                      itemCount: snippets.length,
                      itemBuilder: (context, index) {
                        final snippet = snippets[index];
                        return FItem(
                          prefix: const Icon(Ionicons.flash_outline),
                          title: Text(snippet.name),
                          subtitle: Text(
                            snippet.command,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPress: () =>
                              Navigator.of(context).pop(snippet.command),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
