import 'dart:async';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prefacero_app/model/order.dart';
import 'package:prefacero_app/model/producto.dart';
import 'package:prefacero_app/model/regContable.dart';
import 'package:prefacero_app/model/user.dart';
import 'package:prefacero_app/pruebas/loadCSV.dart';
import 'package:prefacero_app/theme/style.dart';
import 'package:prefacero_app/utils/db.dart';
import 'package:provider/provider.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:intl/intl.dart';

// Adapted from offical flutter gallery:
// https://github.com/flutter/flutter/blob/master/examples/flutter_gallery/lib/demo/material/bottom_app_bar_demo.dart

class PedidosSliverDropBox extends StatefulWidget {
  const PedidosSliverDropBox({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PedidosSliverDropBoxState();
}

class _PedidosSliverDropBoxState extends State<PedidosSliverDropBox> {
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

  List<String> cliente = [
    "Casa Modular",
    "Fundacion Catalina Munoz",
    "AB Casa Lista",
    "Constructora Espinosa",
    "Cadecol",
    "Victor Beltran",
    "Practivivienda",
    "Alvaro Sanchez",
  ];

  String tipoProductoValue = "Perfiles Cal26";
  String clienteValue;

  ///Autocomplete modulo longitud
  String currentText = "";
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  List<String> modulos;
  List<String> medidaVentana;
  List<String> medidaPuerta;
  TextEditingController moduloController = TextEditingController();
  List<Producto> pedidoList = List();

  ///Cantidad Text Field
  TextEditingController cantidadController = TextEditingController();

  ///RefCliente Text Field
  TextEditingController refClienteController = TextEditingController();

  Producto selProd;
  double valorTotal;

  NumberFormat moneyFormat;

  @override
  void initState() {
    valorTotal = 0;
    moneyFormat = NumberFormat("\$ ###,###,###", 'en_US');
    modulos = ["18", "20", "22", "24", "26", "28", "30", "32","34"];
    medidaVentana = ["08-08", "04-08", "06-08"];
    medidaPuerta = ["16-08", "16-06", "18-08", "18-06"];
    super.initState();
  }

  /// Widget para seleccionar el producto (Tipo producto, Tipo Perfil, Modulo y Cantidad
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
          Expanded(
            child: SimpleAutoCompleteTextField(
              keyboardType: TextInputType.number,
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
          Expanded(
              child: TextField(
            keyboardType: TextInputType.number,
            controller: cantidadController,
            decoration: InputDecoration(labelText: 'Cantidad'),
            enabled: true,
            onSubmitted: (value) async {
              selProd = await DatabaseService().getProd("$tipoPerfilValue-${moduloController.text}");
              setState(() {
                print("Selected Prod ${selProd.nombre}");
                selProd.disp = int.parse(cantidadController.text);
                selProd != null ? pedido.listaProd.add(selProd) : print("Selprod null");
                //pedidoList.add(); //Producto(nombre: "$tipoPerfilValue-${moduloController.text}", disp: int.parse(cantidadController.text)));
                valorTotal = valorTotal + selProd.precio * selProd.disp;
                pedido.valorTotal = valorTotal;
                moduloController.text = "";
                cantidadController.text = "";
                pedido.notifyListeners();
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
    var pedido = Provider.of<Order>(context);
    var user = Provider.of<FirebaseUser>(context);
    pedido.uid = user.uid;
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
                  ///Cliente Field
                  Row(
                    children: <Widget>[
                      Text("Cliente:", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 10,),
                      DropdownButton<String>(
                        hint: Text("Cliente"),
                        value: clienteValue,
                        onChanged: (newValue) async {
                          ///Get datos del cliente from Firebase
                          pedido.cliente = await DatabaseService().getCliente(newValue);
                          setState(() {
                            clienteValue = newValue;
                          });
                          print("Cliente nit value ${pedido.cliente.nit}");
                        },
                        items: cliente.map((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  ///Referencia pedido Field
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "Referencia Pedido: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: TextField(
                          controller: refClienteController,
                          decoration: InputDecoration.collapsed(
                              hintText: 'Ej. Pedido 20/10/2019',
                              hintStyle: TextStyle(color: Colors.grey[800])),
                          enabled: true,
                          onSubmitted: (value) {
                            setState(() {
                              pedido.refPedido = value;
                              print("Value on submitted: $value");
                              pedido.notifyListeners();
                            });
                          },
                          onChanged: (val) {
                            setState(() {
                              pedido.refPedido = val;
                              print("Value on changed: $val");
                              pedido.notifyListeners();
                            });
                          },
                        ),
                      ),
                    ],
                  ),

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
                  //Si tipo de producto es Perfiles muestre el widget de seleccion de perfiles
                  (tipoProductoValue == "Perfiles Cal26" || tipoProductoValue == "Perfiles Cal24")
                      ? PerfilesWidget(tipoPerfil, modulos, pedido)
                      : Container(),
                ],
              ),
            ),
          ),
          // If the main content is a list, use SliverList instead.
          ///Titulos tabla
          SliverPadding(
            padding: const EdgeInsets.only(left: 20.0),
            sliver: SliverToBoxAdapter(
              child: Table(children: [
                TableRow(children: [
                  Text("Cantidad", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Producto", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Precio", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(""),
                ]),
              ]),
            ),
          ),
          ///Muestra productos seleccionados en forma de Tabla
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                  return Table(
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      border: TableBorder.all(
                          color: Theme.of(context).hintColor, width: 0.3),
                      children: [
                        _buildTitle(context, pedido.listaProd[index], pedido)
                      ]);
                },
                childCount: pedido.listaProd.length,
              ),
            ),
          ),
          ///Parte inferior Costo Total, boton aprobar, boton infoContable y vaciar carrito
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  Text("Costo Total: ${moneyFormat.format(pedido.valorTotal)}"),
                  RaisedButton(
                      child: Text(
                        "Aprobar",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        generateCsv(pedido, pedido.cliente)
                            .then((path) => sendMessage(path));
                        //var path = await generateCsv(pedido);
                        //await sendMessage(path);
                        //var map = await DatabaseService().getInfoContable();

                        DatabaseService().setPedido(pedido).then((_) {
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
                        pedido.valorTotal = valorTotal;
                        //var map = await DatabaseService().getInfoContable();
                        getInfoContPedido(pedido)?.then((val) {
                          print(
                              "Info Contable ${pedido.listaProd.first.infoContable.toString()}");
                        });
                      }),
                  InkWell(
                    child: Text(
                      "Vaciar Carrito",
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Theme.of(context).hintColor),
                    ),
                    onTap: () {
                      setState(() {
                        pedido.listaProd = List();
                        pedido.valorTotal = 0;
                        pedido.notifyListeners();
                      });
                    },
                  ),
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

  TableRow _buildTitle(BuildContext context, Producto prod, Order pedido) {
    return TableRow(children: [
      Center(child: Text("${prod.disp}")),
      Center(child: Text("${prod.nombre}")),
      Center(child: Text("${prod.precio}")),
      IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            setState(() {
              pedido.listaProd.removeAt(pedido.listaProd.indexOf(prod));
              valorTotal = valorTotal - prod.disp * prod.precio;
            });
          })
    ]

        /*
      Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("${prod.disp}"),
              Text("${prod.precio}"),
              Text("${prod.nombre}")
            ],
          ),
          ),
        ),
      */
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
      if (prod.infoContable != null) {
        print("Get info contable!!!: ${prod.infoContable}");
        return 1;
      } else
        return 0;
    });
  }

  Future<String> generateCsv(Order pedido, Cliente cliente) async {
    //cliente.reteFuente = 0.025;
    //print("Retefuente: ${cliente.reteFuente}");
    List<List<dynamic>> list = List();
    int i = 1;
    pedido.listaProd.forEach((prod) {
      print("infoContable ${prod.infoContable.toString()}");
      list.add([
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        cliente.codCiudad,
        i++,
        cliente.nit,
        prod.nombre,
        0.025 * 100,
        (0.025 * prod.disp * prod.precio).toStringAsFixed(2).replaceAll('.', ','), //it works
        prod.disp * prod.precio * 0.19,
        prod.linea,
        prod.grupo,
        prod.codigo,
        prod.disp,
        prod.disp * prod.precio,
        prod.disp,
      ]); //prod.nombre
    });
    print("List ${list.toString()}");
    List<List<dynamic>> csvData = [
      <String>[
        'TipoCompr',
        'Codigo',
        'NumCompr',
        'Ano del Documento',
        'Mes del Documento',
        'Dia del Documento',
        'Ano Entrega',
        'Mes Entrega',
        'Dia Entrega',
        'Codigo de la Ciudad',
        'Secuencia',
        'Centro de costo',
        'Nit',
        'Descripcion secuencia',
        'Porcentaje Descuento 3', //Porcentaje Retefuente
        'Valor Descuento 3', //Valor Retefuente
        'Porcentaje Cargo 3', //Porcentaje IVA,
        'Valor Cargo 3', //Valor IVA,
        'Linea',
        'Grupo',
        'Codigo',
        'Cantidad',
        'Valor de Secuencia',
        'Cantidad Conversion',
      ],
      ...list.map((prod) => [
            'V',
            '1',
            '1642',
            prod[0],
            prod[1],
            prod[2],
            prod[3],
            prod[4],
            prod[5],
            prod[6],
            prod[7],
            3,
            prod[8],
            prod[9],
            prod[10],
            prod[11],
            19,
            prod[12],
            prod[13],
            prod[14],
            prod[15],
            prod[16],
            prod[17],
            prod[18],
          ]),
    ];
    String csv = const ListToCsvConverter(fieldDelimiter: ';').convert(csvData);
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
