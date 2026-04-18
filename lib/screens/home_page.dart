import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../services/home_service.dart';
import '../services/order_service.dart';
import '../services/profile_service.dart';
import '../services/session_service.dart';
import '../theme/theme.dart';
import '../widgets/how_it_works_section.dart';
import '../widgets/live_tracking_map.dart';
import '../widgets/package_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/section_text.dart';
import 'order_tracking_page.dart';
import 'request_wash_flow_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const HomeService _homeService = HomeService();
  static final OrderService _orderService = OrderService();
  static final ProfileService _profileService = ProfileService();
  static final SessionService _sessionService = SessionService();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1000;
    final horizontalPadding = isDesktop ? 72.0 : 24.0;
    final verticalPadding = isDesktop ? 40.0 : 24.0;
    final featuredPackages = _homeService.getFeaturedPackages();

    return Scaffold(
      body: Container(
        decoration: LavifyTheme.pageDecoration(context),
        child: Stack(
          children: [
            const Positioned(
              top: -120,
              right: -40,
              child: _AmbientGlow(size: 320, color: Color(0x1E6AA8FF)),
            ),
            const Positioned(
              bottom: -90,
              left: -30,
              child: _AmbientGlow(size: 260, color: Color(0x143D7BFF)),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: ValueListenableBuilder<UserProfile>(
                    valueListenable: _profileService.profile,
                    builder: (context, profile, _) {
                      return ValueListenableBuilder(
                        valueListenable: _sessionService.currentSession,
                        builder: (context, sessionState, _) {
                          final session = _homeService.getSessionData();

                          return Column(
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
                          );
                        },
                      );
                    },
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [LavifyColors.primaryStrong, LavifyColors.accent],
            ),
            boxShadow: LavifyTheme.panelShadow(context, floating: false),
          ),
          child: const Icon(Icons.water_drop_rounded, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Text(
          'Lavify',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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
          onPressed: () {
            // TODO: conectar registro o onboarding de lavadores.
          },
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
        Expanded(flex: 11, child: _HeroContent(session: session)),
        const SizedBox(width: 40),
        Expanded(
          flex: 9,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _PreviewCard(orderService: HomePage._orderService),
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
        _PreviewCard(orderService: HomePage._orderService),
      ],
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({required this.session});

  final HomeSessionData session;

  @override
  Widget build(BuildContext context) {
    final isLight = LavifyTheme.isLight(context);

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
            _StatusChip(
              label: 'Lavadores verificados',
              color: LavifyColors.primary,
            ),
          ],
        ),
        const SizedBox(height: 28),
        if (isLight)
          const _MetallicHeroCopy()
        else
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
              onPressed: () {
                // TODO: conectar scroll o navegacion a la seccion explicativa.
              },
            ),
          ],
        ),
        const SizedBox(height: 40),
        Divider(color: LavifyTheme.borderColor(context), height: 1),
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
  const _PreviewCard({required this.orderService});

  final OrderService orderService;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<WashOrder>>(
      valueListenable: orderService.orders,
      builder: (context, _, _) {
        final order = orderService.activeClientOrder;
        final isSearching = order?.status == OrderStatus.searching;
        final selectedPackage = order?.request.packageName;
        final badgeColor = order == null
            ? LavifyColors.primary
            : _statusColor(order.status);
        final badgeLabel = order == null
            ? 'Listo'
            : isSearching
            ? 'Buscando'
            : order.status.label;
        final mapLabel = order == null
            ? 'Explora tu siguiente lavado'
            : isSearching
            ? 'Buscando lavador cerca de ti'
            : order.etaMinutes > 0
            ? 'Llegando en ${order.etaMinutes} min'
            : order.status.label;
        final actionLabel = order == null
            ? 'Pedir tu primer lavado'
            : isSearching
            ? 'Solicitud enviada · \$${order.request.totalPrice}'
            : 'Servicio activo · \$${order.request.totalPrice}';

        return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LavifyTheme.premiumPanelGradient(context),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: LavifyTheme.borderColor(context)),
          boxShadow: LavifyTheme.panelShadow(context),
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
                      order == null
                          ? 'Seguimiento en vivo'
                          : isSearching
                          ? 'Buscando lavador'
                          : 'Seguimiento en vivo',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                    const Spacer(),
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0x336AA8FF),
                      child: Icon(Icons.person, color: LavifyColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 210,
                  child: order == null
                      ? Container(
                          decoration: BoxDecoration(
                            color: LavifyTheme.surfaceAltColor(context),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _MapGridPainter(
                                    gridColor: LavifyTheme.textSecondaryColor(
                                      context,
                                    ).withAlpha(30),
                                  ),
                                ),
                              ),
                              const Positioned(
                                top: 30,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Icon(
                                    Icons.radar_rounded,
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
                                    color: LavifyTheme.surfaceColor(context),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: LavifyTheme.borderColor(context),
                                    ),
                                  ),
                                  child: Text(
                                    mapLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: LavifyTheme.textPrimaryColor(
                                            context,
                                          ),
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Stack(
                          children: [
                            Positioned.fill(
                              child: LiveTrackingMap(
                                order: order,
                                compact: true,
                                borderRadius: 24,
                              ),
                            ),
                            Positioned(
                              right: 18,
                              bottom: 18,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: LavifyTheme.surfaceColor(context),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: LavifyTheme.borderColor(context),
                                  ),
                                ),
                                child: Text(
                                  mapLabel,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: LavifyTheme.textPrimaryColor(
                                          context,
                                        ),
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
                    color: LavifyTheme.surfaceAltColor(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: LavifyTheme.borderColor(context)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            order == null
                                ? 'Tipo de lavado'
                                : 'Estado del pedido',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: LavifyTheme.textPrimaryColor(context),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const Spacer(),
                          _MiniBadge(label: badgeLabel, color: badgeColor),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _OptionTile(
                              icon: Icons.local_car_wash_rounded,
                              label: 'Express',
                              selected: selectedPackage == 'Express',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _OptionTile(
                              icon: Icons.cleaning_services_rounded,
                              label: 'Full Care',
                              selected: selectedPackage == 'Full Care',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _OptionTile(
                              icon: Icons.auto_awesome_rounded,
                              label: 'Premium',
                              selected:
                                  selectedPackage == 'Premium' ||
                                  selectedPackage == null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      PrimaryButton(
                        label: actionLabel,
                        onPressed: () {
                          if (order == null) {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const RequestWashFlowPage(),
                              ),
                            );
                            return;
                          }

                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => OrderTrackingPage(order: order),
                            ),
                          );
                        },
                        isExpanded: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.searching:
        return const Color(0xFFFFC857);
      case OrderStatus.assigned:
      case OrderStatus.onTheWay:
        return LavifyColors.primary;
      case OrderStatus.arrived:
      case OrderStatus.inProgress:
        return const Color(0xFF9B7BFF);
      case OrderStatus.completed:
        return LavifyColors.success;
    }
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
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HowItWorksSection(),
        SizedBox(height: isCompact ? 36 : 56),
        Text(
          'Paquetes disponibles',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Elige el nivel de lavado y entra directo al flujo con el paquete preseleccionado.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontSize: isCompact ? 15 : 16),
        ),
        SizedBox(height: isCompact ? 12 : 16),
        Wrap(
          spacing: isCompact ? 10 : 14,
          runSpacing: isCompact ? 10 : 14,
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
        SizedBox(height: isCompact ? 40 : 56),
        Text(
          'Confianza Lavify',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Operamos con una experiencia clara para cliente y lavador desde el primer pedido.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontSize: isCompact ? 15 : 16),
        ),
        SizedBox(height: isCompact ? 12 : 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final spacing = isCompact ? 10.0 : 14.0;
            final compactWidth = (constraints.maxWidth - spacing) / 2;
            final expandedWidth = (constraints.maxWidth - spacing) / 2;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                _TrustCard(
                  width: isCompact ? compactWidth : expandedWidth,
                  icon: Icons.verified_user_rounded,
                  title: 'Lavadores verificados',
                  subtitle: 'Perfil validado y seguimiento continuo.',
                ),
                _TrustCard(
                  width: isCompact ? compactWidth : expandedWidth,
                  icon: Icons.lock_rounded,
                  title: 'Pagos seguros',
                  subtitle: 'Checkout y backend listos para operar.',
                ),
                _TrustCard(
                  width: isCompact ? compactWidth : expandedWidth,
                  icon: Icons.route_rounded,
                  title: 'Tracking en vivo',
                  subtitle: 'Ubicacion y progreso en una sola vista.',
                ),
                _TrustCard(
                  width: isCompact ? compactWidth : expandedWidth,
                  icon: Icons.support_agent_rounded,
                  title: 'Soporte',
                  subtitle: 'Atencion antes y despues del servicio.',
                ),
              ],
            );
          },
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
    final isLight = LavifyTheme.isLight(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: isLight
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFCF9),
                  Color(0xFFF1EBE4),
                ],
              )
            : null,
        color: isLight
            ? null
            : LavifyTheme.overlayPanelColor(context).withAlpha(180),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LavifyTheme.borderColor(context)),
        boxShadow: LavifyTheme.panelShadow(context, floating: false),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLight)
            Container(
              width: 72,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE4D1B1),
                    Color(0xFFF9F3EA),
                  ],
                ),
              ),
            ),
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
              Icon(
                Icons.timer_outlined,
                color: LavifyColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              if (isLight)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x66FFF8F0),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0x88D9C9B5)),
                  ),
                  child: Text(
                    'Tiempo estimado: ${session.etaLabel}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: LavifyColors.lightNavy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Text(
                  'Tiempo estimado: ${session.etaLabel}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: LavifyTheme.textPrimaryColor(context),
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

class _MetallicHeroCopy extends StatelessWidget {
  const _MetallicHeroCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF8F3EC),
                Color(0xFFEDE4D7),
              ],
            ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0x88D8C8B4)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14FFFFFF),
                blurRadius: 8,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF5E86FF),
                      Color(0xFF85A8FF),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Lavado premium a domicilio',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: LavifyColors.lightNavy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Text(
          'Lava tu auto',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: LavifyColors.lightTextPrimary,
            height: 0.92,
          ),
        ),
        const SizedBox(height: 6),
        const _HeroGradientText('sin salir\nde casa'),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            'Solicita un lavado desde tu celular y un profesional verificado llega a donde estas en minutos. Rapido, confiable y pensado para tu rutina.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: LavifyColors.lightTextSecondary,
              height: 1.7,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroGradientText extends StatelessWidget {
  const _HeroGradientText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headlineLarge?.copyWith(
      color: Colors.white,
      height: 0.92,
    );

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8EB5FF),
            Color(0xFF4A72F4),
            Color(0xFF5866F0),
          ],
        ).createShader(bounds);
      },
      child: Text(text, style: style),
    );
  }
}

class _TrustCard extends StatelessWidget {
  const _TrustCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final double width;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;
    final isLight = LavifyTheme.isLight(context);

    return RepaintBoundary(
      child: Container(
        width: width,
        padding: EdgeInsets.all(isCompact ? 14 : 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isCompact ? 20 : 24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLight
                ? const [Color(0xFFFFFCF8), Color(0xFFF3ECE4)]
                : const [Color(0xCC12203A), Color(0xCC0C1527)],
          ),
          border: Border.all(
            color: isLight
                ? const Color(0x88D9C9B5)
                : LavifyColors.primary.withAlpha(34),
          ),
          boxShadow: [
            BoxShadow(
              color: isLight
                  ? const Color(0x181D2432)
                  : Colors.black.withAlpha(28),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isCompact ? 36 : 42,
              height: isCompact ? 36 : 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isCompact ? 12 : 14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isLight
                        ? const Color(0x22D6B47B)
                        : LavifyColors.primary.withAlpha(34),
                    isLight ? Colors.white : Colors.white.withAlpha(8),
                  ],
                ),
                border: Border.all(
                  color: isLight
                      ? const Color(0x77D8C8B4)
                      : LavifyColors.primary.withAlpha(32),
                ),
              ),
              child: Icon(
                icon,
                color: isLight
                    ? LavifyColors.lightNavy
                    : LavifyColors.primary,
                size: isCompact ? 18 : 22,
              ),
            ),
            SizedBox(height: isCompact ? 12 : 14),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: isCompact ? 16 : 18,
                height: 1.05,
                color: isLight
                    ? LavifyColors.lightTextPrimary
                    : LavifyColors.textPrimary,
              ),
            ),
            SizedBox(height: isCompact ? 6 : 8),
            Text(
              subtitle,
              maxLines: isCompact ? 3 : 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: isCompact ? 12.5 : 13,
                height: 1.35,
                color: isLight
                    ? LavifyColors.lightTextSecondary
                    : Colors.white.withAlpha(150),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.size, required this.color});

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

class _NavLabel extends StatelessWidget {
  const _NavLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: LavifyTheme.textPrimaryColor(context).withAlpha(219),
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
        color: LavifyTheme.softFillColor(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: LavifyTheme.borderColor(context)),
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
              color: LavifyTheme.textPrimaryColor(context),
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
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label, this.color = LavifyColors.success});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: color,
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
        gradient: selected
            ? const LinearGradient(
                colors: [LavifyColors.primaryStrong, LavifyColors.primary],
              )
            : null,
        color: selected ? null : LavifyTheme.softFillColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected
              ? Colors.transparent
              : LavifyTheme.borderColor(context),
        ),
        boxShadow: selected
            ? LavifyTheme.panelShadow(context, floating: false)
            : null,
      ),
      child: Column(
        children: [
          Icon(icon, color: selected ? Colors.white : LavifyColors.primary),
          const SizedBox(height: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: selected
                  ? Colors.white
                  : LavifyTheme.textPrimaryColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  _MapGridPainter({required this.gridColor});

  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
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
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) =>
      oldDelegate.gridColor != gridColor;
}
