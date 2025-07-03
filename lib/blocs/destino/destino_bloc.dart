import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/destino/destino_event.dart';
import 'package:jfapp/blocs/destino/destino_state.dart';
import 'package:jfapp/helpers/api/api-helper.dart';
import 'package:jfapp/models/destino.model.dart';
import 'dart:developer' as dev;
import 'package:jfapp/providers/preference_provider.dart';

class DestinoBloc extends Bloc<DestinoEvent, DestinoState> {
  DestinoBloc() : super(DestinoInitial()) {
    on<DestinoInStartRequest>((event, emit) async {
      emit(DestinoLoading());
      final response = await getDestinos(event.token, event.obraId);
      //dev.log('Respuesta del Destino: $response');
      //return;
      if (response != null && response is DestinosModel) {
        if (response.success) {
          emit(DestinoSuccess(destino: response));
        } else {
          emit(DestinoFailure(response.messages));
        }
      } else {
        emit(DestinoFailure('Error al procesar la respuesta del servidor'));
      }
    });
  }
}
