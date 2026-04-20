import 'package:flutter/material.dart';

import '../models/task_model.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: task.completed,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  'Actualizada: ${task.updatedAt.toLocal()}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 8),
                if (task.pendingSync)
                  const Chip(
                    label: Text('Sync pendiente'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}