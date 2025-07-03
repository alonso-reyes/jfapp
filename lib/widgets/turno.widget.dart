import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/turno/turno_event.dart';
import 'package:jfapp/blocs/turno/turno_state.dart';
import 'dart:developer' as dev;
import 'package:jfapp/blocs/turno/turno_bloc.dart';
import 'package:jfapp/helpers/responsive_helper.dart';
import 'package:intl/intl.dart';
import 'package:jfapp/models/turno-seleccionado.model.dart';
import 'package:jfapp/models/turno.model.dart';
import 'package:jfapp/providers/preference_provider.dart';
import 'package:collection/collection.dart';

class TurnoWidget extends StatefulWidget {
  final String token;
  final int obraId;
  final Responsive responsive;

  const TurnoWidget({
    super.key,
    required this.token,
    required this.obraId,
    required this.responsive,
  });

  @override
  _TurnoWidgetState createState() => _TurnoWidgetState();
}

class _TurnoWidgetState extends State<TurnoWidget> {
  TurnoSeleccionado? turnoGuardado;
  Turno? _selectedTurno;
  TimeOfDay? _horaInicioActividades;
  TimeOfDay? _horaFinActividades;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  void _cargarPreferencias() async {
    //dev.log(jsonEncode(_selectedTurno));
    turnoGuardado = PreferenceProvider.getTurnoSeleccionado();
  }

  TimeOfDay _stringToTimeOfDay(String time) {
    final format = DateFormat("HH:mm"); // Formato de 24 horas
    final parsedTime = format.parse(time);
    return TimeOfDay(hour: parsedTime.hour, minute: parsedTime.minute);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TurnoBloc()
        ..add(
          TurnoInStartRequest(
            token: widget.token,
            obraId: widget.obraId,
          ),
        ),
      child: BlocBuilder<TurnoBloc, TurnoState>(
        builder: (context, state) {
          if (state is TurnoLoading) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: CircularProgressIndicator(color: Colors.black45),
              ),
            );
          }

          if (state is TurnoSuccess) {
            List<Turno> turnos = state.turno.turnos ?? [];

            if (turnoGuardado != null && _selectedTurno == null) {
              final turnoEncontrado = turnos.firstWhereOrNull(
                (turno) => turno.id == turnoGuardado!.id,
              );

              if (turnoEncontrado != null) {
                // Usar WidgetsBinding para establecer el estado después del primer build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _selectedTurno = turnoEncontrado;
                    _horaInicioActividades =
                        _stringToTimeOfDay(turnoGuardado!.horaRealEntrada);
                    _horaFinActividades =
                        _stringToTimeOfDay(turnoGuardado!.horaRealSalida);
                  });
                });
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Turno',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<Turno>(
                  value: _selectedTurno,
                  hint: Text(
                    "Seleccione un turno",
                    style: TextStyle(fontSize: 16),
                  ),
                  isExpanded: true,
                  onChanged: (Turno? newValue) {
                    setState(() {
                      _selectedTurno = newValue;
                      _horaInicioActividades = null;
                      _horaFinActividades = null;
                      PreferenceProvider.clearTurnoSeleccionado();
                    });
                    _guardarDatos(); // Guardamos los datos al seleccionar el turno
                  },
                  items: turnos.map<DropdownMenuItem<Turno>>((Turno turno) {
                    return DropdownMenuItem<Turno>(
                      value: turno,
                      child: Text(
                        turno.turno ?? "Turno sin nombre",
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: widget.responsive.dp(1)),
                if (_selectedTurno != null) ...[
                  Text(
                    "Hora de entrada: ${_selectedTurno!.horaEntrada ?? '00:00:00'}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Hora de salida: ${_selectedTurno!.horaSalida ?? '00:00:00'}",
                    style: TextStyle(fontSize: 16),
                  ),

                  SizedBox(height: widget.responsive.dp(2)),

                  // Selector de hora de inicio de actividades
                  _buildTimePicker(
                    label: "Hora de inicio de actividades",
                    selectedTime: _horaInicioActividades,
                    onTimeSelected: (TimeOfDay time) {
                      setState(() {
                        _horaInicioActividades = time;
                      });
                      _guardarDatos(); // Guardamos los datos cuando se seleccione una hora
                    },
                  ),

                  SizedBox(height: widget.responsive.dp(2)),

                  // Selector de hora de terminación de actividades
                  _buildTimePicker(
                    label: "Hora de terminación de actividades",
                    selectedTime: _horaFinActividades,
                    onTimeSelected: (TimeOfDay time) {
                      setState(() {
                        _horaFinActividades = time;
                      });
                      _guardarDatos(); // Guardamos los datos cuando se seleccione una hora
                    },
                  ),
                ],
              ],
            );
          } else if (state is TurnoFailure) {
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
  Widget _buildTimePicker({
    required String label,
    required TimeOfDay? selectedTime,
    required Function(TimeOfDay) onTimeSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
        );
        if (pickedTime != null) {
          onTimeSelected(pickedTime);
        }
      },
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.access_time),
          ),
          controller: TextEditingController(
            text: selectedTime?.format(context) ?? '',
          ),
        ),
      ),
    );
  }

  void _seleccionarTurnoGuardado() {
    // Buscar el turno guardado en la lista de turnos
    final bloc = context.read<TurnoBloc>();
    final state = bloc.state;

    if (state is TurnoSuccess) {
      dev.log('Success');
      final turnos = state.turno.turnos ?? [];
      final turnoEncontrado = turnos.firstWhere(
        (turno) => turno.id == turnoGuardado!.id,
        //orElse: () => null!,
      );

      if (turnoEncontrado != null) {
        setState(() {
          _selectedTurno = turnoEncontrado;
          // También establecer las horas iniciales y finales
          _horaInicioActividades =
              _stringToTimeOfDay(turnoGuardado!.horaRealEntrada);
          _horaFinActividades =
              _stringToTimeOfDay(turnoGuardado!.horaRealSalida);
        });
      }
    }
  }

  void _guardarDatos() {
    if (_selectedTurno != null &&
        _horaInicioActividades != null &&
        _horaFinActividades != null) {
      // Crear un objeto TurnoSeleccionado con las horas seleccionadas
      TurnoSeleccionado turnoSeleccionado = TurnoSeleccionado(
        id: _selectedTurno!.id!,
        turno: _selectedTurno!.turno!,
        horaRealEntrada: _horaInicioActividades!.format(context),
        horaRealSalida: _horaFinActividades!.format(context),
      );

      // Guardarlo en SharedPreferences
      PreferenceProvider.setTurnoSeleccionado(turnoSeleccionado);

      // Llamar a la función onSave con el objeto en formato JSON
      //widget.onSave(turnoSeleccionado.toMap());
    }
  }
}
