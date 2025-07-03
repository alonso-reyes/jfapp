import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/reporte_diario_whatsapp/reporte_diario_wa_event.dart';
import 'package:jfapp/blocs/reporte_diario_whatsapp/reporte_diario_wa_state.dart';
import 'package:jfapp/helpers/api/api-helper.dart';
import 'package:jfapp/models/reporte-diario-wa.model.dart';
import 'dart:developer' as dev;

import 'package:jfapp/providers/model_provider.dart';

class ReporteDiarioWaBloc
    extends Bloc<ReporteDiarioWaEvent, ReporteDiarioWaState> {
  ReporteDiarioWaBloc() : super(ReporteDiarioWaInitial()) {
    on<ReporteDiarioWaInStartRequest>((event, emit) async {
      emit(ReporteDiarioWaLoading());
      final response =
          await getReporteDiarioWhatsapp(event.token, event.obraId);
      //dev.log('Respuesta del ReporteDiarioWa: $response');
      //return;
      if (response != null && response is ReporteDiarioWaModel) {
        await ModelProvider.guardarCatalogoReporteDiarioWa(response);
        if (response.success) {
          emit(ReporteDiarioWaSuccess(reporte: response));
        } else {
          emit(ReporteDiarioWaFailure(response.messages));
        }
      } else {
        emit(ReporteDiarioWaFailure(
            'Error al procesar la respuesta del servidor'));
      }
    });
  }
}
