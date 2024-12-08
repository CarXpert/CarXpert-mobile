// To parse this JSON data, do
//
//     final booking = bookingFromJson(jsonString);

import 'dart:convert';

List<Booking> bookingFromJson(String str) =>
    List<Booking>.from(json.decode(str).map((x) => Booking.fromJson(x)));

String bookingToJson(List<Booking> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Booking {
  String model;
  String pk;
  Fields fields;

  Booking({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class Fields {
  int user;
  String showroom;
  String car;
  DateTime visitDate;
  String visitTime;
  String status;
  String notes;

  Fields({
    required this.user,
    required this.showroom,
    required this.car,
    required this.visitDate,
    required this.visitTime,
    required this.status,
    required this.notes,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        showroom: json["showroom"],
        car: json["car"],
        visitDate: DateTime.parse(json["visit_date"]),
        visitTime: json["visit_time"],
        status: json["status"],
        notes: json["notes"],
      );

  Map<String, dynamic> toJson() => {
        "user": user,
        "showroom": showroom,
        "car": car,
        "visit_date":
            "${visitDate.year.toString().padLeft(4, '0')}-${visitDate.month.toString().padLeft(2, '0')}-${visitDate.day.toString().padLeft(2, '0')}",
        "visit_time": visitTime,
        "status": status,
        "notes": notes,
      };
}
