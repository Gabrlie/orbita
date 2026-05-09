class TailnetStatus {
  final String backendState;
  final String authUrl;
  final String error;
  final TailnetPeer? self;
  final List<TailnetPeer> peers;

  const TailnetStatus({
    required this.backendState,
    this.authUrl = '',
    this.error = '',
    this.self,
    this.peers = const [],
  });

  bool get isRunning => backendState.toLowerCase() == 'running';

  bool get isUnavailable => backendState.toLowerCase() == 'unavailable';

  bool get needsLogin => authUrl.isNotEmpty && !isRunning;

  TailnetStatus copyWith({
    String? backendState,
    String? authUrl,
    String? error,
    TailnetPeer? Function()? self,
    List<TailnetPeer>? peers,
  }) {
    return TailnetStatus(
      backendState: backendState ?? this.backendState,
      authUrl: authUrl ?? this.authUrl,
      error: error ?? this.error,
      self: self != null ? self() : this.self,
      peers: peers ?? this.peers,
    );
  }

  factory TailnetStatus.fromJson(Map<String, dynamic> json) {
    final selfJson = json['self'];
    final peersJson = json['peers'];
    return TailnetStatus(
      backendState: json['backendState'] as String? ?? 'Stopped',
      authUrl: json['authUrl'] as String? ?? '',
      error: json['error'] as String? ?? '',
      self: selfJson is Map<String, dynamic>
          ? TailnetPeer.fromJson(selfJson)
          : null,
      peers: peersJson is List<dynamic>
          ? peersJson
                .whereType<Map<String, dynamic>>()
                .map(TailnetPeer.fromJson)
                .toList(growable: false)
          : const [],
    );
  }
}

class TailnetPeer {
  final String id;
  final String hostName;
  final String dnsName;
  final List<String> tailscaleIps;
  final bool online;
  final bool isSelf;

  const TailnetPeer({
    required this.id,
    required this.hostName,
    required this.dnsName,
    this.tailscaleIps = const [],
    this.online = false,
    this.isSelf = false,
  });

  String get displayName {
    final dns = dnsNameWithoutTrailingDot;
    if (dns.isNotEmpty) return dns;
    if (hostName.isNotEmpty) return hostName;
    return tailscaleIps.firstOrNull ?? id;
  }

  String get dnsNameWithoutTrailingDot {
    var value = dnsName.trim();
    while (value.endsWith('.')) {
      value = value.substring(0, value.length - 1);
    }
    return value;
  }

  String get bindingTarget {
    if (dnsNameWithoutTrailingDot.isNotEmpty) return dnsNameWithoutTrailingDot;
    if (hostName.isNotEmpty) return hostName;
    return tailscaleIps.firstOrNull ?? id;
  }

  factory TailnetPeer.fromJson(Map<String, dynamic> json) {
    final ips = json['tailscaleIps'];
    return TailnetPeer(
      id: json['id'] as String? ?? '',
      hostName: json['hostName'] as String? ?? '',
      dnsName: json['dnsName'] as String? ?? '',
      tailscaleIps: ips is List<dynamic>
          ? ips.whereType<String>().toList(growable: false)
          : const [],
      online: json['online'] as bool? ?? false,
      isSelf: json['isSelf'] as bool? ?? false,
    );
  }
}

class TailnetProxy {
  final String id;
  final String host;
  final int port;
  final String target;
  final int remotePort;

  const TailnetProxy({
    required this.id,
    required this.host,
    required this.port,
    required this.target,
    required this.remotePort,
  });

  factory TailnetProxy.fromJson(Map<String, dynamic> json) {
    return TailnetProxy(
      id: json['id'] as String? ?? '',
      host: json['host'] as String? ?? '127.0.0.1',
      port: json['port'] as int? ?? 0,
      target: json['target'] as String? ?? '',
      remotePort: json['remotePort'] as int? ?? 22,
    );
  }
}
