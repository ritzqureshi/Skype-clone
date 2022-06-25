import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skype_clone/models/log.dart';
import 'package:skype_clone/resources/local_db/interface/log_interface.dart';
import 'package:sqflite/sqflite.dart';

class SqliteMethods implements LogInterface {
  Database? _db;
  String databaseName = "";
  String tableName = "Call_Logs";
  String id = 'log_id';
  String callerName = 'caller_name';
  String callerPic = 'caller_pic';
  String receiverName = 'receiver_name';
  String receiverPic = 'receiver_pic';
  String callStatus = 'call_status';
  String timestamp = 'timestamp';

  Future<Database> get db async {
    if (_db != null) {
      return _db as Database;
    } else {
      _db = await init();
      return _db as Database;
    }
  }

  @override
  openDb(dbName) => (databaseName = dbName);

  @override
  init() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, databaseName);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    String createTableQuery =
        "CREATE TABLE $tableName ($id INTEGER PRIMARY KEY, $callerName TEXT, $callerPic TEXT, $receiverName TEXT, $receiverPic TEXT, $callStatus TEXT, $timestamp TEXT)";

    await db.execute(createTableQuery);
    debugPrint("table created");
  }

  @override
  addLogs(Log log) async {
    var dbClient = await db;
    debugPrint("the log has been added in sqlite db");
    await dbClient.insert(tableName, log.toMap(log));
  }

  updateLogs(Log log) async {
    var dbClient = await db;
    await dbClient.update(
      tableName,
      log.toMap(log),
      where: '$id = ?',
      whereArgs: [log.logId],
    );
  }

  @override
  Future<List<Log>> getLogs() async {
    try {
      var dbClient = await db;
      List<Map> maps = await dbClient.query(
        tableName,
        columns: [
          id,
          callerName,
          callerPic,
          receiverName,
          receiverPic,
          callStatus,
          timestamp,
        ],
      );

      List<Log> logList = [];

      if (maps.isNotEmpty) {
        for (Map map in maps) {
          logList.add(Log.fromMap(map));
        }
      }

      return logList;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  @override
  deleteLogs(int logId) async {
    var client = await db;
    return await client
        .delete(tableName, where: '$id = ?', whereArgs: [logId + 1]);
  }

  @override
  close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
