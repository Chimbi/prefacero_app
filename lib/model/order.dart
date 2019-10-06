import 'producto.dart';
import 'package:flutter/foundation.dart';

class Order with ChangeNotifier{
  String key;
  String uid;
  String refPedido;
  List<Producto> listaProd;

  Order({this.key, this.uid, this.refPedido, this.listaProd});

  factory Order.fromMap(Map<String, dynamic> map) => Order(
    uid: map["uid"],
    refPedido: map["refPedido"],
  );

  Map<String, dynamic> toMap() => {
    "uid": uid, "refPedido": refPedido,
  };


}