import 'package:flutter/foundation.dart';

import '../data/app_database.dart';
import '../models/task_model.dart';
import 'task_remote_service.dart';

class TaskRepository {
  final AppDatabase localDb;
  final TaskRemoteService remoteService;

  TaskRepository({
    required this.localDb,
    required this.remoteService,
  });

  Stream<List<TaskModel>> watchTasks() {
    return localDb.watchTasks();
  }

  Future<void> loadInitialData() async {
    await refreshFromRemote();
    await syncPendingTasks();
  }

  Future<void> addTask({
    required String title,
    required String description,
  }) async {
    final localTask = TaskModel(
      title: title,
      description: description,
      completed: false,
      updatedAt: DateTime.now(),
      pendingSync: true,
    );

    final insertedTask = await localDb.insertTask(localTask);

    try {
      await remoteService.upsertTask(insertedTask);
      if (insertedTask.id != null) {
        await localDb.markAsSynced(insertedTask.id!);
      }
    } catch (e) {
      debugPrint('Error syncing new task to Firebase: $e');
    }
  }

  Future<void> toggleTask(TaskModel task) async {
    if (task.id == null) return;

    await localDb.toggleCompleted(
      id: task.id!,
      completed: !task.completed,
    );

    try {
      final updatedTask = task.copyWith(
        completed: !task.completed,
        updatedAt: DateTime.now(),
        pendingSync: true,
      );

      await remoteService.upsertTask(updatedTask);
      await localDb.markAsSynced(task.id!);
    } catch (e) {
      debugPrint('Error syncing toggled task to Firebase: $e');
    }
  }

  Future<void> refreshFromRemote() async {
    try {
      final remoteTasks = await remoteService.fetchTasks();

      for (final task in remoteTasks) {
        await localDb.upsertFromRemote(task);
      }
    } catch (e) {
      debugPrint('Error fetching tasks from Firebase: $e');
    }
  }

  Future<void> syncPendingTasks() async {
    final pendingTasks = await localDb.getPendingTasks();

    for (final task in pendingTasks) {
      try {
        await remoteService.upsertTask(task);
        if (task.id != null) {
          await localDb.markAsSynced(task.id!);
        }
      } catch (e) {
        debugPrint('Error sincronizando tarea: $e');
      }
    }
  }
}