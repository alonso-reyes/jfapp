import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jfapp/constants.dart';
import 'package:jfapp/helpers/api/api-helper.dart';
import 'package:jfapp/helpers/campos-generales-validation.helper.dart';
import 'package:jfapp/helpers/session_manager.dart';
import 'package:jfapp/helpers/turno-validation.helper.dart';
import 'package:jfapp/helpers/zona-trabajo-validation.helper.dart';
import 'package:jfapp/models/user.model.dart';
import 'package:jfapp/providers/maquinaria_provider.dart';
import 'package:jfapp/providers/personal_provider.dart';
import 'package:jfapp/providers/photo_provider.dart';
import 'dart:io';
import 'dart:convert';

import 'package:jfapp/providers/preference_provider.dart';
import 'package:jfapp/screens/jfMain_screen.dart';

import 'dart:developer' as dev;

class GuardarReporteScreen extends StatefulWidget {
  final UserModel? user;

  const GuardarReporteScreen({
    required this.user,
    super.key,
  });

  @override
  State<GuardarReporteScreen> createState() => _GuardarReporteScreenState();
}

class _GuardarReporteScreenState extends State<GuardarReporteScreen> {
  late UserModel currentUser;
  List<Map<String, String>> _images = [];
  bool _isLoading = true;
  final TextEditingController _observacionesController =
      TextEditingController();

  @override
  void initState() {
    currentUser = widget.user ?? SessionManager.user!;
    super.initState();
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  bool _tieneConexion = false;

  Future<bool> tieneConexionInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> guardarDatos() async {
    _tieneConexion = await tieneConexionInternet();
    if (!_tieneConexion) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Sin conexión a internet'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // final campoGeneralesSeleccionado =
      //     PreferenceProvider.getCampoSeleccionado();
      final turnoSeleccionado = PreferenceProvider.getTurnoSeleccionado();
      final zonaSeleccionada = PreferenceProvider.getZonaTrabajoSeleccionada();
      final acarreosVolumen =
          PreferenceProvider.getAcarreos('acarreos_volumen');
      final acarreosArea = PreferenceProvider.getAcarreosArea('acarreos_area');
      final acarreosMetroLineal =
          PreferenceProvider.getAcarreosMetro('acarreos_metro');
      final acarreosAgua = PreferenceProvider.getAcarreosAgua('acarreos_agua');
      final maquinaria = MaquinariaProvider.getMaquinaria('maquinaria');
      final personal = PersonalProvider.getPersonal('personal');
      final fotografias = PhotoProvider.getImagesWithDescriptions('images');

      // print(turnoSeleccionado);
      // return;
      // Validaciones
      // if (!CamposGeneralesValidationHelper.areCamposGeneralesComplete(
      //     campoGeneralesSeleccionado)) {
      //   final errorMessage =
      //       CamposGeneralesValidationHelper.getIncompleteCamposMessage(
      //           campoGeneralesSeleccionado);
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text(errorMessage!)),
      //   );
      //   Navigator.pop(context);
      //   return;
      // }

      if (!TurnoValidationHelper.isTurnoComplete(turnoSeleccionado)) {
        final errorMessage =
            TurnoValidationHelper.getIncompleteTurnoMessage(turnoSeleccionado);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage!)),
        );
        Navigator.pop(context);
        return;
      }

      if (!ZonaTrabajoValidationHelper.isZonaComplete(zonaSeleccionada)) {
        final errorMessage =
            ZonaTrabajoValidationHelper.getIncompleteZonaMessage(
                zonaSeleccionada);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage!)),
        );
        Navigator.pop(context);
        return;
      }

      final Map<String, dynamic> reporteData = {
        'usuario_id': currentUser.user!.id,
        // 'generales': campoGeneralesSeleccionado!.toMap(),
        'turno': turnoSeleccionado!.toMap(),
        'zona_trabajo': zonaSeleccionada!.toMap(),
        'observaciones': _observacionesController.text,
        'acarreos_volumen':
            acarreosVolumen.map((acarreo) => acarreo.toMap()).toList(),
        'acarreos_area':
            acarreosArea.map((acarreo) => acarreo.toMap()).toList(),
        'acarreos_metro_lineal':
            acarreosMetroLineal.map((acarreo) => acarreo.toMap()).toList(),
        'acarreos_agua':
            acarreosAgua.map((acarreo) => acarreo.toMap()).toList(),
        'maquinaria': maquinaria.map((maquina) => maquina.toJson()).toList(),
        'personal': personal.map((persona) => persona.toJson()).toList(),
        'fotografias': fotografias,
      };

      // dev.log(reporteData);
      // return;

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.black45),
          );
        },
      );

      final response = await guardarReporteJF(
          currentUser.token, currentUser.user!.obraId, reporteData);

      Navigator.of(context).pop(); // Cerrar loading

      if (response['success'] == true) {
        await _limpiarPreferencias();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte guardado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Error al guardar el reporte'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Cerrar loading si está abierto
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      dev.log('Error al guardar datos: ${e.toString()}');
    }
  }

  Future<void> _limpiarPreferencias() async {
    PreferenceProvider.clearTurnoSeleccionado();
    PreferenceProvider.clearZonaTrabajoSeleccionada();
    PreferenceProvider.clearAcarreosVolumen();
    PreferenceProvider.clearAcarreosArea();
    PreferenceProvider.clearAcarreosMetro();
    PreferenceProvider.clearAcarreosAgua();
    MaquinariaProvider.clearMaquinaria();
    PersonalProvider.clearPersonal();
    PhotoProvider.clearImages('images');

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => JfMainScreen(),
          ),
        );
      }
    });
  }

  void _showGuardarDatosModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enviar reporte'),
        content: const Text(
            '¿Está seguro que desea guardar éste reporte? Una vez guardado no se podrá modificar la información'),
        actions: [
          TextButton(
            onPressed: () {
              guardarDatos();
            },
            child: const Text('Aceptar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildObservaciones() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Observaciones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: TextFormField(
                controller: _observacionesController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Observaciones',
                  labelStyle: TextStyle(color: customBlack),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Colors.grey[400]!,
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    // Borde normal (no enfocado)
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Colors.grey[400]!,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    // Borde al enfocar
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Colors.grey[600]!,
                      width: 1.0,
                    ),
                  ),
                ),
                //onChanged: (value) => _guardarDatosCampos(),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // << importante
        children: [
          ElevatedButton(
            onPressed: _showGuardarDatosModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: customBlack,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Guardar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBgColor,
      appBar: AppBar(
        title: Text('Guardar reporte'),
        backgroundColor: mainBgColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildObservaciones(),
              SizedBox(height: 16),
              _buildSaveButton()
            ],
          ),
        ),
      ),
    );
  }
}
