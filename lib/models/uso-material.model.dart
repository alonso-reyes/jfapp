// To parse this JSON data, do
//
//     final usoMaterialModel = usoMaterialModelFromJson(jsonString);

import 'dart:convert';

UsoMaterialModel usoMaterialModelFromJson(String str) =>
    UsoMaterialModel.fromJson(json.decode(str));

String usoMaterialModelToJson(UsoMaterialModel data) =>
    json.encode(data.toJson());

class UsoMaterialModel {
  bool success;
  String messages;
  List<UsosMaterial> usosMaterial;

  UsoMaterialModel({
    required this.success,
    required this.messages,
    required this.usosMaterial,
  });

  factory UsoMaterialModel.fromJson(Map<String, dynamic> json) =>
      UsoMaterialModel(
        success: json["success"],
        messages: json["messages"],
        usosMaterial: List<UsosMaterial>.from(
            json["usos_material"].map((x) => UsosMaterial.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "messages": messages,
        "usos_material":
            List<dynamic>.from(usosMaterial.map((x) => x.toJson())),
      };
}

class UsosMaterial {
  int id;
  String uso;

  UsosMaterial({
    required this.id,
    required this.uso,
  });

  factory UsosMaterial.fromJson(Map<String, dynamic> json) => UsosMaterial(
        id: json["id"],
        uso: json["uso"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "uso": uso,
      };
}
