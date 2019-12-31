import 'package:flutter/material.dart';
import 'corteBloc.dart';


class NewProvider extends InheritedWidget {

  final bloc = CorteBloc();

  NewProvider({Key key, Widget child}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static CorteBloc of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NewProvider>().bloc;
  }
}