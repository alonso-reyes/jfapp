import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/generales/generales_bloc.dart';
import 'package:jfapp/blocs/generales/generales_event.dart';
import 'package:jfapp/blocs/generales/generales_state.dart';
import 'package:jfapp/constants.dart';
import 'package:jfapp/helpers/responsive_helper.dart';
import 'package:jfapp/models/campos-generales-seleccionado.model.dart';
import 'package:jfapp/models/catalogo-generales.model.dart';
import 'package:jfapp/models/turno-seleccionado.model.dart';
import 'package:jfapp/models/zona-trabajo-seleccionada.model.dart';
import 'package:jfapp/providers/model_provider.dart';
import 'package:jfapp/providers/preference_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:jfapp/widgets/dibujo/zona-trabajo-drawing.widget.dart';

class ImageWithDrawing extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final bool showControls;

  const ImageWithDrawing({
    required this.imageUrl,
    this.width,
    this.height,
    this.showControls = false,
    Key? key,
  }) : super(key: key);

  @override
  _ImageWithDrawingState createState() => _ImageWithDrawingState();
}

class _ImageWithDrawingState extends State<ImageWithDrawing> {
  List<Offset> points = [];
  Color drawingColor = Colors.red;
  double strokeWidth = 4.0;

  void _clearDrawing() {
    setState(() {
      points.clear();
    });
  }

  void _changeColor(Color newColor) {
    setState(() {
      drawingColor = newColor;
    });
  }

  final GlobalKey _globalKey = GlobalKey();

  Future<Uint8List?> captureImage() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Error capturando imagen: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showControls)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.undo, color: Colors.red),
                  onPressed: _clearDrawing,
                  tooltip: 'Borrar dibujo',
                ),
                _buildColorButton(Colors.red),
                _buildColorButton(Colors.blue),
                _buildColorButton(Colors.green),
                _buildColorButton(Colors.black)
              ],
            ),
          ),
        // Add constrained container for the image
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: widget.width ?? double.infinity,
            maxHeight: widget.height ?? 400, // Default height if not specified
          ),
          child: RepaintBoundary(
            key: _globalKey,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanUpdate: (details) {
                setState(() {
                  // RenderBox renderBox = context.findRenderObject() as RenderBox;
                  // Offset localPosition =
                  //     renderBox.globalToLocal(details.globalPosition);
                  // points = List.from(points)..add(localPosition);

                  // Obtén el RenderBox del RepaintBoundary (que contiene la imagen)
                  final RenderBox renderBox = _globalKey.currentContext!
                      .findRenderObject() as RenderBox;

                  // Calcula la posición relativa al RepaintBoundary
                  Offset localPosition =
                      renderBox.globalToLocal(details.globalPosition);

                  // Asegúrate de que la posición está dentro de los límites de la imagen
                  if (localPosition.dx >= 0 &&
                      localPosition.dy >= 0 &&
                      localPosition.dx <= renderBox.size.width &&
                      localPosition.dy <= renderBox.size.height) {
                    points = List.from(points)..add(localPosition);
                  }
                });
              },
              onPanEnd: (details) => points.add(Offset.infinite),
              child: Stack(
                children: [
                  // Image with explicit sizing
                  SizedBox(
                    width: widget.width,
                    height: widget.height,
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                  CustomPaint(
                    painter: DrawingPainter(points,
                        color: drawingColor, strokeWidth: strokeWidth),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorButton(Color color) {
    return IconButton(
      icon: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: drawingColor == color ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      onPressed: () => _changeColor(color),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  DrawingPainter(this.points,
      {this.color = Colors.red, this.strokeWidth = 4.0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.infinite && points[i + 1] != Offset.infinite) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}

class GeneralesWidget extends StatefulWidget {
  final String token;
  final int obraId;
  final Responsive responsive;

  const GeneralesWidget({
    super.key,
    required this.token,
    required this.obraId,
    required this.responsive,
  });

  @override
  _GeneralesWidgetState createState() => _GeneralesWidgetState();

  //@override
  //bool get wantKeepAlive => true;
}

class _GeneralesWidgetState extends State<GeneralesWidget> {
  bool _isLoading = true;
  bool _tieneConexion = false;
  final String fechaActual = DateFormat('dd/MM/yyyy').format(DateTime.now());

  CatalogoGeneralesModel? catalogoGenerales;
  CampoGeneralesSeleccionado? camposGenerales;
  final TextEditingController _sobrestanteController = TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();

  Turno? _selectedTurno;
  TimeOfDay? _horaInicioActividades;
  TimeOfDay? _horaFinActividades;
  Zona? _selectedZona;
  bool _showImage = false;
// bool _tieneConexion = false;
// bool _isLoading = true;

// Función unificada para verificar conexión

  @override
  void initState() {
    super.initState();
    // print('inicializa generales');
    _inicializarDatos();
  }

  Future<void> _inicializarDatos() async {
    await _verificarConexion();
    await _cargarPreferencias();
    await _cargarSeleccionesGuardadas();
  }

  Future<void> _verificarConexion() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _tieneConexion = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<void> _cargarPreferencias() async {
    try {
      final catalogoLocal = await ModelProvider.cargarCatalogoGenerales();
      setState(() {
        catalogoGenerales = catalogoLocal;
        _isLoading = catalogoLocal == null;
      });
      //print(catalogoLocal.toString());

      // if (_tieneConexion && catalogoLocal == null) {
      //   await _recargarCatalogos();
      // }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos locales')),
      );
    }
  }

  Future<void> _cargarSeleccionesGuardadas() async {
    final turnoGuardado = PreferenceProvider.getTurnoSeleccionado();
    final zonaGuardada = PreferenceProvider.getZonaTrabajoSeleccionada();

    if (turnoGuardado != null && catalogoGenerales != null) {
      final turnoEncontrado = catalogoGenerales!.catalogoGenerales.turnos!
          .firstWhere((t) => t.id == turnoGuardado.id);

      if (turnoEncontrado != null) {
        setState(() {
          _selectedTurno = turnoEncontrado;
          _horaInicioActividades =
              _stringToTimeOfDay(turnoGuardado.horaRealEntrada);
          _horaFinActividades =
              _stringToTimeOfDay(turnoGuardado.horaRealSalida);
        });
      }
    }

    if (zonaGuardada != null && catalogoGenerales != null) {
      final zonaEncontrada = catalogoGenerales!.catalogoGenerales.zonas!
          .firstWhere((z) => z.id == zonaGuardada.id);

      if (zonaEncontrada != null) {
        setState(() {
          _selectedZona = zonaEncontrada;
          _showImage = true;
        });
      }
    }
  }

// Actualiza los catálogos sin bloquear la UI
  /*Future<void> _actualizarCatalogosEnSegundoPlano() async {
    try {
      final generalesBloc = context.read<GeneralesBloc>();
      generalesBloc.add(GeneralesInStartRequest(
        token: widget.token,
        obraId: widget.obraId,
      ));

      // Opcional: Guardar automáticamente cuando se actualice
      // (depende de tu implementación del BLoC)
    } catch (e) {
      // Silenciar errores en la actualización en segundo plano
      debugPrint('Error en actualización en segundo plano: $e');
    }
  }*/

// Recarga forzada (para pull-to-refresh o botón manual)
  Future<void> _recargarCatalogos() async {
    if (!_tieneConexion) return;

    setState(() => _isLoading = true);
    try {
      final generalesBloc = context.read<GeneralesBloc>();
      generalesBloc.add(GeneralesInStartRequest(
        token: widget.token,
        obraId: widget.obraId,
      ));
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar datos')),
      );
    }
  }

// Para el RefreshIndicator
  Future<void> _onRefresh() async {
    PreferenceProvider.clearTurnoSeleccionado();
    PreferenceProvider.clearZonaTrabajoSeleccionada();
    _selectedTurno = null;
    _selectedZona = null;
    await _recargarCatalogos();
  }

  TimeOfDay _stringToTimeOfDay(String time) {
    final format = DateFormat("HH:mm");
    final parsedTime = format.parse(time);
    return TimeOfDay(hour: parsedTime.hour, minute: parsedTime.minute);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<GeneralesBloc, GeneralesState>(
          listener: (context, state) {
            if (state is GeneralesSuccess) {
              setState(() {
                catalogoGenerales = state.catalogoGenerales;
                ModelProvider.guardarCatalogoGenerales(catalogoGenerales!);
                _isLoading = false;
              });
            } else if (state is GeneralesFailure) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al actualizar datos')),
              );
            }
          },
        ),
      ],
      child: _isLoading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (!_tieneConexion)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Modo sin conexión: usando datos locales',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      if (catalogoGenerales != null)
                        Column(
                          children: [
                            _buildObraInfo(),
                            SizedBox(height: 16),
                            if (catalogoGenerales!
                                .catalogoGenerales.turnos.isNotEmpty)
                              _buildTurnoSelection(),
                            SizedBox(height: 16),
                            if (catalogoGenerales!
                                .catalogoGenerales.zonas.isNotEmpty)
                              _buildZonaSelection(),
                            SizedBox(height: 16),
                            _buildObservaciones()
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildObraInfo() {
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
                Expanded(
                  child: Text(
                    'Obra: ${catalogoGenerales!.catalogoGenerales.obra.nombre} (${catalogoGenerales!.catalogoGenerales.obra.clave})',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, // o TextOverflow.fade
                    maxLines: 5,
                  ),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Ubicación: ${catalogoGenerales!.catalogoGenerales.obra.ubicacion}',
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis, // o TextOverflow.fade
                    maxLines: 5,
                  ),
                ),
                Text(
                  'Fecha: $fechaActual',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: TextField(
                controller: _sobrestanteController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Escriba el nombre del sobrestante',
                  labelStyle: TextStyle(color: customBlack),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey[400]!,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    // Borde cuando no está enfocado
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey[400]!,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    // Borde cuando está enfocado
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey[400]!,
                      width: 1,
                    ),
                  ),
                ),
                onChanged: (value) => _guardarDatosCampos(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTurnoSelection() {
    final turnosDisponibles = catalogoGenerales?.catalogoGenerales.turnos ?? [];
    final turnoValido = _selectedTurno != null &&
        turnosDisponibles.any((t) => t.id == _selectedTurno?.id);

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
                  'Turno',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey[400]!,
                  width: 1,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<Turno>(
                value: turnoValido ? _selectedTurno : null,
                hint: Text(
                  "Seleccione un turno",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                onChanged: (Turno? newValue) {
                  if (newValue == null) return;

                  setState(() {
                    _selectedTurno = newValue;
                    _horaInicioActividades =
                        _stringToTimeOfDay(newValue.horaEntrada);
                    _horaFinActividades =
                        _stringToTimeOfDay(newValue.horaSalida);
                  });
                  _guardarDatosTurno();
                },
                items: turnosDisponibles.map((Turno turno) {
                  return DropdownMenuItem<Turno>(
                    value: turno,
                    child: Text(turno.turno ?? "Turno sin nombre"),
                  );
                }).toList(),
                isExpanded: true,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[700],
                  size: 28,
                ),
                underline: SizedBox(),
                dropdownColor: Colors.white,
                elevation: 2,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: 16),
            if (_selectedTurno != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: Colors.grey[700],
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Hora de entrada: ${_selectedTurno!.horaEntrada}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: Colors.grey[700],
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Hora de salida: ${_selectedTurno!.horaSalida}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 22),
              _buildTimePicker(
                label: "Hora de inicio de actividades",
                selectedTime: _horaInicioActividades,
                onTimeSelected: (TimeOfDay time) {
                  setState(() {
                    _horaInicioActividades = time;
                  });
                  _guardarDatosTurno();
                },
              ),
              SizedBox(height: 16),
              _buildTimePicker(
                label: "Hora de terminación de actividades",
                selectedTime: _horaFinActividades,
                onTimeSelected: (TimeOfDay time) {
                  setState(() {
                    _horaFinActividades = time;
                  });
                  _guardarDatosTurno();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildZonaSelection() {
    final zonasDisponibles = catalogoGenerales?.catalogoGenerales.zonas ?? [];
    final zonaValida = _selectedZona != null &&
        zonasDisponibles.any((z) => z.id == _selectedZona?.id);
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
                  'Zona de trabajo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey[400]!,
                  width: 1,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<Zona>(
                value: zonaValida ? _selectedZona : null,
                hint: Text(
                  "Seleccione una zona de trabajo",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                onChanged: (Zona? newValue) {
                  setState(() {
                    _selectedZona = newValue;
                    _showImage = true;
                    print(_selectedZona!.imagenUrl.toString());
                  });
                  //_guardarDatosZona();
                },
                items: zonasDisponibles.map((Zona zona) {
                  return DropdownMenuItem<Zona>(
                    value: zona,
                    child: Text(
                      zona.nombre ?? "Zona sin nombre",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                  );
                }).toList(),
                isExpanded: true,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[700],
                  size: 28,
                ),
                underline: SizedBox(),
                dropdownColor: Colors.white,
                elevation: 2,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: 16),
            if (_selectedZona != null && _showImage) ...[
              Text(
                'Imagen de la zona:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () => _navigateToDrawingScreen(context, _selectedZona!),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      // Muestra la imagen con los dibujos guardados si existen
                      FutureBuilder<Uint8List?>(
                        future: _getImageWithDrawings(_selectedZona!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            return Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            );
                          }
                          return Image.network(
                            _selectedZona!.imagenUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          );
                        },
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Toca para dibujar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // GestureDetector(
              //   onTap: () =>
              //       _showDrawingModal(context, _selectedZona!.imagenUrl),
              //   child: Container(
              //     height: 200,
              //     decoration: BoxDecoration(
              //       border: Border.all(color: Colors.grey),
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     child: Stack(
              //       children: [
              //         Image.network(
              //           _selectedZona!.imagenUrl,
              //           fit: BoxFit.cover,
              //           width: double.infinity,
              //         ),
              //         Positioned.fill(
              //           child: Center(
              //             child: Container(
              //               padding: EdgeInsets.all(8),
              //               decoration: BoxDecoration(
              //                 color: Colors.black54,
              //                 borderRadius: BorderRadius.circular(20),
              //               ),
              //               child: Text(
              //                 'Toca para dibujar',
              //                 style: TextStyle(color: Colors.white),
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ],
        ),
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
                onChanged: (value) => _guardarDatosCampos(),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay? selectedTime,
    required Function(TimeOfDay) onTimeSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
        );
        if (pickedTime != null) {
          onTimeSelected(pickedTime);
        }
      },
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.access_time),
          ),
          controller: TextEditingController(
            text: selectedTime?.format(context) ?? '',
          ),
        ),
      ),
    );
  }

  void _guardarDatosCampos() {
    //if (_sobrestanteController.text.isNotEmpty) {
    final camposSeleccionado = CampoGeneralesSeleccionado(
        sobrestante: _sobrestanteController.text,
        observaciones: _observacionesController.text.isNotEmpty
            ? _observacionesController.text
            : '');
    //print(jsonEncode(camposSeleccionado));
    PreferenceProvider.setCampoSeleccionado(camposSeleccionado);
    //}
  }

  void _guardarDatosTurno() {
    if (_selectedTurno != null &&
        _horaInicioActividades != null &&
        _horaFinActividades != null) {
      final turnoSeleccionado = TurnoSeleccionado(
        id: _selectedTurno!.id,
        turno: _selectedTurno!.turno,
        horaRealEntrada: _horaInicioActividades!.format(context),
        horaRealSalida: _horaFinActividades!.format(context),
      );
      PreferenceProvider.setTurnoSeleccionado(turnoSeleccionado);
    }
  }

  void _guardarDatosZona() {
    //print('entro aqui');
    if (_selectedZona != null) {
      final zonaSeleccionada = ZonaTrabajoSeleccionada(
        id: _selectedZona!.id,
        clave: _selectedZona!.clave,
        dibujos: [
          DrawingPath(
            puntos: [Offset(10, 10), Offset(20, 20)],
            color: Colors.red,
            grosor: 4.0,
          ),
        ],
      );
      PreferenceProvider.setZonaTrabajoSeleccionada(zonaSeleccionada);
      Navigator.of(context).pop();
    }
  }

  Future<void> _navigateToDrawingScreen(BuildContext context, Zona zona) async {
    // Cargar dibujos existentes si los hay
    final zonaGuardada = PreferenceProvider.getZonaTrabajoSeleccionada();
    List<DrawingStroke>? existingStrokes;
    Uint8List? existingImage;

    if (zonaGuardada != null && zonaGuardada.imagenDibujadaBase64 != null) {
      existingImage = base64Decode(zonaGuardada.imagenDibujadaBase64!);
    }

    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => ZonaTrabajoDrawingScreen(
          imageUrl: zona.imagenUrl,
          initialStrokes: existingStrokes,
          //initialImage: existingImage,
        ),
      ),
    );

    if (result != null && zona.id != null) {
      final imageBytes = result['imageBytes'];
      final strokes = result['strokes'] as List<DrawingStroke>;

      final zonaSeleccionada = ZonaTrabajoSeleccionada(
        id: zona.id!,
        clave: zona.clave,
        imagenDibujadaBase64: base64Encode(imageBytes),
        dibujos: strokes
            .map((stroke) => DrawingPath(
                  puntos: stroke.points,
                  color: stroke.color,
                  grosor: stroke.strokeWidth,
                ))
            .toList(),
      );

      PreferenceProvider.setZonaTrabajoSeleccionada(zonaSeleccionada);
      setState(() {}); // Actualizar la vista
    }
  }

  Future<Uint8List?> _getImageWithDrawings(Zona zona) async {
    final zonaGuardada = PreferenceProvider.getZonaTrabajoSeleccionada();
    if (zonaGuardada != null && zonaGuardada.imagenDibujadaBase64 != null) {
      return base64Decode(zonaGuardada.imagenDibujadaBase64!);
    }
    return null;
  }

  void _showDrawingModal(BuildContext context, String imageUrl) {
    final GlobalKey<_ImageWithDrawingState> drawingKey = GlobalKey();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dibujar sobre la imagen',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: ImageWithDrawing(
                  key: drawingKey,
                  imageUrl: imageUrl,
                  showControls: true,
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    // Capturar la imagen dibujada
                    final imageBytes =
                        await drawingKey.currentState?.captureImage();
                    if (imageBytes != null && _selectedZona != null) {
                      final imageBase64 = base64Encode(imageBytes);

                      final zonaSeleccionada = ZonaTrabajoSeleccionada(
                        id: _selectedZona!.id,
                        clave: _selectedZona!.clave,
                        imagenDibujadaBase64: imageBase64,
                        dibujos: [], // Puedes seguir guardando los dibujos si lo necesitas
                      );

                      PreferenceProvider.setZonaTrabajoSeleccionada(
                          zonaSeleccionada);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    height: widget.responsive.dp(5),
                    width: widget.responsive.hp(13),
                    margin: EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: customBlack,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Guardar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // ElevatedButton(
              //   onPressed: () => Navigator.of(context).pop(),
              //   child: Text('Guardar y cerrar'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
