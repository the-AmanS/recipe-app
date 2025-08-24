import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/recipe.dart';
import '../services/firebase_service.dart';

class RecipeProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _error;

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  RecipeProvider() {
    _initRecipes();
  }

  void _initRecipes() {
    _firebaseService.getRecipesStream().listen(
      (updatedRecipes) {
        _recipes = updatedRecipes;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to load recipes: $error';
        notifyListeners();
      },
    );
  }

  Future<void> addRecipe({
    required String title,
    required List<String> ingredients,
    required String instructions,
    File? imageFile,
    String imageUrl = '',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String finalImageUrl = imageUrl;
      String tempId = DateTime.now().millisecondsSinceEpoch.toString();
      
      if (imageFile != null) {
        finalImageUrl = await _firebaseService.uploadImage(imageFile, tempId);
      }

      final recipe = Recipe(
        id: '', // Will be set by the service
        title: title,
        ingredients: ingredients,
        instructions: instructions,
        imageUrl: finalImageUrl,
      );

      await _firebaseService.addRecipe(recipe);
    } catch (e) {
      _error = 'Failed to add recipe: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRecipe({
    required String id,
    required String title,
    required List<String> ingredients,
    required String instructions,
    File? imageFile,
    required String currentImageUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String finalImageUrl = currentImageUrl;
      
      if (imageFile != null) {
        finalImageUrl = await _firebaseService.uploadImage(imageFile, id);
      }

      final recipe = Recipe(
        id: id,
        title: title,
        ingredients: ingredients,
        instructions: instructions,
        imageUrl: finalImageUrl,
      );

      await _firebaseService.updateRecipe(recipe);
    } catch (e) {
      _error = 'Failed to update recipe: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteRecipe(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.deleteRecipe(id);
    } catch (e) {
      _error = 'Failed to delete recipe: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Recipe? getRecipeById(String id) {
    try {
      return _recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }
}