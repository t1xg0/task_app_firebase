import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/task_repository.dart';
import '../widgets/task_form_dialog.dart';
import '../widgets/task_tile.dart';

class TasksPage extends StatefulWidget {
  final TaskRepository repository;

  const TasksPage({
    super.key,
    required this.repository,
  });

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late final Stream<List<TaskModel>> _tasksStream;

  @override
  void initState() {
    super.initState();
    _tasksStream = widget.repository.watchTasks();
    widget.repository.loadInitialData();
  }

  Future<void> _addTask() async {
    final result = await showDialog<TaskFormResult>(
      context: context,
      builder: (_) => const TaskFormDialog(),
    );

    if (result == null) return;

    await widget.repository.addTask(
      title: result.title,
      description: result.description,
    );
  }

  Future<void> _toggleTask(TaskModel task) async {
    await widget.repository.toggleTask(task);
  }

  Future<void> _refresh() async {
    await widget.repository.refreshFromRemote();
    await widget.repository.syncPendingTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task App Firebase'),
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: _tasksStream,
        builder: (context, snapshot) {
          final tasks = snapshot.data ?? const [];

          if (snapshot.connectionState == ConnectionState.waiting && tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (tasks.isEmpty) {
            return const Center(
              child: Text('No hay tareas registradas'),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];

                return TaskTile(
                  task: task,
                  onToggle: () => _toggleTask(task),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}