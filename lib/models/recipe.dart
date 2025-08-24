class Recipe {
  final String id;
  final String title;
  final List<String> ingredients;
  final String instructions;
  final String imageUrl;

  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'ingredients': ingredients,
      'instructions': instructions,
      'imageUrl': imageUrl,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: map['instructions'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Recipe copyWith({
    String? id,
    String? title,
    List<String>? ingredients,
    String? instructions,
    String? imageUrl,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}