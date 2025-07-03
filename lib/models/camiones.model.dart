// To parse this JSON data, do
//
//     final camionModel = camionModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

CamionModel camionModelFromJson(String str) => CamionModel.fromJson(json.decode(str));

String camionModelToJson(CamionModel data) => json.encode(data.toJson());

class CamionModel {
    bool success;
    String messages;
    List<Camiones> camiones;

    CamionModel({
        required this.success,
        required this.messages,
        required this.camiones,
    });

    factory CamionModel.fromJson(Map<String, dynamic> json) => CamionModel(
        success: json["success"],
        messages: json["messages"],
        camiones: List<Camiones>.from(json["camiones"].map((x) => Camiones.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "messages": messages,
        "camiones": List<dynamic>.from(camiones.map((x) => x.toJson())),
    };
}

class Camiones {
    int? id;
    String? clave;
    String? tipo;
    String? largo;
    String? ancho;
    String? altura;
    String? capacidad;
    String? inspeccionMecanica;
    String? propietario;

    Camiones({
        this.id,
        this.clave,
        this.tipo,
        this.largo,
        this.ancho,
        this.altura,
        this.capacidad,
        this.inspeccionMecanica,
        this.propietario,
    });

    factory Camiones.fromJson(Map<String, dynamic> json) => Camiones(
        id: json["id"] ?? 0,
        clave: json["clave"] ?? '',
        tipo: json["tipo"] ?? '',
        largo: json["largo"] ?? 0,
        ancho: json["ancho"] ?? 0,
        altura: json["altura"] ?? 0,
        capacidad: json["capacidad"] ?? 0,
        inspeccionMecanica: json["inspeccion_mecanica"] ?? '',
        propietario: json["propietario"] ?? '',
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "clave": clave,
        "tipo": tipo,
        "largo": largo,
        "ancho": ancho,
        "altura": altura,
        "capacidad": capacidad,
        "inspeccion_mecanica": inspeccionMecanica,
        "propietario": propietario,
    };
}
