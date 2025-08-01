import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
//import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jfapp/blocs/reporte_diario_whatsapp/reporte_diario_wa_bloc.dart';
import 'package:jfapp/blocs/reporte_diario_whatsapp/reporte_diario_wa_event.dart';
import 'package:jfapp/blocs/reporte_diario_whatsapp/reporte_diario_wa_state.dart';
import 'package:jfapp/constants.dart';
import 'package:jfapp/helpers/api/api-helper.dart';
import 'package:jfapp/helpers/connectivity_helper.dart';
import 'package:jfapp/models/reporte-diario-wa.model.dart';
import 'package:jfapp/models/user.model.dart';
import 'package:jfapp/providers/model_provider.dart';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReporteDiarioWaScreen extends StatefulWidget {
  final UserModel user;
  final int obraId;

  const ReporteDiarioWaScreen({
    super.key,
    required this.user,
    required this.obraId,
  });

  @override
  State<ReporteDiarioWaScreen> createState() => _ReporteDiarioWaScreenState();
}

class _ReporteDiarioWaScreenState extends State<ReporteDiarioWaScreen> {
  bool _tieneConexion = false;
  bool _isLoading = true;
  bool _isDownloading = false;

  final Map<int, bool> _selecciones = {};
  final TextEditingController _searchController = TextEditingController();
  List<DataWa> _reporteWaFiltrado = [];

  ReporteDiarioWaModel? reporteDiarioWaModel;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filtrarReporteDiarioWa);
    _cargarDatosIniciales();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosIniciales() async {
    reporteDiarioWaModel = await ModelProvider.cargarCatalogoReporteDiarioWa();
    _reporteWaFiltrado = reporteDiarioWaModel?.data ?? [];

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _actualizarDesdeApi() async {
    _tieneConexion = await ConnectivityHelper.tieneConexionInternet();

    if (_tieneConexion) {
      final token = widget.user.token;
      final obraId = widget.user.user!.obraId;
      context.read<ReporteDiarioWaBloc>().add(
            ReporteDiarioWaInStartRequest(token: token, obraId: obraId!),
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay conexión a internet')),
      );
    }
  }

  void _filtrarReporteDiarioWa() {
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      _reporteWaFiltrado = reporteDiarioWaModel?.data ?? [];
    } else {
      _reporteWaFiltrado = (reporteDiarioWaModel?.data ?? []).where((item) {
        final fechaFormateada = DateFormat('dd/MM/yyyy').format(item.fecha);
        return fechaFormateada.toLowerCase().contains(query);
      }).toList();
    }

    setState(() {});
  }

// Función para obtener y copiar texto del reporte
  Future<void> _obtenerYCopiarTextoReporte(DateTime fecha) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Obteniendo datos...')
              ],
            ),
          );
        },
      );

      final textoDesdeAPI = await obtenerTextoDesdeAPI(
          widget.user.token, widget.user.user!.obraId!, fecha);

      // Cerrar el diálogo de carga
      Navigator.of(context, rootNavigator: true).pop();

      if (textoDesdeAPI != null) {
        await Clipboard.setData(ClipboardData(text: textoDesdeAPI));
        _mostrarMensajeCopiado();
      } else {
        _copiarTextoBasico(fecha);
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al copiar texto: ${e.toString()}')),
      );
    }
  }

  void _copiarTextoBasico(DateTime fecha) async {
    // Buscar el DataWa correspondiente a la fecha
    final dataWa = _reporteWaFiltrado.firstWhere(
      (item) => isSameDay(item.fecha, fecha),
      orElse: () => _reporteWaFiltrado.first,
    );

    final maquinariaList = dataWa.maquinariaPorTipo
        .map((e) => '- ${e.total} ${e.tipoMaquinaria}')
        .join('\n');

    final personalList = dataWa.personalPorPuesto
        .map((e) => '- ${e.total} ${e.puesto}')
        .join('\n');

    final actividadesList = dataWa.acarreos.detallesVolumen
        .map((e) => '- ${e.material} ${e.volumen} m3')
        .join('\n');

    final textoBasico = '''
REPORTE DIARIO DE OBRA
Fecha: ${DateFormat('dd/MM/yyyy').format(dataWa.fecha)}

Equipos activos: ${dataWa.totalMaquinaria}
$maquinariaList

Personal activo: ${dataWa.totalPersonal}
$personalList


Actividades realizadas: 
$actividadesList

Volumen Total: ${dataWa.acarreos.volumen.totalVolumen} m3
''';

    // Copiar al portapapeles
    await Clipboard.setData(ClipboardData(text: textoBasico));
    _mostrarMensajeCopiado();
  }

// Función para mostrar un mensaje de éxito
  void _mostrarMensajeCopiado() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Texto copiado al portapapeles'),
        backgroundColor: Colors.green,
      ),
    );
  }

// Función auxiliar para comparar días
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /* Future<void> _descargarYCompartirPDF(String obraId, String fecha) async {
    try {
      _tieneConexion = await ConnectivityHelper.tieneConexionInternet();
      if (!_tieneConexion) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay conexión a internet')),
        );
        return;
      }

      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generando reporte PDF...')
              ],
            ),
          );
        },
      );

      final token = widget.user.token;
      final response =
          await enviarReporteDiario(token, widget.user.user!.obraId!, fecha);

      // Agregar logs para depuración
      dev.log('Respuesta completa: ${response.toString()}');
      dev.log('Tipo de data: ${response['data'].runtimeType}');

      if (response['success'] == true && response['data'] != null) {
        var pdfUrl = '';

        // Intentamos obtener la URL del PDF de diferentes formas posibles según la estructura de la respuesta
        if (response['data'] is Map) {
          final dataMap = response['data'] as Map;

          // Verificar si el map contiene directamente la clave pdf_url
          if (dataMap.containsKey('pdf_url')) {
            pdfUrl = dataMap['pdf_url'].toString();
          }
          // O si contiene una clave 'data' que a su vez tiene pdf_url
          else if (dataMap.containsKey('data') && dataMap['data'] is Map) {
            final innerData = dataMap['data'] as Map;
            if (innerData.containsKey('pdf_url')) {
              pdfUrl = innerData['pdf_url'].toString();
            }
          }
        }
        // Si data es un string, puede ser un JSON que necesita ser parseado
        else if (response['data'] is String) {
          try {
            final jsonData = jsonDecode(response['data']);
            if (jsonData is Map && jsonData.containsKey('pdf_url')) {
              pdfUrl = jsonData['pdf_url'].toString();
            } else if (jsonData is Map &&
                jsonData.containsKey('data') &&
                jsonData['data'] is Map &&
                jsonData['data'].containsKey('pdf_url')) {
              pdfUrl = jsonData['data']['pdf_url'].toString();
            }
          } catch (e) {
            dev.log('Error al decodificar JSON: ${e.toString()}');
          }
        }

        // Si hemos obtenido una URL, procedemos a descargar y compartir
        if (pdfUrl.isNotEmpty) {
          dev.log('URL del PDF encontrada: $pdfUrl');
          final nombreArchivo = 'reporte_$obraId-$fecha';
          await _descargarYCompartirPDFArchivo(pdfUrl, nombreArchivo);
        } else {
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'No se pudo encontrar la URL del PDF en la respuesta')),
          );
        }
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error al generar el reporte: ${response['message'] ?? "Error desconocido"}')),
        );
      }
    } catch (e) {
      // Cerrar el diálogo de carga si ocurre un error
      if (Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      dev.log('Error en _descargarYCompartirPDF: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }*/

  Future<void> _descargarYCompartirPDF(String obraId, String fecha) async {
    try {
      _tieneConexion = await ConnectivityHelper.tieneConexionInternet();
      if (!_tieneConexion) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay conexión a internet')),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generando reporte PDF...')
              ],
            ),
          );
        },
      );

      final token = widget.user.token;
      final file = await descargarPDFReporte(token, int.parse(obraId), fecha);

      // Cerrar el loader
      if (Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (file != null) {
        // Compartir el archivo
        await Share.shareXFiles([XFile(file.path)], text: 'Reporte Diario');
      } else {
        dev.log('El archivo PDF no se pudo descargar.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo generar el reporte PDF')),
        );
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      dev.log('Error general: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _descargarYCompartirPDFArchivo(
      String url, String nombreArchivo) async {
    try {
      dev.log('Iniciando descarga desde: $url');

      // if (kIsWeb) {
      //   html.window.open(url, '_blank');
      //   Navigator.of(context, rootNavigator: true).pop();
      //   return;
      // }
      // Descargar el archivo
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        dev.log('Descarga exitosa, tamaño: ${response.bodyBytes.length} bytes');

        // Obtener directorio temporal
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/$nombreArchivo.pdf';
        final file = File(filePath);

        // Guardar el archivo
        await file.writeAsBytes(response.bodyBytes);
        dev.log('Archivo guardado en: $filePath');

        // Comprobar si el archivo existe
        if (!await file.exists()) {
          dev.log('Error: El archivo no existe después de guardarlo');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Error: No se pudo guardar el archivo')),
          );
          return;
        }

        dev.log('El archivo existe y pesa: ${await file.length()} bytes');

        // Cerrar el diálogo de carga antes de compartir
        if (Navigator.canPop(context)) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        // Compartir el archivo usando share_plus
        final result = await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Reporte de Obra $nombreArchivo',
        );

        dev.log('Resultado de compartir: ${result.status}');
      } else {
        if (Navigator.canPop(context)) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        dev.log(
            'Error al descargar PDF: ${response.statusCode}, ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Error al descargar el PDF: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      dev.log('Error en _descargarYCompartirPDFArchivo: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al compartir: ${e.toString()}')),
      );
    }
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por fecha...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildListaReporte() {
    if (_reporteWaFiltrado.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _searchController.text.isEmpty
                ? 'No hay fechas disponibles'
                : 'No se encontraron resultados',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _actualizarDesdeApi,
      child: ListView.builder(
        itemCount: _reporteWaFiltrado.length,
        itemBuilder: (context, index) {
          final data = _reporteWaFiltrado[index];
          return Card(
            color: Colors.grey[200],
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            elevation: 2,
            child: ExpansionTile(
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Actividades: ${DateFormat('dd/MM/yyyy').format(data.fecha)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              trailing: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      setState(() {
                        _isDownloading = true;
                      });
                      final fechaFormateada =
                          DateFormat('yyyy-MM-dd').format(data.fecha);
                      _descargarYCompartirPDF(
                          widget.obraId.toString(), fechaFormateada);
                      setState(() {
                        _isDownloading = false;
                      });
                      //_mostrarModalCompartir(data);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      setState(() {
                        _isDownloading = true;
                      });
                      _obtenerYCopiarTextoReporte(data.fecha);
                      setState(() {
                        _isDownloading = false;
                      });
                      //_mostrarModalCompartir(data);
                    },
                  ),
                ],
              ),
              children: [
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Primera columna (Equipos)
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Equipos activos: ${data.totalMaquinaria}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...data.maquinariaPorTipo.map((e) {
                              return Text('-${e.total} ${e.tipoMaquinaria}');
                            }),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),

                      // Segunda columna (Personal)
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Personal activo: ${data.totalPersonal}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...data.personalPorPuesto.map((e) {
                              return Text('-${e.total} ${e.puesto}');
                            }),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ReporteDiarioWaBloc, ReporteDiarioWaState>(
            listener: (context, state) {
          dev.log('Listener detected state: $state');
          if (state is ReporteDiarioWaSuccess) {
            setState(() {
              reporteDiarioWaModel = state.reporte;
              _reporteWaFiltrado = state.reporte.data;
              _isLoading = false;
            });
            ModelProvider.guardarCatalogoReporteDiarioWa(state.reporte);
          } else if (state is ReporteDiarioWaFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.error}')),
            );
          }
        }),
      ],
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: mainBgColor,
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Reporte diario de avance:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildSearchField(),
                  Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : (reporteDiarioWaModel == null ||
                                  reporteDiarioWaModel!.data.isEmpty)
                              ? RefreshIndicator(
                                  onRefresh: _actualizarDesdeApi,
                                  child: const Center(
                                      child: Text('No hay datos disponibles')),
                                )
                              : _buildListaReporte())
                ],
              ),
            ),
          ),
          if (_isDownloading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Procesando PDF...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
