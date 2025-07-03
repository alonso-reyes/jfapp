// To parse this JSON data, do
//
//     final turnoModel = turnoModelFromJson(jsonString);

import 'dart:convert';

TurnoModel turnoModelFromJson(String str) =>
    TurnoModel.fromJson(json.decode(str));

String turnoModelToJson(TurnoModel data) => json.encode(data.toJson());

class TurnoModel {
  bool success;
  String messages;
  List<Turno>? turnos;

  TurnoModel({
    required this.success,
    required this.messages,
    this.turnos,
  });

  factory TurnoModel.fromJson(Map<String, dynamic> json) => TurnoModel(
        success: json["success"],
        messages: json["messages"],
        turnos: json["turnos"] == null
            ? []
            : List<Turno>.from(json["turnos"]!.map((x) => Turno.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "messages": messages,
        "turnos": turnos == null
            ? []
            : List<dynamic>.from(turnos!.map((x) => x.toJson())),
      };
}

class Turno {
  int? id;
  String? turno;
  String? horaEntrada;
  String? horaSalida;

  Turno({
    this.id,
    this.turno,
    this.horaEntrada,
    this.horaSalida,
  });

  factory Turno.fromJson(Map<String, dynamic> json) => Turno(
        id: json["id"],
        turno: json["turno"],
        horaEntrada: json["hora_entrada"],
        horaSalida: json["hora_salida"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "turno": turno,
        "hora_entrada": horaEntrada,
        "hora_salida": horaSalida,
      };
}
