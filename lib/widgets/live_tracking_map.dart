import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/wash_models.dart';
import '../services/tracking_service.dart';
import '../theme/theme.dart';

class LiveTrackingMap extends StatefulWidget {
  const LiveTrackingMap({
    super.key,
    required this.order,
    this.compact = false,
    this.showLegend = true,
    this.borderRadius = 28,
  });

  final WashOrder order;
  final bool compact;
  final bool showLegend;
  final double borderRadius;

  @override
  State<LiveTrackingMap> createState() => _LiveTrackingMapState();
}

class _LiveTrackingMapState extends State<LiveTrackingMap> {
  static final TrackingService _trackingService = TrackingService();
  GoogleMapController? _controller;
  Timer? _fitDebounce;

  @override
  void dispose() {
    _fitDebounce?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LiveTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.id != widget.order.id ||
        oldWidget.order.status != widget.order.status ||
        oldWidget.order.etaMinutes != widget.order.etaMinutes) {
      _scheduleFit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<OrderTrackingSnapshot?>(
      valueListenable: _trackingService.trackingForOrder(widget.order.id),
      builder: (context, snapshot, _) {
        final effectiveSnapshot =
            snapshot ??
            OrderTrackingSnapshot(
              orderId: widget.order.id,
              customerLocation: widget.order.customerLocation,
              updatedAt: DateTime.now(),
              source: TrackingSource.mock,
              etaMinutes: widget.order.etaMinutes,
            );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _scheduleFit();
          }
        });
        final customer = effectiveSnapshot.customerLocation.toLatLng();
        final washer = effectiveSnapshot.workerLocation?.location.toLatLng();
        final statusAccent = _statusAccent(widget.order.status);
        final markers = <Marker>{
          Marker(
            markerId: const MarkerId('customer_location'),
            position: customer,
            infoWindow: const InfoWindow(title: 'Cliente'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRose,
            ),
          ),
        };

        final polylines = <Polyline>{};

        if (washer != null) {
          markers.add(
            Marker(
              markerId: const MarkerId('washer_location'),
              position: washer,
              infoWindow: InfoWindow(title: widget.order.assignedWasherName),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
            ),
          );
          final routePoints = effectiveSnapshot.routePoints.isNotEmpty
              ? effectiveSnapshot.routePoints
                    .map((point) => point.toLatLng())
                    .toList()
              : [washer, customer];

          polylines.add(
            Polyline(
              polylineId: const PolylineId('washer_route'),
              points: routePoints,
              width: widget.compact ? 4 : 5,
              color: statusAccent,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: customer,
                  zoom: washer == null ? 14.6 : 13.4,
                ),
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
                markers: markers,
                polylines: polylines,
                onMapCreated: (controller) {
                  _controller = controller;
                  _scheduleFit();
                },
              ),
              if (widget.showLegend)
                Positioned(
                  left: 14,
                  top: 14,
                  child: _MapLegend(
                    order: widget.order,
                    snapshot: effectiveSnapshot,
                    compact: widget.compact,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _scheduleFit() {
    _fitDebounce?.cancel();
    _fitDebounce = Timer(const Duration(milliseconds: 60), _fitMap);
  }

  Future<void> _fitMap() async {
    final controller = _controller;
    if (controller == null || !mounted) {
      return;
    }

    final snapshot = _trackingService.snapshotForOrder(widget.order.id);
    final customer =
        (snapshot?.customerLocation ?? widget.order.customerLocation)
            .toLatLng();
    final washer = snapshot?.workerLocation?.location.toLatLng();
    if (washer == null) {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: customer, zoom: 14.6),
        ),
      );
      return;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(
        customer.latitude < washer.latitude
            ? customer.latitude
            : washer.latitude,
        customer.longitude < washer.longitude
            ? customer.longitude
            : washer.longitude,
      ),
      northeast: LatLng(
        customer.latitude > washer.latitude
            ? customer.latitude
            : washer.latitude,
        customer.longitude > washer.longitude
            ? customer.longitude
            : washer.longitude,
      ),
    );

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, widget.compact ? 54 : 72),
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

class _MapLegend extends StatelessWidget {
  const _MapLegend({
    required this.order,
    required this.snapshot,
    required this.compact,
  });

  final WashOrder order;
  final OrderTrackingSnapshot snapshot;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final distanceKm = snapshot.distanceKm;
    final items = [
      const _LegendItem(color: Colors.pinkAccent, label: 'Cliente'),
      if (snapshot.hasWorkerLocation)
        _LegendItem(
          color: LavifyColors.primary,
          label: order.assignedWasherName,
        ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: LavifyTheme.overlayPanelColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...items,
          if (distanceKm != null) ...[
            SizedBox(height: compact ? 6 : 8),
            Text(
              '${distanceKm.toStringAsFixed(1)} km de distancia',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: LavifyTheme.textPrimaryColor(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
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
