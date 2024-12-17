// To parse this JSON data, do
//
//     final showroomEntry = showroomEntryFromJson(jsonString);

import 'dart:convert';

ShowroomEntry showroomEntryFromJson(String str) => ShowroomEntry.fromJson(json.decode(str));

String showroomEntryToJson(ShowroomEntry data) => json.encode(data.toJson());

class ShowroomEntry {
    List<Showroom> showrooms;

    ShowroomEntry({
        required this.showrooms,
    });

    factory ShowroomEntry.fromJson(Map<String, dynamic> json) => ShowroomEntry(
        showrooms: List<Showroom>.from(json["showrooms"].map((x) => Showroom.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "showrooms": List<dynamic>.from(showrooms.map((x) => x.toJson())),
    };
}

class Showroom {
    String id;
    String showroomName;
    String showroomLocation;
    String showroomRegency;

    Showroom({
        required this.id,
        required this.showroomName,
        required this.showroomLocation,
        required this.showroomRegency,
    });

    factory Showroom.fromJson(Map<String, dynamic> json) => Showroom(
        id: json["id"],
        showroomName: json["showroom_name"],
        showroomLocation: json["showroom_location"],
        showroomRegency: json["showroom_regency"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "showroom_name": showroomName,
        "showroom_location": showroomLocation,
        "showroom_regency": showroomRegency,
    };
}
