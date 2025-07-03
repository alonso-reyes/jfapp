import 'dart:convert';

class AcarreoArea {
  final double largo;
  final double ancho;
  final double area;
  // final int viajes;
  final String? observaciones;

  AcarreoArea({
    required this.largo,
    required this.ancho,
    required this.area,
    // required this.viajes,
    this.observaciones,
  });

  Map<String, dynamic> toMap() {
    return {
      'largo': largo,
      'ancho': ancho,
      'area': area,
      // 'viajes': viajes,
      'observaciones': observaciones,
    };
  }

  // Convierte el objeto a String
  @override
  String toString() {
    return jsonEncode({
      'largo': largo,
      'ancho': ancho,
      'area': area,
      // 'viajes': viajes,
      'observaciones': observaciones,
    });
  }

  // Convierte un String a objeto
  factory AcarreoArea.fromString(String str) {
    final Map<String, dynamic> data = jsonDecode(str);
    return AcarreoArea(
      largo: data['largo'],
      ancho: data['ancho'],
      area: data['area'],
      // viajes: data['viajes'],
      observaciones: data['observaciones'],
    );
  }
}
