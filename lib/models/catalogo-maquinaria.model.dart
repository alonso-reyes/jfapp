// To parse this JSON data, do
//
//     final catalogoMaquinariaResponse = catalogoMaquinariaResponseFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

CatalogoMaquinariaResponse catalogoMaquinariaResponseFromJson(String str) =>
    CatalogoMaquinariaResponse.fromJson(json.decode(str));

String catalogoMaquinariaResponseToJson(CatalogoMaquinariaResponse data) =>
    json.encode(data.toJson());

class CatalogoMaquinariaResponse {
  bool success;
  String messages;
  List<FamiliaMaquinaria> catalogoMaquinarias;

  CatalogoMaquinariaResponse({
    required this.success,
    required this.messages,
    required this.catalogoMaquinarias,
  });

  factory CatalogoMaquinariaResponse.fromJson(Map<String, dynamic> json) =>
      CatalogoMaquinariaResponse(
        success: json["success"],
        messages: json["messages"],
        catalogoMaquinarias: List<FamiliaMaquinaria>.from(
            json["catalogo_maquinarias"]
                .map((x) => FamiliaMaquinaria.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "messages": messages,
        "catalogo_maquinarias":
            List<dynamic>.from(catalogoMaquinarias.map((x) => x.toJson())),
      };
}

class FamiliaMaquinaria {
  int id;
  String familia;
  List<Maquinaria> maquinarias;
  List<Operador> operadores;

  FamiliaMaquinaria({
    required this.id,
    required this.familia,
    required this.maquinarias,
    required this.operadores,
  });

  factory FamiliaMaquinaria.fromJson(Map<String, dynamic> json) =>
      FamiliaMaquinaria(
        id: json["id"],
        familia: json["familia"],
        maquinarias: List<Maquinaria>.from(
            json["maquinarias"].map((x) => Maquinaria.fromJson(x))),
        operadores: List<Operador>.from(
            json["operadores"].map((x) => Operador.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "familia": familia,
        "maquinarias": List<dynamic>.from(maquinarias.map((x) => x.toJson())),
        "operadores": List<dynamic>.from(operadores.map((x) => x.toJson())),
      };
}

class Maquinaria {
  int id;
  String numeroEconomico;
  Horometro horometro;

  Maquinaria({
    required this.id,
    required this.numeroEconomico,
    required this.horometro,
  });

  factory Maquinaria.fromJson(Map<String, dynamic> json) => Maquinaria(
        id: json["id"],
        numeroEconomico: json["numero_economico"],
        horometro: Horometro.fromJson(json["horometro"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "numero_economico": numeroEconomico,
        "horometro": horometro.toJson(),
      };
}

class Horometro {
  double? horometroInicial;
  double? horometroFinal;

  Horometro({
    this.horometroInicial,
    this.horometroFinal,
  });

  factory Horometro.fromJson(Map<String, dynamic> json) {
    return Horometro(
      horometroInicial: (json['horometro_inicial'] is String)
          ? double.tryParse(json['horometro_inicial'])
          : (json['horometro_inicial'] as num?)?.toDouble(),
      horometroFinal: (json['horometro_final'] is String)
          ? double.tryParse(json['horometro_final'])
          : (json['horometro_final'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        "horometro_inicial": horometroInicial,
        "horometro_final": horometroFinal,
      };
}

class Operador {
  int? id;
  String? nombre;

  Operador({
    this.id,
    this.nombre,
  });

  factory Operador.fromJson(Map<String, dynamic> json) => Operador(
        id: json["id"],
        nombre: json["nombre"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
      };
}
