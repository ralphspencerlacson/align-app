import 'package:align_app/services/recipe_service.dart';
import 'package:flutter/material.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final TextEditingController _ingredientsController = TextEditingController();

  // State variables
  bool _isLoading = false;
  String _recipe = '';
  String? _errorMessage;

  void _generateRecipe() async {
    if(_ingredientsController.text.trim().isEmpty) {
        setState(() {
            _errorMessage = 'Please enter at least one ingredient.';
        });
        return;
    }

    setState(() {
        _isLoading = true;
        _errorMessage = null;
        _recipe = '';
    });

    try {
      final recipe = await RecipeService.generateRecipe(_ingredientsController.text.trim());

      setState(() {
          _isLoading = false;
          _recipe = recipe;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              const Text(
                  'Enter ingredients.',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                  ),
              ),
              const SizedBox(height: 10),

              TextField(
                  controller: _ingredientsController,
                  decoration: const InputDecoration(
                      hintText: 'e.g., chicken, rice, onions',
                      border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
              ),
              const SizedBox(height: 20),
      
              ElevatedButton(
                onPressed: _isLoading ? null : _generateRecipe,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Generate recipe')
              ),
              SizedBox(height: 20),

              if(_errorMessage != null) ... [
                Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                    )
                ),
              ],

              if(!_isLoading && _recipe.isNotEmpty) ... [
                Expanded(
                    child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                        ),
                        child: SingleChildScrollView(
                            child: Text(
                                _recipe,
                                style: const TextStyle(fontSize: 16),
                            )
                        )
                    )
                )
              ]
          ],
      ),
    );
  }

  @override
  void dispose() {
    _ingredientsController.dispose();
    super.dispose();
  }
}