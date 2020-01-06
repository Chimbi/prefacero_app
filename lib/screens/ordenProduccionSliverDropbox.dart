import 'dart:async';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prefacero_app/bloc/Provider.dart';
import 'package:prefacero_app/model/order.dart';
import 'package:prefacero_app/model/produccion.dart';
import 'package:prefacero_app/model/producto.dart';
import 'package:prefacero_app/model/regContable.dart';
import 'package:prefacero_app/theme/style.dart';
import 'package:prefacero_app/utils/db.dart';
import 'package:provider/provider.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:intl/intl.dart';

// Adapted from offical flutter gallery:
// https://github.com/flutter/flutter/blob/master/examples/flutter_gallery/lib/demo/material/bottom_app_bar_demo.dart

class ProduccionSliverDropBox extends StatefulWidget {
  final DetalleRollo rollo;
  final int consecutivo;
  const ProduccionSliverDropBox({Key key, this.rollo, this.consecutivo}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProduccionSliverDropBoxState();
}

///Clase para crear una orden de produccion. En la orden debe quedar registrado el rollo seleccionado
///identificado por la remesa, la cantidad disponible después de la orden y el consumo de la orden.
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

  List<Producto> productList = List();

  List<Producto> adicProductList = List();


  ///Cantidad Text Field
  TextEditingController cantidadController = TextEditingController();

  Produccion selProd;
  int consecutivo;
  OrdenProduccion ordenProd = OrdenProduccion(listProdPerfiles: List());

  NumberFormat moneyFormat;

  double disponibleGlobal;


  @override
  void initState() {
    moneyFormat = NumberFormat("\$ ###,###,###", 'en_US');
    modulos = ["18", "20", "22", "24", "26", "28", "30"];
    medidaVentana = ["08-08", "04-08", "06-08"];
    medidaPuerta = ["16-08", "16-06", "18-08", "18-06"];
    disponibleGlobal = widget.rollo.disponible;
    super.initState();
  }

  /// Widget para seleccionar el producto (Tipo producto, Tipo Perfil, Modulo y Cantidad). Llenado listaProducción
  Widget PerfilesWidget(List<String> tipoProducto, List<String> suggestions) {
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

              //Busca la informacion de produccion del producto seleccionado
              selProd = await DatabaseService().getProduccion("$tipoPerfilValue-${moduloController.text}", int.parse(cantidadController.text), widget.rollo.tipoRollo);

              //Crea el objeto producto y le adjunta la informacion contable
              var producto = Producto(nombre: selProd.nombre, disp: selProd.cantidad);
              var listContProd = await DatabaseService().getInfoContable(producto);
              producto.infoContable = listContProd;
              print("Prueba ${producto.infoContable.toString()}");

              //Si el producto genera producto adicional y es tipo rollo crea el producto y le adjunta la informacion contable
              //Adiciona el producto a la lista de productos adicionales
              if(selProd.cantAdicional != 0 && widget.rollo.tipoRollo == "Rollo") {
                var productoAdic = Producto(nombre: selProd.prodAdicional, disp: selProd.cantAdicional * selProd.laminas);
                var listContProdAdic = await DatabaseService().getInfoContable(productoAdic);
                productoAdic.infoContable = listContProdAdic;
                setState(() {
                  adicProductList.add(productoAdic);
                });
              }
              var pesoLam;
              if(widget.rollo.tipoRollo == "Rollo"){
                pesoLam = selProd.laminas * selProd.kilosLamina;
                print("Laminas ${selProd.laminas}");
                print("Kilos por lamina ${selProd.kilosLamina}");
                print("Peso: $pesoLam");
                print("Desarollo: ${selProd.des}");
              } else {
                pesoLam = (7.85 * widget.rollo.espesor * selProd.longLamina)/selProd.cantLam * selProd.cantidad;
                print("Peso: $pesoLam");
                print("Desarollo: ${selProd.des}");
              }

              setState(() {
                //TODO Actualmente la informacion de produccion solo tiene los kilos por lamina en Rollo
                disponibleGlobal = disponibleGlobal - pesoLam;
                print("Disponible al agregar $disponibleGlobal");
                productList.add(producto);
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
    var bloc = NewProvider.of(context);
    List<List<RegContable>> listaCon = List();
    String path;

    return Scaffold(
      // SliverAppBar is declared in Scaffold.body, in slivers of a
      // CustomScrollView.
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text(
              "Orden Producción No: ${widget.consecutivo}",
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: new IconThemeData(color: Colors.white),
            elevation: 40.0,
            snap: false,
            floating: false,
            pinned: true,
            expandedHeight: 120.0,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(10),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: <Widget>[
                  Text("${widget.rollo.producto}"),
                  SizedBox(height: 2,),
                  Text("Remesa: ${widget.rollo.remesa}"),
                  Text("Disponible: ${disponibleGlobal.toStringAsFixed(2)} Kg"),
                ],
              ),
            ),
          ),
          ///Seleccion productos y campos
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 12.0),
            sliver: SliverToBoxAdapter(
              child: PerfilesWidget(tipoPerfil, modulos),
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
                        _buildTitle(context, productList[index], widget.rollo.tipoRollo)
                      ]);
                },
                childCount: productList.length,
              ),
            ),
          ),
          ///Titulos tabla
          adicProductList.length > 0 ? SliverPadding(
            padding: const EdgeInsets.only(left: 20.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Productos adicionales"),
                  Table(children: [
                    TableRow(children: [
                      Text("Cantidad",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Producto",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(""),
                    ]),
                  ]),
                ],
              ),
            ),
          ) : SliverToBoxAdapter(),
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
                        _buildTitle(context, adicProductList[index], widget.rollo.tipoRollo)
                      ]);
                },
                childCount: adicProductList.length,
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
                        if(disponibleGlobal<0){
                          showDialog<void>(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Error en el peso'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Text(
                                          'El consumo de kilos del rollo no puede superar la cantidad disponible'),
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
                        }else{
                          //El consumo del rollo es menor o igual que la cantidad disponible
                          DatabaseService().setOrdenProduccion(produccionList, user.uid, bloc, widget.consecutivo, widget.rollo, widget.rollo.kilos-disponibleGlobal).then((orden) async {
                            //Actualizar el consecutivo en la base de datos
                            DatabaseService().setConsecutivoOrden(widget.consecutivo);
                            //Crear csv
                            generateCsvProductos(List.from(productList)..addAll(adicProductList),widget.consecutivo);
                            //Dialogo informando que orden fue enviada con éxito
                            showDialog<void>(
                              context: context,
                              barrierDismissible: false, // user must tap button!
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Orden de producción enviada'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text(
                                            'La orden de producción ${widget.consecutivo} '
                                                'fue enviada con éxito'),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('Aceptar'),
                                      onPressed: () {
                                        Navigator.of(context).popUntil(ModalRoute.withName('/inicio'));
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          });
                        }
                      }),
                  RaisedButton(
                      child: Text(
                        "Create CSV",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        print("Pressed");
                        generateCsvProductos(List.from(productList)..addAll(adicProductList), widget.consecutivo);
                        //
                        //ordenProd.listProduccion = produccionList;
                        //var map = await DatabaseService().getInfoContable();
                        //getInfoContProduccion(produccionList);
                      }),
                  RaisedButton(
                      child: Text(
                        "Imprimir Path",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        print("Path $path");
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

  TableRow _buildTitle(BuildContext context, Producto prod, String tipoRollo) {
    return TableRow(children: [
      Center(child: Text("${prod.disp}")),
      Center(child: Text("${prod.nombre}")),
      IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            var pesoLam;
            var index = productList.indexOf(prod);
            if(tipoRollo == "Rollo"){
              pesoLam = produccionList[index].kilosLamina * produccionList[index].laminas;
            } else {
              pesoLam = (7.85 * widget.rollo.espesor * produccionList[index].longLamina)/produccionList[index].cantLam * produccionList[index].cantidad;
            }
            setState(() {
              disponibleGlobal = disponibleGlobal + pesoLam;
              print("Index $index");
              print("Product list length: ${productList.length}");
              productList.removeAt(index);
              produccionList.removeAt(index);
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


  Future<List<Produccion>> getInfoContProduccion(List<Produccion> listaProd) {
    listaProd.forEach((prod) async {
      print("Prod en getInfoCont ${prod.nombre}");
      prod.infoContable = List();
      var lista = await DatabaseService().getInfoContableByProduct(prod.nombre, prod.cantidad);
      prod.infoContable = lista;
    });
    return Future.value(listaProd); listaProd;
  }
  Future<void> generateCsvProductos(List<Producto> listProd, int consecutivo) async{
    List<List<dynamic>> list = List();
    int i = 1;
    listProd.forEach((prod){
      print("infoContable ${prod.infoContable.toString()}");
      prod.infoContable.forEach((c){
        print("Contable ${c.accountCode}");
        //TODO costo falta multiplicarlo por la cantidad
        list.add([c.accountCode,c.transNature, (c.costo).toString(), DateTime.now().year, DateTime.now().month, DateTime.now().day, i++, c.nombre,c.linea,c.grupo,c.codigo, (c.cantBase).toStringAsFixed(2).replaceAll('.', ',')]); //prod.nombre

      });
    });
    print("List ${list.toString()}");
    List<List<dynamic>> csvData = [
      <String>['TipoCompr', 'Codigo', 'NumCompr', 'Cuenta Cont','Naturaleza', 'Valor', 'Año', 'Mes', 'Dia', 'Secuencia', 'CCosto','SubCCosto',   'NIT',   'Descripcion','Linea','Grupo',  'Codigo', 'Cantidad', 'Bodega', 'TipoCruce', 'NumDocCruce', 'AñoVencCruce', 'MesVencCruce','DiaVencCruce','DescLarga', ],
      ...list.map((prod) => ['O','31',    consecutivo,    prod[0],        prod[1],   prod[2],prod[3],prod[4],prod[5],prod[6],       3,       0,    860353552,  prod[7],       prod[8], prod[9], prod[10], prod[11],      3,     "","","","","",""]),
    ];
    String csv = const ListToCsvConverter(fieldDelimiter: ';').convert(csvData);
    final String dir = (await getApplicationDocumentsDirectory()).path;

    final String path = '$dir/ordenProduccion.csv';
    //Create file
    final File file = File(path);
    //Save csv String
    await file.writeAsString(csv).then((_){
      sendMessage(path);
    });
  }

  Future<void> sendMessage(path) async {
    String username = 'increeceapp@gmail.com';
    String password = 'Afr21052';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..attachments = [FileAttachment(File(path))]
      ..from = Address(username, 'Prefacero App')
      ..recipients.add('comercial@prefacero.com.co')
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
    return path;
  }

}
