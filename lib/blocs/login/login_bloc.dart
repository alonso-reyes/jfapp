import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/login/login_event.dart';
import 'package:jfapp/blocs/login/login_state.dart';
import 'package:jfapp/helpers/api/api-helper.dart';
import 'package:jfapp/helpers/session_manager.dart';
import 'dart:developer' as dev;

import 'package:jfapp/models/user.model.dart';
import 'package:jfapp/providers/preference_provider.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());
      final response = await login(event.username, event.password);
      dev.log('Respuesta del login: $response');
      //return;
      if (response != null && response is UserModel) {
        //print('entro aqui');
        if (response.success) {
          await SessionManager.saveUser(response);
          // PreferenceProvider.user = jsonEncode(response);
          // PreferenceProvider.user = jsonEncode(response.user);
          //dev.log("Usuario guardado: ${PreferenceProvider.user}");
          emit(LoginSuccess(user: response));
        } else {
          emit(LoginFailure(response.messages.toString()));
        }
      } else if (response != null && response is String) {
        LoginFailure('Server error');
      }
    });

    // on<LogoutSubmitted>((event, emit) async {
    //   emit(LoginLoading()); // Emitimos el estado de carga inicial

    //   try {
    //     final response = await logout(event.token);
    //     if (response != null && response is UserModel) {
    //       if (response.success) {
    //         print('Logout exitoso');
    //         emit(LogoutSuccess(response.messages.toString())); // Emitimos éxito
    //       } else {
    //         emit(LogoutFailure(response.messages.toString())); // Emitimos fallo
    //       }
    //     } else {
    //       emit(LogoutFailure('Error al procesar la respuesta del servidor'));
    //     }
    //   } catch (e) {
    //     emit(LogoutFailure(
    //         'Error: ${e.toString()}')); // Manejamos errores inesperados
    //   }
    // });
  }
}
