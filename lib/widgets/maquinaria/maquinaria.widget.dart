import 'package:flutter/material.dart';
import 'package:jfapp/constants.dart';
import 'dart:developer' as dev;
import 'package:jfapp/helpers/responsive_helper.dart';
import 'package:intl/intl.dart';
import 'package:jfapp/models/catalogo-maquinaria.model.dart';
import 'package:jfapp/models/concepto.model.dart';
import 'package:jfapp/models/guardar-catalogo-maquinaria.model.dart';
import 'package:jfapp/models/user.model.dart';
import 'package:jfapp/providers/maquinaria_provider.dart';
import 'package:jfapp/providers/model_provider.dart';
import 'package:jfapp/screens/maquinaria/agregar_maquinaria_screen.dart';

class MaquinariaWidget extends StatefulWidget {
  final UserModel user;
  final String token;
  final int obraId;
  final Responsive responsive;

  const MaquinariaWidget({
    Key? key,
    required this.user,
    required this.token,
    required this.obraId,
    required this.responsive,
  }) : super(key: key);

  @override
  _MaquinariaWidgetState createState() => _MaquinariaWidgetState();
}

class _MaquinariaWidgetState extends State<MaquinariaWidget> {
  List<GuardarCatalogoMaquinariaModel> maquinas = [];
  CatalogoMaquinariaResponse? catalogoMaquinaria;

  @override
  void initState() {
    super.initState();
    _cargaCatalogoMaquinaria();
    _cargarMaquinaria();
  }

  Future<void> _cargaCatalogoMaquinaria() async {
    catalogoMaquinaria = await ModelProvider.cargarCatalogoMaquinaria();
    setState(() {});
  }

  void _cargarMaquinaria() {
    setState(() {
      maquinas = MaquinariaProvider.getMaquinaria('maquinaria');
      print(maquinas);
    });
  }

  void _agregarMaquina(GuardarCatalogoMaquinariaModel nuevaMaquinaria) {
    setState(() {
      print('------------------------------');
      print(nuevaMaquinaria);
      MaquinariaProvider.addMaquinaria('maquinaria', nuevaMaquinaria);
      maquinas = MaquinariaProvider.getMaquinaria('maquinaria');
    });
  }

  void _eliminarMaquina(int index) {
    setState(() {
      MaquinariaProvider.removeMaquina('maquinaria', index);
      maquinas = MaquinariaProvider.getMaquinaria('maquinaria');
    });
  }

  void _editarAcarreo(int index) async {
    final maquinaEditar = maquinas[index];

    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgregarMaquinariaScreen(
          obraId: widget.obraId,
          user: widget.user,
          maquinaEditar: maquinaEditar, // Pasa el acarreo existente
        ),
      ),
    );

    if (resultado != null && resultado is GuardarCatalogoMaquinariaModel) {
      setState(() {
        MaquinariaProvider.updateMaquinaria('maquinaria', index, resultado);
        maquinas = MaquinariaProvider.getMaquinaria('maquinaria');
      });
    }
  }

  void _confirmarEliminacion(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar eliminación"),
          content: Text("¿Estás seguro de que deseas eliminar esta máquina?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                _eliminarMaquina(index);
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

  List<Maquinaria> _obtenerMaquinariaFaltante() {
    if (catalogoMaquinaria == null ||
        catalogoMaquinaria!.catalogoMaquinarias.isEmpty) {
      return [];
    }

    // Obtener IDs de máquinas ya agregadas
    final idsAgregados =
        maquinas.map((m) => m.maquinaria?.id).where((id) => id != null).toSet();

    // Obtener todas las máquinas del catálogo (aplanar la lista de familias)
    final todasLasMaquinas = catalogoMaquinaria!.catalogoMaquinarias
        .expand((familia) => familia.maquinarias)
        .toList();

    // Filtrar para obtener solo las no agregadas
    return todasLasMaquinas
        .where((maquinaCatalogo) => !idsAgregados.contains(maquinaCatalogo.id))
        .toList();
  }

  String _obtenerNombreFamilia(Maquinaria maquina) {
    if (catalogoMaquinaria == null) return '';

    final familia = catalogoMaquinaria!.catalogoMaquinarias.firstWhere(
      (f) => f.maquinarias.any((m) => m.id == maquina.id),
      orElse: () => FamiliaMaquinaria(
          id: -1, familia: 'Desconocida', maquinarias: [], operadores: []),
    );

    return familia.familia;
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
                          'Maquinaria',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final resultado = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AgregarMaquinariaScreen(
                                  obraId: widget.obraId,
                                  user: widget.user,
                                  maquinasCargadas: maquinas,
                                ),
                              ),
                            );

                            if (resultado != null &&
                                resultado is GuardarCatalogoMaquinariaModel) {
                              _agregarMaquina(resultado);
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
                        'Lista de maquinaria',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Divider(thickness: 1.5, color: Colors.grey[400]),
                  maquinas.isNotEmpty
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
                                      maquinas.asMap().entries.map((entry) {
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
                                                  text: 'Concepto: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(
                                                    text:
                                                        '${acarreo.concepto?.concepto}\n'),
                                                TextSpan(
                                                  text: 'Numero económico: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(
                                                    text:
                                                        '${acarreo.maquinaria?.numeroEconomico}\n'),
                                                TextSpan(
                                                  text: 'Operador: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(
                                                    text:
                                                        '${acarreo.operador?.nombre}\n'),
                                                TextSpan(
                                                  text: acarreo.horometro
                                                              ?.horometroInicial !=
                                                          null
                                                      ? 'Horometro inicial: ${acarreo.horometro!.horometroInicial}\n'
                                                      : '',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: acarreo.horometro
                                                              ?.horometroFinal !=
                                                          null
                                                      ? 'Horometro final: ${acarreo.horometro!.horometroFinal}\n'
                                                      : '',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                if (acarreo.observaciones !=
                                                    '') ...[
                                                  TextSpan(
                                                    text: 'Observaciones: ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                      text:
                                                          '${acarreo.observaciones}\n'),
                                                ]
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
          _buildMaquinariaFaltante(),
        ],
      ),
    );
  }

  Widget _buildMaquinariaFaltante() {
    final maquinariaFaltante = _obtenerMaquinariaFaltante();

    if (maquinariaFaltante.isEmpty) return SizedBox.shrink();

    // Agrupar por familia
    final maquinasPorFamilia = <String, List<Maquinaria>>{};
    for (var maquina in maquinariaFaltante) {
      final familia = _obtenerNombreFamilia(maquina);
      maquinasPorFamilia.putIfAbsent(familia, () => []).add(maquina);
    }

    // Ordenar alfabéticamente por nombre de familia
    final familiasOrdenadas = maquinasPorFamilia.keys.toList()..sort();

    return Container(
      margin: EdgeInsets.only(top: 15),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Maquinaria faltante por agregar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          Divider(thickness: 1, color: Colors.grey[400]),
          ConstrainedBox(
            constraints:
                BoxConstraints(maxHeight: 200), // Altura máxima con scroll
            child: ListView(
              shrinkWrap: true,
              children: familiasOrdenadas.map((familia) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: Text(
                        familia,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                    ...maquinasPorFamilia[familia]!.map((maquina) {
                      return Padding(
                        padding: EdgeInsets.fromLTRB(24, 4, 12, 4),
                        child: Text(
                          '• ${maquina.numeroEconomico}',
                          style: TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Método para construir el selector de hora

// Función para guardar los datos cuando cualquiera de los campos cambie
