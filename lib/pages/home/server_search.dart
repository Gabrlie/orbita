import 'package:orbita/models/server.dart';

List<Server> filterServersForQuery(List<Server> servers, String query) {
  final terms = query
      .trim()
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((term) => term.isNotEmpty)
      .toList();

  if (terms.isEmpty) return servers;

  return servers.where((server) {
    final searchable = [
      server.name,
      server.host,
      server.port.toString(),
      server.username,
      server.osType.name,
      ...server.tags,
    ].join(' ').toLowerCase();

    return terms.every(searchable.contains);
  }).toList();
}
