import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/auxCont.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'dart:core';
import '../model/transaccion.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/database_helper.dart';

class AuxCont extends StatefulWidget {
  @override
  _AuxContState createState() => _AuxContState();
}

class _AuxContState extends State<AuxCont>{
  final TextEditingController _typeAheadController = TextEditingController();
  List<JournalTrans> entryList = List();
  List<Auxiliar> auxList = List(); //Crea la lista de info Auxiliar experto
  List<List<Auxiliar>> multiProd = List();
  List<List<dynamic>> csvList = List();
  JournalEntry journal;
  Auxiliar auxEntry;
  JournalTrans entry;
  JournalTrans results;
  final FirebaseDatabase database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey();
  DatabaseReference journalRef;
  DatabaseReference auxRef;
  DatabaseReference auxRef1;
  DatabaseReference prodRef;
  DatabaseReference entryRef;
  DatabaseReference rootRef;
  DatabaseReference newEntryRef;
  DatabaseReference dataRef;
  var _cant;
  var _val;
  var _itemVal;
  var lastKey;
  var db = DatabaseHelper();


  List<String> _nits = [""];
  String _nit = '';
  List<String> _prods = [""];
  String _prod = '';

  @override
  void initState() {
    //Create an Auxiliar Object
    auxEntry = Auxiliar();

    //Create and initialize a Journal Object. Init numDoc, tipo y cod Compr and SumZero = false
    journal = JournalEntry.init();

    //Create a Journal Transaction
    entry = JournalTrans();

    //Firebase reference for auxCont
    auxRef = database.reference().child("auxCont");

    //Firebase reference for journal
    journalRef = database.reference().child("journal");

    //Root ref
    rootRef = database.reference();

    //Initialize the list of nits from Firebase /auxCont/keys
    auxRef.onChildAdded.listen(_onAdded);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Solucion temporal si el numero es mayor puede dejar de funcionar
    double c_width = MediaQuery.of(context).size.width * 0.7;
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
                    labelText: "Numero de Comprobante",
                    hintText: "Ej. 674",
                    icon: Icon(Icons.info)),
                initialValue: "",
                onSaved: (val) => journal.numDoc = int.parse(val),
                validator: (val) => val == "" ? val : null,
              ),
            ),
            //Nit
            ListTile(
              title: FormField<String>(
                builder: (FormFieldState state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      icon: const Icon(Icons.person),
                      labelText: 'Nit tercero',
                    ),
                    isEmpty: _nit == '',
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _nit,
                        isDense: true,
                        onChanged: (String newValue) {
                          setState(() {
                            //For multi invoice should not initialize when nit changes
                            journal = JournalEntry.init();
                            debugPrint("SumZero in nit: ${journal.sumZero}");
                            journal.nit = int.parse(newValue);
                            _nit = newValue;
                            state.didChange(newValue);
                            auxRef1 =
                                auxRef.reference().child("${journal.nit}");
                            //En multifactura no puede limpiar el registro
                            auxList.clear(); //limpia el registro si se cambia el nit
                            //Limpia la lista de productos cuando el nit cambia
                            _prods = [""];
                            auxRef1.onChildAdded.listen(_onNitAdded);
                            if (_prod != "") {
                              setState(() {
                                //Cleans the product when the nit is changed
                                _prod = '';
                              });
                            }
                          });
                        },
                        items: _nits.map((valor) {
                          return DropdownMenuItem<String>(
                            value: valor,
                            child:
                                Container(width: c_width, child: Text(valor)),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
            //Producto - guarda var _prod
            ListTile(
              title: FormField<String>(
                builder: (FormFieldState state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      icon: const Icon(Icons.add),
                      labelText: 'Producto',
                    ),
                    isEmpty: _prod == '',
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _prod,
                        isDense: true,
                        onChanged: (String newValue) {
                          setState(() {
                            _prod = newValue;
                            state.didChange(newValue);
                          });
                        },
                        items: _prods.map((valor) {
                          return DropdownMenuItem<String>(
                            value: valor,
                            child:
                                Container(width: c_width, child: Text(valor)),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
            ListTile(
              title: TextFormField(
                decoration: InputDecoration(
                    labelText: "Valor",
                    hintText: "Ej:2300",
                    icon: Icon(Icons.attach_money)),
                initialValue: "",
                onSaved: (val) => _val = double.parse(val),
                validator: (val) => val == "" ? val : null,
              ),
            ),
            ListTile(
              title: TextFormField(
                decoration: InputDecoration(
                    labelText: "Cantidad",
                    hintText: "Ej. 4",
                    icon: Icon(Icons.apps)),
                initialValue: "",
                onSaved: (val) => _cant = int.parse(val),
                validator: (val) => val == "" ? val : null,
              ),
            ),
            //onEditingComplete: ,
            //journal.numDoc = int.parse(val),
//-----------------------------------------------------------------------

            Padding(padding: EdgeInsets.only(top: 10.0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                    color: Colors.deepOrange,
                    onPressed: () {
                      //Consulta el auxiliar por informacion
                      //Llena  auxList
                      GetAux();
                      journal.hint = _prod;
                      setState(() {
                        //validate credits and debits sum zero
                        transValidator(auxList);
                      });
                    },
                    //_GetEntry(prod: _prod,valor: _val, cantidad: _cant, entryList: entryList),
                    child: Text(
                      "Validar",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )),
                FlatButton(
                    color: Colors.deepOrange,
                    onPressed: () {
                      setState(() {
                        auxList.length > 0 && journal.sumZero == true
                               ? handelSubmit()
                            : _showDialog();
                      });
                    },
                    child: Text(
                      "Guardar",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )),
              ],
            ),
            //Text(entryList.length == 0 ? "" : "${entryList[0].description}"),
            Center(
                child: transValidator(auxList) == true
                    ? Text("Comprobante cuadrado")
                    : Text("")),
            ExpansionTile(
              title: Text("$_prod"),
              leading: Text("$_val"),
              children: <Widget>[
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: auxList.length,
                  itemBuilder: (context, index) {
                    return ExpansionTile(
                      title: ListTile(
                        leading: Text("${auxList[index].transNature}"),
                        title: Text("${auxList[index].description}"),
                      ),
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text("${auxList[index].jaccount_code}"),
                            Text("${auxList[index].lastValue}"),
                          ],
                        )
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _onAdded(Event event) {
    setState(() {
      _nits.add(event.snapshot.key);
      print("Add ${event.snapshot.key}");
    });
  }

  _onNitAdded(Event event) {
    setState(() {
      //populate products for the selected nit
      _prods.add(event.snapshot.key);
      print("Add ${event.snapshot.key}");
      //_hints.add(Auxiliar.fromSnapshot(event.snapshot));
      //entryList.add(entry);
    });
  }

  _onAuxAdded(Event event){

    //var res = await db.saveAuxEntry(Auxiliar.fromSnapshot(event.snapshot, _itemVal));

    setState((){
      //Este evento trae la informacion de cada auxiliar con ella
      //crear de una vez la lista de registros de diario

      auxList.add(Auxiliar.fromSnapshot(event.snapshot, _itemVal));
      //Check out if the use is correct
      ;
    });
  }

  void _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Comprobante descuadrado"),
            content: Text("Debitos y créditos deben sumar cero"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cerrar"))
            ],
          );
        });
  }

  handelSubmit() {
    debugPrint("La longitud de aux list es: ${auxList.length}");
    final FormState form = formKey.currentState;
    if (form.validate()) {
      debugPrint("Form validated");
      form.save();
      form.reset();

      debugPrint("numDoc de journal es ${journal.numDoc}");
      String newKey = journalRef.push().key;
      journalRef.child(newKey).set(journal.toJson());
      debugPrint("last key es: $newKey");
      //journalRef.child('entry').orderByChild('accType').equalTo('docCruce');

      entryList = auxList.map((aux) {
        return JournalTrans(
            description: aux.description,
            unitaryPrice: _val,
            cant: _cant,
            itemValue: aux.lastValue,
            tagCode: aux.tagCode,
            jAccountCode: aux.jaccount_code,
            transNature: aux.transNature,
            accType: aux.accType,
            regType: aux.regType,
            accountName: aux.description);
      }).toList();

      journal.entry = entryList;
      debugPrint("Longitud de entry list: ${entryList.length}");

      for (int i = 0; i < entryList.length; i++) {
        journalRef
            .child("${newKey}")
            .child('entry')
            .child('$i')
            .set(entryList[i].toJson());
      }
    }
    auxList.clear();
    _nit = "";
    _prod = "";

    createCSV() {
      for (int i = 0; i < auxList.length; i++) {
        csvList[i][0] = journal.codigoCompr;
        csvList[i][1] = journal.hint;
        csvList[i][2] = journal.hint;
      }
    }
  }

  GetAux() {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      debugPrint("Form validated in GetAux");
      form.save();
      _itemVal = _val * _cant;
      //auxList.clear(); //On multiproducto no se debe limpiar
      auxRef
          .child("${journal.nit}/$_prod/entry")
          .onChildAdded
          .listen(_onAuxAdded);
    }
  }

  bool transValidator(List<Auxiliar> auxList) {
    //Problem if the aux list is null the validator does not work
    if (auxList.length != 0) {
      double acum = 0.0;
      double element;
      for (int i = 0; i < auxList.length; i++) {
        element = auxList[i].lastValue;
        if (auxList[i].transNature == "C") {
          element = auxList[i].lastValue * (-1);
          debugPrint("Credito $element en posicion $i");
        } else {
          element = auxList[i].lastValue;
          debugPrint("Debito $element en posicion $i");
        }
        acum = acum + element;
        debugPrint("valor de acum $acum");
      }
      debugPrint("El valor de acum es: $acum");
      if (acum == 0) {
        debugPrint("transaccion de suma cero");
        journal.sumZero = true;
        return true;
      } else {
        debugPrint("$acum");
        debugPrint("transaccion descuadrada");
        return false;
      }
    } else {
      debugPrint("No es posible validar el documento");
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
