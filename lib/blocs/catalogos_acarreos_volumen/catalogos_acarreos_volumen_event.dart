abstract class CatalogosAcarreosVolumenEvent {}

class CatalogosAcarreosVolumenInStartRequest
    extends CatalogosAcarreosVolumenEvent {
  //final Map<String, String> params;
  final String token;
  final int obraId;

  CatalogosAcarreosVolumenInStartRequest(
      {required this.token, required this.obraId});
}
