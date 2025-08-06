import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/generales/generales_event.dart';
import 'package:jfapp/blocs/generales/generales_state.dart';
import 'package:jfapp/helpers/api/api-helper.dart';
import 'package:jfapp/models/catalogo-generales.model.dart';
import 'dart:developer' as dev;
import 'package:jfapp/providers/model_provider.dart';

class GeneralesBloc extends Bloc<GeneralesEvent, GeneralesState> {
  GeneralesBloc() : super(GeneralesInitial()) {
    on<GeneralesInStartRequest>((event, emit) async {
      emit(GeneralesLoading());
      final response = await getCatalogoGenerales(event.token, event.obraId);
      //return;
      if (response != null && response is CatalogoGeneralesModel) {
        await ModelProvider.guardarCatalogoGenerales(response);
        if (response.success) {
          emit(GeneralesSuccess(catalogoGenerales: response));
        } else {
          emit(GeneralesFailure(response.messages));
        }
      } else {
        emit(GeneralesFailure('Error al procesar la respuesta del servidor'));
      }
    });
  }
}
