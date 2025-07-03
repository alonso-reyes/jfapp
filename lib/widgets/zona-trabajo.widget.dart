import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev;
import 'package:jfapp/blocs/zonas-trabajo/zonas_trabajo_bloc.dart';
import 'package:jfapp/blocs/zonas-trabajo/zonas_trabajo_event.dart';
import 'package:jfapp/blocs/zonas-trabajo/zonas_trabajo_state.dart';
import 'package:jfapp/helpers/responsive_helper.dart';
import 'package:intl/intl.dart';
import 'package:jfapp/models/zona-trabajo-seleccionada.model.dart';
import 'package:jfapp/models/zonas-trabajo.model.dart';
import 'package:jfapp/providers/preference_provider.dart';

class ZonaTrabajoWidget extends StatefulWidget {
  final String token;
  final int obraId;
  final Responsive responsive;

  const ZonaTrabajoWidget({
    Key? key,
    required this.token,
    required this.obraId,
    required this.responsive,
  }) : super(key: key);

  @override
  _ZonaTrabajoWidgetState createState() => _ZonaTrabajoWidgetState();
}

class _ZonaTrabajoWidgetState extends State<ZonaTrabajoWidget> {
  Zona? _selectedZona;
  ZonaTrabajoSeleccionada? zonaGuardada;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  void _cargarPreferencias() async {
    //dev.log(jsonEncode(_selectedTurno));
    zonaGuardada = PreferenceProvider.getZonaTrabajoSeleccionada();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ZonaTrabajoBloc()
        ..add(
          ZonaTrabajoInStartRequest(
            token: widget.token,
            obraId: widget.obraId,
          ),
        ),
      child: BlocBuilder<ZonaTrabajoBloc, ZonaTrabajoState>(
        builder: (context, state) {
          if (state is ZonaTrabajoLoading) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: CircularProgressIndicator(color: Colors.black45),
              ),
            );
          }

          if (state is ZonaTrabajoSuccess) {
            List<Zona> zona = state.zonaTrabajo.zonas ?? [];

            if (zonaGuardada != null && _selectedZona == null) {
              final zonaEncontrada = zona.firstWhereOrNull(
                (zona) => zona.id == zonaGuardada!.id,
              );

              if (zonaGuardada != null) {
                // Usar WidgetsBinding para establecer el estado después del primer build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _selectedZona = zonaEncontrada;
                  });
                });
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Zona de Trabajo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<Zona>(
                    value: _selectedZona,
                    hint: Text(
                      "Seleccione una zona de trabajo",
                      style: TextStyle(fontSize: 16),
                    ),
                    isExpanded: true,
                    onChanged: (Zona? newValue) {
                      setState(() {
                        _selectedZona = newValue;
                        PreferenceProvider.clearZonaTrabajoSeleccionada();
                      });
                      _guardarDatos(); // Guardamos los datos al seleccionar el ZonaTrabajo
                    },
                    items: zona.map<DropdownMenuItem<Zona>>((Zona zona) {
                      return DropdownMenuItem<Zona>(
                        value: zona,
                        child: Text(
                          zona.clave ?? "",
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: widget.responsive.dp(1)),
                  if (_selectedZona != null) ...[
                    //Image.network('https://via.placeholder.com/150'),
                    Image.network(
                      _selectedZona!.imagenUrl!,
                      //     .replaceAll("127.0.0.1", "localhost"),
                      //'http://localhost:8000/storage/2025/01/31/4531905d9dc644231bb7fa8b272362f86c89f6dc.png',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Text("No se pudo cargar la imagen",
                            style: TextStyle(color: Colors.red));
                      },
                    )
                  ],
                ],
              ),
            );
          } else if (state is ZonaTrabajoFailure) {
            return Column(
              children: [
                SizedBox(height: widget.responsive.dp(2)),
                Text(
                  state.error,
                  style: TextStyle(fontSize: widget.responsive.dp(2)),
                ),
              ],
            );
          }

          return SizedBox.shrink(); // Widget vacío por defecto
        },
      ),
    );
  }

  /// Método para construir el selector de hora

  // Función para guardar los datos cuando cualquiera de los campos cambie
  void _guardarDatos() {
    if (_selectedZona != null) {
      // Crear un objeto TurnoSeleccionado con las horas seleccionadas
      ZonaTrabajoSeleccionada zonaTrabajoSeleccionada = ZonaTrabajoSeleccionada(
        id: _selectedZona!.id!,
        clave: _selectedZona!.clave!,
        // nombre: _selectedZona!.nombre!,
        // descripcion: _selectedZona!.descripcion!,
      );

      // Guardarlo en SharedPreferences
      PreferenceProvider.setZonaTrabajoSeleccionada(zonaTrabajoSeleccionada);

      // Llamar a la función onSave con el objeto en formato JSON
      //widget.onSave(turnoSeleccionado.toMap());
    }
    // if (_selectedZonaTrabajo != null &&
    //     _horaInicioActividades != null &&
    //     _horaFinActividades != null) {
    //   Map<String, dynamic> datos = {
    //     "id_ZonaTrabajo": _selectedZonaTrabajo!.id,
    //     "horaInicioActividades": _horaInicioActividades?.format(context),
    //     "horaFinActividades": _horaFinActividades?.format(context),
    //   };
    //   widget.onSave(
    //       datos);
    // }
  }
}
