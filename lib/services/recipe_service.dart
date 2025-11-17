
import 'dart:convert';

import 'package:align_app/models/recipe.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RecipeService {
  
  static Future<Recipe> generateRecipe(String ingredients) async {
    final _baseUrl = dotenv.env['AI_API_BASEURL'] ?? '';
    final _apiKey = dotenv.env['AI_API_KEY'] ?? '';

    String _region = 'Philippines';

    try {

      if (_baseUrl.isEmpty) {
        throw Exception('API base URL is not set in environment variables.');
      }

      if (_apiKey.isEmpty) {
        throw Exception(' API key is not set in environment variables.');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      };

      final body = {
        'model': 'openai/gpt-oss-120b',
        'messages': [
          {
            'role': 'system',
            'content': '''You are a helpful cook expert from $_region. Your task is to identify and suggest ACTUAL, TRADITIONAL Filipino recipes based on the provided ingredients.

              RULES:
              1. Always suggest a REAL, well-known $_region dish name from traditional cuisine
              2. Match the ingredients to the closest traditional $_region recipe
              3. If ingredients match multiple dishes, choose the most popular/common one
              4. DO NOT invent new dish names - use established traditional recipe names from $_region
              5. Focus on authentic $_region cooking methods and flavors
              6. Use cooking techniques and ingredients commonly available in $_region

              APPROACH:
              - Analyze the provided ingredients
              - Identify what traditional $_region dish they best represent
              - Provide an authentic recipe for that dish
              - Include traditional cooking methods from $_region cuisine
              - Use measurements and ingredients commonly found in $_region

              IMPORTANT: Return your response as a valid JSON object with this exact structure:
              {
                "title": "Traditional $_region Recipe Name",
                "description": "Brief description of this traditional $_region dish",
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
                  "Step 1 instruction using traditional $_region cooking methods",
                  "Step 2 instruction"
                ],
                "tips": [
                  "Authentic $_region cooking tips and variations",
                  "Cooking tip 2"
                ],
                "image": "https://example.com/food-image-url-related-to-this-recipe.jpg"
              }

              IMPORTANT: For each ingredient object, provide:
              - "icon": The most appropriate emoji (🐔 for chicken, 🥩 for beef/meat, 🐟 for fish, 🍚 for rice, 🧄 for garlic, 🧅 for onion, 🥕 for carrot, 🍅 for tomato, 🥔 for potato, 🌶️ for chili/pepper, 🥥 for coconut, 🥚 for egg, 🧂 for salt, 🫒 for oil, 🌿 for herbs, etc.)
              - "label": The ingredient name only (e.g., "Chicken", "Garlic", "Rice")  
              - "quantity": The measurement only (e.g., "1 kg", "5 cloves", "2 cups")

              For the image field which is a required field, get a related food image URL that would be appropriate for this recipe.

              Focus on authentic $_region recipes that families in $_region actually cook.
              Make sure all ingredients and cooking methods are suitable and available in $_region.'''
          },
          {
            'role': 'user',
            'content': 'Create a recipe using these ingredients: $ingredients'
          },
        ],
        'max_tokens': 1500,
        'temperature': 0.3,
      };

      print('Making API request to: $_baseUrl');
      print('Request body: $body');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final recipeString = data['choices'][0]['message']['content'];

        final recipeJson = jsonDecode(recipeString);

        if (recipeJson.containsKey('error')) {
          throw Exception(recipeJson['error']);
        }

        return Recipe.fromJson(recipeJson);
      } else {
        // Handle different HTTP error codes with user-friendly messages
        if (response.statusCode == 401) {
          throw Exception('Authentication failed. Please check your API key.');
        } else if (response.statusCode == 429) {
          throw Exception('Too many requests. Please try again in a moment.');
        } else if (response.statusCode >= 500) {
          throw Exception('Server error. Please try again later.');
        } else {
          throw Exception('Unable to generate recipe. Please try again.');
        }
      }
    } on FormatException {
      throw Exception('Invalid response format. Please try again.');
    } on http.ClientException {
      throw Exception('Network error. Please check your internet connection.');
    } catch (e) {
      print('Error in generateRecipe: $e');
      
      // Convert technical errors to user-friendly messages
      String errorMessage = e.toString();
      if (errorMessage.contains('SocketException') || errorMessage.contains('NetworkException')) {
        throw Exception('Network error. Please check your internet connection.');
      } else if (errorMessage.contains('TimeoutException')) {
        throw Exception('Request timed out. Please try again.');
      } else if (errorMessage.contains('FormatException')) {
        throw Exception('Invalid response. Please try again.');
      } else if (errorMessage.startsWith('Exception: ')) {
        rethrow;
      } else {
        throw Exception('Something went wrong. Please try again.');
      }
    }
  }
}