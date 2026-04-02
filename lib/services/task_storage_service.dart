import 'package:hive_flutter/hive_flutter.dart';

import '../models/task_model.dart';

class TaskStorageService {
  static const String boxName = 'tasksBox';
  static const String tasksKey = 'tasks';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  Future<void> saveTasks(List<TaskModel> tasks) async {
    final box = Hive.box(boxName);
    final taskMaps = tasks.map((task) => task.toMap()).toList();
    await box.put(tasksKey, taskMaps);
  }

  List<TaskModel> getTasks() {
    final box = Hive.box(boxName);
    final data = box.get(tasksKey, defaultValue: []);

    return (data as List)
        .map((item) => TaskModel.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }
}