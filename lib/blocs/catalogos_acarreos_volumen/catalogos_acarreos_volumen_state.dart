import 'package:jfapp/models/catalogos-volumen.model.dart';

abstract class CatalogosAcarreosVolumenState {}

class CatalogosAcarreosVolumenInitial extends CatalogosAcarreosVolumenState {}

class CatalogosAcarreosVolumenLoading extends CatalogosAcarreosVolumenState {}

class CatalogosAcarreosVolumenSuccess extends CatalogosAcarreosVolumenState {
  final CatalogosVolumenModel catalogoVolumen;

  CatalogosAcarreosVolumenSuccess({required this.catalogoVolumen});
}

class CatalogosAcarreosVolumenNoSuccess extends CatalogosAcarreosVolumenState {
  final CatalogosVolumenModel camion;

  CatalogosAcarreosVolumenNoSuccess({required this.camion});
}

class CatalogosAcarreosVolumenFailure extends CatalogosAcarreosVolumenState {
  final String error;

  CatalogosAcarreosVolumenFailure(this.error);
}
