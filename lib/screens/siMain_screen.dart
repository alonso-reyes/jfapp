import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/logout/logout_bloc.dart';
import 'package:jfapp/blocs/logout/logout_state.dart';
import 'package:jfapp/blocs/reporte_diario_whatsapp/reporte_diario_wa_bloc.dart';
import 'package:jfapp/blocs/reporte_diario_whatsapp/reporte_diario_wa_event.dart';
import 'package:jfapp/constants.dart';
import 'package:jfapp/helpers/connectivity_helper.dart';
import 'package:jfapp/helpers/responsive_helper.dart';
import 'package:jfapp/helpers/session_manager.dart';
import 'package:jfapp/models/reporte-diario-wa.model.dart';
import 'package:jfapp/models/user.model.dart';
import 'package:jfapp/providers/model_provider.dart';
import 'package:jfapp/screens/login_screen.dart';
import 'package:jfapp/screens/superintendente/reporteDiarioWa_screen.dart';
import 'package:jfapp/widgets/user-drawer.widget.dart';
import 'dart:developer' as dev;

import 'package:http/http.dart' as http;

class SiMainScreen extends StatefulWidget {
  const SiMainScreen({super.key});

  @override
  _SiMainScreenState createState() => _SiMainScreenState();
}

class _SiMainScreenState extends State<SiMainScreen>
    with SingleTickerProviderStateMixin {
  late UserModel user;
  bool _tieneConexion = false;
  late TabController _tabController;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    user = SessionManager.user!;
    _tabController = TabController(length: 2, vsync: this);
    _initFuture = _inicializarCatalogos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _inicializarCatalogos() async {
    _tieneConexion = await ConnectivityHelper.tieneConexionInternet();
    await _cargarCatalogos();
  }

  Future<void> _cargarCatalogos() async {
    dev.log('Cargando catalogos de superintendente.....');
    if (_tieneConexion) {
      dev.log('Hay internet, despachando evento para consultar API');
      final token = user.token;
      final obraId = user.user!.obraId;
      context.read<ReporteDiarioWaBloc>().add(
            ReporteDiarioWaInStartRequest(token: token, obraId: obraId!),
          );
    } else {
      dev.log('Sin internet, cargando catálogo desde preferencias...');
      // final catalogoOffline =
      //     await ModelProvider.cargarCatalogoReporteDiarioWa();
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: mainBgColor,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

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
          ],
          child: Scaffold(
            backgroundColor: mainBgColor,
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              title: Text(
                user.user!.nombre!,
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: customBlack,
              bottom: TabBar(
                controller: _tabController,
                isScrollable: false,
                labelPadding: EdgeInsets.symmetric(horizontal: 16.0),
                labelStyle: TextStyle(fontSize: 12),
                labelColor: Colors.white,
                dividerColor: Colors.white,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: 'Actividades'),
                  Tab(text: 'Avances de obra'),
                ],
              ),
            ),
            drawer: UserDrawer(user: user),
            body: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ReporteDiarioWaScreen(
                    user: user,
                    obraId: user.user!.obraId!,
                  ),
                ),
                Text(''),
              ],
            ),
          ),
        );
      },
    );
  }
}
