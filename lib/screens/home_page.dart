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
import 'role_login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const HomeService _homeService = HomeService();
  static final ProfileService _profileService = ProfileService();
  static final SessionService _sessionService = SessionService();

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _howItWorksKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToHowItWorks() {
    final ctx = _howItWorksKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1000;

    if (!isDesktop) return const _HomeMobileView();

    final horizontalPadding = isDesktop ? 72.0 : 24.0;
    final verticalPadding = isDesktop ? 40.0 : 24.0;
    final featuredPackages = _homeService.getFeaturedPackages();

    return Scaffold(
      body: Container(
        decoration: LavifyTheme.pageDecoration(context),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -40,
              child: _AmbientGlow(
                size: 320,
                color: LavifyTheme.isLight(context)
                    ? const Color(0x18D6B47B)
                    : const Color(0x1E6AA8FF),
              ),
            ),
            Positioned(
              bottom: -90,
              left: -30,
              child: _AmbientGlow(
                size: 260,
                color: LavifyTheme.isLight(context)
                    ? const Color(0x12C9A870)
                    : const Color(0x143D7BFF),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
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
                                _DesktopHero(
                                  session: session,
                                  onHowItWorks: _scrollToHowItWorks,
                                )
                              else
                                _MobileHero(
                                  session: session,
                                  onHowItWorks: _scrollToHowItWorks,
                                ),
                              const SizedBox(height: 56),
                              _FunctionalSection(
                                session: session,
                                featuredPackages: featuredPackages,
                                howItWorksKey: _howItWorksKey,
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
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const RoleLoginPage(
                  initialMode: AppRole.worker,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DesktopHero extends StatelessWidget {
  const _DesktopHero({required this.session, required this.onHowItWorks});

  final HomeSessionData session;
  final VoidCallback onHowItWorks;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 11,
          child: _HeroContent(session: session, onHowItWorks: onHowItWorks),
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
  const _MobileHero({required this.session, required this.onHowItWorks});

  final HomeSessionData session;
  final VoidCallback onHowItWorks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroContent(session: session, onHowItWorks: onHowItWorks),
        const SizedBox(height: 32),
        const _PreviewCard(),
      ],
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({required this.session, required this.onHowItWorks});

  final HomeSessionData session;
  final VoidCallback onHowItWorks;

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
              onPressed: onHowItWorks,
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
  const _PreviewCard();

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();
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
      case OrderStatus.cancelled:
        return const Color(0xFFFF6B6B);
    }
  }
}

class _FunctionalSection extends StatelessWidget {
  const _FunctionalSection({
    required this.session,
    required this.featuredPackages,
    required this.howItWorksKey,
  });

  final HomeSessionData session;
  final List<WashPackage> featuredPackages;
  final GlobalKey howItWorksKey;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HowItWorksSection(key: howItWorksKey),
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
                colors: [Color(0xFFFFFCF9), Color(0xFFF1EBE4)],
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
                  colors: [Color(0xFFE4D1B1), Color(0xFFF9F3EA)],
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
              Icon(Icons.timer_outlined, color: LavifyColors.primary, size: 18),
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
              colors: [Color(0xFFF8F3EC), Color(0xFFEDE4D7)],
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
                    colors: [Color(0xFF5E86FF), Color(0xFF85A8FF)],
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
    final style = Theme.of(
      context,
    ).textTheme.headlineLarge?.copyWith(color: Colors.white, height: 0.92);

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8EB5FF), Color(0xFF4A72F4), Color(0xFF5866F0)],
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
                ? const [Color(0xFFF4F5F7), Color(0xFFECEDF1)]
                : const [Color(0xFF22252F), Color(0xFF1A1C24)],
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
                color: isLight ? LavifyColors.lightNavy : LavifyColors.primary,
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
                color: LavifyTheme.textPrimaryColor(context),
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

// ── Mobile map-first home (Uber-style) ────────────────────────────────────────

class _HomeMobileView extends StatefulWidget {
  const _HomeMobileView();

  @override
  State<_HomeMobileView> createState() => _HomeMobileViewState();
}

class _HomeMobileViewState extends State<_HomeMobileView> {
  static final OrderService _orderService = OrderService();
  static final ProfileService _profileService = ProfileService();
  static final HomeService _homeService = HomeService();

  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _NotificationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = LavifyTheme.isLight(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: _MapBackground(isLight: isLight),
            ),
          ),

          // Top bar overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<UserProfile>(
                        valueListenable: _profileService.profile,
                        builder: (context, _, child) {
                          final addr =
                              _homeService.getSessionData().savedAddress;
                          return GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const RequestWashFlowPage(),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: LavifyTheme.overlayPanelColor(context),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color:
                                      LavifyTheme.navRailBorderColor(context),
                                ),
                                boxShadow: LavifyTheme.panelShadow(
                                  context,
                                  floating: false,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 15,
                                    color: LavifyColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      addr,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color:
                                                LavifyTheme.textPrimaryColor(
                                                  context,
                                                ),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color: LavifyTheme.textSecondaryColor(
                                      context,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _showNotificationSheet(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: LavifyTheme.overlayPanelColor(context),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: LavifyTheme.navRailBorderColor(context),
                          ),
                          boxShadow: LavifyTheme.panelShadow(
                            context,
                            floating: false,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.notifications_outlined,
                                size: 20,
                                color: LavifyTheme.textPrimaryColor(context),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 9,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: LavifyColors.danger,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: LavifyTheme.overlayPanelColor(
                                      context,
                                    ),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Active order floating card
          ValueListenableBuilder<List<WashOrder>>(
            valueListenable: _orderService.orders,
            builder: (context, _, child) {
              final order = _orderService.activeClientOrder;
              if (order == null) return const SizedBox.shrink();
              return Positioned(
                top: MediaQuery.of(context).padding.top + 64,
                left: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => OrderTrackingPage(order: order),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          LavifyColors.primaryStrong,
                          LavifyColors.primary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: LavifyTheme.panelShadow(
                        context,
                        floating: false,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.local_car_wash_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EN CAMINO · ${order.etaMinutes} MIN',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${order.request.packageName} · Ver en mapa',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          Positioned(
            right: 20,
            bottom: MediaQuery.of(context).size.height * 0.42 + 16,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: LavifyTheme.overlayPanelColor(context),
                shape: BoxShape.circle,
                border: Border.all(color: LavifyTheme.navRailBorderColor(context)),
                boxShadow: LavifyTheme.panelShadow(context, floating: false),
              ),
              child: Icon(
                Icons.navigation_rounded,
                color: LavifyColors.primary,
                size: 20,
              ),
            ),
          ),

          // Draggable bottom sheet
          DraggableScrollableSheet(
            initialChildSize: 0.42,
            minChildSize: 0.42,
            maxChildSize: 0.85,
            snap: true,
            snapSizes: const [0.42, 0.85],
            builder: (context, scrollController) => _HomeBottomSheet(
              scrollController: scrollController,
              packages: _homeService.getFeaturedPackages(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapBackground extends StatelessWidget {
  const _MapBackground({required this.isLight});
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MapBackgroundPainter(isLight: isLight),
      isComplex: true,
      willChange: false,
      child: const SizedBox.expand(),
    );
  }
}

class _MapBackgroundPainter extends CustomPainter {
  _MapBackgroundPainter({required this.isLight});
  final bool isLight;

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color =
            isLight ? const Color(0xFFE8ECEF) : const Color(0xFF0E1117),
    );

    // Fine grid
    final gridPaint = Paint()
      ..color = (isLight
              ? const Color(0xFF50648C)
              : const Color(0xFF7890B4))
          .withAlpha(isLight ? 25 : 15)
      ..strokeWidth = 0.5;
    for (var x = 0.0; x < size.width; x += 22) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y < size.height; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Horizontal roads
    final roadH = Paint()
      ..color =
          isLight ? const Color(0x733C5078) : const Color(0x2EB4C8FF)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 14; i++) {
      final y = (i * 60.0 + 24) % (size.height + 20);
      final slant = (i % 4 == 0) ? 8.0 : 0.0;
      canvas.drawLine(
        Offset(-20 + slant, y),
        Offset(size.width + 20, y + 5),
        roadH,
      );
    }

    // Vertical avenues
    final ave = Paint()
      ..color =
          isLight ? const Color(0x733C5078) : const Color(0x38B4C8FF)
      ..strokeCap = StrokeCap.round;
    ave.strokeWidth = 1.8;
    canvas.drawLine(
      Offset(size.width * 0.22, 0),
      Offset(size.width * 0.24, size.height),
      ave,
    );
    ave.strokeWidth = 2.4;
    canvas.drawLine(
      Offset(size.width * 0.55, 0),
      Offset(size.width * 0.57, size.height),
      ave,
    );
    ave.strokeWidth = 1.8;
    canvas.drawLine(
      Offset(size.width * 0.82, 0),
      Offset(size.width * 0.80, size.height),
      ave,
    );

    // Building blocks
    final blockFill = Paint()
      ..color = (isLight
              ? Colors.black
              : Colors.white)
          .withAlpha(isLight ? 7 : 4)
      ..style = PaintingStyle.fill;
    final blockStroke = Paint()
      ..color =
          isLight ? const Color(0x1A50648C) : const Color(0x147890B4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;
    const blocks = [
      [38.0, 110.0, 76.0, 66.0],
      [148.0, 92.0, 58.0, 72.0],
      [238.0, 124.0, 68.0, 78.0],
      [48.0, 250.0, 88.0, 62.0],
      [168.0, 268.0, 72.0, 82.0],
      [276.0, 240.0, 62.0, 72.0],
      [38.0, 410.0, 78.0, 68.0],
      [152.0, 428.0, 82.0, 72.0],
      [268.0, 400.0, 68.0, 78.0],
    ];
    for (final b in blocks) {
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(b[0], b[1], b[2], b[3]),
        const Radius.circular(3),
      );
      canvas.drawRRect(rr, blockFill);
      canvas.drawRRect(rr, blockStroke);
    }

    final parkRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.56, size.height * 0.2, 78, 96),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      parkRect,
      Paint()
        ..color = (isLight ? const Color(0xFF10B981) : const Color(0xFF10B981))
            .withAlpha(isLight ? 30 : 18),
    );

    // Water body
    final waterPath = Path()
      ..moveTo(-20, size.height * 0.74)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.71,
        size.width * 0.5,
        size.height * 0.73,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.75,
        size.width + 20,
        size.height * 0.72,
      )
      ..lineTo(size.width + 20, size.height + 10)
      ..lineTo(-20, size.height + 10)
      ..close();
    canvas.drawPath(
      waterPath,
      Paint()
        ..color = (isLight
                ? const Color(0xFFC5D4E0)
                : const Color(0xFF0A1628))
            .withAlpha(isLight ? 180 : 150),
    );

    // Destination pin (center-ish)
    const px = 196.0;
    const py = 310.0;

    canvas.drawCircle(
      const Offset(px, py),
      26,
      Paint()..color = LavifyColors.primary.withAlpha(38),
    );
    canvas.drawCircle(
      const Offset(px, py),
      18,
      Paint()..color = LavifyColors.primary.withAlpha(55),
    );

    final pinPath = Path()
      ..moveTo(px, py - 22)
      ..cubicTo(px - 10, py - 22, px - 16, py - 14, px - 16, py - 6)
      ..cubicTo(px - 16, py + 4, px, py + 14, px, py + 14)
      ..cubicTo(px, py + 14, px + 16, py + 4, px + 16, py - 6)
      ..cubicTo(px + 16, py - 14, px + 10, py - 22, px, py - 22)
      ..close();
    canvas.drawPath(
      pinPath,
      Paint()
        ..color = LavifyColors.primary
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      pinPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      const Offset(px, py - 7),
      4,
      Paint()..color = Colors.white,
    );

    _paintMapLabel(
      canvas,
      'AV. REFORMA',
      Offset(size.width * 0.58, size.height * 0.19),
    );
    _paintMapLabel(
      canvas,
      'POLANCO',
      Offset(size.width * 0.08, size.height * 0.56),
    );
    _paintMapLabel(
      canvas,
      'ROMA NORTE',
      Offset(size.width * 0.62, size.height * 0.68),
    );
  }

  void _paintMapLabel(Canvas canvas, String text, Offset offset) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: (isLight ? const Color(0xFF455064) : Colors.white)
              .withAlpha(isLight ? 72 : 48),
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _MapBackgroundPainter old) =>
      old.isLight != isLight;
}

class _HomeBottomSheet extends StatelessWidget {
  const _HomeBottomSheet({
    required this.scrollController,
    required this.packages,
  });

  final ScrollController scrollController;
  final List<WashPackage> packages;

  @override
  Widget build(BuildContext context) {
    final isLight = LavifyTheme.isLight(context);

    return Container(
      decoration: BoxDecoration(
        color: LavifyTheme.overlayPanelColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.zero,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: LavifyTheme.borderColor(context),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Lavamos tu auto?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: LavifyTheme.textPrimaryColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lavadores disponibles a 5 min de ti',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: LavifyTheme.textSecondaryColor(context),
                  ),
                ),
                const SizedBox(height: 14),

                // Big CTA
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const RequestWashFlowPage(),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: LavifyTheme.textPrimaryColor(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isLight
                                ? LavifyColors.lightBackground
                                : LavifyColors.background,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.water_drop_rounded,
                            color: LavifyColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pedir lavado ahora',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isLight
                                      ? LavifyColors.lightBackground
                                      : LavifyColors.background,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                'Llega en ~20 min · desde \$99',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: (isLight
                                          ? LavifyColors.lightBackground
                                          : LavifyColors.background)
                                      .withAlpha(170),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: isLight
                              ? LavifyColors.lightBackground
                              : LavifyColors.background,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),
                Text(
                  'PAQUETES',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: LavifyTheme.textSecondaryColor(context),
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // Package shortcuts
          SizedBox(
            height: 152,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: packages.length,
              itemBuilder: (context, i) =>
                  _PackageShortcutCard(package: packages[i]),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _RecentOrdersSection(),
                const SizedBox(height: 18),

                // Promo card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        LavifyColors.primaryStrong,
                        LavifyColors.primary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -24,
                        bottom: -24,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: const BoxDecoration(
                            color: Colors.white10,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lavado nocturno',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '20% off en tu primer\nlavado de noche',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Reclamar',
                              style: TextStyle(
                                color: LavifyColors.primaryStrong,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'NUEVO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentOrdersSection extends StatelessWidget {
  const _RecentOrdersSection();

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();

    return ValueListenableBuilder<List<WashOrder>>(
      valueListenable: orderService.orders,
      builder: (context, _, child) {
        final recentOrders = orderService.clientVisibleOrders
            .where((order) => order.status == OrderStatus.completed)
            .take(2)
            .toList(growable: false);

        if (recentOrders.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RECIENTES',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: LavifyTheme.textSecondaryColor(context),
                letterSpacing: 0.7,
              ),
            ),
            const SizedBox(height: 10),
            ...recentOrders.map((order) => _RecentOrderTile(order: order)),
          ],
        );
      },
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  const _RecentOrderTile({required this.order});

  final WashOrder order;

  @override
  Widget build(BuildContext context) {
    final date = '${order.createdAt.day}/${order.createdAt.month}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: LavifyTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: LavifyTheme.selectedTileSoftColor(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.history_rounded,
              color: LavifyTheme.textSecondaryColor(context),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${order.request.packageName} · \$${order.request.totalPrice}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: LavifyTheme.textPrimaryColor(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.request.address} · $date',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: LavifyTheme.textSecondaryColor(context),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => RequestWashFlowPage(
                  initialPackage: washPackages.firstWhere(
                    (package) => package.id == order.request.packageId,
                    orElse: () => washPackages.first,
                  ),
                ),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: LavifyTheme.selectedTileColor(context),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Repetir',
                style: TextStyle(
                  color: LavifyColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageShortcutCard extends StatelessWidget {
  const _PackageShortcutCard({required this.package});
  final WashPackage package;

  @override
  Widget build(BuildContext context) {
    final isPopular = package.id == 'full-care';

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => RequestWashFlowPage(initialPackage: package),
        ),
      ),
      child: Container(
        width: 118,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: LavifyTheme.surfaceColor(context),
          border: Border.all(
            color: isPopular
                ? LavifyColors.primary
                : LavifyTheme.borderColor(context),
            width: isPopular ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPopular) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: LavifyColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: LavifyColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(package.icon, size: 15, color: LavifyColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              package.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: LavifyTheme.textPrimaryColor(context),
                fontSize: 13,
              ),
            ),
            Text(
              package.durationLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: LavifyTheme.textSecondaryColor(context),
                fontSize: 10,
              ),
            ),
            const Spacer(),
            Text(
              package.formattedPrice,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: LavifyTheme.textPrimaryColor(context),
                fontSize: 16,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
      decoration: BoxDecoration(
        color: LavifyTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: LavifyTheme.textPrimaryColor(context),
              fontSize: 16,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: LavifyTheme.textSecondaryColor(context),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notification sheet ─────────────────────────────────────────────────────

enum _NotifFilter { all, orders, promos }

enum _NotifCategory { order, promo, system }

class _NotifData {
  const _NotifData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isUnread,
    required this.category,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final bool isUnread;
  final _NotifCategory category;
}

class _NotificationSheet extends StatefulWidget {
  const _NotificationSheet();

  @override
  State<_NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<_NotificationSheet> {
  _NotifFilter _filter = _NotifFilter.all;

  static const _items = [
    _NotifData(
      icon: Icons.local_car_wash_rounded,
      iconColor: LavifyColors.primary,
      title: 'Carlos llegó a tu ubicación',
      subtitle: 'Tu lavador está listo para empezar.',
      time: 'hace 2 min',
      isUnread: true,
      category: _NotifCategory.order,
    ),
    _NotifData(
      icon: Icons.local_offer_rounded,
      iconColor: LavifyColors.warning,
      title: '20% off en tu próximo Premium',
      subtitle: 'Usa el código PREMIUM20 antes del 30/Abr.',
      time: 'hace 3 h',
      isUnread: true,
      category: _NotifCategory.promo,
    ),
    _NotifData(
      icon: Icons.check_rounded,
      iconColor: LavifyColors.success,
      title: 'Lavado completado · Full Care',
      subtitle: 'Tu auto en Av. Reforma 245.',
      time: 'ayer',
      isUnread: false,
      category: _NotifCategory.order,
    ),
    _NotifData(
      icon: Icons.shield_rounded,
      iconColor: LavifyColors.primary,
      title: 'Verificación de cuenta lista',
      subtitle: 'Ya puedes solicitar lavados premium.',
      time: 'lun',
      isUnread: false,
      category: _NotifCategory.system,
    ),
    _NotifData(
      icon: Icons.auto_awesome_rounded,
      iconColor: LavifyColors.warning,
      title: 'Nuevo: lavado nocturno',
      subtitle: 'Disponible de 19:00 a 23:00 hrs.',
      time: '24/Abr',
      isUnread: false,
      category: _NotifCategory.promo,
    ),
  ];

  List<_NotifData> get _filtered => switch (_filter) {
    _NotifFilter.all => _items,
    _NotifFilter.orders =>
      _items.where((n) => n.category == _NotifCategory.order).toList(),
    _NotifFilter.promos =>
      _items.where((n) => n.category == _NotifCategory.promo).toList(),
  };

  int get _unreadCount => _items.where((n) => n.isUnread).length;

  @override
  Widget build(BuildContext context) {
    final isLight = LavifyTheme.isLight(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: isLight ? Colors.white : LavifyColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: LavifyTheme.borderColor(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: LavifyTheme.surfaceAltColor(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: LavifyTheme.borderColor(context),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: LavifyTheme.textPrimaryColor(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Notificaciones',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: LavifyColors.primary,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    child: const Text('Marcar leídas'),
                  ),
                ],
              ),
            ),
            // Filter tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  _NotifFilterTab(
                    label: 'Todas',
                    selected: _filter == _NotifFilter.all,
                    badge: _unreadCount > 0 ? _unreadCount : null,
                    onTap: () => setState(() => _filter = _NotifFilter.all),
                  ),
                  const SizedBox(width: 8),
                  _NotifFilterTab(
                    label: 'Pedidos',
                    selected: _filter == _NotifFilter.orders,
                    onTap: () =>
                        setState(() => _filter = _NotifFilter.orders),
                  ),
                  const SizedBox(width: 8),
                  _NotifFilterTab(
                    label: 'Promos',
                    selected: _filter == _NotifFilter.promos,
                    onTap: () =>
                        setState(() => _filter = _NotifFilter.promos),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // List
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  MediaQuery.of(context).padding.bottom + 16,
                ),
                itemCount: _filtered.length,
                separatorBuilder: (context, i) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _NotifItem(data: _filtered[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifFilterTab extends StatelessWidget {
  const _NotifFilterTab({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final isLight = LavifyTheme.isLight(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? LavifyTheme.textPrimaryColor(context)
              : LavifyTheme.surfaceAltColor(context),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: LavifyTheme.borderColor(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? (isLight ? Colors.white : LavifyColors.background)
                    : LavifyTheme.textSecondaryColor(context),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withAlpha(40)
                      : LavifyColors.primarySoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$badge',
                  style: TextStyle(
                    color: selected ? Colors.white : LavifyColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotifItem extends StatelessWidget {
  const _NotifItem({required this.data});

  final _NotifData data;

  @override
  Widget build(BuildContext context) {
    final isLight = LavifyTheme.isLight(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: data.isUnread
            ? (isLight
                  ? LavifyColors.primarySoft
                  : const Color(0x0A3B82F6))
            : LavifyTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: data.isUnread
              ? LavifyColors.primary.withAlpha(50)
              : LavifyTheme.borderColor(context),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: data.iconColor.withAlpha(isLight ? 28 : 22),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(data.icon, color: data.iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        data.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: LavifyTheme.textPrimaryColor(context),
                          fontWeight: data.isUnread
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          data.time,
                          style: TextStyle(
                            color: LavifyTheme.textSecondaryColor(context),
                            fontSize: 11,
                          ),
                        ),
                        if (data.isUnread) ...[
                          const SizedBox(width: 4),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: LavifyColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  data.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: LavifyTheme.textSecondaryColor(context),
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
