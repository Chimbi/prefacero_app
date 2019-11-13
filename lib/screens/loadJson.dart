import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:prefacero_app/model/producto.dart';
import 'package:prefacero_app/model/regContable.dart';
import 'package:prefacero_app/utils/db.dart';

class LoadJson extends StatefulWidget {
  @override
  _LoadJsonState createState() => _LoadJsonState();
}

class _LoadJsonState extends State<LoadJson> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cargar Informacion"),
      ),
      body: Center(
        child: Container(
          child: RaisedButton(
              child: Text("Get info"),
              onPressed: () async {
                var list = await loadProduct();
                print("Lista ${list.toString()}");
              }),
        ),
      ),
    );
  }
}



Future<List<Producto>> loadProduct() async {
  List<Producto> listProd = List();
  String jsonString = await _loadAsset();
  final jsonResponse = json.decode(jsonString);
  jsonResponse.forEach((prod) async {
    //await DatabaseService().setProd(prod);
    Producto producto = new Producto.fromMap(prod);
    print("Prod: ${producto.nombre} \$ ${producto.precio}");
    //loadProceso(producto.nombre);
    loadProduccion(producto.nombre);
    if(producto!= null){
      listProd.add(producto);
    }
  });
  return listProd;
}

Future<List<RegContable>> loadProceso(String producto) async {
  List<RegContable> listCont = List();
  String jsonString = await _loadAssetProceso();
  final jsonResponse = json.decode(jsonString);
  //print("Json ${jsonResponse['$producto'].toString()}");
  if(jsonResponse['$producto']!=null){
    jsonResponse['$producto'].forEach((k,V) async {
      await DatabaseService().setRegContable(V, k, producto);
      RegContable regContable = RegContable.fromMap(V, 1);
      listCont.add(regContable);
    });
    return listCont;
  } else {
   print("Producto $producto sin receta contable");
   return null;
  }
}

Future<void> loadProduccion(String producto) async {
  List<RegContable> listCont = List();
  String jsonString = await _loadAssetProduccion();
  final jsonResponse = json.decode(jsonString);
  //print("Json ${jsonResponse['$producto'].toString()}");
  if(jsonResponse['$producto']!=null){
    print("${jsonResponse['$producto']}");
    await DatabaseService().setInfoProduccion(jsonResponse['$producto'], producto);
    /*
    jsonResponse['$producto'].forEach((val) async {
        print("$producto: $val");
       //await DatabaseService().setInfoProduccion(val, key);
      //RegContable regContable = RegContable.fromMap(val, 1);
      //listCont.add(regContable);
    });
    */
  } else {
    print("Producto $producto sin receta contable");
    return null;
  }
}

Future<String> _loadAsset() async {
  return await rootBundle.loadString('assets/perfilesGeneral.json');
}

Future<String> _loadAssetProceso() async {
  return await rootBundle.loadString('assets/infoTerminado2.json');
}

Future<String> _loadAssetProduccion() async {
  return await rootBundle.loadString('assets/infoProduccion.json');
}