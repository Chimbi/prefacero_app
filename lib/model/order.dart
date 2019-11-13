import 'package:prefacero_app/model/user.dart';

import 'producto.dart';
import 'package:flutter/foundation.dart';

class Order with ChangeNotifier{
  String key;
  String uid;
  Cliente cliente;
  String refPedido;
  double valorTotal;
  DateTime fechaSolicitud;
  List<Producto> listaProd;

  Order({this.key, this.uid, this.cliente, this.refPedido, this.valorTotal, this.fechaSolicitud, this.listaProd});

  factory Order.fromMap(Map<String, dynamic> map) => Order(
    uid: map["uid"],
    key: map["key"],
    cliente: map["cliente"],
    refPedido: map["refPedido"],
    valorTotal: map["valorTotal"],
    fechaSolicitud: map["fechaSolicitud"].toDate(),
  );

  Map<String, dynamic> toMap() => {
     "uid": uid, "key": key, "cliente": cliente.nomComercial, "refPedido": refPedido, "valorTotal": valorTotal, "fechaSolicitud" : fechaSolicitud
  };
}


