import 'package:jfapp/models/catalogo-generales.model.dart';

abstract class GeneralesState {}

class GeneralesInitial extends GeneralesState {}

class GeneralesLoading extends GeneralesState {}

class GeneralesSuccess extends GeneralesState {
  final CatalogoGeneralesModel catalogoGenerales;

  GeneralesSuccess({required this.catalogoGenerales});
}

class GeneralesNoSuccess extends GeneralesState {
  final CatalogoGeneralesModel catalogoGenerales;

  GeneralesNoSuccess({required this.catalogoGenerales});
}

class GeneralesFailure extends GeneralesState {
  final String error;

  GeneralesFailure(this.error);
}
