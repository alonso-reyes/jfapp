import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/turno/turno_event.dart';
import 'package:jfapp/blocs/turno/turno_state.dart';
import 'package:jfapp/helpers/api/api-helper.dart';
import 'package:jfapp/models/turno.model.dart';
import 'package:jfapp/providers/model_provider.dart';
import 'dart:developer' as dev;
import 'package:jfapp/providers/preference_provider.dart';

class TurnoBloc extends Bloc<TurnoEvent, TurnoState> {
  TurnoBloc() : super(TurnoInitial()) {
    on<TurnoInStartRequest>((event, emit) async {
      emit(TurnoLoading());
      final response = await getTurno(event.token, event.obraId);
      //dev.log('Respuesta del Turno: $response');
      //return;
      if (response != null && response is TurnoModel) {
        await ModelProvider.guardarCatalogoTurnos(response);
        if (response.success) {
          emit(TurnoSuccess(turno: response));
        } else {
          emit(TurnoFailure(response.messages));
        }
      } else {
        emit(TurnoFailure('Error al procesar la respuesta del servidor'));
      }
    });
  }
}
