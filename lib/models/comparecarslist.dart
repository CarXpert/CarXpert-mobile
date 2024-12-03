// To parse this JSON data, do
//
//     final compareCarList = compareCarListFromJson(jsonString);

import 'dart:convert';

List<CompareCarList> compareCarListFromJson(String str) => List<CompareCarList>.from(json.decode(str).map((x) => CompareCarList.fromJson(x)));

String compareCarListToJson(List<CompareCarList> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CompareCarList {
    int id;
    String title;
    Car car1;
    Car car2;
    DateTime dateAdded;

    CompareCarList({
        required this.id,
        required this.title,
        required this.car1,
        required this.car2,
        required this.dateAdded,
    });

    factory CompareCarList.fromJson(Map<String, dynamic> json) => CompareCarList(
        id: json["id"],
        title: json["title"],
        car1: Car.fromJson(json["car1"]),
        car2: Car.fromJson(json["car2"]),
        dateAdded: DateTime.parse(json["date_added"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "car1": car1.toJson(),
        "car2": car2.toJson(),
        "date_added": dateAdded.toIso8601String(),
    };
}

class Car {
    String brand;
    String model;

    Car({
        required this.brand,
        required this.model,
    });

    factory Car.fromJson(Map<String, dynamic> json) => Car(
        brand: json["brand"],
        model: json["model"],
    );

    Map<String, dynamic> toJson() => {
        "brand": brand,
        "model": model,
    };
}
