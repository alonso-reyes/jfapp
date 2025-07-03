// To parse this JSON data, do
//
//     final zonasTrabajoModel = zonasTrabajoModelFromJson(jsonString);

import 'dart:convert';

ZonasTrabajoModel zonasTrabajoModelFromJson(String str) =>
    ZonasTrabajoModel.fromJson(json.decode(str));

String zonasTrabajoModelToJson(ZonasTrabajoModel data) =>
    json.encode(data.toJson());

class ZonasTrabajoModel {
  bool success;
  String messages;
  List<Zona>? zonas;

  ZonasTrabajoModel({
    required this.success,
    required this.messages,
    this.zonas,
  });

  factory ZonasTrabajoModel.fromJson(Map<String, dynamic> json) =>
      ZonasTrabajoModel(
        success: json["success"],
        messages: json["messages"],
        zonas: json["zonas"] == null
            ? []
            : List<Zona>.from(json["zonas"]!.map((x) => Zona.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "messages": messages,
        "zonas": zonas == null
            ? []
            : List<dynamic>.from(zonas!.map((x) => x.toJson())),
      };
}

class Zona {
  int? id;
  String? clave;
  String? nombre;
  String? descripcion;
  int? obraId;
  String? imagenUrl;

  Zona({
    this.id,
    this.clave,
    this.nombre,
    this.descripcion,
    this.obraId,
    this.imagenUrl,
  });

  factory Zona.fromJson(Map<String, dynamic> json) => Zona(
        id: json["id"],
        clave: json["clave"],
        nombre: json["nombre"],
        descripcion: json["descripcion"],
        obraId: json["obra_id"],
        imagenUrl: json["imagen_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "clave": clave,
        "nombre": nombre,
        "descripcion": descripcion,
        "obra_id": obraId,
        "imagen_url": imagenUrl,
      };
}
