import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/session_models.dart';
import '../services/auth_service.dart';
import '../theme/theme.dart';


class RoleLoginPage extends StatefulWidget {
  const RoleLoginPage({super.key, this.initialMode = AppRole.client});

  final AppRole initialMode;

  @override
  State<RoleLoginPage> createState() => _RoleLoginPageState();
}

enum _AuthEntryIntent { signUp, signIn }

class _RoleLoginPageState extends State<RoleLoginPage> {
  static final _authService = AuthService();
  static bool _introSeen = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberSession = true;
  bool _showAuthForm = false;
  late bool _showIntro;
  bool _isSubmitting = false;
  _AuthEntryIntent _authIntent = _AuthEntryIntent.signUp;
  late AppRole _selectedMode;

  bool get _isClient => _selectedMode == AppRole.client;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode;
    _showIntro = !_introSeen && widget.initialMode == AppRole.client;
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
              child: _showIntro
                  ? _PreAuthOnboarding(onDone: _finishIntro)
                  : !_showAuthForm
                  ? _EntryLanding(
                      onCreateAccount: () => _openAuthForm(
                        mode: AppRole.client,
                        intent: _AuthEntryIntent.signUp,
                      ),
                      onSignIn: () =>
                          _openAuthForm(intent: _AuthEntryIntent.signIn),
                      onWorkerAccess: () => _openAuthForm(
                        mode: AppRole.worker,
                        intent: _AuthEntryIntent.signUp,
                      ),
                    )
                  : Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 40 : 20,
                          vertical: 24,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1160),
                          child: isDesktop
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
                                        onPasswordReset: _sendPasswordReset,
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
                                      onPasswordReset: _sendPasswordReset,
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
                                ),
                        ),
                      ),
                    ),
            ),
            if (_isSubmitting)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).scaffoldBackgroundColor.withAlpha(220),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: LavifyColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.local_car_wash_rounded,
                            color: LavifyColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 22),
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: LavifyColors.primary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _authIntent == _AuthEntryIntent.signUp
                              ? 'Creando tu cuenta...'
                              : 'Iniciando sesión...',
                          style: TextStyle(
                            color: LavifyTheme.textSecondaryColor(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

  void _finishIntro() {
    setState(() {
      _introSeen = true;
      _showIntro = false;
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
          fallbackRole: _selectedMode,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_firebaseAuthMessage(error))));
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

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe tu correo para recuperar tu contrasena.'),
        ),
      );
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enlace enviado a $email. Revisa tu bandeja.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo enviar el correo. Verifica la direccion.'),
        ),
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
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: LavifyTheme.borderColor(context)),
        color: isLight ? LavifyColors.lightSurface : LavifyColors.backgroundSoft,
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

class _PreAuthOnboarding extends StatefulWidget {
  const _PreAuthOnboarding({required this.onDone});

  final VoidCallback onDone;

  @override
  State<_PreAuthOnboarding> createState() => _PreAuthOnboardingState();
}

class _PreAuthOnboardingState extends State<_PreAuthOnboarding> {
  final PageController _controller = PageController();
  int _index = 0;

  static const _slides = [
    _IntroSlideData(
      icon: Icons.water_drop_rounded,
      title: 'Tu auto limpio,\nsin moverte',
      body:
          'Pide un lavado a domicilio en segundos. Lavadores verificados llegan a donde estes.',
    ),
    _IntroSlideData(
      icon: Icons.location_on_rounded,
      title: 'Mira al lavador\nllegar en vivo',
      body:
          'Sigue su ubicacion en tiempo real y recibe avisos claros de cada paso del servicio.',
    ),
    _IntroSlideData(
      icon: Icons.shield_outlined,
      title: 'Pagos seguros,\nlavados garantizados',
      body:
          'Tarjeta o efectivo, soporte y una experiencia pensada para que todo se sienta simple.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == _slides.length - 1) {
      widget.onDone();
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 980;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF172B4C), Color(0xFF090B10), Color(0xFF07090D)],
          stops: [0.0, 0.36, 1.0],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 520 : double.infinity,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isDesktop ? 64 : 28,
              18,
              isDesktop ? 64 : 28,
              30,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Row(
                      children: List.generate(
                        _slides.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: i == _index ? 28 : 16,
                          height: 3,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: i <= _index
                                ? Colors.white
                                : Colors.white.withAlpha(42),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: widget.onDone,
                      child: Text(
                        'Saltar',
                        style: TextStyle(
                          color: Colors.white.withAlpha(170),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (value) => setState(() => _index = value),
                    itemCount: _slides.length,
                    itemBuilder: (context, i) => _IntroSlide(data: _slides[i]),
                  ),
                ),
                Row(
                  children: [
                    if (_index > 0) ...[
                      _IntroBackButton(
                        onTap: () => _controller.previousPage(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: _SplashActionButton(
                        label: _index == _slides.length - 1
                            ? 'Empezar'
                            : 'Continuar',
                        icon: Icons.arrow_forward_rounded,
                        filled: true,
                        onTap: _next,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroSlide extends StatelessWidget {
  const _IntroSlide({required this.data});

  final _IntroSlideData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: LavifyColors.primary,
                borderRadius: BorderRadius.circular(34),
              ),
              child: Icon(data.icon, color: Colors.white, size: 70),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            data.title,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              height: 1.05,
              letterSpacing: -1.4,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            data.body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withAlpha(185),
              fontSize: 15,
              height: 1.55,
            ),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _IntroBackButton extends StatelessWidget {
  const _IntroBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1C24),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withAlpha(22)),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
    );
  }
}

class _IntroSlideData {
  const _IntroSlideData({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
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
    required this.onPasswordReset,
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
  final Future<void> Function() onPasswordReset;
  final VoidCallback onBack;
  final VoidCallback onSwitchToSignIn;
  final VoidCallback onSwitchToSignUp;

  bool get isClient => selectedMode == AppRole.client;
  bool get isSignUp => authIntent == _AuthEntryIntent.signUp;

  @override
  Widget build(BuildContext context) {
    final isLight = LavifyTheme.isLight(context);
    final textSecondary = LavifyTheme.textSecondaryColor(context);
    final textPrimary = LavifyTheme.textPrimaryColor(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : LavifyColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LavifyTheme.borderColor(context)),
        boxShadow: LavifyTheme.panelShadow(context),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back link — small, unobtrusive
            GestureDetector(
              onTap: isSubmitting ? null : onBack,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    size: 15,
                    color: textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Volver',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            // Title
            Text(
              isSignUp ? 'Crear cuenta' : 'Iniciar sesión',
              style: TextStyle(
                color: textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              isSignUp
                  ? isClient
                        ? 'Para tu primer lavado a domicilio'
                        : 'Acceso al panel de lavadores'
                  : isClient
                  ? 'Tu auto impecable, sin moverte'
                  : 'Panel de lavadores profesionales',
              style: TextStyle(color: textSecondary, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 20),
            _RoleSelector(
              selectedMode: selectedMode,
              onModeChanged: isSubmitting ? (_) {} : onModeChanged,
            ),
            if (isSignUp) ...[
              const SizedBox(height: 14),
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: _inputDecoration(
                  context: context,
                  hint: isClient ? 'Nombre completo' : 'Tu nombre completo',
                  prefixIcon: Icons.person_outline_rounded,
                ),
                validator: (value) {
                  if (!isSignUp) return null;
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Ingresa tu nombre.';
                  if (text.length < 2) return 'Escribe un nombre valido.';
                  return null;
                },
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: _inputDecoration(
                context: context,
                hint: 'Correo electrónico',
                prefixIcon: Icons.mail_outline_rounded,
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Ingresa tu correo.';
                if (!text.contains('@') || !text.contains('.')) {
                  return 'Correo no válido.';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              style: TextStyle(
                color: textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: _inputDecoration(
                context: context,
                hint: 'Contraseña',
                prefixIcon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  onPressed: isSubmitting ? null : onTogglePassword,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: textSecondary,
                    size: 20,
                  ),
                ),
              ),
              validator: (value) {
                if ((value ?? '').trim().length < 6) {
                  return 'Mínimo 6 caracteres.';
                }
                return null;
              },
            ),
            if (!isSignUp) ...[
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isSubmitting ? null : () => onPasswordReset(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            // Primary action button — uses theme ElevatedButton (white/dark)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : onLogin,
                child: isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isLight
                                  ? Colors.white
                                  : LavifyColors.background,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isSignUp ? 'Creando cuenta...' : 'Verificando...',
                          ),
                        ],
                      )
                    : Text(
                        isSignUp
                            ? isClient
                                  ? 'Crear cuenta'
                                  : 'Registrarme como lavador'
                            : 'Entrar',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Divider(color: LavifyTheme.borderColor(context)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'o',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(color: LavifyTheme.borderColor(context)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: isSubmitting ? null : () => onGoogleLogin(),
                icon: const Text(
                  'G',
                  style: TextStyle(
                    color: Color(0xFF4285F4),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                label: const Text('Continuar con Google'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isLight
                      ? LavifyColors.lightSurface
                      : LavifyColors.surfaceAlt,
                  side: BorderSide(color: LavifyTheme.borderColor(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  foregroundColor: textPrimary,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Single clean footer link
            Center(
              child: GestureDetector(
                onTap: isSubmitting
                    ? null
                    : () => isSignUp ? onSwitchToSignIn() : onSwitchToSignUp(),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 13, color: textSecondary),
                    text: isSignUp
                        ? '¿Ya tienes cuenta?  '
                        : '¿No tienes cuenta?  ',
                    children: [
                      TextSpan(
                        text: isSignUp ? 'Iniciar sesión' : 'Registrarse',
                        style: TextStyle(
                          color: LavifyColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 980;
    final isLight = LavifyTheme.isLight(context);

    final splash = Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isLight
              ? const [Color(0xFFD6E9FF), Color(0xFFEEF5FF), Color(0xFFF8FAFF)]
              : const [Color(0xFF172B4C), Color(0xFF090B10), Color(0xFF07090D)],
          stops: const [0.0, 0.28, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              isDesktop ? 64 : 58,
              isDesktop ? 86 : 64,
              isDesktop ? 64 : 42,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: LavifyColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: LavifyColors.primary.withAlpha(48),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.water_drop_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Tu auto\nimpecable.',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: isLight ? const Color(0xFF0A0B0F) : Colors.white,
                    fontSize: isDesktop ? 56 : 52,
                    fontWeight: FontWeight.w800,
                    height: 0.96,
                    letterSpacing: -2,
                  ),
                ),
                Text(
                  'Sin moverte.',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: LavifyColors.primary,
                    fontSize: isDesktop ? 56 : 52,
                    fontWeight: FontWeight.w800,
                    height: 0.96,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Lavado a domicilio profesional. Pide, sigue en vivo, paga seguro.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isLight
                        ? LavifyColors.lightTextSecondary
                        : Colors.white.withAlpha(205),
                    fontSize: 20,
                    height: 1.45,
                  ),
                ),
                const Expanded(child: SizedBox()),
                _SplashActionButton(
                  label: 'Crear cuenta gratis',
                  icon: Icons.arrow_forward_rounded,
                  filled: true,
                  onTap: onCreateAccount,
                ),
                const SizedBox(height: 12),
                _SplashActionButton(
                  label: 'Ya tengo cuenta',
                  icon: Icons.login_rounded,
                  onTap: onSignIn,
                ),
                const SizedBox(height: 18),
                Center(
                  child: TextButton(
                    onPressed: onWorkerAccess,
                    child: Text.rich(
                      TextSpan(
                        text: 'Soy lavador · ',
                        children: [
                          TextSpan(
                            text: 'Acceder',
                            style: TextStyle(
                              color: LavifyColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        color: LavifyTheme.textSecondaryColor(context),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isDesktop) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: splash,
        ),
      );
    }

    return splash;
  }
}

class _SplashActionButton extends StatelessWidget {
  const _SplashActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final foreground = filled
        ? (LavifyTheme.isLight(context)
              ? Colors.white
              : const Color(0xFF0A0B0F))
        : LavifyTheme.textPrimaryColor(context);
    final background = filled
        ? LavifyTheme.textPrimaryColor(context)
        : LavifyTheme.surfaceColor(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: filled
                ? null
                : Border.all(color: LavifyTheme.borderColor(context)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 18, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
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
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: LavifyTheme.surfaceAltColor(context),
        borderRadius: BorderRadius.circular(18),
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
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: selected ? LavifyColors.primary : Colors.transparent,
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
            color: LavifyColors.primarySoft,
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
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: LavifyTheme.borderColor(context)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: LavifyColors.primary),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
    ),
  );
}
