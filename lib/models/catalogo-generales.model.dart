// To parse this JSON data, do
//
//     final catalogoGeneralesModel = catalogoGeneralesModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

CatalogoGeneralesModel catalogoGeneralesModelFromJson(String str) =>
    CatalogoGeneralesModel.fromJson(json.decode(str));

String catalogoGeneralesModelToJson(CatalogoGeneralesModel data) =>
    json.encode(data.toJson());

class CatalogoGeneralesModel {
  bool success;
  String messages;
  CatalogoGenerales catalogoGenerales;

  CatalogoGeneralesModel({
    required this.success,
    required this.messages,
    required this.catalogoGenerales,
  });

  factory CatalogoGeneralesModel.fromJson(Map<String, dynamic> json) =>
      CatalogoGeneralesModel(
        success: json["success"],
        messages: json["messages"],
        catalogoGenerales:
            CatalogoGenerales.fromJson(json["catalogo_generales"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "messages": messages,
        "catalogo_generales": catalogoGenerales.toJson(),
      };
}

class CatalogoGenerales {
  Obra obra;
  List<Turno> turnos;
  List<Zona> zonas;

  CatalogoGenerales({
    required this.obra,
    required this.turnos,
    required this.zonas,
  });

  factory CatalogoGenerales.fromJson(Map<String, dynamic> json) =>
      CatalogoGenerales(
        obra: Obra.fromJson(json["obra"]),
        turnos: List<Turno>.from(json["turnos"].map((x) => Turno.fromJson(x))),
        zonas: List<Zona>.from(json["zonas"].map((x) => Zona.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "obra": obra.toJson(),
        "turnos": List<dynamic>.from(turnos.map((x) => x.toJson())),
        "zonas": List<dynamic>.from(zonas.map((x) => x.toJson())),
      };
}

class Obra {
  String clave;
  String nombre;
  String contrato;
  String ubicacion;
  String descripcion;

  Obra({
    required this.clave,
    required this.nombre,
    required this.contrato,
    required this.ubicacion,
    required this.descripcion,
  });

  factory Obra.fromJson(Map<String, dynamic> json) => Obra(
        clave: json["clave"],
        nombre: json["nombre"],
        contrato: json["contrato"],
        ubicacion: json["ubicacion"],
        descripcion: json["descripcion"],
      );

  Map<String, dynamic> toJson() => {
        "clave": clave,
        "nombre": nombre,
        "contrato": contrato,
        "ubicacion": ubicacion,
        "descripcion": descripcion,
      };
}

class Turno {
  int id;
  String turno;
  String horaEntrada;
  String horaSalida;

  Turno({
    required this.id,
    required this.turno,
    required this.horaEntrada,
    required this.horaSalida,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Turno && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory Turno.fromJson(Map<String, dynamic> json) => Turno(
        id: json["id"],
        turno: json["turno"],
        horaEntrada: json["hora_entrada"],
        horaSalida: json["hora_salida"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "turno": turno,
        "hora_entrada": horaEntrada,
        "hora_salida": horaSalida,
      };
}

class Zona {
  int id;
  String clave;
  String nombre;
  String descripcion;
  int obraId;
  String imagenUrl;

  Zona({
    required this.id,
    required this.clave,
    required this.nombre,
    required this.descripcion,
    required this.obraId,
    required this.imagenUrl,
  });

  factory Zona.fromJson(Map<String, dynamic> json) => Zona(
        id: json["id"],
        clave: json["clave"],
        nombre: json["nombre"],
        descripcion: json["descripcion"],
        obraId: json["obra_id"],
        imagenUrl: json["imagen_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "clave": clave,
        "nombre": nombre,
        "descripcion": descripcion,
        "obra_id": obraId,
        "imagen_url": imagenUrl,
      };
}
