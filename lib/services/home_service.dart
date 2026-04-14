import '../models/wash_models.dart';
import 'profile_service.dart';

class HomeSessionData {
  const HomeSessionData({
    required this.firstName,
    required this.savedAddress,
    required this.availabilityLabel,
    required this.etaLabel,
  });

  final String firstName;
  final String savedAddress;
  final String availabilityLabel;
  final String etaLabel;
}

class HomeService {
  const HomeService();

  HomeSessionData getSessionData() {
    final profile = ProfileService().profile.value;

    return HomeSessionData(
      firstName: ProfileService().resolveGreetingName(),
      savedAddress: _buildSavedAddress(profile.favoriteAddress),
      availabilityLabel: 'Disponible en tu zona',
      etaLabel: '20-30 min',
    );
  }

  List<WashPackage> getFeaturedPackages() => washPackages;

  String _buildSavedAddress(String favoriteAddress) {
    final trimmedAddress = favoriteAddress.trim();
    if (trimmedAddress.isEmpty) {
      return 'Tu ubicacion: Agrega una direccion favorita';
    }

    return 'Tu ubicacion: $trimmedAddress';
  }
}
