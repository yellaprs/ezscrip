import 'package:sembast/sembast.dart';

class RetentionTask {
  DateTime _taskDate;
  int _count;

  RetentionTask(this._taskDate, this._count);

  DateTime getTaskDate() => _taskDate;

  int getCount() => _count;

  toJson() {
    return {
      'taskDate': _taskDate.millisecondsSinceEpoch,
      'count': _count
    };
  }

  static RetentionTask fromJson(Map<String, dynamic> taskMap) {
    int taskDate = taskMap['taskDate'];
    print(taskDate);
    return RetentionTask(
        DateTime.fromMillisecondsSinceEpoch(taskDate), taskMap['count']);
  }
}

class RetentionTaskList {
  RetentionTaskList();

  List<RetentionTask> retentionTasks = [];

  factory RetentionTaskList.fromJson(Map<String, dynamic> taskListJson) {
    List<RetentionTask> taskList = taskListJson.entries
        .map((entry) => RetentionTask(
            DateTime.parse(entry.key), int.parse(entry.value as String)))
        .toList();

    RetentionTaskList retentionTaskList = RetentionTaskList();
    retentionTaskList.retentionTasks = taskList;

    return retentionTaskList;
  }

  addRetentionTask(RetentionTask task) {
    retentionTasks.add(task);
  }

  removeRetentionTask(RetentionTask task) {
    retentionTasks.remove(task);
  }

  toJson() {
    return retentionTasks
        .map((retentionTask) => retentionTask.toJson())
        .toList();
  }
}

class RetentionAudit {
  static StoreRef _auditStore = intMapStoreFactory.store('audit');

  static Future<RetentionTaskList> getRetentionAuditLog(Database db) async {
    RetentionTaskList? retentionLog = RetentionTaskList();

    var recordSnapshots = await _auditStore.find(db);

    List<RetentionTask> taskList = recordSnapshots.map((snapshot) {
      final retentionTask =
          RetentionTask.fromJson(snapshot.value as Map<String, dynamic>);

      return retentionTask;
    }).toList();

    taskList.forEach((task) {
      retentionLog.addRetentionTask(task);
    });

    return retentionLog;
  }

  static Future<int> addToRetentionAuditLog(
      Database db, RetentionTask task) async {
    int id = await _auditStore.add(db, task.toJson()) as int;
    return id;
  }

  static Future<int> clearRetentionAuditLog(Database db) async {
    int deleteCount = await _auditStore.delete(db);

    return deleteCount;
  }
}
