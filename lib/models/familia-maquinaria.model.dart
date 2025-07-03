// To parse this JSON data, do
//
//     final familiaMaquinariaModel = familiaMaquinariaModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

FamiliaMaquinariaModel familiaMaquinariaModelFromJson(String str) =>
    FamiliaMaquinariaModel.fromJson(json.decode(str));

String familiaMaquinariaModelToJson(FamiliaMaquinariaModel data) =>
    json.encode(data.toJson());

class FamiliaMaquinariaModel {
  bool success;
  String messages;
  List<Familia> familias;

  FamiliaMaquinariaModel({
    required this.success,
    required this.messages,
    required this.familias,
  });

  factory FamiliaMaquinariaModel.fromJson(Map<String, dynamic> json) =>
      FamiliaMaquinariaModel(
        success: json["success"],
        messages: json["messages"],
        familias: List<Familia>.from(
            json["familias"].map((x) => Familia.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "messages": messages,
        "familias": List<dynamic>.from(familias.map((x) => x.toJson())),
      };
}

class Familia {
  int? id;
  String? familia;

  Familia({
    this.id,
    this.familia,
  });

  factory Familia.fromJson(Map<String, dynamic> json) => Familia(
        id: json["id"] ?? 0,
        familia: json["familia"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "familia": familia,
      };
}
