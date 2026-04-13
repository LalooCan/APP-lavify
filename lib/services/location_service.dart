import '../models/wash_models.dart';
import 'geocoding_service.dart';

class LocationService {
  const LocationService({
    GeocodingService geocodingService = const GeocodingService(),
  }) : _geocodingService = geocodingService;

  final GeocodingService _geocodingService;

  ServiceLocation getDefaultLocation() {
    return const ServiceLocation(
      latitude: 19.432608,
      longitude: -99.133209,
    );
  }

  bool hasResolvedAddress(String address) => address.trim().isNotEmpty;

  Future<LocationResolution> reverseGeocode(ServiceLocation location) async {
    return _geocodingService.reverseGeocode(location);
  }
}
