import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../providers/recipe_provider.dart';

class RecipeFormScreen extends StatefulWidget {
  final Recipe? recipe;

  const RecipeFormScreen({super.key, this.recipe});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    // If editing an existing recipe, populate the form
    if (widget.recipe != null) {
      _titleController.text = widget.recipe!.title;
      _ingredientsController.text = widget.recipe!.ingredients.join('\n');
      _instructionsController.text = widget.recipe!.instructions;
      _imageUrl = widget.recipe!.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _imageUrl = null; // Clear the image URL if a new image is selected
      });
    }
  }

  List<String> _parseIngredients(String ingredientsText) {
    return ingredientsText
        .split('\n')
        .map((ingredient) => ingredient.trim())
        .where((ingredient) => ingredient.isNotEmpty)
        .toList();
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
      final title = _titleController.text.trim();
      final ingredients = _parseIngredients(_ingredientsController.text);
      final instructions = _instructionsController.text.trim();

      try {
        if (widget.recipe == null) {
          // Add new recipe
          await recipeProvider.addRecipe(
            title: title,
            ingredients: ingredients,
            instructions: instructions,
            imageFile: _imageFile,
            imageUrl: _imageUrl ?? '',
          );
        } else {
          // Update existing recipe
          await recipeProvider.updateRecipe(
            id: widget.recipe!.id,
            title: title,
            ingredients: ingredients,
            instructions: instructions,
            imageFile: _imageFile,
            currentImageUrl: _imageUrl ?? '',
          );
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recipe != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Recipe' : 'Add Recipe',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Picker
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : _imageUrl != null && _imageUrl!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      _imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text('Tap to add an image'),
                                      ],
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title Field
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Recipe Title',
                        hintText: 'e.g., Spaghetti Carbonara',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Ingredients Field
                    TextFormField(
                      controller: _ingredientsController,
                      decoration: const InputDecoration(
                        labelText: 'Ingredients',
                        hintText: 'Enter each ingredient on a new line',
                        prefixIcon: Icon(Icons.list),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter at least one ingredient';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Instructions Field
                    TextFormField(
                      controller: _instructionsController,
                      decoration: const InputDecoration(
                        labelText: 'Instructions',
                        hintText: 'Enter the cooking instructions',
                        prefixIcon: Icon(Icons.menu_book),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 8,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter instructions';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    ElevatedButton.icon(
                      onPressed: _saveRecipe,
                      icon: const Icon(Icons.save),
                      label: Text(isEditing ? 'Update Recipe' : 'Save Recipe'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}