import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../services/order_service.dart';
import '../services/worker_service.dart';
import '../theme/theme.dart';
import '../widgets/live_tracking_map.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import 'worker_services_page.dart';

class WorkerDashboardPage extends StatelessWidget {
  const WorkerDashboardPage({super.key});

  static final OrderService _orderService = OrderService();
  static final WorkerService _workerService = WorkerService();

  @override
  Widget build(BuildContext context) {
    void handleToggleAvailability() {
      final isAvailable = _workerService.isAvailable.value;
      if (isAvailable && _orderService.hasActiveWorkerOrder) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No puedes pausar tu disponibilidad mientras tienes un servicio en curso.',
            ),
          ),
        );
        return;
      }

      _workerService.toggleAvailability();
    }

    return Scaffold(
      body: Container(
        decoration: LavifyTheme.pageDecoration(context),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panel del trabajador',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  'Consulta tu disponibilidad, servicios activos y avance del dia.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                ValueListenableBuilder<bool>(
                  valueListenable: _workerService.isAvailable,
                  builder: (context, isAvailable, _) {
                    return _HeroCard(
                      isAvailable: isAvailable,
                      onToggleAvailability: handleToggleAvailability,
                      onOpenServices: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const WorkerServicesPage(),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                ValueListenableBuilder<List<WashOrder>>(
                  valueListenable: _orderService.orders,
                  builder: (context, _, _) {
                    final activeOrder = _orderService.activeWorkerOrder;
                    if (activeOrder == null) {
                      return const SizedBox.shrink();
                    }

                    return _AcceptedJobPanel(
                      order: activeOrder,
                      onOpenServices: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const WorkerServicesPage(),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                ValueListenableBuilder<List<WashOrder>>(
                  valueListenable: _orderService.orders,
                  builder: (context, _, _) {
                    final orders = _orderService.workerVisibleOrders;
                    return _StatsRow(orders: orders);
                  },
                ),
                const SizedBox(height: 20),
                ValueListenableBuilder<List<WashOrder>>(
                  valueListenable: _orderService.orders,
                  builder: (context, _, _) {
                    final orders = _orderService.workerVisibleOrders;
                    return _AgendaCard(orders: orders);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.isAvailable,
    required this.onToggleAvailability,
    required this.onOpenServices,
  });

  final bool isAvailable;
  final VoidCallback onToggleAvailability;
  final VoidCallback onOpenServices;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LavifyTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: isAvailable
                        ? const [LavifyColors.success, Color(0xFF3BE28F)]
                        : const [
                            LavifyColors.primaryStrong,
                            LavifyColors.primary,
                          ],
                  ),
                ),
                child: const Icon(
                  Icons.local_car_wash_rounded,
                  color: LavifyColors.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAvailable
                          ? 'Disponible para tomar servicios'
                          : 'Disponibilidad pausada',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAvailable
                          ? 'Ya puedes aceptar nuevas solicitudes desde la seccion de servicios.'
                          : 'Activa tu disponibilidad para empezar a recibir trabajo.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              PrimaryButton(
                label: isAvailable
                    ? 'Pausar disponibilidad'
                    : 'Activar disponibilidad',
                icon: isAvailable
                    ? Icons.pause_circle_outline_rounded
                    : Icons.play_circle_outline_rounded,
                onPressed: onToggleAvailability,
              ),
              SecondaryButton(
                label: 'Ver servicios',
                icon: Icons.schedule_rounded,
                onPressed: onOpenServices,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AcceptedJobPanel extends StatelessWidget {
  const _AcceptedJobPanel({required this.order, required this.onOpenServices});

  final WashOrder order;
  final VoidCallback onOpenServices;

  @override
  Widget build(BuildContext context) {
    final accent = _statusColor(order.status);
    final progressLabel = _progressLabel(order);
    final helperLabel = _helperLabel(order);
    final etaLabel = order.etaMinutes > 0
        ? '${order.etaMinutes} min'
        : order.status == OrderStatus.arrived
        ? 'En sitio'
        : order.status == OrderStatus.inProgress
        ? 'En proceso'
        : 'Sin ETA';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LavifyTheme.overlayPanelColor(context),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: LavifyTheme.borderColor(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [LavifyColors.primaryStrong, LavifyColors.primary],
                  ),
                ),
                child: const Icon(Icons.route_rounded, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trabajo aceptado',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      helperLabel,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              _StatusBadge(label: progressLabel, color: accent),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: LavifyTheme.surfaceAltColor(context),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: LavifyTheme.borderColor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 180,
                  child: LiveTrackingMap(
                    order: order,
                    compact: true,
                    borderRadius: 20,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  order.request.packageName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  order.request.address,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: LavifyTheme.textPrimaryColor(context),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InfoPill(
                      icon: Icons.schedule_rounded,
                      label: order.request.scheduleLabel,
                    ),
                    _InfoPill(
                      icon: Icons.directions_car_filled_rounded,
                      label: order.request.vehicleTypeName,
                    ),
                    _InfoPill(
                      icon: Icons.timer_rounded,
                      label: etaLabel,
                      accent: accent,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total del servicio: \$${order.request.totalPrice} ${order.request.currency}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: LavifyTheme.textPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 220,
                child: PrimaryButton(
                  label: 'Abrir panel del servicio',
                  icon: Icons.open_in_new_rounded,
                  onPressed: onOpenServices,
                  isExpanded: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _statusColor(OrderStatus status) {
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

  static String _progressLabel(WashOrder order) {
    switch (order.status) {
      case OrderStatus.assigned:
        return 'Preparando salida';
      case OrderStatus.onTheWay:
        return 'En camino';
      case OrderStatus.arrived:
        return 'Ya llegaste';
      case OrderStatus.inProgress:
        return 'Lavando';
      case OrderStatus.completed:
        return 'Completado';
      case OrderStatus.searching:
        return 'Disponible';
    }
  }

  static String _helperLabel(WashOrder order) {
    switch (order.status) {
      case OrderStatus.assigned:
        return 'Confirma ruta y sal a tiempo al punto del servicio.';
      case OrderStatus.onTheWay:
        return 'Manten actualizado el avance mientras vas al cliente.';
      case OrderStatus.arrived:
        return 'Marca inicio cuando estes listo para comenzar el lavado.';
      case OrderStatus.inProgress:
        return 'Sigue el servicio y completa el trabajo al terminar.';
      case OrderStatus.completed:
        return 'Este servicio ya quedo terminado.';
      case OrderStatus.searching:
        return 'Aun no hay un trabajo tomado.';
    }
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.orders});

  final List<WashOrder> orders;

  @override
  Widget build(BuildContext context) {
    final activeOrders = orders
        .where((order) => order.status != OrderStatus.completed)
        .length;
    final pendingPickup = orders
        .where((order) => order.status == OrderStatus.searching)
        .length;
    final completedOrders = orders
        .where((order) => order.status == OrderStatus.completed)
        .length;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _StatCard(
          title: '$activeOrders',
          subtitle: 'Servicios activos',
          icon: Icons.local_shipping_rounded,
        ),
        _StatCard(
          title: '$pendingPickup',
          subtitle: 'Por aceptar',
          icon: Icons.notifications_active_rounded,
        ),
        _StatCard(
          title: '$completedOrders',
          subtitle: 'Completados',
          icon: Icons.task_alt_rounded,
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label, this.accent});

  final IconData icon;
  final String label;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final resolvedAccent = accent ?? LavifyColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: LavifyTheme.softFillStrongColor(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: resolvedAccent),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: LavifyTheme.textPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LavifyTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: LavifyColors.primary),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _AgendaCard extends StatelessWidget {
  const _AgendaCard({required this.orders});

  final List<WashOrder> orders;

  @override
  Widget build(BuildContext context) {
    final visibleOrders = orders.take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: LavifyTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Agenda visible', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 18),
          if (visibleOrders.isEmpty)
            Text(
              'Cuando aceptes servicios, aqui veras tus proximos trabajos.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            ...visibleOrders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AgendaItem(order: order),
              ),
            ),
        ],
      ),
    );
  }
}

class _AgendaItem extends StatelessWidget {
  const _AgendaItem({required this.order});

  final WashOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LavifyTheme.softFillStrongColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0x1A22C1FF),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: Text(
              order.request.scheduleLabel.split(' - ').last,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: LavifyColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${order.request.packageName} en ${order.request.address}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: LavifyColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.request.vehicleTypeName} · ${order.status.label}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
