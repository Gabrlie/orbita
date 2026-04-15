import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/widgets/common.dart';
import 'package:orbita/widgets/server_card.dart';
import 'package:orbita/widgets/os_icon.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final mockServers = [
      ServerCard(
        name: 'NAS',
        osType: OsType.debian,
        online: true,
        uptime: '16天11时14分',
        load: '0.6',
        cpuPercent: 0.03,
        cpuSub: '12 C',
        memPercent: 0.61,
        memSub: '30.8 GB',
        diskPercent: 0.22,
        diskSub: '1.4 TB',
        netUp: '0 B',
        netUpTotal: '113.8 GB',
        netDown: '0 B',
        netDownTotal: '76.5 GB',
        ioWrite: '0 B',
        ioWriteTotal: '37.0 GB',
        ioRead: '0 B',
        ioReadTotal: '801.5 GB',
        onTap: () => context.go('/home/server/1'),
      ),
      ServerCard(
        name: 'Web Server',
        osType: OsType.ubuntu,
        online: true,
        uptime: '142天3时',
        load: '1.2',
        cpuPercent: 0.45,
        cpuSub: '4 C',
        memPercent: 0.78,
        memSub: '6.2 GB',
        diskPercent: 0.55,
        diskSub: '44 GB',
        netUp: '1.2 KB',
        netUpTotal: '2.1 TB',
        netDown: '3.5 KB',
        netDownTotal: '1.8 TB',
        ioWrite: '512 B',
        ioWriteTotal: '120 GB',
        ioRead: '1.0 KB',
        ioReadTotal: '450 GB',
        onTap: () => context.go('/home/server/2'),
      ),
      ServerCard(
        name: 'Backup Node',
        osType: OsType.alpine,
        online: false,
        onTap: () => context.go('/home/server/3'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.servers),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(label: Text(l10n.all), selected: true, onSelected: (_) {}),
                const SizedBox(width: 8),
                FilterChip(label: Text(l10n.production), selected: false, onSelected: (_) {}),
                const SizedBox(width: 8),
                FilterChip(label: Text(l10n.test), selected: false, onSelected: (_) {}),
              ],
            ),
          ),
          Expanded(
            child: mockServers.isEmpty
                ? EmptyState(
                    icon: Icons.dns,
                    title: l10n.noServersTitle,
                    subtitle: l10n.noServersSubtitle,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: mockServers.length,
                    itemBuilder: (context, index) => mockServers[index],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
