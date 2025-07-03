import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PhotoProvider with ChangeNotifier {
  static late SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Métodos para imágenes sin descripción (compatibilidad)
  static List<String> getImages(String key) {
    return _preferences.getStringList(key) ?? [];
  }

  static void addImage(String key, String image) {
    final images = getImages(key);
    images.add(image);
    _preferences.setStringList(key, images);
  }

  // Métodos para imágenes con descripción
  static List<Map<String, String>> getImagesWithDescriptions(String key) {
    final imagesJson = _preferences.getStringList(key) ?? [];
    return imagesJson.map((json) {
      try {
        final Map<String, dynamic> data = jsonDecode(json);
        return {
          'image': data['image']?.toString() ?? '',
          'description': data['description']?.toString() ?? 'Sin descripción',
        };
      } catch (e) {
        return {
          'image': json,
          'description': 'Imagen sin descripción',
        };
      }
    }).toList();
  }

  static void addImageWithDescription(
      String key, String image, String description) {
    final images = _preferences.getStringList(key) ?? [];
    images.add(jsonEncode({
      'image': image,
      'description': description,
    }));
    _preferences.setStringList(key, images);
  }

  static void removeImage(String key, int index) {
    final images = _preferences.getStringList(key) ?? [];
    if (index >= 0 && index < images.length) {
      images.removeAt(index);
      _preferences.setStringList(key, images);
    }
  }

  static void clearImages(String key) {
    _preferences.remove(key);
  }
}
