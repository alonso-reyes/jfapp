import 'package:jfapp/models/reporte-diario-wa.model.dart';

abstract class ReporteDiarioWaState {}

class ReporteDiarioWaInitial extends ReporteDiarioWaState {}

class ReporteDiarioWaLoading extends ReporteDiarioWaState {}

class ReporteDiarioWaSuccess extends ReporteDiarioWaState {
  final ReporteDiarioWaModel reporte;

  ReporteDiarioWaSuccess({required this.reporte});
}

class ReporteDiarioWaNoSuccess extends ReporteDiarioWaState {
  final ReporteDiarioWaModel reporte;

  ReporteDiarioWaNoSuccess({required this.reporte});
}

class ReporteDiarioWaFailure extends ReporteDiarioWaState {
  final String error;

  ReporteDiarioWaFailure(this.error);
}
