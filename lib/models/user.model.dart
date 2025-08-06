import 'dart:developer';
import 'package:jfapp/providers/preference_provider.dart';
import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel user) => json.encode(user.toJson());

class UserModel {
  UserModel(
      {required this.token,
      this.token_type,
      required this.success,
      this.messages,
      this.user
      // this.minVerIos = 0,
      // this.minVerAndroid = 0,
      });

  String token;
  String? token_type;
  bool success;
  String? messages;
  User? user;
  //List<User>? user;
  // int minVerIos;
  // int minVerAndroid;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: json['token'] ?? '',
      token_type: json['token_type'] ?? '',
      success: json['success'] ?? false,
      messages: json['messages'] ?? '',
      user: json["user"] != null ? User.fromJson(json["user"]) : null,
      //user: List<User>.from(json["user"].map((x) => User.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // "user":
      //     user != null ? List<User>.from(user!.map((x) => x.toJson())) : null,
      'token': token,
      'token_type': token_type,
      'success': success,
      'messages': messages,
      'user': user?.toJson(),

      // 'min_ver_android': minVerAndroid,
      // 'min_ver_ios': minVerIos,
    };
  }
}

class User {
  final int id;
  final String tipoUsuario;
  final String nombre;
  final String? email;
  final int obraId;

  User({
    required this.id,
    required this.tipoUsuario,
    required this.nombre,
    this.email,
    required this.obraId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"] ?? 0,
        tipoUsuario: json["tipo_usuario"] ?? '',
        nombre: json["nombre"] ?? '',
        email: json["email"] ?? '',
        obraId: json["obra_id"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "tipo_usuario": tipoUsuario,
        "nombre": nombre,
        "email": email,
        "obra_id": obraId,
      };
}
