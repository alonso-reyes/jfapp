import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/catalogos_acarreos_volumen/catalogos_acarreos_volumen_bloc.dart';
import 'package:jfapp/blocs/catalogos_acarreos_volumen/catalogos_acarreos_volumen_event.dart';
import 'package:jfapp/blocs/catalogos_acarreos_volumen/catalogos_acarreos_volumen_state.dart';
import 'package:jfapp/constants.dart';
import 'package:jfapp/helpers/responsive_helper.dart';
import 'package:jfapp/models/acarreos-volumen.model.dart';
import 'package:jfapp/models/catalogos-volumen.model.dart';
import 'package:jfapp/models/user.model.dart';

class AcarreosVolumenScreen extends StatefulWidget {
  final UserModel user;
  final int obraId;
  final AcarreoVolumen? acarreoExistente;

  const AcarreosVolumenScreen({
    super.key,
    required this.user,
    required this.obraId,
    this.acarreoExistente,
  });

  @override
  _AcarreosVolumenScreenState createState() => _AcarreosVolumenScreenState();
}

class _AcarreosVolumenScreenState extends State<AcarreosVolumenScreen> {
  final TextEditingController _viajesController = TextEditingController();
  final TextEditingController _capacidadController = TextEditingController();
  final TextEditingController _volumenController = TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();
  MateriaL? _selectedMaterial;
  UsosMateriaLes? _selectedUso;
  Origenes? _selectedOrigen;
  Destinos? _selectedDestino;
  TiposCamion? _selectedTipoCamion;

  void _calcularVolumen() {
    double numeroViajes = double.tryParse(_viajesController.text) ?? 0.0;
    double capacidad = double.tryParse(_capacidadController.text) ?? 0.0;
    _volumenController.text = (numeroViajes * capacidad).toStringAsFixed(2);
  }

  void _guardarAcarreo() {
    if (_viajesController.text.isNotEmpty &&
        _capacidadController.text.isNotEmpty &&
        _volumenController.text.isNotEmpty &&
        _selectedMaterial != null &&
        _selectedUso != null &&
        _selectedOrigen != null &&
        _selectedDestino != null &&
        _selectedTipoCamion != null) {
      final acarreo = AcarreoVolumen(
        material: _selectedMaterial,
        usoMaterial: _selectedUso,
        origen: _selectedOrigen,
        destino: _selectedDestino,
        camion: _selectedTipoCamion,
        viajes: int.parse(_viajesController.text),
        capacidad: double.parse(_capacidadController.text),
        volumen: double.parse(_volumenController.text),
        observaciones: _observacionesController.text,
      );
      Navigator.pop(context, acarreo);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, complete todos los campos.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.acarreoExistente != null) {
      _viajesController.text = widget.acarreoExistente!.viajes.toString();
      _capacidadController.text = widget.acarreoExistente!.capacidad.toString();
      _volumenController.text = widget.acarreoExistente!.volumen.toString();
      _observacionesController.text = widget.acarreoExistente!.observaciones!;
    }
    _viajesController.addListener(_calcularVolumen);
    _capacidadController.addListener(_calcularVolumen);
  }

  MateriaL? _findMaterial(MateriaL? material, List<MateriaL> materiales) {
    if (material == null) return null;
    return materiales.firstWhere((m) => m.id == material.id,
        orElse: () => material);
  }

  UsosMateriaLes? _findUso(UsosMateriaLes? uso, List<UsosMateriaLes> usos) {
    if (uso == null) return null;
    return usos.firstWhere((u) => u.id == uso.id, orElse: () => uso);
  }

  Origenes? _findOrigen(Origenes? origen, List<Origenes> origenes) {
    if (origen == null) return null;
    return origenes.firstWhere((o) => o.id == origen.id, orElse: () => origen);
  }

  Destinos? _findDestino(Destinos? destino, List<Destinos> destinos) {
    if (destino == null) return null;
    return destinos.firstWhere((d) => d.id == destino.id,
        orElse: () => destino);
  }

  TiposCamion? _findCamion(
      TiposCamion? tipoCamion, List<TiposCamion> tiposCamiones) {
    if (tipoCamion == null) return null;
    return tiposCamiones.firstWhere((c) => c.id == tipoCamion.id,
        orElse: () => tipoCamion);
  }

  // Camion? _findCamion(Camion? camion, List<Camion> camiones) {
  //   if (camion == null) return null;
  //   return camiones.firstWhere((c) => c.id == camion.id, orElse: () => camion);
  // }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider<CatalogosAcarreosVolumenBloc>(
            create: (context) => CatalogosAcarreosVolumenBloc()
              ..add(CatalogosAcarreosVolumenInStartRequest(
                  obraId: widget.obraId, token: widget.user.token))),
      ],
      child: Scaffold(
        backgroundColor: mainBgColor,
        appBar: AppBar(
          title: Text(
            'Agregar acarreo',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: customBlack,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<CatalogosAcarreosVolumenBloc,
                CatalogosAcarreosVolumenState>(
              builder: (context, state) {
                if (state is CatalogosAcarreosVolumenSuccess) {
                  final materiales =
                      state.catalogoVolumen.catalogo.materiales ?? [];
                  final usos =
                      state.catalogoVolumen.catalogo.usosMateriaL ?? [];
                  final origenes =
                      state.catalogoVolumen.catalogo.origenes ?? [];
                  final destinos =
                      state.catalogoVolumen.catalogo.destinos ?? [];
                  final tiposCamiones =
                      state.catalogoVolumen.catalogo.tiposCamion ?? [];

                  if (widget.acarreoExistente != null) {
                    _selectedMaterial ??= _findMaterial(
                        widget.acarreoExistente!.material, materiales);
                    _selectedUso ??=
                        _findUso(widget.acarreoExistente!.usoMaterial, usos);
                    _selectedOrigen ??=
                        _findOrigen(widget.acarreoExistente!.origen, origenes);
                    _selectedDestino ??= _findDestino(
                        widget.acarreoExistente!.destino, destinos);
                    _selectedTipoCamion ??= _findCamion(
                        widget.acarreoExistente!.camion, tiposCamiones);
                  }

                  return _buildUI(responsive, materiales, usos, origenes,
                      destinos, tiposCamiones);
                } else if (state is CatalogosAcarreosVolumenLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is CatalogosAcarreosVolumenFailure) {
                  return Center(child: Text(state.error));
                } else {
                  return Center(child: Text('Server error'));
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUI(
    Responsive responsive,
    List<MateriaL> materiales,
    List<UsosMateriaLes> usos,
    List<Origenes> origenes,
    List<Destinos> destinos,
    // List<Camion> camiones,
    List<TiposCamion> tiposCamiones,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Materiales
          Text('Material',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          DropdownButton<MateriaL>(
            value: _selectedMaterial,
            hint: Text("Seleccione un material"),
            isExpanded: true,
            onChanged: (MateriaL? newValue) {
              setState(() {
                print('Material seleccionado: ${newValue?.material}');
                _selectedMaterial = newValue;
              });
            },
            items:
                materiales.map<DropdownMenuItem<MateriaL>>((MateriaL material) {
              return DropdownMenuItem<MateriaL>(
                value: material,
                child: Text(material.material ?? "Material sin nombre"),
              );
            }).toList(),
          ),
          SizedBox(height: 16),

          /// Usos de materiales
          Text(
            'Uso Material',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          DropdownButton<UsosMateriaLes>(
            value: _selectedUso,
            hint: Text(
              "Seleccione un uso de material",
              style: TextStyle(fontSize: 16),
            ),
            isExpanded: true,
            onChanged: (UsosMateriaLes? newValue) {
              setState(() {
                _selectedUso = newValue;
              });
              //_guardarDatos(); // Guardamos los datos al seleccionar el turno
            },
            items: usos.map<DropdownMenuItem<UsosMateriaLes>>(
                (UsosMateriaLes usoMaterial) {
              return DropdownMenuItem<UsosMateriaLes>(
                value: usoMaterial,
                child: Text(
                  usoMaterial.uso ?? "Uso de material sin nombre",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: responsive.dp(1)),

          /// Origenes
          Text(
            'Origen',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          DropdownButton<Origenes>(
            value: _selectedOrigen,
            hint: Text(
              "Seleccione un origen",
              style: TextStyle(fontSize: 16),
            ),
            isExpanded: true,
            onChanged: (Origenes? newValue) {
              setState(() {
                _selectedOrigen = newValue;
              });
              //_guardarDatos(); // Guardamos los datos al seleccionar el turno
            },
            items: origenes.map<DropdownMenuItem<Origenes>>((Origenes origen) {
              return DropdownMenuItem<Origenes>(
                value: origen,
                child: Text(
                  origen.origen ?? "Origen sin nombre",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: responsive.dp(1)),
          //Destinos
          Text(
            'Destino',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          DropdownButton<Destinos>(
            value: _selectedDestino,
            hint: Text(
              "Seleccione un destino",
              style: TextStyle(fontSize: 16),
            ),
            isExpanded: true,
            onChanged: (Destinos? newValue) {
              setState(() {
                _selectedDestino = newValue;
              });
              //_guardarDatos(); // Guardamos los datos al seleccionar el turno
            },
            items: destinos.map<DropdownMenuItem<Destinos>>((Destinos destino) {
              return DropdownMenuItem<Destinos>(
                value: destino,
                child: Text(
                  destino.destino ?? "Destino sin nombre",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: responsive.dp(1)),
          // Camiones
          Text(
            'Camión',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          DropdownButton<TiposCamion>(
            value: _selectedTipoCamion,
            hint: Text(
              "Seleccione un camión",
              style: TextStyle(fontSize: 16),
            ),
            isExpanded: true,
            onChanged: (TiposCamion? newValue) {
              setState(() {
                _selectedTipoCamion = newValue;
                _capacidadController.text =
                    newValue?.capacidad.toStringAsFixed(2) ?? '';
              });
              //_guardarDatos(); // Guardamos los datos al seleccionar el turno
            },
            items: tiposCamiones
                .map<DropdownMenuItem<TiposCamion>>((TiposCamion camion) {
              return DropdownMenuItem<TiposCamion>(
                value: camion,
                child: Text(
                  camion.nombre,
                  style: TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: responsive.dp(1)),

          _buildTextField(
            _capacidadController, "Capacidad",
            TextInputType.number,
            true,
            enabled: false, // Solo lectura
          ),
          _buildTextField(_viajesController, 'Escriba la cantidad de viajes',
              TextInputType.number, true),
          _buildTextField(_volumenController, 'Volumen calculado',
              TextInputType.number, true,
              enabled: false),
          _buildTextField(_observacionesController, 'Escriba las observaciones',
              TextInputType.text, false,
              maxLines: 5),
          SizedBox(height: responsive.dp(2)),
          Center(
            child: GestureDetector(
              onTap: _guardarAcarreo,
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
          // ElevatedButton(
          //   onPressed: _guardarAcarreo,
          //   child: Text('Guardar'),
          // ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      TextInputType inputType, bool decimal,
      {bool enabled = true, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: TextField(
        controller: controller,
        keyboardType: decimal
            ? TextInputType.numberWithOptions(decimal: true)
            : inputType,
        enabled: enabled,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: customBlack),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.black, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.black, width: 2.0),
          ),
        ),
      ),
    );
  }
}
