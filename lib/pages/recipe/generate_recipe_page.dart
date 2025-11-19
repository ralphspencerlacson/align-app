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
  List<String> _ingredientsList = [];

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
        _isAnalyzing = false;

        for (String ingredient in ingredients) {
          if (!_ingredientsList.contains(ingredient.trim().toLowerCase())) {
            _ingredientsList.add(ingredient.trim());
          }
        }
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'Error analyzing image: $e';
      });
    }
  }

  void _addIngredient() {
    final ingredient = _ingredientsController.text.trim();
    if(ingredient.isNotEmpty && !_ingredientsList.contains(ingredient)) {
      setState(() {
        _ingredientsList.add(ingredient);
        _ingredientsController.clear();
        _errorMessage = null;
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredientsList.removeAt(index);
    });
  }

  void _generateRecipe() async {
    if(_ingredientsList.isEmpty) {
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
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            const Text(
              'Enter ingredients or scan/upload an image from your fridge...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            if (_selectedImage != null) ...[
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
              const SizedBox(height: 10),
            ],

            // Ingredient TextField
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ingredientsController,
                    decoration: const InputDecoration(
                      hintText: 'Add ingredient (e.g., chicken)',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addIngredient(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addIngredient,
                  child: const Icon(Icons.add),
                )
              ],
            ),
            const SizedBox(height: 20),

            // Ingredient Display
            if (_ingredientsList.isNotEmpty) ...[
              const Text(
                'Ingredients:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _ingredientsList.asMap().entries.map((entry) {
                  return Chip(
                    label: Text(entry.value),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeIngredient(entry.key),
                    backgroundColor: Colors.orange.shade100,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Error message display
            if(_errorMessage != null) ...[
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
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.orange.shade100,
        shape: const CircularNotchedRectangle(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.orange,),
                  onPressed: _isAnalyzing ? null : _pickImageFromCamera,
                  tooltip: 'Take Photo',
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: const Icon(Icons.photo_library, color: Colors.orange,),
                  onPressed: _isAnalyzing ? null : _pickImageFromGallery,
                  tooltip: 'Upload from Gallery',
                ),
              ),
            ],
          ),
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _generateRecipe,
        tooltip: 'Generate Recipe',
        backgroundColor: Colors.orange,
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : const Icon(Icons.restaurant_menu, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

    );
  }
  
  @override
  void dispose() {
    _ingredientsController.dispose();
    super.dispose();
  }
}