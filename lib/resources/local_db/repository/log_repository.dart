import 'package:skype_clone/models/log.dart';
import 'package:skype_clone/resources/local_db/db/hive_methods.dart';
import 'package:skype_clone/resources/local_db/db/sqlite_methods.dart';

class LogRepository {
  static bool isHive = false;
  static var dbObject = isHive ? HiveMethods() : SqliteMethods();

  static init({required bool isHive, required String dbName}) {
    dbObject = isHive ? HiveMethods() : SqliteMethods();
    dbObject.openDb(dbName);
    dbObject.init();
  }

  static addLogs(Log log) => dbObject.addLogs(log);

  static deleteLogs(int logId) => dbObject.deleteLogs(logId);

  static getLogs() => dbObject.getLogs();

  static close() => dbObject.close();
}
