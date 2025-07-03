import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/Obra/obra_event.dart';
import 'package:jfapp/blocs/Obra/obra_state.dart';
import 'package:jfapp/helpers/api/api-helper.dart';
import 'package:jfapp/models/obra.model.dart';
import 'dart:developer' as dev;
import 'package:jfapp/providers/preference_provider.dart';

class ObraBloc extends Bloc<ObraEvent, ObraState> {
  ObraBloc() : super(ObraInitial()) {
    on<ObraInStartRequest>((event, emit) async {
      emit(ObraLoading());
      final Map<String, String> params;
      final response = await getObra(event.token, event.obraId);
      // dev.log('Respuesta del Obra: $response');
      //return;
      if (response != null && response is ObraModel) {
        //PreferenceProvider.obra = jsonEncode(response.obra);
        //print('entro aqui');
        if (response.success) {
          emit(ObraSuccess(obra: response));
        } else {
          emit(ObraFailure(response.messages.toString()));
        }
      } else if (response != null && response is String) {
        ObraFailure('Server error');
      }
    });
  }
}
