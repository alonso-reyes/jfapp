import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/personal/personal_bloc.dart';
import 'package:jfapp/blocs/personal/personal_event.dart';
import 'package:jfapp/constants.dart';
import 'package:jfapp/models/catalogo-personal.model.dart';
import 'package:jfapp/models/guardar-catalogo-personal.model.dart';
import 'package:jfapp/models/user.model.dart';
import 'package:jfapp/providers/model_provider.dart';
import 'package:jfapp/providers/personal_provider.dart';

class PersonalWidget extends StatefulWidget {
  final UserModel user;
  final int obraId;

  const PersonalWidget({
    super.key,
    required this.user,
    required this.obraId,
  });

  @override
  State<PersonalWidget> createState() => _PersonalWidgetState();
}

class _PersonalWidgetState extends State<PersonalWidget> {
  List<GuardarCatalogoPersonalModel> _personalSeleccionado = [];
  CatalogoPersonalModel? _catalogoPersonal;
  bool _tieneConexion = false;

  bool _isLoading = true;
  final Map<int, bool> _selecciones = {};
  final TextEditingController _searchController = TextEditingController();
  List<Personal> _personalFiltrado = [];

  @override
  void initState() {
    print(widget.user.token);
    super.initState();
    _searchController.addListener(_filtrarPersonal);
    _cargarDatosIniciales();
    _verificarConexion();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filtrarPersonal() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _personalFiltrado = _catalogoPersonal?.personal.where((personal) {
            final nombre = personal.nombre?.toLowerCase() ?? '';
            final puesto = personal.puesto?.toLowerCase() ?? '';
            return nombre.contains(query) || puesto.contains(query);
          }).toList() ??
          [];
    });
  }

  Future<void> _verificarConexion() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _tieneConexion = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<void> _cargarDatosIniciales() async {
    await Future.wait([
      _cargarCatalogoPersonal(),
      _cargarPersonalGuardado(),
    ]);
    setState(() {
      _isLoading = false;
      _personalFiltrado = _catalogoPersonal?.personal ?? [];
    });
  }

  Future<void> _cargarCatalogoPersonal() async {
    final catalogo = await ModelProvider.cargarCatalogoPersonal();
    //print(catalogo!.toJson());
    setState(() => _catalogoPersonal = catalogo);
  }

  Future<void> _cargarPersonalGuardado() async {
    final personal = PersonalProvider.getPersonal('personal');
    setState(() {
      _personalSeleccionado = personal;
      for (var p in personal) {
        if (p.personal?.id != null) {
          _selecciones[p.personal!.id!] = true;
        }
      }
    });
  }

  Future<void> _recargarCatalogos() async {
    if (!_tieneConexion) return;

    setState(() => _isLoading = true);
    try {
      final personalBloc = context.read<CatalogoPersonalBloc>();
      personalBloc.add(CatalogoPersonalInStartRequest(
        token: widget.user.token,
        obraId: widget.obraId,
      ));
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar datos')),
      );
    }
  }

  void _actualizarSeleccion(Personal personal, bool seleccionado) {
    setState(() {
      _selecciones[personal.id!] = seleccionado;

      if (seleccionado) {
        _personalSeleccionado
            .add(GuardarCatalogoPersonalModel(personal: personal));
      } else {
        _personalSeleccionado.removeWhere((p) => p.personal?.id == personal.id);
      }

      PersonalProvider.setPersonal('personal', _personalSeleccionado);
    });
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar personal...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildListaPersonal() {
    return ListView.builder(
      itemCount: _personalFiltrado.isEmpty ? 1 : _personalFiltrado.length,
      itemBuilder: (context, index) {
        if (_personalFiltrado.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                _searchController.text.isEmpty
                    ? 'No hay personal disponible'
                    : 'No se encontraron resultados',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        final personal = _personalFiltrado[index];
        return Card(
          color: Colors.grey[200],
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          elevation: 2,
          child: CheckboxListTile(
            title: Text(
              personal.nombre ?? '',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(personal.puesto ?? ''),
            value: _selecciones[personal.id!] ?? false,
            onChanged: (value) => _actualizarSeleccion(personal, value!),
            secondary: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person, color: Colors.grey[600]),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBgColor,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Seleccione el personal:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildSearchField(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _recargarCatalogos,
                child: _isLoading
                    ? ListView(
                        // Necesario para permitir el gesto de pull incluso en loading
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ],
                      )
                    : _buildListaPersonal(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
