import 'dart:convert';

import 'package:jfapp/blocs/material/material_event.dart';
import 'package:jfapp/models/camiones.model.dart';
import 'package:jfapp/models/destino.model.dart';
import 'package:jfapp/models/material.model.dart';
import 'package:jfapp/models/origen.model.dart';
import 'package:jfapp/models/uso-material.model.dart';

class AcarreiVolumenOLD {
  final Materiales? material;
  final UsosMaterial? usoMaterial;
  final Origen? origen;
  final Destino? destino;
  final Camiones? camion;
  final int viajes;
  final String? observaciones;

  AcarreiVolumenOLD({
    required this.material,
    required this.usoMaterial,
    required this.origen,
    required this.destino,
    required this.camion,
    required this.viajes,
    this.observaciones,
  });

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
      'observaciones': observaciones,
    });
  }

  // Convierte un String a objeto
  factory AcarreiVolumenOLD.fromString(String str) {
    final Map<String, dynamic> data = jsonDecode(str);
    return AcarreiVolumenOLD(
      material: Materiales.fromJson(data['material']),
      usoMaterial: UsosMaterial.fromJson(data['usoMaterial']),
      origen: Origen.fromJson(data['origen']),
      destino: Destino.fromJson(data['destino']),
      camion: Camiones.fromJson(data['camion']),
      viajes: data['viajes'],
      observaciones: data['observaciones'],
    );
  }
}
