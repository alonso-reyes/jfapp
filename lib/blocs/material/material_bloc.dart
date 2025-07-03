import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/material/material_event.dart';
import 'package:jfapp/blocs/material/material_state.dart';
import 'package:jfapp/helpers/api/api-helper.dart';
import 'package:jfapp/models/material.model.dart';
import 'dart:developer' as dev;
import 'package:jfapp/providers/preference_provider.dart';

class MaterialBloc extends Bloc<MaterialEvent, MaterialSt> {
  MaterialBloc() : super(MaterialInitial()) {
    on<MaterialInStartRequest>((event, emit) async {
      emit(MaterialLoading());
      final response = await getMaterial(event.token, event.obraId);
      //dev.log('Respuesta del Material: $response');
      //return;
      if (response != null && response is MaterialModel) {
        if (response.success) {
          emit(MaterialSuccess(material: response));
        } else {
          emit(MaterialFailure(response.messages));
        }
      } else {
        emit(MaterialFailure('Error al procesar la respuesta del servidor'));
      }
    });
  }
}
