class StringUtils {
  /// Parse the Groq response to extract clean ingredient list
  static List<String> parseIngredients(String content) {
    // Clean up the response
    String cleaned = content.trim();
    
    // Remove any extra text that might be included
    if (cleaned.toLowerCase().contains('ingredients:')) {
      cleaned = cleaned.split('ingredients:').last.trim();
    }
    
    // Split by commas and clean each ingredient
    List<String> ingredients = cleaned
        .split(',')
        .map((ingredient) => ingredient.trim())
        .where((ingredient) => ingredient.isNotEmpty)
        .where((ingredient) => ingredient.length > 1) // Remove single characters
        .take(10) // Limit to 10 ingredients
        .toList();

    // Filter out common non-ingredients
    ingredients = ingredients.where((ingredient) {
      String lower = ingredient.toLowerCase();
      return !lower.contains('image') &&
             !lower.contains('photo') &&
             !lower.contains('picture') &&
             !lower.contains('visible') &&
             !lower.contains('appears') &&
             !lower.contains('seems');
    }).toList();

    return ingredients;
  }
}