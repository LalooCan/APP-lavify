import 'package:flutter/material.dart';

import '../services/profile_service.dart';
import '../theme/theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import 'app_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static final _profileService = ProfileService();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberSession = true;

  @override
  void dispose() {
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF06101D), Color(0xFF0D203D), Color(0xFF09111F)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -120,
              right: -60,
              child: _GlowBubble(size: 280, color: Color(0x1F22C1FF)),
            ),
            const Positioned(
              bottom: -90,
              left: -40,
              child: _GlowBubble(size: 240, color: Color(0x1628D17C)),
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
                    child: isDesktop
                        ? Row(
                            children: [
                              const Expanded(flex: 11, child: _LoginShowcase()),
                              const SizedBox(width: 28),
                              Expanded(
                                flex: 9,
                                child: _LoginCard(
                                  formKey: _formKey,
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  obscurePassword: _obscurePassword,
                                  rememberSession: _rememberSession,
                                  onTogglePassword: _togglePassword,
                                  onRememberChanged: _setRememberSession,
                                  onLogin: _submitLogin,
                                  onGuestAccess: _openApp,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              const _LoginShowcase(compact: true),
                              const SizedBox(height: 20),
                              _LoginCard(
                                formKey: _formKey,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                obscurePassword: _obscurePassword,
                                rememberSession: _rememberSession,
                                onTogglePassword: _togglePassword,
                                onRememberChanged: _setRememberSession,
                                onLogin: _submitLogin,
                                onGuestAccess: _openApp,
                              ),
                            ],
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

  void _submitLogin() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _profileService.syncLoginEmail(_emailController.text);
    _openApp();
  }

  void _openApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const AppShell(mode: AppMode.client),
      ),
    );
  }
}

class _LoginShowcase extends StatelessWidget {
  const _LoginShowcase({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 24 : 34),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: const Color(0xFF1B3357)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A1528), Color(0xCC102446)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0x1428D17C),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0x2B28D17C)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  size: 16,
                  color: LavifyColors.success,
                ),
                SizedBox(width: 8),
                Text(
                  'Acceso seguro para clientes verificados',
                  style: TextStyle(
                    color: LavifyColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: compact ? 22 : 30),
          Text(
            'Tu auto limpio sin romper tu rutina.',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: compact ? 38 : 56,
              height: 0.95,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              'Inicia sesion para pedir lavados, seguir tus pedidos y guardar direcciones frecuentes desde una sola cuenta.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: LavifyColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: compact ? 24 : 34),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: const [
              _MetricCard(
                value: '< 30 min',
                label: 'Tiempo promedio de llegada',
                icon: Icons.schedule_rounded,
              ),
              _MetricCard(
                value: '4.9/5',
                label: 'Calificacion de la experiencia',
                icon: Icons.star_rounded,
              ),
              _MetricCard(
                value: '365 dias',
                label: 'Cobertura en zonas activas',
                icon: Icons.pin_drop_rounded,
              ),
            ],
          ),
          SizedBox(height: compact ? 24 : 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(6),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: LavifyColors.border),
            ),
            child: Column(
              children: const [
                _BenefitRow(
                  icon: Icons.flash_on_rounded,
                  title: 'Reserva en minutos',
                  subtitle: 'Repite un pedido con tus preferencias guardadas.',
                ),
                SizedBox(height: 18),
                _BenefitRow(
                  icon: Icons.route_rounded,
                  title: 'Seguimiento en vivo',
                  subtitle:
                      'Ubica a tu lavador y recibe confirmaciones claras.',
                ),
                SizedBox(height: 18),
                _BenefitRow(
                  icon: Icons.workspace_premium_rounded,
                  title: 'Equipo verificado',
                  subtitle: 'Perfiles revisados y procesos estandarizados.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberSession,
    required this.onTogglePassword,
    required this.onRememberChanged,
    required this.onLogin,
    required this.onGuestAccess,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberSession;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onLogin;
  final VoidCallback onGuestAccess;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xDD101C31),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: LavifyColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [
                        LavifyColors.primaryStrong,
                        LavifyColors.primary,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.water_drop_rounded,
                    color: LavifyColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenido a Lavify',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Accede a tu cuenta para continuar.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Correo',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: LavifyColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: LavifyColors.textPrimary),
              decoration: _inputDecoration(
                hint: 'cliente@lavify.app',
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Contrasena',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: LavifyColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Olvide mi contrasena'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: LavifyColors.textPrimary),
              decoration: _inputDecoration(
                hint: 'Escribe tu contrasena',
                prefixIcon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  onPressed: onTogglePassword,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: LavifyColors.textSecondary,
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
                        onChanged: onRememberChanged,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Mantener sesion iniciada',
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
                    color: Colors.white.withAlpha(6),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: LavifyColors.border),
                  ),
                  child: const Text(
                    'Demo UI',
                    style: TextStyle(
                      color: LavifyColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              label: 'Entrar a mi cuenta',
              icon: Icons.login_rounded,
              isExpanded: true,
              onPressed: onLogin,
            ),
            const SizedBox(height: 14),
            SecondaryButton(
              label: 'Entrar como invitado',
              icon: Icons.arrow_forward_rounded,
              isExpanded: true,
              onPressed: onGuestAccess,
            ),
            const SizedBox(height: 24),
            Row(
              children: const [
                Expanded(child: Divider(color: LavifyColors.border)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'o continua con',
                    style: TextStyle(color: LavifyColors.textSecondary),
                  ),
                ),
                Expanded(child: Divider(color: LavifyColors.border)),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: const [
                Expanded(
                  child: _ProviderButton(
                    label: 'Google',
                    logo: _GoogleLogo(),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _ProviderButton(
                    label: 'Apple',
                    logo: Icon(Icons.apple_rounded, size: 24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  Text(
                    'Aun no tienes cuenta?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Crear cuenta'),
                  ),
                ],
              ),
            ),
          ],
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
        color: Colors.white.withAlpha(6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LavifyColors.border),
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
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
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
                  color: LavifyColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({required this.label, required this.logo});

  final String label;
  final Widget logo;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: logo,
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        foregroundColor: LavifyColors.textPrimary,
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        color: LavifyColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 1,
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

InputDecoration _inputDecoration({
  required String hint,
  required IconData prefixIcon,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: LavifyColors.textSecondary),
    prefixIcon: Icon(prefixIcon, color: LavifyColors.textSecondary),
    suffixIcon: suffix,
    filled: true,
    fillColor: LavifyColors.surfaceAlt,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: LavifyColors.border),
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
