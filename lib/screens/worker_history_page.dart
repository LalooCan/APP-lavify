import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../services/order_service.dart';
import '../theme/theme.dart';

class WorkerHistoryPage extends StatelessWidget {
  const WorkerHistoryPage({super.key});

  static final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<WashOrder>>(
      valueListenable: _orderService.orders,
      builder: (context, orders, _) {
        final completed = orders
            .where((o) => o.status == OrderStatus.completed)
            .toList();

        return Scaffold(
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                  Text(
                    'Historial',
                    style: TextStyle(
                      color: LavifyTheme.textPrimaryColor(context),
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Todos tus lavados completados',
                    style: TextStyle(
                      color: LavifyTheme.textSecondaryColor(context),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 22),
                  if (completed.isEmpty)
                    _EmptyState()
                  else
                    ..._buildGroups(context, completed),
                ],
              ),
            ),
          ),
        ),
      ),
        );
      },
    );
  }

  List<Widget> _buildGroups(BuildContext context, List<WashOrder> orders) {
    return [
      _HistoryGroup(label: 'Recientes', orders: orders),
    ];
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: LavifyTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: LavifyColors.primarySoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.local_car_wash_rounded,
              color: LavifyColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin lavados aún',
            style: TextStyle(
              color: LavifyTheme.textPrimaryColor(context),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tus lavados completados aparecerán aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: LavifyTheme.textSecondaryColor(context),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryGroup extends StatelessWidget {
  const _HistoryGroup({required this.label, required this.orders});
  final String label;
  final List<WashOrder> orders;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: LavifyTheme.textSecondaryColor(context),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 10),
        ...orders.map((o) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _HistoryCard(order: o),
        )),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.order});
  final WashOrder order;

  @override
  Widget build(BuildContext context) {
    final earned = (order.request.totalPrice * 0.85).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LavifyTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.request.packageName,
                      style: TextStyle(
                        color: LavifyTheme.textPrimaryColor(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${order.customerEmail.split('@').first} · ${order.request.vehicleTypeName}',
                      style: TextStyle(
                        color: LavifyTheme.textSecondaryColor(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+\$$earned',
                    style: const TextStyle(
                      color: LavifyColors.success,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    order.request.scheduleLabel,
                    style: TextStyle(
                      color: LavifyTheme.textSecondaryColor(context),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                Divider(
                  color: LavifyTheme.borderColor(context),
                  height: 1,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                ...List.generate(5, (i) => Icon(
                  Icons.star_rounded,
                  size: 11,
                  color: i < 5
                      ? LavifyColors.warning
                      : LavifyTheme.borderColor(context),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
