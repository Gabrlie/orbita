import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/providers/app_lifecycle_provider.dart';

void main() {
  test('waitUntilResumed completes when lifecycle resumes', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(appLifecycleProvider.notifier);

    controller.update(AppLifecycleState.paused);
    var completed = false;
    final wait = controller.waitUntilResumed().then((_) => completed = true);

    await Future<void>.delayed(Duration.zero);
    expect(completed, isFalse);

    controller.update(AppLifecycleState.resumed);
    await wait;

    expect(completed, isTrue);
    expect(controller.isResumeRecoveryWindow, isTrue);
  });
}
