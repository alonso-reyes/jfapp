import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:jfapp/blocs/personal/personal_bloc.dart';
import 'package:jfapp/blocs/personal/personal_event.dart';
import 'package:jfapp/blocs/personal/personal_state.dart';
import 'package:jfapp/constants.dart';
import 'package:jfapp/helpers/responsive_helper.dart';
import 'package:jfapp/models/catalogo-personal.model.dart';
import 'package:jfapp/models/guardar-catalogo-personal.model.dart';
import 'package:jfapp/models/user.model.dart';
import 'package:jfapp/providers/model_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:jfapp/providers/personal_provider.dart';

class AgregarPersonalScreen extends StatefulWidget {
  final UserModel user;
  final int obraId;
  final GuardarCatalogoPersonalModel? personalExistente;

  const AgregarPersonalScreen({
    super.key,
    required this.user,
    required this.obraId,
    this.personalExistente,
  });

  @override
  _AgregarPersonalScreenState createState() => _AgregarPersonalScreenState();
}

class _AgregarPersonalScreenState extends State<AgregarPersonalScreen> {
  bool _tieneConexion = false;
  bool _catalogoPersonalListo = false;
  bool _isLoading = true;

  CatalogoPersonalModel? catalogoPersonal;
  Personal? _selectedPersonal;

  final TextEditingController _personalController = TextEditingController();
  final TextEditingController _puestoController = TextEditingController();

  List<GuardarCatalogoPersonalModel> _personalGuardado = [];

  Future<bool> tieneConexionInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  void initState() {
    super.initState();

    _verificarConexionYCargarDatos();
    _cargarPersonalGuardado();

    if (widget.personalExistente != null) {
      _cargarDatosPersonalExistente();
    }
  }

  Future<void> _verificarConexionYCargarDatos() async {
    _tieneConexion = await tieneConexionInternet();

    if (_tieneConexion) {
      final personalBloc = context.read<CatalogoPersonalBloc>();
      personalBloc.add(CatalogoPersonalInStartRequest(
        token: widget.user.token,
        obraId: widget.user.user!.obraId!,
      ));
    } else {
      catalogoPersonal = await ModelProvider.cargarCatalogoPersonal();
      _intentarCargarPersonalExistente();
    }

    setState(() {
      //_isLoading = false;
    });
  }

  void _cargarPersonalGuardado() async {
    setState(() {
      _personalGuardado = PersonalProvider.getPersonal('personal') ?? [];
    });
  }

  void _cargarDatosPersonalExistente() {
    // print(
    //     "Familia maquinarias: ${catalogoPersonal?.personal.length ?? 'nulo'}");

    if (catalogoPersonal == null) {
      return;
    }

    if (widget.personalExistente!.personal != null) {
      try {
        _selectedPersonal = catalogoPersonal!.personal.firstWhere(
          (personal) => personal.id == widget.personalExistente!.personal!.id,
          orElse: () => widget.personalExistente!.personal!,
        );

        // ✅ Asegúrate de llenar los controladores de texto
        _personalController.text = _selectedPersonal?.nombre ?? '';
        _puestoController.text = _selectedPersonal?.puesto ?? '';

        setState(() {});
      } catch (e) {
        print("Error al seleccionar el personal: $e");
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _intentarCargarPersonalExistente() {
    if (widget.personalExistente != null && catalogoPersonal != null) {
      _cargarDatosPersonalExistente();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _guardarPersonal() {
    if (_selectedPersonal != null) {
      final guardarPersonal =
          GuardarCatalogoPersonalModel(personal: _selectedPersonal);
      Navigator.pop(context, guardarPersonal);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, complete todos los campos.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<CatalogoPersonalBloc, CatalogoPersonalState>(
            listener: (context, state) {
          //print('Listener detected state: $state');
          if (state is CatalogoPersonalSuccess) {
            setState(() {
              catalogoPersonal = state.personal;
              ModelProvider.guardarCatalogoPersonal(catalogoPersonal!);
              _catalogoPersonalListo = true;

              if (_catalogoPersonalListo) {
                _intentarCargarPersonalExistente();
                //_isLoading = false;
              }
            });
          } else if (state is CatalogoPersonalFailure) {}
        }),
      ],
      child: Scaffold(
        backgroundColor: mainBgColor,
        appBar: AppBar(
          title: Text(
            'Agregar personal',
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
                        // Dropdown para seleccionar la familia
                        Text(
                          'Personal',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        TypeAheadField<Personal>(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: _personalController,
                            decoration: InputDecoration(
                              hintText: 'Buscar personal...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          suggestionsCallback: (pattern) async {
                            // return catalogoPersonal!.personal
                            //     .where((personal) =>
                            //         personal.nombre!
                            //             .toLowerCase()
                            //             .contains(pattern.toLowerCase()) &&
                            //         personal.id !=
                            //             _selectedPersonal
                            //                 ?.id)
                            //     .toList();
                            return catalogoPersonal!.personal.where((personal) {
                              // Verifica si el personal ya ha sido seleccionado
                              bool yaSeleccionado = _personalGuardado
                                  .any((p) => p.personal!.id == personal.id);
                              return personal.nombre!
                                      .toLowerCase()
                                      .contains(pattern.toLowerCase()) &&
                                  !yaSeleccionado; // Excluir los que ya están en la lista
                            }).toList();
                          },
                          itemBuilder: (context, Personal personal) {
                            return ListTile(
                              title: Text(personal.nombre ?? ''),
                            );
                          },
                          onSuggestionSelected: (Personal personal) {
                            setState(() {
                              _selectedPersonal = personal;
                              _personalController.text = personal.nombre ?? '';
                              _puestoController.text = personal.puesto ?? '';
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _puestoController,
                          decoration: InputDecoration(
                            labelText: 'Puesto',
                            border: OutlineInputBorder(),
                          ),
                          readOnly:
                              true, // Para evitar que lo editen manualmente
                        ),

                        SizedBox(height: 16),

                        // Botón para guardar
                        if (_selectedPersonal != null)
                          Center(
                            child: GestureDetector(
                              onTap: _guardarPersonal,
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
