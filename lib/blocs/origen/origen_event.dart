abstract class OrigenEvent {}

class OrigenInStartRequest extends OrigenEvent {
  //final Map<String, String> params;
  final String token;
  final int obraId;

  OrigenInStartRequest({required this.token, required this.obraId});
}
