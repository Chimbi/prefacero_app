import 'package:prefacero_app/model/regContable.dart';

class Producto {
  String key;
  String nombre;
  double long;
  double precio;
  int disp;
  int tiempoFab;
  int calibre;
  int linea;
  int grupo;
  int codigo;
  List<RegContable> infoContable;

  Producto({this.nombre, this.long, this.precio, this.disp, this.tiempoFab, this.calibre, this.linea, this.grupo, this.codigo});

  /*
  Producto.fromSnapshot(DataSnapshot snapshot){
      key = snapshot.key;
      nombre = snapshot.value["nombre"];
      long = snapshot.value["long"];
      precio = snapshot.value["precio"];
      disp = snapshot.value["disp"];
      tiempoFab = snapshot.value["tiempoFab"];
  }
*/
  Map<String, dynamic> toMap() => {
   "nombre": nombre, "precio": precio, "disp": disp, "tiempoFab": tiempoFab, "calibre": calibre
  };

  factory Producto.fromMap(Map<String, dynamic> map) => Producto(
      nombre: map["nombre"], linea: map["linea"], grupo: map["grupo"], codigo: map["codigo"], long: map["long"].toDouble(),  disp: map["disp"], tiempoFab: map["tiempoFab"], calibre: map["calibre"], precio: map["precio"].toDouble(),
      );


  toJson() {
    return {
      "nombre": nombre,
      "precio": precio,
      "disp": disp,
      "tiempoFab": tiempoFab,
      "calibre": calibre
    };
  }
}
