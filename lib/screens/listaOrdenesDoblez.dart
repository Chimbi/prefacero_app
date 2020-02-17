
import 'package:flutter/material.dart';
import 'package:prefacero_app/bloc/Provider.dart';
import 'package:prefacero_app/bloc/corteBloc.dart';
import 'package:prefacero_app/model/produccion.dart';
import 'package:prefacero_app/screens/cortePage.dart';
import 'package:prefacero_app/utils/db.dart';
import 'package:provider/provider.dart';

import 'DoblezPage.dart';

///Pantalla que muestra la lista de ordenes de produccion
///
class AreaDoblez extends StatefulWidget {
  @override
  _AreaDoblezState createState() => _AreaDoblezState();
}

class _AreaDoblezState extends State<AreaDoblez> {

  Widget _buildItem(BuildContext context, OrdenProduccion data, CorteBloc bloc){

    return Card(
      child: ListTile(
        title: Text("No. Orden: ${data.numero}"),
        onTap: () async {
          Navigator.push<dynamic>(context, MaterialPageRoute<dynamic>(settings: RouteSettings(name: "/doblezOrden"), builder: (BuildContext context) => DoblezPage(data.key)),);
        }
      ),
     );
  }


  @override
  Widget build(BuildContext context) {
    final bloc = NewProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Area Corte"),
      ),
      body: StreamBuilder<Map<String,OrdenProduccion>>(
        initialData: Map<String,OrdenProduccion>(),
        stream: bloc.ordenes,
        builder: (context, snapshot){
          if(snapshot.hasData){
            return ListView(
                children: snapshot.data.entries.map((entry) => _buildItem(context,entry.value, bloc)).toList()
            );
          } else {
            print("No hay datos");
            return Text("Snap: ${snapshot.data.toString()}");
          }
        }
      )

      /*FutureBuilder(
        future: DatabaseService().getListaOrdenes(),
        builder: (context,snap){
          if(snap.hasData){
           return ListView.builder(
             itemCount: snap.data.length,
               itemBuilder:(context,index) => _buildItem(context, snap.data[index]));
          } else return Center(child: CircularProgressIndicator());
        },
      )
        */
    );
  }
}
