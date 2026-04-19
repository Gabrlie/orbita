import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/providers/server_refresh_provider.dart';

void main() {
  test('refreshAll increments every tracked server token', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    const firstServerId = 'server-a';
    const secondServerId = 'server-b';

    final firstInitial = container.read(serverRefreshProvider(firstServerId));
    final secondInitial = container.read(serverRefreshProvider(secondServerId));

    container.read(serverRefreshControllerProvider.notifier).refreshAll([
      firstServerId,
      secondServerId,
    ]);

    expect(
      container.read(serverRefreshProvider(firstServerId)),
      firstInitial + 1,
    );
    expect(
      container.read(serverRefreshProvider(secondServerId)),
      secondInitial + 1,
    );
  });

  test('refreshServer increments only the selected server token', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    const selectedServerId = 'server-a';
    const untouchedServerId = 'server-b';

    final selectedInitial = container.read(
      serverRefreshProvider(selectedServerId),
    );
    final untouchedInitial = container.read(
      serverRefreshProvider(untouchedServerId),
    );

    container
        .read(serverRefreshControllerProvider.notifier)
        .refreshServer(selectedServerId);

    expect(
      container.read(serverRefreshProvider(selectedServerId)),
      selectedInitial + 1,
    );
    expect(
      container.read(serverRefreshProvider(untouchedServerId)),
      untouchedInitial,
    );
  });
}
