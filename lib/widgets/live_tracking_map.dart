import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

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

  MapboxMap? _mapboxMap;
  CircleAnnotationManager? _circleManager;
  PolylineAnnotationManager? _lineManager;
  bool _managersReady = false;
  Timer? _fitDebounce;

  ValueListenable<OrderTrackingSnapshot?> get _trackingNotifier =>
      _trackingService.trackingForOrder(widget.order.id);

  @override
  void initState() {
    super.initState();
    _trackingNotifier.addListener(_onTrackingChanged);
  }

  @override
  void didUpdateWidget(covariant LiveTrackingMap old) {
    super.didUpdateWidget(old);
    if (old.order.id != widget.order.id) {
      old.order; // suppress unused warning
      _trackingService
          .trackingForOrder(old.order.id)
          .removeListener(_onTrackingChanged);
      _trackingNotifier.addListener(_onTrackingChanged);
      _managersReady = false;
    }
  }

  @override
  void dispose() {
    _fitDebounce?.cancel();
    _trackingNotifier.removeListener(_onTrackingChanged);
    super.dispose();
  }

  void _onTrackingChanged() {
    if (!mounted || !_managersReady) return;
    final snapshot = _trackingNotifier.value;
    if (snapshot != null) unawaited(_drawAnnotations(snapshot));
  }

  Future<void> _onMapCreated(MapboxMap controller) async {
    _mapboxMap = controller;

    await Future.wait([
      controller.compass.updateSettings(CompassSettings(enabled: false)),
      controller.scaleBar.updateSettings(ScaleBarSettings(enabled: false)),
      controller.attribution
          .updateSettings(AttributionSettings(enabled: false)),
      controller.logo.updateSettings(LogoSettings(enabled: false)),
    ]);

    _lineManager =
        await controller.annotations.createPolylineAnnotationManager();
    _circleManager =
        await controller.annotations.createCircleAnnotationManager();
    _managersReady = true;

    final snapshot = _trackingNotifier.value ??
        OrderTrackingSnapshot(
          orderId: widget.order.id,
          customerLocation: widget.order.customerLocation,
          updatedAt: DateTime.now(),
          source: TrackingSource.mock,
          etaMinutes: widget.order.etaMinutes,
        );

    await _drawAnnotations(snapshot);
  }

  Future<void> _drawAnnotations(OrderTrackingSnapshot snapshot) async {
    final circles = _circleManager;
    final lines = _lineManager;
    if (circles == null || lines == null) return;

    await circles.deleteAll();
    await lines.deleteAll();

    final washerLoc = snapshot.workerLocation?.location;

    // Ruta (debajo de los marcadores)
    if (washerLoc != null) {
      final coords = snapshot.routePoints.isNotEmpty
          ? snapshot.routePoints.map((p) => p.toPosition()).toList()
          : [washerLoc.toPosition(), snapshot.customerLocation.toPosition()];

      await lines.create(
        PolylineAnnotationOptions(
          geometry: LineString(coordinates: coords),
          lineColor: _colorToInt(_statusColor(widget.order.status)),
          lineWidth: widget.compact ? 4.0 : 5.0,
          lineOpacity: 0.88,
        ),
      );
    }

    // Marcador del cliente (rosa)
    await circles.create(
      CircleAnnotationOptions(
        geometry: snapshot.customerLocation.toPoint(),
        circleColor: _colorToInt(Colors.pinkAccent),
        circleRadius: widget.compact ? 9.0 : 11.0,
        circleStrokeColor: _colorToInt(Colors.white),
        circleStrokeWidth: 2.5,
      ),
    );

    // Marcador del lavador (azul)
    if (washerLoc != null) {
      await circles.create(
        CircleAnnotationOptions(
          geometry: washerLoc.toPoint(),
          circleColor: _colorToInt(LavifyColors.primary),
          circleRadius: widget.compact ? 9.0 : 11.0,
          circleStrokeColor: _colorToInt(Colors.white),
          circleStrokeWidth: 2.5,
        ),
      );
    }

    _scheduleFit(snapshot);
  }

  void _scheduleFit(OrderTrackingSnapshot snapshot) {
    _fitDebounce?.cancel();
    _fitDebounce = Timer(
      const Duration(milliseconds: 120),
      () => _fitCamera(snapshot),
    );
  }

  Future<void> _fitCamera(OrderTrackingSnapshot snapshot) async {
    final controller = _mapboxMap;
    if (controller == null || !mounted) return;

    final washer = snapshot.workerLocation?.location;
    final customer = snapshot.customerLocation;

    if (washer == null) {
      await controller.flyTo(
        CameraOptions(center: customer.toPoint(), zoom: 14.6),
        MapAnimationOptions(duration: 600),
      );
      return;
    }

    final minLat = customer.latitude < washer.latitude
        ? customer.latitude
        : washer.latitude;
    final maxLat = customer.latitude > washer.latitude
        ? customer.latitude
        : washer.latitude;
    final minLng = customer.longitude < washer.longitude
        ? customer.longitude
        : washer.longitude;
    final maxLng = customer.longitude > washer.longitude
        ? customer.longitude
        : washer.longitude;

    final pad = widget.compact ? 60.0 : 80.0;
    try {
      final camera = await controller.cameraForCoordinateBounds(
        CoordinateBounds(
          southwest: Point(coordinates: Position(minLng, minLat)),
          northeast: Point(coordinates: Position(maxLng, maxLat)),
          infiniteBounds: false,
        ),
        MbxEdgeInsets(top: pad, left: pad, bottom: pad, right: pad),
        null,
        null,
        null,
        null,
      );
      await controller.flyTo(camera, MapAnimationOptions(duration: 700));
    } catch (_) {
      await controller.flyTo(
        CameraOptions(center: customer.toPoint(), zoom: 13.0),
        MapAnimationOptions(duration: 600),
      );
    }
  }

  // Mapbox espera ARGB como int (mismo formato que Flutter Color).
  int _colorToInt(Color color) => color.toARGB32();

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

  @override
  Widget build(BuildContext context) {
    final mapStyle = MapboxStyles.MAPBOX_STREETS;

    final initialCenter =
        (_trackingNotifier.value?.customerLocation ?? widget.order.customerLocation)
            .toPoint();

    return ValueListenableBuilder<OrderTrackingSnapshot?>(
      valueListenable: _trackingNotifier,
      builder: (context, snapshot, _) {
        final effectiveSnapshot = snapshot ??
            OrderTrackingSnapshot(
              orderId: widget.order.id,
              customerLocation: widget.order.customerLocation,
              updatedAt: DateTime.now(),
              source: TrackingSource.mock,
              etaMinutes: widget.order.etaMinutes,
            );

        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Stack(
            children: [
              if (kIsWeb)
                _WebMapPlaceholder(location: effectiveSnapshot.customerLocation)
              else
                MapWidget(
                  key: const ValueKey('mapbox_tracking'),
                  styleUri: mapStyle,
                  viewport: CameraViewportState(
                    center: initialCenter,
                    zoom: 13.5,
                  ),
                  onMapCreated: _onMapCreated,
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
          const _LegendItem(color: Colors.pinkAccent, label: 'Cliente'),
          if (snapshot.hasWorkerLocation)
            _LegendItem(
              color: LavifyColors.primary,
              label: order.assignedWasherName,
            ),
          if (distanceKm != null) ...[
            SizedBox(height: compact ? 6 : 8),
            Text(
              '${distanceKm.toStringAsFixed(1)} km',
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

class _WebMapPlaceholder extends StatelessWidget {
  const _WebMapPlaceholder({required this.location});

  final ServiceLocation location;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LavifyTheme.surfaceAltColor(context),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map_outlined,
              size: 48,
              color: LavifyTheme.textSecondaryColor(context),
            ),
            const SizedBox(height: 12),
            Text(
              'Mapa disponible en la app móvil',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: LavifyTheme.textSecondaryColor(context),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              '${location.latitude.toStringAsFixed(5)}, '
              '${location.longitude.toStringAsFixed(5)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
