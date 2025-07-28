import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/catalogo_motivos_inactividad_maquinaria/catalogo_motivos_inactividad_maquinaria_event.dart';
import 'package:jfapp/blocs/catalogo_motivos_inactividad_maquinaria/catalogo_motivos_inactividad_maquinaria_state.dart';
import 'package:jfapp/helpers/api/api-helper.dart';
import 'package:jfapp/models/catalogo-motivos-inactividad-maquinaria.model.dart';
import 'dart:developer' as dev;
import 'package:jfapp/providers/preference_provider.dart';

class CatalogoMotivosInactvidadMaquinariaBloc extends Bloc<
    CatalogoMotivosInactvidadMaquinariaEvent,
    CatalogoMotivosInactvidadMaquinariaState> {
  CatalogoMotivosInactvidadMaquinariaBloc()
      : super(CatalogoMotivosInactvidadMaquinariaInitial()) {
    on<CatalogoMotivosInactvidadMaquinariaInStartRequest>((event, emit) async {
      emit(CatalogoMotivosInactvidadMaquinariaLoading());
      final response =
          await getCatalogoInactividadMaquinaria(event.token, event.obraId);
      //dev.log('Respuesta del CatalogoMotivosInactvidadMaquinaria: $response');
      //return;
      if (response != null && response is MotivosInactividadMaquinariaModel) {
        if (response.success) {
          emit(CatalogoMotivosInactvidadMaquinariaSuccess(
              motivoInactividad: response));
        } else {
          emit(CatalogoMotivosInactvidadMaquinariaFailure(response.messages));
        }
      } else {
        emit(CatalogoMotivosInactvidadMaquinariaFailure(
            'Error al procesar la respuesta del servidor'));
      }
    });
  }
}
