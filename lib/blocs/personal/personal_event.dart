abstract class CatalogoPersonalEvent {}

class CatalogoPersonalInStartRequest extends CatalogoPersonalEvent {
  //final Map<String, String> params;
  final String token;
  final int obraId;

  CatalogoPersonalInStartRequest({required this.token, required this.obraId});
}
