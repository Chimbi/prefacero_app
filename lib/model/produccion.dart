
import 'package:cloud_firestore/cloud_firestore.dart';
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
  double kilosLaminaFleje;
  double longLamina;
  String nombre;
  int laminas;
  List<RegContable> infoContable;


  Produccion({this.cantidad, this.cantidadTerm, this.cantAdicional, this.prodAdicional, this.cantLam, this.des, this.kilosLamina, this.kilosLaminaFleje, this.longLamina, this.nombre, this.laminas});


  factory Produccion.fromMap(Map<String, dynamic> map) => Produccion(
    cantAdicional: map['cantAdicional'], prodAdicional: map['prodAdicional'], cantLam: map['cantLam'], des: map['des'].toDouble(),
    kilosLamina: map['kilosLamina'], kilosLaminaFleje: map['kilosLaminaFleje'], longLamina: map['longLamina'], nombre: map['nombre'],
  );


  Map<String, dynamic> toMap() => {
     "cantidad": cantidad, "cantidadTerm": cantidadTerm, "cantAdicional": cantAdicional, "prodAdicional": prodAdicional, "cantLam": cantLam, "des": des, "kilosLamina": kilosLamina,
    "kilosLaminaFleje": kilosLaminaFleje, "longLamina": longLamina, "nombre": nombre,
  };
}

class DetalleRollo {
  String remesa;
  DateTime fecha;
  String producto;
  String tipoRollo;
  double espesor;
  double kilos;
  double disponible;
  double gastado;
  int terminado;
  List<ConsumoRollo> consumo;

  DetalleRollo({this.remesa, this.fecha, this.producto, this.tipoRollo, this.espesor, this.kilos,
      this.disponible, this.gastado, this.terminado});

  factory DetalleRollo.fromMap(Map<String, dynamic> map) => DetalleRollo(
    remesa: map['remesa'],
    fecha: (map['fecha'] as Timestamp).toDate(),
    producto: map['producto'],
    tipoRollo: map['tipoRollo'],
    espesor: map['espesor'],
    kilos: map['kilos'],//.toDouble(),
    disponible: map['disponible'],//.toDouble(),
    gastado: map['gastado'].toDouble(),
    terminado: map['terminado'],
  );

  Map<String, dynamic> toMap() => {
    "remesa": remesa,
    "fecha": fecha,
    "producto": producto,
    "tipoRollo": tipoRollo,
    "espesor" : espesor,
    "kilos": kilos,
    "disponible": kilos,
    "gastado": 0,
    "terminado": 0
  };

}


class RegBitacora {
  String proceso;
  String numOrden;
  String producto;
  String area;
  List<String> responsable;
  int cantidad;
  DateTime tiempoInicio;
  DateTime tiempoFin;
  int anho;
  int mes;
  int tiempoSeg;

  RegBitacora({this.proceso, this.numOrden, this.producto, this.area, this.responsable,
      this.cantidad, this.tiempoInicio, this.tiempoFin, this.anho, this.mes,
      this.tiempoSeg});

  factory RegBitacora.fromMap(Map<String, dynamic> map) => RegBitacora(
    proceso: map["proceso"],
    numOrden: map["numOrden"],
    producto: map["producto"],
    area: map["area"],
    responsable: map["responsable"].toList(),
    cantidad: map["cantidad"],
    tiempoInicio: map["tiempoInicio"].toDate(),
    tiempoFin: map["tiempoFin"].toDate(),
    anho: map["anho"],
    mes: map["mes"],
    tiempoSeg: map["tiempoSeg"],
    //TODO revisar se deben incluirse
    //kilos, tipo de lamina, espesor
  );

  Map<String, dynamic> toMap() => {
    "proceso": proceso,
    "numOrden": numOrden,
    "producto": producto,
    "area": area,
    "responsable": responsable.asMap(),
    "cantidad": cantidad,
    "tiempoInicio": tiempoInicio,
    "tiempoFin": tiempoFin,
    "anho": anho,
    "mes": mes,
    "tiempoSeg": tiempoSeg
  };



}

class ConsumoRollo {
  String producto;
  DateTime fecha;
  String numOrden;
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
  String remesaRollo;
  String tipoRollo;
  double consumoOrden;
  String numero;
  String area;
  List<DetalleProdPerfil> listProdPerfiles;

  OrdenProduccion({this.key, this.fechaSolicitud, this.uid, this.remesaRollo, this.tipoRollo, this.consumoOrden, this.numero, this.area, this.listProdPerfiles});

  factory OrdenProduccion.fromMap(Map<String, dynamic> map) => OrdenProduccion(
    key: map['key'],
    numero: map['numero'].toString(),
    remesaRollo: map['remesaRollo'],
    tipoRollo: map['tipoRollo'],
    consumoOrden: map['consumoOrden'],
    area: map['area'],
    fechaSolicitud: map['fechaSolicitud'].toDate()
  );

  Map<String, dynamic> toMap() =>
      {
        "key": key, "numero": numero, "uid": uid, "remesaRollo": remesaRollo, "tipoRollo": tipoRollo, "consumoOrden": consumoOrden, "area": area, "fechaSolicitud": fechaSolicitud,
      };
  Map<String, dynamic> toMapDoblez() =>
      {
        "key": key, "numero": numero, "uid": uid, "tipoRollo": tipoRollo,  "fechaSolicitud": fechaSolicitud, "area": area
      };

}

class DetalleProdPerfil {
  String nombre;
  String textoCorte;
  int cantProceso;
  int terminadaProceso;

  String textoDespunte;
  String textoDespunte2;
  int cantDespunte;
  int terminadaDespunte;
  double longLamina;
  double kilosLamina; //Varia dependiendo si el producto se corta de rollo o fleje

  DetalleProdPerfil({this.nombre, this.textoCorte, this.cantProceso, this.terminadaProceso,
      this.textoDespunte, this.textoDespunte2, this.cantDespunte,
      this.terminadaDespunte, this.longLamina, this.kilosLamina});

  Map<String, dynamic> toMap() =>
      {
        "nombre": nombre, "textoCorte":textoCorte, "cantProceso": cantProceso, "terminadaProceso":terminadaProceso,
        "textoDespunte":textoDespunte, "textoDespunte2": textoDespunte2, "cantDespunte": cantDespunte,
        "terminadaDespunte": terminadaDespunte, "longLamina": longLamina, "kilosLamina": kilosLamina
      };

  factory DetalleProdPerfil.fromMap(Map<String,dynamic> map) => DetalleProdPerfil(
    nombre: map['nombre'],
    textoCorte: map['textoCorte'],
    cantProceso: map['cantProceso'],
    terminadaProceso: map['terminadaProceso'],
    textoDespunte: map['textoDespunte'],
    textoDespunte2: map['textoDespunte2'],
    cantDespunte: map['cantDespunte'],
    terminadaDespunte: map['terminadaDespunte'],
    longLamina: map['longLamina'],
    kilosLamina: map['kilosLamina']
  );

  factory DetalleProdPerfil.fromProduccion(Produccion prod, int anchoLam, String rollo) => DetalleProdPerfil(
    nombre: prod.nombre,
    textoCorte: "${prod.laminas} lamina${prod.laminas > 1 ? "s" : ""} de ${prod.longLamina} (${prod.cantidad} ${prod.nombre})",
    cantProceso: prod.laminas,
    terminadaProceso: 0,
    textoDespunte: rollo == "Rollo" ? "${prod.laminas} laminas en ${prod.cantLam} tiras de ${prod.des}cm = ${prod.laminas*prod.cantLam} tiras de ${prod.nombre}" : "",
    textoDespunte2: rollo == "Rollo" ? "${prod.cantAdicional != 0 ? "Por cada lamina sale ${prod.cantAdicional} tira de ${(anchoLam - prod.des*prod.cantLam).toStringAsFixed(2)} cm = ${prod.cantAdicional*prod.laminas} tiras de ${prod.prodAdicional}" :""}": "",
    terminadaDespunte: 0,
    cantDespunte: rollo == "Rollo" ? prod.laminas : 0,
    longLamina: prod.longLamina,
    kilosLamina: rollo == "Rollo" ? prod.kilosLamina: prod.kilosLaminaFleje
  );
}


