class Dessert {
  final String id;
  final String name;
  final String thumb;

  const Dessert({required this.id, required this.name, required this.thumb});

  factory Dessert.fromJson(Map<String, dynamic> j) => Dessert(
        id: j['idMeal'].toString(),
        name: (j['strMeal'] ?? '').toString(),
        thumb: (j['strMealThumb'] ?? '').toString(),
      );
}

class Ingredient {
  final String name;
  final String measure;
  const Ingredient(this.name, this.measure);
}

class MealDetail {
  final String id;
  final String name;
  final String thumb;
  final String category;
  final String area;
  final String instructions;
  final List<Ingredient> ingredients;

  const MealDetail({
    required this.id,
    required this.name,
    required this.thumb,
    required this.category,
    required this.area,
    required this.instructions,
    required this.ingredients,
  });

  factory MealDetail.fromJson(Map<String, dynamic> j) {
    final items = <Ingredient>[];
    for (var i = 1; i <= 20; i++) {
      final name = (j['strIngredient$i'] ?? '').toString().trim();
      final measure = (j['strMeasure$i'] ?? '').toString().trim();
      if (name.isNotEmpty) items.add(Ingredient(name, measure));
    }
    return MealDetail(
      id: j['idMeal'].toString(),
      name: (j['strMeal'] ?? '').toString(),
      thumb: (j['strMealThumb'] ?? '').toString(),
      category: (j['strCategory'] ?? '').toString(),
      area: (j['strArea'] ?? '').toString(),
      instructions: (j['strInstructions'] ?? '').toString(),
      ingredients: items,
    );
  }
}
