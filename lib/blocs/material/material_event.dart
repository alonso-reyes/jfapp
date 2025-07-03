abstract class MaterialEvent {}

class MaterialInStartRequest extends MaterialEvent {
  //final Map<String, String> params;
  final String token;
  final int obraId;

  MaterialInStartRequest({required this.token, required this.obraId});
}
