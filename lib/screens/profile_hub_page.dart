import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../services/profile_service.dart';
import '../theme/theme.dart';
import '../widgets/primary_button.dart';

class ProfileHubPage extends StatelessWidget {
  const ProfileHubPage({super.key});

  static final _profileService = ProfileService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF07101D),
              Color(0xFF102446),
              Color(0xFF09111F),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ValueListenableBuilder<UserProfile>(
              valueListenable: _profileService.profile,
              builder: (context, profile, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perfil',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 20),
                    Container(
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
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 30,
                                backgroundColor: Color(0x3322C1FF),
                                child: Icon(
                                  Icons.person,
                                  color: LavifyColors.primary,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.name,
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
                          const SizedBox(height: 24),
                          _ProfileItem(
                            label: 'Vehiculo principal',
                            value: profile.vehicleLabel,
                          ),
                          _ProfileItem(
                            label: 'Direccion favorita',
                            value: profile.favoriteAddress,
                          ),
                          _ProfileItem(
                            label: 'Metodo de pago',
                            value: profile.paymentMethod,
                          ),
                          const SizedBox(height: 8),
                          PrimaryButton(
                            label: 'Editar perfil',
                            onPressed: () => _showEditProfileDialog(context, profile),
                            isExpanded: true,
                          ),
                        ],
                      ),
                    ),
                  ],
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
    final emailController = TextEditingController(text: profile.email);
    final vehicleController = TextEditingController(text: profile.vehicleLabel);
    final addressController = TextEditingController(
      text: profile.favoriteAddress,
    );
    final paymentController = TextEditingController(
      text: profile.paymentMethod,
    );

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
                  _ProfileField(controller: nameController, label: 'Nombre'),
                  const SizedBox(height: 12),
                  _ProfileField(controller: emailController, label: 'Email'),
                  const SizedBox(height: 12),
                  _ProfileField(
                    controller: vehicleController,
                    label: 'Vehiculo principal',
                  ),
                  const SizedBox(height: 12),
                  _ProfileField(
                    controller: addressController,
                    label: 'Direccion favorita',
                  ),
                  const SizedBox(height: 12),
                  _ProfileField(
                    controller: paymentController,
                    label: 'Metodo de pago',
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
                _profileService.updateProfile(
                  profile.copyWith(
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    vehicleLabel: vehicleController.text.trim(),
                    favoriteAddress: addressController.text.trim(),
                    paymentMethod: paymentController.text.trim(),
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
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({
    required this.label,
    required this.value,
  });

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

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
  });

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
