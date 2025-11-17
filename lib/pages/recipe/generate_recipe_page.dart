import 'dart:io';

import 'package:align_app/pages/recipe/display_recipe_page.dart';
import 'package:align_app/services/groq_ai_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class GenerateRecipePage extends StatefulWidget {
  const GenerateRecipePage({super.key});

  @override
  State<GenerateRecipePage> createState() => _GenerateRecipePageState();
}

class _GenerateRecipePageState extends State<GenerateRecipePage> {
  // Controller
  final TextEditingController _ingredientsController = TextEditingController();

  // State variables
  bool _isLoading = false;
  bool _isAnalyzing = false;
  String? _errorMessage;
  File? _selectedImage;
  List<String> _analyzedIngredients = [];

  // Objects
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromCamera() async {
    try {
      var status = await Permission.camera.status;

      if (status.isDenied) {
        status = await Permission.camera.request();
      }

      if (status.isGranted) {
        setState(() {
          _errorMessage = 'Camera permission is required to take photos.';
        });
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _errorMessage = null;
        });

        await _analyzeImageWithGroq();
      }
    } catch (e) {
    setState(() {
      _errorMessage = 'Error taking photo: $e';
    });
  }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _errorMessage = null;
        });

        await _analyzeImageWithGroq();
      }
    }  catch (e) {
    setState(() {
      _errorMessage = 'Error taking photo: $e';
    });
  }
  }

  Future<void> _analyzeImageWithGroq() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final ingredients = await GroqAIService.analyzeIngredients(_selectedImage!);

      setState(() {
        _analyzedIngredients = ingredients;
        _isAnalyzing = false;

        String currentIngredients = _ingredientsController.text.trim();
        String newIngredients = ingredients.join(', ');
        
        if(currentIngredients.isEmpty) {
          _ingredientsController.text = newIngredients;
        } else {
          _ingredientsController.text = '$currentIngredients, $newIngredients';
        }
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'Error analyzing image: $e';
      });
    }
  }

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
      final recipe = await GroqAIService.generateRecipe(_ingredientsController.text.trim());

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
                  'Enter ingredients or scan/upload an ingredients from your fridge...',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                  ),
              ),
              const SizedBox(height: 10),

              if (_selectedImage != null) ... [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                ),
                const SizedBox(height: 10,),
              ],

              // Camera and Gallery Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _pickImageFromCamera,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera')
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _pickImageFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),

              // Ingredients TextField
              TextField(
                  controller: _ingredientsController,
                  decoration: const InputDecoration(
                      hintText: 'e.g., chicken, rice, onions',
                      border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _generateRecipe,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Generate recipe')
              ),
              SizedBox(height: 20),

              // Error message display
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