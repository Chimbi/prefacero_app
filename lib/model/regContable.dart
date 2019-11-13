class RegContable{
  int linea;
  int codigo;
  int grupo;
  double cantBase;
  double costo;
  String transNature;
  String accountCode;
  String nombre;

  RegContable({this.linea, this.codigo, this.grupo, this.cantBase, this.costo,
      this.transNature, this.accountCode, this.nombre});

  factory RegContable.fromMap(Map<String, dynamic> map, int cantidad) => RegContable(
      linea: map["linea"],
      codigo: map["codigo"],
      grupo: map["grupo"],
      cantBase: map["cantBase"].toDouble() * cantidad,
      costo: map["costo"].toDouble() * cantidad,
      transNature: map["transNature"].toString(),
      accountCode: map["accountCode"].toString(),
      nombre: map["nombre"]
      );

//codigo: 18,  linea: 2, costo: 7642.35, transNature: D, grupo: 23, cantBase: 1, accountCode: 1410050000
}