//part of 'package:jfapp/blocs/login/login_bloc.dart';

abstract class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  //final Map<String, String> params;
  final String username;
  final String password;

  //LoginSubmitted({required this.params});
  LoginSubmitted({required this.username, required this.password});
}

// class LogoutSubmitted extends LoginEvent {
//   //final Map<String, String> params;
//   final String token;

//   //LoginSubmitted({required this.params});
//   LogoutSubmitted({required this.token});
// }
