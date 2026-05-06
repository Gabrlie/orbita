class CommandSnippet {
  final String id;
  final String name;
  final String command;
  final DateTime createdAt;

  const CommandSnippet({
    required this.id,
    required this.name,
    required this.command,
    required this.createdAt,
  });

  CommandSnippet copyWith({
    String? name,
    String? command,
    DateTime? createdAt,
  }) {
    return CommandSnippet(
      id: id,
      name: name ?? this.name,
      command: command ?? this.command,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'command': command,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CommandSnippet.fromJson(Map<String, dynamic> json) {
    return CommandSnippet(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      command: json['command'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
