import 'dart:convert';

class CampoGeneralesSeleccionado {
  String sobrestante;
  String? observaciones;

  CampoGeneralesSeleccionado({
    required this.sobrestante,
    this.observaciones,
  });

  factory CampoGeneralesSeleccionado.fromJson(String str) =>
      CampoGeneralesSeleccionado.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CampoGeneralesSeleccionado.fromMap(Map<String, dynamic> json) =>
      CampoGeneralesSeleccionado(
        sobrestante: json["sobrestante"],
        observaciones: json["observaciones"] ?? '',
      );

  Map<String, dynamic> toMap() => {
        "sobrestante": sobrestante,
        "observaciones": observaciones,
      };
}
