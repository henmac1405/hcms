import 'dart:async';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:hcms/models/config.dart';
import 'package:hcms/models/error.dart';
import 'package:hcms/models/nik.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  //table config
  final String tableConfig = 'config';
  final String columnConfig1 = 'config1';
  final String columnConfig2 = 'config2';
  final String columnConfig3 = 'config3';

  //table error
  final String tableError = 'error';
  final String columnError1 = 'error1';
  final String columnError2 = 'error2';
  final String columnErrorDate = 'errordate';

  //table NIK
  final String tableNIK = 'nik';
  final String columnPersonalid = 'personalid';
  final String columnName = 'name';

  static Database? _db;

  DatabaseHelper.internal();

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();

    return _db;
  }

  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'HCMSNewNew.db');

//    await deleteDatabase(path); // just for testing

    var db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    return db;
  }

  void _onCreate(Database db, int newVersion) async {
    print('_onCreate');
    await db.execute(
        'CREATE TABLE $tableConfig($columnConfig1 TEXT,$columnConfig2 TEXT, $columnConfig3 TEXT)');
    await db.execute(
        'CREATE TABLE $tableError($columnError1 TEXT,$columnError2 TEXT, $columnErrorDate TEXT)');
    await db.execute(
        'CREATE TABLE $tableNIK($columnPersonalid TEXT,$columnName TEXT)');

    print('_onCreate2');
  }

  // CONFIG

  Future<int> saveConfig(Config config) async {
    var dbClient = await db;
    var result = await dbClient!.insert(tableConfig, config.toMap());

    return result;
  }

  Future<List> getConfig() async {
    var dbClient = await db;
    var result = await dbClient!.query(tableConfig,
        columns: [columnConfig1, columnConfig2, columnConfig3]);
    return result.toList();
  }

  Future<List> getConfig_byid(String id) async {
    var dbClient = await db;
    var result = await dbClient!
        .rawQuery('SELECT * FROM config where iteminventory_id = ? ', [id]);
    return result.toList();
  }

  Future<int> deleteConfigAll() async {
    var dbClient = await db;
    return await dbClient!.delete(tableConfig);
  }

  // ERROR

  Future<int> saveError(Error error) async {
    var dbClient = await db;
    var result = await dbClient!.insert(tableError, error.toMap());

    return result;
  }

  Future<List> getError() async {
    var dbClient = await db;
    var result =
        await dbClient!.rawQuery('SELECT * FROM error order by errordate desc');
    return result.toList();
  }

  Future<List> getError_byid(String tanggal) async {
    var dbClient = await db;
    var result = await dbClient!
        .rawQuery('SELECT * FROM error where errordate = ? ', [tanggal]);
    return result.toList();
  }

  Future<int> deleteErrorAll() async {
    var dbClient = await db;
    return await dbClient!.delete(tableError);
  }

  // NIK

  Future<int> saveNIK(NIKS nik) async {
    var dbClient = await db;
    var result = await dbClient!.insert(tableNIK, nik.toMap());

    return result;
  }

  Future<List> getNIK() async {
    var dbClient = await db;
    var result = await dbClient!.rawQuery('SELECT * FROM nik');
    return result.toList();
  }

  Future<List> getNIK_byid(String nik) async {
    var dbClient = await db;
    var result = await dbClient!
        .rawQuery('SELECT * FROM nik where personalid = ? ', [nik]);
    return result.toList();
  }

  Future<int> deleteNIKAll() async {
    var dbClient = await db;
    return await dbClient!.delete(tableNIK);
  }

  Future<int> deleteNIKbyid(String personalid) async {
    var dbClient = await db;
    // return await dbClient!.delete(tableLog, where: '$columnSalesid = ?' '$columnId = ?' , whereArgs: [salesid,id]);
    return await dbClient!
        .rawDelete('DELETE FROM nik WHERE personalid =?', [personalid]);
  }

  Future close() async {
    var dbClient = await db;
    return dbClient!.close();
  }
}

//
