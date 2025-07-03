//part of 'package:jfapp/blocs/login/login_bloc.dart';

abstract class LogoutEvent {}

class LogoutSubmitted extends LogoutEvent {
  //final Map<String, String> params;
  final String token;

  //LoginSubmitted({required this.params});
  LogoutSubmitted({required this.token});
}
