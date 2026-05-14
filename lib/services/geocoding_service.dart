import 'dart:convert';

import 'package:http/http.dart' as http;

import '../app_config.dart';
import '../models/wash_models.dart';

class AddressSuggestion {
  const AddressSuggestion({
    required this.displayName,
    required this.location,
  });

  final String displayName;
  final ServiceLocation location;
}

class GeocodingService {
  const GeocodingService();

  static const String _base = 'api.mapbox.com';

  // Búsqueda de dirección por texto → lista de sugerencias con coordenadas.
  Future<List<AddressSuggestion>> searchAddress(
    String query, {
    ServiceLocation? proximity,
  }) async {
    final q = query.trim();
    if (q.length < 3) return [];

    final params = <String, String>{
      'access_token': AppConfig.mapboxPublicToken,
      'country': 'MX',
      'language': 'es',
      'limit': '6',
      'types': 'address,place,neighborhood,locality,poi',
      if (proximity != null)
        'proximity': '${proximity.longitude},${proximity.latitude}',
    };

    final uri = Uri.https(
      _base,
      '/geocoding/v5/mapbox.places/${Uri.encodeComponent(q)}.json',
      params,
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return [];
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final features = body['features'] as List<dynamic>? ?? [];
      return features.map((f) {
        final feat = f as Map<String, dynamic>;
        final name = feat['place_name'] as String? ?? '';
        final center = feat['center'] as List<dynamic>? ?? [];
        final lng = center.isNotEmpty ? (center[0] as num).toDouble() : 0.0;
        final lat = center.length > 1 ? (center[1] as num).toDouble() : 0.0;
        return AddressSuggestion(
          displayName: name,
          location: ServiceLocation(latitude: lat, longitude: lng),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // Geocodificación inversa: coordenadas → dirección legible (usa Mapbox).
  Future<LocationResolution> reverseGeocode(ServiceLocation location) async {
    final fallback = LocationResolution(
      location: location,
      address: location.coordinatesLabel,
      source: LocationAddressSource.fallback,
      isPrecise: false,
    );

    final uri = Uri.https(
      _base,
      '/geocoding/v5/mapbox.places/'
      '${location.longitude},${location.latitude}.json',
      {
        'access_token': AppConfig.mapboxPublicToken,
        'language': 'es',
        'country': 'MX',
        'types': 'address,place,neighborhood',
        'limit': '1',
      },
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return fallback;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final features = body['features'] as List<dynamic>? ?? [];
      if (features.isEmpty) return fallback;
      final address =
          (features.first as Map<String, dynamic>)['place_name'] as String? ??
          fallback.address;
      return LocationResolution(
        location: location,
        address: address,
        source: LocationAddressSource.reverseGeocoding,
        isPrecise: true,
      );
    } catch (_) {
      return fallback;
    }
  }
}
