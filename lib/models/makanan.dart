// import 'dart:convert';

class RestaurantListResult {
  final bool error;
  final String message;
  final int count;
  final List<Restaurant> restaurants;

  RestaurantListResult({
    required this.error,
    required this.message,
    required this.count,
    required this.restaurants,
  });

  factory RestaurantListResult.fromJson(Map<String, dynamic> json) =>
      RestaurantListResult(
        error: json["error"] as bool,
        message: json["message"] as String,
        count: json["count"] as int,
        restaurants: List<Restaurant>.from(
          json["restaurants"].map((x) => Restaurant.fromJson(x)),
        ),
      );
}

class Restaurant {
  final String? id;
  final String? name;
  final String? description;
  final String? pictureId;
  final String? city;
  final double? rating;

  Restaurant({
    this.id,
    this.name,
    this.description,
    this.pictureId,
    this.city,
    this.rating,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
    id: json["id"] as String?,
    name: json["name"] as String?,
    description: json["description"] as String?,
    pictureId: json["pictureId"] as String?,
    city: json["city"] as String?,
    rating: (json['rating'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pictureId': pictureId,
      'city': city,
      'rating': rating,
    };
  }

  // Konversi dari Map (Sqflite)
  factory Restaurant.fromMap(Map<String, dynamic> map) => Restaurant(
    id: map['id'],
    name: map['name'],
    description: map['description'],
    pictureId: map['pictureId'],
    city: map['city'],
    rating: map['rating'],
  );
}

// --- Model Detail Restaurant ---
class RestaurantDetailResult {
  final bool error;
  final String message;
  final RestaurantDetail restaurant;

  RestaurantDetailResult({
    required this.error,
    required this.message,
    required this.restaurant,
  });

  factory RestaurantDetailResult.fromJson(Map<String, dynamic> json) =>
      RestaurantDetailResult(
        error: json["error"] as bool,
        message: json["message"] as String,
        restaurant: RestaurantDetail.fromJson(json["restaurant"]),
      );
}

class RestaurantDetail {
  final String? id;
  final String? name;
  final String? description;
  final String? city;
  final String? address;
  final String? pictureId;
  final List<Category> categories;
  final Menus menus;
  final double? rating;

  RestaurantDetail({
    this.id,
    this.name,
    this.description,
    this.city,
    this.address,
    this.pictureId,
    required this.categories,
    required this.menus,
    this.rating,
  });

  factory RestaurantDetail.fromJson(Map<String, dynamic> json) =>
      RestaurantDetail(
        id: json["id"] as String?,
        name: json["name"] as String?,
        description: json["description"] as String?,
        city: json["city"] as String?,
        address: json["address"] as String?,
        pictureId: json["pictureId"] as String?,
        categories: List<Category>.from(
          json["categories"].map((x) => Category.fromJson(x)),
        ),
        menus: Menus.fromJson(json["menus"]),
        rating: (json['rating'] as num?)?.toDouble(),
      );
}

class Category {
  final String name;
  Category({required this.name});
  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(name: json["name"] as String);
}

class Menus {
  final List<Category> foods;
  final List<Category> drinks;

  Menus({required this.foods, required this.drinks});
  factory Menus.fromJson(Map<String, dynamic> json) => Menus(
    foods: List<Category>.from(json["foods"].map((x) => Category.fromJson(x))),
    drinks: List<Category>.from(
      json["drinks"].map((x) => Category.fromJson(x)),
    ),
  );
}
