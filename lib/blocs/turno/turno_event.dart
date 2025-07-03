abstract class TurnoEvent {}

class TurnoInStartRequest extends TurnoEvent {
  //final Map<String, String> params;
  final String token;
  final int obraId;

  TurnoInStartRequest({required this.token, required this.obraId});
}
