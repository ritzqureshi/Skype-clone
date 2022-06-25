import 'package:skype_clone/models/log.dart';

abstract class LogInterface {
  openDb(dbName);
  init();
  addLogs(Log log);
  Future<List<Log>> getLogs();
  deleteLogs(int logId);
  close();
}
