import 'dart:convert';

import 'package:jfapp/models/acarreos-agua.model.dart';
import 'package:jfapp/models/acarreos-area.model.dart';
import 'package:jfapp/models/acarreos-metro.model.dart';
import 'package:jfapp/models/acarreos-volumen.model.dart';
import 'package:jfapp/models/campos-generales-seleccionado.model.dart';
import 'package:jfapp/models/turno-seleccionado.model.dart';
import 'package:jfapp/models/user.model.dart';
import 'package:jfapp/models/zona-trabajo-seleccionada.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:developer' as dev;

class PreferenceProvider {
  static late SharedPreferences _preferences;

  /// Inicializa las preferencias compartidas
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future<void> saveUserModel(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _preferences.setString('current_user', userJson);
    dev.log('Usuario guardado completo: $userJson');
  }

  static UserModel? get getUserModel {
    final userJson = _preferences.getString('current_user');
    if (userJson != null && userJson.isNotEmpty) {
      try {
        return UserModel.fromJson(jsonDecode(userJson));
      } catch (e) {
        dev.log('Error al decodificar usuario: $e');
        return null;
      }
    }
    return null;
  }

  /// Guarda el token de autenticación
  static set token(String token) {
    _preferences.setString('token', token);
  }

  /// Recupera el token de autenticación
  static String get token {
    return _preferences.getString('token') ?? '';
  }

  /// Guarda el usuario como un string (en formato JSON, por ejemplo)
  static set user(String user) {
    _preferences.setString('user', user);
  }

  /// Recupera el usuario como string (puedes convertirlo de JSON si es necesario)
  static String get user {
    return _preferences.getString('user') ?? '';
  }

  static Future<void> clearPreferences() async {
    await _preferences.clear();
  }

  ////Campos Extras generales
  ///
  /// Guarda el campo seleccionado en SharedPreferences
  static void setCampoSeleccionado(CampoGeneralesSeleccionado campo) {
    _preferences.setString('campoSeleccionado', campo.toJson());
  }

  /// Recupera el campo seleccionado
  static CampoGeneralesSeleccionado? getCampoSeleccionado() {
    final turnoStr = _preferences.getString('campoSeleccionado');
    if (turnoStr == null) return null;
    return CampoGeneralesSeleccionado.fromJson(turnoStr);
  }

  /// Elimina el campo seleccionado
  static void clearCampoSeleccionado() {
    _preferences.remove('campoSeleccionado');
  }

  ////Turnos
  ///
  /// Guarda el turno seleccionado en SharedPreferences
  static void setTurnoSeleccionado(TurnoSeleccionado turno) {
    _preferences.setString('turnoSeleccionado', turno.toJson());
  }

  /// Recupera el turno seleccionado
  static TurnoSeleccionado? getTurnoSeleccionado() {
    final turnoStr = _preferences.getString('turnoSeleccionado');
    if (turnoStr == null) return null;
    return TurnoSeleccionado.fromJson(turnoStr);
  }

  /// Elimina el turno seleccionado
  static void clearTurnoSeleccionado() {
    _preferences.remove('turnoSeleccionado');
  }

  ////Zona de trabajo
  ///
  /// Guarda el turno seleccionado en SharedPreferences
  static void setZonaTrabajoSeleccionada(ZonaTrabajoSeleccionada zona) {
    _preferences.setString('zonaSeleccionada', zona.toJson());
  }

  /// Recupera el turno seleccionado
  static ZonaTrabajoSeleccionada? getZonaTrabajoSeleccionada() {
    final zonaStr = _preferences.getString('zonaSeleccionada');
    return zonaStr != null ? ZonaTrabajoSeleccionada.fromJson(zonaStr) : null;
  }

  /// Elimina el turno seleccionado
  static void clearZonaTrabajoSeleccionada() {
    _preferences.remove('zonaSeleccionada');
  }

  //////////////////////////////////// Acarreos
  /// Volumen

  static void setAcarreos(String key, List<AcarreoVolumen> lista) {
    final listaString = lista.map((acarreo) => acarreo.toString()).toList();
    _preferences.setStringList(key, listaString);
  }

  static List<AcarreoVolumen> getAcarreos(String key) {
    final listaString = _preferences.getStringList(key) ?? [];
    return listaString.map((item) => AcarreoVolumen.fromString(item)).toList();
  }

  static void addAcarreo(String key, AcarreoVolumen nuevoAcarreo) {
    final lista = getAcarreos(key);
    lista.add(nuevoAcarreo);
    setAcarreos(key, lista);
  }

  static void removeAcarreo(String key, int index) {
    final lista = getAcarreos(key);
    lista.removeAt(index);
    setAcarreos(key, lista);
  }

  static void updateAcarreo(String key, int index, AcarreoVolumen acarreo) {
    final lista = getAcarreos(key);
    lista[index] = acarreo;
    setAcarreos(key, lista);
  }

  static void clearAcarreosVolumen() {
    _preferences.remove('acarreos_volumen');
  }

  //// Area
  static void setAcarreosArea(String key, List<AcarreoArea> lista) {
    final listaString = lista.map((acarreo) => acarreo.toString()).toList();
    _preferences.setStringList(key, listaString);
  }

  static List<AcarreoArea> getAcarreosArea(String key) {
    final listaString = _preferences.getStringList(key) ?? [];
    return listaString.map((item) => AcarreoArea.fromString(item)).toList();
  }

  static void addAcarreoArea(String key, AcarreoArea nuevoAcarreo) {
    final lista = getAcarreosArea(key);
    lista.add(nuevoAcarreo);
    setAcarreosArea(key, lista);
  }

  static void removeAcarreoArea(String key, int index) {
    final lista = getAcarreosArea(key);
    lista.removeAt(index);
    setAcarreosArea(key, lista);
  }

  static void updateAcarreoArea(String key, int index, AcarreoArea acarreo) {
    final lista = getAcarreosArea(key);
    lista[index] = acarreo;
    setAcarreosArea(key, lista);
  }

  static void clearAcarreosArea() {
    _preferences.remove('acarreos_area');
  }

  //// Metro
  static void setAcarreosMetro(String key, List<AcarreoMetro> lista) {
    final listaString = lista.map((acarreo) => acarreo.toString()).toList();
    _preferences.setStringList(key, listaString);
  }

  static List<AcarreoMetro> getAcarreosMetro(String key) {
    final listaString = _preferences.getStringList(key) ?? [];
    return listaString.map((item) => AcarreoMetro.fromString(item)).toList();
  }

  static void addAcarreoMetro(String key, AcarreoMetro nuevoAcarreo) {
    final lista = getAcarreosMetro(key);
    lista.add(nuevoAcarreo);
    setAcarreosMetro(key, lista);
  }

  static void removeAcarreoMetro(String key, int index) {
    final lista = getAcarreosMetro(key);
    lista.removeAt(index);
    setAcarreosMetro(key, lista);
  }

  static void updateAcarreoMetro(String key, int index, AcarreoMetro acarreo) {
    final lista = getAcarreosMetro(key);
    lista[index] = acarreo;
    setAcarreosMetro(key, lista);
  }

  static void clearAcarreosMetro() {
    _preferences.remove('acarreos_metro');
  }

  //// Agua
  static void setAcarreosAgua(String key, List<AcarreoAgua> lista) {
    final listaString = lista.map((acarreo) => acarreo.toString()).toList();
    _preferences.setStringList(key, listaString);
  }

  static List<AcarreoAgua> getAcarreosAgua(String key) {
    final listaString = _preferences.getStringList(key) ?? [];
    return listaString.map((item) => AcarreoAgua.fromString(item)).toList();
  }

  static void addAcarreoAgua(String key, AcarreoAgua nuevoAcarreo) {
    final lista = getAcarreosAgua(key);
    lista.add(nuevoAcarreo);
    setAcarreosAgua(key, lista);
  }

  static void removeAcarreoAgua(String key, int index) {
    final lista = getAcarreosAgua(key);
    lista.removeAt(index);
    setAcarreosAgua(key, lista);
  }

  static void updateAcarreoAgua(String key, int index, AcarreoAgua acarreo) {
    final lista = getAcarreosAgua(key);
    lista[index] = acarreo;
    setAcarreosAgua(key, lista);
  }

  static void clearAcarreosAgua() {
    _preferences.remove('acarreos_agua');
  }

  //////////////////////////////////// Maquinaria
}

// import 'package:shared_preferences/shared_preferences.dart';

// class PreferenceProvider {
//   static late SharedPreferences _preferences;

//   static String _user = '';

//   static Future init() async {
//     _preferences = await SharedPreferences.getInstance();
//   }

//   static set user(String user) {
//     _user = user;
//     _preferences.setString('user', user);
//   }

//   static String get user {
//     return _preferences.getString('user') ?? _user;
//   }
// }
