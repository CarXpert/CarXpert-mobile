import 'dart:convert';

List<CompareCar> compareCarFromJson(String str) => List<CompareCar>.from(json.decode(str).map((x) => CompareCar.fromJson(x)));

String compareCarToJson(List<CompareCar> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CompareCar {
    String model;
    int pk;
    Fields fields;

    CompareCar({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory CompareCar.fromJson(Map<String, dynamic> json) => CompareCar(
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
    int comparecar;
    int user;

    Fields({
        required this.comparecar,
        required this.user,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        comparecar: json["comparecar"],
        user: json["user"],
    );

    Map<String, dynamic> toJson() => {
        "comparecar": comparecar,
        "user": user,
    };
}
