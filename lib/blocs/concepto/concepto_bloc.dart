import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/concepto/concepto_event.dart';
import 'package:jfapp/blocs/concepto/concepto_state.dart';
import 'package:jfapp/helpers/api/api-helper.dart';
import 'package:jfapp/models/concepto.model.dart';
import 'package:jfapp/providers/model_provider.dart';
import 'dart:developer' as dev;
import 'package:jfapp/providers/preference_provider.dart';

class ConceptoBloc extends Bloc<ConceptoEvent, ConceptoState> {
  ConceptoBloc() : super(ConceptoInitial()) {
    on<ConceptoInStartRequest>((event, emit) async {
      emit(ConceptoLoading());
      final response = await getConceptos(event.token, event.obraId);
      //dev.log('Respuesta del Concepto: $response');
      //return;
      if (response != null && response is ConceptoModel) {
        await ModelProvider.guardarCatalogoConceptos(response);
        if (response.success) {
          emit(ConceptoSuccess(concepto: response));
        } else {
          emit(ConceptoFailure(response.messages));
        }
      } else {
        emit(ConceptoFailure('Error al procesar la respuesta del servidor'));
      }
    });
  }
}
