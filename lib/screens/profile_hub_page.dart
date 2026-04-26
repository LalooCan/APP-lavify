import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/wash_models.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/review_service.dart';
import '../services/session_service.dart';
import '../services/theme_service.dart';
import '../services/worker_service.dart';
import '../theme/theme.dart';
import 'role_login_page.dart';

class ProfileHubPage extends StatefulWidget {
  const ProfileHubPage({super.key, required this.mode});

  final AppRole mode;

  @override
  State<ProfileHubPage> createState() => _ProfileHubPageState();
}

class _ProfileHubPageState extends State<ProfileHubPage> {
  static final _profileService = ProfileService();
  static final _sessionService = SessionService();
  static final _themeService = ThemeService();
  static final _authService = AuthService();
  static final _workerService = WorkerService();
  static final _reviewService = ReviewService();

  AppRole get mode => widget.mode;

  double _totalEarnings = 0;
  int _completedCount = 0;
  double _averageRating = 0;

  @override
  void initState() {
    super.initState();
    _profileService.ensureFavoriteAddressResolved();
    if (mode == AppRole.worker) {
      _workerService.watchEarnings().listen((data) {
        if (!mounted) return;
        setState(() {
          _totalEarnings =
              (data['totalEarnings'] as num?)?.toDouble() ?? 0;
          _completedCount =
              (data['completedServicesCount'] as num?)?.toInt() ?? 0;
        });
      });
      _reviewService
          .getWorkerAverageRating(
            FirebaseAuth.instance.currentUser?.uid ?? '',
          )
          .then((avg) {
            if (!mounted) return;
            setState(() => _averageRating = avg);
          });
    }
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final email =
        _profileService.profile.value.email.trim();
    if (email.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        content: Text(
          'Se enviará un enlace de restablecimiento a\n$email',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Enviar enlace'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await _authService.sendPasswordResetEmail(email);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enlace enviado a $email')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo enviar el correo.'),
        ),
      );
    }
  }

  List<_ProfileStat> _buildStats(UserProfile profile) {
    if (mode == AppRole.worker) {
      final ratingLabel = _averageRating > 0
          ? _averageRating.toStringAsFixed(1)
          : '—';
      final earningsLabel = _totalEarnings > 0
          ? '\$${_totalEarnings.toStringAsFixed(0)}'
          : '\$0';
      return [
        _ProfileStat(value: '$_completedCount', label: 'Lavados'),
        _ProfileStat(
            value: earningsLabel, label: 'Ganancias', highlight: true),
        _ProfileStat(value: ratingLabel, label: 'Rating'),
      ];
    }
    final clientOrders = _completedCount;
    return [
      _ProfileStat(value: '$clientOrders', label: 'Lavados'),
      _ProfileStat(
          value: '\$${_totalEarnings.toStringAsFixed(0)}',
          label: 'Total',
          highlight: true),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Scaffold(
      backgroundColor: _profileBackgroundColor(context),
      body: DecoratedBox(
        decoration: LavifyTheme.pageDecoration(context),
        child: SafeArea(
          child: ValueListenableBuilder<UserProfile>(
            valueListenable: _profileService.profile,
            builder: (context, profile, _) {
              final stats = _buildStats(profile);
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 32 : 20,
                  isDesktop ? 20 : 16,
                  isDesktop ? 32 : 20,
                  120,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 980 : 420,
                    ),
                    child: isDesktop
                        ? _DesktopProfileLayout(
                            profile: profile,
                            stats: stats,
                            mode: mode,
                            isLightMode: _themeService.isLightMode,
                            onEditProfile: () =>
                                _showEditProfileDialog(context, profile),
                            onEditVehicle: () => _showSingleFieldDialog(
                              context,
                              title: 'Vehiculo principal',
                              label: 'Vehiculo principal',
                              initialValue: profile.vehicleLabel,
                              onSave: (value) {
                                _profileService.updateProfile(
                                  profile.copyWith(vehicleLabel: value),
                                );
                              },
                            ),
                            onEditAddress: () => _showSingleFieldDialog(
                              context,
                              title: 'Direccion favorita',
                              label: 'Direccion favorita',
                              initialValue: profile.favoriteAddress,
                              onSave: (value) {
                                _profileService.updateProfile(
                                  profile.copyWith(favoriteAddress: value),
                                );
                              },
                            ),
                            onEditPayment: () => _showSingleFieldDialog(
                              context,
                              title: 'Metodo de pago',
                              label: 'Metodo de pago',
                              initialValue: profile.paymentMethod,
                              onSave: (value) {
                                _profileService.updateProfile(
                                  profile.copyWith(paymentMethod: value),
                                );
                              },
                            ),
                            onChangePassword: () =>
                                _showChangePasswordDialog(context),
                            onToggleTheme: _themeService.toggleBrightness,
                            onLogout: () => _handleLogout(context),
                          )
                        : _MobileProfileLayout(
                            profile: profile,
                            stats: stats,
                            mode: mode,
                            isLightMode: _themeService.isLightMode,
                            onEditProfile: () =>
                                _showEditProfileDialog(context, profile),
                            onEditVehicle: () => _showSingleFieldDialog(
                              context,
                              title: 'Vehiculo principal',
                              label: 'Vehiculo principal',
                              initialValue: profile.vehicleLabel,
                              onSave: (value) {
                                _profileService.updateProfile(
                                  profile.copyWith(vehicleLabel: value),
                                );
                              },
                            ),
                            onEditAddress: () => _showSingleFieldDialog(
                              context,
                              title: 'Direccion favorita',
                              label: 'Direccion favorita',
                              initialValue: profile.favoriteAddress,
                              onSave: (value) {
                                _profileService.updateProfile(
                                  profile.copyWith(favoriteAddress: value),
                                );
                              },
                            ),
                            onEditPayment: () => _showSingleFieldDialog(
                              context,
                              title: 'Metodo de pago',
                              label: 'Metodo de pago',
                              initialValue: profile.paymentMethod,
                              onSave: (value) {
                                _profileService.updateProfile(
                                  profile.copyWith(paymentMethod: value),
                                );
                              },
                            ),
                            onChangePassword: () =>
                                _showChangePasswordDialog(context),
                            onToggleTheme: _themeService.toggleBrightness,
                            onLogout: () => _handleLogout(context),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showEditProfileDialog(
    BuildContext context,
    UserProfile profile,
  ) async {
    final nameController = TextEditingController(text: profile.name);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _profileSurfaceColor(context),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: _profileBorderColor(context)),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          title: Text(
            'Editar perfil',
            style: TextStyle(
              color: _profileTextPrimaryColor(context),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ProfileField(
                    controller: nameController,
                    label: 'Nombre de usuario',
                  ),
                  const SizedBox(height: 12),
                  _ReadOnlyProfileField(
                    label: 'Correo vinculado',
                    value: profile.email,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'El correo se toma del login. El nombre de usuario si lo eliges tu.',
                    style: TextStyle(
                      color: _profileTextSecondaryColor(context),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: _profileAccentColor(context),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _profileAccentColor(context),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              onPressed: () {
                final nextName = nameController.text.trim();
                _profileService.updateProfile(
                  profile.copyWith(
                    name: nextName.isEmpty ? 'Elige tu nombre' : nextName,
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSingleFieldDialog(
    BuildContext context, {
    required String title,
    required String label,
    required String initialValue,
    required ValueChanged<String> onSave,
  }) async {
    final controller = TextEditingController(text: initialValue);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _profileSurfaceColor(dialogContext),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: _profileBorderColor(dialogContext)),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          title: Text(
            title,
            style: TextStyle(
              color: _profileTextPrimaryColor(dialogContext),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: SizedBox(
            width: 420,
            child: _ProfileField(controller: controller, label: label),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor: _profileAccentColor(dialogContext),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _profileAccentColor(dialogContext),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              onPressed: () {
                onSave(controller.text.trim());
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _profileSurfaceColor(dialogContext),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: _profileBorderColor(dialogContext)),
          ),
          title: Text(
            'Cerrar sesion',
            style: TextStyle(
              color: _profileTextPrimaryColor(dialogContext),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Vas a salir de tu cuenta actual y regresar a la pantalla de login.',
            style: TextStyle(
              color: _profileTextSecondaryColor(dialogContext),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: _profileAccentColor(dialogContext),
              ),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDB5C5C),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) {
      return;
    }

    await _authService.signOut();
    _sessionService.clearSession();
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => RoleLoginPage(initialMode: mode)),
      (route) => false,
    );
  }
}

class _MobileProfileLayout extends StatelessWidget {
  const _MobileProfileLayout({
    required this.profile,
    required this.stats,
    required this.mode,
    required this.isLightMode,
    required this.onEditProfile,
    required this.onEditVehicle,
    required this.onEditAddress,
    required this.onEditPayment,
    required this.onChangePassword,
    required this.onToggleTheme,
    required this.onLogout,
  });

  final UserProfile profile;
  final List<_ProfileStat> stats;
  final AppRole mode;
  final bool isLightMode;
  final VoidCallback onEditProfile;
  final VoidCallback onEditVehicle;
  final VoidCallback onEditAddress;
  final VoidCallback onEditPayment;
  final VoidCallback onChangePassword;
  final ValueChanged<bool> onToggleTheme;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final accountItems = [
      _ProfileMenuItem(
        icon: Icons.person_outline_rounded,
        title: 'Informacion personal',
        value: 'Editar',
        onTap: onEditProfile,
      ),
      _ProfileMenuItem(
        icon: Icons.lock_outline_rounded,
        title: 'Contrasena',
        value: 'Cambiar',
        onTap: onChangePassword,
      ),
      _ProfileMenuItem(
        icon: Icons.notifications_none_rounded,
        title: 'Notificaciones',
        value: 'Activadas',
        onTap: () {},
      ),
    ];
    final dataItems = [
      _ProfileMenuItem(
        icon: Icons.directions_car_outlined,
        title: 'Vehiculo principal',
        value: _fallbackValue(profile.vehicleLabel, 'Sedan · Gris'),
        onTap: onEditVehicle,
      ),
      _ProfileMenuItem(
        icon: Icons.location_on_outlined,
        title: 'Direccion favorita',
        value: _displayAddress(profile.favoriteAddress, 'Av. Reforma 245'),
        onTap: onEditAddress,
      ),
      _ProfileMenuItem(
        icon: Icons.credit_card_rounded,
        title: 'Metodo de pago',
        value: _fallbackValue(profile.paymentMethod, 'Visa ···4242'),
        onTap: onEditPayment,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _ProfileHero(profile: profile, mode: mode, onEditAvatar: onEditProfile),
        const SizedBox(height: 22),
        Row(
          children: stats
              .map(
                (stat) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: stat == stats.last ? 0 : 10,
                    ),
                    child: _StatCard(stat: stat),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        _ProfileSection(title: 'Mi cuenta', items: accountItems),
        const SizedBox(height: 22),
        _ProfileSection(title: 'Mis datos', items: dataItems),
        const SizedBox(height: 22),
        _ThemePreferenceTile(
          isLightMode: isLightMode,
          onChanged: onToggleTheme,
        ),
        const SizedBox(height: 22),
        _DangerButton(label: 'Cerrar sesion', onTap: onLogout),
      ],
    );
  }
}

class _DesktopProfileLayout extends StatelessWidget {
  const _DesktopProfileLayout({
    required this.profile,
    required this.stats,
    required this.mode,
    required this.isLightMode,
    required this.onEditProfile,
    required this.onEditVehicle,
    required this.onEditAddress,
    required this.onEditPayment,
    required this.onChangePassword,
    required this.onToggleTheme,
    required this.onLogout,
  });

  final UserProfile profile;
  final List<_ProfileStat> stats;
  final AppRole mode;
  final bool isLightMode;
  final VoidCallback onEditProfile;
  final VoidCallback onEditVehicle;
  final VoidCallback onEditAddress;
  final VoidCallback onEditPayment;
  final VoidCallback onChangePassword;
  final ValueChanged<bool> onToggleTheme;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileHero(
                profile: profile,
                mode: mode,
                onEditAvatar: onEditProfile,
              ),
              const SizedBox(height: 20),
              Row(
                children: stats
                    .map(
                      (stat) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: stat == stats.last ? 0 : 10,
                          ),
                          child: _StatCard(stat: stat),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              _ThemePreferenceTile(
                isLightMode: isLightMode,
                onChanged: onToggleTheme,
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _ProfileSection(
                title: 'Mi cuenta',
                items: [
                  _ProfileMenuItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Informacion personal',
                    value: 'Editar',
                    onTap: onEditProfile,
                  ),
                  _ProfileMenuItem(
                    icon: Icons.lock_outline_rounded,
                    title: 'Contrasena',
                    value: 'Cambiar',
                    onTap: onChangePassword,
                  ),
                  _ProfileMenuItem(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notificaciones',
                    value: 'Activadas',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _ProfileSection(
                title: 'Mis datos',
                items: [
                  _ProfileMenuItem(
                    icon: Icons.directions_car_outlined,
                    title: 'Vehiculo principal',
                    value: _fallbackValue(profile.vehicleLabel, 'Sedan · Gris'),
                    onTap: onEditVehicle,
                  ),
                  _ProfileMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Direccion favorita',
                    value: _displayAddress(
                      profile.favoriteAddress,
                      'Av. Reforma 245',
                    ),
                    onTap: onEditAddress,
                  ),
                  _ProfileMenuItem(
                    icon: Icons.credit_card_rounded,
                    title: 'Metodo de pago',
                    value: _fallbackValue(
                      profile.paymentMethod,
                      'Visa ···4242',
                    ),
                    onTap: onEditPayment,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _DangerButton(label: 'Cerrar sesion', onTap: onLogout),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.profile,
    required this.mode,
    required this.onEditAvatar,
  });

  final UserProfile profile;
  final AppRole mode;
  final VoidCallback onEditAvatar;

  @override
  Widget build(BuildContext context) {
    final isWorker = mode == AppRole.worker;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 22),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _profileBorderColor(context))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            height: 68,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0x4D3D7BFF), Color(0x2D6AA8FF)],
                    ),
                    border: Border.all(
                      color: const Color(0x476AA8FF),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x336AA8FF),
                        blurRadius: 22,
                        spreadRadius: 1,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: LavifyColors.primary,
                    size: 30,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onEditAvatar,
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: LavifyColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _profileBackgroundColor(context),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile.name.trim().isEmpty
                            ? 'Usuario Lavify'
                            : profile.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _profileTextPrimaryColor(context),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    if (isWorker) ...[
                      const SizedBox(width: 8),
                      const _VerifiedBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  profile.email.isEmpty ? 'cliente@lavify.app' : profile.email,
                  style: TextStyle(
                    color: _profileTextSecondaryColor(context),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                if (isWorker)
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: Color(0xFFFFC857),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '4.9',
                        style: TextStyle(
                          color: _profileTextPrimaryColor(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '\u00B7 128 lavados completados',
                        style: TextStyle(
                          color: _profileTextSecondaryColor(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    '3 lavados solicitados',
                    style: TextStyle(
                      color: _profileTextSecondaryColor(context),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0x2634D39A),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x5134D39A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.verified_rounded, size: 12, color: LavifyColors.success),
          SizedBox(width: 4),
          Text(
            'Verificado',
            style: TextStyle(
              color: LavifyColors.success,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.items});

  final String title;
  final List<_ProfileMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: _profileTextSecondaryColor(context),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: _profileSurfaceColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _profileBorderColor(context)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _ProfileRow(item: items[i]),
                if (i < items.length - 1)
                  Divider(color: _profileBorderColor(context), height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.item});

  final _ProfileMenuItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0x146AA8FF),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(item.icon, size: 16, color: LavifyColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  color: _profileTextPrimaryColor(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Flexible(
              child: Text(
                item.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: _profileTextSecondaryColor(context),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: _profileTextSecondaryColor(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemePreferenceTile extends StatelessWidget {
  const _ThemePreferenceTile({
    required this.isLightMode,
    required this.onChanged,
  });

  final bool isLightMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PREFERENCIAS',
          style: TextStyle(
            color: _profileTextSecondaryColor(context),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: _profileSurfaceColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _profileBorderColor(context)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0x146AA8FF),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    isLightMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    size: 16,
                    color: LavifyColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Modo claro',
                    style: TextStyle(
                      color: _profileTextPrimaryColor(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch(
                  value: isLightMode,
                  onChanged: onChanged,
                  activeThumbColor: Colors.white,
                  activeTrackColor: _profileAccentColor(context),
                  inactiveThumbColor: _profileTextSecondaryColor(context),
                  inactiveTrackColor: _profileSurfaceAltColor(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0x14FF5050),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x30FF5050)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFFF6B6B),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final _ProfileStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: _profileSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _profileBorderColor(context)),
      ),
      child: Column(
        children: [
          Text(
            stat.value,
            style: TextStyle(
              color: stat.highlight
                  ? LavifyColors.success
                  : _profileTextPrimaryColor(context),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            stat.label,
            style: TextStyle(
              color: _profileTextSecondaryColor(context),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(
        color: _profileTextPrimaryColor(context),
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: _profileTextSecondaryColor(context),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: TextStyle(
          color: _profileAccentColor(context),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: TextStyle(
          color: _profileTextSecondaryColor(context).withAlpha(170),
          fontSize: 14,
        ),
        filled: true,
        fillColor: _profileSurfaceAltColor(context),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: _profileBorderColor(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: _profileAccentColor(context),
            width: 1.3,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: _profileBorderColor(context)),
        ),
      ),
    );
  }
}

class _ReadOnlyProfileField extends StatelessWidget {
  const _ReadOnlyProfileField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _profileTextSecondaryColor(context),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: _profileSurfaceAltColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _profileBorderColor(context)),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: _profileTextPrimaryColor(context).withAlpha(210),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
}

class _ProfileStat {
  const _ProfileStat({
    required this.value,
    required this.label,
    this.highlight = false,
  });

  final String value;
  final String label;
  final bool highlight;
}

Color _profileBackgroundColor(BuildContext context) =>
    Theme.of(context).scaffoldBackgroundColor;

Color _profileSurfaceColor(BuildContext context) =>
    LavifyTheme.surfaceColor(context);

Color _profileSurfaceAltColor(BuildContext context) =>
    LavifyTheme.surfaceAltColor(context);

Color _profileBorderColor(BuildContext context) =>
    LavifyTheme.borderColor(context);

Color _profileTextPrimaryColor(BuildContext context) =>
    LavifyTheme.textPrimaryColor(context);

Color _profileTextSecondaryColor(BuildContext context) =>
    LavifyTheme.textSecondaryColor(context);

Color _profileAccentColor(BuildContext context) => LavifyTheme.isLight(context)
    ? LavifyColors.lightNavy
    : LavifyColors.primary;


String _fallbackValue(String value, String fallback) {
  return value.trim().isEmpty ? fallback : value.trim();
}

final RegExp _coordPattern = RegExp(r'^-?\d{1,3}\.\d+\s*,\s*-?\d{1,3}\.\d+$');

String _displayAddress(String value, String fallback) {
  final trimmed = value.trim();
  if (trimmed.isEmpty || _coordPattern.hasMatch(trimmed)) {
    return fallback;
  }
  return trimmed;
}
