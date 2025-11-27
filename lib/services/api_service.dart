// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/makanan.dart';

class ApiService {
  static const String baseUrl = 'https://restaurant-api.dicoding.dev/';
  static const String smallPictureUrl = '${baseUrl}images/small/';
  static const String mediumPictureUrl = '${baseUrl}images/medium/';

  Future<RestaurantListResult> fetchAllRestaurants() async {
    final response = await http.get(Uri.parse('${baseUrl}list'));

    if (response.statusCode == 200) {
      return RestaurantListResult.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load restaurant list');
    }
  }

  Future<RestaurantDetailResult> fetchRestaurantDetail(String id) async {
    final response = await http.get(Uri.parse('${baseUrl}detail/$id'));

    if (response.statusCode == 200) {
      return RestaurantDetailResult.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load restaurant detail');
    }
  }

  Future<RestaurantListResult> searchRestaurants(String query) async {
    final response = await http.get(Uri.parse('${baseUrl}search?q=$query'));

    if (response.statusCode == 200) {
      return RestaurantListResult.fromJson(json.decode(response.body));
    } else {
      try {
        return RestaurantListResult.fromJson(json.decode(response.body));
      } catch (e) {
        return RestaurantListResult(
          error: false,
          message: "No restaurants found for '$query'",
          count: 0,
          restaurants: [],
        );
      }
    }
  }
}
