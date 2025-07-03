import 'dart:convert';

class TurnoSeleccionado {
  int id;
  String turno;
  String horaRealEntrada;
  String horaRealSalida;

  TurnoSeleccionado({
    required this.id,
    required this.turno,
    required this.horaRealEntrada,
    required this.horaRealSalida,
  });

  factory TurnoSeleccionado.fromJson(String str) =>
      TurnoSeleccionado.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TurnoSeleccionado.fromMap(Map<String, dynamic> json) =>
      TurnoSeleccionado(
        id: json["id"],
        turno: json["turno"],
        horaRealEntrada: json["hora_real_entrada"],
        horaRealSalida: json["hora_real_salida"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "turno": turno,
        "hora_real_entrada": horaRealEntrada,
        "hora_real_salida": horaRealSalida,
      };
}
