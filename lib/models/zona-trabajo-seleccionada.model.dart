import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ZonaTrabajoSeleccionada {
  int id;
  String clave;
  List<DrawingPath> dibujos; // Lista de trazos realizados
  String? imagenDibujadaBase64;

  ZonaTrabajoSeleccionada({
    required this.id,
    required this.clave,
    this.dibujos = const [],
    this.imagenDibujadaBase64,
  });

  factory ZonaTrabajoSeleccionada.fromJson(String str) =>
      ZonaTrabajoSeleccionada.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
        'id': id,
        'clave': clave,
        'dibujos': dibujos.map((d) => d.toMap()).toList(),
        'imagen_dibujada': imagenDibujadaBase64,
      };

  factory ZonaTrabajoSeleccionada.fromMap(Map<String, dynamic> map) {
    return ZonaTrabajoSeleccionada(
      id: map['id'],
      clave: map['clave'],
      dibujos: map['dibujos'] != null
          ? List<DrawingPath>.from(
              map['dibujos'].map((x) => DrawingPath.fromMap(x)))
          : [],
      imagenDibujadaBase64: map['imagen_dibujada'],
    );
  }
  // Método para agregar un nuevo dibujo
  void agregarDibujo(DrawingPath dibujo) {
    dibujos.add(dibujo);
  }

  // Método para limpiar todos los dibujos
  void limpiarDibujos() {
    dibujos.clear();
  }
}

class DrawingPath {
  final List<Offset> puntos;
  final Color color;
  final double grosor;

  DrawingPath({
    required this.puntos,
    this.color = Colors.red,
    this.grosor = 4.0,
  });

  factory DrawingPath.fromMap(Map<String, dynamic> map) {
    return DrawingPath(
      puntos: List<Offset>.from(
          map['puntos'].map((p) => Offset(p['x'] as double, p['y'] as double))),
      color: Color(map['color'] as int),
      grosor: map['grosor'] as double,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'puntos': puntos.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
      'color': color.value,
      'grosor': grosor,
    };
  }
}
