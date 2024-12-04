// To parse this JSON data, do
//
//     final carEntry = carEntryFromJson(jsonString);

import 'dart:convert';

List<CarEntry> carEntryFromJson(String str) => List<CarEntry>.from(json.decode(str).map((x) => CarEntry.fromJson(x)));

String carEntryToJson(List<CarEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CarEntry {
    CarEntryModel model;
    String pk;
    Fields fields;

    CarEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory CarEntry.fromJson(Map<String, dynamic> json) => CarEntry(
        model: carEntryModelValues.map[json["model"]]!,
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": carEntryModelValues.reverse[model],
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    String showroom;
    String brand;
    String carType;
    FieldsModel model;
    String color;
    int year;
    Transmission transmission;
    FuelType fuelType;
    int doors;
    int cylinderSize;
    int cylinderTotal;
    bool turbo;
    int mileage;
    String licensePlate;
    int priceCash;
    int priceCredit;
    int pkbValue;
    int pkbBase;
    DateTime stnkDate;
    DateTime levyDate;
    int swdkllj;
    int totalLevy;
    DateTime createdAt;
    DateTime updatedAt;

    Fields({
        required this.showroom,
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
        required this.createdAt,
        required this.updatedAt,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        showroom: json["showroom"],
        brand: json["brand"],
        carType: json["car_type"],
        model: fieldsModelValues.map[json["model"]]!,
        color: json["color"],
        year: json["year"],
        transmission: transmissionValues.map[json["transmission"]]!,
        fuelType: fuelTypeValues.map[json["fuel_type"]]!,
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
        stnkDate: DateTime.parse(json["stnk_date"]),
        levyDate: DateTime.parse(json["levy_date"]),
        swdkllj: json["swdkllj"],
        totalLevy: json["total_levy"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "showroom": showroom,
        "brand": brand,
        "car_type": carType,
        "model": fieldsModelValues.reverse[model],
        "color": color,
        "year": year,
        "transmission": transmissionValues.reverse[transmission],
        "fuel_type": fuelTypeValues.reverse[fuelType],
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
        "stnk_date": "${stnkDate.year.toString().padLeft(4, '0')}-${stnkDate.month.toString().padLeft(2, '0')}-${stnkDate.day.toString().padLeft(2, '0')}",
        "levy_date": "${levyDate.year.toString().padLeft(4, '0')}-${levyDate.month.toString().padLeft(2, '0')}-${levyDate.day.toString().padLeft(2, '0')}",
        "swdkllj": swdkllj,
        "total_levy": totalLevy,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
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

enum FieldsModel {
    JEEP,
    JEEP_L_C_HDTP,
    JEEP_S_C_HDTP,
    MICRO_MINIBUS,
    MINIBUS,
    MINIVAN,
    MODEL_MINIBUS,
    MPV,
    SEDAN,
    SUV
}

final fieldsModelValues = EnumValues({
    "JEEP": FieldsModel.JEEP,
    "JEEP L.C.HDTP": FieldsModel.JEEP_L_C_HDTP,
    "JEEP S.C.HDTP": FieldsModel.JEEP_S_C_HDTP,
    "MICRO/MINIBUS": FieldsModel.MICRO_MINIBUS,
    "MINIBUS": FieldsModel.MINIBUS,
    "MINIVAN": FieldsModel.MINIVAN,
    "Minibus": FieldsModel.MODEL_MINIBUS,
    "MPV": FieldsModel.MPV,
    "SEDAN": FieldsModel.SEDAN,
    "SUV": FieldsModel.SUV
});

enum Transmission {
    AUTOMATIC,
    MANUAL
}

final transmissionValues = EnumValues({
    "automatic": Transmission.AUTOMATIC,
    "manual": Transmission.MANUAL
});

enum CarEntryModel {
    CARS_CAR
}

final carEntryModelValues = EnumValues({
    "cars.car": CarEntryModel.CARS_CAR
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
