import 'package:orbita/models/server.dart';

const ungroupedServerGroupId = '__ungrouped__';

class ServerGroup {
  final String id;
  final String name;
  final DateTime createdAt;

  const ServerGroup({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  ServerGroup copyWith({String? name}) {
    return ServerGroup(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ServerGroup.fromJson(Map<String, dynamic> json) {
    return ServerGroup(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class ServerGroupState {
  final List<ServerGroup> groups;
  final Map<String, String> assignments;
  final Map<String, List<String>> serverOrders;

  const ServerGroupState({
    this.groups = const [],
    this.assignments = const {},
    this.serverOrders = const {},
  });

  Map<String, dynamic> toJson() => {
    'groups': groups.map((group) => group.toJson()).toList(),
    'assignments': assignments,
    'serverOrders': serverOrders,
  };

  factory ServerGroupState.fromJson(Map<String, dynamic> json) {
    return ServerGroupState(
      groups: (json['groups'] as List<dynamic>? ?? const [])
          .map((item) => ServerGroup.fromJson(item as Map<String, dynamic>))
          .where((group) => group.name.trim().isNotEmpty)
          .toList(),
      assignments: (json['assignments'] as Map<String, dynamic>? ?? const {})
          .map((key, value) => MapEntry(key, value.toString())),
      serverOrders:
          (json['serverOrders'] as Map<String, dynamic>? ?? const {}).map(
            (key, value) => MapEntry(
              key,
              (value is List<dynamic> ? value : const [])
                  .map((item) => item.toString())
                  .toList(),
            ),
          ),
    );
  }
}

class ServerGroupBucket {
  final String id;
  final String name;
  final bool isUngrouped;
  final List<Server> servers;

  const ServerGroupBucket({
    required this.id,
    required this.name,
    required this.isUngrouped,
    required this.servers,
  });
}
