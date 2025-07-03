abstract class ObraEvent {}

class ObraInStartRequest extends ObraEvent {
  //final Map<String, String> params;
  final String token;
  final int obraId;

  ObraInStartRequest({required this.token, required this.obraId});
}
