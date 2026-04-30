import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../theme/theme.dart';
import '../widgets/primary_button.dart';

class WorkerVerificationPage extends StatefulWidget {
  const WorkerVerificationPage({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<WorkerVerificationPage> createState() => _WorkerVerificationPageState();
}

class _WorkerVerificationPageState extends State<WorkerVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _curpCtrl = TextEditingController();

  bool _loading = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.profile.name;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _expCtrl.dispose();
    _curpCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final updated =
          await AuthService().submitVerificationRequest(widget.profile);
      ProfileService().setProfile(updated);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _submitted = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocurrió un error. Intenta de nuevo.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: LavifyTheme.pageDecoration(context),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  'Verificación de lavador',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                sliver: SliverToBoxAdapter(
                  child: _submitted ? _SuccessView(onBack: () => Navigator.of(context).pop()) : _FormView(
                    formKey: _formKey,
                    nameCtrl: _nameCtrl,
                    phoneCtrl: _phoneCtrl,
                    cityCtrl: _cityCtrl,
                    expCtrl: _expCtrl,
                    curpCtrl: _curpCtrl,
                    loading: _loading,
                    onSubmit: _submit,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  const _FormView({
    required this.formKey,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.cityCtrl,
    required this.expCtrl,
    required this.curpCtrl,
    required this.loading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController expCtrl;
  final TextEditingController curpCtrl;
  final bool loading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Completa tu perfil profesional',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'Revisaremos tu información en 2-3 días hábiles. Los clientes podrán ver tu badge de verificado.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          _Field(
            controller: nameCtrl,
            label: 'Nombre completo',
            icon: Icons.person_outline_rounded,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
          ),
          const SizedBox(height: 16),
          _Field(
            controller: phoneCtrl,
            label: 'Teléfono',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) =>
                (v == null || v.trim().length < 10) ? 'Ingresa un teléfono válido' : null,
          ),
          const SizedBox(height: 16),
          _Field(
            controller: cityCtrl,
            label: 'Ciudad de operación',
            icon: Icons.location_city_rounded,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Ingresa tu ciudad' : null,
          ),
          const SizedBox(height: 16),
          _Field(
            controller: expCtrl,
            label: 'Años de experiencia',
            icon: Icons.workspace_premium_outlined,
            keyboardType: TextInputType.number,
            validator: (v) {
              final n = int.tryParse(v?.trim() ?? '');
              if (n == null || n < 0) return 'Ingresa un número válido';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _Field(
            controller: curpCtrl,
            label: 'CURP / RFC (opcional)',
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 36),
          loading
              ? const Center(child: CircularProgressIndicator())
              : PrimaryButton(
                  label: 'Enviar solicitud',
                  icon: Icons.send_rounded,
                  onPressed: onSubmit,
                  isExpanded: true,
                ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: LavifyColors.success.withAlpha(24),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            size: 48,
            color: LavifyColors.success,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Solicitud enviada',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'Revisaremos tu información en 2-3 días hábiles y te notificaremos el resultado.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 36),
        OutlinedButton(
          onPressed: onBack,
          child: const Text('Volver al panel'),
        ),
      ],
    );
  }
}
