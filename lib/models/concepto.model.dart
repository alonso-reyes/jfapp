// To parse this JSON data, do
//
//     final conceptoModel = conceptoModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

ConceptoModel conceptoModelFromJson(String str) =>
    ConceptoModel.fromJson(json.decode(str));

String conceptoModelToJson(ConceptoModel data) => json.encode(data.toJson());

class ConceptoModel {
  bool success;
  String messages;
  List<Concepto> conceptos;

  ConceptoModel({
    required this.success,
    required this.messages,
    required this.conceptos,
  });

  factory ConceptoModel.fromJson(Map<String, dynamic> json) => ConceptoModel(
        success: json["success"],
        messages: json["messages"],
        conceptos: List<Concepto>.from(
            json["conceptos"].map((x) => Concepto.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "messages": messages,
        "conceptos": List<dynamic>.from(conceptos.map((x) => x.toJson())),
      };
}

class Concepto {
  int id;
  String concepto;
  String descripcion;

  Concepto(
      {required this.id, required this.concepto, required this.descripcion});

  factory Concepto.fromJson(Map<String, dynamic> json) => Concepto(
      id: json["id"],
      concepto: json["concepto"],
      descripcion: json["descripcion"]);

  Map<String, dynamic> toJson() =>
      {"id": id, "concepto": concepto, "descripcion": descripcion};
}
