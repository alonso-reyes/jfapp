import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev;

import 'package:jfapp/blocs/zonas-trabajo/zonas_trabajo_event.dart';
import 'package:jfapp/blocs/zonas-trabajo/zonas_trabajo_state.dart';
import 'package:jfapp/helpers/api/api-helper.dart';
import 'package:jfapp/models/zonas-trabajo.model.dart';
import 'package:jfapp/providers/model_provider.dart';

class ZonaTrabajoBloc extends Bloc<ZonaTrabajoEvent, ZonaTrabajoState> {
  ZonaTrabajoBloc() : super(ZonaTrabajoInitial()) {
    on<ZonaTrabajoInStartRequest>((event, emit) async {
      emit(ZonaTrabajoLoading());
      final response = await getZonasTrabajo(event.token, event.obraId);
      //dev.log('Respuesta del ZonaTrabajo: $response');
      //return;
      if (response != null && response is ZonasTrabajoModel) {
        await ModelProvider.guardarCatalogoZonaTrabajo(response);
        if (response.success) {
          emit(ZonaTrabajoSuccess(zonaTrabajo: response));
        } else {
          emit(ZonaTrabajoFailure(response.messages));
        }
      } else {
        emit(ZonaTrabajoFailure('Error al procesar la respuesta del servidor'));
      }
    });
  }
}
