import 'package:flutter/material.dart';

import '../models/session_models.dart';
import '../services/profile_service.dart';
import '../services/session_service.dart';
import '../theme/theme.dart';
import '../widgets/primary_button.dart';
import 'app_shell.dart';

class RoleLoginPage extends StatefulWidget {
  const RoleLoginPage({
    super.key,
    this.initialMode = AppRole.client,
  });

  final AppRole initialMode;

  @override
  State<RoleLoginPage> createState() => _RoleLoginPageState();
}

class _RoleLoginPageState extends State<RoleLoginPage> {
  static final _profileService = ProfileService();
  static final _sessionService = SessionService();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberSession = true;
  late AppRole _selectedMode;

  bool get _isClient => _selectedMode == AppRole.client;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode;
  }

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
                    child: isDesktop
                        ? Row(
                            children: [
                              Expanded(
                                flex: 11,
                                child: _LoginShowcase(mode: _selectedMode),
                              ),
                              const SizedBox(width: 28),
                              Expanded(
                                flex: 9,
                                child: _LoginCard(
                                  formKey: _formKey,
                                  selectedMode: _selectedMode,
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  obscurePassword: _obscurePassword,
                                  rememberSession: _rememberSession,
                                  onModeChanged: _setMode,
                                  onTogglePassword: _togglePassword,
                                  onRememberChanged: _setRememberSession,
                                  onLogin: _submitLogin,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _LoginCard(
                                formKey: _formKey,
                                selectedMode: _selectedMode,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                obscurePassword: _obscurePassword,
                                rememberSession: _rememberSession,
                                onModeChanged: _setMode,
                                onTogglePassword: _togglePassword,
                                onRememberChanged: _setRememberSession,
                                onLogin: _submitLogin,
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

    _profileService.syncLoginIdentity(email: _emailController.text);
    final profile = _profileService.profile.value;
    _sessionService.startSession(
      role: _selectedMode,
      email: profile.email,
      visibleName: profile.name,
      favoriteAddress: profile.favoriteAddress,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => AppShell(mode: _selectedMode)),
    );
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
              ? const [Color(0xFFFFFFFF), Color(0xFFF4F8FC)]
              : const [Color(0xFF0A1528), Color(0xCC102446)],
        ),
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
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberSession,
    required this.onModeChanged,
    required this.onTogglePassword,
    required this.onRememberChanged,
    required this.onLogin,
  });

  final GlobalKey<FormState> formKey;
  final AppRole selectedMode;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberSession;
  final ValueChanged<AppRole> onModeChanged;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onLogin;

  bool get isClient => selectedMode == AppRole.client;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: LavifyTheme.overlayPanelColor(context),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Elige como quieres entrar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: LavifyTheme.textPrimaryColor(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _RoleSelector(
              selectedMode: selectedMode,
              onModeChanged: onModeChanged,
            ),
            const SizedBox(height: 24),
            Text(
              isClient ? 'Cliente Lavify' : 'Trabajador Lavify',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              isClient
                  ? 'Entraras a tu cuenta para pedir y seguir servicios.'
                  : 'Entraras a tu panel operativo de Lavify.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(
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
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(
                color: LavifyTheme.textPrimaryColor(context),
              ),
              decoration: _inputDecoration(
                context: context,
                hint: 'Escribe tu contrasena',
                prefixIcon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  onPressed: onTogglePassword,
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
              label: isClient
                  ? 'Entrar como cliente'
                  : 'Entrar como trabajador',
              icon: Icons.login_rounded,
              isExpanded: true,
              onPressed: onLogin,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Text(
                      'G',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    label: const Text('Google'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.apple_rounded,
                      color: Colors.black54,
                      size: 22,
                    ),
                    label: const Text('Apple'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Center(
              child: Wrap(
                spacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    isClient
                        ? 'Quieres trabajar con Lavify?'
                        : 'Necesitas lavar tu carro ?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => onModeChanged(
                      isClient ? AppRole.worker : AppRole.client,
                    ),
                    child: Text(
                      isClient ? 'Cambiar a trabajador' : 'Cambiar a cliente',
                    ),
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
    prefixIcon: Icon(prefixIcon, color: LavifyTheme.textSecondaryColor(context)),
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
