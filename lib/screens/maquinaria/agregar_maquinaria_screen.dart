import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:jfapp/blocs/catalogo_motivos_inactividad_maquinaria/catalogo_motivos_inactividad_maquinaria_bloc.dart';
import 'package:jfapp/blocs/catalogo_motivos_inactividad_maquinaria/catalogo_motivos_inactividad_maquinaria_event.dart';
import 'package:jfapp/blocs/catalogo_motivos_inactividad_maquinaria/catalogo_motivos_inactividad_maquinaria_state.dart';
import 'package:jfapp/blocs/familias_maquinaria/familias_maquinaria_bloc.dart';
import 'package:jfapp/blocs/familias_maquinaria/familias_maquinaria_event.dart';
import 'package:jfapp/blocs/familias_maquinaria/familias_maquinaria_state.dart';
import 'package:jfapp/constants.dart';
import 'package:jfapp/helpers/responsive_helper.dart';
import 'package:jfapp/models/catalogo-maquinaria.model.dart';
import 'package:jfapp/models/catalogo-motivos-inactividad-maquinaria.model.dart';
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
  bool _catalogoMotivosInactividadListo = false;
  bool _isLoading = true;
  bool _mostrarDropdownMotivo = false;

  CatalogoMaquinariaResponse? catalogoMaquinaria;
  FamiliaMaquinaria? _selectedFamilia;
  Maquinaria? _selectedMaquinaria;
  Operador? _selectedOperador;

  MotivosInactividadMaquinariaModel? catalogoMotivosInactividad;
  MotivosInactividadMaquinaria? _selectedMotivo;

  final TextEditingController _descripcionController = TextEditingController();

  final TextEditingController _maquinariaController = TextEditingController();
  final TextEditingController _operadorController = TextEditingController();
  final TextEditingController _horometroInicialController =
      TextEditingController();
  final TextEditingController _horometroFinalController =
      TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();
  final TextEditingController _actividadController = TextEditingController();

  List<GuardarCatalogoMaquinariaModel> _maquinariaGuardada = [];

  List<Map<String, TextEditingController>> _horometros = [];

  Future<bool> tieneConexionInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  void initState() {
    super.initState();
    // print('Maquinas cargandas previamente -------');
    // print(widget.maquinasCargadas);
    _verificarConexionYCargarDatos();
    _cargarMaquinariaGuardada();

    _horometros.add({
      'inicial': TextEditingController(),
      'final': TextEditingController(),
    });

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

      final motivoInactividadBloc =
          context.read<CatalogoMotivosInactvidadMaquinariaBloc>();
      motivoInactividadBloc
          .add(CatalogoMotivosInactvidadMaquinariaInStartRequest(
        token: widget.user.token,
        obraId: widget.user.user!.obraId!,
      ));
    } else {
      // Si no hay conexión, cargar datos desde SharedPreferences
      catalogoMaquinaria = await ModelProvider.cargarCatalogoMaquinaria();
      catalogoMotivosInactividad =
          await ModelProvider.cargarCatalogoMotivosInactividad();

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
    // Verificar nuevamente que los catálogos no sean nulos y tengan datos
    if (catalogoMaquinaria == null ||
        catalogoMotivosInactividad == null ||
        catalogoMaquinaria!.catalogoMaquinarias.isEmpty) {
      //print("Catálogos no están listos aún");
      return;
    }

    if (widget.maquinaEditar!.motivoInactividadId != null) {
      try {
        _selectedMotivo =
            catalogoMotivosInactividad!.motivosInactividadMaquinaria.firstWhere(
          (motivo) => motivo.id == widget.maquinaEditar!.motivoInactividadId!,
          // orElse: () => widget.maquinaEditar!.motivoInactividadId,
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
        catalogoMotivosInactividad != null &&
        catalogoMaquinaria!.catalogoMaquinarias.isNotEmpty) {
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
    final horometroInicial = _horometroInicialController.text.isNotEmpty
        ? double.tryParse(_horometroInicialController.text)
        : null;

    final horometroFinal = _horometroFinalController.text.isNotEmpty
        ? double.tryParse(_horometroFinalController.text)
        : null;

    if (_selectedFamilia != null &&
        _selectedMaquinaria != null &&
        (_selectedOperador != null &&
            horometroInicial != null &&
            horometroFinal != null) &&
        _actividadController.text.isNotEmpty) {
      final horometro = Horometro(
        horometroInicial: horometroInicial,
        horometroFinal: horometroFinal,
      );

      final guardarMaquinaria = GuardarCatalogoMaquinariaModel(
          familia: _selectedFamilia,
          maquinaria: _selectedMaquinaria,
          operador: _selectedOperador,
          horometro: horometro,
          observaciones: _observacionesController.text,
          actividad: _actividadController.text,
          motivoInactividadId: _selectedMotivo?.id ?? 0);

      // print(guardarMaquinaria);
      // return;
      Navigator.pop(context, guardarMaquinaria);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complete todos los campos requeridos')),
      );
    }
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

                if (_catalogoMaquinariaListo) {
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
        BlocListener<CatalogoMotivosInactvidadMaquinariaBloc,
            CatalogoMotivosInactvidadMaquinariaState>(
          listener: (context, state) async {
            if (state is CatalogoMotivosInactvidadMaquinariaSuccess) {
              setState(() {
                catalogoMotivosInactividad = state.motivoInactividad;
                ModelProvider.guardarCatalogoMotivosInactividad(
                    catalogoMotivosInactividad!);
                _catalogoMotivosInactividadListo = true;

                if (_catalogoMaquinariaListo &&
                    _catalogoMotivosInactividadListo) {
                  _intentarCargarmaquinaEditar();
                  //_isLoading = false;
                }
              });
            } else if (state is CatalogoMotivosInactvidadMaquinariaFailure) {
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
                        if (_selectedMaquinaria != null)
                          /*Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Horómetros',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _horometros.length,
                                itemBuilder: (context, index) {
                                  final horometro = _horometros[index];
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Inicial',
                                                  style:
                                                      TextStyle(fontSize: 14)),
                                              TextFormField(
                                                controller:
                                                    horometro['inicial'],
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                                decoration: InputDecoration(
                                                  hintText: 'Inicial',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Final',
                                                  style:
                                                      TextStyle(fontSize: 14)),
                                              TextFormField(
                                                controller: horometro['final'],
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                                decoration: InputDecoration(
                                                  hintText: 'Final',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(Icons.add_circle,
                                              color: Colors.green),
                                          onPressed: () {
                                            setState(() {
                                              _horometros.add({
                                                'inicial':
                                                    TextEditingController(),
                                                'final':
                                                    TextEditingController(),
                                              });
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),*/

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
                                  SizedBox(width: 16),
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
                                            fillColor: Colors.white,
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
                        SizedBox(height: 20),

                        if (_selectedMaquinaria != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Actividades realizadas',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Divider(),
                              SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: TextFormField(
                                  controller: _actividadController,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    //labelText: 'Actividades realizadas',
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
                            ],
                          ),
                        SizedBox(height: 16),

                        // Dropdown para seleccionar el motivo de la inactividad
                        if (_selectedMaquinaria != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¿La maquinaria estuvo inactiva?',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              CheckboxListTile(
                                title: Text("Mostrar motivo de inactividad"),
                                value: _mostrarDropdownMotivo,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _mostrarDropdownMotivo = value ?? false;
                                    if (!_mostrarDropdownMotivo) {
                                      _selectedMotivo =
                                          null; // Limpiar si se desactiva
                                    }
                                  });
                                },
                              ),
                              if (_mostrarDropdownMotivo)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Motivo de inactividad',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    DropdownButton<
                                        MotivosInactividadMaquinaria>(
                                      value: _selectedMotivo,
                                      hint: Text(
                                          "Seleccione un motivo de inactividad de la maquinaria"),
                                      isExpanded: true,
                                      onChanged: (MotivosInactividadMaquinaria?
                                          newValue) {
                                        setState(() {
                                          _selectedMotivo = newValue;
                                        });
                                      },
                                      items: catalogoMotivosInactividad
                                              ?.motivosInactividadMaquinaria
                                              .map<
                                                      DropdownMenuItem<
                                                          MotivosInactividadMaquinaria>>(
                                                  (MotivosInactividadMaquinaria
                                                      motivo) {
                                            return DropdownMenuItem<
                                                MotivosInactividadMaquinaria>(
                                              value: motivo,
                                              child: Text(
                                                  motivo.motivoInactividad),
                                            );
                                          }).toList() ??
                                          [],
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                            ],
                          ),

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
