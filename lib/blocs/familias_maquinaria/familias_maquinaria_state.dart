import 'package:jfapp/models/catalogo-maquinaria.model.dart';

abstract class FamiliaMaquinariaState {}

class FamiliaMaquinariaInitial extends FamiliaMaquinariaState {}

class FamiliaMaquinariaLoading extends FamiliaMaquinariaState {}

class FamiliaMaquinariaSuccess extends FamiliaMaquinariaState {
  final CatalogoMaquinariaResponse catalogoMaquinaria;

  FamiliaMaquinariaSuccess({required this.catalogoMaquinaria});
}

class FamiliaMaquinariaNoSuccess extends FamiliaMaquinariaState {
  final CatalogoMaquinariaResponse catalogoMaquinaria;

  FamiliaMaquinariaNoSuccess({required this.catalogoMaquinaria});
}

class FamiliaMaquinariaFailure extends FamiliaMaquinariaState {
  final String error;

  FamiliaMaquinariaFailure(this.error);
}
