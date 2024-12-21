import 'dart:convert';

List<Booking> bookingFromJson(String str) =>
    List<Booking>.from(json.decode(str).map((x) => Booking.fromJson(x)));

String bookingToJson(List<Booking> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Booking {
  String id;
  User user;
  Showroom showroom;
  Car car;
  String visitDate;
  String visitTime;
  Status status;
  String? notes;

  Booking({
    required this.id,
    required this.user,
    required this.showroom,
    required this.car,
    required this.visitDate,
    required this.visitTime,
    required this.status,
    this.notes,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json["id"],
        user: User.fromJson(json["user"]),
        showroom: Showroom.fromJson(json["showroom"]),
        car: Car.fromJson(json["car"]),
        visitDate: json["visit_date"],
        visitTime: json["visit_time"],
        status: statusValues.map[json["status"]]!,
        notes: json["notes"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user": user.toJson(),
        "showroom": showroom.toJson(),
        "car": car.toJson(),
        "visit_date": visitDate,
        "visit_time": visitTime,
        "status": statusValues.reverse[status],
        "notes": notes,
      };
}

class Showroom {
  String id;
  String name;
  String location;
  String regency;

  Showroom({
    required this.id,
    required this.name,
    required this.location,
    required this.regency,
  });

  factory Showroom.fromJson(Map<String, dynamic> json) => Showroom(
        id: json["id"],
        name: json["name"],
        location: json["location"],
        regency: json["regency"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "showroom_name": name,
        "showroom_location": location,
        "showroom_regency": regency,
      };
}

class Car {
  String id;
  String brand;
  String carType;
  String model;
  String color;
  int year;
  String transmission;
  String fuelType;
  int doors;
  int cylinderSize;
  int cylinderTotal;
  bool turbo;
  int mileage;
  String licensePlate;
  int priceCash;
  int priceCredit;
  double pkbValue;
  double pkbBase;
  String stnkDate;
  String levyDate;
  double swdkllj;
  double totalLevy;

  Car({
    required this.id,
    required this.brand,
    required this.carType,
    required this.model,
    required this.color,
    required this.year,
    required this.transmission,
    required this.fuelType,
    required this.doors,
    required this.cylinderSize,
    required this.cylinderTotal,
    required this.turbo,
    required this.mileage,
    required this.licensePlate,
    required this.priceCash,
    required this.priceCredit,
    required this.pkbValue,
    required this.pkbBase,
    required this.stnkDate,
    required this.levyDate,
    required this.swdkllj,
    required this.totalLevy,
  });

  factory Car.fromJson(Map<String, dynamic> json) => Car(
        id: json["id"],
        brand: json["brand"],
        carType: json["car_type"],
        model: json["model"],
        color: json["color"],
        year: json["year"],
        transmission: json["transmission"],
        fuelType: json["fuel_type"],
        doors: json["doors"],
        cylinderSize: json["cylinder_size"],
        cylinderTotal: json["cylinder_total"],
        turbo: json["turbo"],
        mileage: json["mileage"],
        licensePlate: json["license_plate"],
        priceCash: json["price_cash"],
        priceCredit: json["price_credit"],
        pkbValue: json["pkb_value"],
        pkbBase: json["pkb_base"],
        stnkDate: json["stnk_date"],
        levyDate: json["levy_date"],
        swdkllj: json["swdkllj"],
        totalLevy: json["total_levy"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "brand": brand,
        "car_type": carType,
        "model": model,
        "color": color,
        "year": year,
        "transmission": transmission,
        "fuel_type": fuelType,
        "doors": doors,
        "cylinder_size": cylinderSize,
        "cylinder_total": cylinderTotal,
        "turbo": turbo,
        "mileage": mileage,
        "license_plate": licensePlate,
        "price_cash": priceCash,
        "price_credit": priceCredit,
        "pkb_value": pkbValue,
        "pkb_base": pkbBase,
        "stnk_date": stnkDate,
        "levy_date": levyDate,
        "swdkllj": swdkllj,
        "total_levy": totalLevy,
      };
}

enum Status { PENDING, CONFIRMED, CANCELED }

final statusValues = EnumValues({
  "pending": Status.PENDING,
  "confirmed": Status.CONFIRMED,
  "canceled": Status.CANCELED,
});

class User {
  int id;
  String username;

  User({
    required this.id,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        username: json["username"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
