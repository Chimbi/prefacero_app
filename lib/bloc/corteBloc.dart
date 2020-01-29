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
  DetalleRollo rolloOrden;

  Stream<Map<String, OrdenProduccion>> get ordenes => _ordenesSubject.stream;

  final _ordenesSubject = BehaviorSubject<Map<String, OrdenProduccion>>();

  Sink<Map<String, dynamic>> get ordenUpdate => _ordenUpdateController.sink;

  final _ordenUpdateController = StreamController<Map<String, dynamic>>();


  Sink<OrdenProduccion> get newOrden  => _newOrdenController.sink;

  final _newOrdenController = StreamController<OrdenProduccion>();

  //Sink rollo orden actual
  Sink<DetalleRollo> get rolloActual  => _rolloActualController.sink;
  final _rolloActualController = StreamController<DetalleRollo>();

  dispose() {
    _ordenesSubject.close();
  }

  CorteBloc() {
    //Initialize ordenList
    ordenMap = Map<String,OrdenProduccion>();
    rolloOrden = DetalleRollo(remesa: "prueba");

    getOrdenes().then((_) {
      print("OrdenList: ${ordenMap.toString()}");
      _ordenesSubject.add(ordenMap);
    });

    //Listen for the stream of changes in the form of a Map
    _ordenUpdateController.stream.listen((data) {
      evaluateChanges(data, rolloOrden).then((_) {
        _ordenesSubject.add(ordenMap);
      }
      );
    });

    _newOrdenController.stream.listen((orden){
      ordenMap.putIfAbsent(orden.key, () => orden);
      _ordenesSubject.add(ordenMap);
    });

    _rolloActualController.stream.listen((rollo){
      rolloOrden = rollo;
      print("rollo actual es ${rolloOrden.remesa}");
    });

  }

  Future<Map<String, OrdenProduccion>> getOrdenes() async {
    print("Ejecución get Ordenes");
    ordenMap = await DatabaseService().getListaOrdenes();
    print("OrdenList ${ordenMap.toString()}");
    return ordenMap;
  }

  Future<void> evaluateChanges(Map<String, dynamic> data, DetalleRollo rollo) async {
    print("Map en sink: ${data.toString()}");
    print("Rollo en evaluate: ${rollo.remesa}");

    //key es el identificador de la orden
    String key = data["key"];

    //Index se refiere al indice de la lista de detalle producción
    int index = data["index"];
    String proceso = data["proceso"];
    int cantidad = data["cantidad"];
    DateTime fecha = data["fecha"];
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
        //Proceso Corte
        //Cantidad inferior o igual a la orden => modifica la cantidad terminada en la orden
        orden.listProdPerfiles[index].terminadaCorte = cantidadNueva;

        //Consumo del rollo se presenta unicamente en el corte no en despunte
        var consumoRollo = ConsumoRollo(producto: orden.listProdPerfiles[index].nombre, fecha:  fecha, numOrden: orden.numero, longTotal: orden.listProdPerfiles[index].longLamina*cantidad, cantidadLam: cantidad, kilosTotales: orden.listProdPerfiles[index].kilosLamina * cantidad);
        print("Consumo ${consumoRollo.fecha.toString()}");
        var nuevoRollo = await DatabaseService().setConsumoRollo(orden, consumoRollo, rollo);
        //TODO registrar en bitacora. Falta tiempo inicio completar el mapa
        //Se actualiza el bloc
        rolloActual.add(nuevoRollo);
      }
    } else {
      valorAntes = orden.listProdPerfiles[index].terminadaDespunte;
      cantOrden = orden.listProdPerfiles[index].cantDespunte;
      cantidadNueva = valorAntes + cantidad;
      if (cantidadNueva > cantOrden) {
        throw CustomError("La cantidad no puede ser superior a la orden");
      } else {
        //Proceso Despunte
        //Cantidad inferior o igual a la orden => modifica la cantidad terminada en la orden
        orden.listProdPerfiles[index].terminadaDespunte = cantidadNueva;
      }
    }
    //Actualiza en la lista la orden modificada
    ordenMap[key] = orden;
    //ordenList.update(key, (orden) => orden);

    _ordenesSubject.add(ordenMap);


    //print("Terminada despunte: ${orden.listProdPerfiles[index].terminadaDespunte}");
    await DatabaseService().setOrden(orden, orden.listProdPerfiles[index].nombre , index);
  }
}
