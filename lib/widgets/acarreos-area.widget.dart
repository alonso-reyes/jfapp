import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/constants.dart';
import 'dart:developer' as dev;
import 'package:jfapp/helpers/responsive_helper.dart';
import 'package:intl/intl.dart';
import 'package:jfapp/models/acarreos-area.model.dart';
import 'package:jfapp/models/user.model.dart';
import 'package:jfapp/providers/preference_provider.dart';
import 'package:jfapp/screens/acarreos_area_screen.dart';

class AcarreosAreaWidget extends StatefulWidget {
  final UserModel user;
  final String token;
  final int obraId;
  final Responsive responsive;

  const AcarreosAreaWidget({
    Key? key,
    required this.user,
    required this.token,
    required this.obraId,
    required this.responsive,
  }) : super(key: key);

  @override
  _AcarreosAreaWidgetState createState() => _AcarreosAreaWidgetState();
}

class _AcarreosAreaWidgetState extends State<AcarreosAreaWidget> {
  List<AcarreoArea> acarreos = [];

  @override
  void initState() {
    super.initState();
    _cargarAcarreos();
    // dev.log('ACARREOS AREA' + acarreos.toString());
  }

  void _cargarAcarreos() {
    setState(() {
      acarreos = PreferenceProvider.getAcarreosArea('acarreos_area');
    });
  }

  void _agregarAcarreo(AcarreoArea nuevoAcarreo) {
    setState(() {
      PreferenceProvider.addAcarreoArea('acarreos_area', nuevoAcarreo);
      acarreos = PreferenceProvider.getAcarreosArea('acarreos_area');
    });
  }

  void _eliminarAcarreo(int index) {
    setState(() {
      PreferenceProvider.removeAcarreoArea('acarreos_area', index);
      acarreos = PreferenceProvider.getAcarreosArea('acarreos_area');
    });
  }

  void _editarAcarreo(int index) async {
    final acarreoExistente = acarreos[index]; // Obtén el acarreo existente

    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AcarreosAreaScreen(
          obraId: widget.obraId,
          user: widget.user,
          acarreoExistente: acarreoExistente, // Pasa el acarreo existente
        ),
      ),
    );

    if (resultado != null && resultado is AcarreoArea) {
      setState(() {
        PreferenceProvider.updateAcarreoArea('acarreos_area', index, resultado);
        acarreos = PreferenceProvider.getAcarreosArea('acarreos_area');
      });
    }
  }

  void _confirmarEliminacion(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar eliminación"),
          content: Text("¿Estás seguro de que deseas eliminar este acarreo?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                _eliminarAcarreo(index);
                Navigator.of(context)
                    .pop(); // Cerrar el diálogo después de eliminar
              },
              child: Text("Eliminar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8), // Bordes redondeados
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
              // Fila superior con título y botón "Agregar"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Acarreos Area Opcional',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final resultado = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AcarreosAreaScreen(
                            obraId: widget.obraId,
                            user: widget.user,
                          ),
                        ),
                      );

                      if (resultado != null && resultado is AcarreoArea) {
                        _agregarAcarreo(resultado);
                      }
                    },
                    child: Container(
                      height: widget.responsive.dp(4),
                      width: widget.responsive.hp(12),
                      margin: EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: customBlack,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 3,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Agregar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Divider(thickness: 1.5, color: Colors.grey[400]),
              acarreos.isNotEmpty
                  ? Column(
                      children: [
                        // Encabezado fijo de la tabla
                        Table(
                          border: TableBorder.all(color: Colors.grey),
                          columnWidths: const {
                            0: FlexColumnWidth(3),
                            1: FlexColumnWidth(1),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(color: customBlack),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Detalles del Acarreo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Acciones',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Cuerpo scrollable de la tabla
                        SizedBox(
                          height: 200, // Ajusta la altura según necesites
                          child: SingleChildScrollView(
                            child: Table(
                              border: TableBorder.all(color: Colors.grey),
                              columnWidths: const {
                                0: FlexColumnWidth(3),
                                1: FlexColumnWidth(1),
                              },
                              children: acarreos.asMap().entries.map((entry) {
                                final index = entry.key;
                                final acarreo = entry.value;
                                return TableRow(
                                  decoration: BoxDecoration(
                                    color: index.isEven
                                        ? Colors.grey[300]
                                        : Colors.grey[400],
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Largo: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            TextSpan(
                                                text: '${acarreo.largo}\n'),
                                            TextSpan(
                                              text: 'Ancho: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            TextSpan(
                                                text: '${acarreo.ancho}\n'),
                                            TextSpan(
                                              text: 'Area: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            TextSpan(text: '${acarreo.area}\n'),
                                            TextSpan(
                                              text: 'Viajes: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            // TextSpan(
                                            //     text: '${acarreo.viajes}\n'),
                                            TextSpan(
                                              text: 'Observaciones: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            TextSpan(
                                                text:
                                                    '${acarreo.observaciones}\n'),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 8.0, // Espacio entre íconos
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: Colors.blue),
                                          onPressed: () =>
                                              _editarAcarreo(index),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _confirmarEliminacion(index),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                        'No hay datos',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
