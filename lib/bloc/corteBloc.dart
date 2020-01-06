import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prefacero_app/model/produccion.dart';
import 'package:prefacero_app/utils/db.dart';
import 'package:rxdart/rxdart.dart';

class CustomError extends Error {
  final String message;

  CustomError(this.message);

  @override
  String toString() {
    return 'CustomError{message: $message}';
  }


}

class CorteBloc {
  Map<String, OrdenProduccion> ordenMap;

  Stream<Map<String, OrdenProduccion>> get ordenes => _ordenesSubject.stream;

  final _ordenesSubject = BehaviorSubject<Map<String, OrdenProduccion>>();

  Sink<Map<String, dynamic>> get ordenUpdate => _ordenUpdateController.sink;

  final _ordenUpdateController = StreamController<Map<String, dynamic>>();


  Sink<OrdenProduccion> get newOrden  => _newOrdenController.sink;

  final _newOrdenController = StreamController<OrdenProduccion>();

  dispose() {
    _ordenesSubject.close();
  }

  CorteBloc() {
    //Initialize ordenList
    ordenMap = Map<String,OrdenProduccion>();

    getOrdenes().then((_) {
      print("OrdenList: ${ordenMap.toString()}");
      _ordenesSubject.add(ordenMap);
    });

    //Listen for the stream of changes in the form of a Map
    _ordenUpdateController.stream.listen((data) {
      evaluateChanges(data).then((_) {
        _ordenesSubject.add(ordenMap);
      }
      );
    });

    _newOrdenController.stream.listen((orden){
      ordenMap.putIfAbsent(orden.key, () => orden);
      _ordenesSubject.add(ordenMap);
    });

  }

  Future<Map<String, OrdenProduccion>> getOrdenes() async {
    print("Ejecución get Ordenes");
    ordenMap = await DatabaseService().getListaOrdenes();
    print("OrdenList ${ordenMap.toString()}");
    return ordenMap;
  }

  Future<void> evaluateChanges(Map<String, dynamic> data) async {
    print("Map en sink: ${data.toString()}");

    String key = data["key"];

    //Index se refiere al indice de la lista de detalle producción
    int index = data["index"];
    String proceso = data["proceso"];
    int cantidad = data["cantidad"];
    int valorAntes;
    int cantOrden;
    int cantidadNueva;

    var orden = ordenMap[key];

    //Obtiene cantidad en orden y valor anterior
    if (proceso == "Corte") {
      valorAntes = orden.listProdPerfiles[index].terminadaCorte;
      cantOrden = orden.listProdPerfiles[index].cantCorte;
      cantidadNueva = valorAntes + cantidad;
      if (cantidadNueva > cantOrden) {
        throw CustomError("La cantidad no puede ser superior a la orden");
      } else {
        orden.listProdPerfiles[index].terminadaCorte = cantidadNueva;
      }
    } else {
      valorAntes = orden.listProdPerfiles[index].terminadaDespunte;
      print("ValorAntes $valorAntes");
      cantOrden = orden.listProdPerfiles[index].cantDespunte;
      print("Cantidad Orden: $cantOrden");
      cantidadNueva = valorAntes + cantidad;
      print("Cantidad nueva: $cantidadNueva");
      if (cantidadNueva > cantOrden) {
        throw CustomError("La cantidad no puede ser superior a la orden");
      } else {
        orden.listProdPerfiles[index].terminadaDespunte = cantidadNueva;
      }
    }
    ordenMap[key] = orden;
    //ordenList.update(key, (orden) => orden);
    print("Orden List term corte key: $key: ${ordenMap[key].listProdPerfiles[index].terminadaCorte}");

    print("Terminadas orden: ${orden.listProdPerfiles[index].terminadaCorte.toString()}");
    _ordenesSubject.add(ordenMap);
    //print("Terminada despunte: ${orden.listProdPerfiles[index].terminadaDespunte}");
    await DatabaseService().setOrden(orden, orden.listProdPerfiles[index].nombre , index);
  }
}
