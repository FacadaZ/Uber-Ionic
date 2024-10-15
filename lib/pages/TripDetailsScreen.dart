import 'package:driverchofer/pages/tripslista.dart';
import 'package:driverchofer/providers/ApiProvider.dart';
import 'package:flutter/material.dart';
import 'package:driverchofer/models/tripsadd.dart';

class TripDetailsScreen extends StatefulWidget {
  final Tripadd trip;

  const TripDetailsScreen({Key? key, required this.trip}) : super(key: key);

  @override
  _TripDetailsScreenState createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();

  ApiProvider apiProvider = ApiProvider();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.trip.name;
    _dateController.text = widget.trip.date;
    _priceController.text = widget.trip.price;
    _seatsController.text = widget.trip.seats.toString();
    _startTimeController.text = widget.trip.startTime;
  }

  Future<bool> addTrip(Tripadd tripDetails) async {
    bool tripAdded = (await apiProvider.addTrip(tripDetails)) as bool;
    return tripAdded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Viaje'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre del viaje'),
            ),
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Fecha del viaje'),
            ),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Precio del viaje'),
            ),
            TextFormField(
              controller: _seatsController,
              decoration:
                  const InputDecoration(labelText: 'Asientos disponibles'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _startTimeController,
              decoration: const InputDecoration(labelText: 'Hora de salida'),
            ),
            TextFormField(
              controller:
                  TextEditingController(text: widget.trip.latOrigin.toString()),
              decoration: const InputDecoration(labelText: 'Latitud Origen'),
              enabled: false,
            ),
            TextFormField(
              controller:
                  TextEditingController(text: widget.trip.lngOrigin.toString()),
              decoration: const InputDecoration(labelText: 'Longitud Origen'),
              enabled: false,
            ),
            TextFormField(
              controller: TextEditingController(
                  text: widget.trip.latDestination.toString()),
              decoration: const InputDecoration(labelText: 'Latitud Destino'),
              enabled: false,
            ),
            TextFormField(
              controller: TextEditingController(
                  text: widget.trip.lngDestination.toString()),
              decoration: const InputDecoration(labelText: 'Longitud Destino'),
              enabled: false,
            ),
            SizedBox(height: 20),
            const Text(
              'Paradas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...widget.trip.stops.map((stop) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: TextEditingController(text: stop.lat),
                      decoration:
                          const InputDecoration(labelText: 'Latitud Parada'),
                      enabled: false,
                    ),
                    TextFormField(
                      controller: TextEditingController(text: stop.lng),
                      decoration:
                          const InputDecoration(labelText: 'Longitud Parada'),
                      enabled: false,
                    ),
                    TextFormField(
                      controller: TextEditingController(text: stop.time),
                      decoration:
                          const InputDecoration(labelText: 'Hora de Parada'),
                      enabled: false,
                    ),
                  ],
                ),
              );
            }).toList(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  print('Paradas existentes:');
                  for (var stop in widget.trip.stops) {
                    print(
                        'Latitud: ${stop.lat}, Longitud: ${stop.lng}, Hora: ${stop.time}');
                  }

                  Tripadd tripDetails = Tripadd(
                    name: _nameController.text,
                    date: _dateController.text,
                    price: _priceController.text,
                    seats: int.parse(_seatsController.text),
                    startTime: _startTimeController.text,
                    latOrigin: widget.trip.latOrigin,
                    lngOrigin: widget.trip.lngOrigin,
                    latDestination: widget.trip.latDestination,
                    lngDestination: widget.trip.lngDestination,
                    stops: widget.trip.stops,
                  );

                  bool tripAdded = await addTrip(tripDetails);
                  if (tripAdded) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => TripsScreen()),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Error'),
                        content: Text('No se pudo agregar el viaje.'),
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
                      content: Text('Ocurrió un error al agregar el viaje.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Agregar Viaje'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Limpiar los controladores
    _nameController.dispose();
    _dateController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    _startTimeController.dispose();
    super.dispose();
  }
}
