import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../models/recipe.dart';

class FirebaseService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _recipesCollection = 
      FirebaseFirestore.instance.collection('recipes');
  final Uuid _uuid = const Uuid();

  Stream<List<Recipe>> getRecipesStream() {
    return _recipesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Recipe.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<String> addRecipe(Recipe recipe) async {
    try {
      String id = _uuid.v4();
      Recipe newRecipe = recipe.copyWith(id: id);
      await _recipesCollection.doc(id).set(newRecipe.toMap());
      return id;
    } catch (e) {
      throw Exception('Failed to add recipe: $e');
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      await _recipesCollection.doc(recipe.id).update(recipe.toMap());
    } catch (e) {
      throw Exception('Failed to update recipe: $e');
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      await _recipesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete recipe: $e');
    }
  }

  Future<String> uploadImage(File imageFile, String recipeId) async {
    try {
      final Reference storageRef = _storage.ref().child('recipe_images/$recipeId.jpg');
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}