import 'package:jfapp/models/guardar-catalogo-maquinaria.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MaquinariaProvider {
  static late SharedPreferences _preferences;

  /// Inicializa las preferencias compartidas
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static void setMaquinaria(
      String key, List<GuardarCatalogoMaquinariaModel> lista) {
    final listaString = lista.map((maquina) => maquina.toString()).toList();
    _preferences.setStringList(key, listaString);
  }

  static List<GuardarCatalogoMaquinariaModel> getMaquinaria(String key) {
    final listaString = _preferences.getStringList(key) ?? [];
    return listaString
        .map((item) => GuardarCatalogoMaquinariaModel.fromString(item))
        .toList();
  }

  static void addMaquinaria(
      String key, GuardarCatalogoMaquinariaModel nuevaMaquina) {
    final lista = getMaquinaria(key);
    lista.add(nuevaMaquina);
    setMaquinaria(key, lista);
  }

  static void removeMaquina(String key, int index) {
    final lista = getMaquinaria(key);
    lista.removeAt(index);
    setMaquinaria(key, lista);
  }

  static void updateMaquinaria(
      String key, int index, GuardarCatalogoMaquinariaModel maquina) {
    final lista = getMaquinaria(key);
    lista[index] = maquina;
    setMaquinaria(key, lista);
  }

  static void clearMaquinaria() {
    _preferences.remove('maquinaria');
  }
}
