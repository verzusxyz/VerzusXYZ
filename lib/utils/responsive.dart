import 'package:flutter/material.dart';
import 'dart:math';

class Responsive {
  final BuildContext context;
  late final double _width;
  late final double _height;
  late final double _diagonal;

  Responsive(this.context) {
    final Size size = MediaQuery.of(context).size;
    _width = size.width;
    _height = size.height;
    _diagonal = sqrt(pow(_width, 2) + pow(_height, 2));
  }

  double widthPercent(double percent) => _width * percent;
  double heightPercent(double percent) => _height * percent;
  double diagonalPercent(double percent) => _diagonal * percent;

  // Example usage for scalable font sizes
  double get headline1 => diagonalPercent(0.045);
  double get headline2 => diagonalPercent(0.04);
  double get headline3 => diagonalPercent(0.035);
  double get bodyText1 => diagonalPercent(0.025);
  double get bodyText2 => diagonalPercent(0.02);
  double get caption => diagonalPercent(0.015);
}
