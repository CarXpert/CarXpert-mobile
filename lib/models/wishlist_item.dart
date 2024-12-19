// To parse this JSON data, do
//
//     final wishlistItem = wishlistItemFromJson(jsonString);

import 'dart:convert';

List<WishlistItem> wishlistItemFromJson(String str) => List<WishlistItem>.from(json.decode(str).map((x) => WishlistItem.fromJson(x)));

String wishlistItemToJson(List<WishlistItem> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class WishlistItem {
    int pk;
    Car car;
    String? notes;
    DateTime createdAt;

    WishlistItem({
        required this.pk,
        required this.car,
        required this.notes,
        required this.createdAt,
    });

    factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
        pk: json["pk"],
        car: Car.fromJson(json["car"]),
        notes: json["notes"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "pk": pk,
        "car": car.toJson(),
        "notes": notes,
        "created_at": createdAt.toIso8601String(),
    };
}

class Car {
    String carId;
    String brand;
    String carType;
    String showroom;

    Car({
        required this.carId,
        required this.brand,
        required this.carType,
        required this.showroom,
    });

    factory Car.fromJson(Map<String, dynamic> json) => Car(
        carId: json["carId"],
        brand: json["brand"],
        carType: json["car_type"],
        showroom: json["showroom"],
    );

    Map<String, dynamic> toJson() => {
        "carId": carId,
        "brand": brand,
        "car_type": carType,
        "showroom": showroom,
    };
}
