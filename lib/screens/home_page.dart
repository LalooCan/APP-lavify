import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../services/home_service.dart';
import '../theme/theme.dart';
import '../widgets/how_it_works_section.dart';
import '../widgets/package_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/section_text.dart';
import 'request_wash_flow_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const HomeService _homeService = HomeService();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1000;
    final horizontalPadding = isDesktop ? 72.0 : 24.0;
    final verticalPadding = isDesktop ? 40.0 : 24.0;
    final session = _homeService.getSessionData();
    final featuredPackages = _homeService.getFeaturedPackages();

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
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                children: [
                  _TopBar(isDesktop: isDesktop),
                  const SizedBox(height: 56),
                  if (isDesktop)
                    _DesktopHero(session: session)
                  else
                    _MobileHero(session: session),
                  const SizedBox(height: 56),
                  _FunctionalSection(
                    session: session,
                    featuredPackages: featuredPackages,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [LavifyColors.primaryStrong, LavifyColors.primary],
            ),
          ),
          child: const Icon(
            Icons.water_drop_rounded,
            color: LavifyColors.textPrimary,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'Lavify',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const Spacer(),
        if (isDesktop) ...[
          const _NavLabel(label: 'Como funciona'),
          const SizedBox(width: 24),
          const _NavLabel(label: 'Precios'),
          const SizedBox(width: 24),
          const _NavLabel(label: 'Para lavadores'),
          const SizedBox(width: 32),
        ],
        SecondaryButton(
          label: 'Quiero trabajar',
          icon: Icons.arrow_outward_rounded,
          onPressed: () {},
        ),
      ],
    );
  }
}

class _DesktopHero extends StatelessWidget {
  const _DesktopHero({required this.session});

  final HomeSessionData session;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 11,
          child: _HeroContent(session: session),
        ),
        const SizedBox(width: 40),
        Expanded(
          flex: 9,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: const _PreviewCard(),
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileHero extends StatelessWidget {
  const _MobileHero({required this.session});

  final HomeSessionData session;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroContent(session: session),
        const SizedBox(height: 32),
        const _PreviewCard(),
      ],
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({required this.session});

  final HomeSessionData session;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StatusChip(
              label: session.availabilityLabel,
              color: LavifyColors.success,
            ),
            const _StatusChip(
              label: 'Lavadores verificados',
              color: LavifyColors.primary,
            ),
          ],
        ),
        const SizedBox(height: 28),
        const SectionText(
          title: 'Lava tu auto',
          highlight: 'sin salir\nde casa',
          subtitle:
              'Solicita un lavado desde tu celular y un profesional verificado llega a donde estas en minutos. Rapido, confiable y pensado para tu rutina.',
        ),
        const SizedBox(height: 24),
        _SessionOverview(session: session),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            PrimaryButton(
              label: 'Pedir lavado',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const RequestWashFlowPage(),
                  ),
                );
              },
            ),
            SecondaryButton(
              label: 'Ver como funciona',
              icon: Icons.play_circle_outline_rounded,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 40),
        const Divider(color: LavifyColors.border, height: 1),
        const SizedBox(height: 28),
        const Wrap(
          spacing: 28,
          runSpacing: 20,
          children: [
            _MetricItem(value: '+2,400', label: 'Lavados realizados'),
            _MetricItem(value: '4.9', label: 'Calificacion promedio'),
            _MetricItem(value: '20 min', label: 'Tiempo estimado de llegada'),
          ],
        ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xCC0E1A2C),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: LavifyColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 28,
              offset: Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              const Icon(
                Icons.water_drop_rounded,
                color: LavifyColors.primary,
              ),
              const SizedBox(width: 10),
              Text(
                'Seguimiento en vivo',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                    ),
              ),
              const Spacer(),
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0x3322C1FF),
                child: Icon(Icons.person, color: LavifyColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            height: 210,
            decoration: BoxDecoration(
              color: LavifyColors.surfaceAlt,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MapGridPainter(),
                  ),
                ),
                const Positioned(
                  top: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Icon(
                      Icons.linear_scale_rounded,
                      color: LavifyColors.primary,
                      size: 76,
                    ),
                  ),
                ),
                const Positioned(
                  top: 74,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      color: Colors.pinkAccent,
                      size: 34,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 18,
                  right: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: LavifyColors.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Llegando en 18 min',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: LavifyColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2940),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: LavifyColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Tipo de lavado',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: LavifyColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    const _MiniBadge(label: 'En camino'),
                  ],
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(
                      child: _OptionTile(
                        icon: Icons.local_car_wash_rounded,
                        label: 'Exterior',
                        selected: true,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _OptionTile(
                        icon: Icons.cleaning_services_rounded,
                        label: 'Interior',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _OptionTile(
                        icon: Icons.auto_awesome_rounded,
                        label: 'Premium',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Confirmar lavado · \$199',
                  onPressed: () {},
                  isExpanded: true,
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

class _FunctionalSection extends StatelessWidget {
  const _FunctionalSection({
    required this.session,
    required this.featuredPackages,
  });

  final HomeSessionData session;
  final List<WashPackage> featuredPackages;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HowItWorksSection(),
        const SizedBox(height: 56),
        Text(
          'Paquetes disponibles',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Elige el nivel de lavado y entra directo al flujo con el paquete preseleccionado.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: featuredPackages
              .map(
                (package) => PackageCard(
                  package: package,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            RequestWashFlowPage(initialPackage: package),
                      ),
                    );
                  },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 56),
        Text(
          'Confianza Lavify',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Operamos con una experiencia clara para cliente y lavador desde el primer pedido.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        const Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _TrustCard(
              icon: Icons.verified_user_rounded,
              title: 'Lavadores verificados',
              subtitle: 'Perfil validado y seguimiento continuo.',
            ),
            _TrustCard(
              icon: Icons.lock_rounded,
              title: 'Pagos seguros',
              subtitle: 'Base lista para integrar checkout y backend.',
            ),
            _TrustCard(
              icon: Icons.route_rounded,
              title: 'Seguimiento en tiempo real',
              subtitle: 'Ubicacion y progreso del servicio en una sola vista.',
            ),
            _TrustCard(
              icon: Icons.support_agent_rounded,
              title: 'Soporte',
              subtitle: 'Canal preparado para atencion y post-servicio.',
            ),
          ],
        ),
      ],
    );
  }
}

class _SessionOverview extends StatelessWidget {
  const _SessionOverview({required this.session});

  final HomeSessionData session;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0x73101C31),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LavifyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hola, ${session.firstName}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            session.savedAddress,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.timer_outlined,
                color: LavifyColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Tiempo estimado: ${session.etaLabel}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: LavifyColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrustCard extends StatelessWidget {
  const _TrustCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: LavifyColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: LavifyColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0x1A22C1FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: LavifyColors.primary),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLabel extends StatelessWidget {
  const _NavLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: LavifyColors.textPrimary.withAlpha(219),
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: LavifyColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: LavifyColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 22,
                ),
          ),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x1F28D17C),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: LavifyColors.success,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: selected ? LavifyColors.primaryStrong : Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? Colors.transparent : LavifyColors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: selected ? LavifyColors.textPrimary : LavifyColors.primary,
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: LavifyColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(15)
      ..strokeWidth = 1;

    const gap = 28.0;
    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
