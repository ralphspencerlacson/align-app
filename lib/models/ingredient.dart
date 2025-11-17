class Ingredient {
  final String icon;
  final String label;
  final String quantity;

  Ingredient({
    required this.icon,
    required this.label,
    required this.quantity,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      icon: json['icon'],
      label: json['label'],
      quantity: json['quantity'],
    );
  }
}