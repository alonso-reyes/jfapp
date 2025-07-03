import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jfapp/blocs/camiones/camiones_bloc.dart';
import 'package:jfapp/blocs/catalogos_acarreos_volumen/catalogos_acarreos_volumen_bloc.dart';
import 'package:jfapp/blocs/concepto/concepto_bloc.dart';
import 'package:jfapp/blocs/familias_maquinaria/familias_maquinaria_bloc.dart';
import 'package:jfapp/blocs/generales/generales_bloc.dart';
import 'package:jfapp/blocs/login/login_bloc.dart';
import 'package:jfapp/blocs/logout/logout_bloc.dart';
import 'package:jfapp/blocs/obra/obra_bloc.dart';
import 'package:jfapp/blocs/personal/personal_bloc.dart';
import 'package:jfapp/blocs/reporte_diario_whatsapp/reporte_diario_wa_bloc.dart';
import 'package:jfapp/blocs/turno/turno_bloc.dart';
import 'package:jfapp/blocs/zonas-trabajo/zonas_trabajo_bloc.dart';
import 'package:jfapp/models/user.model.dart';
import 'package:jfapp/providers/maquinaria_provider.dart';
import 'package:jfapp/providers/model_provider.dart';
import 'package:jfapp/providers/personal_provider.dart';
import 'package:jfapp/providers/preference_provider.dart';
import 'package:jfapp/providers/photo_provider.dart';
import 'package:jfapp/screens/jfMain_screen.dart';
import 'package:jfapp/screens/login_screen.dart';
import 'dart:io';

import 'package:jfapp/screens/siMain_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceProvider.init();
  await ModelProvider.init();
  await MaquinariaProvider.init();
  await PersonalProvider.init();
  await PhotoProvider.init();
  await dotenv.load(fileName: ".env");

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LoginBloc()),
        BlocProvider(create: (_) => LogoutBloc()),
        BlocProvider(create: (_) => ObraBloc()),
        BlocProvider(create: (_) => TurnoBloc()),
        BlocProvider(create: (_) => ZonaTrabajoBloc()),
        BlocProvider(create: (_) => ConceptoBloc()),
        BlocProvider(create: (_) => CamionesBloc()),
        BlocProvider(create: (_) => CatalogosAcarreosVolumenBloc()),
        BlocProvider(create: (_) => FamiliaMaquinariaBloc()),
        BlocProvider(create: (_) => CatalogoPersonalBloc()),
        BlocProvider(create: (_) => GeneralesBloc()),
        /* App super intendente */
        BlocProvider(create: (_) => ReporteDiarioWaBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Crear un usuario de prueba
    User testUser = User(
        id: 1,
        tipoUsuario: '',
        name: "Andres reyes",
        email: "johndoe@example.com",
        obraId: 1);

    // Crear un modelo de usuario de prueba
    UserModel testUserModel = UserModel(
      token: "3|glqPeqGIbK0leMlouLDMAepawJlXAGYyUDiqQMb40706ea9c",
      token_type: "Bearer",
      success: true,
      messages: "User loaded successfully",
      user: testUser,
    );

    return MaterialApp(
      title: 'JFAPP',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: JfMainScreen(user: testUserModel),
    );

    return MaterialApp(
      title: 'JFAPP',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}
