import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';

/// Supported server operating system types.
enum OsType {
  ubuntu,
  debian,
  centos,
  rocky,
  alma,
  fedora,
  arch,
  alpine,
  opensuse,
  nixos,
  gentoo,
  linux,
  windows,
  macos,
  freebsd,
  openbsd,
  unknown,
}

/// Display config for each OS type.
class OsConfig {
  final String label;
  final Color color;
  final IconData icon;

  const OsConfig(this.label, this.color, this.icon);
}

final _configs = <OsType, OsConfig>{
  OsType.ubuntu:   OsConfig('Ubuntu',      SimpleIconColors.ubuntu,        SimpleIcons.ubuntu),
  OsType.debian:   OsConfig('Debian',      SimpleIconColors.debian,        SimpleIcons.debian),
  OsType.centos:   OsConfig('CentOS',      SimpleIconColors.centos,        SimpleIcons.centos),
  OsType.rocky:    OsConfig('Rocky Linux', SimpleIconColors.rockylinux,    SimpleIcons.rockylinux),
  OsType.alma:     OsConfig('AlmaLinux',   SimpleIconColors.almalinux,     SimpleIcons.almalinux),
  OsType.fedora:   OsConfig('Fedora',      SimpleIconColors.fedora,        SimpleIcons.fedora),
  OsType.arch:     OsConfig('Arch Linux',  SimpleIconColors.archlinux,     SimpleIcons.archlinux),
  OsType.alpine:   OsConfig('Alpine',      SimpleIconColors.alpinelinux,   SimpleIcons.alpinelinux),
  OsType.opensuse: OsConfig('openSUSE',    SimpleIconColors.opensuse,      SimpleIcons.opensuse),
  OsType.nixos:    OsConfig('NixOS',       SimpleIconColors.nixos,         SimpleIcons.nixos),
  OsType.gentoo:   OsConfig('Gentoo',      SimpleIconColors.gentoo,        SimpleIcons.gentoo),
  OsType.linux:    OsConfig('Linux',       SimpleIconColors.linux,         SimpleIcons.linux),
  OsType.windows:  const OsConfig('Windows',  Color(0xFF0078D4),              Icons.window),
  OsType.macos:    OsConfig('macOS',       SimpleIconColors.apple,         SimpleIcons.apple),
  OsType.freebsd:  OsConfig('FreeBSD',     SimpleIconColors.freebsd,       SimpleIcons.freebsd),
  OsType.openbsd:  OsConfig('OpenBSD',     SimpleIconColors.openbsd,       SimpleIcons.openbsd),
  OsType.unknown:  const OsConfig('Unknown', Color(0xFF9E9E9E),            Icons.help_outline),
};

/// Get config for a given OS type.
OsConfig osConfigOf(OsType type) => _configs[type] ?? _configs[OsType.unknown]!;

/// Resolve [OsType] from a string (e.g., from /etc/os-release ID).
OsType osTypeFromString(String id) {
  final lower = id.toLowerCase().trim();
  for (final type in OsType.values) {
    if (type.name == lower) return type;
  }
  if (lower.contains('ubuntu')) return OsType.ubuntu;
  if (lower.contains('debian')) return OsType.debian;
  if (lower.contains('centos')) return OsType.centos;
  if (lower.contains('rocky')) return OsType.rocky;
  if (lower.contains('alma')) return OsType.alma;
  if (lower.contains('fedora')) return OsType.fedora;
  if (lower.contains('arch')) return OsType.arch;
  if (lower.contains('alpine')) return OsType.alpine;
  if (lower.contains('suse')) return OsType.opensuse;
  if (lower.contains('nix')) return OsType.nixos;
  if (lower.contains('gentoo')) return OsType.gentoo;
  if (lower.contains('windows')) return OsType.windows;
  if (lower.contains('darwin') || lower.contains('macos')) return OsType.macos;
  if (lower.contains('freebsd')) return OsType.freebsd;
  if (lower.contains('openbsd')) return OsType.openbsd;
  return OsType.unknown;
}

/// Displays an OS brand icon with official color.
///
/// Reusable in server cards, list selectors, and configuration forms.
class OsIcon extends StatelessWidget {
  final OsType type;
  final double size;

  const OsIcon({super.key, required this.type, this.size = 32});

  @override
  Widget build(BuildContext context) {
    final config = osConfigOf(type);
    return Icon(config.icon, size: size, color: config.color);
  }
}

/// List tile with OS brand icon, for use in selection lists / pickers.
class OsListTile extends StatelessWidget {
  final OsType type;
  final bool selected;
  final VoidCallback? onTap;

  const OsListTile({
    super.key,
    required this.type,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = osConfigOf(type);
    return ListTile(
      leading: OsIcon(type: type),
      title: Text(config.label),
      trailing: selected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
