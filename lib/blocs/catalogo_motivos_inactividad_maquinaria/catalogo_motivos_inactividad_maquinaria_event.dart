abstract class CatalogoMotivosInactvidadMaquinariaEvent {}

class CatalogoMotivosInactvidadMaquinariaInStartRequest
    extends CatalogoMotivosInactvidadMaquinariaEvent {
  //final Map<String, String> params;
  final String token;
  final int obraId;

  CatalogoMotivosInactvidadMaquinariaInStartRequest(
      {required this.token, required this.obraId});
}
