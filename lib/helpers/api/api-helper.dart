import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jfapp/models/camiones.model.dart';
import 'package:jfapp/models/catalogo-generales.model.dart';
import 'package:jfapp/models/catalogo-maquinaria.model.dart';
import 'package:jfapp/models/catalogo-motivos-inactividad-maquinaria.model.dart';
import 'package:jfapp/models/catalogo-personal.model.dart';
import 'package:jfapp/models/catalogo-tipos-camion.model.dart';
import 'package:jfapp/models/catalogos-agua.model.dart';
import 'package:jfapp/models/catalogos-volumen.model.dart';
import 'package:jfapp/models/concepto.model.dart';
import 'package:jfapp/models/destino.model.dart';
import 'package:jfapp/models/familia-maquinaria.model.dart';
import 'package:jfapp/models/material.model.dart';
import 'package:jfapp/models/obra.model.dart';
import 'package:jfapp/models/origen.model.dart';
import 'package:jfapp/models/pipas.model.dart';
import 'package:jfapp/models/reporte-diario-wa.model.dart';
import 'package:jfapp/models/turno.model.dart';
import 'dart:developer' as dev;

import 'package:jfapp/models/user.model.dart';
import 'package:jfapp/models/uso-material.model.dart';
import 'package:jfapp/models/zonas-trabajo.model.dart';

Future apiCall(Map<String, dynamic> params, String endpoint) async {
  try {
    final baseUrl = dotenv.env['BASE_URL_API'] ?? '';
    if (baseUrl.isEmpty) {
      throw Exception('La URL base de la API no está configurada.');
    }

    // Construye la URL completa concatenando la base con el endpoint
    final url = Uri.parse('$baseUrl/$endpoint');

    //dev.log('Llamando a la API: $url');
    //dev.log('Parámetros: ${jsonEncode(params)}');

    var token = params['token'] != null ? params['token'] : '';
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      },
      body: jsonEncode(params),
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      return res;
    } else {
      throw Exception(
          'Error del servidor: ${response.statusCode}, ${response.body}');
    }
  } catch (e) {
    dev.log('Error en la API: $e');
    throw e;
  }
}

login(String user, String password) async {
  final params = {'usuario': user, 'password': password};

  final response = await apiCall(params, 'login');
  //dev.log('Respuesta del servidor: $response');

  if (response == null) {
    return 'Server error.';
  } else {
    final res = UserModel.fromJson(response);
    return res;
  }
}

logout(String token) async {
  final params = {'token': token};

  final response = await apiCall(params, 'logout');
  //dev.log('Respuesta del servidor: $response');

  if (response == null) {
    return 'Server error.';
  } else {
    final res = UserModel.fromJson(response);
    return res;
  }
}

getObra(String token, int idObra) async {
  final params = {'token': token, 'obra_id': idObra};

  final response = await apiCall(params, 'getObra');
  //dev.log('Respuesta del servidor: $response');

  if (response == null) {
    return 'Server error.';
  } else {
    final res = ObraModel.fromJson(response);
    return res;
  }
}

getTurno(String token, int idObra) async {
  final params = {'token': token, 'obra_id': idObra};

  final response = await apiCall(params, 'getTurnos');
  //dev.log('Respuesta del servidor: $response');

  if (response == null) {
    return 'Server error.';
  } else {
    final res = TurnoModel.fromJson(response);
    return res;
  }
}

getZonasTrabajo(String token, int idObra) async {
  final params = {'token': token, 'obra_id': idObra};

  final response = await apiCall(params, 'getZonasTrabajo');
  //dev.log('Respuesta del servidor: $response');

  if (response == null) {
    return 'Server error.';
  } else {
    final res = ZonasTrabajoModel.fromJson(response);
    return res;
  }
}

getMaterial(String token, int idObra) async {
  final params = {'token': token, 'obra_id': idObra};

  final response = await apiCall(params, 'getMateriales');
  dev.log('Respuesta del servidor: $response');

  if (response == null) {
    return 'Server error.';
  } else {
    final res = MaterialModel.fromJson(response);
    return res;
  }
}

getUsoMaterial(String token, int idObra) async {
  final params = {'token': token, 'obra_id': idObra};

  final response = await apiCall(params, 'getUsoMateriales');
  //dev.log('Respuesta del servidor: $response');

  if (response == null) {
    return 'Server error.';
  } else {
    final res = UsoMaterialModel.fromJson(response);
    return res;
  }
}

getOrigenes(String token, int idObra) async {
  final params = {'token': token, 'obra_id': idObra};

  final response = await apiCall(params, 'getOrigenes');
  //dev.log('Respuesta del servidor: $response');

  if (response == null) {
    return 'Server error.';
  } else {
    final res = OrigenesModel.fromJson(response);
    return res;
  }
}

getDestinos(String token, int idObra) async {
  final params = {'token': token, 'obra_id': idObra};

  final response = await apiCall(params, 'getDestinos');
  //dev.log('Respuesta del servidor: $response');

  if (response == null) {
    return 'Server error.';
  } else {
    final res = DestinosModel.fromJson(response);
    return res;
  }
}

getConceptos(String token, int idObra) async {
  final params = {'token': token, 'obra_id': idObra};

  final response = await apiCall(params, 'getConceptos');
  //dev.log('Respuesta del servidor: $response');

  if (response == null) {
    return 'Server error.';
  } else {
    final res = ConceptoModel.fromJson(response);
    return res;
  }
}

getCamiones(String token, int idObra) async {
  final params = {'token': token, 'obra_id': idObra};

  final response = await apiCall(params, 'getCamiones');
  //dev.log('Respuesta del servidor: $response');

  if (response == null) {
    return 'Server error.';
  } else {
    final res = CamionModel.fromJson(response);
    return res;
  }
}

getCatalogoTipoCamion(String token, int idObra) async {
  final params = {'token': token, 'obra_id': idObra};

  final response = await apiCall(params, 'getCatalogoCamionesAcarreo');
  //dev.log('Respuesta del servidor: $response');

  if (response == null) {
    return 'Server error.';
  } else {
    final res = CatalogoTiposCamionesModel.fromJson(response);
    return res;
  }
}

getCatalogosAcarreoVolumen(String token, int idObra) async {
  final params = {'token': token, 'obra_id': idObra};
  final response = await apiCall(params, 'getCatalogosVolumen');
  //dev.log('Respuesta de catalogos de volumen: $response');
  if (response == null) {
    return 'Server error.';
  } else {
    final res = CatalogosVolumenModel.fromJson(response);
    return res;
  }
}

getCatalogosAcarreoAgua(String token, int idObra) async {
  final params = {'token': token, 'obra_id': idObra};
  final response = await apiCall(params, 'getCatalogosAgua');
  //dev.log('Respuesta de catalogos de volumen: $response');
  if (response == null) {
    return 'Server error.';
  } else {
    final res = CatalogosAcarreosAguaModel.fromJson(response);
    return res;
  }
}

getCatalogosPipas(String token, int idObra) async {
  final params = {'token': token, 'obra_id': idObra};
  final response = await apiCall(params, 'getPipas');
  //dev.log('Respuesta de catalogos de volumen: $response');
  if (response == null) {
    return 'Server error.';
  } else {
    final res = PipasModel.fromJson(response);
    return res;
  }
}

getFamiliasMaquinaria(String token, int idObra) async {
  final params = {'token': token, 'obra_id': idObra};
  final response = await apiCall(params, 'getTiposMaquinaria');
  //dev.log('Respuesta de catalogos de volumen: $response');
  if (response == null) {
    return 'Server error.';
  } else {
    final res = CatalogoMaquinariaResponse.fromJson(response);
    return res;
  }
}

getCatalogoPersonal(String token, int idObra) async {
  final params = {'token': token, 'obra_id': idObra};
  final response = await apiCall(params, 'getPersonal');
  //dev.log('Respuesta de catalogos de volumen: $response');
  if (response == null) {
    return 'Server error.';
  } else {
    final res = CatalogoPersonalModel.fromJson(response);
    return res;
  }
}

getCatalogoGenerales(String token, int idObra) async {
  final params = {'token': token, 'obra_id': idObra};
  final response = await apiCall(params, 'getCatalogoGenerales');
  dev.log('Respuesta de catalogos de GENERALES: $response');
  //dev.log('Respuesta de catalogos de GENERALES: $response');
  if (response == null) {
    return 'Server error.';
  } else {
    final res = CatalogoGeneralesModel.fromJson(response);
    return res;
  }
}

Future<Map<String, dynamic>> guardarReporteJF(
    String token, int idObra, Map<String, dynamic> data) async {
  try {
    final params = {'token': token, 'obra_id': idObra, 'data': data};
    dev.log(params.toString());
    //return {};
    final response = await apiCall(params, 'guardar_reporte');

    if (response != null) {
      return {
        'success': true,
        'message': 'Reporte guardado exitosamente',
        //'data': response
      };
    } else {
      return {
        'success': false,
        'message': 'No se pudo guardar el reporte',
      };
    }
  } catch (e) {
    // Manejar cualquier error de red o de procesamiento
    return {
      'success': false,
      'message': 'Error al guardar el reporte: ${e.toString()}',
    };
  }
}

getReporteDiarioWhatsapp(String token, int idObra) async {
  final params = {'token': token, 'obra_id': idObra};
  final response = await apiCall(params, 'reporte_diario_whatsapp');
  //dev.log('Respuesta de catalogos de volumen: $response');
  if (response == null) {
    return 'Server error.';
  } else {
    final res = ReporteDiarioWaModel.fromJson(response);
    return res;
  }
}

Future<Map<String, dynamic>> enviarReporteDiario(
    String token, int idObra, String fecha) async {
  try {
    final params = {'token': token, 'obra_id': idObra, 'fecha': fecha};
    dev.log(params.toString());
    //return {};
    final response = await apiCall(params, 'enviar_reporte_diario');
    dev.log(response.toString());
    // return {};
    if (response != null) {
      return {
        'success': true,
        'message': 'Reporte enviado exitosamente',
        'data': response
      };
    } else {
      return {
        'success': false,
        'message': 'No se pudo enviar el reporte',
      };
    }
  } catch (e) {
    // Manejar cualquier error de red o de procesamiento
    return {
      'success': false,
      'message': 'Error al enviar el reporte: ${e.toString()}',
    };
  }
}

Future<String?> obtenerTextoDesdeAPI(
    String token, int obraId, DateTime fecha) async {
  try {
    final fechaFormateada = DateFormat('yyyy-MM-dd').format(fecha);

    final params = {
      'token': token,
      'obra_id': obraId,
      'fecha': fechaFormateada,
      'formato': 'texto'
    };

    final response = await apiCall(params, 'obtener_texto_reporte');

    if (response != null &&
        response['success'] == true &&
        response['data'] != null) {
      if (response['data'] is String) {
        return response['data'];
      } else if (response['data'] is Map &&
          response['data'].containsKey('texto')) {
        return response['data']['texto'];
      }
    }

    return null;
  } catch (e) {
    dev.log('Error al obtener texto del API: ${e.toString()}');
    return null;
  }
}

getCatalogoInactividadMaquinaria(String token, int idObra) async {
  final params = {'token': token, 'obra_id': idObra};
  final response = await apiCall(params, 'getTiposMaquinaria');
  //dev.log('Respuesta de catalogos de volumen: $response');
  if (response == null) {
    return 'Server error.';
  } else {
    final res = MotivosInactividadMaquinariaModel.fromJson(response);
    return res;
  }
}
