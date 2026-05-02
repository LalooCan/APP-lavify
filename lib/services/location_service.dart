import 'package:geolocator/geolocator.dart';

import '../models/wash_models.dart';
import 'geocoding_service.dart';

class LocationPermissionDeniedException implements Exception {
  const LocationPermissionDeniedException(this.message);
  final String message;
  @override
  String toString() => message;
}

class LocationService {
  const LocationService({
    GeocodingService geocodingService = const GeocodingService(),
  }) : _geocodingService = geocodingService;

  final GeocodingService _geocodingService;

  ServiceLocation getDefaultLocation() {
    return const ServiceLocation(latitude: 19.432608, longitude: -99.133209);
  }

  bool hasResolvedAddress(String address) => address.trim().isNotEmpty;

  Future<LocationResolution> reverseGeocode(ServiceLocation location) async {
    return _geocodingService.reverseGeocode(location);
  }

  Future<ServiceLocation> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationPermissionDeniedException(
        'Los servicios de ubicación están desactivados. Actívalos en Configuración.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationPermissionDeniedException(
        'Permiso de ubicación denegado. Actívalo en Configuración > Lavify.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );

    return ServiceLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
