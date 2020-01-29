import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prefacero_app/model/produccion.dart';
import 'package:prefacero_app/utils/db.dart';

class IngresoRollo extends StatefulWidget {
  @override
  _IngresoRolloState createState() => _IngresoRolloState();
}

class _IngresoRolloState extends State<IngresoRollo> {
  String seleccionRollo;
  String tipoRolloSelected;
  TextEditingController remesaController = TextEditingController();
  TextEditingController kilosController = TextEditingController();
  TextEditingController espesorController = TextEditingController();
  final dateFormat = DateFormat("EEEE, MMMM d, yyyy 'at' h:mma");
  DateTime date;
  DetalleRollo rollo = DetalleRollo();

  final GlobalKey<FormState> formKey = GlobalKey();

  List<String> listaRollos = [
    "Rollo 0.43-1000 Z90 Gr33 Galv",
    "Rollo 0.70-1000 Z180 Galv.",
    "Rollo C.R. 0.70-1220"
  ];

  List<String> tipoRollo = [
    "Rollo",
    "Fleje"
  ];

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    remesaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ingreso Rollo"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: <Widget>[
              BasicDateField(rollo: rollo),
              //Text("Fecha Rollo en objeto ${rollo.fecha}"),
              DropdownButtonFormField<String>(
                validator: (val) => val == null ? "Campo obligatorio" : null,
                decoration: InputDecoration(labelText: "Tipo Rollo"),
                //hint: Text("Tipo Perfil"),
                value: seleccionRollo,
                onChanged: (newValue) {
                  setState(() {
                    seleccionRollo = newValue;
                    rollo.producto = newValue;
                  });
                  print("Tipo producto value $seleccionRollo");
                },
                items: listaRollos.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              DropdownButtonFormField<String>(
                validator: (val) => val == null ? "Campo obligatorio" : null,
                decoration: InputDecoration(labelText: "Tipo Perfil"),
                //hint: Text("Tipo Perfil"),
                value: tipoRolloSelected,
                onChanged: (newValue) {
                  setState(() {
                    tipoRolloSelected = newValue;
                    rollo.tipoRollo = newValue;
                  });
                  print("Tipo producto value $seleccionRollo");
                },
                items: tipoRollo.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              TextFormField(
                controller: espesorController,
                decoration: InputDecoration(labelText: 'Espesor mm'),
                enabled: true,
                onChanged: (value) =>  rollo.espesor = double.parse(value),
                validator: (val) => val == "" ? "Campo obligatorio" : null,
              ),
              TextFormField(
                controller: remesaController,
                decoration: InputDecoration(labelText: 'Remesa'),
                enabled: true,
                onChanged: (value) =>  rollo.remesa = value,
                validator: (val) => val == "" ? "Campo obligatorio" : null,
              ),
              TextFormField(
                controller: kilosController,
                decoration: InputDecoration(labelText: 'Kilos'),
                enabled: true,
                onChanged: (value) => rollo.kilos = double.parse(value),
                validator: (val) => val == "" ? "Campo obligatorio" : null,
              ),
              Center(
                child: RaisedButton(
                  onPressed: handleSubmit,
                  child: Text("Enviar",style: TextStyle(color: Colors.white),),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  handleSubmit() {
    final FormState form = formKey.currentState;
    if (form != null && form.validate()) {
      debugPrint("Form validated");
      setState(() {
        form.save();
        //form.reset();
        DatabaseService().setRollo(rollo).then((_) {
          Navigator.of(context).pop();
        });
      });
    }
  }
}

/*
final FormState form = formKey.currentState;
    if (form.validate()) {
      debugPrint("Form validated");
      setState(() {
        form.save();
        form.reset();
 */

class BasicDateField extends StatefulWidget {
  DetalleRollo rollo;

  BasicDateField({Key key, this.rollo}) : super(key: key);

  @override
  _BasicDateFieldState createState() => _BasicDateFieldState();
}

class _BasicDateFieldState extends State<BasicDateField> {
  final format = DateFormat("yyyy-MM-dd");
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      DateTimeField(
        validator: (date) => date == null ? 'Fecha invalida' : null,
        onChanged: (value){
          setState((){
            widget.rollo.fecha = value;
            print("Fecha $value");
          });
        },
        decoration: InputDecoration(labelText: "Fecha"),
        format: format,
        onShowPicker: (context, currentValue) {
          return showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100));
        },
      ),
    ]);
  }
}
