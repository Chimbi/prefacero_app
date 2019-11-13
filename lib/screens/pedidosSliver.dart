import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prefacero_app/model/order.dart';
import 'package:prefacero_app/model/producto.dart';
import 'package:prefacero_app/theme/style.dart';
import 'package:prefacero_app/utils/db.dart';
import 'package:provider/provider.dart';

// Adapted from offical flutter gallery:
// https://github.com/flutter/flutter/blob/master/examples/flutter_gallery/lib/demo/material/bottom_app_bar_demo.dart


class PedidosSliver extends StatefulWidget {
  const PedidosSliver({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PedidosSliverState();
}

class _PedidosSliverState extends State<PedidosSliver> {
  List<String> prodName = ["Perfil H", "Perfil T"];
  List<List<Producto>> productos = [
    [Producto(nombre: "H-18",precio: 23000, disp: 0), Producto(nombre: "H-20",precio: 24000, disp: 0), Producto(nombre: "H-22",precio: 25000, disp: 0), Producto(nombre: "H-24",precio: 26000, disp: 0)],
    [Producto(nombre: "T-18",precio: 23000, disp: 0), Producto(nombre: "T-20",precio: 24000, disp: 0), Producto(nombre: "T-22",precio: 25000, disp: 0), Producto(nombre: "T-24",precio: 26000, disp: 0)]
  ];


  @override
  Widget build(BuildContext context) {
    var polizaObj = Provider.of<Order>(context);
    var user = Provider.of<FirebaseUser>(context);
    return Scaffold(
      // SliverAppBar is declared in Scaffold.body, in slivers of a
      // CustomScrollView.
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            iconTheme: new IconThemeData(color: Theme.of(context).accentColor),
            elevation: 20.0,
            backgroundColor: Colors.white,
            snap: true,
            floating: true,
            expandedHeight: 160.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Pedido Nuevo", style: TextStyle(color: Theme.of(context).accentColor)
              ),
              background: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
          ),
          // If the main content is a list, use SliverList instead.
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildTitle(context, productos[index], index);
              },
              childCount: productos.length,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, List<Producto> prod, int index) {
    return SizedBox(
      height: 240.0,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                title: Text("${prodName[index]}"),
                subtitle: Text("Perfil en acero galvanizado"),
              ),
              Expanded(
                child: ListView.builder(
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: prod.length,
                  itemBuilder: (BuildContext context, int prodIndex) => Card(
                    child: Container(
                        height: 500,
                        width: 100,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Center(
                                child: Text(
                                  prod[prodIndex].nombre,
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              subtitle: Column(
                                children: <Widget>[
                                  Text(
                                    "Cant: ${prod[prodIndex].disp}",
                                    style: TextStyle(
                                        fontSize: 18.0, fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ),
                            prod[prodIndex].disp == 0 ? RaisedButton(color: Colors.grey[100],child: Text("Agregar"),onPressed: () => _addOne(prod[prodIndex], index, prodIndex)) :
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () => _removeOne(prod[prodIndex],index, prodIndex)),
                                IconButton(
                                    icon: Icon(Icons.add), onPressed: () => _addOne(prod[prodIndex],index, prodIndex))
                              ],
                            )
                          ],
                        ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _removeOne(Producto entry, int index, int prodIndex) {
    setState(() {
      if(entry.disp>0) {
        //pedidoUid.child(entry.key).update({"disp": entry.disp - 1}); //update disp

        productos[index][prodIndex].disp = entry.disp - 1;
      }
    });
  }

  _addOne(Producto entry, int index, int prodIndex) {
    setState(() {
      if(entry.disp > 0) {
        //pedidoUid.child(entry.key).update({"disp": entry.disp + 1}); //update disp
        productos[index][prodIndex].disp = entry.disp + 1;
      } else {
        productos[index][prodIndex].disp = entry.disp + 1;
      }
    });
  }
}
