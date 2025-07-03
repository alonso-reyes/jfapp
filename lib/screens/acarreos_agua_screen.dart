import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/catalogos_acarreos_agua/catalogos_acarreos_agua_bloc.dart';
import 'package:jfapp/blocs/catalogos_acarreos_agua/catalogos_acarreos_agua_event.dart';
import 'package:jfapp/blocs/catalogos_acarreos_agua/catalogos_acarreos_agua_state.dart';
import 'package:jfapp/components/custom_save_button.dart';
import 'package:jfapp/constants.dart';
import 'package:jfapp/helpers/responsive_helper.dart';
import 'package:jfapp/models/acarreos-agua.model.dart';
import 'package:jfapp/models/catalogos-agua.model.dart';
import 'package:jfapp/models/user.model.dart';

class AcarreosAguaScreen extends StatefulWidget {
  final UserModel user;
  final int obraId;
  final AcarreoAgua? acarreoExistente;

  const AcarreosAguaScreen({
    super.key,
    required this.user,
    required this.obraId,
    this.acarreoExistente,
  });

  @override
  _AcarreosAguaScreenState createState() => _AcarreosAguaScreenState();
}

class _AcarreosAguaScreenState extends State<AcarreosAguaScreen> {
  final TextEditingController _viajesController = TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();
  Pipas? _selectedPipa;
  Origenes? _selectedOrigen;
  Destinos? _selectedDestino;

  void _guardarAcarreo() {
    if (_viajesController.text.isNotEmpty &&
        _selectedPipa != null &&
        _selectedOrigen != null &&
        _selectedDestino != null) {
      final acarreo = AcarreoAgua(
        pipa: _selectedPipa,
        origen: _selectedOrigen,
        destino: _selectedDestino,
        viajes: int.parse(_viajesController.text),
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
      _observacionesController.text = widget.acarreoExistente!.observaciones!;
    }
  }

  Pipas? _findPipa(Pipas? pipa, List<Pipas> pipas) {
    if (pipa == null) return null;
    return pipas.firstWhere((m) => m.id == pipa.id, orElse: () => pipa);
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

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider<CatalogosAcarreosAguaBloc>(
            create: (context) => CatalogosAcarreosAguaBloc()
              ..add(CatalogosAcarreosAguaInStartRequest(
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
            child: BlocBuilder<CatalogosAcarreosAguaBloc,
                CatalogosAcarreosAguaState>(
              builder: (context, state) {
                if (state is CatalogosAcarreosAguaSuccess) {
                  final pipas = state.catalogoAgua.catalogo.pipas ?? [];

                  final origenes = state.catalogoAgua.catalogo.origenes ?? [];
                  final destinos = state.catalogoAgua.catalogo.destinos ?? [];

                  if (widget.acarreoExistente != null) {
                    _selectedPipa ??=
                        _findPipa(widget.acarreoExistente!.pipa, pipas);

                    _selectedOrigen ??=
                        _findOrigen(widget.acarreoExistente!.origen, origenes);
                    _selectedDestino ??= _findDestino(
                        widget.acarreoExistente!.destino, destinos);
                  }

                  return _buildUI(responsive, pipas, origenes, destinos);
                } else if (state is CatalogosAcarreosAguaLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is CatalogosAcarreosAguaFailure) {
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
    List<Pipas> pipas,
    List<Origenes> origenes,
    List<Destinos> destinos,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Materiales
          Text('Número económico',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          DropdownButton<Pipas>(
            value: _selectedPipa,
            hint: Text("Seleccione una pipa"),
            isExpanded: true,
            onChanged: (Pipas? newValue) {
              setState(() {
                print('Material seleccionado: ${newValue?.numeroEconomico}');
                _selectedPipa = newValue;
              });
            },
            items: pipas.map<DropdownMenuItem<Pipas>>((Pipas pipa) {
              return DropdownMenuItem<Pipas>(
                value: pipa,
                child: Text(pipa.numeroEconomico ?? "Sin número económico"),
              );
            }).toList(),
          ),
          SizedBox(height: 16),

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

          SizedBox(height: responsive.dp(1)),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: TextField(
              controller: _viajesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Escriba la cantidad de viajes',
                labelStyle: TextStyle(color: customBlack),
                filled: true,
                fillColor: Colors.white, // Fondo blanco
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(10.0), // Bordes redondeados
                  borderSide: BorderSide(
                      color: Colors.black, width: 1.0), // Borde negro
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                      color: Colors.black,
                      width: 2.0), // Borde negro al enfocar
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: TextFormField(
              controller: _observacionesController,
              maxLines: 5, // Permite múltiples líneas
              decoration: InputDecoration(
                labelText: 'Observaciones',
                labelStyle: TextStyle(color: customBlack),
                filled: true,
                fillColor: Colors.white, // Fondo blanco
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(10.0), // Bordes redondeados
                  borderSide: BorderSide(
                      color: Colors.black, width: 1.0), // Borde negro
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                      color: Colors.black,
                      width: 2.0), // Borde negro al enfocar
                ),
              ),
            ),
          ),
          SizedBox(height: responsive.dp(2)),
          CustomSaveButton(
            onPressed: _guardarAcarreo,
          )
          // ElevatedButton(
          //   onPressed: _guardarAcarreo,
          //   child: Text('Guardar'),
          // ),
        ],
      ),
    );
  }
}
