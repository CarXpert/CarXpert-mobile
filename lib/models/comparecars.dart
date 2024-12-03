// To parse this JSON data, do
//
//     final compareCar = compareCarFromJson(jsonString);

import 'dart:convert';

List<CompareCar> compareCarFromJson(String str) => List<CompareCar>.from(json.decode(str).map((x) => CompareCar.fromJson(x)));

String compareCarToJson(List<CompareCar> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CompareCar {
    int id;
    String? title;
    DateTime dateAdded;
    Car car1;
    Car car2;

    CompareCar({
        required this.id,
        required this.title,
        required this.dateAdded,
        required this.car1,
        required this.car2,
    });

    factory CompareCar.fromJson(Map<String, dynamic> json) => CompareCar(
        id: json["id"],
        title: json["title"],
        dateAdded: DateTime.parse(json["date_added"]),
        car1: Car.fromJson(json["car1"]),
        car2: Car.fromJson(json["car2"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "date_added": dateAdded.toIso8601String(),
        "car1": car1.toJson(),
        "car2": car2.toJson(),
    };
}

class Car {
    String id;
    String brand;
    String model;
    int year;
    FuelType fuelType;
    String color;
    int priceCash;

    Car({
        required this.id,
        required this.brand,
        required this.model,
        required this.year,
        required this.fuelType,
        required this.color,
        required this.priceCash,
    });

    factory Car.fromJson(Map<String, dynamic> json) => Car(
        id: json["id"],
        brand: json["brand"],
        model: json["model"],
        year: json["year"],
        fuelType: fuelTypeValues.map[json["fuel_type"]]!,
        color: json["color"],
        priceCash: json["price_cash"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "brand": brand,
        "model": model,
        "year": year,
        "fuel_type": fuelTypeValues.reverse[fuelType],
        "color": color,
        "price_cash": priceCash,
    };
}

enum FuelType {
    DIESEL,
    GASOLINE
}

final fuelTypeValues = EnumValues({
    "Diesel": FuelType.DIESEL,
    "Gasoline": FuelType.GASOLINE
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
