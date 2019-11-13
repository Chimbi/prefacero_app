import 'dart:io';

import 'package:prefacero_app/model/regContable.dart';
import 'package:prefacero_app/pruebas/loadCSV.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prefacero_app/model/order.dart';
import 'package:provider/provider.dart';

class csvPage extends StatefulWidget {
  @override
  _csvPageState createState() => _csvPageState();
}

class _csvPageState extends State<csvPage> {
  @override
  Widget build(BuildContext context) {
    var polizaObj = Provider.of<Order>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: Center(child: Text("Csv data")),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
          onPressed: () => generateCsv(polizaObj)),
    );
  }

  Future<void> generateCsv(Order pedido) async{
    List<List<dynamic>> list = List();
    int i = 1;
    pedido.listaProd.forEach((prod){
      print("infoContable ${prod.infoContable.toString()}");
      prod.infoContable.forEach((c){
        print("Contable ${c.accountCode}");
        //TODO costo falta multiplicarlo por la cantidad
        list.add([c.accountCode,c.transNature, (c.costo).toString(), DateTime.now().year, DateTime.now().month, DateTime.now().day, i++, c.nombre,c.linea,c.grupo,c.codigo, (c.cantBase).toString()]); //prod.nombre

      });
    });
    print("List ${list.toString()}");
    List<List<dynamic>> csvData = [
      <String>['TipoCompr', 'Codigo', 'NumCompr', 'Cuenta Cont','Naturaleza', 'Valor', 'Año', 'Mes', 'Dia', 'Secuencia', 'CCosto','SubCCosto',   'NIT',   'Descripcion','Linea','Grupo',  'Codigo', 'Cantidad', 'Bodega', 'TipoCruce', 'NumDocCruce', 'AñoVencCruce', 'MesVencCruce','DiaVencCruce','DescLarga', ],
      ...list.map((prod) => ['O','31',    '1072',    prod[0],        prod[1],   prod[2],prod[3],prod[4],prod[5],prod[6],       3,       0,    860353552,  prod[7],       prod[8], prod[9], prod[10], prod[11],      3,     "","","","","",""]),
    ];
    String csv = const ListToCsvConverter().convert(csvData);
    final String dir = (await getApplicationDocumentsDirectory()).path;

    final String path = '$dir/ordenProduccion.csv';
    //Create file
    final File file = File(path);
    //Save csv String
    await file.writeAsString(csv);

    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_)=> LoadAndViewCsvPage(path: path)));

  }
}
