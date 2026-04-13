import '../models/wash_models.dart';

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
    return const HomeSessionData(
      firstName: 'Luis',
      savedAddress: 'Tu ubicacion: Av. Paseo de la Reforma 245, Juarez, CDMX',
      availabilityLabel: 'Disponible en tu zona',
      etaLabel: '20-30 min',
    );
  }

  List<WashPackage> getFeaturedPackages() => washPackages;
}
