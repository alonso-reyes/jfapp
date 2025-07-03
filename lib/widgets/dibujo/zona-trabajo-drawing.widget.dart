import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'dart:developer' as dev;

import 'package:jfapp/constants.dart';
import 'package:jfapp/helpers/responsive_helper.dart';

class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  DrawingStroke({
    required this.points,
    required this.color,
    this.strokeWidth = 4.0,
  });
}

// Modelo para textos en el lienzo
class DrawingText {
  final Offset position;
  final String text;
  final Color color;
  final double fontSize;

  DrawingText({
    required this.position,
    required this.text,
    this.color = Colors.black,
    this.fontSize = 16,
  });
}

class DrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;

  DrawingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      Paint paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < stroke.points.length - 1; i++) {
        if (stroke.points[i] != Offset.infinite &&
            stroke.points[i + 1] != Offset.infinite) {
          canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) =>
      oldDelegate.strokes != strokes;
}

class CurrentStrokePainter extends CustomPainter {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  CurrentStrokePainter(this.points,
      {this.color = Colors.red, this.strokeWidth = 4.0});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.infinite && points[i + 1] != Offset.infinite) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(CurrentStrokePainter oldDelegate) =>
      !listEquals(oldDelegate.points, points) ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}

class ZonaTrabajoDrawingScreen extends StatefulWidget {
  final String imageUrl;
  final List<DrawingStroke>? initialStrokes;

  const ZonaTrabajoDrawingScreen({
    super.key,
    required this.imageUrl,
    this.initialStrokes,
  });

  @override
  State<ZonaTrabajoDrawingScreen> createState() =>
      _ZonaTrabajoDrawingScreenState();
}

// Estados de interacción
enum InteractionMode { draw, text, zoom, none }

InteractionMode _currentMode = InteractionMode.none;

class _ZonaTrabajoDrawingScreenState extends State<ZonaTrabajoDrawingScreen> {
  final GlobalKey _imageKey = GlobalKey();

  final List<Color> availableColors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
  ];

  double _zoom = 1.0;
  Offset _panOffset = Offset.zero;

  // Para el gesto de pellizco
  double _baseScaleFactor = 1.0;
  Offset _lastFocalPoint = Offset.zero;

  final GlobalKey _globalKey = GlobalKey();
  final ValueNotifier<List<DrawingStroke>> strokesNotifier = ValueNotifier([]);
  final ValueNotifier<List<Offset>> currentPoints = ValueNotifier([]);
  final ValueNotifier<List<DrawingText>> texts = ValueNotifier([]);

  Color currentColor = Colors.red;
  double strokeWidth = 4.0;

  final imageKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    strokesNotifier.value = widget.initialStrokes ?? [];
  }

  void _addTextAt(Offset globalPos) {
    // Usamos la misma función que ya funciona para los trazos
    final Offset localPosition = _globalToLocal(globalPos);

    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Agregar texto'),
          content: TextField(controller: controller, autofocus: true),
          actions: [
            TextButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  texts.value = [
                    ...texts.value,
                    DrawingText(
                      position: localPosition,
                      text: text,
                      color: currentColor,
                    ),
                  ];
                }
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Future<Uint8List?> _captureImage() async {
    try {
      // Obtener el RenderRepaintBoundary
      final boundary = _globalKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      // Capturar la imagen
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;
      final pngBytes = byteData.buffer.asUint8List();

      // Decodificar la imagen utilizando el paquete 'image'
      final decodedImage = img.decodeImage(pngBytes);
      if (decodedImage == null) return null;

      // Determinar los límites del contenido visible
      int top = decodedImage.height;
      int bottom = 0;
      int left = decodedImage.width;
      int right = 0;

      for (int y = 0; y < decodedImage.height; y++) {
        for (int x = 0; x < decodedImage.width; x++) {
          final pixel = decodedImage.getPixel(x, y);
          final alpha = img.getAlpha(pixel);
          if (alpha != 0) {
            if (x < left) left = x;
            if (x > right) right = x;
            if (y < top) top = y;
            if (y > bottom) bottom = y;
          }
        }
      }

      // Verificar si se encontró contenido visible
      if (left >= right || top >= bottom) {
        // No se encontró contenido visible
        return null;
      }

      // Recortar la imagen a los límites detectados
      final croppedImage = img.copyCrop(
        decodedImage,
        left,
        top,
        right - left + 1,
        bottom - top + 1,
      );

      // Codificar la imagen recortada en formato PNG
      final croppedBytes = img.encodePng(croppedImage);

      return Uint8List.fromList(croppedBytes);
    } catch (e) {
      debugPrint("Error al capturar y recortar la imagen: $e");
      return null;
    }
  }

  void _handlePointerDown(Offset globalPosition) {
    //dev.log('evento pointer downs');
    //if (!_isInsideImage(globalPosition)) return;
    //dev.log(_currentMode.toString());
    if (_currentMode == InteractionMode.text) {
      _addTextAt(globalPosition);
      return;
    }

    if (_currentMode == InteractionMode.draw) {
      final Offset localPosition = _globalToLocal(globalPosition);
      //dev.log(localPosition.toString());
      currentPoints.value = [localPosition];
    }
  }

// Update _handlePointerMove similarly
  void _handlePointerMove(Offset globalPosition) {
    //if (!_isInsideImage(globalPosition)) return;

    if (_currentMode == InteractionMode.draw) {
      final Offset localPosition = _globalToLocal(globalPosition);
      currentPoints.value = [...currentPoints.value, localPosition];
    }
  }

  Offset _globalToLocal(Offset globalPosition) {
    final RenderBox box =
        _globalKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(globalPosition);

    return (localPosition - _panOffset) / _zoom;
  }

  void _handlePointerUp() {
    if (_currentMode == InteractionMode.draw &&
        currentPoints.value.length > 1) {
      strokesNotifier.value = [
        ...strokesNotifier.value,
        DrawingStroke(
          points: List.from(currentPoints.value),
          color: currentColor,
          strokeWidth: strokeWidth,
        ),
      ];
    }
    currentPoints.value = [];
  }

  // Cambia el modo de interacción
  void _toggleMode(InteractionMode mode) {
    setState(() {
      _currentMode = _currentMode == mode ? InteractionMode.none : mode;
    });
  }

  bool _isInsideImage(Offset globalPosition) {
    final RenderBox? box =
        _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return false;

    final Offset topLeft = box.localToGlobal(Offset.zero);
    final Size size = box.size;

    // Calculamos el centro del rectángulo
    final centerX = topLeft.dx + size.width / 2;
    final centerY = topLeft.dy + size.height / 2;

    // Ajustamos el tamaño según el zoom
    final adjustedWidth = size.width * _zoom;
    final adjustedHeight = size.height * _zoom;

    // Calculamos la nueva esquina superior izquierda considerando el desplazamiento
    final adjustedTopLeft = Offset(
      centerX - (adjustedWidth / 2) + (_panOffset.dx * _zoom),
      centerY - (adjustedHeight / 2) + (_panOffset.dy * _zoom),
    );

    // Creamos el rectángulo ajustado
    final Rect adjustedRect =
        adjustedTopLeft & Size(adjustedWidth, adjustedHeight);

    return adjustedRect.contains(globalPosition);
  }

  @override
  Widget build(BuildContext context) {
    final Responsive responsive = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: customBlack,
        title: Text(
          'Dibujar sobre la imagen',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () {
              if (strokesNotifier.value.isNotEmpty) {
                List<DrawingStroke> newStrokes =
                    List.from(strokesNotifier.value);
                newStrokes.removeLast();
                strokesNotifier.value = newStrokes;
              } else if (texts.value.isNotEmpty) {
                List<DrawingText> newTexts = List.from(texts.value);
                newTexts.removeLast();
                texts.value = newTexts;
              }
            },
            tooltip: 'Deshacer último elemento',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              setState(() {
                strokesNotifier.value = [];
                texts.value = [];
              });
            },
            tooltip: 'Limpiar todo',
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de modo
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildModeButton(Icons.draw, 'Dibujar', InteractionMode.draw),
                const SizedBox(width: 16),
                _buildModeButton(
                    Icons.text_fields, 'Texto', InteractionMode.text),
              ],
            ),
          ),

          // Selector de colores (siempre visible)
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: availableColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() => currentColor = color);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color == currentColor
                            ? Colors.black
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Modo actual y zoom
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentMode == InteractionMode.none
                      ? "Modo: Zoom (${(_zoom * 100).toInt()}%)"
                      : _currentMode == InteractionMode.draw
                          ? "Modo: Dibujando (${(_zoom * 100).toInt()}%)"
                          : "Modo: Texto (${(_zoom * 100).toInt()}%)",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Área de dibujo
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _globalKey,
                child: GestureDetector(
                  onScaleStart: (details) {
                    _baseScaleFactor = _zoom;
                    _lastFocalPoint = details.focalPoint;
                    //print(_currentMode);
                    // For drawing or text mode, treat this as pointer down
                    if (_currentMode != InteractionMode.none) {
                      _handlePointerDown(details.focalPoint);
                    }
                  },
                  onScaleUpdate: (details) {
                    // If scale operation (2+ fingers), always handle as zoom/pan
                    if (details.pointerCount >= 2) {
                      final RenderBox box = _globalKey.currentContext!
                          .findRenderObject() as RenderBox;
                      final Offset localFocalPoint =
                          box.globalToLocal(details.focalPoint);

                      setState(() {
                        // Zoom logic
                        final double newZoom =
                            (_baseScaleFactor * details.scale).clamp(0.5, 5.0);

                        final Offset focalPointInContent =
                            (localFocalPoint - _panOffset) / _zoom;

                        _zoom = newZoom;

                        _panOffset =
                            localFocalPoint - focalPointInContent * _zoom;
                      });
                    } else {
                      // Single finger - handle based on mode
                      if (_currentMode != InteractionMode.none) {
                        // Drawing or text mode
                        _handlePointerMove(details.focalPoint);
                      } else {
                        // Pan mode
                        final Offset delta =
                            details.focalPoint - _lastFocalPoint;
                        setState(() {
                          _panOffset += delta / _zoom;
                          _lastFocalPoint = details.focalPoint;
                        });
                      }
                    }
                  },
                  onScaleEnd: (details) {
                    // Handle pointer up for drawing/text modes
                    if (_currentMode != InteractionMode.none) {
                      _handlePointerUp();
                    }
                  },
                  child: ClipRect(
                    child: CustomPaint(
                      painter: BackgroundPainter(),
                      child: Transform.translate(
                        offset: _panOffset,
                        child: Transform.scale(
                          scale: _zoom,
                          alignment: Alignment
                              .topLeft, // Importante para zoom correcto
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Positioned.fill(
                                    child: Image.network(
                                      widget.imageUrl,
                                      key: _imageKey,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  ValueListenableBuilder<List<DrawingStroke>>(
                                    valueListenable: strokesNotifier,
                                    builder: (_, strokes, __) => CustomPaint(
                                        painter: DrawingPainter(strokes)),
                                  ),
                                  ValueListenableBuilder<List<Offset>>(
                                    valueListenable: currentPoints,
                                    builder: (_, points, __) => CustomPaint(
                                      painter: CurrentStrokePainter(
                                        points,
                                        color: currentColor,
                                        strokeWidth: strokeWidth,
                                      ),
                                    ),
                                  ),
                                  ValueListenableBuilder<List<DrawingText>>(
                                    valueListenable: texts,
                                    builder: (_, textList, __) => CustomPaint(
                                      painter: TextPainterOverlay(textList,
                                          zoom: _zoom),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  final imageBytes = await _captureImage();
                  if (imageBytes != null && mounted) {
                    Navigator.of(context).pop({
                      'imageBytes': imageBytes,
                      'strokes': strokesNotifier.value,
                      'texts': texts.value,
                    });
                  }
                },
                child: Container(
                  height: responsive.dp(5),
                  width: responsive.hp(13),
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
          ),
        ],
      ),
      // Botón para guardar
      // floatingActionButton: Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     FloatingActionButton(
      //       heroTag: 'save',
      //       onPressed: () async {
      //         final imageBytes = await _captureImage();
      //         if (imageBytes != null && mounted) {
      //           Navigator.of(context).pop({
      //             'imageBytes': imageBytes,
      //             'strokes': strokesNotifier.value,
      //             'texts': texts.value,
      //           });
      //         }
      //       },
      //       child: const Icon(Icons.save),
      //     ),
      //   ],
      // ),
    );
  }

  Widget _buildModeButton(IconData icon, String label, InteractionMode mode) {
    final isSelected = _currentMode == mode;
    return InkWell(
      onTap: () => _toggleMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.black54,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.black54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pintor de fondo que ayuda a visualizar los límites
class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.grey.withOpacity(0.1);
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TextPainterOverlay extends CustomPainter {
  final List<DrawingText> texts;
  final double zoom;

  TextPainterOverlay(this.texts, {this.zoom = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    for (final textItem in texts) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: textItem.text,
          style: TextStyle(
            color: textItem.color,
            fontSize: textItem.fontSize,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // The position is already stored in the original image coordinates
      // No need to adjust for zoom here as the canvas is already transformed
      textPainter.paint(canvas, textItem.position);
    }
  }

  @override
  bool shouldRepaint(TextPainterOverlay oldDelegate) =>
      oldDelegate.texts != texts || oldDelegate.zoom != zoom;
}
