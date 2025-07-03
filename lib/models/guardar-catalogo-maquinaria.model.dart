import 'dart:convert';

import 'package:jfapp/models/catalogo-maquinaria.model.dart';
import 'package:jfapp/models/concepto.model.dart';

class GuardarCatalogoMaquinariaModel {
  final Concepto? concepto;
  final FamiliaMaquinaria? familia;
  final Maquinaria? maquinaria;
  final Operador? operador;
  final Horometro? horometro;
  final String? observaciones;

  GuardarCatalogoMaquinariaModel(
      {required this.concepto,
      required this.familia,
      required this.maquinaria,
      required this.horometro,
      this.operador,
      this.observaciones});

  factory GuardarCatalogoMaquinariaModel.fromJson(Map<String, dynamic> json) {
    return GuardarCatalogoMaquinariaModel(
      concepto:
          json['concepto'] != null ? Concepto.fromJson(json['concepto']) : null,
      familia: json['familia'] != null
          ? FamiliaMaquinaria.fromJson(json['familia'])
          : null,
      maquinaria: json['maquinaria'] != null
          ? Maquinaria.fromJson(json['maquinaria'])
          : null,
      operador:
          json['operador'] != null ? Operador.fromJson(json['operador']) : null,
      horometro: json['horometro'] != null
          ? Horometro.fromJson(json['horometro'])
          : null,
      observaciones: json['observaciones'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'concepto': concepto?.toJson(),
      'familia': {
        'id': familia?.id,
        'familia': familia?.familia,
      },
      'maquinaria': {
        'id': maquinaria?.id,
        'numero_economico': maquinaria?.numeroEconomico,
      },
      'operador': {
        'id': operador?.id,
        'nombre': operador?.nombre,
      },
      'horometro': horometro?.toJson(),
      'observaciones': observaciones,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'concepto': concepto?.toJson(),
      'familia': familia?.toJson(),
      'maquinaria': maquinaria?.toJson(),
      'operador': operador?.toJson(),
      'horometro': horometro?.toJson(),
      'observaciones': observaciones,
    };
  }

  // Convierte el objeto a String
  @override
  String toString() {
    return jsonEncode({
      'concepto': concepto?.toJson(),
      'familia': {
        'id': familia?.id,
        'familia': familia?.familia,
      },
      'maquinaria': {
        'id': maquinaria?.id,
        'numero_economico': maquinaria?.numeroEconomico,
      },
      'operador': {
        'id': operador?.id,
        'nombre': operador?.nombre,
      },
      'horometro': horometro?.toJson(),
      'observaciones': observaciones, // 👈 Para string también
    });
  }

  // Convierte un String a objeto
  factory GuardarCatalogoMaquinariaModel.fromString(String str) {
    final Map<String, dynamic> data = jsonDecode(str);
    return GuardarCatalogoMaquinariaModel(
      concepto: Concepto.fromJson(data['concepto']),
      familia: FamiliaMaquinaria(
        id: data['familia']['id'],
        familia: data['familia']['familia'],
        maquinarias: [],
        operadores: [],
      ),
      maquinaria: Maquinaria(
        id: data['maquinaria']['id'],
        numeroEconomico: data['maquinaria']['numero_economico'],
        horometro: Horometro.fromJson(data['horometro']),
      ),
      operador: Operador(
        id: data['operador']['id'],
        nombre: data['operador']['nombre'],
      ),
      horometro: Horometro.fromJson(data['horometro']),
      observaciones: data['observaciones'],
    );
  }
}

/* factory GuardarCatalogoMaquinariaModel.fromString(String str) {
    final Map<String, dynamic> data = jsonDecode(str);
    return GuardarCatalogoMaquinariaModel(
      concepto: Concepto.fromJson(data['concepto']),
      familia: FamiliaMaquinaria.fromJson(data['familia']),
      maquinaria: Maquinaria.fromJson(data['maquinaria']),
      operador: Operador.fromJson(data['operador']),
      horometro: Horometro.fromJson(data['horometro']),
    );
  }
}*/
