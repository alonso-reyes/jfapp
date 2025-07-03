//part of 'package:jfapp/blocs/login/login_bloc.dart';

import 'package:jfapp/models/user.model.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final UserModel user;

  LoginSuccess({required this.user});
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure(this.error);
}

// class LogoutSuccess extends LoginState {
//   final String message;

//   LogoutSuccess(this.message);
// }

// class LogoutFailure extends LoginState {
//   final String error;

//   LogoutFailure(this.error);
// }
