import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';


class LoadAndViewCsvPage extends StatelessWidget {
  final String path;
  String username = 'increeceapp@gmail.com';
  String password = 'Afr21052';


  LoadAndViewCsvPage({Key key, this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final message = Message()
      ..attachments = [FileAttachment(File(path))]
      ..from = Address(username, 'Prefacero App')
      ..recipients.add('afrestrepocastro@gmail.com')
    //..ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com'])
    //..bccRecipients.add(Address('bccAddress@example.com'))
      ..subject = 'Orden de producción Proceso 1072 :: 😀 :: ${DateTime.now()}'
      //..text = 'This is the plain text.\nThis is line 2 of the text part.';
      ..html = "<h1>Orden de produción</h1>\n<p>Diana buenos días\,</p>"
          "\n<p>Por favor cargar a la contabilidad el archivo adjunto. Muchas gracias</p>"
          "\n<p>Saludos\,</p>\n<p>Andrés Restrepo</p>";

    final smtpServer = gmail(username, password);
    return Scaffold(
      appBar: AppBar(
        title: Text("View csv"),
      ),
      body: FutureBuilder(
        future: _loadCsvData(),
        builder: (_, AsyncSnapshot<List<dynamic>> snapshot) {
          if(snapshot.hasData){
            return SafeArea(
              child: ListView(
                children: <Widget>[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: <Widget>[
                        DataTable(
                            columns: [
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("")),
                            ],
                            rows: snapshot.data.map((row){
                              return DataRow(cells: [
                                DataCell(Text(row[0].toString())),
                                DataCell(Text(row[1].toString())),
                                DataCell(Text(row[2].toString())),
                                DataCell(Text(row[3].toString())),
                                DataCell(Text(row[4].toString())),
                                DataCell(Text(row[5].toString())),
                                DataCell(Text(row[6].toString())),
                                DataCell(Text(row[7].toString())),
                                DataCell(Text(row[8].toString())),
                                DataCell(Text(row[9].toString())),
                                DataCell(Text(row[10].toString())),
                                DataCell(Text(row[11].toString())),
                                DataCell(Text(row[12].toString())),
                                DataCell(Text(row[13].toString())),
                                DataCell(Text(row[14].toString())),
                                DataCell(Text(row[15].toString())),
                                DataCell(Text(row[16].toString())),
                                DataCell(Text(row[17].toString())),
                                DataCell(Text(row[18].toString())),
                                DataCell(Text(row[19].toString())),
                                DataCell(Text(row[20].toString())),
                                DataCell(Text(row[21].toString())),
                                DataCell(Text(row[22].toString())),
                                DataCell(Text(row[23].toString())),
                                DataCell(Text(row[24].toString())),
                              ]);
                            }).toList()),
                        RaisedButton(
                          child: Text("Enviar", style: TextStyle(color: Colors.white)),
                            onPressed: () async {
                          print("Boton click");
                          try {
                            final sendReport = await send(message, smtpServer);
                            print('Message sent: ' + sendReport.toString());
                          } on MailerException catch (e) {
                            print("Error $e");
                            print('Message not sent.');
                            for (var p in e.problems) {
                              print('Problem: ${p.code}: ${p.msg}');
                            }
                          }
                        })
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: Text('No data found'),
          );
        },
      ),);
  }
/*
Padding(
              padding: EdgeInsets.all(16.0),
              child: ListView(
                  children: snapshot.data.map((row) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      //Text(row[0].toString()),
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text("1")),
                          DataColumn(label: Text("1")),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Text(row[0].toString())),
                            DataCell(Text(row[1].toString())),

                          ])
                        ],
                      ),
                    ),
                  )).toList()
              ),
            );
 */


  //Load csv as String and transform to List<List<dynamic>>

  Future<List<dynamic>> _loadCsvData() async {
    final file = File(path).openRead();
    return await file.transform(utf8.decoder)
        .transform(CsvToListConverter())
        .toList() ;
  }
}
