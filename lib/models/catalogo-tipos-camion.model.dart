// To parse this JSON data, do
//
//     final catalogoTiposCamionesModel = catalogoTiposCamionesModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

CatalogoTiposCamionesModel catalogoTiposCamionesModelFromJson(String str) =>
    CatalogoTiposCamionesModel.fromJson(json.decode(str));

String catalogoTiposCamionesModelToJson(CatalogoTiposCamionesModel data) =>
    json.encode(data.toJson());

class CatalogoTiposCamionesModel {
  bool success;
  String messages;
  List<TipoCamion> camiones;

  CatalogoTiposCamionesModel({
    required this.success,
    required this.messages,
    required this.camiones,
  });

  factory CatalogoTiposCamionesModel.fromJson(Map<String, dynamic> json) =>
      CatalogoTiposCamionesModel(
        success: json["success"],
        messages: json["messages"],
        camiones: List<TipoCamion>.from(
            json["camiones"].map((x) => TipoCamion.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "messages": messages,
        "camiones": List<dynamic>.from(camiones.map((x) => x.toJson())),
      };
}

class TipoCamion {
  int id;
  String nombre;

  TipoCamion({
    required this.id,
    required this.nombre,
  });

  factory TipoCamion.fromJson(Map<String, dynamic> json) => TipoCamion(
        id: json["id"],
        nombre: json["nombre"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
      };
}
