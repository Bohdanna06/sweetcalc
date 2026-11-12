import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

/// Мережевий шар: TheMealDB (безкоштовне API без ключа).
class MealApi {
  static const _base = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<dynamic>> _get(String path) async {
    final res = await http
        .get(Uri.parse('$_base/$path'))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return (body['meals'] as List?) ?? [];
  }

  Future<List<Dessert>> fetchDesserts() async {
    final meals = await _get('filter.php?c=Dessert');
    return meals.map((m) => Dessert.fromJson(m as Map<String, dynamic>)).toList();
  }

  Future<List<Dessert>> searchDesserts(String query) async {
    final meals = await _get('search.php?s=${Uri.encodeQueryComponent(query)}');
    return meals
        .cast<Map<String, dynamic>>()
        .where((m) => m['strCategory'] == 'Dessert')
        .map(Dessert.fromJson)
        .toList();
  }

  Future<MealDetail?> fetchDetail(String id) async {
    final meals = await _get('lookup.php?i=$id');
    if (meals.isEmpty) return null;
    return MealDetail.fromJson(meals.first as Map<String, dynamic>);
  }
}
