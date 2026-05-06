import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/providers/command_snippet_provider.dart';
import 'package:orbita/widgets/common.dart';

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
    final command = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _TerminalSnippetSheet(),
    );
    if (command != null && mounted) widget.onSelected(command);
  }
}

class _TerminalSnippetSheet extends ConsumerStatefulWidget {
  const _TerminalSnippetSheet();

  @override
  ConsumerState<_TerminalSnippetSheet> createState() =>
      _TerminalSnippetSheetState();
}

class _TerminalSnippetSheetState extends ConsumerState<_TerminalSnippetSheet> {
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

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.68,
        child: TonalListBackground(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: l10n.commandSnippetSearchHint,
                    prefixIcon: const Icon(Ionicons.search_outline),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Expanded(
                child: snippets.isEmpty
                    ? EmptyState(
                        icon: Ionicons.flash_outline,
                        title: l10n.commandSnippetEmpty,
                        subtitle: l10n.settingsSnippetsDesc,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: snippets.length,
                        itemBuilder: (context, index) {
                          final snippet = snippets[index];
                          return Card(
                            color: tonalItemColor(context),
                            surfaceTintColor: Colors.transparent,
                            child: ListTile(
                              leading: const Icon(Ionicons.flash_outline),
                              title: Text(snippet.name),
                              subtitle: Text(
                                snippet.command,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () =>
                                  Navigator.of(context).pop(snippet.command),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
