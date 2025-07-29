import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jfapp/blocs/catalogo_motivos_inactividad_maquinaria/catalogo_motivos_inactividad_maquinaria_bloc.dart';
import 'package:jfapp/blocs/catalogo_motivos_inactividad_maquinaria/catalogo_motivos_inactividad_maquinaria_event.dart';
import 'package:jfapp/blocs/catalogo_motivos_inactividad_maquinaria/catalogo_motivos_inactividad_maquinaria_state.dart';
import 'package:jfapp/blocs/concepto/concepto_bloc.dart';
import 'package:jfapp/blocs/concepto/concepto_event.dart';
import 'package:jfapp/blocs/concepto/concepto_state.dart';
import 'package:jfapp/blocs/familias_maquinaria/familias_maquinaria_bloc.dart';
import 'package:jfapp/blocs/familias_maquinaria/familias_maquinaria_event.dart';
import 'package:jfapp/blocs/familias_maquinaria/familias_maquinaria_state.dart';
import 'package:jfapp/blocs/generales/generales_bloc.dart';
import 'package:jfapp/blocs/generales/generales_event.dart';
import 'package:jfapp/blocs/generales/generales_state.dart';
import 'package:jfapp/blocs/logout/logout_bloc.dart';
import 'package:jfapp/blocs/logout/logout_state.dart';
import 'package:jfapp/blocs/personal/personal_bloc.dart';
import 'package:jfapp/blocs/personal/personal_event.dart';
import 'package:jfapp/blocs/personal/personal_state.dart';
import 'package:jfapp/constants.dart';
import 'package:jfapp/helpers/api/api-helper.dart';
import 'package:jfapp/helpers/campos-generales-validation.helper.dart';
import 'package:jfapp/helpers/responsive_helper.dart';
import 'package:jfapp/helpers/turno-validation.helper.dart';
import 'package:jfapp/helpers/zona-trabajo-validation.helper.dart';
import 'package:jfapp/models/catalogo-generales.model.dart';
import 'package:jfapp/models/catalogo-maquinaria.model.dart';
import 'package:jfapp/models/catalogo-motivos-inactividad-maquinaria.model.dart';
import 'package:jfapp/models/catalogo-personal.model.dart';
import 'package:jfapp/models/concepto.model.dart';
import 'package:jfapp/models/turno.model.dart';
import 'package:jfapp/models/user.model.dart';
import 'package:jfapp/models/zonas-trabajo.model.dart';
import 'package:jfapp/providers/maquinaria_provider.dart';
import 'package:jfapp/providers/model_provider.dart';
import 'package:jfapp/providers/personal_provider.dart';
import 'package:jfapp/providers/photo_provider.dart';
import 'package:jfapp/providers/preference_provider.dart';
import 'package:jfapp/screens/jefe_frente_guardar/guardar_reporte_screen.dart';
import 'package:jfapp/screens/login_screen.dart';
import 'package:jfapp/widgets/acarreos-agua.widget.dart';
import 'package:jfapp/widgets/acarreos-area.widget.dart';
import 'package:jfapp/widgets/acarreos-metro.widget.dart';
import 'package:jfapp/widgets/acarreos-volumen.widget.dart';
import 'package:jfapp/widgets/fotografias/imagen.widget.dart';
import 'package:jfapp/widgets/generales.widget.dart';
import 'package:jfapp/widgets/maquinaria/maquinaria.widget.dart';
import 'package:jfapp/widgets/personal/personal.widget.dart';
import 'package:jfapp/widgets/user-drawer.widget.dart';
import 'dart:developer' as dev;

import 'package:http/http.dart' as http;

class JfMainScreen extends StatefulWidget {
  final UserModel user;

  const JfMainScreen({super.key, required this.user});

  @override
  _JfMainScreenState createState() => _JfMainScreenState();
}

class _JfMainScreenState extends State<JfMainScreen>
    with SingleTickerProviderStateMixin {
  bool _tieneConexion = false;
  bool _isLoading = true;
  late TabController _tabController;
  String? username;
  // final TextEditingController _observacionesController =
  //     TextEditingController();

  // Catálogos
  CatalogoGeneralesModel? catalogoGenerales;
  CatalogoMaquinariaResponse? catalogoMaquinaria;
  ConceptoModel? catalogoConceptos;
  TurnoModel? catalogoTurnos;
  ZonasTrabajoModel? catalogoZonas;
  CatalogoPersonalModel? catalogoPersonal;
  MotivosInactividadMaquinariaModel? catalogoMotivoInactividadMaquinaria;

  Future<bool> tieneConexionInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _inicializarCatalogos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    // _observacionesController.dispose();
    super.dispose();
  }

  /// Método principal para inicializar los catálogos
  Future<void> _inicializarCatalogos() async {
    try {
      setState(() {
        _isLoading = true;
      });

      dev.log('Inicializando catálogos...');

      // Verificar conexión a internet
      _tieneConexion = await tieneConexionInternet();
      dev.log('Estado de conexión: $_tieneConexion');

      if (_tieneConexion) {
        await _cargarCatalogosConInternet();
      } else {
        await _cargarCatalogosDesdePreferencias();
      }

      dev.log('Catálogos inicializados correctamente');
    } catch (e) {
      dev.log('Error al inicializar catálogos: $e');
      // En caso de error, intentar cargar solo desde preferencias
      await _cargarCatalogosDesdePreferencias();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Carga catálogos cuando hay internet (desde API con fallback a preferencias)
  Future<void> _cargarCatalogosConInternet() async {
    try {
      dev.log('Cargando catálogos desde API...');

      // Primero cargar desde preferencias como fallback
      await _cargarCatalogosDesdePreferencias();

      // Luego intentar actualizar desde API
      dev.log('Disparando eventos de los BLoCs...');
      await _cargarCatalogoConceptos();
      await _cargarCatalogoGenerales();
      await _cargarCatalogoMaquinaria();
      await _cargarCatalogoPersonal();
      await _cargarCatalogoMotivosInactividad();

      dev.log('Eventos de BLoCs enviados correctamente');
    } catch (e) {
      dev.log('Error al cargar catálogos con internet: $e');
      // Si falla, al menos tenemos los datos de preferencias
    }
  }

  /// Carga catálogos solo desde preferencias (modo offline)
  Future<void> _cargarCatalogosDesdePreferencias() async {
    try {
      dev.log('Cargando catálogos desde preferencias...');

      final results = await Future.wait([
        ModelProvider.cargarCatalogoConcepto(),
        ModelProvider.cargarCatalogoGenerales(),
        ModelProvider.cargarCatalogoMaquinaria(),
        ModelProvider.cargarCatalogoPersonal(),
        ModelProvider.cargarCatalogoMotivosInactividad(),
      ]);

      dev.log('Resultados de preferencias obtenidos');

      if (mounted) {
        setState(() {
          if (results[0] != null) {
            catalogoConceptos = results[0] as ConceptoModel;
            dev.log('✓ Catálogo conceptos cargado desde preferencias');
          } else {
            dev.log('✗ Catálogo conceptos no encontrado en preferencias');
          }

          if (results[1] != null) {
            catalogoGenerales = results[1] as CatalogoGeneralesModel;
            dev.log('✓ Catálogo generales cargado desde preferencias');
          } else {
            dev.log('✗ Catálogo generales no encontrado en preferencias');
          }

          if (results[2] != null) {
            catalogoMaquinaria = results[2] as CatalogoMaquinariaResponse;
            dev.log('✓ Catálogo maquinaria cargado desde preferencias');
          } else {
            dev.log('✗ Catálogo maquinaria no encontrado en preferencias');
          }

          if (results[3] != null) {
            catalogoPersonal = results[3] as CatalogoPersonalModel;
            dev.log('✓ Catálogo personal cargado desde preferencias');
          } else {
            dev.log('✗ Catálogo personal no encontrado en preferencias');
          }
          if (results[4] != null) {
            catalogoMotivoInactividadMaquinaria =
                results[4] as MotivosInactividadMaquinariaModel;
            dev.log(
                '✓ Catálogo motivos de inactividad cargado desde preferencias');
          } else {
            dev.log(
                '✗ Catálogo motivos de inactividad no encontrado en preferencias');
          }
        });
      }

      // Mostrar mensaje si no hay datos offline
      if (!_tieneConexion && _todosLosCatalogosVacios()) {
        _mostrarMensajeSinDatos();
      }
    } catch (e) {
      dev.log('Error al cargar catálogos desde preferencias: $e');
    }
  }

  /// Carga catálogo de conceptos desde API
  Future<void> _cargarCatalogoConceptos() async {
    try {
      dev.log('Enviando evento ConceptoInStartRequest...');
      final conceptoBloc = context.read<ConceptoBloc>();
      conceptoBloc.add(ConceptoInStartRequest(
        token: widget.user.token,
        obraId: widget.user.user!.obraId!,
      ));
      dev.log('Evento ConceptoInStartRequest enviado');
    } catch (e) {
      dev.log('Error al cargar catálogo conceptos desde API: $e');
    }
  }

  Future<void> _cargarCatalogoMotivosInactividad() async {
    try {
      dev.log('Enviando evento MotivosInactividadInStartRequest...');
      final motivosInactividadBloc =
          context.read<CatalogoMotivosInactvidadMaquinariaBloc>();
      motivosInactividadBloc
          .add(CatalogoMotivosInactvidadMaquinariaInStartRequest(
        token: widget.user.token,
        obraId: widget.user.user!.obraId!,
      ));
      dev.log('Evento MotivosInactividadInStartRequest enviado');
    } catch (e) {
      dev.log('Error al cargar catálogo conceptos desde API: $e');
    }
  }

  /// Carga catálogo generales desde API
  Future<void> _cargarCatalogoGenerales() async {
    try {
      dev.log('Enviando evento GeneralesInStartRequest...');
      final generalesBloc = context.read<GeneralesBloc>();
      generalesBloc.add(GeneralesInStartRequest(
        token: widget.user.token,
        obraId: widget.user.user!.obraId!,
      ));
      dev.log('Evento GeneralesInStartRequest enviado');
    } catch (e) {
      dev.log('Error al cargar catálogo generales desde API: $e');
    }
  }

  /// Carga catálogo maquinaria desde API
  Future<void> _cargarCatalogoMaquinaria() async {
    try {
      dev.log('Enviando evento FamiliaMaquinariaInStartRequest...');
      final maquinariaBloc = context.read<FamiliaMaquinariaBloc>();
      maquinariaBloc.add(FamiliaMaquinariaInStartRequest(
        token: widget.user.token,
        obraId: widget.user.user!.obraId!,
      ));
      dev.log('Evento FamiliaMaquinariaInStartRequest enviado');
    } catch (e) {
      dev.log('Error al cargar catálogo maquinaria desde API: $e');
    }
  }

  /// Carga catálogo personal desde API
  Future<void> _cargarCatalogoPersonal() async {
    try {
      dev.log('Enviando evento CatalogoPersonalInStartRequest...');
      final personalBloc = context.read<CatalogoPersonalBloc>();
      personalBloc.add(CatalogoPersonalInStartRequest(
        token: widget.user.token,
        obraId: widget.user.user!.obraId!,
      ));
      dev.log('Evento CatalogoPersonalInStartRequest enviado');
    } catch (e) {
      dev.log('Error al cargar catálogo personal desde API: $e');
    }
  }

  /// Verifica si todos los catálogos están vacíos
  bool _todosLosCatalogosVacios() {
    return catalogoConceptos == null &&
        catalogoGenerales == null &&
        catalogoMaquinaria == null &&
        catalogoPersonal == null;
  }

  /// Muestra mensaje cuando no hay datos disponibles offline
  void _mostrarMensajeSinDatos() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Sin conexión y sin datos guardados. Algunos catálogos pueden no estar disponibles.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    });
  }

  /// Método para refrescar catálogos manualmente
  Future<void> _refrescarCatalogos() async {
    await _inicializarCatalogos();
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
      final campoGeneralesSeleccionado =
          PreferenceProvider.getCampoSeleccionado();
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

      //print(personal);
      //return;
      // Validaciones
      if (!CamposGeneralesValidationHelper.areCamposGeneralesComplete(
          campoGeneralesSeleccionado)) {
        final errorMessage =
            CamposGeneralesValidationHelper.getIncompleteCamposMessage(
                campoGeneralesSeleccionado);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage!)),
        );
        return;
      }

      if (!TurnoValidationHelper.isTurnoComplete(turnoSeleccionado)) {
        final errorMessage =
            TurnoValidationHelper.getIncompleteTurnoMessage(turnoSeleccionado);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage!)),
        );
        return;
      }

      if (!ZonaTrabajoValidationHelper.isZonaComplete(zonaSeleccionada)) {
        final errorMessage =
            ZonaTrabajoValidationHelper.getIncompleteZonaMessage(
                zonaSeleccionada);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage!)),
        );
        return;
      }

      final Map<String, dynamic> reporteData = {
        'usuario_id': widget.user.user!.id,
        'generales': campoGeneralesSeleccionado!.toMap(),
        'turno': turnoSeleccionado!.toMap(),
        'zona_trabajo': zonaSeleccionada!.toMap(),
        // 'observaciones': _observacionesController.text,
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
          widget.user.token, widget.user.user!.obraId!, reporteData);

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
            builder: (context) => JfMainScreen(user: widget.user),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<LogoutBloc, LogoutState>(listener: (context, state) {
          if (state is LogoutSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
            );
          } else if (state is LogoutFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        }),
        BlocListener<GeneralesBloc, GeneralesState>(listener: (context, state) {
          if (state is GeneralesSuccess) {
            setState(() {
              catalogoGenerales = state.catalogoGenerales;
            });
            dev.log('Catálogo generales actualizado desde API');
          } else if (state is GeneralesFailure) {
            dev.log('Error al cargar catálogo generales: ${state.toString()}');
          }
        }),
        BlocListener<FamiliaMaquinariaBloc, FamiliaMaquinariaState>(
            listener: (context, state) {
          if (state is FamiliaMaquinariaSuccess) {
            setState(() {
              catalogoMaquinaria = state.catalogoMaquinaria;
            });
            dev.log('Catálogo maquinaria actualizado desde API');
          } else if (state is FamiliaMaquinariaFailure) {
            dev.log('Error al cargar catálogo maquinaria: ${state.toString()}');
          }
        }),
        BlocListener<ConceptoBloc, ConceptoState>(listener: (context, state) {
          if (state is ConceptoNoSuccess) {
            setState(() {
              catalogoConceptos = state.concepto;
            });
            dev.log('Catálogo conceptos actualizado desde API');
          } else if (state is ConceptoFailure) {
            dev.log('Error al cargar catálogo conceptos: ${state.toString()}');
          }
        }),
        BlocListener<CatalogoPersonalBloc, CatalogoPersonalState>(
            listener: (context, state) {
          if (state is CatalogoPersonalSuccess) {
            setState(() {
              catalogoPersonal = state.personal;
            });
            dev.log('Catálogo personal actualizado desde API');
          } else if (state is CatalogoPersonalFailure) {
            dev.log('Error al cargar catálogo personal: ${state.toString()}');
          }
        }),
        BlocListener<CatalogoMotivosInactvidadMaquinariaBloc,
                CatalogoMotivosInactvidadMaquinariaState>(
            listener: (context, state) {
          if (state is CatalogoMotivosInactvidadMaquinariaSuccess) {
            setState(() {
              catalogoMotivoInactividadMaquinaria = state.motivoInactividad;
            });
            dev.log('Catálogo conceptos actualizado desde API');
          } else if (state is ConceptoFailure) {
            dev.log('Error al cargar catálogo conceptos: ${state.toString()}');
          }
        }),
      ],
      child: Scaffold(
        backgroundColor: mainBgColor,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            widget.user.user!.name,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: customBlack,
          actions: [
            // Botón para refrescar catálogos
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _tieneConexion ? _refrescarCatalogos : null,
              tooltip: 'Refrescar catálogos',
            ),
            // Indicador de conexión
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(
                _tieneConexion ? Icons.wifi : Icons.wifi_off,
                color: _tieneConexion ? Colors.green : Colors.red,
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: false,
            labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            labelStyle: const TextStyle(fontSize: 10),
            unselectedLabelStyle: const TextStyle(fontSize: 10),
            labelColor: Colors.white,
            dividerColor: Colors.white,
            indicatorColor: Colors.white,
            // tabs: const [
            //   Tab(text: 'Generales'),
            //   Tab(text: 'Avances de obra'),
            //   Tab(text: 'Maquinaria'),
            //   Tab(text: 'Personal'),
            //   Tab(text: 'Fotografías'),
            //   Tab(text: 'Guardar')
            // ],
            tabs: const [
              Tab(icon: Icon(Icons.info)), // Generales
              Tab(icon: Icon(Icons.bar_chart)), // Avances de obra
              Tab(icon: Icon(Icons.construction)), // Maquinaria
              Tab(icon: Icon(Icons.groups)), // Personal
              Tab(icon: Icon(Icons.photo_camera)), // Fotografías
              Tab(icon: Icon(Icons.save)), // Guardar
            ],
          ),
        ),
        drawer: UserDrawer(user: widget.user),
        body: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando catálogos...'),
                  ],
                ),
              )
            : TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          GeneralesWidget(
                            sobrestante: widget.user.user!.name,
                            token: widget.user.token,
                            obraId: widget.user.user!.obraId!,
                            responsive: responsive,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.only(bottom: 8, top: 8, left: 8),
                                child: Text(
                                  'Avance de obra',
                                  style: TextStyle(fontSize: 22),
                                ),
                              ),
                            ],
                          ),
                          AcarreosVolumenWidget(
                            user: widget.user,
                            token: widget.user.token,
                            obraId: widget.user.user!.obraId!,
                            responsive: responsive,
                          ),
                          AcarreosAreaWidget(
                            user: widget.user,
                            token: widget.user.token,
                            obraId: widget.user.user!.obraId!,
                            responsive: responsive,
                          ),
                          AcarreosMetroWidget(
                            user: widget.user,
                            token: widget.user.token,
                            obraId: widget.user.user!.obraId!,
                            responsive: responsive,
                          ),
                          AcarreosAguaWidget(
                            user: widget.user,
                            token: widget.user.token,
                            obraId: widget.user.user!.obraId!,
                            responsive: responsive,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          MaquinariaWidget(
                            user: widget.user,
                            token: widget.user.token,
                            obraId: widget.user.user!.obraId!,
                            responsive: responsive,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: PersonalWidget(
                      user: widget.user,
                      obraId: widget.user.user!.obraId!,
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ImageGalleryScreen(),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GuardarReporteScreen(
                      user: widget.user,
                    ),
                  ),
                ],
              ),
        /* bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: guardarDatos,
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
        ),*/
      ),
    );
  }
}
