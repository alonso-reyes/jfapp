// To parse this JSON data, do
//
//     final origenesModel = origenesModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

OrigenesModel origenesModelFromJson(String str) =>
    OrigenesModel.fromJson(json.decode(str));

String origenesModelToJson(OrigenesModel data) => json.encode(data.toJson());

class OrigenesModel {
  bool success;
  String messages;
  List<Origen> origenes;

  OrigenesModel({
    required this.success,
    required this.messages,
    required this.origenes,
  });

  factory OrigenesModel.fromJson(Map<String, dynamic> json) => OrigenesModel(
        success: json["success"],
        messages: json["messages"],
        origenes:
            List<Origen>.from(json["origenes"].map((x) => Origen.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "messages": messages,
        "origenes": List<dynamic>.from(origenes.map((x) => x.toJson())),
      };
}

class Origen {
  int id;
  String origen;

  Origen({
    required this.id,
    required this.origen,
  });

  factory Origen.fromJson(Map<String, dynamic> json) => Origen(
        id: json["id"],
        origen: json["origen"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "origen": origen,
      };
}
