import 'package:flutter/material.dart';

import 'screens/login_page.dart';
import 'screens/app_shell.dart';
import 'theme/theme.dart';

void main() {
  runApp(const LavifyApp());
}

class LavifyApp extends StatelessWidget {
  const LavifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lavify',
      debugShowCheckedModeBanner: false,
      theme: LavifyTheme.theme,
      home: const LoginPage(),
    );
  }
}

class LegacyHomePage extends StatelessWidget {
  const LegacyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B1C2C),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Lava tu auto",
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "sin salir de casa",
              style: TextStyle(
                color: Color(0xFF4FC3F7),
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Solicita un lavado desde tu celular y un profesional llega a donde estás en minutos.",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2196F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Pedir lavado ahora",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
