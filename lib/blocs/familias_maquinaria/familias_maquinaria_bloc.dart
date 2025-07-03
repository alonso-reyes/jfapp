import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/familias_maquinaria/familias_maquinaria_event.dart';
import 'package:jfapp/blocs/familias_maquinaria/familias_maquinaria_state.dart';

import 'package:jfapp/helpers/api/api-helper.dart';
import 'package:jfapp/models/catalogo-maquinaria.model.dart';
import 'dart:developer' as dev;
import 'package:jfapp/providers/model_provider.dart';

class FamiliaMaquinariaBloc
    extends Bloc<FamiliaMaquinariaEvent, FamiliaMaquinariaState> {
  FamiliaMaquinariaBloc() : super(FamiliaMaquinariaInitial()) {
    on<FamiliaMaquinariaInStartRequest>((event, emit) async {
      emit(FamiliaMaquinariaLoading());
      final response = await getFamiliasMaquinaria(event.token, event.obraId);
      //dev.log('Respuesta del FamiliaMaquinaria: $response');
      //return;
      if (response != null && response is CatalogoMaquinariaResponse) {
        await ModelProvider.guardarCatalogoMaquinaria(response);
        if (response.success) {
          emit(FamiliaMaquinariaSuccess(catalogoMaquinaria: response));
        } else {
          emit(FamiliaMaquinariaFailure(response.messages));
        }
      } else {
        emit(FamiliaMaquinariaFailure(
            'Error al procesar la respuesta del servidor'));
      }
    });
  }
}
