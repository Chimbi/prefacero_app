import 'package:flutter/material.dart';
import 'package:prefacero_app/screens/product_manager.dart';
import 'package:firebase_database/firebase_database.dart';
import '../model/producto.dart';
import '../model/order.dart';

class OrderManagement extends StatefulWidget {
  @override
  _OrderManagementState createState() => _OrderManagementState();
}

class _OrderManagementState extends State<OrderManagement> {
  String fakeUserId = "29IJRlHxM3e2kQJQbFPehNSYBu43";
  List<Producto> listaPed = List();
  Producto producto;
  Order pedido;
  final FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference dataRef;
  DatabaseReference refPedido;
  DatabaseReference pedidoUid;
  var initEntry;

  @override
  void initState() {
    print("begin init");
    producto = Producto();
    dataRef = database.reference().child("inventario");
    dataRef.onChildAdded.listen(_onAdded);
    refPedido = database.reference().child("pedido");
    pedidoUid = refPedido.child(fakeUserId);
    //dataRef.onChildChanged.listen(_onEntryChanged);
    print("last init");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView(
        physics: BouncingScrollPhysics(),
        // if you want IOS bouncing effect, otherwise remove this line
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        //change the number as you want
        children: listaPed.map((entry) {
          if (entry != null) {
            return Card(
                child: Column(
              children: <Widget>[
                ListTile(
                  title: Text(
                    entry.nombre == null ? "null" : entry.nombre,
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    children: <Widget>[
                      Text(
                        "Cant: ${entry.disp}",
                        style: TextStyle(
                            fontSize: 18.0, fontStyle: FontStyle.italic),
                      ),
                      Text(
                        "Cant: 0",
                        style: TextStyle(
                            fontSize: 18.0, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => _removeOne(entry)),
                    IconButton(
                        icon: Icon(Icons.add), onPressed: () => _addOne(entry))
                  ],
                )
              ],
            ));
          } else
            print("null");
        }).toList(),
      ),
    );
  }

  _onAdded(Event event) {
    setState(() {
      print("On entry added");
      listaPed.add(Producto.fromSnapshot(event.snapshot));
    });
  }

  void _removeOne(Producto entry) {
    setState(() {
      if(entry.disp>0) {
        pedidoUid.child(entry.key).update(
            {"disp": entry.disp - 1}); //update disp
        listaPed[listaPed.indexOf(entry)].disp = entry.disp - 1;
      }
    });
  }

  _addOne(Producto entry) {
    setState(() {
      if(entry.disp > 0) {
        pedidoUid.child(entry.key).update(
            {"disp": entry.disp + 1}); //update disp
        listaPed[listaPed.indexOf(entry)].disp = entry.disp + 1;
      } else {
        pedidoUid.child(entry.key).set(
            {
              "nombre": entry.nombre,
              "precio": entry.precio,
              "tiempoFab" : entry.tiempoFab,
              "disp": entry.disp + 1,
              "costo": entry.costo
            });
        listaPed[listaPed.indexOf(entry)].disp = entry.disp + 1;// Create item in the pedidos database
      }

    });
  }
}
