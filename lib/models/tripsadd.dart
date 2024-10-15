class Stop {
  final String lat;
  final String lng;
  final String time;

  Stop({
    required this.lat,
    required this.lng,
    required this.time,
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      lat: json['lat'],
      lng: json['lng'],
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'time': time,
    };
  }
}

class Tripadd {
  final String name;
  final String latOrigin;
  final String lngOrigin;
  final String latDestination;
  final String lngDestination;
  final String date;
  final String price;
  final int seats;
  final List<Stop> stops;
  final String startTime;

  Tripadd({
    required this.name,
    required this.latOrigin,
    required this.lngOrigin,
    required this.latDestination,
    required this.lngDestination,
    required this.date,
    required this.price,
    required this.seats,
    required this.stops,
    required this.startTime,
  });

  factory Tripadd.fromJson(Map<String, dynamic> json) {
    var stopsFromJson = json['stops'] as List;
    List<Stop> stopList = stopsFromJson.map((i) => Stop.fromJson(i)).toList();

    return Tripadd(
      name: json['name'],
      latOrigin: json['latOrigin'],
      lngOrigin: json['lngOrigin'],
      latDestination: json['latDestination'],
      lngDestination: json['lngDestination'],
      date: json['date'],
      price: json['price'],
      seats: json['seats'],
      stops: stopList,
      startTime: json['startTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latOrigin': latOrigin,
      'lngOrigin': lngOrigin,
      'latDestination': latDestination,
      'lngDestination': lngDestination,
      'date': date,
      'price': price,
      'seats': seats,
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'startTime': startTime,
    };
  }
}
