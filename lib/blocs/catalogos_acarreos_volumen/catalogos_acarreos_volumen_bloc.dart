import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/catalogos_acarreos_volumen/catalogos_acarreos_volumen_event.dart';
import 'package:jfapp/blocs/catalogos_acarreos_volumen/catalogos_acarreos_volumen_state.dart';
import 'package:jfapp/helpers/api/api-helper.dart';
import 'package:jfapp/models/catalogos-volumen.model.dart';
import 'dart:developer' as dev;
import 'package:jfapp/providers/preference_provider.dart';

class CatalogosAcarreosVolumenBloc
    extends Bloc<CatalogosAcarreosVolumenEvent, CatalogosAcarreosVolumenState> {
  CatalogosAcarreosVolumenBloc() : super(CatalogosAcarreosVolumenInitial()) {
    on<CatalogosAcarreosVolumenInStartRequest>((event, emit) async {
      emit(CatalogosAcarreosVolumenLoading());
      final response =
          await getCatalogosAcarreoVolumen(event.token, event.obraId);
      //dev.log('Respuesta del CatalogosAcarreosVolumen: $response');
      //return;
      if (response != null && response is CatalogosVolumenModel) {
        if (response.success) {
          emit(CatalogosAcarreosVolumenSuccess(catalogoVolumen: response));
        } else {
          emit(CatalogosAcarreosVolumenFailure(response.messages));
        }
      } else {
        emit(CatalogosAcarreosVolumenFailure(
            'Error al procesar la respuesta del servidor'));
      }
    });
  }
}
