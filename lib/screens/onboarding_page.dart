import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../screens/app_shell.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../theme/theme.dart';
import '../widgets/primary_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _completing = false;

  List<_OnboardingSlide> get _slides {
    if (widget.profile.role == AppRole.worker) {
      return const [
        _OnboardingSlide(
          icon: Icons.local_car_wash_rounded,
          title: 'Acepta servicios\ncerca de ti',
          body:
              'Elige los pedidos que quieras tomar. Sin jefes, sin horarios fijos.',
        ),
        _OnboardingSlide(
          icon: Icons.schedule_rounded,
          title: 'Trabaja\na tu ritmo',
          body:
              'Activa tu disponibilidad cuando quieras y pausa cuando necesites un descanso.',
        ),
        _OnboardingSlide(
          icon: Icons.verified_rounded,
          title: 'Completa\ntu perfil',
          body:
              'Verificarte aumenta tu visibilidad con los clientes y genera más confianza.',
        ),
      ];
    }
    return const [
      _OnboardingSlide(
        icon: Icons.water_drop_rounded,
        title: 'Pide tu\nlavado',
        body:
            'Elige el paquete, tu vehículo y el horario que más te convenga. En segundos.',
      ),
      _OnboardingSlide(
        icon: Icons.directions_car_rounded,
        title: 'Tu lavador\nllega a ti',
        body:
            'Sin mover el auto de donde está. El lavador va a tu ubicación.',
      ),
      _OnboardingSlide(
        icon: Icons.map_rounded,
        title: 'Rastreo\nen tiempo real',
        body:
            'Ve exactamente dónde está el lavador y cuándo llegará en el mapa.',
      ),
    ];
  }

  Future<void> _finish() async {
    if (_completing) return;
    setState(() => _completing = true);
    try {
      final updated =
          await AuthService().completeOnboarding(widget.profile);
      ProfileService().setProfile(updated);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => AppShell(mode: updated.role),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _completing = false);
    }
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      body: Container(
        decoration: LavifyTheme.pageDecoration(context),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isLast)
                      TextButton(
                        onPressed: _completing ? null : _finish,
                        child: Text(
                          'Saltar',
                          style: TextStyle(
                            color: LavifyTheme.textSecondaryColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (page) =>
                      setState(() => _currentPage = page),
                  itemCount: _slides.length,
                  itemBuilder: (context, index) =>
                      _SlideView(slide: _slides[index]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _slides.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == i ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                                ? LavifyColors.primary
                                : LavifyTheme.borderColor(context),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _completing
                        ? const SizedBox(
                            height: 56,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : PrimaryButton(
                            label: isLast ? 'Comenzar' : 'Siguiente',
                            icon: isLast
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            onPressed: _next,
                            isExpanded: true,
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LavifyTheme.premiumPanelGradient(context),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: LavifyTheme.borderColor(context)),
              boxShadow: LavifyTheme.panelShadow(context, floating: false),
            ),
            child: Icon(
              slide.icon,
              size: 52,
              color: LavifyColors.primary,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
