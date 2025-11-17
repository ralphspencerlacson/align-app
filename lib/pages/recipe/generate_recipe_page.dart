import 'package:align_app/pages/recipe/display_recipe_page.dart';
import 'package:align_app/services/recipe_service.dart';
import 'package:flutter/material.dart';

class GenerateRecipePage extends StatefulWidget {
  const GenerateRecipePage({super.key});

  @override
  State<GenerateRecipePage> createState() => _GenerateRecipePageState();
}

class _GenerateRecipePageState extends State<GenerateRecipePage> {
  final TextEditingController _ingredientsController = TextEditingController();


  // State variables
  bool _isLoading = false;
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
    });

    try {
      final recipe = await RecipeService.generateRecipe(_ingredientsController.text.trim());

      setState(() {
          _isLoading = false;
      });

      // Navigate to DisplayRecipePage
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisplayRecipePage(recipe: recipe),
          )
        );
      }
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

              // if(!_isLoading && _recipe != null) ... [
              //   Expanded(
              //       child: Container(
              //           padding: const EdgeInsets.all(16),
              //           decoration: BoxDecoration(
              //               color: Colors.green.shade50,
              //               borderRadius: BorderRadius.circular(8),
              //               border: Border.all(color: Colors.green.shade200),
              //           ),
              //           child: SingleChildScrollView(
              //               child: Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   // Image
              //                   if (_recipe!.image.isNotEmpty) ...[
              //                     ClipRRect(
              //                       borderRadius: BorderRadius.circular(8),
              //                       child: Image.network(
              //                         _recipe!.image,
              //                         height: 200,
              //                         width: double.infinity,
              //                         fit: BoxFit.cover,
              //                         errorBuilder: (context, error, stackTrace) {
              //                           return Container(
              //                             height: 200,
              //                             color: Colors.grey.shade300,
              //                             child: const Center(
              //                               child: Text('Image not available'),
              //                             ),
              //                           );
              //                         },
              //                       ),
              //                     ),
              //                     const SizedBox(height: 16),
              //                   ],
              //                   // Title
              //                   Text(
              //                     _recipe!.title,
              //                     style: const TextStyle(
              //                         fontSize: 24,
              //                         fontWeight: FontWeight.bold,
              //                     ),
              //                   ),
              //                   const SizedBox(height: 10),

              //                   // Description
              //                   Text(
              //                     _recipe!.description,
              //                     style: const TextStyle(
              //                       fontSize: 16,
              //                       fontStyle: FontStyle.italic,
              //                     ),
              //                   ),
              //                   const SizedBox(height: 16),

              //                   // Info Row
              //                   Row(
              //                     children: [
              //                       Text('Servings: ${_recipe!.servings}'),
              //                       const SizedBox(width: 16),
              //                       Text('Total Time: ${_recipe!.totalTime}'),
              //                       const SizedBox(width: 16),
              //                       Text('Difficulty: ${_recipe!.difficulty}'),
              //                     ],
              //                   ),
              //                   const SizedBox(height: 16),

              //                   // Ingredients Section
              //                   const Text(
              //                     'Ingredients:',
              //                     style: TextStyle(
              //                       fontSize: 18,
              //                       fontWeight: FontWeight.bold,
              //                     ),
              //                   ),
              //                   const SizedBox(height: 8),
              //                   ...(_recipe!.ingredients.map((ingredient) => 
              //                     Padding(
              //                       padding: const EdgeInsets.only(bottom: 4),
              //                       child: Text('• $ingredient'),
              //                     )
              //                   )),
              //                   const SizedBox(height: 16),

              //                   // Instructions Section
              //                   const Text(
              //                     'Instructions:',
              //                     style: TextStyle(
              //                       fontSize: 18,
              //                       fontWeight: FontWeight.bold,
              //                     ),
              //                   ),
              //                   const SizedBox(height: 8),
              //                   ...(_recipe!.instructions.asMap().entries.map((entry) => 
              //                     Padding(
              //                       padding: const EdgeInsets.only(bottom: 8),
              //                       child: Text('${entry.key + 1}. ${entry.value}'),
              //                     )
              //                   )),
              //                   const SizedBox(height: 16),

              //                   // Tips Section
              //                   if (_recipe!.tips.isNotEmpty) ...[
              //                     const Text(
              //                       'Tips:',
              //                       style: TextStyle(
              //                         fontSize: 18,
              //                         fontWeight: FontWeight.bold,
              //                       ),
              //                     ),
              //                     const SizedBox(height: 8),
              //                     ...(_recipe!.tips.map((tip) => 
              //                       Padding(
              //                         padding: const EdgeInsets.only(bottom: 4),
              //                         child: Text('💡 $tip'),
              //                       )
              //                     )),
              //                   ],
              //                 ],
              //               )
              //           )
              //       )
              //   )
              // ]
          
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