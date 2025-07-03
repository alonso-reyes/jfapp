// To parse this JSON data, do
//
//     final destinosModel = destinosModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

DestinosModel destinosModelFromJson(String str) =>
    DestinosModel.fromJson(json.decode(str));

String destinosModelToJson(DestinosModel data) => json.encode(data.toJson());

class DestinosModel {
  bool success;
  String messages;
  List<Destino> destinos;

  DestinosModel({
    required this.success,
    required this.messages,
    required this.destinos,
  });

  factory DestinosModel.fromJson(Map<String, dynamic> json) => DestinosModel(
        success: json["success"],
        messages: json["messages"],
        destinos: List<Destino>.from(
            json["destinos"].map((x) => Destino.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "messages": messages,
        "destinos": List<dynamic>.from(destinos.map((x) => x.toJson())),
      };
}

class Destino {
  int id;
  String destino;

  Destino({
    required this.id,
    required this.destino,
  });

  factory Destino.fromJson(Map<String, dynamic> json) => Destino(
        id: json["id"],
        destino: json["destino"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "destino": destino,
      };
}
