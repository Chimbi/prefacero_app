/*
import 'package:flutter/material.dart';
import '../model/producto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'dart:core';

class ProductManager extends StatefulWidget {
  @override
  _ProductManagerState createState() => _ProductManagerState();
}

class _ProductManagerState extends State<ProductManager> {
  TextEditingController dispController = TextEditingController();
  List<Producto> listaProd = List();
  Producto producto;
  final FirebaseDatabase database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey();
  DatabaseReference dataRef;

  @override
  void initState() {
    print("begin init");
    producto = Producto();
    dataRef = database.reference().child("inventario");
    dataRef.onChildAdded.listen(_onAdded);
    dataRef.onChildChanged.listen(_onEntryChanged);
    print("last init");

    super.initState();
  }

  /*
  @override
  void initState() {
    super.initState();



  }
*/
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(
          flex: 0,
          child: Center(
            child: Form(
                key: formKey,
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    ListTile(
                      title: TextFormField(
                        decoration: InputDecoration(
                            labelText: "Nombre de producto", hintText: "H-22"),
                        initialValue: "",
                        onSaved: (val) => producto.nombre = val,
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    ListTile(
                      title: TextFormField(
                        decoration: InputDecoration(
                            labelText: "Precio de venta", hintText: "22500"),
                        initialValue: "",
                        onSaved: (val) => producto.precio = int.parse(val),
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    ListTile(
                      title: TextFormField(
                        decoration: InputDecoration(
                            labelText: "Cantidad disponible",
                            hintText: "Ej. 4"),
                        initialValue: "",
                        onSaved: (val) => producto.disp = int.parse(val),
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    ListTile(
                      title: TextFormField(
                          decoration: InputDecoration(
                              labelText: "Tiempo de fabricacion en días",
                              hintText: "Ej. 2"),
                          initialValue: "",
                          onSaved: (val) => producto.tiempoFab = int.parse(val),
                          validator: (val) => val == "" ? val : null),
                    ),
                    ListTile(
                      title: TextFormField(
                        decoration: InputDecoration(
                            labelText: "Costo de fabricación",
                            hintText: "Ej.17500"),
                        initialValue: "",
                        onSaved: (val) => producto.costo = int.parse(val),
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    FlatButton(
                        color: Colors.deepOrange,
                        onPressed: () => handelSubmit(),
                        child: Text(
                          "Guardar",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                  ],
                )),
          ),
        ),
        Flexible(
          child: FirebaseAnimatedList(
              //shrinkWrap: true,
              query: dataRef,
              itemBuilder: (_, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                return ExpansionTile(
                  title: ListTile(
                    onLongPress: () {
                      _updateItem(listaProd[index].key, index);
                    },
                    leading: CircleAvatar(
                      child: Text(
                        "${listaProd[index].disp}",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: listaProd[index].disp > 0
                          ? Colors.lightGreen
                          : Colors.red,
                    ),
                    title: Text(listaProd[index].nombre),
                    subtitle: Text("${listaProd[index].precio}"),
                  ),
                  children: <Widget>[
                    Text(
                        "Tiempo: ${listaProd[index].tiempoFab} - Costo: ${listaProd[index].costo}"),
                  ],
                );
              }),
        ),
      ],
    );
  }

  _onAdded(Event event) {
    setState(() {
      print("On entry added");
      listaProd.add(Producto.fromSnapshot(event.snapshot));
    });
  }

  _onEntryChanged(Event event){
    //Objeto "entry" en la lista tal que su clave coincide con la
    //clave del evento que la llama
    Producto oldEntry = listaProd.singleWhere((entry){
      return entry.key == event.snapshot.key;
    });
    // Una vez identificado la entrada en la lista se actualiza con
    //la informacion del evento
    setState((){
      listaProd[listaProd.indexOf(oldEntry)] = Producto.fromSnapshot(event.snapshot);
    });
  }

  handelSubmit() {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();
      form.reset();
      //save for m to the database
      dataRef.child(producto.nombre).set(producto.toJson());
    }
  }

  _updateItem(String key, int index) {
    var alert = AlertDialog(
      title: Text("Actualizar cantidad de ${listaProd[index].key}:"),
      content: Row(
        children: <Widget>[
          Text(""),
          Expanded(
            child: TextField(
                controller: dispController,
              ),
            )
        ],
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () {
              setState(() {
                var newdisp = int.parse(dispController.text);
                dataRef.child(key).update({"disp": newdisp}); //update disp
                listaProd[index].disp = newdisp;
              });
              dispController.clear();
              Navigator.pop(context);
            },
            child: Text("Guardar")),
        FlatButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
      ],
    );
    showDialog(context: context, builder: (BuildContext context) => alert);
  }
}
*/