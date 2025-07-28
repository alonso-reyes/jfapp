// To parse this JSON data, do
//
//     final motivosInactividadMaquinariaModel = motivosInactividadMaquinariaModelFromJson(jsonString);

import 'dart:convert';

MotivosInactividadMaquinariaModel motivosInactividadMaquinariaModelFromJson(
        String str) =>
    MotivosInactividadMaquinariaModel.fromJson(json.decode(str));

String motivosInactividadMaquinariaModelToJson(
        MotivosInactividadMaquinariaModel data) =>
    json.encode(data.toJson());

class MotivosInactividadMaquinariaModel {
  final bool success;
  final String messages;
  final List<MotivosInactividadMaquinaria> motivosInactividadMaquinaria;

  MotivosInactividadMaquinariaModel({
    required this.success,
    required this.messages,
    required this.motivosInactividadMaquinaria,
  });

  factory MotivosInactividadMaquinariaModel.fromJson(
          Map<String, dynamic> json) =>
      MotivosInactividadMaquinariaModel(
        success: json["success"],
        messages: json["messages"],
        motivosInactividadMaquinaria: List<MotivosInactividadMaquinaria>.from(
            json["motivos_inactividad_maquinaria"]
                .map((x) => MotivosInactividadMaquinaria.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "messages": messages,
        "motivos_inactividad_maquinaria": List<dynamic>.from(
            motivosInactividadMaquinaria.map((x) => x.toJson())),
      };
}

class MotivosInactividadMaquinaria {
  final int id;
  final String motivoInactividad;

  MotivosInactividadMaquinaria({
    required this.id,
    required this.motivoInactividad,
  });

  factory MotivosInactividadMaquinaria.fromJson(Map<String, dynamic> json) =>
      MotivosInactividadMaquinaria(
        id: json["id"],
        motivoInactividad: json["motivo_inactividad"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "motivo_inactividad": motivoInactividad,
      };
}
