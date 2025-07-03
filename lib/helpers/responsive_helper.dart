import 'package:flutter/material.dart';
import 'dart:math';

class Responsive {
  bool? _isTablet, _web;
  double? _width, _height, _diagonal, _aspectRatio;

  double get width => _width!;
  double get height => _height!;
  bool get isTablet => _isTablet!;
  double get diagonal => _diagonal!;
  double get aspectRatio => _aspectRatio!;
  bool get web => _web!;

  static Responsive of(BuildContext context) => Responsive(context);

  Responsive(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _width = size.width;
    _height = size.height;
    _aspectRatio = size.aspectRatio;

    _diagonal = sqrt(pow(_width!, 2) + pow(_height!, 2));
    _isTablet = size.width > 500;
    _web = size.width > 1100;
  }

  double wp(double percent) {
    var sizeWeb = ((_width! / 0.9988) - _width!);
    var sizeTablet = ((_width! / 0.998) - _width!);
    if (_web!) {
      return (_width! / sizeWeb) * percent / 100;
    } else if (_isTablet!) {
      return (_width! / sizeTablet) * percent / 100;
    } else {
      return _width! * percent / 100;
    }
  }

  double hp(double percent) => _height! * percent / 100;

  double dp(double percent) {
    var sizeWeb = ((_width! / 0.9988) - _width!);
    var sizeTablet = ((_width! / 0.998) - _width!);
    if (_web!) {
      return (_diagonal! / sizeWeb) * percent / 100;
    } else if (_isTablet!) {
      return (_diagonal! / sizeTablet) * percent / 100;
    } else {
      return _diagonal! * percent / 100;
    }
  }
}
