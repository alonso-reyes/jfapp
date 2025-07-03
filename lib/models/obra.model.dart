// To parse this JSON data, do
//
//     final obraModel = obraModelFromJson(jsonString);

import 'dart:convert';

ObraModel obraModelFromJson(String str) => ObraModel.fromJson(json.decode(str));

String obraModelToJson(ObraModel data) => json.encode(data.toJson());

class ObraModel {
  bool success;
  String messages;
  String clave;
  String nombre;
  String contrato;
  String ubicacion;
  String descripcion;

  ObraModel({
    required this.success,
    required this.messages,
    required this.clave,
    required this.nombre,
    required this.contrato,
    required this.ubicacion,
    required this.descripcion,
  });

  factory ObraModel.fromJson(Map<String, dynamic> json) => ObraModel(
        success: json["success"],
        messages: json["messages"],
        clave: json["clave"] ?? '',
        nombre: json["nombre"] ?? '',
        contrato: json["contrato"] ?? '',
        ubicacion: json["ubicacion"] ?? '',
        descripcion: json["descripcion"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "messages": messages,
        "clave": clave,
        "nombre": nombre,
        "contrato": contrato,
        "ubicacion": ubicacion,
        "descripcion": descripcion,
      };
}
