import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/constants.dart';
import 'dart:developer' as dev;
import 'package:jfapp/helpers/responsive_helper.dart';
import 'package:intl/intl.dart';
import 'package:jfapp/models/catalogo-personal.model.dart';
import 'package:jfapp/models/guardar-catalogo-personal.model.dart';
import 'package:jfapp/models/user.model.dart';
import 'package:jfapp/providers/model_provider.dart';
import 'package:jfapp/providers/personal_provider.dart';
import 'package:jfapp/screens/personal/agregar_personal_screen.dart';

class PersonalWidgetV1 extends StatefulWidget {
  final UserModel user;
  final String token;
  final int obraId;
  final Responsive responsive;

  const PersonalWidgetV1({
    super.key,
    required this.user,
    required this.token,
    required this.obraId,
    required this.responsive,
  });

  @override
  _PersonalWidgetV1State createState() => _PersonalWidgetV1State();
}

class _PersonalWidgetV1State extends State<PersonalWidgetV1> {
  List<GuardarCatalogoPersonalModel> personales = [];
  CatalogoPersonalModel? catalogoPersonal;

  @override
  void initState() {
    super.initState();
    _cargarPersonal();
    _cargaCatalogoPersonal();
  }

  Future<void> _cargaCatalogoPersonal() async {
    catalogoPersonal = await ModelProvider.cargarCatalogoPersonal();
    setState(() {});
  }

  void _cargarPersonal() {
    setState(() {
      personales = PersonalProvider.getPersonal('personal');
    });
  }

  void _agregarPersona(GuardarCatalogoPersonalModel nuevaPersona) {
    setState(() {
      // print('------------------------------');
      // print(nuevaPersona);
      PersonalProvider.addPersonal('personal', nuevaPersona);
      personales = PersonalProvider.getPersonal('personal');
    });
  }

  void _eliminarPersona(int index) {
    setState(() {
      PersonalProvider.removePersonal('personal', index);
      personales = PersonalProvider.getPersonal('personal');
    });
  }

  void _editarPersona(int index) async {
    final personaExistente = personales[index];

    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgregarPersonalScreen(
          obraId: widget.obraId,
          user: widget.user,
          personalExistente: personaExistente,
        ),
      ),
    );

    if (resultado != null && resultado is GuardarCatalogoPersonalModel) {
      setState(() {
        PersonalProvider.updatePersonal('personal', index, resultado);
        personales = PersonalProvider.getPersonal('personal');
      });
    }
  }

  void _confirmarEliminacion(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar eliminación"),
          content: Text("¿Estás seguro de que deseas eliminar esta persona?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                _eliminarPersona(index);
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
      child: Column(
        children: [
          Padding(
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
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Personal',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final resultado = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AgregarPersonalScreen(
                                  obraId: widget.obraId,
                                  user: widget.user,
                                ),
                              ),
                            );

                            if (resultado != null &&
                                resultado is GuardarCatalogoPersonalModel) {
                              _agregarPersona(resultado);
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
                  ],
                ),
              ),
            ),
          ),
          Container(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lista de personal técnico-administrativo',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Divider(thickness: 1.5, color: Colors.grey[400]),
                  personales.isNotEmpty
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
                                        'Detalles',
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
                              height: 500,
                              child: SingleChildScrollView(
                                child: Table(
                                  border: TableBorder.all(color: Colors.grey),
                                  columnWidths: const {
                                    0: FlexColumnWidth(3),
                                    1: FlexColumnWidth(1),
                                  },
                                  children:
                                      personales.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final persona = entry.value;
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
                                                  text: 'Nombre: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(
                                                    text:
                                                        '${persona.personal?.nombre}\n'),
                                                TextSpan(
                                                  text: 'Puesto: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(
                                                    text:
                                                        '${persona.personal?.puesto}\n'),
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
                                                  _editarPersona(index),
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
        ],
      ),
    );
  }
}

/// Método para construir el selector de hora

// Función para guardar los datos cuando cualquiera de los campos cambie
