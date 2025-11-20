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
      final recipe = await GroqAIService.generateRecipe(_ingredientsList);

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

  void _showUploadedImage() {
    if (_selectedImage == null) return;

    showDialog(
      context: context, 
      builder: (builder) => AlertDialog(
        content: Image.file(_selectedImage!),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          )
        ]
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
            SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            const SizedBox(height: 20),

            // Header Text
            const Text(
              'Enter ingredients or scan/upload an image from your fridge...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

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
                TextButton(
                  onPressed: _addIngredient,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Icon(Icons.add),
                ),
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
            const SizedBox(height: 100), // Add space for floating button
          ],
        ),
      ),
      
      // Image Preview Button (positioned absolutely)
      if (_selectedImage != null)
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            heroTag: "imagePreview",
            onPressed: _showUploadedImage,
            tooltip: 'View Uploaded Image',
            backgroundColor: Colors.orange.shade100,
            child: const Icon(Icons.image, color: Colors.orange),
          ),
        ),
      ],
    ),
    bottomNavigationBar: BottomAppBar(
        color: Colors.orange.shade100,
        shape: const CircularNotchedRectangle(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.orange, size: 40),
                  onPressed: _isAnalyzing ? null : _pickImageFromCamera,
                  tooltip: 'Take Photo',
                ),
              ),
              const SizedBox(width: 90),
              Expanded(
                child: IconButton(
                  icon: const Icon(Icons.photo_library, color: Colors.orange, size: 40,),
                  onPressed: _isAnalyzing ? null : _pickImageFromGallery,
                  tooltip: 'Upload from Gallery',
                ),
              ),
            ],
          ),
        )
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: _isLoading ? null : _generateRecipe,
        tooltip: 'Generate Recipe',
        backgroundColor: Colors.orange,
        child: _isLoading
            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),)
            : const Icon(Icons.restaurant_menu, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,

    );
  }
  
  @override
  void dispose() {
    _ingredientsController.dispose();
    super.dispose();
  }
}