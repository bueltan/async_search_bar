import 'package:flutter/material.dart';

class SearchBarStyle {
  final Color backgroundColor;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  // Color of the cursor
  final Color cursorColor;

  const SearchBarStyle(
      {this.backgroundColor = const Color.fromRGBO(142, 142, 147, .15),
      this.padding = const EdgeInsets.all(5.0),
      this.cursorColor = Colors.white,
      this.borderRadius = const BorderRadius.all(Radius.circular(5.0)),
      this.borderColor = const Color.fromRGBO(142, 142, 147, .15)});
}
