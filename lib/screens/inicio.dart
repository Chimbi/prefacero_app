import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prefacero_app/bloc/Provider.dart';
import 'package:prefacero_app/bloc/corteBloc.dart';
import 'package:prefacero_app/model/order.dart';
import 'package:prefacero_app/theme/style.dart';
import 'package:provider/provider.dart';

class MenuRoute {
  const MenuRoute(this.name, this.route, this.widget);

  final widget;
  final String name;
  final String route;
}


// Adapted from offical flutter gallery:
// https://github.com/flutter/flutter/blob/master/examples/flutter_gallery/lib/demo/material/bottom_app_bar_demo.dart

final List<MenuRoute> menu = <MenuRoute>[
  MenuRoute("Nuevo Pedido", '/pedido', Icon(Icons.add, size: 60.0, color: backgroundCol)),
  MenuRoute("Ingreso Rollo", '/rollo', Icon(Icons.person_outline, size: 60.0, color: backgroundCol)),
  MenuRoute("Orden Produccion", '/orden', Icon(Icons.build , size: 60.0, color: backgroundCol)),
  MenuRoute("Inventario", '/inventario', Icon(Icons.build , size: 60.0, color: backgroundCol)),
  MenuRoute("Corte", '/corte', Icon(Icons.content_cut , size: 60.0, color: backgroundCol)),
  MenuRoute("Doblez", '/doblez', Icon(Icons.all_inclusive, size: 60.0, color: backgroundCol)),
  MenuRoute("Soldadura", '/soldadura', Icon(Icons.all_inclusive, size: 60.0, color: backgroundCol)),
  MenuRoute("Historico", '/pedidos', Icon(Icons.history, size: 60.0, color: backgroundCol)),
  MenuRoute("Load Info", '/loadJson', Icon(Icons.cloud_upload, size: 60.0, color: backgroundCol)),
  MenuRoute("CSV Test", '/csv', Icon(Icons.add_circle_outline, size: 60.0, color: backgroundCol)),
  MenuRoute("Usuario", '/profile', Icon(Icons.person_outline, size: 60.0, color: backgroundCol)),
];


class PaginaInicio extends StatefulWidget {
  const PaginaInicio({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PaginaInicioState();
}

class _PaginaInicioState extends State<PaginaInicio> {

  @override
  Widget build(BuildContext context) {
    var polizaObj = Provider.of<Order>(context);
    var user = Provider.of<FirebaseUser>(context);
    final drawerHeader = UserAccountsDrawerHeader(
      accountEmail: Text(user.email),
      accountName: Text("Cuenta"),
      //accountEmail: polizaObj.intermediary != null ? Text('${polizaObj.intermediary.email}'): Container(),
      currentAccountPicture: CircleAvatar(
        child: Image.asset('assets/logo.png'),
        backgroundColor: Colors.white,
      )
    );
    final drawerItems = ListView(
      children: <Widget>[
        drawerHeader,
        ListTile(
          title: Text('Pedido nuevo'),
          onTap: () => Navigator.pushNamed(context, '/pedido'),
        ),
        /*
        ListTile(
            title: Text('Historico'),
            onTap: () => Navigator.pushNamed(context, '/polizas')
        ),
        ListTile(
          title: Text('Control Técnico'),
          onTap: () => DatabaseService().checkAutorization(context, polizaObj),//Navigator.pushNamed(context, '/control')
        ),
        */
        ListTile(
            title: Text('Perfil'),
            onTap: () => Navigator.pushNamed(context, '/profile')
        ),
      ],
    );
    return Scaffold(
      drawer: Drawer(
        elevation: 10.0,
        child: drawerItems,
      ),
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
                  (context,index) => _buildTitle(context, menu[index], polizaObj),
              childCount: menu.length,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, MenuRoute menu, polizaObj) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
          children: <Widget>[
            InkWell(
              onTap: () async {
                Navigator.pushNamed(context, menu.route);
                if (menu.route == "/corte") {
                  NewProvider.of(context).areaActual.add("corte");
                } else if (menu.route == "/doblez") {
                  NewProvider.of(context).areaActual.add("doblez");
                }
              },
              child: Card(
                  elevation: 7.0,
                  margin: EdgeInsets.all(5.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [BoxShadow(
                        blurRadius: 20.0,
                        offset: Offset(25, 25),
                        color: Colors.black54
                      )],
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                        gradient: LinearGradient(
                          colors: [hintCol, Colors.blue[800]],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ListTile(
                          title: Center(
                            child: Text(
                              "${menu.name}",
                              style: TextStyle(
                                color: Colors.white,
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          subtitle: menu.widget,
                        ),
                      ],
                    ),
                  )),
            ),
          ]
      ),
    );
  }
}