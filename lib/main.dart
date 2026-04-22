import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/session_models.dart';
import 'screens/app_shell.dart';
import 'screens/role_login_page.dart';
import 'services/auth_service.dart';
import 'services/profile_service.dart';
import 'services/session_service.dart';
import 'services/theme_service.dart';
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LavifyApp());
}

class LavifyApp extends StatelessWidget {
  const LavifyApp({super.key});

  static final ThemeService _themeService = ThemeService();
  static final AuthService _authService = AuthService();
  static final ProfileService _profileService = ProfileService();
  static final SessionService _sessionService = SessionService();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeService.themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          key: ValueKey(themeMode),
          title: 'Lavify',
          debugShowCheckedModeBanner: false,
          theme: LavifyTheme.lightTheme,
          darkTheme: LavifyTheme.darkTheme,
          themeMode: themeMode,
          themeAnimationDuration: Duration.zero,
          routes: {'/home': (_) => const AppShell(mode: AppRole.client)},
          home: const _AuthGate(),
        );
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MockSession?>(
      valueListenable: LavifyApp._sessionService.currentSession,
      builder: (context, session, _) {
        return StreamBuilder(
          stream: LavifyApp._authService.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                session == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final user = snapshot.data;
            if (user != null) {
              return FutureBuilder(
                future: LavifyApp._authService.loadOrCreateUserProfile(
                  user: user,
                ),
                builder: (context, profileSnapshot) {
                  if (profileSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final profile = profileSnapshot.data;
                  if (profile != null) {
                    LavifyApp._profileService.setProfile(profile);
                    LavifyApp._sessionService.startSessionFromProfile(profile);
                  }

                  return AppShell(mode: profile?.role ?? AppRole.client);
                },
              );
            }

            if (session != null) {
              return AppShell(mode: session.role);
            }

            return const RoleLoginPage();
          },
        );
      },
    );
  }
}
