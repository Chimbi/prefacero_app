import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prefacero_app/model/order.dart';

class PedidoPage extends StatefulWidget {
  Order pedido;


  PedidoPage(this.pedido);

  @override
  _PedidoPageState createState() => _PedidoPageState();
}

class _PedidoPageState extends State<PedidoPage> {
  NumberFormat moneyFormat;

  @override
  void initState() {
    moneyFormat = NumberFormat("\$ ###,###,###", 'en_US');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: Text("Pedido ${widget.pedido.refPedido}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
          subtitle: Text("Valor Total ${moneyFormat?.format(widget.pedido.valorTotal)}", style: TextStyle(color: Colors.white),),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Center(
            child: DataTable(
                columns: [
                  DataColumn(label: Text("Cantidad")),
                  DataColumn(label: Text("Producto")),
                ],
                rows: widget.pedido.listaProd.map((prod){
                  return DataRow(cells: [
                    DataCell(Text(prod.disp.toString())),
                    DataCell(Text(prod.nombre.toString())),
                  ]);
                }).toList()),
          ),
        ],
      ),
    );
  }
}
