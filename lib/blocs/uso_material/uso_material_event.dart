abstract class UsoMaterialEvent {}

class UsoMaterialInStartRequest extends UsoMaterialEvent {
  //final Map<String, String> params;
  final String token;
  final int obraId;

  UsoMaterialInStartRequest({required this.token, required this.obraId});
}
