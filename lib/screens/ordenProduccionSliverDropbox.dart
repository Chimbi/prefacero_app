import 'dart:io';

import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prefacero_app/model/order.dart';
import 'package:prefacero_app/model/produccion.dart';
import 'package:prefacero_app/model/producto.dart';
import 'package:prefacero_app/model/regContable.dart';
import 'package:prefacero_app/pruebas/loadCSV.dart';
import 'package:prefacero_app/theme/style.dart';
import 'package:prefacero_app/utils/db.dart';
import 'package:provider/provider.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:intl/intl.dart';

// Adapted from offical flutter gallery:
// https://github.com/flutter/flutter/blob/master/examples/flutter_gallery/lib/demo/material/bottom_app_bar_demo.dart

class ProduccionSliverDropBox extends StatefulWidget {
  const ProduccionSliverDropBox({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProduccionSliverDropBoxState();
}

class _ProduccionSliverDropBoxState extends State<ProduccionSliverDropBox> {
  List<String> prodName = ["Perfil H", "Perfil T"];
  List<List<Producto>> productos = [
    [
      Producto(nombre: "H-18", precio: 23000, disp: 0),
      Producto(nombre: "H-20", precio: 24000, disp: 0),
      Producto(nombre: "H-22", precio: 25000, disp: 0),
      Producto(nombre: "H-24", precio: 26000, disp: 0)
    ],
    [
      Producto(nombre: "T-18", precio: 23000, disp: 0),
      Producto(nombre: "T-20", precio: 24000, disp: 0),
      Producto(nombre: "T-22", precio: 25000, disp: 0),
      Producto(nombre: "T-24", precio: 26000, disp: 0)
    ]
  ];

  ///Tipo perfil DropBox variables
  List<String> tipoPerfil = ["H", "K", "L", "T", "X", "S", "U"];
  List<String> tipoVentana = [
    "Ventana Tipo Aluminio",
    "Ventana Reja Horizontal",
    "Ventana solo marco",
    "Ventana Reja Bancaria"
  ];
  List<String> tipoPuerta = [
    "Puerta Tipo Aluminio",
    "Puerta Reja Vertical",
    "Puerta Lisa Pasador",
    "Puerta Lisa Cerradura 999"
  ];
  String tipoPerfilValue;

  ///Tipo producto DropBox variables
  List<String> tipoProducto = [
    "Perfiles Cal26",
    "Perfiles Cal24",
    "Puertas",
    "Ventanas",
    "Accesorios",
    "Otro"
  ];
  String tipoProductoValue = "Perfiles Cal26";

  ///Autocomplete modulo longitud
  String currentText = "";
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  List<String> modulos;
  List<String> medidaVentana;
  List<String> medidaPuerta;
  TextEditingController moduloController = TextEditingController();

  List<Produccion> produccionList = List();

  ///Cantidad Text Field
  TextEditingController cantidadController = TextEditingController();

  Produccion selProd;

  NumberFormat moneyFormat;

  Order pedido;

  @override
  void initState() {
    pedido = Order(listaProd: List());//Provider.of<Order>(context);
    moneyFormat = NumberFormat("\$ ###,###,###", 'en_US');
    modulos = ["18", "20", "22", "24", "26", "28", "30"];
    medidaVentana = ["08-08", "04-08", "06-08"];
    medidaPuerta = ["16-08", "16-06", "18-08", "18-06"];
    super.initState();
  }

  /// Widget para seleccionar el producto (Tipo producto, Tipo Perfil, Modulo y Cantidad). Llenado listaProducción
  Widget PerfilesWidget(
       List<String> tipoProducto, List<String> suggestions, Order pedido) {
    List<DropdownMenuItem> items;
    items = tipoProducto.map((value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          //Seleccion de tipo de perfil
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: Text("Tipo Perfil"),
                value: tipoPerfilValue,
                onChanged: (newValue) {
                  setState(() {
                    tipoPerfilValue = newValue;
                  });
                  print("Tipo perfil value $tipoPerfilValue");
                },
                items: items,
              ),
            ),
          ),
          //Seleccion de Módulo
          Expanded(
            child: SimpleAutoCompleteTextField(
              key: key,
              decoration: InputDecoration(labelText: "Módulo"),
              controller: moduloController,
              suggestions: suggestions,
              textChanged: (text) {
                currentText = text;
                moduloController.text = text;
              },
              clearOnSubmit: false,
              textSubmitted: (text) => setState(() {
                if (text != "") {
                  suggestions.contains(text)
                      ? print("$text")
                      : print("elemento no encontrado");
                }
              }),
            ),
          ),
          //Seleccion de Cantidad, busqueda de info produccion y llenado listaProduccion
          Expanded(
              child: TextField(
            controller: cantidadController,
            decoration: InputDecoration(labelText: 'Cantidad'),
            enabled: true,
            onSubmitted: (value) async {
              selProd = await DatabaseService().getProduccion("$tipoPerfilValue-${moduloController.text}", int.parse(cantidadController.text));
              setState(() {
                print("Selected Prod ${selProd.nombre}");
                selProd != null ? produccionList.add(selProd) : print("Selprod null");
                moduloController.text = "";
                cantidadController.text = "";
              });
            },
            onChanged: (val) {
              setState(() {
                //polizaObj.excecutionTime = int.parse(val);
                //polizaObj.notifyListeners();
              });
            },
          )),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    pedido.uid = user.uid;
    //TODO Hard coded
    pedido.refPedido = "Primer pedido";
    List<List<RegContable>> listaCon = List();

    return Scaffold(
      // SliverAppBar is declared in Scaffold.body, in slivers of a
      // CustomScrollView.
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text(
              "Pedido Nuevo",
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: new IconThemeData(color: Colors.white),
            elevation: 40.0,
            snap: false,
            floating: false,
            pinned: true,
            expandedHeight: 120.0,
          ),
          ///Seleccion productos y campos
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 12.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: <Widget>[
                  ///Seleccion tipo de producto
                  Row(
                    children: <Widget>[
                      Text(
                        "Tipo de producto:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      DropdownButton<String>(
                        hint: Text("Tipo Perfil"),
                        value: tipoProductoValue,
                        onChanged: (newValue) {
                          setState(() {
                            tipoProductoValue = newValue;
                          });
                          print("Tipo producto value $tipoProductoValue");
                        },
                        items: tipoProducto.map((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  (tipoProductoValue == "Perfiles Cal26" ||
                          tipoProductoValue == "Perfiles Cal24")
                      ? PerfilesWidget(tipoPerfil, modulos, pedido)
                      : Container(),
                ],
              ),
            ),
          ),
          ///Titulos tabla
          SliverPadding(
            padding: const EdgeInsets.only(left: 20.0),
            sliver: SliverToBoxAdapter(
              child: Table(children: [
                TableRow(children: [
                  Text("Cantidad",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Producto",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(""),
                ]),
              ]),
            ),
          ),
          ///Muestra productos seleccionados en forma de Tabla
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Table(
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      border: TableBorder.all(
                          color: Theme.of(context).hintColor, width: 0.3),
                      children: [
                        _buildTitle(context, produccionList[index], pedido)
                      ]);
                },
                childCount: produccionList.length,
              ),
            ),
          ),
          ///Parte inferior Costo Total, boton aprobar, boton infoContable y vaciar carrito
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  RaisedButton(
                      child: Text(
                        "Aprobar",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        print("Pressed");
                        //getInfoContPedido(pedido)?.then((int) async {if(int==1){sendMessage(await generateCsv(pedido));}});
                        //var path = await generateCsv(pedido);
                        //await sendMessage(path);
                        //var map = await DatabaseService().getInfoContable();
                        DatabaseService().setOrdenProduccion(produccionList).then((_) {
                          showDialog<void>(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Pedido enviado'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Text(
                                          'El pedido Ref: ${pedido.refPedido} fue enviado con exito '
                                          'para consultar el estado del mismo ingrese al historial de pedidos'),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('Aceptar'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        });
                      }),
                  RaisedButton(
                      child: Text(
                        "Info Contable",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        print("Pressed");
                        //var map = await DatabaseService().getInfoContable();
                        getInfoContPedido(pedido)?.then((val){
                          print("Info Contable ${pedido.listaProd.first.infoContable.toString()}");
                        });
                      }),
                  /*
                        listaCon = await DatabaseService().getInfoContPedido(pedido);
                        listaCon.forEach((reg){
                          print("Codigo ${reg.cantBase}");
                        });
                      })
                      */
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  TableRow _buildTitle(BuildContext context, Produccion prod, Order pedido) {
    return TableRow(children: [
      Center(child: Text("${prod.cantidad}")),
      Center(child: Text("${prod.nombre}")),
      IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            setState(() {
              produccionList.removeAt(produccionList.indexOf(prod));
            });
          })
    ]
        );
  }

  void _removeOne(Producto entry, int index, int prodIndex) {
    setState(() {
      if (entry.disp > 0) {
        //pedidoUid.child(entry.key).update({"disp": entry.disp - 1}); //update disp

        productos[index][prodIndex].disp = entry.disp - 1;
      }
    });
  }

  _addOne(Producto entry, int index, int prodIndex) {
    setState(() {
      if (entry.disp > 0) {
        //pedidoUid.child(entry.key).update({"disp": entry.disp + 1}); //update disp
        productos[index][prodIndex].disp = entry.disp + 1;
      } else {
        productos[index][prodIndex].disp = entry.disp + 1;
      }
    });
  }

  Future<int> getInfoContPedido(Order pedido) {
    pedido.listaProd.forEach((prod) async {
      print("Prod en getInfoCont ${prod.nombre}");
      prod.infoContable = List();
      prod.infoContable = await DatabaseService().getInfoContable(prod);
      pedido.notifyListeners();
      if(prod.infoContable!=null){
        print("Get info contable!!!: ${prod.infoContable}");
        return 1;
      } else return 0;
    });
  }
  Future<String> generateCsv(Order pedido) async{
    List<List<dynamic>> list = List();
    int i = 1;
    pedido.listaProd.forEach((prod){
      print("infoContable ${prod.infoContable.toString()}");
      prod.infoContable.forEach((c){
        print("Contable ${c.accountCode}");
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

    return path;
  }

  Future<void> sendMessage(path) async {
    String username = 'increeceapp@gmail.com';
    String password = 'Afr21052';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..attachments = [FileAttachment(File(path))]
      ..from = Address(username, 'Prefacero App')
      ..recipients.add('afrestrepocastro@gmail.com')
    //..ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com'])
    //..bccRecipients.add(Address('bccAddress@example.com'))
      ..subject = 'Orden de producción Proceso 1072 :: 😀 :: ${DateTime.now()}'
    //..text = 'This is the plain text.\nThis is line 2 of the text part.';
      ..html = "<h1>Orden de produción</h1>\n<p>Diana buenos días\,</p>"
          "\n<p>Por favor cargar a la contabilidad el archivo adjunto. Muchas gracias</p>"
          "\n<p>Saludos\,</p>\n<p>Andrés Restrepo</p>";

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print("Error $e");
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }


  }

}
