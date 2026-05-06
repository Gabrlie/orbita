import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/models/command_snippet.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:uuid/uuid.dart';

const _keyCommandSnippets = 'command_snippets';

final commandSnippetProvider =
    NotifierProvider<CommandSnippetNotifier, List<CommandSnippet>>(
      CommandSnippetNotifier.new,
    );

class CommandSnippetNotifier extends Notifier<List<CommandSnippet>> {
  @override
  List<CommandSnippet> build() {
    final prefs = ref.read(sharedPrefsProvider);
    final raw = prefs.getString(_keyCommandSnippets);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => CommandSnippet.fromJson(item as Map<String, dynamic>))
          .where((snippet) => snippet.command.trim().isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> add({required String name, required String command}) async {
    final snippet = CommandSnippet(
      id: const Uuid().v4(),
      name: name.trim(),
      command: command.trimRight(),
      createdAt: DateTime.now(),
    );
    await _save([...state, snippet]);
  }

  Future<void> update(CommandSnippet snippet) async {
    await _save(
      state.map((item) => item.id == snippet.id ? snippet : item).toList(),
    );
  }

  Future<void> delete(String id) async {
    await _save(state.where((snippet) => snippet.id != id).toList());
  }

  Future<void> _save(List<CommandSnippet> snippets) async {
    state = snippets;
    final encoded = jsonEncode(snippets.map((item) => item.toJson()).toList());
    await ref.read(sharedPrefsProvider).setString(_keyCommandSnippets, encoded);
  }
}

List<CommandSnippet> filterCommandSnippets(
  List<CommandSnippet> snippets,
  String query,
) {
  final terms = query
      .trim()
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((term) => term.isNotEmpty)
      .toList();
  if (terms.isEmpty) return snippets;
  return snippets.where((snippet) {
    final haystack = '${snippet.name} ${snippet.command}'.toLowerCase();
    return terms.every(haystack.contains);
  }).toList();
}
