import 'package:jfapp/models/catalogo-motivos-inactividad-maquinaria.model.dart';

abstract class CatalogoMotivosInactvidadMaquinariaState {}

class CatalogoMotivosInactvidadMaquinariaInitial
    extends CatalogoMotivosInactvidadMaquinariaState {}

class CatalogoMotivosInactvidadMaquinariaLoading
    extends CatalogoMotivosInactvidadMaquinariaState {}

class CatalogoMotivosInactvidadMaquinariaSuccess
    extends CatalogoMotivosInactvidadMaquinariaState {
  final MotivosInactividadMaquinariaModel motivoInactividad;

  CatalogoMotivosInactvidadMaquinariaSuccess({required this.motivoInactividad});
}

class CatalogoMotivosInactvidadMaquinariaNoSuccess
    extends CatalogoMotivosInactvidadMaquinariaState {
  final MotivosInactividadMaquinariaModel motivoInactividad;

  CatalogoMotivosInactvidadMaquinariaNoSuccess(
      {required this.motivoInactividad});
}

class CatalogoMotivosInactvidadMaquinariaFailure
    extends CatalogoMotivosInactvidadMaquinariaState {
  final String error;

  CatalogoMotivosInactvidadMaquinariaFailure(this.error);
}
