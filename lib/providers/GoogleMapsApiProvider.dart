import 'package:http/http.dart' as http;

class GoogleMapsApiProvider {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';
  final String apiKey;

  GoogleMapsApiProvider(this.apiKey);

  Future<String?> getRouteCoordinates(double startLat, double startLng, double endLat, double endLng) async {
    String url = '$_baseUrl?origin=$startLat,$startLng&destination=$endLat,$endLng&key=$apiKey';
    
    // Podrías agregar manejo de paradas intermedias aquí si es necesario

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load route');
    }
  }
}
