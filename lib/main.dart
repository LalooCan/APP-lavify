import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'app_config.dart';
import 'firebase_options.dart';
import 'models/wash_models.dart';
import 'screens/app_shell.dart';
import 'screens/onboarding_page.dart';
import 'screens/role_login_page.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/profile_service.dart';
import 'services/session_service.dart';
import 'services/theme_service.dart';
import 'theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    MapboxOptions.setAccessToken(AppConfig.mapboxPublicToken);
  }

  // Inicia Firebase sin bloquear — runApp muestra el splash de inmediato
  // mientras el SDK se inicializa en paralelo.
  final firebaseReady = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(LavifyApp(firebaseReady: firebaseReady));

  // Notificaciones solo después de que Firebase esté listo.
  unawaited(firebaseReady.then((_) => NotificationService().initialize()));
}

class LavifyApp extends StatelessWidget {
  const LavifyApp({super.key, required this.firebaseReady});

  final Future<FirebaseApp> firebaseReady;

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
          title: 'Lavify',
          debugShowCheckedModeBanner: false,
          theme: LavifyTheme.lightTheme,
          darkTheme: LavifyTheme.darkTheme,
          themeMode: themeMode,
          themeAnimationDuration: Duration.zero,
          routes: {'/home': (_) => const AppShell(mode: AppRole.client)},
          home: FutureBuilder<FirebaseApp>(
            future: firebaseReady,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const _SplashScreen();
              }
              return const _AuthGate();
            },
          ),
        );
      },
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  String? _profileUid;
  Future<UserProfile>? _profileFuture;

  @override
  void initState() {
    super.initState();
    // Si el usuario ya estaba logueado (estado local de Firebase), iniciamos la
    // carga del perfil inmediatamente sin esperar a que el stream emita.
    final existingUser = FirebaseAuth.instance.currentUser;
    if (existingUser != null) {
      _profileFor(existingUser);
    }
  }

  Future<UserProfile> _profileFor(User user) {
    if (_profileUid != user.uid || _profileFuture == null) {
      _profileUid = user.uid;
      _profileFuture = _loadAndStoreProfile(user);
    }
    return _profileFuture!;
  }

  Future<UserProfile> _loadAndStoreProfile(User user) async {
    final pendingRole = AuthService.consumePendingRegistrationRole();

    // Perfil cacheado por signInWithGoogle / createUserWithEmailAndPassword.
    final cached = AuthService.consumeRecentlyLoadedProfile();
    if (cached != null && cached.uid == user.uid) {
      final profile = _applyPendingRole(cached, pendingRole);
      LavifyApp._profileService.setProfile(profile);
      return profile;
    }

    // Future en vuelo iniciado por signInWithEmailAndPassword: reutilizarlo
    // para evitar una segunda lectura Firestore en paralelo.
    final inflightFuture = AuthService.consumeInflightProfileFuture();
    if (inflightFuture != null) {
      try {
        final fetched = await inflightFuture;
        if (fetched.uid == user.uid) {
          final profile = _applyPendingRole(fetched, pendingRole);
          LavifyApp._profileService.setProfile(profile);
          return profile;
        }
      } catch (_) {
        // Si falla el future en vuelo, cae al fetch normal de abajo.
      }
    }

    final fetched = await LavifyApp._authService.loadOrCreateUserProfile(
      user: user,
      fallbackRole: pendingRole ?? AppRole.client,
    );
    final profile = _applyPendingRole(fetched, pendingRole);
    LavifyApp._profileService.setProfile(profile);
    return profile;
  }

  // Aplica el rol seleccionado en login al perfil en memoria (sin tocar Firestore).
  // Permite que una misma cuenta acceda como cliente o trabajador según la pestaña.
  UserProfile _applyPendingRole(UserProfile profile, AppRole? pendingRole) {
    if (pendingRole == null || pendingRole == profile.role) return profile;
    return profile.copyWith(role: pendingRole);
  }

  void _clearProfileFuture() {
    _profileUid = null;
    _profileFuture = null;
    LavifyApp._profileService.clearCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MockSession?>(
      valueListenable: LavifyApp._sessionService.currentSession,
      builder: (context, session, _) {
        return StreamBuilder(
          stream: LavifyApp._authService.authStateChanges,
          builder: (context, snapshot) {
            // Solo mostrar spinner si realmente no sabemos el estado de auth.
            // Si currentUser ya está disponible localmente, procedemos de inmediato.
            if (snapshot.connectionState == ConnectionState.waiting &&
                session == null &&
                FirebaseAuth.instance.currentUser == null) {
              return const _SplashScreen();
            }

            final user = snapshot.data;
            if (user != null) {
              return FutureBuilder<UserProfile>(
                future: _profileFor(user),
                builder: (context, profileSnapshot) {
                  if (profileSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  // Reaccionar a cambios del perfil (ej. onboardingComplete)
                  // sin sacar _AuthGate del árbol con pushReplacement.
                  return ValueListenableBuilder<UserProfile>(
                    valueListenable: LavifyApp._profileService.profile,
                    builder: (context, liveProfile, _) {
                      final profile =
                          liveProfile.uid.isNotEmpty &&
                                  liveProfile.uid == user.uid
                              ? liveProfile
                              : profileSnapshot.data;
                      if (profile != null && !profile.onboardingComplete) {
                        return OnboardingPage(profile: profile);
                      }
                      return AppShell(
                        mode: profile?.role ?? AppRole.client,
                      );
                    },
                  );
                },
              );
            }

            _clearProfileFuture();
            if (session != null && AppConfig.backendMode == BackendMode.mock) {
              return AppShell(mode: session.role);
            }

            return const RoleLoginPage();
          },
        );
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: LavifyColors.primary.withAlpha(22),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.local_car_wash_rounded,
                color: LavifyColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Lavify',
              style: TextStyle(
                color: LavifyTheme.textPrimaryColor(context),
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 36),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: LavifyColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
