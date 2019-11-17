
class Produccion{
  String uid;
  String key;
  int cantidad; //Cantidad de producto
  int cantAdicional; //Cantidad producto Adicional
  String prodAdicional;  //Referencia adicional
  int cantLam;  //Cantidad de producto principal por lamina
  double des;  //Desarrollo producto principal
  // Falta desarrollo del producto adicional
  double kilosLamina;
  double longLamina;
  String nombre;
  int laminas;


  Produccion({this.key, this.cantidad, this.cantAdicional, this.prodAdicional, this.cantLam, this.des, this.kilosLamina, this.longLamina, this.nombre, this.laminas});


  factory Produccion.fromMap(Map<String, dynamic> map) => Produccion(
    key: map['key'], cantAdicional: map['cantAdicional'], prodAdicional: map['prodAdicional'], cantLam: map['cantLam'], des: map['des'].toDouble(),
    kilosLamina: map['kilosLamina'], longLamina: map['longLamina'], nombre: map['nombre'],
  );


  Map<String, dynamic> toMap() => {
    "uid": uid, "key": key, "cantAdicional": cantAdicional, "prodAdicional": prodAdicional, "cantLam": cantLam, "des": des, "kilosLamina": kilosLamina,
    "longLamina": longLamina, "nombre": nombre,
  };
}

class OrdenProduccion{
  String key; //Key de la orden
  DateTime fechaSolicitud;
  String uid; //uid de la persona que crea la solicitud
  List<Produccion> listProduccion;

  OrdenProduccion({this.key, this.fechaSolicitud, this.uid, this.listProduccion});

  Map<String, dynamic> toMap() => {
    "key": key, "uid": uid, "fechaSolicitud": fechaSolicitud,
  };


}


