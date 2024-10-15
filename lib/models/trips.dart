class Trip {
  final int id;
  final String name;
  final double latOrigin;
  final double lngOrigin;
  final double latDestination;
  final double lngDestination;
  final String date;
  final String startTime;
  final int driverId;
  final double price;
  final int status;
  final int totalSeats;
  final int usedSeats;
  final String createdAt;
  final String updatedAt;
  final Driver driver;
  final List<Passenger> passengers;
  

  Trip({
    required this.id,
    required this.name,
    required this.latOrigin,
    required this.lngOrigin,
    required this.latDestination,
    required this.lngDestination,
    required this.date,
    required this.startTime,
    required this.driverId,
    required this.price,
    required this.status,
    required this.totalSeats,
    required this.usedSeats,
    required this.createdAt,
    required this.updatedAt,
    required this.driver,
    required this.passengers,
    
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      name: json['name'],
      latOrigin: double.parse(json['latOrigin'].toString()),
      lngOrigin: double.parse(json['lngOrigin'].toString()),
      latDestination: double.parse(json['latDestination'].toString()),
      lngDestination: double.parse(json['lngDestination'].toString()),
      date: json['date'],
      startTime: json['startTime'],
      driverId: json['driverId'],
      price: double.parse(json['price'].toString()),
      status: json['status'],
      totalSeats: json['totalSeats'],
      usedSeats: json['usedSeats'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      driver: Driver.fromJson(json['driver']),
      passengers: List<Passenger>.from(json['passengers'].map((x) => Passenger.fromJson(x))),
    );
  }

  Object? toJson( ) {
    return null;
  }
}

class Driver {
  final int id;
  final String fullname;
  final String email;
  final int type;
  final String createdAt;
  final String updatedAt;

  Driver({
    required this.id,
    required this.fullname,
    required this.email,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      fullname: json['fullname'],
      email: json['email'],
      type: json['type'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class Passenger {
  final int id;
  final String fullname;
  final String email;
  final int type;
  final String createdAt;
  final String updatedAt;
  final TripPassenger tripPassenger;

  Passenger({
    required this.id,
    required this.fullname,
    required this.email,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.tripPassenger,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      id: json['id'],
      fullname: json['fullname'],
      email: json['email'],
      type: json['type'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      tripPassenger: TripPassenger.fromJson(json['trip_passenger']),
    );
  }
}

class TripPassenger {
  final int tripId;
  final int passengerId;
  final int stopId;
  final String createdAt;
  final String updatedAt;

  TripPassenger({
    required this.tripId,
    required this.passengerId,
    required this.stopId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TripPassenger.fromJson(Map<String, dynamic> json) {
    return TripPassenger(
      tripId: json['tripId'],
      passengerId: json['passengerId'],
      stopId: json['stopId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
