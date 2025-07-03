import 'package:jfapp/models/guardar-catalogo-personal.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalProvider {
  static late SharedPreferences _preferences;

  /// Inicializa las preferencias compartidas
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static void setPersonal(
      String key, List<GuardarCatalogoPersonalModel> lista) {
    final listaString = lista.map((personal) => personal.toString()).toList();
    _preferences.setStringList(key, listaString);
  }

  static List<GuardarCatalogoPersonalModel> getPersonal(String key) {
    final listaString = _preferences.getStringList(key) ?? [];
    return listaString
        .map((item) => GuardarCatalogoPersonalModel.fromString(item))
        .toList();
  }

  static void addPersonal(
      String key, GuardarCatalogoPersonalModel nuevaPersona) {
    final lista = getPersonal(key);
    lista.add(nuevaPersona);
    setPersonal(key, lista);
  }

  static void removePersonal(String key, int index) {
    final lista = getPersonal(key);
    lista.removeAt(index);
    setPersonal(key, lista);
  }

  static void updatePersonal(
      String key, int index, GuardarCatalogoPersonalModel persona) {
    final lista = getPersonal(key);
    lista[index] = persona;
    setPersonal(key, lista);
  }

  static void clearPersonal() {
    _preferences.remove('personal');
  }
}
