abstract class CamionesEvent {}

class CamionesInStartRequest extends CamionesEvent {
  //final Map<String, String> params;
  final String token;
  final int obraId;

  CamionesInStartRequest({required this.token, required this.obraId});
}
