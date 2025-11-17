import 'package:align_app/models/recipe.dart';
import 'package:align_app/widgets/info_card.dart';
import 'package:align_app/widgets/timeline.dart';
import 'package:flutter/material.dart';

class DisplayRecipePage extends StatelessWidget {
  final Recipe recipe;

  const DisplayRecipePage({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image and overlapping header section
                SizedBox(
                  height: 260, // Image height minus overlap amount
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Image
                      if (recipe.image.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          child: Image.network(
                            recipe.image,
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 300,
                                color: Colors.orange,
                              );
                            },
                          ),
                        ),
                      ],

                      // Recipe Header - overlapping the image
                      Positioned(
                        top: 180,
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Title
                              Text(
                                recipe.title,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Description
                              Text(
                                recipe.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Recipe Info Cards
                              Row(
                                children: [
                                  Expanded(
                                    child: InfoCard(label: 'Servings', value: recipe.servings),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: InfoCard(label: 'Prep Time', value: recipe.prepTime),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: InfoCard(label: 'Cook Time', value: recipe.cookTime),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Add spacing for the overlapping content
                const SizedBox(height: 340),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ingredients Section
                      const Text(
                        'Ingredients',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Horizontal scrolling ingredients
                      SizedBox(
                        height: 120, // Fixed height for the horizontal scroll
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: recipe.ingredients.length,
                          itemBuilder: (context, index) {
                            final ingredient = recipe.ingredients[index];
                            
                            // Different background colors for variety
                            final colors = [
                              Colors.red.shade50,
                              Colors.yellow.shade50,
                              Colors.green.shade50,
                              Colors.purple.shade50,
                              Colors.blue.shade50,
                              Colors.orange.shade50,
                            ];
                            
                            return Container(
                              width: 100, // Fixed width for each ingredient card
                              margin: EdgeInsets.only(
                                left: index == 0 ? 0 : 8,
                                right: index == recipe.ingredients.length - 1 ? 0 : 0,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Large emoji/icon
                                  Container(
                                    width: 40,
                                    height: 40,
                                    child: Center(
                                      child: Text(
                                        ingredient.icon,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  
                                  // Ingredient label
                                  Text(
                                    ingredient.label,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  
                                  // Ingredient quantity
                                  Text(
                                    ingredient.quantity,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Instructions Section
                      const Text(
                        'Instructions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Timeline Instructions
                      Timeline(
                        items: recipe.instructions,
                        accentColor: Colors.orange,
                        circleSize: 36,
                        fontSize: 16,
                      ),

                      // Tips Section
                      if (recipe.tips.isNotEmpty) ...[
                        const Text(
                          'Tips',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: recipe.tips.map((tip) => 
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('💡 ', style: TextStyle(fontSize: 16)),
                                    Expanded(child: Text(tip, style: const TextStyle(fontSize: 16))),
                                  ],
                                ),
                              )
                            ).toList(),
                          ),
                        ),
                      ],

                    ]
                  )
                ),
                
                const SizedBox(height: 100),
              ],
            )
          ),

          // Back Button (Top Left)
          Positioned(
            top: 50,
            left: 16,
            child: FloatingActionButton(
              heroTag: "back_button",
              mini: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back),
            ),
          ),
          
          // Generate More Button (Bottom Right)
          Positioned(
            bottom: 30,
            right: 16,
            child: FloatingActionButton.extended(
              heroTag: "generate_more_button",
              onPressed: () {
                // TODO: Navigate to generate more recipes
                print('Generate more recipes');
              },
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.refresh),
              label: const Text('Generate More'),
            ),
          ),
        ],
      )
    );
  }
}