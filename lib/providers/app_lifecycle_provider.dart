import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appLifecycleProvider =
    NotifierProvider<AppLifecycleController, AppLifecycleState>(
      AppLifecycleController.new,
    );

class AppLifecycleController extends Notifier<AppLifecycleState> {
  final _resumeWaiters = <Completer<void>>[];
  DateTime? _lastResumedAt;

  @override
  AppLifecycleState build() => AppLifecycleState.resumed;

  bool get isResumed => state == AppLifecycleState.resumed;

  bool get isResumeRecoveryWindow {
    final resumedAt = _lastResumedAt;
    if (resumedAt == null) return false;
    return DateTime.now().difference(resumedAt) < const Duration(seconds: 8);
  }

  void update(AppLifecycleState nextState) {
    state = nextState;
    if (nextState != AppLifecycleState.resumed) return;
    _lastResumedAt = DateTime.now();
    final waiters = List<Completer<void>>.of(_resumeWaiters);
    _resumeWaiters.clear();
    for (final waiter in waiters) {
      if (!waiter.isCompleted) waiter.complete();
    }
  }

  Future<void> waitUntilResumed() {
    if (isResumed) return Future.value();
    final completer = Completer<void>();
    _resumeWaiters.add(completer);
    return completer.future;
  }
}
