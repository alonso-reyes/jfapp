import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/personal/personal_event.dart';
import 'package:jfapp/blocs/personal/personal_state.dart';
import 'package:jfapp/helpers/api/api-helper.dart';
import 'package:jfapp/models/catalogo-personal.model.dart';
import 'package:jfapp/providers/model_provider.dart';
import 'dart:developer' as dev;

class CatalogoPersonalBloc
    extends Bloc<CatalogoPersonalEvent, CatalogoPersonalState> {
  CatalogoPersonalBloc() : super(CatalogoPersonalInitial()) {
    on<CatalogoPersonalInStartRequest>((event, emit) async {
      emit(CatalogoPersonalLoading());
      final response = await getCatalogoPersonal(event.token, event.obraId);
      //dev.log('Respuesta del CatalogoPersonal: $response');
      //return;
      if (response != null && response is CatalogoPersonalModel) {
        await ModelProvider.guardarCatalogoPersonal(response);
        if (response.success) {
          emit(CatalogoPersonalSuccess(personal: response));
        } else {
          emit(CatalogoPersonalFailure(response.messages));
        }
      } else {
        emit(CatalogoPersonalFailure(
            'Error al procesar la respuesta del servidor'));
      }
    });
  }
}
