import 'package:jfapp/models/destino.model.dart';

abstract class DestinoState {}

class DestinoInitial extends DestinoState {}

class DestinoLoading extends DestinoState {}

class DestinoSuccess extends DestinoState {
  final DestinosModel destino;

  DestinoSuccess({required this.destino});
}

class DestinoNoSuccess extends DestinoState {
  final DestinosModel destino;

  DestinoNoSuccess({required this.destino});
}

class DestinoFailure extends DestinoState {
  final String error;

  DestinoFailure(this.error);
}
