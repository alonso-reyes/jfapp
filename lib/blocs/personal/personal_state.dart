import 'package:jfapp/models/catalogo-personal.model.dart';

abstract class CatalogoPersonalState {}

class CatalogoPersonalInitial extends CatalogoPersonalState {}

class CatalogoPersonalLoading extends CatalogoPersonalState {}

class CatalogoPersonalSuccess extends CatalogoPersonalState {
  final CatalogoPersonalModel personal;

  CatalogoPersonalSuccess({required this.personal});
}

class CatalogoPersonalNoSuccess extends CatalogoPersonalState {
  final CatalogoPersonalModel personal;

  CatalogoPersonalNoSuccess({required this.personal});
}

class CatalogoPersonalFailure extends CatalogoPersonalState {
  final String error;

  CatalogoPersonalFailure(this.error);
}
