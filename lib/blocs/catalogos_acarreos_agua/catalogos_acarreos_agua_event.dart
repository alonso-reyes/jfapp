abstract class CatalogosAcarreosAguaEvent {}

class CatalogosAcarreosAguaInStartRequest extends CatalogosAcarreosAguaEvent {
  //final Map<String, String> params;
  final String token;
  final int obraId;

  CatalogosAcarreosAguaInStartRequest(
      {required this.token, required this.obraId});
}
