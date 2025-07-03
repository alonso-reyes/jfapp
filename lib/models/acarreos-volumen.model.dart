import 'dart:convert';
import 'package:jfapp/models/catalogos-volumen.model.dart';

class AcarreoVolumen {
  final MateriaL? material;
  final UsosMateriaLes? usoMaterial;
  final Origenes? origen;
  final Destinos? destino;
  //final Camion? camion;
  final TiposCamion? camion;
  final int viajes;
  final double capacidad;
  final double volumen;
  final String? observaciones;

  AcarreoVolumen({
    required this.material,
    required this.usoMaterial,
    required this.origen,
    required this.destino,
    required this.camion,
    required this.viajes,
    required this.capacidad,
    required this.volumen,
    this.observaciones,
  });

  Map<String, dynamic> toMap() {
    return {
      'material': material?.toJson(),
      'usoMaterial': usoMaterial?.toJson(),
      'origen': origen?.toJson(),
      'destino': destino?.toJson(),
      'camion': camion?.toJson(),
      'viajes': viajes,
      'capacidad': capacidad,
      'volumen': volumen,
      'observaciones': observaciones,
    };
  }

  // Convierte el objeto a String
  @override
  String toString() {
    return jsonEncode({
      'material': material?.toJson(),
      'usoMaterial': usoMaterial?.toJson(),
      'origen': origen?.toJson(),
      'destino': destino?.toJson(),
      'camion': camion?.toJson(),
      'viajes': viajes,
      'capacidad': capacidad,
      'volumen': volumen,
      'observaciones': observaciones,
    });
  }

  // Convierte un String a objeto
  factory AcarreoVolumen.fromString(String str) {
    final Map<String, dynamic> data = jsonDecode(str);
    return AcarreoVolumen(
      material: MateriaL.fromJson(data['material']),
      usoMaterial: UsosMateriaLes.fromJson(data['usoMaterial']),
      origen: Origenes.fromJson(data['origen']),
      destino: Destinos.fromJson(data['destino']),
      //camion: Camion.fromJson(data['camion']),
      camion: TiposCamion.fromJson(data['camion']),
      viajes: data['viajes'],
      capacidad: data['capacidad'],
      volumen: data['volumen'],
      observaciones: data['observaciones'],
    );
  }
}
