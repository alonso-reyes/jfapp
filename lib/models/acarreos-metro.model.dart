import 'dart:convert';

class AcarreoMetro {
  final double largo;
  // final int viajes;
  final String? observaciones;

  AcarreoMetro({
    required this.largo,
    // required this.viajes,
    this.observaciones,
  });

  Map<String, dynamic> toMap() {
    return {
      'largo': largo,
      // 'viajes': viajes,
      'observaciones': observaciones,
    };
  }

  @override
  String toString() {
    return jsonEncode({
      'largo': largo,
      // 'viajes': viajes,
      'observaciones': observaciones,
    });
  }

  // Convierte un String a objeto
  factory AcarreoMetro.fromString(String str) {
    final Map<String, dynamic> data = jsonDecode(str);
    return AcarreoMetro(
      largo: data['largo'],
      // viajes: data['viajes'],
      observaciones: data['observaciones'],
    );
  }
}
