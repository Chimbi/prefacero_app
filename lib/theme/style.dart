import 'package:flutter/material.dart';

const Color accent = Color(0xff003f75);
const Color hintCol = Color(0xff428bca);
const Color backgroundCol = Colors.grey;

ThemeData appTheme() {
  return ThemeData(
    primaryColor: hintCol,
    accentColor: accent,
    hintColor: hintCol,
    dividerColor: accent,
    buttonColor: hintCol,
    scaffoldBackgroundColor: Colors.white,
    canvasColor: Colors.white,
  );
}