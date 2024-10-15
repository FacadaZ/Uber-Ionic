// To parse this JSON data, do
//
//     final rutasid = rutasidFromJson(jsonString);

import 'dart:convert';

Rutasid rutasidFromJson(String str) => Rutasid.fromJson(json.decode(str));

String rutasidToJson(Rutasid data) => json.encode(data.toJson());

class Rutasid {
    int id;
    String name;
    String latOrigin;
    String lngOrigin;
    String latDestination;
    String lngDestination;
    List<Stop> stops;

    Rutasid({
        required this.id,
        required this.name,
        required this.latOrigin,
        required this.lngOrigin,
        required this.latDestination,
        required this.lngDestination,
        required this.stops,
    });

    factory Rutasid.fromJson(Map<String, dynamic> json) => Rutasid(
        id: json["id"],
        name: json["name"],
        latOrigin: json["latOrigin"],
        lngOrigin: json["lngOrigin"],
        latDestination: json["latDestination"],
        lngDestination: json["lngDestination"],
        stops: List<Stop>.from(json["stops"].map((x) => Stop.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "latOrigin": latOrigin,
        "lngOrigin": lngOrigin,
        "latDestination": latDestination,
        "lngDestination": lngDestination,
        "stops": List<dynamic>.from(stops.map((x) => x.toJson())),
    };
}

class Stop {
    int id;
    String lat;
    String lng;
    String time;

    Stop({
        required this.id,
        required this.lat,
        required this.lng,
        required this.time,
    });

    factory Stop.fromJson(Map<String, dynamic> json) => Stop(
        id: json["id"],
        lat: json["lat"],
        lng: json["lng"],
        time: json["time"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "lat": lat,
        "lng": lng,
        "time": time,
    };
}
