import 'dart:convert';
import 'package:driverchofer/models/tripsadd.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:driverchofer/models/trips.dart';

class ApiProvider {
  final String _baseUrl = 'http://143.198.16.180/api/auth';
  final String _trips = 'http://143.198.16.180/api';

  Future<String?> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/registerdriver');
    final response = await http.post(url, body: {
      'username': username,
      'password': password,
    });

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final String token = jsonResponse['access_token'];
      return token;
    } else {
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<http.Response> loginDriver(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/logindriver');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return response;
  }

  Future<http.Response> getTrips(String token) async {
    final url = Uri.parse('$_trips/trips');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  Future<List<Trip>> loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final response = await getTrips(token!);
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      final List<Trip> trips =
          jsonResponse.map((e) => Trip.fromJson(e)).toList();
      return trips;
    } else {
      return [];
    }
  }

  Future<http.Response> registerDriver(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/registerdriver');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return response;
  }

  Future<bool> addTrip(Tripadd trip) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final url = Uri.parse('$_trips/trips');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(trip.toJson()),
    );

    // Verifica si el código de estado HTTP es 200, lo que indica éxito
    if (response.statusCode == 201) {
      // Operación exitosa, devuelve true
      return true;
    } else {
      // Operación fallida, devuelve false
      return false;
    }
  }

//http://143.198.16.180/api/trips/16 16 es el id del viaje
  final String _RutasID = 'http://143.198.16.180/api/trips';

  Future<http.Response> getTripById(String token, int id) async {
    final url = Uri.parse('$_RutasID/$id');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load trip');
    }
  }

  
  Future<http.Response> startTrip(String token, int id) async {
    final url = Uri.parse('$_RutasID/$id/start');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to start trip');
    }
  }
}
