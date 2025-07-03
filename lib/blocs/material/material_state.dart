import 'package:jfapp/models/material.model.dart';

abstract class MaterialSt {}

class MaterialInitial extends MaterialSt {}

class MaterialLoading extends MaterialSt {}

class MaterialSuccess extends MaterialSt {
  final MaterialModel material;

  MaterialSuccess({required this.material});
}

class MaterialNoSuccess extends MaterialSt {
  final MaterialModel material;

  MaterialNoSuccess({required this.material});
}

class MaterialFailure extends MaterialSt {
  final String error;

  MaterialFailure(this.error);
}
