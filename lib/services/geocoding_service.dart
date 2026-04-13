import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/wash_models.dart';

class GeocodingService {
  const GeocodingService();

  static const String _mapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
  static const String _geocodingApiKey = String.fromEnvironment(
    'GOOGLE_GEOCODING_API_KEY',
    defaultValue: _mapsApiKey,
  );

  Future<LocationResolution> reverseGeocode(ServiceLocation location) async {
    final fallback = LocationResolution(
      location: location,
      address: location.coordinatesLabel,
      source: LocationAddressSource.fallback,
      isPrecise: false,
    );

    if (_geocodingApiKey.isEmpty) {
      return fallback.copyWith(
        errorMessage:
            'Configura GOOGLE_MAPS_API_KEY o GOOGLE_GEOCODING_API_KEY para obtener direcciones reales.',
      );
    }

    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '${location.latitude},${location.longitude}',
      'language': 'es',
      'region': 'mx',
      'key': _geocodingApiKey,
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        return fallback.copyWith(
          errorMessage: 'No fue posible consultar la direccion en este momento.',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final status = body['status'] as String? ?? 'UNKNOWN_ERROR';
      if (status != 'OK') {
        return fallback.copyWith(
          errorMessage: 'Geocoding no disponible: $status.',
        );
      }

      final results = body['results'] as List<dynamic>;
      if (results.isEmpty) {
        return fallback.copyWith(
          errorMessage: 'No se encontro una direccion para este punto.',
        );
      }

      final firstResult = results.first as Map<String, dynamic>;
      final address =
          firstResult['formatted_address'] as String? ?? fallback.address;

      return LocationResolution(
        location: location,
        address: address,
        source: LocationAddressSource.reverseGeocoding,
        isPrecise: true,
      );
    } catch (_) {
      return fallback.copyWith(
        errorMessage: 'Ocurrio un error al resolver la direccion.',
      );
    }
  }
}
