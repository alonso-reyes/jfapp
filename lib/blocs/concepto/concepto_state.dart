import 'package:jfapp/models/concepto.model.dart';

abstract class ConceptoState {}

class ConceptoInitial extends ConceptoState {}

class ConceptoLoading extends ConceptoState {}

class ConceptoSuccess extends ConceptoState {
  final ConceptoModel concepto;

  ConceptoSuccess({required this.concepto});
}

class ConceptoNoSuccess extends ConceptoState {
  final ConceptoModel concepto;

  ConceptoNoSuccess({required this.concepto});
}

class ConceptoFailure extends ConceptoState {
  final String error;

  ConceptoFailure(this.error);
}
