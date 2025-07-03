import 'package:jfapp/models/turno.model.dart';

abstract class TurnoState {}

class TurnoInitial extends TurnoState {}

class TurnoLoading extends TurnoState {}

class TurnoSuccess extends TurnoState {
  final TurnoModel turno;

  TurnoSuccess({required this.turno});
}

class TurnoNoSuccess extends TurnoState {
  final TurnoModel turno;

  TurnoNoSuccess({required this.turno});
}

class TurnoFailure extends TurnoState {
  final String error;

  TurnoFailure(this.error);
}
