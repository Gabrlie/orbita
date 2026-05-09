part of 'ssh_connection_manager.dart';

String _connectionFingerprint(Server server, SshKey? key) {
  return [
    server.host,
    server.port,
    server.username,
    server.authType.name,
    server.password ?? '',
    server.keyId ?? '',
    server.connectionMode.name,
    server.tailscalePeerId ?? '',
    server.tailscalePeerName ?? '',
    server.tailscaleDnsName ?? '',
    key?.id ?? '',
    key?.privateKeyPem.hashCode ?? 0,
    key?.passphrase?.hashCode ?? 0,
  ].join('|');
}
