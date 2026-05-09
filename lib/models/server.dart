import 'package:orbita/widgets/os_icon.dart';

enum AuthType { password, key }

enum ServerConnectionMode { direct, tailscale }

ServerConnectionMode serverConnectionModeFromString(String value) {
  return value == ServerConnectionMode.tailscale.name
      ? ServerConnectionMode.tailscale
      : ServerConnectionMode.direct;
}

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
  final ServerConnectionMode connectionMode;
  final String? tailscalePeerId;
  final String? tailscalePeerName;
  final String? tailscaleDnsName;

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
    this.connectionMode = ServerConnectionMode.direct,
    this.tailscalePeerId,
    this.tailscalePeerName,
    this.tailscaleDnsName,
  });

  String? get tailnetTarget {
    final dns = tailscaleDnsName?.trim();
    if (dns != null && dns.isNotEmpty) return dns;
    final name = tailscalePeerName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final id = tailscalePeerId?.trim();
    if (id != null && id.isNotEmpty) return id;
    return null;
  }

  String get displayHost {
    if (connectionMode == ServerConnectionMode.tailscale) {
      return tailnetTarget ?? host;
    }
    return host;
  }

  String get displayEndpoint {
    final display = displayHost.trim();
    if (display.isEmpty) return port.toString();
    return '$display:$port';
  }

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
    ServerConnectionMode? connectionMode,
    String? Function()? tailscalePeerId,
    String? Function()? tailscalePeerName,
    String? Function()? tailscaleDnsName,
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
      connectionMode: connectionMode ?? this.connectionMode,
      tailscalePeerId: tailscalePeerId != null
          ? tailscalePeerId()
          : this.tailscalePeerId,
      tailscalePeerName: tailscalePeerName != null
          ? tailscalePeerName()
          : this.tailscalePeerName,
      tailscaleDnsName: tailscaleDnsName != null
          ? tailscaleDnsName()
          : this.tailscaleDnsName,
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
    'connectionMode': connectionMode.name,
    'tailscalePeerId': tailscalePeerId,
    'tailscalePeerName': tailscalePeerName,
    'tailscaleDnsName': tailscaleDnsName,
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
    tags:
        (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
        const [],
    connectionMode: serverConnectionModeFromString(
      json['connectionMode'] as String? ?? '',
    ),
    tailscalePeerId: json['tailscalePeerId'] as String?,
    tailscalePeerName:
        json['tailscalePeerName'] as String? ??
        json['tailscaleTarget'] as String?,
    tailscaleDnsName:
        json['tailscaleDnsName'] as String? ??
        json['tailscaleTarget'] as String?,
  );
}
