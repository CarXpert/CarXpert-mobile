import 'dart:convert';

List<WishlistItem> wishlistItemFromJson(String str) => List<WishlistItem>.from(json.decode(str).map((x) => WishlistItem.fromJson(x)));

String wishlistItemToJson(List<WishlistItem> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class WishlistItem {
    String model;
    int pk;
    Fields fields;

    WishlistItem({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
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
    String car;
    String? notes;
    DateTime createdAt;

    Fields({
        required this.user,
        required this.car,
        required this.notes,
        required this.createdAt,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        car: json["car"],
        notes: json["notes"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "car": car,
        "notes": notes,
        "created_at": createdAt.toIso8601String(),
    };
}