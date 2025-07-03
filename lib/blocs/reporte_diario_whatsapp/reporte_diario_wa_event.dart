abstract class ReporteDiarioWaEvent {}

class ReporteDiarioWaInStartRequest extends ReporteDiarioWaEvent {
  //final Map<String, String> params;
  final String token;
  final int obraId;

  ReporteDiarioWaInStartRequest({required this.token, required this.obraId});
}
