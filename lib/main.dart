import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prefacero_app/model/order.dart';
import 'package:prefacero_app/screens/home.dart';
import 'package:prefacero_app/screens/inicio.dart';
import 'package:prefacero_app/screens/login.dart';
import 'package:prefacero_app/screens/pedidos.dart';
import 'package:prefacero_app/screens/profile.dart';
import 'package:prefacero_app/theme/style.dart';
import 'package:prefacero_app/utils/auth.dart';
import 'package:provider/provider.dart';


void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Order>(builder: (context) => Order()), //polizaNumber: 784000000192,)
        StreamProvider<FirebaseUser>.value(value: AuthService().user),
      ],
      child: MaterialApp(
        theme: appTheme(),
          routes: {
            // When navigating to the "/" route, build the FirstScreen widget.
            '/': (context) => LoginPage(),
            //'/login': (context) => LoginPage(),
            // When navigating to the "/second" route, build the SecondScreen widget.
            '/inicio': (context) => PaginaInicio(),
            '/pedido': (context) => OrderManagement(),
            //'/terceros': (context) => AuxiliarPage(),
            //'/polizas': (context) => PolizasPage(),
            //'/pdfdemo': (context) => PdfDemo(),
            //'/csv': (context) => csvPage(),
            '/profile' : (context) => ProfilePage(),
            //'/control' : (context) => ControlPage(),
            //'/batch' : (context) => BatchPage(),
          }
      ),
    );
  }
}

