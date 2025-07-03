// To parse this JSON data, do
//
//     final catalogosAcarreosAguaModel = catalogosAcarreosAguaModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

CatalogosAcarreosAguaModel catalogosAcarreosAguaModelFromJson(String str) =>
    CatalogosAcarreosAguaModel.fromJson(json.decode(str));

String catalogosAcarreosAguaModelToJson(CatalogosAcarreosAguaModel data) =>
    json.encode(data.toJson());

class CatalogosAcarreosAguaModel {
  bool success;
  String messages;
  Catalogo catalogo;

  CatalogosAcarreosAguaModel({
    required this.success,
    required this.messages,
    required this.catalogo,
  });

  factory CatalogosAcarreosAguaModel.fromJson(Map<String, dynamic> json) =>
      CatalogosAcarreosAguaModel(
        success: json["success"],
        messages: json["messages"],
        catalogo: Catalogo.fromJson(json["catalogo"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "messages": messages,
        "catalogo": catalogo.toJson(),
      };
}

class Catalogo {
  List<Origenes> origenes;
  List<Destinos> destinos;
  List<Pipas> pipas;

  Catalogo({
    required this.origenes,
    required this.destinos,
    required this.pipas,
  });

  factory Catalogo.fromJson(Map<String, dynamic> json) => Catalogo(
        origenes: List<Origenes>.from(
            json["origenes"].map((x) => Origenes.fromJson(x))),
        destinos: List<Destinos>.from(
            json["destinos"].map((x) => Destinos.fromJson(x))),
        pipas: List<Pipas>.from(json["pipas"].map((x) => Pipas.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "origenes": List<dynamic>.from(origenes.map((x) => x.toJson())),
        "destinos": List<dynamic>.from(destinos.map((x) => x.toJson())),
        "pipas": List<dynamic>.from(pipas.map((x) => x.toJson())),
      };
}

class Destinos {
  int id;
  String destino;

  Destinos({
    required this.id,
    required this.destino,
  });

  factory Destinos.fromJson(Map<String, dynamic> json) => Destinos(
        id: json["id"],
        destino: json["destino"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "destino": destino,
      };
}

class Origenes {
  int id;
  String origen;

  Origenes({
    required this.id,
    required this.origen,
  });

  factory Origenes.fromJson(Map<String, dynamic> json) => Origenes(
        id: json["id"],
        origen: json["origen"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "origen": origen,
      };
}

class Pipas {
  int? id;
  String? numeroEconomico;
  String? modelo;
  String? tipo;
  String? capacidad;
  String? estado;
  String? inactividad;

  Pipas({
    required this.id,
    required this.numeroEconomico,
    required this.modelo,
    required this.tipo,
    required this.capacidad,
    required this.estado,
    required this.inactividad,
  });

  factory Pipas.fromJson(Map<String, dynamic> json) => Pipas(
        id: json["id"],
        numeroEconomico: json["numero_economico"],
        modelo: json["modelo"],
        tipo: json["tipo"],
        capacidad: json["capacidad"],
        estado: json["estado"],
        inactividad: json["inactividad"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "numero_economico": numeroEconomico,
        "modelo": modelo,
        "tipo": tipo,
        "capacidad": capacidad,
        "estado": estado,
        "inactividad": inactividad,
      };
}
