abstract class PipasEvent {}

class PipasInStartRequest extends PipasEvent {
  //final Map<String, String> params;
  final String token;
  final int obraId;

  PipasInStartRequest({required this.token, required this.obraId});
}
