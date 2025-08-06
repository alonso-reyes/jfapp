import 'package:flutter/material.dart';
import 'package:jfapp/constants.dart';
import 'package:jfapp/helpers/responsive_helper.dart';
import 'package:jfapp/models/acarreos-area.model.dart';
import 'package:jfapp/models/user.model.dart';

class AcarreosAreaScreen extends StatefulWidget {
  final AcarreoArea? acarreoExistente;

  const AcarreosAreaScreen({
    super.key,
    this.acarreoExistente,
  });

  @override
  _AcarreosAreaScreenState createState() => _AcarreosAreaScreenState();
}

class _AcarreosAreaScreenState extends State<AcarreosAreaScreen> {
  final TextEditingController _viajesController = TextEditingController();
  final TextEditingController _largoController = TextEditingController();
  final TextEditingController _anchoController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();

  void _calcularArea() {
    double largo = double.tryParse(_largoController.text) ?? 0.0;
    double ancho = double.tryParse(_anchoController.text) ?? 0.0;
    _areaController.text = (largo * ancho).toStringAsFixed(2);
  }

  void _guardarAcarreo() {
    if (_largoController.text.isNotEmpty &&
        _anchoController.text.isNotEmpty &&
        _areaController.text.isNotEmpty) {
      final acarreo = AcarreoArea(
        largo: double.parse(_largoController.text),
        ancho: double.parse(_anchoController.text),
        area: double.parse(_areaController.text),
        // viajes: int.parse(_viajesController.text),
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
      _largoController.text = widget.acarreoExistente!.largo.toString();
      _anchoController.text = widget.acarreoExistente!.ancho.toString();
      _areaController.text = widget.acarreoExistente!.area.toString();
      _observacionesController.text = widget.acarreoExistente!.observaciones!;
    }
    _largoController.addListener(_calcularArea);
    _anchoController.addListener(_calcularArea);
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    return Scaffold(
      backgroundColor: mainBgColor,
      appBar: AppBar(
        title: Text('Agregar acarreo', style: TextStyle(color: Colors.white)),
        backgroundColor: customBlack,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(16.0), child: _buildUI(responsive)),
      ),
    );
  }

  Widget _buildUI(Responsive responsive) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // _buildTextField(_viajesController, 'Cantidad de viajes',
          //     TextInputType.number, false),
          _buildTextField(
              _largoController, 'Largo', TextInputType.number, true),
          _buildTextField(
              _anchoController, 'Ancho', TextInputType.number, true),
          _buildTextField(_areaController, 'Área', TextInputType.number, true,
              enabled: false),
          _buildTextField(_observacionesController, 'Observaciones',
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
