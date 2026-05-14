import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../models/service_location.dart';
import '../theme/theme.dart';

/// Mapa estático centrado en una ubicación. Sin marcadores ni rutas.
/// En web muestra un placeholder ya que Mapbox no soporta Flutter Web.
class CityMapView extends StatelessWidget {
  const CityMapView({
    super.key,
    required this.location,
    this.zoom = 12.5,
    this.borderRadius = 24.0,
  });

  final ServiceLocation location;
  final double zoom;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _WebPlaceholder(borderRadius: borderRadius);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: MapWidget(
        key: ValueKey('city_${location.latitude}_${location.longitude}'),
        styleUri: MapboxStyles.MAPBOX_STREETS,
        viewport: CameraViewportState(
          center: location.toPoint(),
          zoom: zoom,
        ),
      ),
    );
  }
}

class _WebPlaceholder extends StatelessWidget {
  const _WebPlaceholder({required this.borderRadius});
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        color: LavifyTheme.surfaceAltColor(context),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.map_outlined,
                size: 36,
                color: LavifyTheme.textSecondaryColor(context),
              ),
              const SizedBox(height: 8),
              Text(
                'Mapa en la app móvil',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
