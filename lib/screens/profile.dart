//import 'package:appsolidariav3/model/polizaModel.dart';

import 'package:prefacero_app/utils/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  final AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil de usuario"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: <Widget>[
                Image.asset(
                  "assets/logo.png",
                  scale: 1.0,
                ),
                SizedBox(height: 20.0,),
                Text("Informacion de usuario", style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold),),
                Text("Email: ${user.email}"),
                SizedBox(height: 30.0,),
      ],
            ),
            SizedBox(height: 30.0,),
            RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.circular(10.0)),
                child: Text("Salir", style: TextStyle(color: Colors.white),),
                onPressed: () async {
                  await auth.signOut();
                  Navigator.popUntil(context, ModalRoute.withName("/"));
                }),
          ],
        ),
      ),
    );
  }
}
