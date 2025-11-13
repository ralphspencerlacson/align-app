
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RecipeService {
  
  static Future<String> generateRecipe(String ingredients) async {
    final _baseUrl = dotenv.env['AI_API_BASEURL'] ?? '';
    final _apiKey = dotenv.env['AI_API_KEY'] ?? '';

    String _region = 'Philippines';

    try {

      if (_baseUrl == null || _baseUrl.isEmpty) {
        throw Exception('API base URL is not set in environment variables.');
      }

      if (_apiKey == null || _apiKey.isEmpty) {
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
            'content': '''You are a helpful cooking assistant. Generate detailed, easy-to-follow recipes using the provided ingredients. 

              IMPORTANT: Return your response as a valid JSON object with this exact structure:
              {
                "title": "Recipe Name",
                "description": "Brief description of the dish",
                "servings": "Number of servings",
                "prep_time": "Preparation time in minutes",
                "cook_time": "Cooking time in minutes",
                "total_time": "Total time in minutes",
                "difficulty": "Easy/Medium/Hard",
                "ingredients": [
                  "ingredient 1 with measurement",
                  "ingredient 2 with measurement"
                ],
                "instructions": [
                  "Step 1 instruction",
                  "Step 2 instruction"
                ],
                "tips": [
                  "Cooking tip 1",
                  "Cooking tip 2"
                ]
              }

              Make sure recipes are suitable for cooking in the $_region with locally available ingredients.'''
          },
          {
            'role': 'user',
            'content': 'Create a recipe using these ingredients: $ingredients'
          },
        ],
        'max_tokens': 1500,
        'temperature': 0.7,
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
        final recipe = data['choices'][0]['message']['content'];

        return recipe;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('API Error: ${errorData['error']['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error in generateRecipe: $e');
      throw Exception('Failed to generate recipe: $e');
    }
  }
}