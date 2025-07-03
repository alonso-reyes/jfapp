abstract class DestinoEvent {}

class DestinoInStartRequest extends DestinoEvent {
  //final Map<String, String> params;
  final String token;
  final int obraId;

  DestinoInStartRequest({required this.token, required this.obraId});
}
