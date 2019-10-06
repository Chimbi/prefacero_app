import 'package:firebase_database/firebase_database.dart';

class Producto {
  String key;
  String nombre;
  int precio;
  int disp;
  int tiempoFab;
  int costo;

  Producto({this.nombre, this.precio, this.disp, this.tiempoFab, this.costo});

  Producto.fromSnapshot(DataSnapshot snapshot){
      key = snapshot.key;
      nombre = snapshot.value["nombre"];
      precio = snapshot.value["precio"];
      disp = snapshot.value["disp"];
      tiempoFab = snapshot.value["tiempoFab"];
      costo = snapshot.value["costo"];
  }

  Map<String, dynamic> toMap() => {
   "nombre": nombre, "precio": precio, "disp": disp, "tiempoFab": tiempoFab, "costo": costo
  };

  factory Producto.fromMap(Map<String, dynamic> map) => Producto(
      nombre: map["nombre"], precio: map["precio"], disp: map["disp"], tiempoFab: map["tiempoFab"],
      costo: map["costo"]
      );


  toJson() {
    return {
      "nombre": nombre,
      "precio": precio,
      "disp": disp,
      "tiempoFab": tiempoFab,
      "costo": costo
    };
  }
}
