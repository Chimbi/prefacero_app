//import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';

class JournalEntry {
  String key;
  String tipoCompr;
  int codigoCompr;
  int numDoc;
  //DateTime date = DateTime.now();
  //DateTime dateDue = DateTime.now().add(Duration(days: 30));
  int nit;
  String provInvoiceNum;
  String hint;
  bool sumZero;
  List<JournalTrans> entry;

  JournalEntry.init(
      {this.key,
        this.tipoCompr = "P",
      this.codigoCompr = 8,
      this.numDoc = 678,
      //this.date,
      //this.dateDue,
      this.nit,
      this.provInvoiceNum,
      this.hint,
      this.sumZero = false,
      this.entry});

  JournalEntry(
      {
        this.key,
        @required this.tipoCompr,
      @required this.codigoCompr,
      @required this.numDoc,
       // this.date,
      //@required this.dateDue,
      @required this.nit,
      this.provInvoiceNum,
      @required this.hint,
      this.sumZero,
      @required this.entry});
/*
  fromSnapshot(DataSnapshot snapshot){
      key = snapshot.key;
      tipoCompr = snapshot.value["tipoCompr"];
      codigoCompr = snapshot.value["codigoCompr"];
      numDoc = snapshot.value["numDoc"];
      //this.date,
      //this.dateDue,
      nit = snapshot.value["nit"];
    //provInvoiceNum,
      hint = snapshot.value["hint"];
      sumZero = snapshot.value["sum_zero"];
    }
*/
  toJson() {
    return {
      "tipoCompr" : tipoCompr,
      "codigoCompr": codigoCompr,
      "numDoc": numDoc,
      //"day": date.day,
      //"month": date.month,
      //"year": date.year,
      //"day_due": dateDue.day,
      //"month_due": dateDue.month,
      //"year_due": dateDue.year,
      "nit": nit,
      "factura_prov": provInvoiceNum,
      //"dateDue": dateDue,
      "hint": hint,
      "sum_zero": sumZero,
      //"entry": entry,  La lista de transacciones se agrega a la base de datos directamente
      };
  }
}

class JournalTrans {
  String description;
  int prodGroup;
  int prodLine;
  int prodCode;
  double unitaryPrice;
  int cant;
  double itemValue;
  int tagCode;
  int jAccountCode;
  String transNature;
  String accType;
  String regType;
  String accountName;

  JournalTrans(
      {this.description,
      this.prodGroup,
      this.prodLine,
      this.prodCode,
      this.unitaryPrice,
      this.cant,
      this.itemValue,
      this.tagCode,
      this.jAccountCode,
      this.transNature,
      this.accType,
      this.regType,
      this.accountName});

  toJson() {
    return {
      "description": description,
      "grupo": prodGroup,
      "linea": prodLine,
      "codigo": prodCode,
      "precioUnit": unitaryPrice,
      "cant": cant,
      "itemValue": itemValue,
      "tagCode": tagCode,
      "jaccount_code": jAccountCode,
      "transNature": transNature,
      "accType": accType,
      "regType": regType,
      "account_name": accountName,
    };
  }
}
