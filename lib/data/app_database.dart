import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/task_model.dart';

part 'app_database.g.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();
}

@DriftDatabase(tables: [Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'task_app_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.dart.js'),
      ),
    );
  }

  TaskModel _mapTaskToModel(Task row) {
    return TaskModel(
      id: row.id,
      title: row.title,
      description: row.description,
      completed: row.completed,
      updatedAt: row.updatedAt,
      pendingSync: row.pendingSync,
    );
  }

  Stream<List<TaskModel>> watchTasks() {
    final query = select(tasks)
      ..orderBy([
        (t) => OrderingTerm.desc(t.updatedAt),
      ]);

    return query.watch().map(
      (rows) => rows.map(_mapTaskToModel).toList(),
    );
  }

  Future<List<TaskModel>> getAllTasks() async {
    final rows = await select(tasks).get();
    return rows.map(_mapTaskToModel).toList();
  }

  Future<TaskModel> insertTask(TaskModel task) async {
    final insertedId = await into(tasks).insert(
      TasksCompanion.insert(
        title: task.title,
        description: task.description,
        completed: Value(task.completed),
        updatedAt: task.updatedAt,
        pendingSync: Value(task.pendingSync),
      ),
    );

    return task.copyWith(id: insertedId);
  }

  Future<void> updateTask(TaskModel task) async {
    if (task.id == null) return;

    await update(tasks).replace(
      Task(
        id: task.id!,
        title: task.title,
        description: task.description,
        completed: task.completed,
        updatedAt: task.updatedAt,
        pendingSync: task.pendingSync,
      ),
    );
  }

  Future<void> toggleCompleted({
    required int id,
    required bool completed,
  }) async {
    await (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        completed: Value(completed),
        updatedAt: Value(DateTime.now()),
        pendingSync: const Value(true),
      ),
    );
  }

  Future<List<TaskModel>> getPendingTasks() async {
    final rows = await (select(tasks)..where((t) => t.pendingSync.equals(true))).get();
    return rows.map(_mapTaskToModel).toList();
  }

  Future<void> markAsSynced(int id) async {
    await (update(tasks)..where((t) => t.id.equals(id))).write(
      const TasksCompanion(
        pendingSync: Value(false),
      ),
    );
  }

  Future<void> upsertFromRemote(TaskModel task) async {
    if (task.id == null) return;

    await into(tasks).insertOnConflictUpdate(
      TasksCompanion(
        id: Value(task.id!),
        title: Value(task.title),
        description: Value(task.description),
        completed: Value(task.completed),
        updatedAt: Value(task.updatedAt),
        pendingSync: const Value(false),
      ),
    );
  }
}