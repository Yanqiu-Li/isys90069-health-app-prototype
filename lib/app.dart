import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shared/themes/app_theme.dart';
import 'features/auth/presentation/pages/auth_wrapper.dart';
import 'core/constants/app_constants.dart';

class HypertensionApp extends ConsumerWidget {
  const HypertensionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}