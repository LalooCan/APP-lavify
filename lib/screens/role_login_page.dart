import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/session_models.dart';
import '../services/auth_service.dart';
import '../theme/theme.dart';
import '../widgets/primary_button.dart';

class RoleLoginPage extends StatefulWidget {
  const RoleLoginPage({super.key, this.initialMode = AppRole.client});

  final AppRole initialMode;

  @override
  State<RoleLoginPage> createState() => _RoleLoginPageState();
}

enum _AuthEntryIntent { signUp, signIn }

class _RoleLoginPageState extends State<RoleLoginPage> {
  static final _authService = AuthService();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberSession = true;
  bool _showAuthForm = false;
  bool _isSubmitting = false;
  _AuthEntryIntent _authIntent = _AuthEntryIntent.signUp;
  late AppRole _selectedMode;

  bool get _isClient => _selectedMode == AppRole.client;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 980;

    return Scaffold(
      body: Container(
        decoration: LavifyTheme.pageDecoration(context),
        child: Stack(
          children: [
            const Positioned(
              top: -120,
              right: -60,
              child: _GlowBubble(size: 280, color: Color(0x1F22C1FF)),
            ),
            Positioned(
              bottom: -90,
              left: -40,
              child: _GlowBubble(
                size: 240,
                color: _isClient
                    ? const Color(0x1628D17C)
                    : const Color(0x14FFC857),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40 : 20,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1160),
                    child: _showAuthForm
                        ? isDesktop
                              ? Row(
                                  children: [
                                    Expanded(
                                      flex: 11,
                                      child: _LoginShowcase(
                                        mode: _selectedMode,
                                      ),
                                    ),
                                    const SizedBox(width: 28),
                                    Expanded(
                                      flex: 9,
                                      child: _LoginCard(
                                        formKey: _formKey,
                                        selectedMode: _selectedMode,
                                        authIntent: _authIntent,
                                        nameController: _nameController,
                                        emailController: _emailController,
                                        passwordController: _passwordController,
                                        obscurePassword: _obscurePassword,
                                        rememberSession: _rememberSession,
                                        isSubmitting: _isSubmitting,
                                        onModeChanged: _setMode,
                                        onTogglePassword: _togglePassword,
                                        onRememberChanged: _setRememberSession,
                                        onLogin: _submitLogin,
                                        onGoogleLogin: _signInWithGoogle,
                                        onBack: _hideAuthForm,
                                        onSwitchToSignIn: _switchToSignIn,
                                        onSwitchToSignUp: _switchToSignUp,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _LoginCard(
                                      formKey: _formKey,
                                      selectedMode: _selectedMode,
                                      authIntent: _authIntent,
                                      nameController: _nameController,
                                      emailController: _emailController,
                                      passwordController: _passwordController,
                                      obscurePassword: _obscurePassword,
                                      rememberSession: _rememberSession,
                                      isSubmitting: _isSubmitting,
                                      onModeChanged: _setMode,
                                      onTogglePassword: _togglePassword,
                                      onRememberChanged: _setRememberSession,
                                      onLogin: _submitLogin,
                                      onGoogleLogin: _signInWithGoogle,
                                      onBack: _hideAuthForm,
                                      onSwitchToSignIn: _switchToSignIn,
                                      onSwitchToSignUp: _switchToSignUp,
                                    ),
                                    const SizedBox(height: 16),
                                    _LoginShowcase(
                                      mode: _selectedMode,
                                      compact: true,
                                    ),
                                  ],
                                )
                        : _EntryLanding(
                            onCreateAccount: () => _openAuthForm(
                              mode: AppRole.client,
                              intent: _AuthEntryIntent.signUp,
                            ),
                            onSignIn: () =>
                                _openAuthForm(intent: _AuthEntryIntent.signIn),
                            onWorkerAccess: () => _openAuthForm(
                              mode: AppRole.worker,
                              intent: _AuthEntryIntent.signIn,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setMode(AppRole mode) {
    setState(() {
      _selectedMode = mode;
    });
  }

  void _openAuthForm({AppRole? mode, _AuthEntryIntent? intent}) {
    setState(() {
      if (mode != null) {
        _selectedMode = mode;
      }
      if (intent != null) {
        _authIntent = intent;
      }
      _showAuthForm = true;
    });
  }

  void _hideAuthForm() {
    setState(() {
      _showAuthForm = false;
    });
  }

  void _switchToSignIn() {
    setState(() {
      _authIntent = _AuthEntryIntent.signIn;
    });
  }

  void _switchToSignUp() {
    setState(() {
      _authIntent = _AuthEntryIntent.signUp;
    });
  }

  void _togglePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _setRememberSession(bool? value) {
    setState(() {
      _rememberSession = value ?? false;
    });
  }

  Future<void> _submitLogin() async {
    if (_isSubmitting) {
      return;
    }
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final displayName = _authIntent == _AuthEntryIntent.signUp
        ? _nameController.text.trim()
        : null;

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_authIntent == _AuthEntryIntent.signUp) {
        await _authService.createUserWithEmailAndPassword(
          email,
          password,
          fallbackRole: _selectedMode,
          displayName: displayName,
        );
      } else {
        await _authService.signInWithEmailAndPassword(
          email,
          password,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_firebaseAuthMessage(error))),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo iniciar sesion. Intentalo de nuevo.'),
        ),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isSubmitting) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = await _authService.signInWithGoogle(
        fallbackRole: _selectedMode,
      );
      if (!mounted) {
        return;
      }

      if (user == null) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo iniciar sesion con Google')),
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo iniciar sesion con Google')),
      );
    }
  }

  String _firebaseAuthMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'El correo no tiene un formato valido.';
      case 'user-disabled':
        return 'Esta cuenta esta deshabilitada.';
      case 'user-not-found':
        return 'No existe una cuenta con ese correo.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contrasena incorrectos.';
      case 'email-already-in-use':
        return 'Ese correo ya esta registrado. Inicia sesion.';
      case 'weak-password':
        return 'La contrasena es demasiado debil.';
      case 'network-request-failed':
        return 'No hay conexion. Revisa tu internet e intentalo de nuevo.';
      default:
        return error.message ?? 'No se pudo autenticar la cuenta.';
    }
  }
}

class _LoginShowcase extends StatelessWidget {
  const _LoginShowcase({required this.mode, this.compact = false});

  final AppRole mode;
  final bool compact;

  bool get isClient => mode == AppRole.client;

  @override
  Widget build(BuildContext context) {
    final isLight = LavifyTheme.isLight(context);

    final metrics = isClient
        ? const [
            _MetricData(
              '< 30 min',
              'Tiempo promedio de llegada',
              Icons.schedule_rounded,
            ),
            _MetricData(
              '4.9/5',
              'Calificacion de la experiencia',
              Icons.star_rounded,
            ),
            _MetricData(
              '365 dias',
              'Cobertura en zonas activas',
              Icons.pin_drop_rounded,
            ),
          ]
        : const [
            _MetricData(
              '12 min',
              'Promedio para aceptar un servicio',
              Icons.timer_outlined,
            ),
            _MetricData('4.9', 'Calificacion promedio', Icons.star_rounded),
            _MetricData(
              '24/7',
              'Panel disponible',
              Icons.monitor_heart_rounded,
            ),
          ];

    final benefits = isClient
        ? const [
            _BenefitData(
              Icons.flash_on_rounded,
              'Reserva en minutos',
              'Repite un pedido con tus preferencias guardadas.',
            ),
            _BenefitData(
              Icons.route_rounded,
              'Seguimiento en vivo',
              'Ubica a tu lavador y recibe confirmaciones claras.',
            ),
            _BenefitData(
              Icons.workspace_premium_rounded,
              'Equipo verificado',
              'Perfiles revisados y procesos estandarizados.',
            ),
          ]
        : const [
            _BenefitData(
              Icons.route_rounded,
              'Rutas mas claras',
              'Consulta zonas, servicios y tiempos desde un solo panel.',
            ),
            _BenefitData(
              Icons.local_car_wash_rounded,
              'Servicios organizados',
              'Visualiza pendientes, en camino y completados.',
            ),
            _BenefitData(
              Icons.payments_rounded,
              'Seguimiento diario',
              'Ten visibilidad sobre actividad e ingresos del dia.',
            ),
          ];

    return Container(
      padding: EdgeInsets.all(compact ? 24 : 34),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: LavifyTheme.borderColor(context)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? const [Color(0xFFFFFFFF), Color(0xFFF6F8FC)]
              : const [Color(0xE3131E32), Color(0xD810223F)],
        ),
        boxShadow: LavifyTheme.panelShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isClient
                  ? const Color(0x1428D17C)
                  : const Color(0x14FFC857),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isClient
                    ? const Color(0x2B28D17C)
                    : const Color(0x35FFC857),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  size: 16,
                  color: isClient
                      ? LavifyColors.success
                      : const Color(0xFFFFC857),
                ),
                const SizedBox(width: 8),
                Text(
                  isClient
                      ? 'Acceso seguro para clientes verificados'
                      : 'Acceso operativo para lavadores verificados',
                  style: TextStyle(
                    color: LavifyTheme.textPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: compact ? 22 : 30),
          Text(
            isClient
                ? 'Tu auto limpio sin romper tu rutina.'
                : 'Organiza tus servicios desde una sola cabina.',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: compact ? 38 : 56,
              height: 0.95,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isClient
                ? 'Inicia sesion para pedir lavados, seguir tus pedidos y guardar direcciones frecuentes.'
                : 'Inicia sesion como trabajador para revisar rutas, aceptar servicios y llevar control de tu jornada.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (compact) ...[
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: metrics
                  .take(2)
                  .map(
                    (metric) => _CompactMetricChip(
                      value: metric.value,
                      label: metric.label,
                      icon: metric.icon,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LavifyTheme.softFillStrongColor(context),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: LavifyTheme.borderColor(context)),
              ),
              child: Column(
                children: benefits
                    .take(2)
                    .map(
                      (benefit) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _BenefitRow(
                          icon: benefit.icon,
                          title: benefit.title,
                          subtitle: benefit.subtitle,
                          compact: true,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ] else ...[
            const SizedBox(height: 34),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: metrics
                  .map(
                    (metric) => _MetricCard(
                      value: metric.value,
                      label: metric.label,
                      icon: metric.icon,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: LavifyTheme.softFillStrongColor(context),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: LavifyTheme.borderColor(context)),
              ),
              child: Column(
                children: benefits
                    .map(
                      (benefit) => Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _BenefitRow(
                          icon: benefit.icon,
                          title: benefit.title,
                          subtitle: benefit.subtitle,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.selectedMode,
    required this.authIntent,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberSession,
    required this.isSubmitting,
    required this.onModeChanged,
    required this.onTogglePassword,
    required this.onRememberChanged,
    required this.onLogin,
    required this.onGoogleLogin,
    required this.onBack,
    required this.onSwitchToSignIn,
    required this.onSwitchToSignUp,
  });

  final GlobalKey<FormState> formKey;
  final AppRole selectedMode;
  final _AuthEntryIntent authIntent;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberSession;
  final bool isSubmitting;
  final ValueChanged<AppRole> onModeChanged;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onLogin;
  final Future<void> Function() onGoogleLogin;
  final VoidCallback onBack;
  final VoidCallback onSwitchToSignIn;
  final VoidCallback onSwitchToSignUp;

  bool get isClient => selectedMode == AppRole.client;
  bool get isSignUp => authIntent == _AuthEntryIntent.signUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: LavifyTheme.overlayPanelColor(context),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: LavifyTheme.borderColor(context)),
        boxShadow: LavifyTheme.panelShadow(context),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: isSubmitting ? null : onBack,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Volver'),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
            ),
            const SizedBox(height: 10),
            Text(
              isSignUp ? 'Crea tu cuenta gratis' : 'Inicia sesion',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: LavifyTheme.textPrimaryColor(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _RoleSelector(
              selectedMode: selectedMode,
              onModeChanged: isSubmitting ? (_) {} : onModeChanged,
            ),
            const SizedBox(height: 24),
            Text(
              isSignUp
                  ? isClient
                        ? 'Nueva cuenta de cliente'
                        : 'Nueva cuenta de trabajador'
                  : isClient
                  ? 'Cliente Lavify'
                  : 'Trabajador Lavify',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              isSignUp
                  ? isClient
                        ? 'Crea tu acceso para pedir lavados y seguir tus servicios desde un solo lugar.'
                        : 'Crea tu acceso operativo para aceptar servicios y gestionar tu jornada.'
                  : isClient
                  ? 'Entra a tu cuenta para pedir y seguir servicios.'
                  : 'Entra a tu panel operativo de Lavify.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (isSignUp) ...[
              const SizedBox(height: 24),
              Text(
                'Nombre',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: LavifyTheme.textPrimaryColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: LavifyTheme.textPrimaryColor(context),
                ),
                decoration: _inputDecoration(
                  context: context,
                  hint: isClient ? 'Ej. Andrea Lopez' : 'Ej. Carlos Mendez',
                  prefixIcon: Icons.person_outline_rounded,
                ),
                validator: (value) {
                  if (!isSignUp) {
                    return null;
                  }

                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Ingresa tu nombre.';
                  }
                  if (text.length < 2) {
                    return 'Escribe un nombre valido.';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Correo',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: LavifyTheme.textPrimaryColor(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: LavifyTheme.textPrimaryColor(context),
              ),
              decoration: _inputDecoration(
                context: context,
                hint: isClient ? 'cliente@lavify.app' : 'lavador@lavify.app',
                prefixIcon: Icons.mail_outline_rounded,
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) {
                  return 'Ingresa tu correo.';
                }
                if (!text.contains('@') || !text.contains('.')) {
                  return 'Escribe un correo valido.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Contrasena',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: LavifyTheme.textPrimaryColor(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: LavifyTheme.textPrimaryColor(context),
              ),
              decoration: _inputDecoration(
                context: context,
                hint: 'Escribe tu contrasena',
                prefixIcon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  onPressed: isSubmitting ? null : onTogglePassword,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: LavifyTheme.textSecondaryColor(context),
                  ),
                ),
              ),
              validator: (value) {
                if ((value ?? '').trim().length < 6) {
                  return 'Usa al menos 6 caracteres.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: rememberSession,
                        onChanged: isSubmitting ? null : onRememberChanged,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          isSignUp
                              ? 'Recordar mi cuenta en este dispositivo'
                              : 'Mantener sesion iniciada',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: LavifyTheme.softFillStrongColor(context),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: LavifyTheme.borderColor(context)),
                  ),
                  child: Text(
                    isClient ? 'Cliente' : 'Trabajador',
                    style: TextStyle(
                      color: isClient
                          ? LavifyColors.primary
                          : const Color(0xFFFFC857),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              label: isSubmitting
                  ? isSignUp
                        ? 'Creando cuenta...'
                        : 'Verificando...'
                  : isSignUp
                  ? isClient
                        ? 'Crear cuenta como cliente'
                        : 'Crear cuenta como trabajador'
                  : isClient
                  ? 'Entrar como cliente'
                  : 'Entrar como trabajador',
              icon: isSubmitting
                  ? Icons.hourglass_top_rounded
                  : Icons.login_rounded,
              isExpanded: true,
              onPressed: isSubmitting ? null : onLogin,
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: isSubmitting ? null : () => onGoogleLogin(),
              icon: const Text(
                'G',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              label: Text(isSignUp ? 'Registrarme con Google' : 'Google'),
            ),
            const SizedBox(height: 18),
            Center(
              child: Wrap(
                spacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    isSignUp
                        ? 'Ya tienes cuenta?'
                        : isClient
                        ? 'Quieres trabajar con Lavify?'
                        : 'Necesitas lavar tu carro ?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: isSubmitting ? null : () {
                      if (isSignUp) {
                        onSwitchToSignIn();
                        return;
                      }

                      onModeChanged(isClient ? AppRole.worker : AppRole.client);
                    },
                    child: Text(
                      isSignUp
                          ? 'Iniciar sesion'
                          : isClient
                          ? 'Cambiar a trabajador'
                          : 'Cambiar a cliente',
                    ),
                  ),
                ],
              ),
            ),
            if (!isSignUp && !isClient) ...[
              Center(
                child: Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Eres nuevo trabajador?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: isSubmitting ? null : onSwitchToSignUp,
                      child: const Text('Crear cuenta de trabajador'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EntryLanding extends StatelessWidget {
  const _EntryLanding({
    required this.onCreateAccount,
    required this.onSignIn,
    required this.onWorkerAccess,
  });

  final VoidCallback onCreateAccount;
  final VoidCallback onSignIn;
  final VoidCallback onWorkerAccess;

  @override
  Widget build(BuildContext context) {
    final isLight = LavifyTheme.isLight(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 980;

    final heroCard = Container(
      padding: EdgeInsets.all(isDesktop ? 36 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isDesktop ? 38 : 32),
        border: Border.all(color: LavifyTheme.borderColor(context)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? const [Color(0xFFFFFFFF), Color(0xFFF7F9FD)]
              : const [Color(0xE3131E32), Color(0xD810223F)],
        ),
        boxShadow: LavifyTheme.panelShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [LavifyColors.primaryStrong, LavifyColors.primary],
                  ),
                  boxShadow: LavifyTheme.panelShadow(context, floating: false),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Lavify',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: LavifyTheme.softFillStrongColor(context),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: LavifyTheme.borderColor(context)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  size: 16,
                  color: LavifyColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Reserva lavados en minutos',
                  style: TextStyle(
                    color: LavifyTheme.textPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Text(
            'Tu auto limpio,\n'
            'tu tiempo intacto.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: isDesktop ? 64 : 46,
              height: 0.96,
            ),
          ),
          const SizedBox(height: 14),
          ShaderMask(
            shaderCallback: (bounds) {
              return const LinearGradient(
                colors: [LavifyColors.primaryStrong, LavifyColors.primary],
              ).createShader(bounds);
            },
            child: Text(
              'Pide tu lavado desde donde estes',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontSize: isDesktop ? 42 : 34,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 22),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              'Lavify centraliza tu solicitud, seguimiento y servicio en una sola experiencia. '
              'Olvidate de coordinar por mensajes y crea tu cuenta gratis para pedir tu primer lavado.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.55,
                fontSize: isDesktop ? 24 : 20,
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Crear cuenta gratis',
              icon: Icons.arrow_forward_rounded,
              onPressed: onCreateAccount,
              isExpanded: true,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              Text(
                'Ya tienes cuenta?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: onSignIn,
                child: const Text('Iniciar sesion'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onWorkerAccess,
            icon: const Icon(Icons.local_car_wash_rounded, size: 18),
            label: const Text('Acceso para trabajadores'),
          ),
        ],
      ),
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 11, child: heroCard),
          const SizedBox(width: 24),
          const Expanded(flex: 9, child: _EntryHighlights()),
        ],
      );
    }

    return Column(
      children: [
        heroCard,
        const SizedBox(height: 16),
        const _EntryHighlights(compact: true),
      ],
    );
  }
}

class _EntryHighlights extends StatelessWidget {
  const _EntryHighlights({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final items = const [
      _EntryHighlightData(
        icon: Icons.schedule_rounded,
        title: 'Reservas simples',
        subtitle:
            'Elige paquete, confirma ubicacion y agenda sin complicaciones.',
      ),
      _EntryHighlightData(
        icon: Icons.route_rounded,
        title: 'Seguimiento en vivo',
        subtitle: 'Visualiza cuando va el lavador y como avanza tu servicio.',
      ),
      _EntryHighlightData(
        icon: Icons.verified_user_rounded,
        title: 'Lavadores verificados',
        subtitle: 'Perfiles cuidados para una experiencia mas confiable.',
      ),
    ];

    return Container(
      padding: EdgeInsets.all(compact ? 18 : 24),
      decoration: BoxDecoration(
        color: LavifyTheme.overlayPanelColor(context),
        borderRadius: BorderRadius.circular(compact ? 26 : 32),
        border: Border.all(color: LavifyTheme.borderColor(context)),
        boxShadow: LavifyTheme.panelShadow(context, floating: false),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Todo listo para empezar',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0x1A22C1FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(item.icon, color: LavifyColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: LavifyTheme.textPrimaryColor(context),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryHighlightData {
  const _EntryHighlightData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({
    required this.selectedMode,
    required this.onModeChanged,
  });

  final AppRole selectedMode;
  final ValueChanged<AppRole> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: LavifyTheme.softFillStrongColor(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RoleChip(
              label: 'Cliente',
              icon: Icons.person_rounded,
              selected: selectedMode == AppRole.client,
              onTap: () => onModeChanged(AppRole.client),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _RoleChip(
              label: 'Trabajador',
              icon: Icons.local_car_wash_rounded,
              selected: selectedMode == AppRole.worker,
              onTap: () => onModeChanged(AppRole.worker),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: selected
                ? const LinearGradient(
                    colors: [LavifyColors.primaryStrong, LavifyColors.primary],
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? LavifyColors.textPrimary
                    : LavifyTheme.textSecondaryColor(context),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? LavifyColors.textPrimary
                      : LavifyTheme.textSecondaryColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LavifyTheme.softFillStrongColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: LavifyColors.primary),
          const SizedBox(height: 18),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: compact ? 40 : 44,
          height: compact ? 40 : 44,
          decoration: BoxDecoration(
            color: const Color(0x1A22C1FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: LavifyColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: LavifyTheme.textPrimaryColor(context),
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 16 : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: compact ? 13 : null),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactMetricChip extends StatelessWidget {
  const _CompactMetricChip({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: LavifyTheme.softFillStrongColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: LavifyColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: LavifyTheme.textPrimaryColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: LavifyTheme.textSecondaryColor(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlowBubble extends StatelessWidget {
  const _GlowBubble({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }
}

class _MetricData {
  const _MetricData(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;
}

class _BenefitData {
  const _BenefitData(this.icon, this.title, this.subtitle);

  final IconData icon;
  final String title;
  final String subtitle;
}

InputDecoration _inputDecoration({
  required BuildContext context,
  required String hint,
  required IconData prefixIcon,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: LavifyTheme.textSecondaryColor(context)),
    prefixIcon: Icon(
      prefixIcon,
      color: LavifyTheme.textSecondaryColor(context),
    ),
    suffixIcon: suffix,
    filled: true,
    fillColor: LavifyTheme.surfaceAltColor(context),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: LavifyTheme.borderColor(context)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: LavifyColors.primary),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
    ),
  );
}
