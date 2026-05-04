import 'package:orbita/services/remote_file_command_builder.dart';

class OrbitaScriptSelect {
  final String name;
  final String title;
  final List<OrbitaScriptOption> options;

  const OrbitaScriptSelect({
    required this.name,
    required this.title,
    required this.options,
  });
}

class OrbitaScriptOption {
  final String label;
  final String value;

  const OrbitaScriptOption({required this.label, required this.value});
}

class OrbitaScriptTemplate {
  final String command;
  final List<OrbitaScriptSelect> selects;

  const OrbitaScriptTemplate({required this.command, required this.selects});

  bool get hasInputs => selects.isNotEmpty;
}

OrbitaScriptTemplate parseOrbitaScript(String command) {
  final selects = <String, _SelectBuilder>{};
  final commandLines = <String>[];

  for (final line in command.split('\n')) {
    final directive = _parseDirective(line);
    if (directive == null) {
      commandLines.add(line);
      continue;
    }

    final kind = directive.$1;
    final args = directive.$2;
    final name = args['name']?.trim();
    if (name == null || name.isEmpty) continue;

    if (kind == 'select') {
      selects[name] = _SelectBuilder(
        name: name,
        title: args['title']?.trim().isNotEmpty == true
            ? args['title']!.trim()
            : name,
      );
    } else if (kind == 'option') {
      final label = args['label']?.trim();
      final value = args['value'];
      if (label == null || label.isEmpty || value == null) continue;
      selects
          .putIfAbsent(name, () => _SelectBuilder(name: name, title: name))
          .options
          .add(OrbitaScriptOption(label: label, value: value));
    }
  }

  return OrbitaScriptTemplate(
    command: commandLines.join('\n'),
    selects: [
      for (final select in selects.values)
        if (select.options.isNotEmpty)
          OrbitaScriptSelect(
            name: select.name,
            title: select.title,
            options: List.unmodifiable(select.options),
          ),
    ],
  );
}

String renderOrbitaScript(
  OrbitaScriptTemplate template,
  Map<String, String> values,
) {
  var command = template.command;
  for (final entry in values.entries) {
    command = command.replaceAll('{{${entry.key}}}', shellQuote(entry.value));
    command = command.replaceAll('{{${entry.key}|raw}}', entry.value);
  }
  return command;
}

(String, Map<String, String>)? _parseDirective(String line) {
  final match = RegExp(
    r'^\s*#\s*orbita:(select|option)\s+(.+)$',
  ).firstMatch(line);
  if (match == null) return null;
  return (match.group(1)!, _parseArgs(match.group(2)!));
}

Map<String, String> _parseArgs(String input) {
  final args = <String, String>{};
  final pattern = RegExp(r'(\w+)=("(?:[^"\\]|\\.)*"|\S+)');
  for (final match in pattern.allMatches(input)) {
    final key = match.group(1)!;
    final raw = match.group(2)!;
    args[key] = _unquote(raw);
  }
  return args;
}

String _unquote(String raw) {
  if (raw.length < 2 || !raw.startsWith('"') || !raw.endsWith('"')) {
    return raw;
  }
  return raw
      .substring(1, raw.length - 1)
      .replaceAll(r'\"', '"')
      .replaceAll(r'\\', '\\');
}

class _SelectBuilder {
  final String name;
  final String title;
  final List<OrbitaScriptOption> options = [];

  _SelectBuilder({required this.name, required this.title});
}
