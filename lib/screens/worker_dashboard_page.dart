import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../services/location_service.dart';
import '../services/order_service.dart';
import '../services/profile_service.dart';
import '../services/worker_service.dart';
import '../theme/theme.dart';
import '../widgets/city_map_view.dart';
import 'worker_verification_page.dart';

class WorkerDashboardPage extends StatelessWidget {
  const WorkerDashboardPage({super.key});

  static final OrderService _orderService = OrderService();
  static final WorkerService _workerService = WorkerService();
  static final ProfileService _profileService = ProfileService();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _workerService.isAvailable,
      builder: (context, isOnline, _) {
        return ValueListenableBuilder<List<WashOrder>>(
          valueListenable: _orderService.orders,
          builder: (context, orders, _) {
            final available = orders
                .where((o) => o.status == OrderStatus.searching)
                .toList();
            final completed = orders
                .where((o) => o.status == OrderStatus.completed)
                .toList();
            final todayEarnings =
                completed.fold<int>(0, (s, o) => s + o.request.totalPrice);
            final stats = (
              today: '\$${(todayEarnings * 0.85).round()}',
              washes: '${completed.length}',
              rating: '4.9',
            );

            return Scaffold(
              body: Stack(
                children: [
                  // Map background
                  Positioned.fill(child: _WorkerMapBg(isOnline: isOnline)),

                  // Stats pills — below status bar
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        _StatPill(
                          label: 'HOY',
                          value: stats.today,
                          valueColor: LavifyColors.success,
                        ),
                        const SizedBox(width: 8),
                        _StatPill(
                          label: 'LAVADOS',
                          value: stats.washes,
                        ),
                        const SizedBox(width: 8),
                        _StatPill(
                          label: 'RATING',
                          value: '★ ${stats.rating}',
                          valueColor: LavifyColors.warning,
                        ),
                      ],
                    ),
                  ),

                  // Draggable bottom sheet
                  DraggableScrollableSheet(
                    initialChildSize: 0.54,
                    minChildSize: 0.34,
                    maxChildSize: 0.88,
                    snap: true,
                    snapSizes: const [0.54, 0.88],
                    builder: (ctx, sc) => _WorkerSheet(
                      scrollController: sc,
                      isOnline: isOnline,
                      availableJobs: available,
                      onToggle: () {
                        if (isOnline && _orderService.hasActiveWorkerOrder) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'No puedes pausar con un servicio en curso.',
                              ),
                            ),
                          );
                          return;
                        }
                        _workerService.toggleAvailability();
                      },
                    ),
                  ),

                  // Verification banner (floating at top when needed)
                  ValueListenableBuilder<UserProfile>(
                    valueListenable: _profileService.profile,
                    builder: (context, profile, _) {
                      if (profile.verificationStatus ==
                          WorkerVerificationStatus.approved) {
                        return const SizedBox.shrink();
                      }
                      return Positioned(
                        top: MediaQuery.of(context).padding.top + 72,
                        left: 16,
                        right: 16,
                        child: _FloatingVerificationBanner(
                          profile: profile,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Map background ──────────────────────────────────────────────────────────

class _WorkerMapBg extends StatefulWidget {
  const _WorkerMapBg({required this.isOnline});
  final bool isOnline;

  @override
  State<_WorkerMapBg> createState() => _WorkerMapBgState();
}

class _WorkerMapBgState extends State<_WorkerMapBg>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  static final _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = LavifyTheme.isLight(context);
    final pinColor =
        widget.isOnline ? LavifyColors.success : LavifyColors.primary;
    final cityId = _profileService.profile.value.cityId;
    final location =
        const LocationService().getDefaultLocation(cityId: cityId);

    return Stack(
      children: [
        // Mapa real de Mapbox centrado en la ciudad del lavador
        Positioned.fill(
          child: CityMapView(location: location, zoom: 13.0, borderRadius: 0),
        ),

        // Anillos pulsantes animados encima del mapa
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) => CustomPaint(
              painter: _MapAnimPainter(
                progress: _ctrl.value,
                isLight: isLight,
                isOnline: widget.isOnline,
              ),
            ),
          ),
        ),

        // Pin de ubicación centrado
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0, -0.22),
            child: Icon(
              Icons.location_on_rounded,
              size: 44,
              color: pinColor,
              shadows: [
                Shadow(color: pinColor.withAlpha(100), blurRadius: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Animated elements: pulse rings + demand dots
class _MapAnimPainter extends CustomPainter {
  const _MapAnimPainter({
    required this.progress,
    required this.isLight,
    required this.isOnline,
  });
  final double progress;
  final bool isLight;
  final bool isOnline;

  static const _demands = [
    (-0.28, -0.08, 0xFFF59E0B), // warning
    (0.22, 0.06, 0xFF10B981),   // success
    (-0.06, -0.16, 0xFF3B82F6), // primary
    (0.34, -0.10, 0xFFF59E0B),  // warning
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Center of visible map (top 46% of screen)
    final cx = size.width * 0.5;
    final cy = size.height * 0.20;

    if (isOnline) {
      // Demand dots with glow
      for (final (dx, dy, colorVal) in _demands) {
        final pos = Offset(cx + size.width * dx, cy + size.height * dy);
        final c = Color(0xFF000000 | colorVal);
        canvas.drawCircle(
          pos, 6,
          Paint()
            ..color = c.withValues(alpha: 50 / 255)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
        canvas.drawCircle(pos, 5, Paint()..color = c.withValues(alpha: 210 / 255));
        canvas.drawCircle(pos, 2, Paint()..color = Colors.white.withValues(alpha: 0.78));
      }
    }

    // Pulse rings
    final ringColor = isOnline ? LavifyColors.success : LavifyColors.primary;
    for (final offset in [0.0, 0.5]) {
      final p = (progress + offset) % 1.0;
      final r = 36 + p * 90;
      final ringAlpha = ((1 - p) * (isOnline ? 0.55 : 0.32)).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = ringColor.withValues(alpha: ringAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MapAnimPainter old) =>
      old.progress != progress ||
      old.isOnline != isOnline ||
      old.isLight != isLight;
}

// ── Stats pill ───────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: LavifyTheme.isLight(context)
              ? Colors.white.withAlpha(220)
              : LavifyColors.backgroundSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: LavifyTheme.borderColor(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: LavifyTheme.textSecondaryColor(context),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? LavifyTheme.textPrimaryColor(context),
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom sheet ─────────────────────────────────────────────────────────────

class _WorkerSheet extends StatelessWidget {
  const _WorkerSheet({
    required this.scrollController,
    required this.isOnline,
    required this.availableJobs,
    required this.onToggle,
  });

  final ScrollController scrollController;
  final bool isOnline;
  final List<WashOrder> availableJobs;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LavifyTheme.isLight(context)
            ? Colors.white
            : LavifyColors.backgroundSoft,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 40,
            offset: Offset(0, -12),
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
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: LavifyTheme.borderColor(context),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SlideToGoOnline(isOnline: isOnline, onToggle: onToggle),
                const SizedBox(height: 18),
                if (!isOnline) _OfflineContent() else _OnlineContent(jobs: availableJobs),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slide to go online ───────────────────────────────────────────────────────

class _SlideToGoOnline extends StatefulWidget {
  const _SlideToGoOnline({required this.isOnline, required this.onToggle});
  final bool isOnline;
  final VoidCallback onToggle;

  @override
  State<_SlideToGoOnline> createState() => _SlideToGoOnlineState();
}

class _SlideToGoOnlineState extends State<_SlideToGoOnline> {
  double _dragX = 0;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        const thumbSize = 56.0;
        final maxDx = trackWidth - thumbSize - 8;

        return GestureDetector(
          onHorizontalDragStart: (_) => setState(() {
            _dragging = true;
          }),
          onHorizontalDragUpdate: (d) => setState(() {
            _dragX = (_dragX + d.delta.dx).clamp(0, maxDx);
          }),
          onHorizontalDragEnd: (_) {
            if (_dragX > maxDx * 0.7 && !widget.isOnline) {
              widget.onToggle();
            }
            setState(() {
              _dragX = 0;
              _dragging = false;
            });
          },
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              gradient: widget.isOnline
                  ? null
                  : const LinearGradient(
                      colors: [
                        LavifyColors.primaryStrong,
                        LavifyColors.primary,
                      ],
                    ),
              color: widget.isOnline
                  ? LavifyColors.success.withAlpha(34)
                  : null,
              borderRadius: BorderRadius.circular(999),
              border: widget.isOnline
                  ? Border.all(color: LavifyColors.success.withAlpha(80))
                  : null,
              boxShadow: widget.isOnline
                  ? null
                  : [
                      BoxShadow(
                        color: LavifyColors.primaryGlow,
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _dragging ? 0.4 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.isOnline) ...[
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: LavifyColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.isOnline
                                ? 'En línea · toca para terminar turno'
                                : 'Desliza para empezar →',
                            style: TextStyle(
                              color: widget.isOnline
                                  ? LavifyColors.success
                                  : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: _dragging
                      ? Duration.zero
                      : const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  top: 4,
                  left: 4 + _dragX,
                  child: GestureDetector(
                    onTap: widget.isOnline ? widget.onToggle : null,
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: BoxDecoration(
                        color: widget.isOnline
                            ? LavifyColors.success
                            : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isOnline
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        color: widget.isOnline
                            ? Colors.white
                            : LavifyColors.primary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Offline content ──────────────────────────────────────────────────────────

class _OfflineContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: LavifyColors.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.local_car_wash_rounded,
                color: LavifyColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Estás fuera de turno',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: LavifyTheme.textPrimaryColor(context),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Inicia tu turno para empezar a recibir solicitudes en tu zona.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: LavifyTheme.textSecondaryColor(context),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            _HotZoneCard(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _HotZoneCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LavifyTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: LavifyColors.warning.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              size: 16,
              color: LavifyColors.warning,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zona caliente en Roma Norte',
                  style: TextStyle(
                    color: LavifyTheme.textPrimaryColor(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '5 solicitudes en 30 min · +15% tarifa',
                  style: TextStyle(
                    color: LavifyTheme.textSecondaryColor(context),
                    fontSize: 11,
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

// ── Online content (available jobs) ─────────────────────────────────────────

class _OnlineContent extends StatelessWidget {
  const _OnlineContent({required this.jobs});
  final List<WashOrder> jobs;

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return _NoJobsCard();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Jobs cerca de ti',
              style: TextStyle(
                color: LavifyTheme.textPrimaryColor(context),
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const Spacer(),
            Text(
              '${jobs.length} disponibles',
              style: TextStyle(
                color: LavifyTheme.textSecondaryColor(context),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...jobs.map(
          (j) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _JobCard(order: j),
          ),
        ),
      ],
    );
  }
}

class _NoJobsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LavifyTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_rounded,
            color: LavifyColors.primary,
            size: 28,
          ),
          const SizedBox(height: 10),
          Text(
            'Buscando solicitudes…',
            style: TextStyle(
              color: LavifyTheme.textPrimaryColor(context),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Te notificaremos en cuanto haya un job cerca.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: LavifyTheme.textSecondaryColor(context),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.order});
  final WashOrder order;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: LavifyTheme.surfaceColor(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: LavifyTheme.borderColor(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: LavifyColors.primarySoft,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.local_car_wash_rounded,
                  size: 20,
                  color: LavifyColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          order.request.packageName,
                          style: TextStyle(
                            color: LavifyTheme.textPrimaryColor(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: LavifyTheme.surfaceAltColor(context),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            order.request.vehicleTypeName,
                            style: TextStyle(
                              color: LavifyTheme.textSecondaryColor(context),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.request.address,
                      style: TextStyle(
                        color: LavifyTheme.textSecondaryColor(context),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${order.etaMinutes} min · ${order.request.scheduleLabel}',
                      style: TextStyle(
                        color: LavifyTheme.textSecondaryColor(context)
                            .withAlpha(150),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${order.request.totalPrice}',
                style: const TextStyle(
                  color: LavifyColors.success,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Floating verification banner ─────────────────────────────────────────────

class _FloatingVerificationBanner extends StatelessWidget {
  const _FloatingVerificationBanner({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final status = profile.verificationStatus;
    final (accent, icon, title) = switch (status) {
      WorkerVerificationStatus.pending => (
          LavifyColors.primary,
          Icons.hourglass_top_rounded,
          'Verificación en revisión',
        ),
      WorkerVerificationStatus.rejected => (
          LavifyColors.danger,
          Icons.cancel_outlined,
          'Verificación rechazada',
        ),
      _ => (
          LavifyColors.primary,
          Icons.verified_outlined,
          'Completa tu verificación',
        ),
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: LavifyTheme.overlayPanelColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withAlpha(60)),
        boxShadow: LavifyTheme.panelShadow(context),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: LavifyTheme.textPrimaryColor(context),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (status != WorkerVerificationStatus.pending)
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => WorkerVerificationPage(profile: profile),
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Verificar',
                style: TextStyle(
                  color: accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

