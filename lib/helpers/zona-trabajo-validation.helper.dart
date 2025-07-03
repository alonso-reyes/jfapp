import 'package:jfapp/models/zona-trabajo-seleccionada.model.dart';

class ZonaTrabajoValidationHelper {
  static bool isZonaComplete(ZonaTrabajoSeleccionada? zonaSeleccionada) {
    if (zonaSeleccionada == null) {
      return false;
    }

    return zonaSeleccionada.id != null &&
        zonaSeleccionada.clave != null &&
        zonaSeleccionada.dibujos != null;
  }

  // Método que puedes usar para obtener el mensaje de error específico
  static String? getIncompleteZonaMessage(
      ZonaTrabajoSeleccionada? zonaSeleccionada) {
    if (zonaSeleccionada == null) {
      return 'Complete todos los campos de la zona de trabajo';
    }

    // if (turnoSeleccionado.id == null) {
    //   return 'El ID del turno no está definido';
    // }

    if (zonaSeleccionada.clave.isEmpty) {
      return 'Complete todos los campos de la zona de trabajo';
    }

    if (zonaSeleccionada.dibujos.isEmpty) {
      return 'Dibuje la zona de trabajo';
    }

    return null;
  }
}
