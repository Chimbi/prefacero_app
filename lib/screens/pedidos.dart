import 'dart:io';


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prefacero_app/model/order.dart';
import 'package:prefacero_app/screens/pedido.dart';
import 'package:prefacero_app/utils/db.dart';
//import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';

  class PedidosPage extends StatefulWidget {
  @override
  _PedidosPageState createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  NumberFormat moneyFormat;

  @override
  void initState() {
    moneyFormat = NumberFormat("\$ ###,###,###", 'en_US');
  }

  /*
  Future<void> _saveAsFile(String polizaRef) async {
    Poliza poliza = await DatabaseService().getPolizaId(polizaRef);
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;
    final File file = File(appDocPath + '/' + 'document.pdf');
    print('Save as file ${file.path} ...');
    await file.writeAsBytes((await generateDocument(PdfPageFormat.a3, poliza)).save());
    Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => PdfViewer(file: file)),
    );
  }
*/
  /*
  Future<void> _getPedido(String polizaRef) async {
    Poliza poliza = await DatabaseService().getPedidoId(pedidoRef);
    Map<String, dynamic> uploads = await DatabaseService().getUploads(poliza.polizaId);
    Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => HistoryPage(poliza: poliza, uploads: uploads)),
    );
  }
*/

  Future<void> _getPedido(String polizaRef) async {
    Order pedido = await DatabaseService().getPedidoId(polizaRef);
    Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => PedidoPage(pedido)),
    );
  }


  Widget _builListItem(BuildContext context, data) {
    //var poliza = Poliza.fromMap(data.data);
    return Card(
      elevation: 7.0,
      child: ListTile(
        onTap: () => _getPedido(data.key),
        leading: Icon(Icons.business_center), //leading: data.issueState == 'Emitida' ? Icon(Icons.check_circle, color: Theme.of(context).buttonColor, size: 35.0,) : data.issueState == 'Borrador' ? Icon(Icons.mail_outline, color: Theme.of(context).accentColor, size: 30.0) : Icon(Icons.clear, color: Colors.red, size: 30.0),
        //trailing: IconButton(icon: Icon(Icons.picture_as_pdf, color: Colors.red,), onPressed: () => _saveAsFile(data.polizaId)),
        title: Text("Ref.Pedido ${data.refPedido}"),
        subtitle: Column(
          children: <Widget>[
            Text("Valor: ${moneyFormat.format(data.valorTotal)}",style: TextStyle(fontWeight: FontWeight.bold),),
            Text("uid: ${data.uid}"),
            Text("Fecha: ${data.fechaSolicitud}"),
            Text("Key: ${data.key}")
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Pedidos"),
      ),
      body: FutureBuilder(
        future: DatabaseService().getListaPedidos(user),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height:20.0),
                Text("Cargando informacion ..."),
              ],
            ),
          ); return RefreshIndicator(
            onRefresh: (){
              setState(() {
                snapshot.requireData;
              });
              return Future.delayed(Duration(seconds: 1));
            },
            child: ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) =>
                    _builListItem(context, snapshot.data[index])),
          );
        },
      ),
    );
  }
}
