import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/pipas/pipas_event.dart';
import 'package:jfapp/blocs/pipas/pipas_state.dart';
import 'package:jfapp/helpers/api/api-helper.dart';
import 'package:jfapp/models/pipas.model.dart';
import 'dart:developer' as dev;
import 'package:jfapp/providers/preference_provider.dart';

class PipasBloc extends Bloc<PipasEvent, PipasState> {
  PipasBloc() : super(PipasInitial()) {
    on<PipasInStartRequest>((event, emit) async {
      emit(PipasLoading());
      final response = await getCatalogosPipas(event.token, event.obraId);
      //dev.log('Respuesta del Pipas: $response');
      //return;
      if (response != null && response is PipasModel) {
        if (response.success) {
          emit(PipasSuccess(pipa: response));
        } else {
          emit(PipasFailure(response.messages));
        }
      } else {
        emit(PipasFailure('Error al procesar la respuesta del servidor'));
      }
    });
  }
}
