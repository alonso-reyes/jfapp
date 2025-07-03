import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/logout/logout_event.dart';
import 'package:jfapp/blocs/logout/logout_state.dart';
import 'package:jfapp/helpers/api/api-helper.dart';
import 'dart:developer' as dev;

import 'package:jfapp/models/user.model.dart';
import 'package:jfapp/providers/preference_provider.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  LogoutBloc() : super(LogoutInitial()) {
    on<LogoutSubmitted>((event, emit) async {
      emit(LogoutLoading()); // Emitimos el estado de carga inicial

      try {
        final response = await logout(event.token);
        if (response != null && response is UserModel) {
          if (response.success) {
            print('Logout exitoso');
            emit(LogoutSuccess(response.messages.toString())); // Emitimos éxito
          } else {
            emit(LogoutFailure(response.messages.toString())); // Emitimos fallo
          }
        } else {
          emit(LogoutFailure('Error al procesar la respuesta del servidor'));
        }
      } catch (e) {
        emit(LogoutFailure(
            'Error: ${e.toString()}')); // Manejamos errores inesperados
      }
    });
  }
}
