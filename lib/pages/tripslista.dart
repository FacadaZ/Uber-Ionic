import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:driverchofer/models/trips.dart';
import 'package:driverchofer/pages/maps.dart';
import 'package:driverchofer/pages/mapsrutas.dart';
import 'package:driverchofer/providers/apiprovider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripsScreen extends StatefulWidget {
  @override
  _TripsScreenState createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final ApiProvider _apiProvider = ApiProvider();

  Future<List<Trip>> _loadTrips() async {
    try {
      return await _apiProvider.loadTrips();
    } catch (e) {
      print("Error al cargar los viajes: $e");
      throw Exception("Error al cargar los viajes");
    }
  }

  void _showTripDetails(int tripId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await _apiProvider.getTripById(token!, tripId);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final String tripName = jsonResponse['name'];
        final String latOrigin = jsonResponse['latOrigin'];
        final String lngOrigin = jsonResponse['lngOrigin'];
        final String latDestination = jsonResponse['latDestination'];
        final String lngDestination = jsonResponse['lngDestination'];
        final List<dynamic> stops = jsonResponse['stops'];

        String stopsInfo = "";
        for (var stop in stops) {
          stopsInfo += "Parada: (${stop['lat']}, ${stop['lng']})\n";
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Detalles del Viaje #$tripId'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Nombre: $tripName'),
                  Text('Origen: ($latOrigin, $lngOrigin)'),
                  Text('Destino: ($latDestination, $lngDestination)'),
                  Text(stopsInfo),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cerrar'),
                ),
              ],
            );
          },
        );
      } else {
        throw Exception('Failed to load trip details');
      }
    } catch (e) {
      print('Error: $e');
      // Handle error appropriately
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trips')),
      body: FutureBuilder<List<Trip>>(
        future: _loadTrips(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los viajes'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay viajes disponibles'));
          } else {
            final trips = snapshot.data!;
            return ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(child: Text(trip.name, style: TextStyle(fontWeight: FontWeight.bold))),
                        Icon(
                          Icons.circle,
                          color: trip.status == 1 ? Colors.green : Colors.red,
                          size: 12.0,
                        ),
                      ],
                    ),
                    onTap: () {
                      _showTripDetails(trip.id); 
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => mapsrutas(tripId: trip.id), 
                        ),
                      );
                    },
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => MapsScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Agregar viaje',
      ),
    );
  }
}
