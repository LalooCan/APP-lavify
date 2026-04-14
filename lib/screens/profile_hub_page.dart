import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../services/profile_service.dart';
import '../services/theme_service.dart';
import '../theme/theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import 'app_shell.dart';
import 'role_login_page.dart';

class ProfileHubPage extends StatelessWidget {
  const ProfileHubPage({super.key, required this.mode});

  final AppMode mode;

  static final _profileService = ProfileService();
  static final _themeService = ThemeService();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 920;
    final isWorker = mode == AppMode.worker;

    return Scaffold(
      body: Container(
        decoration: LavifyTheme.pageDecoration(context),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 32 : 24),
            child: ValueListenableBuilder<UserProfile>(
              valueListenable: _profileService.profile,
              builder: (context, profile, _) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configuracion',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isWorker
                              ? 'Administra tu cuenta operativa, tus datos frecuentes y la seguridad de tu sesion.'
                              : 'Administra tu cuenta, tus datos frecuentes y la seguridad de tu sesion.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: _AccountSummaryCard(
                                  profile: profile,
                                  mode: mode,
                                  onEditProfile: () =>
                                      _showEditProfileDialog(context, profile),
                                  onLogout: () => _handleLogout(context),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 7,
                                child: _SettingsPanel(
                                  profile: profile,
                                  isLightMode: _themeService.isLightMode,
                                  onEditProfile: () =>
                                      _showEditProfileDialog(context, profile),
                                  onEditVehicle: () =>
                                      _showSingleFieldDialog(
                                        context,
                                        title: 'Vehiculo principal',
                                        label: 'Vehiculo principal',
                                        initialValue: profile.vehicleLabel,
                                        onSave: (value) {
                                          _profileService.updateProfile(
                                            profile.copyWith(
                                              vehicleLabel: value,
                                            ),
                                          );
                                        },
                                      ),
                                  onEditAddress: () =>
                                      _showSingleFieldDialog(
                                        context,
                                        title: 'Direccion favorita',
                                        label: 'Direccion favorita',
                                        initialValue: profile.favoriteAddress,
                                        onSave: (value) {
                                          _profileService.updateProfile(
                                            profile.copyWith(
                                              favoriteAddress: value,
                                            ),
                                          );
                                        },
                                      ),
                                  onEditPayment: () =>
                                      _showSingleFieldDialog(
                                        context,
                                        title: 'Metodo de pago',
                                        label: 'Metodo de pago',
                                        initialValue: profile.paymentMethod,
                                        onSave: (value) {
                                          _profileService.updateProfile(
                                            profile.copyWith(
                                              paymentMethod: value,
                                            ),
                                          );
                                        },
                                      ),
                                  onLogout: () => _handleLogout(context),
                                  onToggleTheme: _themeService.toggleBrightness,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _AccountSummaryCard(
                            profile: profile,
                            mode: mode,
                            onEditProfile: () =>
                                _showEditProfileDialog(context, profile),
                            onLogout: () => _handleLogout(context),
                          ),
                          const SizedBox(height: 20),
                          _SettingsPanel(
                            profile: profile,
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
                            onLogout: () => _handleLogout(context),
                            onToggleTheme: _themeService.toggleBrightness,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
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
          backgroundColor: LavifyColors.surface,
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
          backgroundColor: LavifyColors.surface,
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
          backgroundColor: LavifyColors.surface,
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

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const RoleLoginPage()),
      (route) => false,
    );
  }
}

class _AccountSummaryCard extends StatelessWidget {
  const _AccountSummaryCard({
    required this.profile,
    required this.mode,
    required this.onEditProfile,
    required this.onLogout,
  });

  final UserProfile profile;
  final AppMode mode;
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final isWorker = mode == AppMode.worker;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LavifyColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: LavifyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0x3322C1FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: LavifyColors.primary,
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name.trim().isEmpty
                          ? 'Elige tu nombre'
                          : profile.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const _AccountBadgeRow(),
          const SizedBox(height: 24),
          _ProfileHighlight(
            label: 'Correo de acceso',
            value: profile.email,
          ),
          _ProfileHighlight(
            label: 'Nombre de usuario',
            value: profile.name.trim().isEmpty
                ? 'Pendiente por elegir'
                : profile.name,
          ),
          _ProfileHighlight(
            label: 'Tipo de cuenta',
            value: isWorker ? 'Trabajador' : 'Cliente',
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Editar cuenta',
            onPressed: onEditProfile,
            isExpanded: true,
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Cerrar sesion',
            icon: Icons.logout_rounded,
            onPressed: onLogout,
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.profile,
    required this.isLightMode,
    required this.onEditProfile,
    required this.onEditVehicle,
    required this.onEditAddress,
    required this.onEditPayment,
    required this.onLogout,
    required this.onToggleTheme,
  });

  final UserProfile profile;
  final bool isLightMode;
  final VoidCallback onEditProfile;
  final VoidCallback onEditVehicle;
  final VoidCallback onEditAddress;
  final VoidCallback onEditPayment;
  final VoidCallback onLogout;
  final ValueChanged<bool> onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SettingsSection(
          title: 'Cuenta',
          subtitle: 'Datos visibles de tu perfil y acceso principal.',
          children: [
            _SettingsTile(
              icon: Icons.badge_rounded,
              title: 'Nombre de usuario',
              subtitle: profile.name,
              onTap: onEditProfile,
            ),
            _SettingsTile(
              icon: Icons.alternate_email_rounded,
              title: 'Correo de acceso',
              subtitle: profile.email,
              onTap: onEditProfile,
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SettingsSection(
          title: 'Preferencias',
          subtitle: 'Informacion rapida para pedir tus lavados.',
          children: [
            _SettingsTile(
              icon: Icons.directions_car_filled_rounded,
              title: 'Vehiculo principal',
              subtitle: profile.vehicleLabel,
              onTap: onEditVehicle,
            ),
            _SettingsTile(
              icon: Icons.home_rounded,
              title: 'Direccion favorita',
              subtitle: profile.favoriteAddress,
              onTap: onEditAddress,
            ),
            _SettingsTile(
              icon: Icons.credit_card_rounded,
              title: 'Metodo de pago',
              subtitle: profile.paymentMethod,
              onTap: onEditPayment,
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SettingsSection(
          title: 'Apariencia',
          subtitle: 'Personaliza como se ve la app en tu dispositivo.',
          children: [
            _ThemeModeTile(
              isLightMode: isLightMode,
              onChanged: onToggleTheme,
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SettingsSection(
          title: 'Seguridad',
          subtitle: 'Control de sesion y acceso a tu cuenta.',
          children: [
            _SettingsTile(
              icon: Icons.password_rounded,
              title: 'Contrasena',
              subtitle: 'Disponible cuando conectemos autenticacion real',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.logout_rounded,
              title: 'Cerrar sesion',
              subtitle: 'Salir y volver a la pantalla de acceso',
              onTap: onLogout,
              danger: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: LavifyColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: LavifyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final accentColor = danger
        ? const Color(0xFFFF8A80)
        : LavifyColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(5),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: LavifyColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(
                      accentColor.withAlpha(28),
                      LavifyColors.surfaceAlt,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: accentColor),
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
                Icon(
                  Icons.chevron_right_rounded,
                  color: danger ? accentColor : LavifyColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({
    required this.isLightMode,
    required this.onChanged,
  });

  final bool isLightMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LavifyColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0x1A22C1FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isLightMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: LavifyColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modo claro',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: LavifyColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLightMode
                      ? 'La app usa una apariencia clara.'
                      : 'Activa una apariencia mas luminosa.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Switch(
            value: isLightMode,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _AccountBadgeRow extends StatelessWidget {
  const _AccountBadgeRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: const [
        _InfoBadge(
          icon: Icons.verified_user_rounded,
          label: 'Cuenta activa',
        ),
        _InfoBadge(
          icon: Icons.tune_rounded,
          label: 'Preferencias editables',
        ),
      ],
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: LavifyColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: LavifyColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: LavifyColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHighlight extends StatelessWidget {
  const _ProfileHighlight({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: LavifyColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: LavifyColors.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: LavifyColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: LavifyColors.border),
        ),
      ),
      child: Text(
        value,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: LavifyColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
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
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: LavifyColors.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: LavifyColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: LavifyColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: LavifyColors.primary),
        ),
      ),
    );
  }
}
