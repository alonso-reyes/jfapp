import 'dart:convert';
import 'package:jfapp/models/catalogo-personal.model.dart';

class GuardarCatalogoPersonalModel {
  final Personal? personal;

  GuardarCatalogoPersonalModel({required this.personal});

  factory GuardarCatalogoPersonalModel.fromJson(Map<String, dynamic> json) {
    return GuardarCatalogoPersonalModel(
        personal: json['personal'] != null
            ? Personal.fromJson(json['personal'])
            : null);
  }

  Map<String, dynamic> toMap() {
    return {
      'personal': personal?.toJson(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'personal': personal?.toJson(),
    };
  }

  @override
  String toString() {
    return jsonEncode({
      'personal': personal?.toJson(),
    });
  }

  factory GuardarCatalogoPersonalModel.fromString(String str) {
    final Map<String, dynamic> data = jsonDecode(str);
    return GuardarCatalogoPersonalModel(
      personal: Personal.fromJson(data['personal']),
    );
  }
}
