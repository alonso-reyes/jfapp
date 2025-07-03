abstract class GeneralesEvent {}

class GeneralesInStartRequest extends GeneralesEvent {
  //final Map<String, String> params;
  final String token;
  final int obraId;

  GeneralesInStartRequest({required this.token, required this.obraId});
}
