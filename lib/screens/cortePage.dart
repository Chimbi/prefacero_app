import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:prefacero_app/bloc/Provider.dart';
import 'package:prefacero_app/bloc/corteBloc.dart';
import 'package:prefacero_app/model/produccion.dart';
import 'package:prefacero_app/utils/db.dart';

class CortePage extends StatefulWidget {
  String clave;

  CortePage(this.clave);

  @override
  _CortePageState createState() => _CortePageState();
}

class _CortePageState extends State<CortePage> {
  String tipoProceso = "Corte";

  ///Tipo producto DropBox variables
  List<String> listaProceso = [
    "Corte",
    "Despunte",
  ];

  @override
  Widget build(BuildContext context) {
    var bloc = NewProvider.of(context);
    return Semantics(
      excludeSemantics: true,
      child: Scaffold(
          body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text("Prueba"),
            pinned: true,
            iconTheme: new IconThemeData(color: Theme.of(context).primaryColor),
            elevation: 20.0,
            backgroundColor: Colors.white,
            expandedHeight: 120.0,
              flexibleSpace: FlexibleSpaceBar(
              title: DropdownButton<String>(
                hint: Text("Tipo Perfil"),
                value: tipoProceso,
                onChanged: (newValue) {
                  setState(() {
                    tipoProceso = newValue;
                  });
                  print("Tipo proceso value $tipoProceso");
                },
                items: listaProceso.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              /*
              background: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.scaleDown,
                ),
              ),
                */
            ),
          ),

          StreamBuilder(
            stream: bloc.ordenes,
            builder: (context, snapshot) {
              if(snapshot.hasData){
                return SliverList(
                  delegate: SliverChildListDelegate(
                      snapshot.data[widget.clave].listProdPerfiles
                          .map<Widget>((prod) {
                        return Card(
                          child: ListTile(
                              title: Wrap(
                                children: <Widget>[
                                  Text("${prod.nombre}"),
                                  SizedBox(width: 5),
                                  tipoProceso == "Corte"
                                      ? Text("Terminadas: ${prod.terminadaCorte}")
                                      : Text(
                                      "Terminadas: ${prod.terminadaDespunte}")
                                ],
                              ),
                              subtitle: tipoProceso == "Corte"
                                  ? Text("${prod.textoCorte}")
                                  : Wrap(
                                children: <Widget>[
                                  Text("${prod.textoDespunte}"),
                                  Text("${prod.textoDespunte2}"),
                                ],
                              ),
                              onTap: () {
                                showModalBottomSheet(context: context, builder: (context){
                                  return ModalBottomSheet(mapOrdenes: snapshot.data, clave: widget.clave, bloc: bloc, detalleProd: prod, proceso: tipoProceso, start: DateTime.now());
                                });
                              }
                            //onTap: () => onPressed(prod, tipoProceso, snapshot.data[widget.clave], bloc), /*showBottomSheet(context: context, builder: (context){
                            //return Text("This is a sheet bottom");
                            //}),
                          ),
                        );
                      }).toList()
                  ),
                );
              }else{
                return SliverToBoxAdapter(
                  child: Text("No hay data"),
                );
              }
            },
          ),
        ],
      )),
    );
  }
}

class ModalBottomSheet extends StatefulWidget {
  Map<String, OrdenProduccion> mapOrdenes;
  String clave;
  String proceso;
  DetalleProdPerfil detalleProd;
  CorteBloc bloc;
  DateTime start;


  ModalBottomSheet({Key key, this.mapOrdenes, this.clave, this.bloc, this.proceso, this.detalleProd, this.start}) : super(key: key);

  _ModalBottomSheetState createState() => _ModalBottomSheetState();
}

class Prueba extends StatefulWidget {
  @override
  _PruebaState createState() => _PruebaState();
}

class _PruebaState extends State<Prueba> {
  TextEditingController pruebaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      child: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(labelText: "Ingrese un valor"),
            controller: pruebaController,
            onSubmitted: (value){
              pruebaController.text = value;
            },
          ),
          Text("Texto cambiando: ${pruebaController.text}")
        ],
      ),
    );
  }
}


class _ModalBottomSheetState extends State<ModalBottomSheet>
    with SingleTickerProviderStateMixin {
  var heightOfModalBottomSheet = 800.0;

  DateTime finishWork;
  TextEditingController cantidadController = TextEditingController();

  void showDialogSingleButton(
      BuildContext context, String title, String message, String buttonLabel) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(buttonLabel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Container(
      height: 400,
      child: ListView(
        children: <Widget>[
          SizedBox(height: 20),
          Center(
              child: Text("${widget.proceso}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18))),
          ListTile(
            title: Column(
              children: <Widget>[
                Text("Producto: ${widget.detalleProd.nombre}"),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "Instrucciones de corte",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                widget.proceso == "Cortea"
                    ? Text("${widget.detalleProd.textoCorte}")
                    : Wrap(
                  children: <Widget>[
                    Text("${widget.detalleProd.textoDespunte}"),
                    Text("${widget.detalleProd.textoDespunte2}"),
                  ],
                ),
                Text("Inicio: ${widget.start ?? ""}"),
                SizedBox(height: 10,),
                TextField(
                  keyboardType: TextInputType.phone,
                  onSubmitted: (value) {
                    setState(() {
                      cantidadController.text = value;
                    });
                  },
                  controller: cantidadController,
                  decoration: InputDecoration(
                      labelText: "Cantidad",
                      border: OutlineInputBorder()),
                ),
                RaisedButton(
                    child: Text("Fin",
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      if (cantidadController.text != "") {
                        setState(() {
                          finishWork = DateTime.now();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // return object of type Dialog
                              return AlertDialog(
                                title: Text("Fin de proceso"),
                                content: Text(
                                    "Usted terminó ${cantidadController.text} es correcto?"),
                                actions: <Widget>[
                                  // usually buttons at the bottom of the dialog
                                  FlatButton(
                                    child: Text("Corregir"),
                                    onPressed: () {
                                      cantidadController.text = "";
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  RaisedButton(
                                    child: Text("Correcto"),
                                    onPressed: () {
                                      var indice = widget.mapOrdenes[widget.clave].listProdPerfiles.indexOf(widget.detalleProd);
                                      var cantidadProceso = int.parse(cantidadController.text);
                                      Map<String, dynamic> map = {
                                        "key": widget.clave,
                                        "index": indice,
                                        "proceso": widget.proceso,
                                        "cantidad": cantidadProceso
                                      };
                                      cantidadController.text = "";
                                      widget.bloc.ordenUpdate.add(map);
                                      Navigator.of(context).popUntil(
                                          ModalRoute.withName(
                                              '/corteOrden'));
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        });
                        print(
                            "Termine ${cantidadController.text} a las ${finishWork?.toString()}");
                      } else
                        print("Favor ingresar cantidad");
                    }),
              ],
            ),
            subtitle: cantidadController.text == ""
                ? Center(
                child: Text(
                    "Favor diligenciar cantidad para continuar",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold)))
                : Text("Tiempo ${finishWork?.toString()}"),
          ),
        ],
      ),
    );
  }
}
