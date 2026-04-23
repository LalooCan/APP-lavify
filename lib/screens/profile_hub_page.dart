import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/session_service.dart';
import '../services/theme_service.dart';
import '../theme/theme.dart';
import 'role_login_page.dart';

class ProfileHubPage extends StatelessWidget {
  const ProfileHubPage({super.key, required this.mode});

  final AppRole mode;

  static final _profileService = ProfileService();
  static final _sessionService = SessionService();
  static final _themeService = ThemeService();
  static final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Scaffold(
      backgroundColor: LavifyColors.background,
      body: DecoratedBox(
        decoration: LavifyTheme.pageDecoration(context),
        child: SafeArea(
          child: ValueListenableBuilder<UserProfile>(
            valueListenable: _profileService.profile,
            builder: (context, profile, _) {
              final stats = _statsForProfile(profile, mode);
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
                            onToggleTheme: _themeService.toggleBrightness,
                            onLogout: () => _handleLogout(context),
                          )
                        : _MobileProfileLayout(
                            profile: profile,
                            stats: stats,
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
          backgroundColor: LavifyTheme.surfaceColor(context),
          title: const Text('Editar perfil'),
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
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
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
          backgroundColor: LavifyTheme.surfaceColor(dialogContext),
          title: Text(title),
          content: SizedBox(
            width: 420,
            child: _ProfileField(controller: controller, label: label),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
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
          backgroundColor: LavifyTheme.surfaceColor(dialogContext),
          title: const Text('Cerrar sesion'),
          content: const Text(
            'Vas a salir de tu cuenta actual y regresar a la pantalla de login.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
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
    required this.isLightMode,
    required this.onEditProfile,
    required this.onEditVehicle,
    required this.onEditAddress,
    required this.onEditPayment,
    required this.onToggleTheme,
    required this.onLogout,
  });

  final UserProfile profile;
  final List<_ProfileStat> stats;
  final bool isLightMode;
  final VoidCallback onEditProfile;
  final VoidCallback onEditVehicle;
  final VoidCallback onEditAddress;
  final VoidCallback onEditPayment;
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
        onTap: () {},
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
        value: _fallbackValue(profile.favoriteAddress, 'Av. Reforma 245'),
        onTap: onEditAddress,
      ),
      _ProfileMenuItem(
        icon: Icons.smartphone_rounded,
        title: 'Metodo de pago',
        value: _fallbackValue(profile.paymentMethod, 'Visa ···4242'),
        onTap: onEditPayment,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _ProfileHero(profile: profile),
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
    required this.isLightMode,
    required this.onEditProfile,
    required this.onEditVehicle,
    required this.onEditAddress,
    required this.onEditPayment,
    required this.onToggleTheme,
    required this.onLogout,
  });

  final UserProfile profile;
  final List<_ProfileStat> stats;
  final bool isLightMode;
  final VoidCallback onEditProfile;
  final VoidCallback onEditVehicle;
  final VoidCallback onEditAddress;
  final VoidCallback onEditPayment;
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
              _ProfileHero(profile: profile),
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
                    onTap: () {},
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
                    value: _fallbackValue(
                      profile.favoriteAddress,
                      'Av. Reforma 245',
                    ),
                    onTap: onEditAddress,
                  ),
                  _ProfileMenuItem(
                    icon: Icons.smartphone_rounded,
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
  const _ProfileHero({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 22),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: LavifyColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0x4D3D7BFF), Color(0x2D6AA8FF)],
              ),
              border: Border.all(color: const Color(0x476AA8FF), width: 2),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: LavifyColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name.trim().isEmpty ? 'Usuario Lavify' : profile.name,
                  style: const TextStyle(
                    color: LavifyColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.email.isEmpty ? 'cliente@lavify.app' : profile.email,
                  style: const TextStyle(
                    color: LavifyColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: const [
                    Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: Color(0xFFFFC857),
                    ),
                    SizedBox(width: 5),
                    Text(
                      '4.9',
                      style: TextStyle(
                        color: LavifyColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      '· 3 lavados completados',
                      style: TextStyle(
                        color: LavifyColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
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
          style: const TextStyle(
            color: LavifyColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: LavifyColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: LavifyColors.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _ProfileRow(item: items[i]),
                if (i < items.length - 1)
                  const Divider(
                    color: LavifyColors.border,
                    height: 1,
                    indent: 18,
                    endIndent: 18,
                  ),
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
                style: const TextStyle(
                  color: LavifyColors.textPrimary,
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
                style: const TextStyle(
                  color: LavifyColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 14,
              color: LavifyColors.textSecondary,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LavifyColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LavifyColors.border),
      ),
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
              isLightMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 16,
              color: LavifyColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Modo claro',
              style: TextStyle(
                color: LavifyColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(value: isLightMode, onChanged: onChanged),
        ],
      ),
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
        color: LavifyColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LavifyColors.border),
      ),
      child: Column(
        children: [
          Text(
            stat.value,
            style: TextStyle(
              color: stat.highlight
                  ? LavifyColors.success
                  : LavifyColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            stat.label,
            style: const TextStyle(
              color: LavifyColors.textSecondary,
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
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _ReadOnlyProfileField extends StatelessWidget {
  const _ReadOnlyProfileField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: false,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(labelText: label),
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

List<_ProfileStat> _statsForProfile(UserProfile profile, AppRole mode) {
  if (mode == AppRole.worker) {
    return const [
      _ProfileStat(value: '128', label: 'Lavados'),
      _ProfileStat(value: '\$8,450', label: 'Total', highlight: true),
      _ProfileStat(value: '4.9', label: 'Rating'),
    ];
  }
  return const [
    _ProfileStat(value: '3', label: 'Lavados'),
    _ProfileStat(value: '\$487', label: 'Total', highlight: true),
    _ProfileStat(value: '4.9', label: 'Rating'),
  ];
}

String _fallbackValue(String value, String fallback) {
  return value.trim().isEmpty ? fallback : value.trim();
}
