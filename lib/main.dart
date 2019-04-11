import 'package:flutter/material.dart';
import 'package:prefacero_app/screens/home.dart';


void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          accentColor: Colors.deepOrange),
      home: Home(),
    );
  }
}

