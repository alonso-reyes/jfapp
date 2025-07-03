import 'package:jfapp/models/uso-material.model.dart';

abstract class UsoUsoMaterialState {}

class UsoMaterialInitial extends UsoUsoMaterialState {}

class UsoMaterialLoading extends UsoUsoMaterialState {}

class UsoMaterialSuccess extends UsoUsoMaterialState {
  final UsoMaterialModel usoMaterial;

  UsoMaterialSuccess({required this.usoMaterial});
}

class UsoMaterialNoSuccess extends UsoUsoMaterialState {
  final UsoMaterialModel usoMaterial;

  UsoMaterialNoSuccess({required this.usoMaterial});
}

class UsoMaterialFailure extends UsoUsoMaterialState {
  final String error;

  UsoMaterialFailure(this.error);
}
