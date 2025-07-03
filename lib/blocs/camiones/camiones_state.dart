import 'package:jfapp/models/camiones.model.dart';

abstract class CamionesState {}

class CamionesInitial extends CamionesState {}

class CamionesLoading extends CamionesState {}

class CamionesSuccess extends CamionesState {
  final CamionModel camion;

  CamionesSuccess({required this.camion});
}

class CamionesNoSuccess extends CamionesState {
  final CamionModel camion;

  CamionesNoSuccess({required this.camion});
}

class CamionesFailure extends CamionesState {
  final String error;

  CamionesFailure(this.error);
}
