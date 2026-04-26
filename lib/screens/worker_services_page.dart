import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../services/order_service.dart';
import '../services/worker_service.dart';
import '../theme/theme.dart';
import '../widgets/live_tracking_map.dart';
import '../widgets/primary_button.dart';

class WorkerServicesPage extends StatefulWidget {
  const WorkerServicesPage({super.key});

  @override
  State<WorkerServicesPage> createState() => _WorkerServicesPageState();
}

class _WorkerServicesPageState extends State<WorkerServicesPage> {
  static final OrderService _orderService = OrderService();
  static final WorkerService _workerService = WorkerService();

  String? _busyOrderId;

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
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Servicios',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Acepta solicitudes, avanza estados y completa servicios desde aqui.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 18),
                ValueListenableBuilder<bool>(
                  valueListenable: _workerService.isAvailable,
                  builder: (context, isAvailable, _) {
                    return _AvailabilityBanner(
                      isAvailable: isAvailable,
                      onToggle: _handleToggleAvailability,
                    );
                  },
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _workerService.isAvailable,
                    builder: (context, isAvailable, _) {
                      return ValueListenableBuilder<List<WashOrder>>(
                        valueListenable: _orderService.orders,
                        builder: (context, _, _) {
                          final orders = _orderService.workerVisibleOrders;
                          WashOrder? activeOrder;
                          for (final item in orders) {
                            if (item.status.isActiveForWorker) {
                              activeOrder = item;
                              break;
                            }
                          }

                          if (orders.isEmpty) {
                            return Center(
                              child: Text(
                                'Todavia no hay servicios disponibles para este panel.',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            );
                          }

                          return ListView(
                            children: [
                              if (activeOrder != null) ...[
                                _ActiveWorkerServiceBanner(order: activeOrder),
                                const SizedBox(height: 14),
                              ],
                              ...List.generate(orders.length, (index) {
                                final order = orders[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index == orders.length - 1 ? 0 : 14,
                                  ),
                                  child: _WorkerOrderCard(
                                    order: order,
                                    isBusy: _busyOrderId == order.id,
                                    workerAvailable: isAvailable,
                                    hasAnotherActiveOrder:
                                        activeOrder != null &&
                                        activeOrder.id != order.id,
                                    hasScheduleConflict: _orderService
                                        .hasScheduleConflictForWorker(order),
                                    onTakeOrder: () => _takeOrder(order),
                                    onAdvanceOrder: () => _advanceOrder(order),
                                  ),
                                );
                              }),
                            ],
                          );
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

  Future<void> _takeOrder(WashOrder order) async {
    if (_busyOrderId != null) {
      return;
    }

    final activeOrder = _orderService.activeWorkerOrder;
    if (activeOrder != null && activeOrder.id != order.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No puedes tomar otro servicio mientras ${activeOrder.id} siga activo.',
          ),
        ),
      );
      return;
    }

    if (_orderService.hasScheduleConflictForWorker(order)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ya tienes un servicio asignado en el horario ${order.request.scheduleLabel}.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _busyOrderId = order.id;
    });

    try {
      final updatedOrder = await _orderService.takeOrder(order.id);
      if (!mounted) {
        return;
      }

      if (updatedOrder == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo tomar el servicio. Revisa tu disponibilidad o intenta de nuevo.',
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Servicio ${updatedOrder.id} tomado correctamente.'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_workerActionErrorMessage(error))));
    } finally {
      if (mounted) {
        setState(() {
          _busyOrderId = null;
        });
      }
    }
  }

  void _handleToggleAvailability() {
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

  Future<void> _advanceOrder(WashOrder order) async {
    if (_busyOrderId != null) {
      return;
    }

    setState(() {
      _busyOrderId = order.id;
    });

    try {
      final updatedOrder = await _orderService.advanceOrder(order.id);
      if (!mounted) {
        return;
      }

      if (updatedOrder == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo avanzar este servicio. Verifica que siga asignado a tu cuenta.',
            ),
          ),
        );
        return;
      }

      final message =
          updatedOrder.status == OrderStatus.onTheWay &&
              updatedOrder.etaMinutes > 0
          ? 'Ruta actualizada. ETA restante: ${updatedOrder.etaMinutes} min.'
          : 'Servicio ${updatedOrder.id} actualizado a ${updatedOrder.status.label}.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_workerActionErrorMessage(error))));
    } finally {
      if (mounted) {
        setState(() {
          _busyOrderId = null;
        });
      }
    }
  }

  String _workerActionErrorMessage(Object error) {
    if (error is OrderSubmissionException) {
      return error.message;
    }
    return 'No se pudo sincronizar el cambio. Intenta de nuevo.';
  }
}

class _ActiveWorkerServiceBanner extends StatelessWidget {
  const _ActiveWorkerServiceBanner({required this.order});

  final WashOrder order;

  @override
  Widget build(BuildContext context) {
    final accent = _statusColor(order.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LavifyTheme.overlayPanelColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Servicio en curso',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Text(
                order.status.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: LiveTrackingMap(
              order: order,
              compact: true,
              borderRadius: 20,
            ),
          ),
        ],
      ),
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

class _AvailabilityBanner extends StatelessWidget {
  const _AvailabilityBanner({
    required this.isAvailable,
    required this.onToggle,
  });

  final bool isAvailable;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LavifyTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.verified_rounded : Icons.pause_circle_rounded,
            color: isAvailable ? LavifyColors.success : const Color(0xFFFFC857),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isAvailable
                  ? 'Estas disponible para aceptar servicios.'
                  : 'Tu disponibilidad esta pausada.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          TextButton(
            onPressed: onToggle,
            child: Text(isAvailable ? 'Pausar' : 'Activar'),
          ),
        ],
      ),
    );
  }
}

class _WorkerOrderCard extends StatelessWidget {
  const _WorkerOrderCard({
    required this.order,
    required this.isBusy,
    required this.workerAvailable,
    required this.hasAnotherActiveOrder,
    required this.hasScheduleConflict,
    required this.onTakeOrder,
    required this.onAdvanceOrder,
  });

  final WashOrder order;
  final bool isBusy;
  final bool workerAvailable;
  final bool hasAnotherActiveOrder;
  final bool hasScheduleConflict;
  final VoidCallback onTakeOrder;
  final VoidCallback onAdvanceOrder;

  @override
  Widget build(BuildContext context) {
    final accent = _statusColor(order.status);
    final actionLabel = _actionLabel(order);
    final helperText = _helperText(order);
    final canTake =
        order.status == OrderStatus.searching &&
        workerAvailable &&
        !hasAnotherActiveOrder &&
        !hasScheduleConflict;
    final canAdvance =
        order.status != OrderStatus.searching &&
        order.status != OrderStatus.completed;
    final isActionEnabled = !isBusy && (canTake || canAdvance);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LavifyTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: accent.withAlpha(28),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  order.status.label,
                  style: TextStyle(color: accent, fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              Text(order.id, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            order.request.packageName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            order.request.address,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '${order.request.vehicleTypeName} · ${order.request.scheduleLabel}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (order.status != OrderStatus.searching) ...[
            SizedBox(
              height: 160,
              child: LiveTrackingMap(
                order: order,
                compact: true,
                borderRadius: 18,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            helperText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: LavifyTheme.textPrimaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (order.request.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Notas: ${order.request.notes}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total: \$${order.request.totalPrice} ${order.request.currency}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: LavifyTheme.textPrimaryColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (actionLabel != null)
                SizedBox(
                  width: 220,
                  child: PrimaryButton(
                    label: isBusy ? 'Actualizando...' : actionLabel,
                    onPressed: isActionEnabled
                        ? canTake
                              ? onTakeOrder
                              : onAdvanceOrder
                        : null,
                    isExpanded: true,
                  ),
                ),
            ],
          ),
          if (order.status == OrderStatus.searching && !workerAvailable) ...[
            const SizedBox(height: 10),
            Text(
              'Activa tu disponibilidad para poder tomar este servicio.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFFFFC857)),
            ),
          ],
          if (order.status == OrderStatus.searching &&
              hasAnotherActiveOrder) ...[
            const SizedBox(height: 10),
            Text(
              'Ya tienes un servicio activo. Completa ese trabajo antes de tomar otro.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFFFFC857)),
            ),
          ],
          if (order.status == OrderStatus.searching && hasScheduleConflict) ...[
            const SizedBox(height: 10),
            Text(
              'Ya tienes otro servicio asignado en ese mismo horario.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFFFF8A80)),
            ),
          ],
        ],
      ),
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

  String? _actionLabel(WashOrder order) {
    switch (order.status) {
      case OrderStatus.searching:
        return 'Tomar servicio';
      case OrderStatus.assigned:
        return 'Marcar en camino';
      case OrderStatus.onTheWay:
        return order.etaMinutes > 0
            ? 'Actualizar ruta (${order.etaMinutes} min)'
            : 'Marcar llegada';
      case OrderStatus.arrived:
        return 'Iniciar lavado';
      case OrderStatus.inProgress:
        return 'Completar servicio';
      case OrderStatus.completed:
        return null;
    }
  }

  String _helperText(WashOrder order) {
    switch (order.status) {
      case OrderStatus.searching:
        return 'Solicitud abierta para lavadores disponibles en esta zona.';
      case OrderStatus.assigned:
        return 'Confirma salida y prepara el trayecto al domicilio del cliente.';
      case OrderStatus.onTheWay:
        return 'Sigue avanzando la ruta para mantener el ETA actualizado.';
      case OrderStatus.arrived:
        return 'Ya estas en sitio. Marca inicio cuando vayas a comenzar.';
      case OrderStatus.inProgress:
        return 'El servicio esta en curso. Completa cuando hayas terminado.';
      case OrderStatus.completed:
        return 'Este servicio ya fue cerrado correctamente.';
    }
  }
}
