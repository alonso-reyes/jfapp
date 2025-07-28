// To parse this JSON data, do
//
//     final catalogoPersonalModel = catalogoPersonalModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

CatalogoPersonalModel catalogoPersonalModelFromJson(String str) =>
    CatalogoPersonalModel.fromJson(json.decode(str));

String catalogoPersonalModelToJson(CatalogoPersonalModel data) =>
    json.encode(data.toJson());

class CatalogoPersonalModel {
  bool success;
  String messages;
  List<Personal> personal;

  CatalogoPersonalModel({
    required this.success,
    required this.messages,
    required this.personal,
  });

  factory CatalogoPersonalModel.fromJson(Map<String, dynamic> json) =>
      CatalogoPersonalModel(
        success: json["success"],
        messages: json["messages"],
        personal: List<Personal>.from(
            json["personal"].map((x) => Personal.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "messages": messages,
        "personal": List<dynamic>.from(personal.map((x) => x.toJson())),
      };
}

class Personal {
  int? id;
  String? nombre;
  String? puesto;
  String? actividad;

  Personal({this.id, this.nombre, this.puesto, this.actividad});

  factory Personal.fromJson(Map<String, dynamic> json) => Personal(
      id: json["id"] ?? 0,
      nombre: json["nombre"] ?? '',
      puesto: json["puesto"] ?? '',
      actividad: json["actividad"] ?? '');

  Map<String, dynamic> toJson() =>
      {"id": id, "nombre": nombre, "puesto": puesto, "actividad": actividad};
}
