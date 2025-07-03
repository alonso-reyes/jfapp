import 'package:jfapp/models/origen.model.dart';

abstract class OrigenState {}

class OrigenInitial extends OrigenState {}

class OrigenLoading extends OrigenState {}

class OrigenSuccess extends OrigenState {
  final OrigenesModel origen;

  OrigenSuccess({required this.origen});
}

class OrigenNoSuccess extends OrigenState {
  final OrigenesModel origen;

  OrigenNoSuccess({required this.origen});
}

class OrigenFailure extends OrigenState {
  final String error;

  OrigenFailure(this.error);
}
