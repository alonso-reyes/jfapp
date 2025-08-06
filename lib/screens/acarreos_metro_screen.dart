import 'package:flutter/material.dart';
import 'package:jfapp/constants.dart';
import 'package:jfapp/helpers/responsive_helper.dart';
import 'package:jfapp/models/acarreos-metro.model.dart';
import 'package:jfapp/models/user.model.dart';

class AcarreosMetroScreen extends StatefulWidget {
  final AcarreoMetro? acarreoExistente;

  const AcarreosMetroScreen({
    super.key,
    this.acarreoExistente,
  });

  @override
  _AcarreosMetroScreenState createState() => _AcarreosMetroScreenState();
}

class _AcarreosMetroScreenState extends State<AcarreosMetroScreen> {
  final TextEditingController _viajesController = TextEditingController();
  final TextEditingController _largoController = TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();

  void _guardarAcarreo() {
    if (_largoController.text.isNotEmpty) {
      final acarreo = AcarreoMetro(
        largo: double.parse(_largoController.text),
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
      // _viajesController.text = widget.acarreoExistente!.viajes.toString();
      _observacionesController.text = widget.acarreoExistente!.observaciones!;
    }
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
