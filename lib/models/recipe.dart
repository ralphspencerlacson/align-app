class Recipe {
  final String title;
  final String description;
  final String servings;
  final String prepTime;
  final String cookTime;
  final String totalTime;
  final String difficulty;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> tips;
  final String image;

  Recipe ({
    required this.title,
    required this.description,
    required this.servings,
    required this.prepTime,
    required this.cookTime,
    required this.totalTime,
    required this.difficulty,
    required this.ingredients,
    required this.instructions,
    required this.tips,
    required this.image,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['title'],
      description: json['description'],
      servings: json['servings'],
      prepTime: json['prep_time'],
      cookTime: json['cook_time'],
      totalTime: json['total_time'],
      difficulty: json['difficulty'],
      ingredients: List<String>.from(json['ingredients']),
      instructions: List<String>.from(json['instructions']),
      tips: List<String>.from(json['tips']),
      image: json['image'],
    );
  }
}