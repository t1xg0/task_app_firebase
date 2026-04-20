import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_model.dart';

class TaskRemoteService {
  final CollectionReference<Map<String, dynamic>> _tasksRef =
      FirebaseFirestore.instance.collection('tasks');

  Future<void> upsertTask(TaskModel task) async {
    if (task.id == null) return;

    await _tasksRef.doc(task.id.toString()).set(task.toFirestore());
  }

  Future<List<TaskModel>> fetchTasks() async {
    final snapshot = await _tasksRef.get();

    return snapshot.docs.map((doc) {
      return TaskModel.fromFirestore(
        doc.data(),
        id: int.parse(doc.id),
      );
    }).toList();
  }
}