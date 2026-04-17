import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/session_models.dart';
import 'screens/app_shell.dart';
import 'screens/role_login_page.dart';
import 'services/theme_service.dart';
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LavifyApp());
}

class LavifyApp extends StatelessWidget {
  const LavifyApp({super.key});

  static final ThemeService _themeService = ThemeService();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeService.themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Lavify',
          debugShowCheckedModeBanner: false,
          theme: LavifyTheme.lightTheme,
          darkTheme: LavifyTheme.darkTheme,
          themeMode: themeMode,
          routes: {
            '/home': (_) => const AppShell(mode: AppRole.client),
          },
          home: const RoleLoginPage(),
        );
      },
    );
  }
}
