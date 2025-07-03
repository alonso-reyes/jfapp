// To parse this JSON data, do
//
//     final materialModel = materialModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

MaterialModel materialModelFromJson(String str) =>
    MaterialModel.fromJson(json.decode(str));

String materialModelToJson(MaterialModel data) => json.encode(data.toJson());

class MaterialModel {
  bool success;
  String messages;
  List<Materiales> material;

  MaterialModel({
    required this.success,
    required this.messages,
    required this.material,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) => MaterialModel(
        success: json["success"],
        messages: json["messages"],
        material: List<Materiales>.from(
            json["material"].map((x) => Materiales.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "messages": messages,
        "material": List<dynamic>.from(material.map((x) => x.toJson())),
      };
}

class Materiales {
  int id;
  String material;

  Materiales({
    required this.id,
    required this.material,
  });

  factory Materiales.fromJson(Map<String, dynamic> json) => Materiales(
        id: json["id"],
        material: json["material"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "material": material,
      };
}
