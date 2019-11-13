import 'package:flutter/material.dart';

class User {
  final String uid;
  final String email;
  final String token;
  final String type;

  //TODO Define type of user as client, employee, director, manager

  User({@required this.uid, @required this.email, @required this.token, this.type});
}

class Cliente {
  int nit;
  String nombre;
  String nomComercial;
  String nomContacto;
  double reteFuente;
  double reteICA;
  int codCiudad;

  Cliente({this.nit, this.nombre, this.nomComercial, this.nomContacto, this.reteFuente, this.reteICA,
      this.codCiudad});

  factory Cliente.fromMap(Map<String, dynamic> map) => Cliente(
    nit: map["nit"],
    nombre: map["nombre"],
    nomComercial: map["nomComercial"],
    nomContacto: map["nomContacto"],
    reteFuente: map["reteFuente"],
    reteICA: map["reteICA"],
    codCiudad: map["codCiudad"],
  );

}