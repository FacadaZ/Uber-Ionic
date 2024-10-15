import 'package:flutter/material.dart';
import 'package:driverchofer/models/tripsadd.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'TripDetailsScreen.dart';

void main() {
  runApp(const MapsScreen());
}

class MapsScreen extends StatelessWidget {
  const MapsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Location Map',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const UserCurrentLocation(),
    );
  }
}

class UserCurrentLocation extends StatefulWidget {
  const UserCurrentLocation({Key? key}) : super(key: key);

  @override
  _UserCurrentLocationState createState() => _UserCurrentLocationState();
}

class _UserCurrentLocationState extends State<UserCurrentLocation> {
  GoogleMapController? mapController;
  LatLng? _center;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  List<Stop> _stops = []; // Lista para almacenar las paradas
  bool _isSelectingOrigin = true;
  LatLng? _origin;
  LatLng? _destination;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
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

  Future<void> _goToCurrentLocation() async {
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

  void _addMarker(LatLng tappedPoint) {
    final String markerIdVal = 'marker_${_markers.length}';
    setState(() {
      if (_isSelectingOrigin) {
        _markers.add(
          Marker(
            markerId: MarkerId(markerIdVal),
            position: tappedPoint,
            onTap: () {
              setState(() {
                _markers.removeWhere(
                    (marker) => marker.markerId.value == markerIdVal);
              });
            },
          ),
        );
        _origin = tappedPoint;
        _isSelectingOrigin = false;
      } else if (_destination == null) {
        _markers.add(
          Marker(
            markerId: MarkerId(markerIdVal),
            position: tappedPoint,
            onTap: () {
              setState(() {
                _markers.removeWhere(
                    (marker) => marker.markerId.value == markerIdVal);
              });
            },
          ),
        );
        _destination = tappedPoint;
      } else {
        _showAddStopDialog(tappedPoint);
      }
    });
  }

  void _showAddStopDialog(LatLng tappedPoint) {
    final TextEditingController _timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Añadir Parada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Parada ${_stops.length + 1}'),
            Text('AGREGAR MAS 1 PARADA? '),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(labelText: 'hora'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: _stops.length > 0
                ? () {
                    _finalizeTrip();
                    Navigator.pop(context);
                  }
                : null, // Se habilita solo si hay más de una parada
            child: Text('No add stop'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _stops.add(Stop(
                  lat: tappedPoint.latitude.toString(),
                  lng: tappedPoint.longitude.toString(),
                  time: _timeController.text,
                ));
                // Imprimir en consola la parada agregada
                print(
                    'Parada agregada: Latitud ${tappedPoint.latitude}, Longitud ${tappedPoint.longitude}, Hora ${_timeController.text}');
              });
              Navigator.pop(context); // Cierra el diálogo
              _addStopMarker(
                  tappedPoint, _stops.length - 1); // Agregar marcador de parada
            },
            child: Text('add stop'),
          ),
        ],
      ),
    );
  }

  void _addStopMarker(LatLng tappedPoint, int stopIndex) {
    final String markerIdVal = 'stop_marker_$stopIndex';
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(markerIdVal),
          position: tappedPoint,
          onTap: () {
            setState(() {
              _markers.removeWhere(
                  (marker) => marker.markerId.value == markerIdVal);
            });
          },
        ),
      );
    });
  }

  void _finalizeTrip() {
    Tripadd newTrip = Tripadd(
      name: '',
      latOrigin: _origin!.latitude.toString(),
      lngOrigin: _origin!.longitude.toString(),
      latDestination: _destination!.latitude.toString(),
      lngDestination: _destination!.longitude.toString(),
      date: '',
      price: '',
      seats: 0,
      stops: _stops, // Agregar las paradas
      startTime: '',
    );

    _navigateToTripDetails(newTrip);
  }

  void _navigateToTripDetails(Tripadd trip) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TripDetailsScreen(trip: trip)),
    );
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Location Map'),
        actions: [
          if (_stops.length >= 2)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _finalizeTrip,
            ),
        ],
      ),
      body: _center == null
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
              height: MediaQuery.of(context).size.height,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center!,
                  zoom: 20.0,
                ),
                markers: _markers,
                onTap: _addMarker,
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCurrentLocation,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.my_location, size: 36.0),
      ),
    );
  }
}
