import 'package:flutter/material.dart';
import 'package:prefacero_app/model/produccion.dart';
import 'package:prefacero_app/screens/ordenProduccionSliverDropbox.dart';
import 'package:prefacero_app/utils/db.dart';


class SelectRollo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seleccion Rollo"),
      ),
      body: ListView(
        children: <Widget>[
          Text("Los rollos disponibles son los siguientes:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
          SizedBox(height: 30,),
          FutureBuilder(
            future: DatabaseService().getListaRollos(),
            builder: (context, snap){
              if(snap.hasData) {
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snap.data.length,
                    itemBuilder: (context, index){
                  return Card(
                    child: GestureDetector(
                      onTap: () async {
                        //TODO actualizar ProduccionSliverDropBox para pasar el rollo seleccionado con el indice de la lista
                        //o pasar el rollo al Stream para actualizarlo
                        var consecutivoOrden = await DatabaseService().getConsecutivoOrden();
                        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ProduccionSliverDropBox(rollo: snap.data[index], consecutivo: consecutivoOrden)));
                      },
                      child: ListTile(
                        title: Column(
                          children: <Widget>[
                            Text("${snap.data[index].producto}", style: TextStyle(fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text("Remesa: ${snap.data[index].remesa}"),
                                Text("${snap.data[index].kilos} Kgs"),
                              ],
                            ),
                          ],
                        ),
                        subtitle: Center(child: Text("Disponible: ${snap.data[index].disponible}")),
                      ),
                    ),
                  );
                });
              } else {
                return Center(child: CircularProgressIndicator());
              }
              },
          )
        ],
      )
    );
  }
}
