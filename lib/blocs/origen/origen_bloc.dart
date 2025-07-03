import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/origen/origen_event.dart';
import 'package:jfapp/blocs/origen/origen_state.dart';
import 'package:jfapp/helpers/api/api-helper.dart';
import 'package:jfapp/models/origen.model.dart';
import 'dart:developer' as dev;
import 'package:jfapp/providers/preference_provider.dart';

class OrigenBloc extends Bloc<OrigenEvent, OrigenState> {
  OrigenBloc() : super(OrigenInitial()) {
    on<OrigenInStartRequest>((event, emit) async {
      emit(OrigenLoading());
      final response = await getOrigenes(event.token, event.obraId);
      //dev.log('Respuesta del Origen: $response');
      //return;
      if (response != null && response is OrigenesModel) {
        if (response.success) {
          emit(OrigenSuccess(origen: response));
        } else {
          emit(OrigenFailure(response.messages));
        }
      } else {
        emit(OrigenFailure('Error al procesar la respuesta del servidor'));
      }
    });
  }
}
