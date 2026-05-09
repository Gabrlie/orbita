import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/models/tailnet_models.dart';
import 'package:orbita/services/embedded_tailnet_service.dart';

final embeddedTailnetServiceProvider = Provider<EmbeddedTailnetService>((ref) {
  return EmbeddedTailnetService();
});

final tailnetStatusProvider = FutureProvider.autoDispose<TailnetStatus>((
  ref,
) async {
  final status = await ref
      .read(embeddedTailnetServiceProvider)
      .startWithPeers();
  if (!status.isRunning || status.needsLogin) {
    final timer = Timer(const Duration(seconds: 3), ref.invalidateSelf);
    ref.onDispose(timer.cancel);
  }
  return status;
});
