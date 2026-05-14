import 'service_location.dart';

class MexicoCity {
  const MexicoCity({
    required this.id,
    required this.name,
    required this.state,
    required this.location,
  });

  final String id;
  final String name;
  final String state;
  final ServiceLocation location;

  String get displayName => '$name, $state';
}

const List<MexicoCity> mexicoCities = [
  MexicoCity(
    id: 'cdmx',
    name: 'Ciudad de México',
    state: 'CDMX',
    location: ServiceLocation(latitude: 19.432608, longitude: -99.133209),
  ),
  MexicoCity(
    id: 'guadalajara',
    name: 'Guadalajara',
    state: 'Jalisco',
    location: ServiceLocation(latitude: 20.659699, longitude: -103.349609),
  ),
  MexicoCity(
    id: 'monterrey',
    name: 'Monterrey',
    state: 'Nuevo León',
    location: ServiceLocation(latitude: 25.686614, longitude: -100.316113),
  ),
  MexicoCity(
    id: 'puebla',
    name: 'Puebla',
    state: 'Puebla',
    location: ServiceLocation(latitude: 19.041298, longitude: -98.206275),
  ),
  MexicoCity(
    id: 'merida',
    name: 'Mérida',
    state: 'Yucatán',
    location: ServiceLocation(latitude: 20.967370, longitude: -89.623101),
  ),
  MexicoCity(
    id: 'cancun',
    name: 'Cancún',
    state: 'Quintana Roo',
    location: ServiceLocation(latitude: 21.161908, longitude: -86.851528),
  ),
  MexicoCity(
    id: 'tijuana',
    name: 'Tijuana',
    state: 'Baja California',
    location: ServiceLocation(latitude: 32.514901, longitude: -117.038498),
  ),
  MexicoCity(
    id: 'leon',
    name: 'León',
    state: 'Guanajuato',
    location: ServiceLocation(latitude: 21.122854, longitude: -101.682510),
  ),
  MexicoCity(
    id: 'queretaro',
    name: 'Querétaro',
    state: 'Querétaro',
    location: ServiceLocation(latitude: 20.588793, longitude: -100.388806),
  ),
  MexicoCity(
    id: 'aguascalientes',
    name: 'Aguascalientes',
    state: 'Aguascalientes',
    location: ServiceLocation(latitude: 21.885240, longitude: -102.291656),
  ),
  MexicoCity(
    id: 'slp',
    name: 'San Luis Potosí',
    state: 'San Luis Potosí',
    location: ServiceLocation(latitude: 22.156990, longitude: -100.985878),
  ),
  MexicoCity(
    id: 'hermosillo',
    name: 'Hermosillo',
    state: 'Sonora',
    location: ServiceLocation(latitude: 29.072967, longitude: -110.955919),
  ),
  MexicoCity(
    id: 'chihuahua',
    name: 'Chihuahua',
    state: 'Chihuahua',
    location: ServiceLocation(latitude: 28.635308, longitude: -106.088890),
  ),
  MexicoCity(
    id: 'saltillo',
    name: 'Saltillo',
    state: 'Coahuila',
    location: ServiceLocation(latitude: 25.428717, longitude: -100.993999),
  ),
  MexicoCity(
    id: 'morelia',
    name: 'Morelia',
    state: 'Michoacán',
    location: ServiceLocation(latitude: 19.705928, longitude: -101.194880),
  ),
  MexicoCity(
    id: 'veracruz',
    name: 'Veracruz',
    state: 'Veracruz',
    location: ServiceLocation(latitude: 19.173773, longitude: -96.134224),
  ),
  MexicoCity(
    id: 'oaxaca',
    name: 'Oaxaca',
    state: 'Oaxaca',
    location: ServiceLocation(latitude: 17.073155, longitude: -96.723068),
  ),
  MexicoCity(
    id: 'culiacan',
    name: 'Culiacán',
    state: 'Sinaloa',
    location: ServiceLocation(latitude: 24.809065, longitude: -107.393741),
  ),
  MexicoCity(
    id: 'mexicali',
    name: 'Mexicali',
    state: 'Baja California',
    location: ServiceLocation(latitude: 32.663780, longitude: -115.467980),
  ),
  MexicoCity(
    id: 'torreon',
    name: 'Torreón',
    state: 'Coahuila',
    location: ServiceLocation(latitude: 25.543846, longitude: -103.411545),
  ),
];

MexicoCity? cityById(String id) {
  for (final city in mexicoCities) {
    if (city.id == id) return city;
  }
  return null;
}
