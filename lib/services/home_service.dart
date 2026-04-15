import '../models/wash_models.dart';
import 'profile_service.dart';
import 'session_service.dart';

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
    final session = SessionService().currentSession.value;
    final profile = ProfileService().profile.value;
    final favoriteAddress = session?.favoriteAddress ?? profile.favoriteAddress;
    final visibleName = (session?.visibleName.trim().isNotEmpty ?? false) &&
            session?.visibleName != 'Elige tu nombre'
        ? session!.visibleName
        : ProfileService().resolveGreetingName();

    return HomeSessionData(
      firstName: visibleName,
      savedAddress: _buildSavedAddress(favoriteAddress),
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
