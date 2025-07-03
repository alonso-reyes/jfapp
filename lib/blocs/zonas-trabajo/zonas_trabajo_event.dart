abstract class ZonaTrabajoEvent {}

class ZonaTrabajoInStartRequest extends ZonaTrabajoEvent {
  //final Map<String, String> params;
  final String token;
  final int obraId;

  ZonaTrabajoInStartRequest({required this.token, required this.obraId});
}
