import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/wash_models.dart';
import '../theme/theme.dart';
import '../widgets/primary_button.dart';

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({super.key, required this.order});

  final WashOrder order;

  @override
  Widget build(BuildContext context) {
    final stages = OrderStatus.values;
    final activeIndex = stages.indexOf(order.status);
    final isSearching = order.status == OrderStatus.searching;
    final statusAccent = _statusAccent(order.status);
    final statusSummary = _statusSummary(order);
    final mapBadgeLabel = isSearching
        ? 'Buscando lavador cerca de ti'
        : order.etaMinutes > 0
        ? 'Llegando en ${order.etaMinutes} min'
        : order.status.label;

    return Scaffold(
      appBar: AppBar(title: Text('Pedido ${order.id}')),
      body: Container(
        decoration: LavifyTheme.pageDecoration(context),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isSearching
                                  ? 'Buscando lavador'
                                  : order.status.label,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: statusAccent.withAlpha(24),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              isSearching ? 'Buscando' : order.status.label,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: statusAccent,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        statusSummary,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: SizedBox(
                    height: 280,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              order.request.latitude,
                              order.request.longitude,
                            ),
                            zoom: 14,
                          ),
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                          markers: {
                            Marker(
                              markerId: const MarkerId('service_location'),
                              position: LatLng(
                                order.request.latitude,
                                order.request.longitude,
                              ),
                              infoWindow: InfoWindow(
                                title: isSearching
                                    ? 'Ubicacion del lavado'
                                    : 'Lavado en seguimiento',
                              ),
                            ),
                          },
                        ),
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: LavifyTheme.overlayPanelColor(context),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: LavifyTheme.borderColor(context),
                              ),
                            ),
                            child: Text(
                              mapBadgeLabel,
                              style: Theme.of(context).textTheme.bodyLarge
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
                ),
                if (isSearching) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: LavifyTheme.surfaceColor(context),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: LavifyTheme.borderColor(context),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Que esta pasando ahora',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 14),
                        _TrackingNote(
                          title: 'Solicitud confirmada',
                          subtitle:
                              'Tu pedido ya entro al flujo y esta listo para asignacion.',
                        ),
                        const SizedBox(height: 12),
                        _TrackingNote(
                          title: 'Buscando lavador disponible',
                          subtitle:
                              'Lavify esta revisando trabajadores cercanos y disponibles.',
                        ),
                        const SizedBox(height: 12),
                        _TrackingNote(
                          title: 'Te avisaremos al asignarlo',
                          subtitle:
                              'Cuando alguien tome el servicio, esta pantalla cambiara al seguimiento del trayecto.',
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: LavifyTheme.surfaceColor(context),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: LavifyTheme.borderColor(context),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progreso del servicio',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 18),
                        for (int i = 0; i < stages.length; i++) ...[
                          _TrackingStep(
                            title: stages[i].label,
                            completed: i <= activeIndex,
                            isLast: i == stages.length - 1,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Container(
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
                        'Detalle del pedido',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 14),
                      _DetailRow(
                        label: 'Paquete',
                        value: order.request.packageName,
                      ),
                      _DetailRow(
                        label: 'Vehiculo',
                        value: order.request.vehicleTypeName,
                      ),
                      _DetailRow(
                        label: 'Direccion',
                        value: order.request.address,
                      ),
                      _DetailRow(
                        label: 'Horario',
                        value: order.request.scheduleLabel,
                      ),
                      _DetailRow(
                        label: 'Total',
                        value:
                            '\$${order.request.totalPrice} ${order.request.currency}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Volver al inicio',
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  isExpanded: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _statusSummary(WashOrder order) {
    switch (order.status) {
      case OrderStatus.searching:
        return 'Tu solicitud esta confirmada y estamos buscando un trabajador disponible cerca de tu ubicacion.';
      case OrderStatus.assigned:
      case OrderStatus.onTheWay:
        return '${order.assignedWasherName} va en ${order.assignedVehicleLabel}. ETA ${order.etaMinutes} min.';
      case OrderStatus.arrived:
        return '${order.assignedWasherName} ya llego al punto de servicio.';
      case OrderStatus.inProgress:
        return '${order.assignedWasherName} ya esta realizando el lavado.';
      case OrderStatus.completed:
        return 'El servicio fue completado correctamente.';
    }
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

class _TrackingStep extends StatelessWidget {
  const _TrackingStep({
    required this.title,
    required this.completed,
    required this.isLast,
  });

  final String title;
  final bool completed;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: completed ? LavifyColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: completed
                      ? LavifyColors.primary
                      : LavifyTheme.borderColor(context),
                  width: 2,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 34,
                color: completed
                    ? LavifyColors.primary
                    : LavifyTheme.borderColor(context),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: completed
                  ? LavifyTheme.textPrimaryColor(context)
                  : LavifyTheme.textSecondaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: LavifyTheme.textPrimaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingNote extends StatelessWidget {
  const _TrackingNote({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LavifyTheme.softFillStrongColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: LavifyTheme.textPrimaryColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
