import 'package:flutter/material.dart';

class User {
  final String uid;
  final String email;
  final String token;

  User({@required this.uid, @required this.email, @required this.token});
}