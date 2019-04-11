import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/producto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'dart:core';
import '../model/transaccion.dart';

class Journal extends StatefulWidget {

  @override
  _JournalState createState() => _JournalState();
}

class _JournalState extends State<Journal> {
  List<JournalTrans> entryList = List();
  JournalEntry journal;
  JournalTrans entry;
  JournalTrans results;
  final FirebaseDatabase database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey();
  DatabaseReference journalRef;
  DatabaseReference entryRef;
  DatabaseReference rootRef;
  DatabaseReference newEntryRef;
  DatabaseReference populate;


  List<String> _colors = <String>[
    '',
    'red',
    'green',
    'black',
    'purple',
    'orange'
  ];
  String _color = '';

  @override
  void initState() {
    print("begin init");
    journal = JournalEntry.init();
    entry = JournalTrans();
    journalRef = database.reference().child("journal");
    rootRef = database.reference();
    journalRef.onChildAdded.listen(_onAdded);

    //var value = prueba.orderByChild("value").once().then('value',(a)=>debugPrint("${a.value['cant']}"));
    //dataRef.onChildAdded.listen(_onAdded);
    //dataRef.onChildChanged.listen(_onEntryChanged);
    print("last init");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Form(
        key: formKey,
        autovalidate: true,
        child: ListView(
          children: <Widget>[
            ListTile(
              title: TextFormField(
                decoration: InputDecoration(
                    labelText: "Concepto registro",
                    hintText: "Compra lamina Proveedor X"),
                initialValue: "",
                onSaved: (val) => journal.hint = val,
                validator: (val) => val == "" ? val : null,
              ),
            ),
            ListTile(
              title: TextFormField(
                decoration: InputDecoration(
                    labelText: "Nit tercero sin digito de verificación",
                    hintText: "860345432"),
                keyboardType: TextInputType.number,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                initialValue: "",
                onSaved: (val) => journal.nit = int.parse(val),
                validator: (val) => val == "" ? val : null,
              ),
            ),
            ListTile(
              title: TextFormField(
                decoration: InputDecoration(
                    labelText: "Numero de factura del proveedor",
                    hintText: "Ej. AB234532"),
                initialValue: "",
                onSaved: (val) => journal.provInvoiceNum = val,
                validator: (val) => val == "" ? val : null,
              ),
            ),
            ListTile(
              title: TextFormField(
                decoration: InputDecoration(
                    labelText: "Numero de documento", hintText: "674"),
                initialValue: "674",
                //onEditingComplete: ,
                onSaved: (val) => journal.numDoc = int.parse(val),
                validator: (val) => val == "" ? val : null,
              ),
            ),
            ListTile(
              title: FormField<String>(
                builder: (FormFieldState state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      icon: const Icon(Icons.color_lens),
                      labelText: 'Color',
                    ),
                    isEmpty: _color == '',
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _color,
                        isDense: true,
                        onChanged: (String newValue) {
                          setState(() {
                            journal.hint = newValue;
                            _color = newValue;
                            state.didChange(newValue);
                          });
                        },
                        items: _colors.map((valor) {
                          return DropdownMenuItem<String>(
                            value: valor,
                            child: Text(valor),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                    color: Colors.deepOrange,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EntryScreen(entryList: entryList)));
                    },
                    child: Text(
                      "Add entry",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )),
                FlatButton(
                    color: Colors.deepOrange,
                    onPressed: () {
                      setState(() {
                        entryList.length > 0 ? journal.entry = entryList : _showDialog();
                        handelSubmit();

                      });
                    },
                    child: Text(
                      "Guardar",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )),
              ],
            ),
            //Text("${journal.entry[0].description}"),
            //Text(entryList.length == 0 ? "" : "${entryList[0].description}"),
            ListView.builder(
              shrinkWrap: true,
              itemCount: entryList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text("${entryList[index].description}"),
                    subtitle: Text("${entryList[index].itemValue}"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  _onAdded(Event event) {
    setState(() {
      print("On entry added");
      journal.fromSnapshot(event.snapshot);
      //entryList.add(entry);
    });
  }

  void _showDialog(){
    showDialog(context: context,
    builder: (BuildContext context){
      return AlertDialog(
        title: Text("Error") ,
        content: Text("Debe incluir como minimo una transacción"),
        actions: <Widget>[
          FlatButton(onPressed: ()=>Navigator.of(context).pop(), child: Text("Cerrar"))
        ],
      );
    });

  }

  /*
  _onEntryChanged(Event event) {
    //Objeto "entry" en la lista tal que su clave coincide con la
    //clave del evento que la llama
    Producto oldEntry = listaProd.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    // Una vez identificado la entrada en la lista se actualiza con
    //la informacion del evento
    setState(() {
      listaProd[listaProd.indexOf(oldEntry)] =
          Producto.fromSnapshot(event.snapshot);
    });
  }
*/
  handelSubmit() {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();
      form.reset();
      journalRef.child("${journal.numDoc}").set(journal.toJson());

      for (int i=0; i<entryList.length;i++){
        debugPrint("Se esta llenando la entrada");
        journalRef.child("${journal.numDoc}").child('entry').child('$i').set(entryList[i].toJson());
      }
      entryList = List();

      //save for m to the database
      //dataRef.child(producto.nombre).set(producto.toJson());
    }
  }
}


class EntryScreen extends StatelessWidget {
  final List<JournalTrans> entryList;

  static final GlobalKey<FormState> formKey = GlobalKey();
  final JournalTrans transEntry = JournalTrans();

  EntryScreen({Key key, @required this.entryList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        //top: true,
        //bottom: true,
        appBar: AppBar(
          title: Text("Asiento contable"),
        ),
        body: Form(
            key: formKey,
            autovalidate: true,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Descripcion",
                      hintText: "Descripcion del registro"),
                  initialValue: "",
                  onSaved: (val) => transEntry.description = val,
                  validator: (val) => val == "" ? val : null,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Codigo Grupo del producto",
                      hintText: "Ej. 1  (Materia Prima)"),
                  initialValue: "",
                  onSaved: (val) => transEntry.prodGroup = int.parse(val),
                  validator: (val) => val == "" ? val : null,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Codigo linea de producto",
                      hintText: "Ej. 7 (Lámina)"),
                  initialValue: "",
                  onSaved: (val) => transEntry.prodLine = int.parse(val),
                  validator: (val) => val == "" ? val : null,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Codigo de producto",
                      hintText: "Ej. 5 (Lamina Rollo 0.43)"),
                  initialValue: "",
                  onSaved: (val) => transEntry.prodCode = int.parse(val),
                  validator: (val) => val == "" ? val : null,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Centro de Costo", hintText: "3"),
                  initialValue: "",
                  onSaved: (val) => transEntry.tagCode = int.parse(val),
                  validator: (val) => val == "" ? val : null,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Precio unitario", hintText: "674"),
                  initialValue: "",
                  onSaved: (val) => transEntry.unitaryPrice = double.parse(val),
                  validator: (val) => val == "" ? val : null,
                ),
                TextFormField(
                  decoration:
                      InputDecoration(labelText: "Cantidad", hintText: "200"),
                  initialValue: "",
                  onSaved: (val) => transEntry.cant = int.parse(val),
                  validator: (val) => val == "" ? val : null,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Valor total item", hintText: "13200450"),
                  initialValue: "",
                  onSaved: (val) => transEntry.itemValue = double.parse(val),
                  validator: (val) => val == "" ? val : null,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Numero de cuenta", hintText: "1405050000"),
                  initialValue: "",
                  onSaved: (val) => transEntry.jAccountCode = int.parse(val),
                  validator: (val) => val == "" ? val : null,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Debito/Credito", hintText: "D ó C"),
                  initialValue: "",
                  onSaved: (val) => transEntry.transNature = val,
                  validator: (val) => val == "" ? val : null,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Tipo de registro",
                      hintText: "main, aux, tax o contrapartida"),
                  initialValue: "",
                  onSaved: (val) => transEntry.regType = val,
                  validator: (val) => val == "" ? val : null,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Tipo registro contable",
                      hintText: "inventario,impuesto,documentoCruce"),
                  initialValue: "",
                  onSaved: (val) => transEntry.accType = val,
                  validator: (val) => val == "" ? val : null,
                ),
                FlatButton(
                    color: Colors.deepOrange,
                    onPressed: () {
                      final FormState form = formKey.currentState;
                      if (form.validate()) {
                        form.save();
                        form.reset();
                        //save for m to the database
                        //dataRef.child(producto.nombre).set(producto.toJson());
                        entryList.add(transEntry);
                        Navigator.of(context).pop();
                        //Navigator.pop(context,MaterialPageRoute(builder: (context)=>Journal(entryList)));
                        debugPrint(
                            "La lista contiene esto: ${entryList[0].description}");
                      }
                    },
                    child: Text(
                      "Add entry",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )),
              ],
            )),
      ),
    );
  }
}
