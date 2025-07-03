import 'package:jfapp/models/zonas-trabajo.model.dart';

abstract class ZonaTrabajoState {}

class ZonaTrabajoInitial extends ZonaTrabajoState {}

class ZonaTrabajoLoading extends ZonaTrabajoState {}

class ZonaTrabajoSuccess extends ZonaTrabajoState {
  final ZonasTrabajoModel zonaTrabajo;

  ZonaTrabajoSuccess({required this.zonaTrabajo});
}

class ZonaTrabajoNoSuccess extends ZonaTrabajoState {
  final ZonasTrabajoModel zonaTrabajo;

  ZonaTrabajoNoSuccess({required this.zonaTrabajo});
}

class ZonaTrabajoFailure extends ZonaTrabajoState {
  final String error;

  ZonaTrabajoFailure(this.error);
}
