import 'dart:convert';
import 'package:driverchofer/pages/tripslista.dart';
import 'package:driverchofer/providers/ApiProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class mapsrutas extends StatelessWidget {
  final int tripId;

  const mapsrutas({Key? key, required this.tripId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Location Map',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserCurrentLocation(tripId: tripId),
    );
  }
}

class UserCurrentLocation extends StatefulWidget {
  final int tripId;

  const UserCurrentLocation({Key? key, required this.tripId}) : super(key: key);

  @override
  _UserCurrentLocationState createState() => _UserCurrentLocationState();
}

class _UserCurrentLocationState extends State<UserCurrentLocation> {
  GoogleMapController? mapController;
  LatLng? _center;
  Position? _currentPosition;
  ApiProvider _apiProvider = ApiProvider();
  Set<Marker> _markers = {};
  int _markerIdCounter = 0;
  Map<PolylineId, Polyline> polylines = {}; // Add this line to store polylines
  Marker? _originMarker;
  Marker? _destinationMarker;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _loadTripDetails(widget.tripId);
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    _currentPosition = await Geolocator.getCurrentPosition();
    setState(() {
      _center = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    });
  }

  Future<void> _loadTripDetails(int tripId) async {
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

        _addMarker(double.parse(latOrigin), double.parse(lngOrigin),
            'Origen: $tripName', true);
        _addMarker(double.parse(latDestination), double.parse(lngDestination),
            'Destino: $tripName', false);

        for (var stop in stops) {
          _addMarker(double.parse(stop['lat']), double.parse(stop['lng']),
              'Parada', null);
        }

        List<LatLng> polylinePoints = await getPolylinePoints();
        generatePolyLineFromPoints(polylinePoints);

        setState(() {});
      } else {
        throw Exception('Fallo la carga de datos del viaje');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _addMarker(double lat, double lng, String title, bool? isOrigin) {
    final markerIdVal = 'marker_$_markerIdCounter';
    _markerIdCounter++;
    final Marker marker = Marker(
      markerId: MarkerId(markerIdVal),
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: title),
    );
    _markers.add(marker);

    if (isOrigin == true) {
      _originMarker = marker;
    } else if (isOrigin == false) {
      _destinationMarker = marker;
    }
  }

  Future<List<LatLng>> getPolylinePoints() async {
    try {
      List<LatLng> polylineCoordinates = [];
      PolylinePoints polylinePoints = PolylinePoints();

      List<LatLng> routePoints = [];
      routePoints.add(LatLng(
          _originMarker!.position.latitude, _originMarker!.position.longitude));

      // Agregar puntos de las paradas intermedias
      for (var marker in _markers) {
        if (marker != _originMarker && marker != _destinationMarker) {
          routePoints.add(marker.position);
        }
      }

      routePoints.add(LatLng(_destinationMarker!.position.latitude,
          _destinationMarker!.position.longitude));

      for (int i = 0; i < routePoints.length - 1; i++) {
        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleApiKey: Constants.apiKey,
          request: PolylineRequest(
            origin:
                PointLatLng(routePoints[i].latitude, routePoints[i].longitude),
            destination: PointLatLng(
                routePoints[i + 1].latitude, routePoints[i + 1].longitude),
            mode: TravelMode.driving,
          ),
        );
        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        } else {
          print("ERROR POLYLINES: ${result.errorMessage}");
        }
      }
      return polylineCoordinates;
    } catch (e) {
      print('Error getting polyline points: $e');
      return [];
    }
  }

  void generatePolyLineFromPoints(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: const Color.fromARGB(255, 40, 122, 198),
      points: polylineCoordinates,
      width: 5,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  Future<void> _goToCurrentLocation() async {
    _currentPosition = await Geolocator.getCurrentPosition();
    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          zoom: 15.0,
        ),
      ));
    }
  }

  Future<void> _startTrip() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await _apiProvider.startTrip(token!, widget.tripId);
      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Viaje Iniciado'),
            content: Text('El viaje ha sido iniciado con éxito.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context); 
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripsScreen(),
                    ),
                  );
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Muestra un diálogo de error
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('No se pudo iniciar el viaje.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Ocurrió un error al intentar iniciar el viaje.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Location Map'),
      ),
      body: Stack(
        children: [
          _center == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center!,
                    zoom: 20.0,
                  ),
                  markers: _markers,
                  polylines: Set<Polyline>.of(polylines.values),
                ),
          Positioned(
            bottom:
                16, 
            right:
                150.0, 
            child: ElevatedButton(
              onPressed:
                  _startTrip, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Background color
              ),
              child: Text('Iniciar Viaje'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCurrentLocation,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        child: Icon(Icons.my_location, size: 36.0),
      ),
    );
  }
}

class Constants {
  static const String apiKey = 'AIzaSyCR5CKjcHySsfqiue7iu7oGjiSIa2QhimI';
}
