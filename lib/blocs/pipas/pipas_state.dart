import 'package:jfapp/models/pipas.model.dart';

abstract class PipasState {}

class PipasInitial extends PipasState {}

class PipasLoading extends PipasState {}

class PipasSuccess extends PipasState {
  final PipasModel pipa;

  PipasSuccess({required this.pipa});
}

class PipasNoSuccess extends PipasState {
  final PipasModel pipa;

  PipasNoSuccess({required this.pipa});
}

class PipasFailure extends PipasState {
  final String error;

  PipasFailure(this.error);
}
