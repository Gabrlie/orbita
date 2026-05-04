class RemoteScript {
  final String id;
  final String name;
  final String description;
  final String command;
  final List<String> providedTools;
  final bool isSystem;

  const RemoteScript({
    required this.id,
    required this.name,
    required this.description,
    required this.command,
    this.providedTools = const [],
    this.isSystem = false,
  });

  RemoteScript copyWith({
    String? id,
    String? name,
    String? description,
    String? command,
    List<String>? providedTools,
    bool? isSystem,
  }) {
    return RemoteScript(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      command: command ?? this.command,
      providedTools: providedTools ?? this.providedTools,
      isSystem: isSystem ?? this.isSystem,
    );
  }

  factory RemoteScript.fromJson(Map<String, Object?> json) {
    return RemoteScript(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      command: json['command'] as String? ?? '',
      providedTools: [
        for (final tool in json['providedTools'] as List? ?? const [])
          if (tool is String) tool,
      ],
      isSystem: json['isSystem'] as bool? ?? false,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'command': command,
      'providedTools': providedTools,
      'isSystem': isSystem,
    };
  }
}
