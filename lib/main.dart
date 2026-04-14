import 'package:flutter/material.dart';

import 'services/theme_service.dart';
import 'screens/role_login_page.dart';
import 'theme/theme.dart';

void main() {
  runApp(const LavifyApp());
}

class LavifyApp extends StatelessWidget {
  const LavifyApp({super.key});

  static final _themeService = ThemeService();

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
          home: const RoleLoginPage(),
        );
      },
    );
  }
}

class LegacyHomePage extends StatelessWidget {
  const LegacyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1C2C),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Lava tu auto",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "sin salir de casa",
              style: const TextStyle(
                color: Color(0xFF4FC3F7),
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Solicita un lavado desde tu celular y un profesional llega a donde estás en minutos.",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Pedir lavado ahora",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
