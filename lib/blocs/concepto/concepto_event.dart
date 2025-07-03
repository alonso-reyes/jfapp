abstract class ConceptoEvent {}

class ConceptoInStartRequest extends ConceptoEvent {
  //final Map<String, String> params;
  final String token;
  final int obraId;

  ConceptoInStartRequest({required this.token, required this.obraId});
}
