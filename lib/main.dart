import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import 'core/database/database_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/auth_service.dart';
import 'shared/themes/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  _setupLogging();
  
  await _initializeServices();
  
  runApp(
    const ProviderScope(
      child: HypertensionApp(),
    ),
  );
}

void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}

Future<void> _initializeServices() async {
  try {
    await DatabaseService.instance.initialize();
    await NotificationService.instance.initialize();
    await AuthService.instance.initialize();
  } catch (e) {
    Logger('main').severe('Failed to initialize services: $e');
  }
}