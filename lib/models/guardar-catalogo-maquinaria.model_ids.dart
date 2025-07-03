import 'dart:convert';

import 'package:jfapp/models/catalogo-maquinaria.model.dart';
import 'package:jfapp/models/concepto.model.dart';

class GuardarCatalogoMaquinariaIDModel {
  final int? conceptoId;
  final int? familiaId;
  final int? maquinariaId;
  final int? operadorId;
  final Horometro? horometro;

  GuardarCatalogoMaquinariaIDModel({
    required this.conceptoId,
    required this.familiaId,
    required this.maquinariaId,
    required this.operadorId,
    required this.horometro,
  });

  Map<String, dynamic> toMap() {
    return {
      'concepto_id': conceptoId,
      'familia_id': familiaId,
      'maquinaria_id': maquinariaId,
      'operador_id': operadorId,
      'horometro': horometro?.toJson(),
    };
  }

  // Convierte el objeto a String
  @override
  String toString() {
    return jsonEncode({
      'concepto_id': conceptoId,
      'familia_id': familiaId,
      'maquinaria_id': maquinariaId,
      'operador_id': operadorId,
      'horometro': horometro?.toJson(),
    });
  }

  // Convierte un String a objeto
  factory GuardarCatalogoMaquinariaIDModel.fromString(String str) {
    final Map<String, dynamic> data = jsonDecode(str);
    return GuardarCatalogoMaquinariaIDModel(
      conceptoId: data['concepto_id'],
      familiaId: data['familia_id'],
      maquinariaId: data['maquinaria_id'],
      operadorId: data['operador_id'],
      horometro: Horometro.fromJson(data['horometro']),
    );
  }
}
