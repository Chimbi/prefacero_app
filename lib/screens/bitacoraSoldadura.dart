import 'package:flutter/material.dart';
import 'package:prefacero_app/model/produccion.dart';
import 'package:prefacero_app/theme/style.dart';

class ActorFilterEntry {
  const ActorFilterEntry(this.name, this.initials);
  final String name;
  final String initials;
}

class CastFilter extends StatefulWidget {
  @override
  State createState() => CastFilterState();
}

class CastFilterState extends State<CastFilter> {
  final List<ActorFilterEntry> _cast = <ActorFilterEntry>[
    const ActorFilterEntry('Borman Prieto', 'AB'),
    const ActorFilterEntry('Pablo Moncada', 'AH'),
    const ActorFilterEntry('Luis Algo', 'EH'),
    const ActorFilterEntry('Vicente Rico', 'JM'),
  ];
  List<String> _filters = <String>[];

  String procesoValue = null;

  List<String> tipoProceso = ["Corte Peinazo", "Armado puerta", "Soldadura Esqueleto Puerta"];

  List<RegBitacora> wipList = [];
  DateTime tiempoInicio;
  DateTime tiempoFin;

  List<String> responsables = [];

  Iterable<Widget> get actorWidgets sync* {
    for (ActorFilterEntry actor in _cast) {
      yield Padding(
        padding: const EdgeInsets.all(4.0),
        child: FilterChip(
          selectedColor: Colors.lightGreenAccent,
          //checkmarkColor: Colors.white,
          //avatar: CircleAvatar(child: Text(actor.initials)),
          label: Text(actor.name),
          selected: _filters.contains(actor.name),
          onSelected: (bool value) {
            setState(() {
              if (value) {
                _filters.add(actor.name);
              }
              else {
                _filters.removeWhere((String name) {
                  return name == actor.name;
                });
              }
            });
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem> items;
    items = tipoProceso.map((value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
    return Scaffold(
      body: CustomScrollView(
        //mainAxisAlignment: MainAxisAlignment.center,
        slivers: <Widget>[
          SliverAppBar(
            title: Text(
              "Bitacora Producción",
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
                  Wrap(children: actorWidgets.toList()),
                  Text(_filters.length != 0 ?'Seleccionado: ${_filters.join(', ')}':""),
                  SizedBox(height: 10,),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: Text("Seleccionar Proceso"),
                      value: procesoValue,
                      onChanged: (newValue) {
                        setState(() {
                          procesoValue = newValue;
                        });
                        print("Tipo perfil value $procesoValue");
                      },
                      items: items,
                    ),
                  ),
                  RaisedButton(child: Text("Inicio", style: TextStyle(color: Colors.white),),
                    onPressed: (){
                    setState(() {
                      responsables = List<String>.from(_filters);
                      wipList.add(RegBitacora(tiempoInicio: DateTime.now(), responsable: responsables));
                    });
                    /*
                    print("${wipList.map((reg){
                      return reg.responsable;
                    })}");
                     */
                  },)
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return Column(
                      children: [
                        _buildTitle(context, wipList[index], index)
                      ]);
                },
                childCount: wipList.length,
              ),
            ),
          )
        ],
      ),
    );
  }
  Widget _buildTitle(BuildContext context, RegBitacora prod, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 10,
          //color: Colors.grey[200],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15)),side: BorderSide(color: hintCol)),
          child: ListTile(
              title: Center(child: Text("${prod.responsable.join(', ')}")),
              subtitle: Center(child: Text("Inicio: ${prod.tiempoInicio.hour}:${prod.tiempoInicio.minute}")),
              /*
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  var index = wipList.indexOf(prod);
                  setState(() {
                    wipList.removeAt(index);
                  });
                })
               */
      )
      ),
    );
  }
}


class BitacoraSoldadura extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BitacoraSoldaduraState();
}

class _BitacoraSoldaduraState extends State<BitacoraSoldadura> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bitacora Soldadura"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
          Text("Usuario como seleccion en chulo"),
          Text("Proceso dropdown button"),
          Text("Inicio Boton"),
          Text("Cantidad TextField"),
          Text("Tiempo Fin en Ventana Popup"),
        ],),
      )
    );
  }

}

