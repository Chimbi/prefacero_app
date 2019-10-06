
/*
import 'package:appsolidariav3/model/amparoModel.dart';
import 'package:appsolidariav3/model/auxiliarModel.dart';
import 'package:appsolidariav3/model/polizaModel.dart';

import 'package:prefacero_app/utils/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class DatabaseService {

  final Firestore _db = Firestore.instance;
  final AuthService auth = AuthService();

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