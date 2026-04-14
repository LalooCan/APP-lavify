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

    return Scaffold(
      appBar: AppBar(title: Text('Pedido ${order.id}')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF07101D), Color(0xFF102446), Color(0xFF09111F)],
          ),
        ),
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
                    color: LavifyColors.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: LavifyColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.status.label,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${order.assignedWasherName} va en ${order.assignedVehicleLabel}. ETA ${order.etaMinutes} min.',
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
                    child: GoogleMap(
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
                          infoWindow: const InfoWindow(
                            title: 'Ubicacion del servicio',
                          ),
                        ),
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: LavifyColors.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: LavifyColors.border),
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
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: LavifyColors.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: LavifyColors.border),
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
                  color: completed ? LavifyColors.primary : LavifyColors.border,
                  width: 2,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 34,
                color: completed ? LavifyColors.primary : LavifyColors.border,
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
                  ? LavifyColors.textPrimary
                  : LavifyColors.textSecondary,
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
                color: LavifyColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
