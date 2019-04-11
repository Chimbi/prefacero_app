import 'dart:async'; //is used to define Future Objects
import 'dart:io'; //import the directory modules
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart'; //To use the get directory
import 'package:prefacero_app/model/auxCont.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  final String auxTable = "auxTable";
  final String columnKey = "key";
  final String columnAccType = "accType";
  final String columnDescrip = "description";
  final String columnJaccount = "jaccount_code";
  final String columnLastValue = "lastValue";
  final String columnRegType = "regType";
  final String columnTagCode = "tagCode";
  final String columnTransNature = "transNature";
  final String columnValueFactor = "valueFactor";

  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();

    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "maindb.db"); // home;
    var ourDb = await openDatabase(path, version: 2, onCreate: _onCreate);
  }

  /*
  id | username | password
  ------------------------
   1 | Paulo    | paulo
   2 | James    | bond
  */
  /*
  String key;
  String accType;
  String description;
  int jaccount_code;
  double lastValue;
  String regType;
  int tagCode;
  String transNature;
  double valueFactor;
*/

  void _onCreate(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $auxTable ($columnKey INTEGER PRIMARY KEY, $columnAccType TEXT, $columnDescrip TEXT, $columnJaccount INTEGER, $columnLastValue REAL, $columnRegType TEXT, $columnTagCode INTEGER, $columnTransNature TEXT, $columnValueFactor REAL)");
  }

//CRUD - CREATE, READ, UPDATE, DELETE

// Insert

  Future<int> saveAuxEntry(Auxiliar auxEntry) async {
    var dbClient = await db;
    int res = await dbClient.insert(auxTable, auxEntry.toMap());
    return res;
  }

//Get all entries
  Future<List> gerAllEntries() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $auxTable");
    return result;
  }

//Count entries
  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery("SELECT COUNT(*) FROM $auxTable"));
  }

  Future<int> deleteAuxEntry(int key) async {
    var dbClient = await db;
    return await dbClient
        .delete(auxTable, where: "$columnKey = ?", whereArgs: [key]);
  }

  Future<int> updateAuxEntry(Auxiliar auxEntry) async {
    var dbClient = await db;
    return await dbClient.update(auxTable, auxEntry.toMap(),
        where: "$columnKey = ?", whereArgs: [auxEntry.key]);
  }

  Future<Auxiliar> getUser(int key) async {
    var dbClient = await db;
    var result = await dbClient
        .rawQuery("SELECT * FROM $auxTable WHERE $columnKey = $key");
    if (result.length == 0) return null;
    return new Auxiliar();
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}
