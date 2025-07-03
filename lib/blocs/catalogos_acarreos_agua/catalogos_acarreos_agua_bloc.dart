import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/catalogos_acarreos_agua/catalogos_acarreos_agua_event.dart';
import 'package:jfapp/blocs/catalogos_acarreos_agua/catalogos_acarreos_agua_state.dart';
import 'package:jfapp/helpers/api/api-helper.dart';
import 'package:jfapp/models/catalogos-agua.model.dart';
import 'dart:developer' as dev;
import 'package:jfapp/providers/preference_provider.dart';

class CatalogosAcarreosAguaBloc
    extends Bloc<CatalogosAcarreosAguaEvent, CatalogosAcarreosAguaState> {
  CatalogosAcarreosAguaBloc() : super(CatalogosAcarreosAguaInitial()) {
    on<CatalogosAcarreosAguaInStartRequest>((event, emit) async {
      emit(CatalogosAcarreosAguaLoading());
      final response = await getCatalogosAcarreoAgua(event.token, event.obraId);
      //dev.log('Respuesta del CatalogosAcarreosAgua: $response');
      //return;
      if (response != null && response is CatalogosAcarreosAguaModel) {
        if (response.success) {
          emit(CatalogosAcarreosAguaSuccess(catalogoAgua: response));
        } else {
          emit(CatalogosAcarreosAguaFailure(response.messages));
        }
      } else {
        emit(CatalogosAcarreosAguaFailure(
            'Error al procesar la respuesta del servidor'));
      }
    });
  }
}
