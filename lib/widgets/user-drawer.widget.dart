import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:jfapp/blocs/login/login_bloc.dart';
// import 'package:jfapp/blocs/login/login_event.dart';
// import 'package:jfapp/blocs/login/login_state.dart';
import 'package:jfapp/blocs/logout/logout_bloc.dart';
import 'package:jfapp/blocs/logout/logout_event.dart';
import 'package:jfapp/blocs/logout/logout_state.dart';
import 'package:jfapp/constants.dart';
import 'package:jfapp/helpers/helper.dart';
import 'package:jfapp/models/user.model.dart';
import 'package:jfapp/providers/preference_provider.dart';
import 'package:jfapp/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDrawer extends StatefulWidget {
  final UserModel user;

  UserDrawer({required this.user});

  @override
  _UserDrawerState createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: customBlack),
            child: Text(
              'Menú Principal',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Inicio'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          // ListTile(
          //   leading: Icon(Icons.settings),
          //   title: Text('Configuración'),
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          // ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Cerrar sesión'),
            onTap: () {
              Navigator.pop(context);
              print('Disparando evento LogoutSubmitted');
              context.read<LogoutBloc>().add(
                    LogoutSubmitted(
                      token: widget.user.token,
                    ),
                  );
            },
          ),
        ],
      ),
    );
  }
}
