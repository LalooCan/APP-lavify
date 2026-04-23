import 'package:google_maps_flutter/google_maps_flutter.dart';

class ServiceLocation {
  const ServiceLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  LatLng toLatLng() => LatLng(latitude, longitude);

  factory ServiceLocation.fromMap(Map<String, dynamic> map) {
    return ServiceLocation(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }

  String get coordinatesLabel =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  ServiceLocation copyWith({double? latitude, double? longitude}) {
    return ServiceLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {'latitude': latitude, 'longitude': longitude};
  }

  Map<String, dynamic> toJson() => toMap();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ServiceLocation &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

enum LocationAddressSource { reverseGeocoding, manual, fallback }

class LocationResolution {
  const LocationResolution({
    required this.location,
    required this.address,
    required this.source,
    required this.isPrecise,
    this.errorMessage,
  });

  final ServiceLocation location;
  final String address;
  final LocationAddressSource source;
  final bool isPrecise;
  final String? errorMessage;

  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  LocationResolution copyWith({
    ServiceLocation? location,
    String? address,
    LocationAddressSource? source,
    bool? isPrecise,
    String? errorMessage,
  }) {
    return LocationResolution(
      location: location ?? this.location,
      address: address ?? this.address,
      source: source ?? this.source,
      isPrecise: isPrecise ?? this.isPrecise,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ServiceLocationPayload {
  const ServiceLocationPayload({
    required this.lat,
    required this.lng,
    required this.address,
  });

  final double lat;
  final double lng;
  final String address;

  Map<String, dynamic> toMap() {
    return {'lat': lat, 'lng': lng, 'address': address};
  }

  Map<String, dynamic> toJson() => toMap();
}
