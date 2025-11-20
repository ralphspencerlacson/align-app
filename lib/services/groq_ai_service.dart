
import 'dart:convert';
import 'dart:io';

import 'package:align_app/models/recipe.dart';
import 'package:align_app/utils/image_utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqAIService {
  static String get _baseUrl => dotenv.env['AI_API_BASEURL'] ?? '';
  static String get _apiKey => dotenv.env['AI_API_KEY'] ?? '';

  static Future<Recipe> generateRecipe(List<String> ingredients) async {
    const String region = 'Philippines';

    if (_baseUrl.isEmpty || _apiKey.isEmpty) {
      throw Exception('API configuration missing. Check environment variables.');
    }

  // Convert list to string
  final ingredientsString = ingredients.join(', ');

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'openai/gpt-oss-120b',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a helpful cook expert from $region. Your task is to identify and suggest ACTUAL, TRADITIONAL Filipino recipes based on the provided ingredients.

              RULES:
              1. Always suggest a REAL, well-known $region dish name from traditional cuisine
              2. Match the ingredients to the closest traditional $region recipe
              3. If ingredients match multiple dishes, choose the most popular/common one
              4. DO NOT invent new dish names - use established traditional recipe names from $region
              5. Focus on authentic $region cooking methods and flavors
              6. Use cooking techniques and ingredients commonly available in $region

              APPROACH:
              - Analyze the provided ingredients
              - Identify what traditional $region dish they best represent
              - Provide an authentic recipe for that dish
              - Include traditional cooking methods from $region cuisine
              - Use measurements and ingredients commonly found in $region

              IMPORTANT: Return your response as a valid JSON object with this exact structure:
              {
                "title": "Traditional $region Recipe Name",
                "description": "Brief description of this traditional $region dish. 2-3 sentences only.",
                "servings": "Number of servings",
                "prep_time": "Preparation time in minutes",
                "cook_time": "Cooking time in minutes",
                "total_time": "Total time in minutes",
                "difficulty": "Easy/Medium/Hard",
                "ingredients": [
                  {
                    "icon": "🐔",
                    "label": "Chicken",
                    "quantity": "1 kg"
                  },
                  {
                    "icon": "🧄",
                    "label": "Garlic",
                    "quantity": "5 cloves"
                  }
                ],
                "instructions": [
                  "Instruction using traditional $region cooking methods",
                  "Instruction"
                ],
                "tips": [
                  "Authentic $region cooking tips and variations",
                  "Cooking tip 2"
                ],
                "image": "https://example.com/food-image-url-related-to-this-recipe.jpg"
              }

              IMPORTANT: For each ingredient object, provide:
              - "icon": The most appropriate emoji (🐔 for chicken, 🥩 for beef/meat, 🐟 for fish, 🍚 for rice, 🧄 for garlic, 🧅 for onion, 🥕 for carrot, 🍅 for tomato, 🥔 for potato, 🌶️ for chili/pepper, 🥥 for coconut, 🥚 for egg, 🧂 for salt, 🫒 for oil, 🌿 for herbs, etc.)
              - "label": The ingredient name only (e.g., "Chicken", "Garlic", "Rice")  
              - "quantity": The measurement only (e.g., "1 kg", "5 cloves", "2 cups")

              For the image field which is a required field, get a related food image URL that would be appropriate for this recipe.

              Focus on authentic $region recipes that families in $region actually cook.
              Make sure all ingredients and cooking methods are suitable and available in $region.'''
            },
            {
              'role': 'user',
              'content': 'Create a recipe using these ingredients: $ingredientsString'
            },
          ],
          'max_tokens': 1500,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode != 200) {
        final errorMessage = switch (response.statusCode) {
          401 => 'Authentication failed. Please check your API key.',
          429 => 'Too many requests. Please try again in a moment.',
          >= 500 => 'Server error. Please try again later.',
          _ => 'Unable to generate recipe. Please try again.',
        };
        throw Exception(errorMessage);
      }

      final data = jsonDecode(response.body);
      final recipeString = data['choices'][0]['message']['content'];
      final recipeJson = jsonDecode(recipeString);

      if (recipeJson.containsKey('error')) {
        throw Exception(recipeJson['error']);
      }

      return Recipe.fromJson(recipeJson);
    } on FormatException {
      throw Exception('Invalid response format. Please try again.');
    } on http.ClientException {
      throw Exception('Network error. Please check your internet connection.');
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('SocketException') || errorMessage.contains('NetworkException')) {
        throw Exception('Network error. Please check your internet connection.');
      } else if (errorMessage.contains('TimeoutException')) {
        throw Exception('Request timed out. Please try again.');
      } else if (errorMessage.startsWith('Exception: ')) {
        rethrow;
      } else {
        throw Exception('Something went wrong. Please try again.');
      }
    }
  }

  static Future<List<String>> analyzeIngredients(File imageFile) async {
    if (_baseUrl.isEmpty || _apiKey.isEmpty) {
      throw Exception('API configuration missing. Check environment variables.');
    }

    final fileSize = await imageFile.length();
    if (fileSize > 20 * 1024 * 1024) {
      throw Exception('Image size exceeds 20MB limit.');
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = ImageUtils.getMimeType(imageFile.path);

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'meta-llama/llama-4-scout-17b-16e-instruct',
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': '''Look at this image and identify specific food ingredients.
                    Rules:
                    - Only list ingredients you can clearly identify
                    - Be specific: "red bell pepper" not "vegetable"
                    - Separate with commas
                    - Maximum 8 ingredients
                    - No explanations, just the list
                    
                    Response format - return EXACTLY this structure with no extra text:
                    {"ingredients":["ingredient1","ingredient2","ingredient3"]}

                    Provide the list of ingredients found in the image.
                    ''',
                },
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:$mimeType;base64,$base64Image'},
                },
              ],
            },
          ],
          'max_tokens': 100,
          'temperature': 0.2,
        }),
      );

      if (response.statusCode != 200) {
        final errorBody = response.body;
        try {
          final errorData = jsonDecode(errorBody);
          final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
          throw Exception('Groq API Error (${response.statusCode}): $errorMessage');
        } catch (_) {
          throw Exception('Groq API Error (${response.statusCode}): $errorBody');
        }
      }

      final data = jsonDecode(response.body);
      if (data['choices'] == null || data['choices'].isEmpty) {
        throw Exception('No response content from Groq API');
      }

      final content = data['choices'][0]['message']['content'] as String;
        print('Groq Vision Response Content: $content');
      try {
        final contentJson = jsonDecode(content);
        if (contentJson['ingredients'] != null) {
          return List<String>.from(contentJson['ingredients']);
        }
      } catch (_) {
        // If JSON fails, parse as comma-separated
        return content
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }

      throw Exception('No ingredients found in the response');
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception('Failed to analyze image with Groq Vision: $e');
    }
  }
}
