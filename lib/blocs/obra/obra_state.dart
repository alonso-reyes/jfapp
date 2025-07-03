import 'package:jfapp/models/obra.model.dart';

abstract class ObraState {}

class ObraInitial extends ObraState {}

class ObraLoading extends ObraState {}

class ObraSuccess extends ObraState {
  final ObraModel obra;

  ObraSuccess({required this.obra});
}

class ObraFailure extends ObraState {
  final String error;

  ObraFailure(this.error);
}
