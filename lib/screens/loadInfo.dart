import 'package:flutter/material.dart';
import 'dart:convert';


class LoadJson1 extends StatefulWidget {
  @override
  _LoadJson1State createState() => _LoadJson1State();
}

class _LoadJson1State extends State<LoadJson1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cargar Informacion"),
      ),
      body: Center(
        child: Container(
          child: FutureBuilder(
              future: DefaultAssetBundle.of(context).loadString('assets/infoGeneral2.json'),
              builder: (context,snapshot){
                if(snapshot.hasData){
                  var myData = json.decode(snapshot.data.toString());
                  return ListView.builder(
                      itemBuilder: (context, index){
                        return Card(
                          child: Column(
                            children: <Widget>[
                              Text("Producto: ${myData[index]['nombre'].toString()}"),
                              Text("Precio: \$ ${myData[index]['precio'].toString()}"),
                              Text("Longitud: ${myData[index]['long'].toString()}m"),
                            ],
                          ),
                        );
                      }
                  );
                } else {
                  print("No data available");
                  return Container();
                };

              }),
        ),
      ),
    );
  }
}
