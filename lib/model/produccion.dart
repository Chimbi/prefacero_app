
import 'package:prefacero_app/model/order.dart';
import 'package:prefacero_app/model/producto.dart';
import 'package:prefacero_app/model/regContable.dart';

class Produccion{
  int cantidad; //Cantidad de producto
  int cantidadTerm;
  int cantAdicional; //Cantidad producto Adicional
  String prodAdicional;  //Referencia adicional
  int cantLam;  //Cantidad de producto principal por lamina
  double des;  //Desarrollo producto principal
  // Falta desarrollo del producto adicional
  double kilosLamina;
  double longLamina;
  String nombre;
  int laminas;
  List<RegContable> infoContable;


  Produccion({this.cantidad, this.cantidadTerm, this.cantAdicional, this.prodAdicional, this.cantLam, this.des, this.kilosLamina, this.longLamina, this.nombre, this.laminas});


  factory Produccion.fromMap(Map<String, dynamic> map) => Produccion(
    cantAdicional: map['cantAdicional'], prodAdicional: map['prodAdicional'], cantLam: map['cantLam'], des: map['des'].toDouble(),
    kilosLamina: map['kilosLamina'], longLamina: map['longLamina'], nombre: map['nombre'],
  );


  Map<String, dynamic> toMap() => {
     "cantidad": cantidad, "cantidadTerm": cantidadTerm, "cantAdicional": cantAdicional, "prodAdicional": prodAdicional, "cantLam": cantLam, "des": des, "kilosLamina": kilosLamina,
    "longLamina": longLamina, "nombre": nombre,
  };
}

class DetalleRollo {
  String remesa;
  DateTime fecha;
  String producto;
  double kilos;
  double disponible;
  double gastado;
  int terminado;
  List<ConsumoRollo> consumo;

  DetalleRollo({this.remesa, this.fecha, this.producto, this.kilos,
      this.disponible, this.gastado, this.terminado});

  factory DetalleRollo.fromMap(Map<String, dynamic> map) => DetalleRollo(
    remesa: map['remesa'],
    fecha: map['fecha'].toDate(),
    producto: map['producto'],
    kilos: map['kilos'].toDouble(),
    disponible: map['disponible'].toDouble(),
    gastado: map ['gastado'].toDouble(),
    terminado: map['terminado'],
  );

  Map<String, dynamic> toMap() => {
    "remesa": remesa,
    "fecha": fecha,
    "producto": producto,
    "kilos": kilos,
    "disponible": kilos,
    "gastado": 0,
    "terminado": 0
  };




}

class ConsumoRollo {
  String producto;
  DateTime fecha;
  int numOrden;
  double longTotal;
  int cantidadLam;
  double kilosTotales;


  ConsumoRollo({this.producto, this.fecha, this.numOrden, this.longTotal,
      this.cantidadLam, this.kilosTotales});

  factory ConsumoRollo.fromMap(Map<String, dynamic> map) => ConsumoRollo(
    producto: map["producto"],
    fecha: map["fecha"].toDate(),
    numOrden: map["numOrden"],
    longTotal: map["longTotal"].toDouble(),
    cantidadLam: map["cantidadLam"],
    kilosTotales: map["kilosTotales"]
  );

  Map<String, dynamic> toMap() => {
    "producto": producto,
    "fecha": fecha,
    "numOrden": numOrden,
    "longTotal": longTotal,
    "cantidadLam": cantidadLam,
    "kilosTotales": kilosTotales
  };
}


class OrdenProduccion {
  String key; //Key de la orden
  DateTime fechaSolicitud;
  String uid; //uid de la persona que crea la solicitud
  List<DetalleProdPerfil> listProdPerfiles;

  OrdenProduccion({this.key, this.fechaSolicitud, this.uid, this.listProdPerfiles});

  factory OrdenProduccion.fromMap(Map<String, dynamic> map) => OrdenProduccion(
    key: map['key'],
    fechaSolicitud: map['fechaSolicitud'].toDate()
  );

  Map<String, dynamic> toMap() =>
      {
        "key": key, "uid": uid, "fechaSolicitud": fechaSolicitud,
      };

}

class DetalleProdPerfil {
  String nombre;
  String textoCorte;
  int cantCorte;
  int terminadaCorte;

  String textoDespunte;
  String textoDespunte2;
  int cantDespunte;
  int terminadaDespunte;

  DetalleProdPerfil({this.nombre, this.textoCorte, this.cantCorte, this.terminadaCorte,
      this.textoDespunte, this.textoDespunte2, this.cantDespunte,
      this.terminadaDespunte});

  Map<String, dynamic> toMap() =>
      {
        "nombre": nombre, "textoCorte":textoCorte, "cantCorte": cantCorte, "terminadaCorte":terminadaCorte,
        "textoDespunte":textoDespunte, "textoDespunte2": textoDespunte2, "cantDespunte": cantDespunte,
        "terminadaDespunte": terminadaDespunte
      };

  factory DetalleProdPerfil.fromMap(Map<String,dynamic> map) => DetalleProdPerfil(
    nombre: map['nombre'],
    textoCorte: map['textoCorte'],
    cantCorte: map['cantCorte'],
    terminadaCorte: map['terminadaCorte'],
    textoDespunte: map['textoDespunte'],
    textoDespunte2: map['textoDespunte2'],
    cantDespunte: map['cantDespunte'],
    terminadaDespunte: map['terminadaDespunte']
  );

  factory DetalleProdPerfil.fromProduccion(Produccion prod, int anchoLam, bool rollo) => DetalleProdPerfil(
    nombre: prod.nombre,
    textoCorte: "${prod.laminas} lamina${prod.laminas > 1 ? "s" : ""} de ${prod.longLamina} (${prod.cantidad} ${prod.nombre})",
    cantCorte: prod.laminas,
    terminadaCorte: 0,
    textoDespunte: rollo == true ? "${prod.laminas} laminas en ${prod.cantLam} tiras de ${prod.des}cm = ${prod.laminas*prod.cantLam} tiras de ${prod.nombre}" : "",
    textoDespunte2: rollo == true ? "${prod.cantAdicional != 0 ? "Por cada lamina sale ${prod.cantAdicional} tira de ${(anchoLam - prod.des*prod.cantLam).toStringAsFixed(2)} cm = ${prod.cantAdicional*prod.laminas} tiras de ${prod.prodAdicional}" :""}": "",
    terminadaDespunte: 0,
    cantDespunte: rollo == true ? prod.laminas : 0,
  );

}


