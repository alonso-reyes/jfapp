// To parse this JSON data, do
//
//     final reporteDiarioWaModel = reporteDiarioWaModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

ReporteDiarioWaModel reporteDiarioWaModelFromJson(String str) =>
    ReporteDiarioWaModel.fromJson(json.decode(str));

String reporteDiarioWaModelToJson(ReporteDiarioWaModel data) =>
    json.encode(data.toJson());

class ReporteDiarioWaModel {
  bool success;
  String messages;
  List<DataWa> data;

  ReporteDiarioWaModel({
    required this.success,
    required this.messages,
    required this.data,
  });

  factory ReporteDiarioWaModel.fromJson(Map<String, dynamic> json) =>
      ReporteDiarioWaModel(
        success: json["success"],
        messages: json["messages"],
        data: List<DataWa>.from(json["data"].map((x) => DataWa.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "messages": messages,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class DataWa {
  DateTime fecha;
  int totalMaquinaria;
  List<MaquinariaPorTipo> maquinariaPorTipo;
  int totalPersonal;
  List<PersonalPorPuesto> personalPorPuesto;
  Acarreos acarreos;

  DataWa({
    required this.fecha,
    required this.totalMaquinaria,
    required this.maquinariaPorTipo,
    required this.totalPersonal,
    required this.personalPorPuesto,
    required this.acarreos,
  });

  factory DataWa.fromJson(Map<String, dynamic> json) => DataWa(
        fecha: DateTime.parse(json["fecha"]),
        totalMaquinaria: json["total_maquinaria"],
        maquinariaPorTipo: List<MaquinariaPorTipo>.from(
            json["maquinaria_por_tipo"]
                .map((x) => MaquinariaPorTipo.fromJson(x))),
        totalPersonal: json["total_personal"],
        personalPorPuesto: List<PersonalPorPuesto>.from(
            json["personal_por_puesto"]
                .map((x) => PersonalPorPuesto.fromJson(x))),
        acarreos: Acarreos.fromJson(json["acarreos"]),
      );

  Map<String, dynamic> toJson() => {
        "fecha":
            "${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}",
        "total_maquinaria": totalMaquinaria,
        "maquinaria_por_tipo":
            List<dynamic>.from(maquinariaPorTipo.map((x) => x.toJson())),
        "total_personal": totalPersonal,
        "personal_por_puesto":
            List<dynamic>.from(personalPorPuesto.map((x) => x.toJson())),
        "acarreos": acarreos.toJson(),
      };
}

class Acarreos {
  List<DetallesVolumen> detallesVolumen;
  Volumen volumen;
  dynamic area;
  dynamic metroLineal;

  Acarreos({
    required this.detallesVolumen,
    required this.volumen,
    required this.area,
    required this.metroLineal,
  });

  factory Acarreos.fromJson(Map<String, dynamic> json) => Acarreos(
        detallesVolumen: List<DetallesVolumen>.from(
            json["detalles_volumen"].map((x) => DetallesVolumen.fromJson(x))),
        volumen: Volumen.fromJson(json["volumen"]),
        area: json["area"],
        metroLineal: json["metro_lineal"],
      );

  Map<String, dynamic> toJson() => {
        "detalles_volumen":
            List<dynamic>.from(detallesVolumen.map((x) => x.toJson())),
        "volumen": volumen.toJson(),
        "area": area,
        "metro_lineal": metroLineal,
      };
}

class DetallesVolumen {
  String material;
  String usoMaterial;
  String volumen;

  DetallesVolumen({
    required this.material,
    required this.usoMaterial,
    required this.volumen,
  });

  factory DetallesVolumen.fromJson(Map<String, dynamic> json) =>
      DetallesVolumen(
        material: json["material"],
        usoMaterial: json["uso_material"],
        volumen: json["volumen"],
      );

  Map<String, dynamic> toJson() => {
        "material": material,
        "uso_material": usoMaterial,
        "volumen": volumen,
      };
}

class Volumen {
  String totalViajes;
  String totalCapacidad;
  String totalVolumen;

  Volumen({
    required this.totalViajes,
    required this.totalCapacidad,
    required this.totalVolumen,
  });

  factory Volumen.fromJson(Map<String, dynamic> json) => Volumen(
        totalViajes: json["total_viajes"],
        totalCapacidad: json["total_capacidad"],
        totalVolumen: json["total_volumen"],
      );

  Map<String, dynamic> toJson() => {
        "total_viajes": totalViajes,
        "total_capacidad": totalCapacidad,
        "total_volumen": totalVolumen,
      };
}

class MaquinariaPorTipo {
  String tipoMaquinaria;
  int total;

  MaquinariaPorTipo({
    required this.tipoMaquinaria,
    required this.total,
  });

  factory MaquinariaPorTipo.fromJson(Map<String, dynamic> json) =>
      MaquinariaPorTipo(
        tipoMaquinaria: json["tipo_maquinaria"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "tipo_maquinaria": tipoMaquinaria,
        "total": total,
      };
}

class PersonalPorPuesto {
  String puesto;
  int total;

  PersonalPorPuesto({
    required this.puesto,
    required this.total,
  });

  factory PersonalPorPuesto.fromJson(Map<String, dynamic> json) =>
      PersonalPorPuesto(
        puesto: json["puesto"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "puesto": puesto,
        "total": total,
      };
}
