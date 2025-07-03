import 'package:jfapp/models/catalogos-agua.model.dart';

abstract class CatalogosAcarreosAguaState {}

class CatalogosAcarreosAguaInitial extends CatalogosAcarreosAguaState {}

class CatalogosAcarreosAguaLoading extends CatalogosAcarreosAguaState {}

class CatalogosAcarreosAguaSuccess extends CatalogosAcarreosAguaState {
  final CatalogosAcarreosAguaModel catalogoAgua;

  CatalogosAcarreosAguaSuccess({required this.catalogoAgua});
}

class CatalogosAcarreosAguaNoSuccess extends CatalogosAcarreosAguaState {
  final CatalogosAcarreosAguaModel catalogoAgua;

  CatalogosAcarreosAguaNoSuccess({required this.catalogoAgua});
}

class CatalogosAcarreosAguaFailure extends CatalogosAcarreosAguaState {
  final String error;

  CatalogosAcarreosAguaFailure(this.error);
}
