import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSharedPrefs();
  initServerStorage();
  runApp(
    const ProviderScope(child: OrbitaApp()),
  );
}
