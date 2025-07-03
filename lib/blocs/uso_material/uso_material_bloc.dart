import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/uso_material/uso_material_event.dart';
import 'package:jfapp/blocs/uso_material/uso_material_state.dart';

import 'package:jfapp/helpers/api/api-helper.dart';
import 'package:jfapp/models/uso-material.model.dart';

import 'dart:developer' as dev;
import 'package:jfapp/providers/preference_provider.dart';

class UsoMaterialBloc extends Bloc<UsoMaterialEvent, UsoUsoMaterialState> {
  UsoMaterialBloc() : super(UsoMaterialInitial()) {
    on<UsoMaterialInStartRequest>((event, emit) async {
      emit(UsoMaterialLoading());
      final response = await getUsoMaterial(event.token, event.obraId);
      //dev.log('Respuesta del UsoMaterial: $response');
      //return;
      if (response != null && response is UsoMaterialModel) {
        if (response.success) {
          emit(UsoMaterialSuccess(usoMaterial: response));
        } else {
          emit(UsoMaterialFailure(response.messages));
        }
      } else {
        emit(UsoMaterialFailure('Error al procesar la respuesta del servidor'));
      }
    });
  }
}
