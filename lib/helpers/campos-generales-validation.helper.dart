import 'package:jfapp/models/campos-generales-seleccionado.model.dart';

class CamposGeneralesValidationHelper {
  static bool areCamposGeneralesComplete(
      CampoGeneralesSeleccionado? camposGenerales) {
    if (camposGenerales == null) {
      return false;
    }

    return camposGenerales.sobrestante != null &&
        camposGenerales.sobrestante.toString().isNotEmpty;
  }

  static String? getIncompleteCamposMessage(
      CampoGeneralesSeleccionado? camposGenerales) {
    if (camposGenerales == null) {
      return 'Complete los campos generales';
    }

    if (camposGenerales == null ||
        camposGenerales.sobrestante.toString().isEmpty) {
      return 'El campo "sobrestante" es obligatorio';
    }

    return null;
  }
}
