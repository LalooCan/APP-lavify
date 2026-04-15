import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../services/order_service.dart';
import '../services/worker_service.dart';
import '../theme/theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import 'worker_services_page.dart';

class WorkerDashboardPage extends StatelessWidget {
  const WorkerDashboardPage({super.key});

  static final OrderService _orderService = OrderService();
  static final WorkerService _workerService = WorkerService();

  @override
  Widget build(BuildContext context) {
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
                      onToggleAvailability: _workerService.toggleAvailability,
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
          Text(
            'Agenda visible',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 18),
          if (visibleOrders.isEmpty)
            Text(
              'Aun no tienes servicios cargados.',
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
