abstract class FamiliaMaquinariaEvent {}

class FamiliaMaquinariaInStartRequest extends FamiliaMaquinariaEvent {
  //final Map<String, String> params;
  final String token;
  final int obraId;

  FamiliaMaquinariaInStartRequest({required this.token, required this.obraId});
}
