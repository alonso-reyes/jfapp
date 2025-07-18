import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfapp/blocs/login/login_bloc.dart';
import 'package:jfapp/blocs/login/login_event.dart';
import 'package:jfapp/blocs/login/login_state.dart';
import 'package:jfapp/components/custom_button.dart';
import 'package:jfapp/components/custom_texfield.dart';
import 'package:jfapp/constants.dart';
import 'package:jfapp/screens/jfMain_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Inicio de sesión exitoso')),
          );
          String tipoUsuario = state.user.user!.tipoUsuario.toString();

          tipoUsuario == 'JEFE DE FRENTE'
              ? Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => JfMainScreen(
                            user: state.user,
                          )),
                  (route) => false,
                )
              : Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => JfMainScreen(
                            user: state.user,
                          )),
                  (route) => false,
                );
          // Navegar a otra pantalla o realizar otra acción
        } else if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: mainBgColor,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Image.asset(
                    'assets/images/logo_rod.png',
                    height: 300,
                    width: 1500,
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    controller: usernameController,
                    hintText: 'Usuario',
                    obscureText: false,
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    controller: passwordController,
                    hintText: 'Contraseña',
                    obscureText: true,
                  ),
                  SizedBox(height: 32),
                  CustomButton(
                    text: 'Iniciar sesion',
                    onTap: () {
                      final username = usernameController.text.trim();
                      final password = passwordController.text.trim();
                      if (username.isNotEmpty && password.isNotEmpty) {
                        context.read<LoginBloc>().add(
                              LoginSubmitted(
                                username: username,
                                password: password,
                              ),
                            );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Por favor, complete todos los campos'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
