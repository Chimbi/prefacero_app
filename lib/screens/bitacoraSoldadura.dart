import 'package:flutter/material.dart';

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
    const ActorFilterEntry('Aaron Burr', 'AB'),
    const ActorFilterEntry('Alexander Hamilton', 'AH'),
    const ActorFilterEntry('Eliza Hamilton', 'EH'),
    const ActorFilterEntry('James Madison', 'JM'),
  ];
  List<String> _filters = <String>[];

  Iterable<Widget> get actorWidgets sync* {
    for (ActorFilterEntry actor in _cast) {
      yield Padding(
        padding: const EdgeInsets.all(4.0),
        child: FilterChip(
          //avatar: CircleAvatar(child: Text(actor.initials)),
          label: Text(actor.name),
          selected: _filters.contains(actor.name),
          onSelected: (bool value) {
            setState(() {
              if (value) {
                _filters[0]= actor.name;//_filters.add(actor.name);
              }
              /*
              else {
                _filters.removeWhere((String name) {
                  return name == actor.name;
                });
              }

               */
            });
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Wrap(
            children: actorWidgets.toList(),
          ),
          Text('Seleccionado: ${_filters.join(', ')}'),
        ],
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

