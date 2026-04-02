import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/task_storage_service.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider(this._storageService);

  final TaskStorageService _storageService;

  final List<TaskModel> _tasks = [];
  bool isSaving = false;
  String searchQuery = '';
  String statusFilter = 'All';

  List<TaskModel> get tasks => List.unmodifiable(_tasks);

  List<TaskModel> get filteredTasks {
    return _tasks.where((task) {
      final matchesSearch =
          task.title.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesFilter =
          statusFilter == 'All' || task.status == statusFilter;

      return matchesSearch && matchesFilter;
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  void loadTasks() {
    _tasks
      ..clear()
      ..addAll(_storageService.getTasks());
    notifyListeners();
  }

  Future<void> addTask(TaskModel task) async {
    if (isSaving) return;
    isSaving = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    _tasks.add(task);
    await _storageService.saveTasks(_tasks);

    isSaving = false;
    notifyListeners();
  }

  Future<void> updateTask(TaskModel updatedTask) async {
    if (isSaving) return;
    isSaving = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await _storageService.saveTasks(_tasks);
    }

    isSaving = false;
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    await _storageService.saveTasks(_tasks);
    notifyListeners();
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void setStatusFilter(String value) {
    statusFilter = value;
    notifyListeners();
  }

  TaskModel? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (_) {
      return null;
    }
  }

  bool isBlocked(TaskModel task) {
    if (task.blockedBy == null || task.blockedBy!.isEmpty) return false;

    final blocker = getTaskById(task.blockedBy!);
    if (blocker == null) return false;

    return blocker.status != 'Done';
  }
}