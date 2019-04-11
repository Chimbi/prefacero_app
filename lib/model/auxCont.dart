import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';

class Auxiliar {
  int key;
  String accType;
  String description;
  int jaccount_code;
  double lastValue;
  String regType;
  int tagCode;
  String transNature;
  double valueFactor;

  Auxiliar(
      {this.key,
      this.accType,
      this.description,
      this.jaccount_code,
      this.lastValue,
      this.regType,
      this.tagCode,
      this.transNature,
      this.valueFactor});

  Auxiliar.fromSnapshot(DataSnapshot snapshot, double value) {
    //key = snapshot.key;
    accType = snapshot.value['accType'];
    description = snapshot.value['description'];
    jaccount_code = snapshot.value['jaccount_code'];
    lastValue = double.parse((snapshot.value['valueFactor']*value).toStringAsFixed(2));
    //valueFactor = snapshot.value['valueFactor'];
    regType = snapshot.value['regType'];
    tagCode = snapshot.value['tagCode'];
    transNature = snapshot.value['transNature'];
  }
  Auxiliar.fromMap(Map<String, dynamic> map){
    key = map['key'];
    accType = map['accType'];
    description = map['description'];
    jaccount_code = map['jaccount_code'];
    //valueFactor = map['valueFactor'];
    lastValue = map['lastValue'];
    regType = map['regType'];
    tagCode = map['tagCode'];
    transNature = map['transNature'];
  }
  Map<String,dynamic> toMap(){
    var auxMap = Map<String,dynamic>();
    auxMap["accType"] = accType;
    auxMap["description"] = description;
    auxMap["jaccount_code"] = jaccount_code;
    //auxMap["valueFactor"] = valueFactor;
    auxMap["lastValue"] = lastValue;
    auxMap["regType"] = regType;
    auxMap["tagCode"] = tagCode;
    auxMap["transNature"] = transNature;

    if(key != null){
      auxMap['key'] = key;
    }
    return auxMap;

  }
}
