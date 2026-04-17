import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../services/order_service.dart';
import '../theme/theme.dart';
import 'order_tracking_page.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  static final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: LavifyTheme.pageDecoration(context),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pedidos',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  'Aqui puedes revisar el estado y el historial de tus servicios.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                ValueListenableBuilder<List<WashOrder>>(
                  valueListenable: _orderService.orders,
                  builder: (context, _, _) {
                    final activeOrder = _orderService.activeClientOrder;
                    if (activeOrder == null) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _ActiveOrderBanner(order: activeOrder),
                    );
                  },
                ),
                Expanded(
                  child: ValueListenableBuilder<List<WashOrder>>(
                    valueListenable: _orderService.orders,
                    builder: (context, _, _) {
                      final orders = _orderService.clientVisibleOrders;
                      if (orders.isEmpty) {
                        return const _EmptyOrdersState();
                      }

                      return ListView.separated(
                        itemCount: orders.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          return _OrderCard(order: orders[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveOrderBanner extends StatelessWidget {
  const _ActiveOrderBanner({required this.order});

  final WashOrder order;

  @override
  Widget build(BuildContext context) {
    final accent = _statusAccent(order.status);
    final helper = order.status == OrderStatus.searching
        ? 'Tu solicitud sigue buscando un lavador disponible.'
        : order.status == OrderStatus.completed
        ? 'Tu ultimo servicio ya fue completado.'
        : 'Tu pedido activo sigue avanzando. Puedes abrir el seguimiento cuando quieras.';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => OrderTrackingPage(order: order),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: LavifyTheme.overlayPanelColor(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: LavifyTheme.borderColor(context)),
            boxShadow: LavifyTheme.panelShadow(context, floating: false),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent.withAlpha(24),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.route_rounded, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedido activo',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(helper, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                order.status.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusAccent(OrderStatus status) {
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

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final WashOrder order;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => OrderTrackingPage(order: order),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: LavifyTheme.surfaceColor(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: LavifyTheme.borderColor(context)),
            boxShadow: LavifyTheme.panelShadow(context, floating: false),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    order.request.packageName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _statusAccent(order.status).withAlpha(22),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: _statusAccent(order.status).withAlpha(40),
                      ),
                    ),
                    child: Text(
                      order.status.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _statusAccent(order.status),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                order.request.address,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '${order.request.scheduleLabel} · ${order.request.vehicleTypeName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '\$${order.request.totalPrice} ${order.request.currency}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: LavifyColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    'Ver detalle',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: LavifyTheme.textSecondaryColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusAccent(OrderStatus status) {
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

class _EmptyOrdersState extends StatelessWidget {
  const _EmptyOrdersState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: LavifyTheme.surfaceColor(context),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: LavifyTheme.borderColor(context)),
          boxShadow: LavifyTheme.panelShadow(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 42,
              color: LavifyTheme.textSecondaryColor(context),
            ),
            const SizedBox(height: 14),
            Text(
              'Aun no tienes pedidos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando confirmes tu primer lavado, aqui podras revisar su estado y abrir el seguimiento.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
