//part of 'package:jfapp/blocs/login/login_bloc.dart';

import 'package:jfapp/models/user.model.dart';

abstract class LogoutState {}

class LogoutInitial extends LogoutState {}

class LogoutLoading extends LogoutState {}

class LogoutSuccess extends LogoutState {
  final String message;

  LogoutSuccess(this.message);
}

class LogoutFailure extends LogoutState {
  final String error;

  LogoutFailure(this.error);
}
