// To parse this JSON data, do
//
//     final catalogosVolumenModel = catalogosVolumenModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

CatalogosVolumenModel catalogosVolumenModelFromJson(String str) =>
    CatalogosVolumenModel.fromJson(json.decode(str));

String catalogosVolumenModelToJson(CatalogosVolumenModel data) =>
    json.encode(data.toJson());

class CatalogosVolumenModel {
  bool success;
  String messages;
  Catalogo catalogo;

  CatalogosVolumenModel({
    required this.success,
    required this.messages,
    required this.catalogo,
  });

  factory CatalogosVolumenModel.fromJson(Map<String, dynamic> json) =>
      CatalogosVolumenModel(
        success: json["success"],
        messages: json["messages"],
        catalogo: Catalogo.fromJson(json["catalogo"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "messages": messages,
        "catalogo": catalogo.toJson(),
      };
}

class Catalogo {
  List<Origenes> origenes;
  List<Destinos> destinos;
  List<MateriaL> materiales;
  List<UsosMateriaLes> usosMateriaL;
  List<Camion> camiones;
  List<TiposCamion> tiposCamion;

  Catalogo(
      {required this.origenes,
      required this.destinos,
      required this.materiales,
      required this.usosMateriaL,
      required this.camiones,
      required this.tiposCamion});

  factory Catalogo.fromJson(Map<String, dynamic> json) => Catalogo(
        origenes: json["origenes"] == null
            ? []
            : List<Origenes>.from(
                json["origenes"].map((x) => Origenes.fromJson(x))),
        destinos: json["destinos"] == null
            ? []
            : List<Destinos>.from(
                json["destinos"].map((x) => Destinos.fromJson(x))),
        materiales: json["materiales"] == null
            ? []
            : List<MateriaL>.from(
                json["materiales"].map((x) => MateriaL.fromJson(x))),
        usosMateriaL: json["usos_material"] == null
            ? []
            : List<UsosMateriaLes>.from(
                json["usos_material"].map((x) => UsosMateriaLes.fromJson(x))),
        camiones: json["camiones"] == null
            ? []
            : List<Camion>.from(
                json["camiones"].map((x) => Camion.fromJson(x))),
        tiposCamion: json["tipos_camion"] == null
            ? []
            : List<TiposCamion>.from(
                json["tipos_camion"].map((x) => TiposCamion.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "origenes": List<dynamic>.from(origenes.map((x) => x.toJson())),
        "destinos": List<dynamic>.from(destinos.map((x) => x.toJson())),
        "materiales": List<dynamic>.from(materiales.map((x) => x.toJson())),
        "usos_material":
            List<dynamic>.from(usosMateriaL.map((x) => x.toJson())),
        "camiones": List<dynamic>.from(camiones.map((x) => x.toJson())),
        "tipos_camion": List<dynamic>.from(tiposCamion.map((x) => x.toJson())),
      };
}

class Camion {
  int id;
  String clave;
  String tipo;
  String largo;
  String ancho;
  String altura;
  String capacidad;
  String? inspeccionMecanica;
  String propietario;

  Camion({
    required this.id,
    required this.clave,
    required this.tipo,
    required this.largo,
    required this.ancho,
    required this.altura,
    required this.capacidad,
    this.inspeccionMecanica,
    required this.propietario,
  });

  factory Camion.fromJson(Map<String, dynamic> json) => Camion(
        id: json["id"],
        clave: json["clave"],
        tipo: json["tipo"],
        largo: json["largo"],
        ancho: json["ancho"],
        altura: json["altura"],
        capacidad: json["capacidad"],
        inspeccionMecanica: json["inspeccion_mecanica"] ?? '',
        propietario: json["propietario"],
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

class Destinos {
  int id;
  String destino;

  Destinos({
    required this.id,
    required this.destino,
  });

  factory Destinos.fromJson(Map<String, dynamic> json) => Destinos(
        id: json["id"],
        destino: json["destino"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "destino": destino,
      };
}

class MateriaL {
  int id;
  String material;

  MateriaL({
    required this.id,
    required this.material,
  });

  factory MateriaL.fromJson(Map<String, dynamic> json) => MateriaL(
        id: json["id"],
        material: json["material"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "material": material,
      };
}

class Origenes {
  int id;
  String origen;

  Origenes({
    required this.id,
    required this.origen,
  });

  factory Origenes.fromJson(Map<String, dynamic> json) => Origenes(
        id: json["id"],
        origen: json["origen"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "origen": origen,
      };
}

class UsosMateriaLes {
  int id;
  String uso;

  UsosMateriaLes({
    required this.id,
    required this.uso,
  });

  factory UsosMateriaLes.fromJson(Map<String, dynamic> json) => UsosMateriaLes(
        id: json["id"],
        uso: json["uso"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "uso": uso,
      };
}

class TiposCamion {
  int id;
  String nombre;

  TiposCamion({
    required this.id,
    required this.nombre,
  });

  factory TiposCamion.fromJson(Map<String, dynamic> json) => TiposCamion(
        id: json["id"],
        nombre: json["nombre"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
      };
}
