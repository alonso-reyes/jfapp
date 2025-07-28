import 'dart:convert';

import 'package:jfapp/models/catalogos-agua.model.dart';
import 'package:jfapp/models/pipas.model.dart';

class AcarreoAgua {
  final Pipas? pipa;
  final Origenes? origen;
  final Destinos? destino;
  final int viajes;
  final double capacidad;
  final double volumen;
  final String? observaciones;

  AcarreoAgua({
    required this.pipa,
    required this.origen,
    required this.destino,
    required this.viajes,
    required this.capacidad,
    required this.volumen,
    this.observaciones,
  });

  Map<String, dynamic> toMap() {
    return {
      'pipa': pipa?.toJson(),
      'origen': origen?.toJson(),
      'destino': destino?.toJson(),
      'viajes': viajes,
      'capacidad': capacidad,
      'volumen': volumen,
      'observaciones': observaciones,
    };
  }

  @override
  String toString() {
    return jsonEncode({
      'pipa': pipa?.toJson(),
      'origen': origen?.toJson(),
      'destino': destino?.toJson(),
      'viajes': viajes,
      'capacidad': capacidad,
      'volumen': volumen,
      'observaciones': observaciones,
    });
  }

  // Convierte un String a objeto
  factory AcarreoAgua.fromString(String str) {
    final Map<String, dynamic> data = jsonDecode(str);
    return AcarreoAgua(
      pipa: Pipas.fromJson(data['pipa']),
      origen: Origenes.fromJson(data['origen']),
      destino: Destinos.fromJson(data['destino']),
      viajes: data['viajes'],
      capacidad: data['capacidad'],
      volumen: data['volumen'],
      observaciones: data['observaciones'],
    );
  }
}
