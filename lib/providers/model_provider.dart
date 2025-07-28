import 'dart:convert';

import 'package:jfapp/models/catalogo-generales.model.dart';
import 'package:jfapp/models/catalogo-maquinaria.model.dart';
import 'package:jfapp/models/catalogo-motivos-inactividad-maquinaria.model.dart';
import 'package:jfapp/models/catalogo-personal.model.dart';
import 'package:jfapp/models/concepto.model.dart';
import 'package:jfapp/models/obra.model.dart';
import 'package:jfapp/models/reporte-diario-wa.model.dart';
import 'package:jfapp/models/turno.model.dart';
import 'package:jfapp/models/zonas-trabajo.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModelProvider {
  static late SharedPreferences _preferences;

  /// Inicializa las preferencias compartidas
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ///
  ///
  /// Guardar el catálogo de turnos en SharedPreferences
  static Future<void> guardarCatalogoObras(ObraModel obra) async {
    final catalogoJson = jsonEncode(obra.toJson()); // Convertir a JSON
    await _preferences.setString('catalogoObra', catalogoJson);
  }

  /// Cargar el catálogo de turnos desde SharedPreferences
  static Future<ObraModel?> cargarCatalogoObras() async {
    final catalogoJson = _preferences.getString('catalogoObra');

    if (catalogoJson != null) {
      final catalogoMap = jsonDecode(catalogoJson); // Convertir a Map
      return ObraModel.fromJson(catalogoMap); // Convertir a objeto
    } else {
      return null; // Si no hay datos guardados, retorna null
    }
  }

  /// Limpiar el catálogo de turnos (opcional)
  static Future<void> limpiarCatalogoObras() async {
    await _preferences.remove('catalogoObra');
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ///
  ///
  /// Guardar el catálogo de turnos en SharedPreferences
  static Future<void> guardarCatalogoTurnos(TurnoModel turno) async {
    final catalogoJson = jsonEncode(turno.toJson()); // Convertir a JSON
    await _preferences.setString('catalogoTurno', catalogoJson);
  }

  /// Cargar el catálogo de turnos desde SharedPreferences
  static Future<TurnoModel?> cargarCatalogoTurno() async {
    final catalogoJson = _preferences.getString('catalogoTurno');

    if (catalogoJson != null) {
      final catalogoMap = jsonDecode(catalogoJson); // Convertir a Map
      return TurnoModel.fromJson(catalogoMap); // Convertir a objeto
    } else {
      return null; // Si no hay datos guardados, retorna null
    }
  }

  /// Limpiar el catálogo de turnos (opcional)
  static Future<void> limpiarCatalogoTurno() async {
    await _preferences.remove('catalogoTurno');
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ///
  ///
  /// Guardar el catálogo de zonas de trabahjo en SharedPreferences
  static Future<void> guardarCatalogoZonaTrabajo(ZonasTrabajoModel zona) async {
    final catalogoJson = jsonEncode(zona.toJson()); // Convertir a JSON
    await _preferences.setString('catalogoZonaTrabajo', catalogoJson);
  }

  /// Cargar el catálogo de zonas de trabahjo desde SharedPreferences
  static Future<ZonasTrabajoModel?> cargarCatalogoZonaTrabajo() async {
    final catalogoJson = _preferences.getString('catalogoZonaTrabajo');

    if (catalogoJson != null) {
      final catalogoMap = jsonDecode(catalogoJson); // Convertir a Map
      return ZonasTrabajoModel.fromJson(catalogoMap); // Convertir a objeto
    } else {
      return null; // Si no hay datos guardados, retorna null
    }
  }

  /// Limpiar el catálogo de zonas de trabahjo (opcional)
  static Future<void> limpiarCatalogoZonaTrabajo() async {
    await _preferences.remove('catalogoZonaTrabajo');
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ///
  ///
  /// /// Guardar el catálogo de conceptos en SharedPreferences
  static Future<void> guardarCatalogoConceptos(ConceptoModel concepto) async {
    final catalogoJson = jsonEncode(concepto.toJson()); // Convertir a JSON
    await _preferences.setString('catalogoConcepto', catalogoJson);
  }

  /// Cargar el catálogo de maquinaria desde SharedPreferences
  static Future<ConceptoModel?> cargarCatalogoConcepto() async {
    final catalogoJson = _preferences.getString('catalogoConcepto');

    if (catalogoJson != null) {
      final catalogoMap = jsonDecode(catalogoJson); // Convertir a Map
      return ConceptoModel.fromJson(catalogoMap); // Convertir a objeto
    } else {
      return null; // Si no hay datos guardados, retorna null
    }
  }

  /// Limpiar el catálogo de maquinaria (opcional)
  static Future<void> limpiarCatalogoConcepto() async {
    await _preferences.remove('catalogoConcepto');
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ///
  /// Guardar el catálogo de generales en SharedPreferences
  static Future<void> guardarCatalogoGenerales(
      CatalogoGeneralesModel catalogo) async {
    final catalogoJson = jsonEncode(catalogo.toJson()); // Convertir a JSON
    await _preferences.setString('catalogoGenerales', catalogoJson);
  }

  /// Cargar el catálogo de maquinaria desde SharedPreferences
  static Future<CatalogoGeneralesModel?> cargarCatalogoGenerales() async {
    final catalogoJson = _preferences.getString('catalogoGenerales');

    if (catalogoJson != null) {
      final catalogoMap = jsonDecode(catalogoJson); // Convertir a Map
      return CatalogoGeneralesModel.fromJson(catalogoMap); // Convertir a objeto
    } else {
      return null; // Si no hay datos guardados, retorna null
    }
  }

  /// Limpiar el catálogo de maquinaria (opcional)
  static Future<void> limpiarCatalogoGenerales() async {
    await _preferences.remove('catalogoGenerales');
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ///
  /// Guardar el catálogo de maquinaria en SharedPreferences
  static Future<void> guardarCatalogoMaquinaria(
      CatalogoMaquinariaResponse catalogo) async {
    final catalogoJson = jsonEncode(catalogo.toJson()); // Convertir a JSON
    await _preferences.setString('catalogoMaquinaria', catalogoJson);
  }

  /// Cargar el catálogo de maquinaria desde SharedPreferences
  static Future<CatalogoMaquinariaResponse?> cargarCatalogoMaquinaria() async {
    final catalogoJson = _preferences.getString('catalogoMaquinaria');

    if (catalogoJson != null) {
      final catalogoMap = jsonDecode(catalogoJson); // Convertir a Map
      return CatalogoMaquinariaResponse.fromJson(
          catalogoMap); // Convertir a objeto
    } else {
      return null; // Si no hay datos guardados, retorna null
    }
  }

  /// Limpiar el catálogo de maquinaria (opcional)
  static Future<void> limpiarCatalogoMaquinaria() async {
    await _preferences.remove('catalogoMaquinaria');
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ///
  /// Guardar el catálogo de personal en SharedPreferences
  static Future<void> guardarCatalogoPersonal(
      CatalogoPersonalModel catalogo) async {
    final catalogoJson = jsonEncode(catalogo.toJson()); // Convertir a JSON
    await _preferences.setString('catalogoPersonal', catalogoJson);
  }

  /// Cargar el catálogo de personal desde SharedPreferences
  static Future<CatalogoPersonalModel?> cargarCatalogoPersonal() async {
    final catalogoJson = _preferences.getString('catalogoPersonal');

    if (catalogoJson != null) {
      final catalogoMap = jsonDecode(catalogoJson);
      return CatalogoPersonalModel.fromJson(catalogoMap);
    } else {
      return null;
    }
  }

  /// Limpiar el catálogo de personal (opcional)
  static Future<void> limpiarCatalogoPersonal() async {
    await _preferences.remove('catalogoPersonal');
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ///
  ///
  /// /// Guardar el catálogo de conceptos en SharedPreferences
  static Future<void> guardarCatalogoMotivosInactividad(
      MotivosInactividadMaquinariaModel motivoInactividad) async {
    final catalogoJson =
        jsonEncode(motivoInactividad.toJson()); // Convertir a JSON
    await _preferences.setString('catalogoMotivosInactividad', catalogoJson);
  }

  /// Cargar el catálogo de maquinaria desde SharedPreferences
  static Future<MotivosInactividadMaquinariaModel?>
      cargarCatalogoMotivosInactividad() async {
    final catalogoJson = _preferences.getString('catalogoMotivosInactividad');

    if (catalogoJson != null) {
      final catalogoMap = jsonDecode(catalogoJson); // Convertir a Map
      return MotivosInactividadMaquinariaModel.fromJson(
          catalogoMap); // Convertir a objeto
    } else {
      return null; // Si no hay datos guardados, retorna null
    }
  }

  /// Limpiar el catálogo de maquinaria (opcional)
  static Future<void> limpiarCatalogoMotivosInactividad() async {
    await _preferences.remove('catalogoMotivosInactividad');
  }

  /********************** Super intendente ******************************* */

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ///
  ///
  static Future<void> guardarCatalogoReporteDiarioWa(
      ReporteDiarioWaModel reporteWa) async {
    final catalogoJson = jsonEncode(reporteWa.toJson()); // Convertir a JSON
    await _preferences.setString('catalogoReporteDiarioWa', catalogoJson);
  }

  static Future<ReporteDiarioWaModel?> cargarCatalogoReporteDiarioWa() async {
    final catalogoJson = _preferences.getString('catalogoReporteDiarioWa');

    if (catalogoJson != null) {
      final catalogoMap = jsonDecode(catalogoJson); // Convertir a Map
      return ReporteDiarioWaModel.fromJson(catalogoMap); // Convertir a objeto
    } else {
      return null;
    }
  }

  static Future<void> limpiarReporteDiarioWaModel() async {
    await _preferences.remove('catalogoReporteDiarioWa');
  }
}
