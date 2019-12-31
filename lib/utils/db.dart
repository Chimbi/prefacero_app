
import 'package:prefacero_app/bloc/corteBloc.dart';
import 'package:prefacero_app/model/order.dart';
import 'package:prefacero_app/model/produccion.dart';
import 'package:prefacero_app/model/regContable.dart';
import 'package:prefacero_app/model/user.dart';
import 'package:prefacero_app/utils/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prefacero_app/model/producto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class DatabaseService {

  final Firestore _db = Firestore.instance;
  final AuthService auth = AuthService();

  Future<Producto> getProd(String prod) async{
    var snap = await _db.collection('Producto').document('$prod').get();
    return Producto.fromMap(snap.data);
  }

  Future<DocumentReference> setProd(Map<String,dynamic> json) async{
    DocumentReference pedidoRef = Firestore.instance.collection('Producto').document("${json["nombre"]}");
    await pedidoRef.setData(json);
    return pedidoRef;
  }

  Future<Produccion> getProduccion(String prod, cantidad) async{
    Produccion infoProd;
    var snap = await _db.collection('Producto/$prod/Produccion').document('infoProduccion').get();
    infoProd = Produccion.fromMap(snap.data);
    infoProd.laminas = (cantidad/infoProd.cantLam).ceil();
    infoProd.cantidad =  infoProd.laminas * infoProd.cantLam;  //Cantidad de producto recalculado
    return infoProd;
  }

  Future<DocumentReference> setRegContable(Map<String,dynamic> json, String key, String producto) async{
    DocumentReference pedidoRef = Firestore.instance.collection('Producto/$producto/Contabilidad').document("Terminado");
    var jsonNuevo = {
      "entry" : {
        "$key" : json
      }
    };
    print("JsonNuevo: ${jsonNuevo.toString()}");
    await pedidoRef.setData(jsonNuevo, merge: true);
    return pedidoRef;
  }

  Future<DocumentReference> setInfoProduccion(Map<String,dynamic> json, String producto) async{
    print("Guardar producto: $producto");
    DocumentReference pedidoRef = Firestore.instance.collection('Producto/$producto/Produccion').document("infoProduccion");
    await pedidoRef.setData(json, merge: true);
    return pedidoRef;
  }

  void setAvanceProduccion(OrdenProduccion orden, String Proceso, String prod, int cantidad) async {
    DocumentReference ordenRef = Firestore.instance.collection('ordenProduccion').document('${orden.key}');
    DocumentSnapshot doc = await ordenRef.get();
    int cantPrevia = doc.data['ordenProduccion']['$prod']['terminada$Proceso'];
    int nuevaCantidad = cantPrevia + cantidad;
    print("Cantidad previa: $cantPrevia");
    if(cantPrevia != null){
      ordenRef.setData({
        "ordenProduccion": {prod : {
          "terminada$Proceso": nuevaCantidad
        }}
      }, merge: true);
    } else {
      print("Algo esta mal");
    }
  }


  Future<OrdenProduccion> setOrdenProduccion(List<Produccion> listProduccion, String uid, CorteBloc bloc) async {
    OrdenProduccion ordenProduccion = OrdenProduccion();
    Map<String, dynamic> map = {};
    DocumentReference ordenRef = Firestore.instance.collection('ordenProduccion').document();
    ordenProduccion.key = ordenRef.documentID;
    ordenProduccion.uid = uid;
    ordenProduccion.fechaSolicitud = DateTime.now();
    //TODO evaluar si es en rollo o en fleje
    var listaDetalleProd = listProduccion.map((prod){
      return DetalleProdPerfil.fromProduccion(prod, 100, true);
    }).toList();
    ordenProduccion.listProdPerfiles = listaDetalleProd;
    //bloc.ordenes.stream.add(ordenProduccion);
    //ordenProduccion.listProducto = listProduccion;
    ordenRef.setData(ordenProduccion.toMap());
    listaDetalleProd.forEach((prod){
      ordenRef.setData({
        "ordenProduccion": {prod.nombre : prod.toMap()}
      },merge: true).then((_){
        bloc.newOrden.add(ordenProduccion);
      });
      print("Producto en Orden: ${prod.toMap()}");
      map.addAll(prod.toMap());
    });
    print("Map: $map");
    return ordenProduccion;
  }

  Future<Null> setOrden (OrdenProduccion orden, String prod, int index){
    DocumentReference pedidoRef = Firestore.instance.collection('ordenProduccion').document(orden.key);
    pedidoRef.setData({
      "ordenProduccion": {prod : orden.listProdPerfiles[index].toMap()}
    },merge: true);
  }

  Future<Null> setRollo (DetalleRollo rollo) async {
    DocumentReference rolloRef = Firestore.instance.collection('controlRollo').document('${rollo.remesa}');
    await rolloRef.setData(rollo.toMap(),merge: true);
  }

  Future<DocumentReference> setPedido(Order pedido) async {
    //Generate the document id for pedido
    DocumentReference pedidoRef = Firestore.instance.collection('pedidos').document();
    pedido.key = pedidoRef.documentID;
    //TODO agregar funcionalidad de horas y dias habiles
    pedido.fechaSolicitud = DateTime.now();
    await pedidoRef.setData(pedido.toMap());
    DocumentReference detalleRef = pedidoRef.collection('detallePedido').document("pedido");
    //Save amparos to Firestore
    pedido.listaProd.forEach((p){
      print("PolizaRef: $pedidoRef");
      detalleRef.setData(
        {
          "${p.nombre}": p.disp

        }, merge: true
      )
          .then((_)=>print("Agregado Correctamente ${p.nombre}"))
          .catchError((error) => print("Algo salio mal $error"));
    });
    return pedidoRef;
  }

  Future<List<Order>> getListaPedidos(FirebaseUser user) async{
    QuerySnapshot query =  await _db.collection('pedidos').where('uid',isEqualTo: user.uid).limit(15).getDocuments();
    var listaPedidos = query.documents.map((doc) async {
      var pedido = Order.fromMap(doc.data);
      return pedido;
    }).toList();
    print("Lista pedidos ${listaPedidos.toString()}");
    return Future.wait(listaPedidos);
  }
  
  Future<List<DetalleRollo>> getListaRollos() async {
    QuerySnapshot query = await _db.collection('controlRollo').getDocuments();
    var listaRollos = query.documents.map((doc){
      var rollo = DetalleRollo.fromMap(doc.data);
      print("Doc en rollo ${doc.data}");
      return rollo;
    }).toList();
    print("Lista Rollos ${listaRollos.first.fecha}");
    return listaRollos;
  }
  

//TODO Aca esta el problema CUAL???
  Future<Map<String, OrdenProduccion>> getListaOrdenes() async{
    List<DetalleProdPerfil> listProd;
    Map<String,dynamic> mapListaProd;
    Map<String, OrdenProduccion> mapOrdenProd = Map<String,OrdenProduccion>();
    //Get query con ordenes de producccion
    QuerySnapshot query =  await _db.collection('ordenProduccion').getDocuments(); //.where('terminada',isEqualTo: 'False')
    print("Query length ${query.documents.length}");

    //Para cada orden agregar su lista de detalle de produccion
    query.documents.forEach((doc){
      listProd = List();
      //Crea la orden a partir del mapa
      OrdenProduccion orden = OrdenProduccion.fromMap(doc.data);
      mapListaProd = doc['ordenProduccion'].cast<String,dynamic>();
      mapListaProd.forEach((d,v){
        listProd.add(DetalleProdPerfil.fromMap(v.cast<String,dynamic>()));
      });
      orden.listProdPerfiles = listProd;
      /*
      listProd = doc['ordenProduccion'].map((prod){
        return DetalleProdPerfil.fromMap(prod.cast<Map<String,dynamic>());
      }).toList();
      orden.listProdPerfiles = listProd;
      */
      mapOrdenProd.putIfAbsent(orden.key, () => orden);
    });
    return mapOrdenProd;
  }

  Future<List<RegContable>> getInfoContable(Producto prod) async{
    print("getInfoContable ejecutada");
      QuerySnapshot snap =  await _db.collection('Producto/${prod.nombre}/Contabilidad/').getDocuments();
      Map<String,dynamic> map;
      List<RegContable> listaCon = List();
      if(snap != null){
        map = snap.documents.first.data["entry"].cast<String,dynamic>();
        map.forEach((k,V){
          listaCon.add(RegContable.fromMap(V.cast<String,dynamic>(),prod.disp));
        });
        print("List Contable prod ${prod.nombre}: $listaCon");
        return listaCon;
      } print("No hay datos");
  }

  Future<List<RegContable>> getInfoContableByProduct(String prod, int cant) async{
    print("getInfoContable ejecutada");
    QuerySnapshot snap =  await _db.collection('Producto/$prod/Contabilidad/').getDocuments();
    Map<String,dynamic> map;
    List<RegContable> listaCon = List();
    if(snap != null){
      map = snap.documents.first.data["entry"].cast<String,dynamic>();
      map.forEach((k,V){
        listaCon.add(RegContable.fromMap(V.cast<String,dynamic>(),cant));
      });
      print("List Contable prod $prod: $listaCon");
      return listaCon;
    } print("No hay datos");
  }

  Future<List<DocumentSnapshot>> getPedidoUser(FirebaseUser user) async{
    return _db.collection('Polizas').where('uid',isEqualTo: user.uid).getDocuments().then((val){
      //Print lista document id polizas
      val.documents.forEach((d){
        print("getPoliza ${d.documentID}");
      });
      return val.documents;
    });
  }

  Future<Order> getPedidoId(String docId) async{
    print("DocumentId: $docId");
    DocumentSnapshot doc =  await _db.collection('pedidos').document('$docId').get();//collection('detallePedido').document('pedido').get();
    print("Doc: ${doc.data.length}");
    var pedido = Order.fromMap(doc.data);
    print("Pedido: ${pedido.toString()}");

    var productos = await getProductos(docId);
    pedido.listaProd = productos;
    return pedido;
  }

  Future<List<Producto>> getProductos(String documentID) async {
    List<Producto> listProd = List();
    DocumentSnapshot doc =  await _db.collection('pedidos').document(documentID).collection('detallePedido').document('pedido').get();
    doc.data.forEach((k,V){
      listProd.add(Producto(nombre: k, disp: V));
    });
    return listProd;
  }

  Future<Cliente> getCliente(String cliente) async {
    DocumentSnapshot doc = await _db.collection('users').document(cliente).get();
    return Cliente.fromMap(doc.data);
  }


  String createOrdenProduccion(Produccion selProd) {
    DocumentReference ordenRef = Firestore.instance.collection('ordenProduccion').document();
    return ordenRef.documentID;
  }

/*


  Future<Map> getQuiz(quizId){
    _db.collection('quizzes')
        .document(quizId)
        .get().then((snap) => snap.data);
  }

  setReporte(String uid){
    print("Reporte modificado");
    _db.collection('reportes').document(uid).setData({
      'uid': uid,
      'correo' : 'andres@gmail.com',
      'lastActivity': DateTime.now()
    });
  }

  Future<AuxBasico> getAux(int nit) async{
    var snap = await _db.collection('Terceros').document('$nit').get();
    return AuxBasico.fromMapObject(snap.data);
  }

  Stream<QuerySnapshot> getPolizasManager() {
    return _db.collection('Polizas').snapshots();
    //return AuxBasico.fromMapObject(snap.data);
  }

  Future<List<DocumentSnapshot>> getPolizas() async{
    var polizas = await _db.collection('Polizas').getDocuments();
    var listaPolizas = polizas.documents;
    return listaPolizas;
    //return AuxBasico.fromMapObject(snap.data);
  }

  Future<List<DocumentSnapshot>> getPolizasUser(FirebaseUser user) async{
    return _db.collection('Polizas').where('uid',isEqualTo: user.uid).getDocuments().then((val){
      //Print lista document id polizas
      val.documents.forEach((d){
        print("getPoliza ${d.documentID}");
      });
      return val.documents;
    });
  }

  Future<List<Poliza>> getPolizasUserObj(FirebaseUser user) async{
    QuerySnapshot query =  await _db.collection('Polizas').where('uid',isEqualTo: user.uid).limit(8).getDocuments();
    var listaPolizas = query.documents.map((doc) async {
      var poliza = Poliza.fromMap(doc.data);
      var amparos = await getAmparos(doc.documentID);
      poliza.covers = amparos;
      return poliza;
    }).toList();
    print("Lista polizas ${listaPolizas.toString()}");
    return Future.wait(listaPolizas);
  }


  Future<List<BasicPoliza>> getListaPolizas(FirebaseUser user) async{
    QuerySnapshot query =  await _db.collection('Polizas').where('uid',isEqualTo: user.uid).limit(15).getDocuments();
    var listaPolizas = query.documents.map((doc) async {
      var poliza = BasicPoliza.fromMap(doc.data);
      return poliza;
    }).toList();
    print("Lista polizas ${listaPolizas.toString()}");
    return Future.wait(listaPolizas);
  }

  Future<List<BasicPoliza>> getListaControl(FirebaseUser user, String agencia) async{
    print("Agencia $agencia");
    //TODO URGENTE Filtrar solo las polizas de la agencia
    QuerySnapshot query =  await _db.collection('Polizas').where('estado',isEqualTo: 'Borrador').where('descAgencia', isEqualTo: agencia).getDocuments();
    query.documents.forEach((d){
      print(d.data.toString());
    });
    var listaPolizas = query.documents.map((doc) async {
      var poliza = BasicPoliza.fromMap(doc.data);
      return poliza;
    }).toList();
    print("Lista polizas ${listaPolizas.toString()}");
    return Future.wait(listaPolizas);
  }



  Future<Poliza> getPolizaId(String docId) async{
    DocumentSnapshot doc =  await _db.collection('Polizas').document('$docId').collection('DetallePoliza').document('Poliza').get();
    var poliza = Poliza.fromMap(doc.data);
    print("Poliza: ${poliza.toString()}");
    var amparos = await getAmparos(docId);
    poliza.covers = amparos;
    return poliza;
  }

  Future<Poliza> getPolizaTemporario(String temp) async{
    var temporario = int.parse(temp);
    Poliza poliza;
    QuerySnapshot query =  await _db.collection('Polizas').where('temporario',isEqualTo: temporario).getDocuments();
    if(query.documents.length > 0){
      String docId = query.documents.first.documentID;
      poliza = await getPolizaId(docId);
    } else {
      return null;
    }
    return poliza;
  }



  Future<List<Amparo>> getAmparos(String documentID) async {
    QuerySnapshot query =  await _db.collection('Polizas').document(documentID).collection('DetallePoliza').document('Poliza').collection('Amparos').getDocuments();
    var listAmparos = query.documents.map((amp){
      var amparo = Amparo.fromMap(amp.data);
      return amparo;
    }).toList();
    return listAmparos;
  }

  Future<void> checkAutorization(context, Poliza poliza) async{
    var uid = poliza.intermediary.uid;
    QuerySnapshot query = await _db.collection('/Intermediario/$uid/PrivateData/').getDocuments();
    var test = query.documents.first.data['rol'];
    print("Test : $test");
    if(test == 'Tecnico' || test == 'Gerente'){
      Navigator.pushNamed(context, '/control');
    }
    else {
      print("No tiene perfil de control técnico");
    }
  }

  Future<void> checkIntermediario(context, FirebaseUser user) async {
    QuerySnapshot query = await _db.collection('Intermediario').where('uid', isEqualTo: user.uid).getDocuments();
    print("Checkintermediario ${query.documents.length}");
    query.documents.forEach((val)=> print("${val.data.toString()}"));
    if(query.documents.isNotEmpty){
      Navigator.pushNamed(context, '/inicio');
    } else{
      Navigator.pushNamed(context, '/terceros');

    }
  }

  Future<String> getIntermediario(String uid) async{
    var snap = await _db.collection('Intermediario').document('$uid').get();
    return snap.data.toString();
  }

  Future<Auxiliar> intermediarioInit() async{
    FirebaseUser user = await auth.getUser;
    var snap = await _db.collection('Intermediario').document('${user.uid}').get();
    return Auxiliar.fromMap(snap.data);
  }

  Future<void> setUpload(String url, String polizaId, String fileName,) async {
    var file = fileName.split('.').first;
    await _db.collection('Uploads').document(polizaId).setData({
      "$file":"$url"
    }, merge: true);
  }

  Future<void> deleteUpload(String polizaId, String filename) async{
    var file = filename.split('.').first;
    DocumentReference docRef = await _db.collection('Uploads').document(polizaId);
    docRef.updateData({
      file : FieldValue.delete()
    }).whenComplete((){
      print("Field Deleted");
    });
  }

  Future<Map<String, dynamic>> getUploads(String polizaId) async{
    Map<String, dynamic> uploadList = Map();
    await _db.collection('Uploads').document('$polizaId').get().then((val){
      if(val.data != null){
        val.data.forEach((key, value){
          uploadList.putIfAbsent('$key', () => '$value');
        });
      }
    });
    return uploadList;
  }



  Future<void> setControl({String concepto, String polizaId, Poliza poliza}) async{
    FirebaseUser user = await auth.getUser;
    if(concepto == 'Autorizo'){
      await _db.collection('Polizas').document(polizaId).collection('DetallePoliza').document('Poliza').updateData({"estado":"Emitida"});
      await _db.collection('Polizas').document(polizaId).updateData({"estado":"Emitida"});
      await _db.collection('Controles').document(polizaId).setData({"estado":"Emitida", "user":user.email, "fechaAutorizacion": DateTime.now()});
      final MailOptions mailOptions = MailOptions(
        body: 'Señores, <br> ${poliza.intermediary.surname} <br><br> Tenemos el gusto de informarle que el temporario #${poliza.temporaryNumber} ha sido autorizado.'
            '<br><br>Atentamente,<br><br> Equipo control técnico<br> Aseguradora solidaria de Colombia',
        subject: 'Respuesta control técnico',
        recipients: ['afrestrepocastro@gmail.com'],
        isHTML: true,
      );
      await FlutterMailer.send(mailOptions);

    } else {
      await _db.collection('Polizas').document(polizaId).collection('DetallePoliza').document('Poliza').updateData({"estado":"No Autorizada"});
      await _db.collection('Polizas').document(polizaId).updateData({"estado":"No Autorizada"});
      await _db.collection('Controles').document(polizaId).setData({"estado":"No Autorizada", "user":user.email, "fechaAutorizacion": DateTime.now()});
      final MailOptions mailOptions = MailOptions(
        body: 'Señores, <br> ${poliza.intermediary.surname} <br><br> Lamentamos informar que el temporario #${poliza.temporaryNumber} no ha sido autorizado.'
            '<br>Si desea apelar la decisión por favor enviar solicitud de seguro al correo a tecnico@solidaria.com.co'
            '<br><br>Atentamente,<br><br> Equipo control técnico<br> Aseguradora solidaria de Colombia',
        subject: 'Respuesta control técnico',
        recipients: ['afrestrepocastro@gmail.com'],
        isHTML: true,
      );
      await FlutterMailer.send(mailOptions);
    }
  }

  Future<int> setAux({Auxiliar auxiliar, FirebaseUser user}) async{
    int result;
    if(auxiliar.thirdPartyType == 'Intermediario'){
      try {
        await _db.collection('Intermediario').document('${user.uid}').setData(auxiliar.toMapIntermed()).then((_)=> result = 1);
        await _db.collection('Intermediario').document('${user.uid}').collection("PrivateData").document('private').setData({
          "rol": "Intermediario",
          "CupoAutorizacion": "0",
        }).then((_)=> result = 1);
      } catch (error){
        result = 0;
        print("Error al guardar intermediario: $error");
      }
    } else if(auxiliar.thirdPartyType == 'Afianzado'){
      try{
        await _db.collection('Afianzado').document('${auxiliar.id}').setData(auxiliar.toMapAfianzado()).then((_)=> result = 1);
        await _db.collection('Terceros').document('${auxiliar.id}').setData(auxiliar.toMapBasicAfianzado()).then((_)=> result = 1);
      }catch (error){
        result = 0;
      }
    } else {
      try{
        await _db.collection('Contratante').document('${auxiliar.id}').setData(auxiliar.toMapOtro()).then((_)=> result = 1);
        await _db.collection('Terceros').document('${auxiliar.id}').setData(auxiliar.toMapBasicOtro()).then((_)=>result = 1);
      } catch (error){
        result = 0;
      }
    }
    return result;
  }



}

loadData() async {
  var data = await DatabaseService().getQuiz('angular');

  print("Data description: ${data['description']}");

}
*/
}