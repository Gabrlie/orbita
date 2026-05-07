import 'package:flutter/material.dart';
import 'package:orbita/widgets/common.dart';

class SecurityPanel extends StatelessWidget {
  final List<Widget> children;

  const SecurityPanel({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tonalItemColor(context),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 24, endIndent: 24),
            children[i],
          ],
        ],
      ),
    );
  }
}

class SecurityInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const SecurityInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Icon(icon, color: theme.colorScheme.primary, size: 20),
      minLeadingWidth: 24,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
    );
  }
}
