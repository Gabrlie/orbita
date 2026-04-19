import 'package:orbita/widgets/os_icon.dart';

enum AuthType { password, key }

class Server {
  final String id;
  final String name;
  final String host;
  final int port;
  final String username;
  final AuthType authType;
  final String? password;
  final String? keyId;
  final OsType osType;
  final List<String> tags;

  const Server({
    required this.id,
    required this.name,
    required this.host,
    this.port = 22,
    required this.username,
    this.authType = AuthType.password,
    this.password,
    this.keyId,
    this.osType = OsType.unknown,
    this.tags = const [],
  });

  Server copyWith({
    String? id,
    String? name,
    String? host,
    int? port,
    String? username,
    AuthType? authType,
    String? Function()? password,
    String? Function()? keyId,
    OsType? osType,
    List<String>? tags,
  }) {
    return Server(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      authType: authType ?? this.authType,
      password: password != null ? password() : this.password,
      keyId: keyId != null ? keyId() : this.keyId,
      osType: osType ?? this.osType,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'host': host,
        'port': port,
        'username': username,
        'authType': authType.name,
        'password': password,
        'keyId': keyId,
        'osType': osType.name,
        'tags': tags,
      };

  factory Server.fromJson(Map<String, dynamic> json) => Server(
        id: json['id'] as String,
        name: json['name'] as String,
        host: json['host'] as String,
        port: json['port'] as int? ?? 22,
        username: json['username'] as String? ?? 'root',
        authType: json['authType'] == 'key' ? AuthType.key : AuthType.password,
        password: json['password'] as String?,
        keyId: json['keyId'] as String?,
        osType: osTypeFromString(json['osType'] as String? ?? ''),
        tags: (json['tags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
      );
}
