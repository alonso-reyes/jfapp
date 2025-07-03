import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:jfapp/blocs/concepto/concepto_bloc.dart';
import 'package:jfapp/blocs/concepto/concepto_event.dart';
import 'package:jfapp/blocs/concepto/concepto_state.dart';
import 'package:jfapp/blocs/familias_maquinaria/familias_maquinaria_bloc.dart';
import 'package:jfapp/blocs/familias_maquinaria/familias_maquinaria_event.dart';
import 'package:jfapp/blocs/familias_maquinaria/familias_maquinaria_state.dart';
import 'package:jfapp/constants.dart';
import 'package:jfapp/helpers/responsive_helper.dart';
import 'package:jfapp/models/catalogo-maquinaria.model.dart';
import 'package:jfapp/models/concepto.model.dart';
import 'package:jfapp/models/guardar-catalogo-maquinaria.model.dart';
import 'package:jfapp/models/user.model.dart';
import 'package:jfapp/providers/maquinaria_provider.dart';
import 'package:jfapp/providers/model_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'dart:developer' as dev;

class AgregarMaquinariaScreen extends StatefulWidget {
  final UserModel user;
  final int obraId;
  final GuardarCatalogoMaquinariaModel? maquinaEditar;
  final List<GuardarCatalogoMaquinariaModel>? maquinasCargadas;

  const AgregarMaquinariaScreen(
      {super.key,
      required this.user,
      required this.obraId,
      this.maquinaEditar,
      this.maquinasCargadas});

  @override
  _AgregarMaquinariaScreenState createState() =>
      _AgregarMaquinariaScreenState();
}

class _AgregarMaquinariaScreenState extends State<AgregarMaquinariaScreen> {
  bool _tieneConexion = false;
  bool _catalogoMaquinariaListo = false;
  bool _catalogoConceptosListo = false;
  bool _isLoading = true;

  CatalogoMaquinariaResponse? catalogoMaquinaria;
  FamiliaMaquinaria? _selectedFamilia;
  Maquinaria? _selectedMaquinaria;
  Operador? _selectedOperador;

  ConceptoModel? catalogoConceptos;
  Concepto? _selectedConcepto;

  final TextEditingController _descripcionController = TextEditingController();

  final TextEditingController _maquinariaController = TextEditingController();
  final TextEditingController _operadorController = TextEditingController();
  final TextEditingController _horometroInicialController =
      TextEditingController();
  final TextEditingController _horometroFinalController =
      TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();

  List<GuardarCatalogoMaquinariaModel> _maquinariaGuardada = [];

  Future<bool> tieneConexionInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  void initState() {
    super.initState();
    print('Maquinas cargandas previamente -------');
    print(widget.maquinasCargadas);
    _verificarConexionYCargarDatos();
    _cargarMaquinariaGuardada();

    // Verificar si el objeto maquinaEditar no es nulo
    if (widget.maquinaEditar != null) {
      _cargarDatosmaquinaEditar();
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _verificarConexionYCargarDatos() async {
    _tieneConexion = await tieneConexionInternet();
    //print(_tieneConexion);

    if (_tieneConexion) {
      // Si hay conexión, obtener datos desde la API a través del Bloc
      final familiaMaquinariaBloc = context.read<FamiliaMaquinariaBloc>();
      familiaMaquinariaBloc.add(FamiliaMaquinariaInStartRequest(
        token: widget.user.token,
        obraId: widget.user.user!.obraId!,
      ));

      final conceptoBloc = context.read<ConceptoBloc>();
      conceptoBloc.add(ConceptoInStartRequest(
        token: widget.user.token,
        obraId: widget.user.user!.obraId!,
      ));
    } else {
      // Si no hay conexión, cargar datos desde SharedPreferences
      catalogoMaquinaria = await ModelProvider.cargarCatalogoMaquinaria();
      catalogoConceptos = await ModelProvider.cargarCatalogoConcepto();

      _intentarCargarmaquinaEditar();
    }
    //await Future.delayed(Duration(seconds: 3));

    setState(() {
      //_isLoading = false;
    });
  }

  void _cargarMaquinariaGuardada() async {
    setState(() {
      _maquinariaGuardada =
          MaquinariaProvider.getMaquinaria('maquinaria') ?? [];
    });
  }

  void _cargarDatosmaquinaEditar() {
    // print("Intentando cargar datos de maquina existente");
    // print(
    //     "Familia maquinarias: ${catalogoMaquinaria?.catalogoMaquinarias.length ?? 'nulo'}");
    // print("Conceptos: ${catalogoConceptos?.conceptos.length ?? 'nulo'}");

    // Verificar nuevamente que los catálogos no sean nulos y tengan datos
    if (catalogoMaquinaria == null ||
        catalogoConceptos == null ||
        catalogoMaquinaria!.catalogoMaquinarias.isEmpty ||
        catalogoConceptos!.conceptos.isEmpty) {
      //print("Catálogos no están listos aún");
      return;
    }

    // Buscar y establecer el concepto
    if (widget.maquinaEditar!.concepto != null) {
      try {
        _selectedConcepto = catalogoConceptos!.conceptos.firstWhere(
          (concepto) => concepto.id == widget.maquinaEditar!.concepto!.id,
          orElse: () => widget.maquinaEditar!.concepto!,
        );
        //print("Concepto seleccionado: ${_selectedConcepto?.concepto}");
      } catch (e) {
        //print("Error al seleccionar concepto: $e");
      }
    }

    // Buscar y establecer la familia
    if (widget.maquinaEditar!.familia != null) {
      try {
        _selectedFamilia = catalogoMaquinaria!.catalogoMaquinarias.firstWhere(
          (familia) => familia.id == widget.maquinaEditar!.familia!.id,
          orElse: () => widget.maquinaEditar!.familia!,
        );
        //print("Familia seleccionada: ${_selectedFamilia?.familia}");
      } catch (e) {
        print("Error al seleccionar familia: $e");
      }
    }

    // Ahora verificamos si _selectedFamilia tiene datos de maquinarias y operadores
    if (_selectedFamilia != null &&
        _selectedFamilia!.maquinarias.isNotEmpty &&
        _selectedFamilia!.operadores.isNotEmpty) {
      // Buscar y establecer la maquinaria
      if (widget.maquinaEditar!.maquinaria != null) {
        try {
          _selectedMaquinaria = _selectedFamilia!.maquinarias.firstWhere(
            (maquinaria) =>
                maquinaria.id == widget.maquinaEditar!.maquinaria!.id,
            orElse: () => widget.maquinaEditar!.maquinaria!,
          );
          _maquinariaController.text = _selectedMaquinaria!.numeroEconomico;
          // print(
          //     "Maquinaria seleccionada: ${_selectedMaquinaria?.numeroEconomico}");
        } catch (e) {
          print("Error al seleccionar maquinaria: $e");
        }
      }

      // Buscar y establecer el operador
      if (widget.maquinaEditar!.operador != null) {
        try {
          _selectedOperador = _selectedFamilia!.operadores.firstWhere(
            (operador) => operador.id == widget.maquinaEditar!.operador!.id,
            orElse: () => widget.maquinaEditar!.operador!,
          );
          _operadorController.text = _selectedOperador!.nombre!;
          //print("Operador seleccionado: ${_selectedOperador?.nombre}");
        } catch (e) {
          print("Error al seleccionar operador: $e");
        }
      }
    }

    if (widget.maquinaEditar!.horometro != null) {
      _horometroInicialController.text =
          widget.maquinaEditar!.horometro!.horometroInicial?.toString() ?? '';
      _horometroFinalController.text =
          widget.maquinaEditar!.horometro!.horometroFinal?.toString() ?? '';
      //print("Horómetro inicial: ${_horometroInicialController.text}");
      //print("Horómetro final: ${_horometroFinalController.text}");
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _intentarCargarmaquinaEditar() {
    if (widget.maquinaEditar != null &&
        catalogoMaquinaria != null &&
        catalogoConceptos != null &&
        catalogoMaquinaria!.catalogoMaquinarias.isNotEmpty &&
        catalogoConceptos!.conceptos.isNotEmpty) {
      _cargarDatosmaquinaEditar();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Validar que el horómetro final no sea menor que el inicial
  bool _validarHorometros() {
    //dev.log('validando');
    final horometroInicial =
        double.tryParse(_horometroInicialController.text) ?? 0;
    final horometroFinal = double.tryParse(_horometroFinalController.text) ?? 0;

    if (horometroFinal < horometroInicial) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('El horómetro final no puede ser menor que el inicial')),
      );
      return false;
    }
    return true;
  }

  // void _guardarMaquinaria() {
  //   if (!_validarHorometros()) {
  //     return;
  //   }
  //   final horometroInicial = _horometroInicialController.text.isNotEmpty
  //       ? double.tryParse(_horometroInicialController.text)
  //       : null;

  //   final horometroFinal = _horometroFinalController.text.isNotEmpty
  //       ? double.tryParse(_horometroFinalController.text)
  //       : null;

  //   if (_selectedConcepto != null &&
  //       _selectedFamilia != null &&
  //       _selectedMaquinaria != null &&
  //       _selectedOperador != null &&
  //       horometroInicial != null &&
  //       horometroFinal != null) {
  //     final horometro = Horometro(
  //       horometroInicial: horometroInicial,
  //       horometroFinal: horometroFinal,
  //     );

  //     final guardarMaquinaria = GuardarCatalogoMaquinariaModel(
  //         concepto: _selectedConcepto,
  //         familia: _selectedFamilia,
  //         maquinaria: _selectedMaquinaria,
  //         operador: _selectedOperador,
  //         horometro: horometro,
  //         observaciones: _observacionesController.text);
  //     print(_selectedConcepto);
  //     print(guardarMaquinaria);

  //     //Navigator.pop(context, guardarMaquinaria);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Complete todos los campos')),
  //     );
  //   }
  // }

  void _guardarMaquinaria() {
    final bool esConceptoInOMtto = _esConceptoInOMtto();

    if (!esConceptoInOMtto && !_validarHorometros()) {
      return;
    }

    final horometroInicial = esConceptoInOMtto
        ? null
        : (_horometroInicialController.text.isNotEmpty
            ? double.tryParse(_horometroInicialController.text)
            : null);

    final horometroFinal = esConceptoInOMtto
        ? null
        : (_horometroFinalController.text.isNotEmpty
            ? double.tryParse(_horometroFinalController.text)
            : null);

    if (_selectedConcepto != null &&
        _selectedFamilia != null &&
        _selectedMaquinaria != null &&
        (esConceptoInOMtto ||
            (_selectedOperador != null &&
                horometroInicial != null &&
                horometroFinal != null))) {
      final horometro = Horometro(
        horometroInicial: horometroInicial,
        horometroFinal: horometroFinal,
      );

      final guardarMaquinaria = GuardarCatalogoMaquinariaModel(
        concepto: _selectedConcepto,
        familia: _selectedFamilia,
        maquinaria: _selectedMaquinaria,
        operador: _selectedOperador,
        horometro: horometro,
        observaciones: _observacionesController.text,
      );

      print(guardarMaquinaria);
      //return;
      Navigator.pop(context, guardarMaquinaria);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complete todos los campos requeridos')),
      );
    }
  }

  bool _esConceptoInOMtto() {
    return _selectedConcepto?.concepto?.toLowerCase().contains('in') == true ||
        _selectedConcepto?.concepto?.toLowerCase().contains('mtto') == true;
  }

  double? _obtenerUltimoHorometroFinal() {
    if (_selectedMaquinaria == null || widget.maquinasCargadas == null) {
      return null;
    }

    // Filtrar máquinas del mismo tipo
    final maquinasFiltradas = widget.maquinasCargadas!
        .where((m) => m.maquinaria?.id == _selectedMaquinaria?.id)
        .toList();

    if (maquinasFiltradas.isEmpty) {
      return null;
    }

    // Ordenar por fecha (asumiendo que tienen timestamp) o tomar la última
    final ultimaMaquina = maquinasFiltradas.last;
    return ultimaMaquina.horometro?.horometroFinal;
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);

    // Mostrar un indicador de carga mientras se verifica la conectividad
    return MultiBlocListener(
      listeners: [
        BlocListener<FamiliaMaquinariaBloc, FamiliaMaquinariaState>(
          listener: (context, state) async {
            if (state is FamiliaMaquinariaSuccess) {
              setState(() {
                catalogoMaquinaria = state.catalogoMaquinaria;
                ModelProvider.guardarCatalogoMaquinaria(catalogoMaquinaria!);
                _catalogoMaquinariaListo = true;

                if (_catalogoMaquinariaListo && _catalogoConceptosListo) {
                  _intentarCargarmaquinaEditar();
                  //_isLoading = false;
                }
              });

              // await Future.delayed(Duration(seconds: 1));

              // setState(() {
              //   _isLoading =
              //       false; // Ocultar el indicador de carga después del retraso
              // });
            } else if (state is FamiliaMaquinariaFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Error al cargar los datos desde la API')),
              );
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
        BlocListener<ConceptoBloc, ConceptoState>(
          listener: (context, state) async {
            if (state is ConceptoSuccess) {
              setState(() {
                catalogoConceptos = state.concepto;
                ModelProvider.guardarCatalogoConceptos(catalogoConceptos!);
                _catalogoConceptosListo = true;

                if (_catalogoMaquinariaListo && _catalogoConceptosListo) {
                  _intentarCargarmaquinaEditar();
                  //_isLoading = false;
                }
              });

              // await Future.delayed(Duration(seconds: 1));

              // setState(() {
              //   _isLoading =
              //       false; // Ocultar el indicador de carga después del retraso
              // });
            } else if (state is ConceptoFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Error al cargar los datos desde la API')),
              );
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: mainBgColor,
        appBar: AppBar(
          title: Text(
            'Agregar maquinaria',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: customBlack,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: SafeArea(
          child: _isLoading
              ? Center(
                  child:
                      CircularProgressIndicator(), // Mostrar el indicador de carga
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Mostrar el mensaje solo cuando la verificación esté completa y no haya conexión
                        if (!_tieneConexion)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Modo sin conexión: usando datos locales',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),

                        // Dropdown para seleccionar el concepto
                        Text(
                          'Actividad/concepto',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<Concepto>(
                          value: _selectedConcepto,
                          hint: Text("Seleccione una actividad"),
                          isExpanded: true,
                          onChanged: (Concepto? newValue) {
                            setState(() {
                              _selectedConcepto = newValue;

                              _descripcionController.text =
                                  newValue?.descripcion ?? '';

                              if (_esConceptoInOMtto()) {
                                _selectedOperador = null;
                                _maquinariaController.clear();
                                _operadorController.clear();
                                _horometroInicialController.clear();
                                _horometroFinalController.clear();
                              }
                            });
                          },
                          items: catalogoConceptos?.conceptos
                                  .map<DropdownMenuItem<Concepto>>(
                                      (Concepto concepto) {
                                return DropdownMenuItem<Concepto>(
                                  value: concepto,
                                  child: Text(concepto.concepto),
                                );
                                // final displayText = concepto
                                //         .descripcion.isNotEmpty
                                //     ? '${concepto.concepto} - ${concepto.descripcion}'
                                //     : concepto.concepto;

                                // return DropdownMenuItem<Concepto>(
                                //     value: concepto,
                                //     child: Text(
                                //       displayText,
                                //       overflow: TextOverflow
                                //           .ellipsis, // Para texto largo
                                //     ));
                              }).toList() ??
                              [],
                        ),
                        SizedBox(height: 10),
                        InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Descripción',
                              prefixIcon: Icon(Icons.description, size: 20),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            child: Text(
                              _selectedConcepto?.descripcion ??
                                  'Seleccione un concepto para ver su descripción',
                              style: TextStyle(fontSize: 14),
                            )),
                        // TextFormField(
                        //   controller: _descripcionController,
                        //   decoration: InputDecoration(
                        //     labelText: 'Descripción del concepto',
                        //     border: OutlineInputBorder(),
                        //     filled: true,
                        //     fillColor: Colors.grey[100],
                        //     contentPadding: EdgeInsets.symmetric(
                        //         horizontal: 12, vertical: 12),
                        //   ),
                        //   readOnly: true,
                        //   maxLines: 3,
                        // ),

                        SizedBox(height: 16),

                        // Dropdown para seleccionar la familia
                        Text(
                          'Familia de Maquinaria',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<FamiliaMaquinaria>(
                          value: _selectedFamilia,
                          hint: Text("Seleccione una familia"),
                          isExpanded: true,
                          onChanged: (FamiliaMaquinaria? newValue) {
                            setState(() {
                              _selectedFamilia = newValue;
                              _selectedMaquinaria = null;
                              _selectedOperador = null;
                              _maquinariaController.clear();
                              _operadorController.clear();
                              _horometroInicialController.clear();
                              _horometroFinalController.clear();
                            });
                          },
                          items: catalogoMaquinaria?.catalogoMaquinarias
                                  .map<DropdownMenuItem<FamiliaMaquinaria>>(
                                      (FamiliaMaquinaria familia) {
                                return DropdownMenuItem<FamiliaMaquinaria>(
                                  value: familia,
                                  child: Text(familia.familia),
                                );
                              }).toList() ??
                              [],
                        ),
                        SizedBox(height: 16),

                        // Buscador de maquinarias
                        if (_selectedFamilia != null)
                          Column(
                            children: [
                              Text(
                                'Maquinaria',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              TypeAheadField<Maquinaria>(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: _maquinariaController,
                                  decoration: InputDecoration(
                                    hintText: 'Buscar maquinaria...',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                suggestionsCallback: (pattern) async {
                                  return _selectedFamilia!.maquinarias
                                      .where((maquinaria) => maquinaria
                                          .numeroEconomico
                                          .toLowerCase()
                                          .contains(pattern.toLowerCase()))
                                      .toList();

                                  // Validacion para no agregar una maquina que ya fue seleccionada
                                  /*return _selectedFamilia!.maquinarias
                                      .where((maquina) {
                                    bool yaSeleccionado =
                                        _maquinariaGuardada.any((p) =>
                                            p.maquinaria!.id == maquina.id);
                                    return maquina.numeroEconomico!
                                            .toLowerCase()
                                            .contains(pattern.toLowerCase()) &&
                                        !yaSeleccionado; // Excluir los que ya están en la lista
                                  }).toList();*/
                                },
                                itemBuilder: (context, Maquinaria maquinaria) {
                                  return ListTile(
                                    title: Text(maquinaria.numeroEconomico),
                                    subtitle: Text(
                                      'Horómetro: ${maquinaria.horometro.horometroInicial ?? 'N/A'} - ${maquinaria.horometro.horometroFinal ?? 'N/A'}',
                                    ),
                                  );
                                },
                                onSuggestionSelected: (Maquinaria maquinaria) {
                                  setState(() {
                                    _selectedMaquinaria = maquinaria;
                                    _maquinariaController.text =
                                        maquinaria.numeroEconomico;
                                    _selectedOperador = null;
                                    _operadorController.clear();

                                    final ultimoHorometro =
                                        _obtenerUltimoHorometroFinal();
                                    if (ultimoHorometro != null) {
                                      _horometroInicialController.text =
                                          ultimoHorometro.toStringAsFixed(2);
                                    } else {
                                      // Si no hay registro previo, usar el valor de la máquina si existe
                                      _horometroInicialController.text =
                                          maquinaria.horometro.horometroInicial
                                                  ?.toString() ??
                                              '';
                                    }
                                    _horometroFinalController.text = '';

                                    // Llenar los campos de horómetro si ya tienen valores
                                    /* _horometroInicialController.text =
                                        maquinaria.horometro.horometroInicial
                                                ?.toString() ??
                                            '';
                                    _horometroFinalController.text = maquinaria
                                            .horometro.horometroFinal
                                            ?.toString() ??
                                        '';*/
                                  });
                                },
                              ),
                            ],
                          ),
                        SizedBox(height: 16),

                        // Buscador de operadores
                        //if (_selectedMaquinaria != null)
                        if (_selectedMaquinaria != null)
                          Column(
                            children: [
                              Text(
                                'Operadores',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              TypeAheadField<Operador>(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: _operadorController,
                                  decoration: InputDecoration(
                                    hintText: 'Buscar operador...',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                suggestionsCallback: (pattern) async {
                                  return _selectedFamilia!.operadores
                                      .where((operador) => operador.nombre!
                                          .toLowerCase()
                                          .contains(pattern.toLowerCase()))
                                      .toList();
                                },
                                itemBuilder: (context, Operador operador) {
                                  return ListTile(
                                    title: Text(operador.nombre!),
                                  );
                                },
                                onSuggestionSelected: (Operador operador) {
                                  setState(() {
                                    _selectedOperador = operador;
                                    _operadorController.text = operador.nombre!;
                                  });
                                },
                              ),
                            ],
                          ),
                        SizedBox(height: 16),

                        // Campos para horómetro inicial y final
                        //if (_selectedMaquinaria != null)
                        if (_selectedMaquinaria != null &&
                            !_esConceptoInOMtto())
                          Column(
                            children: [
                              Text(
                                'Horómetros',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Horómetro Inicial',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        TextFormField(
                                          controller:
                                              _horometroInicialController,
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          enabled: _selectedMaquinaria!
                                                  .horometro.horometroInicial ==
                                              0,
                                          decoration: InputDecoration(
                                            hintText: 'Inicial',
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Este campo es obligatorio';
                                            }
                                            if (double.tryParse(value) ==
                                                null) {
                                              return 'Ingrese un número válido';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      width: 16), // Espacio entre los campos
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Horómetro Final',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        TextFormField(
                                          controller: _horometroFinalController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            hintText: 'Final',
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Este campo es obligatorio';
                                            }
                                            if (!_validarHorometros()) {
                                              return 'El horómetro final no puede ser menor que el inicial';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        SizedBox(height: 16),
                        if (_esConceptoInOMtto())
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
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
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
                            ),
                          ),
                        SizedBox(height: 16),

                        // Botón para guardar
                        if (_selectedMaquinaria != null)
                          Center(
                            child: GestureDetector(
                              onTap: _guardarMaquinaria,
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
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
