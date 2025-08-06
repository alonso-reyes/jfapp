import 'dart:convert';

import 'package:jfapp/models/user.model.dart';
import 'package:jfapp/providers/preference_provider.dart';

import 'dart:developer' as dev;

/*class SessionManager {
  static UserModel? _user;

  static UserModel? get user => _user;

  static Future<void> loadUser() async {
    _user = PreferenceProvider.getUserModel;
    dev.log('Usuario cargado completo: ${_user?.toJson()}');
  }

  static Future<void> saveUser(UserModel userModel) async {
    _user = userModel;
    await PreferenceProvider.saveUserModel(userModel);
  }

  static Future<void> clearUser() async {
    _user = null;
    await PreferenceProvider.clearPreferences();
  }
}*/

class SessionManager {
  static UserModel? _user;

  static UserModel? get user => _user;

  static Future<void> loadUser() async {
    String userJson = PreferenceProvider.user;
    if (userJson.isNotEmpty) {
      try {
        _user = UserModel.fromJson(jsonDecode(userJson));
        dev.log("Usuario cargado: ${_user?.toJson()}");
      } catch (e) {
        dev.log("Error cargando usuario: $e");
        _user = null;
      }
    } else {
      dev.log("No hay usuario guardado");
    }
  }

  static Future<void> saveUser(UserModel userModel) async {
    _user = userModel;
    final userJson = jsonEncode(userModel);
    dev.log("Guardando usuario: $userJson");
    PreferenceProvider.user = userJson;
  }

  static Future<void> clearUser() async {
    _user = null;
    PreferenceProvider.user = '';
  }
}
