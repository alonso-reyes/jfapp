import 'package:jfapp/models/turno-seleccionado.model.dart';

class TurnoValidationHelper {
  static bool isTurnoComplete(TurnoSeleccionado? turnoSeleccionado) {
    if (turnoSeleccionado == null) {
      return false;
    }

    return turnoSeleccionado.id != null &&
        turnoSeleccionado.turno != null &&
        turnoSeleccionado.turno.isNotEmpty &&
        turnoSeleccionado.horaRealEntrada.isNotEmpty &&
        turnoSeleccionado.horaRealSalida.isNotEmpty;
  }

  // Método que puedes usar para obtener el mensaje de error específico
  static String? getIncompleteTurnoMessage(
      TurnoSeleccionado? turnoSeleccionado) {
    if (turnoSeleccionado == null) {
      return 'Complete todos los campos del turno';
    }

    // if (turnoSeleccionado.id == null) {
    //   return 'El ID del turno no está definido';
    // }

    if (turnoSeleccionado.turno.isEmpty) {
      return 'El nombre del turno está vacío';
    }

    if (turnoSeleccionado.horaRealEntrada.isEmpty) {
      return 'La hora de entrada no está definida';
    }

    if (turnoSeleccionado.horaRealSalida.isEmpty) {
      return 'La hora de salida no está definida';
    }

    return null;
  }
}
