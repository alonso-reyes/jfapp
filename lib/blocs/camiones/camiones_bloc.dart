import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/camiones/camiones_event.dart';
import 'package:jfapp/blocs/camiones/camiones_state.dart';
import 'package:jfapp/helpers/api/api-helper.dart';
import 'package:jfapp/models/camiones.model.dart';
import 'dart:developer' as dev;
import 'package:jfapp/providers/preference_provider.dart';

class CamionesBloc extends Bloc<CamionesEvent, CamionesState> {
  CamionesBloc() : super(CamionesInitial()) {
    on<CamionesInStartRequest>((event, emit) async {
      emit(CamionesLoading());
      final response = await getCamiones(event.token, event.obraId);
      //dev.log('Respuesta del Camiones: $response');
      //return;
      if (response != null && response is CamionModel) {
        if (response.success) {
          emit(CamionesSuccess(camion: response));
        } else {
          emit(CamionesFailure(response.messages));
        }
      } else {
        emit(CamionesFailure('Error al procesar la respuesta del servidor'));
      }
    });
  }
}
