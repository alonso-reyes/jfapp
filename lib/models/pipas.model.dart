// To parse this JSON data, do
//
//     final pipasModel = pipasModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

PipasModel pipasModelFromJson(String str) =>
    PipasModel.fromJson(json.decode(str));

String pipasModelToJson(PipasModel data) => json.encode(data.toJson());

class PipasModel {
  bool success;
  String messages;
  CatalogoPipas catalogoPipas;

  PipasModel({
    required this.success,
    required this.messages,
    required this.catalogoPipas,
  });

  factory PipasModel.fromJson(Map<String, dynamic> json) => PipasModel(
        success: json["success"],
        messages: json["messages"],
        catalogoPipas: CatalogoPipas.fromJson(json["catalogo_pipas"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "messages": messages,
        "catalogo_pipas": catalogoPipas.toJson(),
      };
}

class CatalogoPipas {
  List<Pipa> pipas;

  CatalogoPipas({
    required this.pipas,
  });

  factory CatalogoPipas.fromJson(Map<String, dynamic> json) => CatalogoPipas(
        pipas: List<Pipa>.from(json["pipas"].map((x) => Pipa.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "pipas": List<dynamic>.from(pipas.map((x) => x.toJson())),
      };
}

class Pipa {
  int? id;
  String? numeroEconomico;
  String? modelo;
  String? tipo;
  double? capacidad;
  String? estado;
  String? inactividad;
  dynamic observaciones;
  dynamic observacionesInactividad;

  Pipa({
    this.id,
    this.numeroEconomico,
    this.modelo,
    this.tipo,
    required this.capacidad,
    this.estado,
    this.inactividad,
    this.observaciones,
    this.observacionesInactividad,
  });

  factory Pipa.fromJson(Map<String, dynamic> json) => Pipa(
        id: json["id"] ?? 0,
        numeroEconomico: json["numero_economico"] ?? '',
        modelo: json["modelo"] ?? '',
        tipo: json["tipo"] ?? '',
        //capacidad: (json['capacidad'] as num?)?.toDouble() ?? 0,
        capacidad: double.tryParse(json['capacidad'].toString()) ?? 0.0,
        estado: json["estado"] ?? '',
        inactividad: json["inactividad"] ?? '',
        observaciones: json["observaciones"] ?? '',
        observacionesInactividad: json["observaciones_inactividad"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "numero_economico": numeroEconomico,
        "modelo": modelo,
        "tipo": tipo,
        'capacidad': capacidad,
        "estado": estado,
        "inactividad": inactividad,
        "observaciones": observaciones,
        "observaciones_inactividad": observacionesInactividad,
      };
}
