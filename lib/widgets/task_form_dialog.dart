import 'package:flutter/material.dart';

import '../services/app_logger.dart';

class TaskFormResult {
  final String title;
  final String description;

  const TaskFormResult({
    required this.title,
    required this.description,
  });
}

class TaskFormDialog extends StatefulWidget {
  const TaskFormDialog({super.key});

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _titleError;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    AppLogger.debug('Intentando guardar tarea desde TaskFormDialog');

    if (title.isEmpty) {
      AppLogger.warning('Validación fallida: título vacío');

      setState(() {
        _titleError = 'El título no puede estar vacío.';
      });

      return;
    }

    Navigator.of(context).pop(
      TaskFormResult(
        title: title,
        description: description,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva tarea'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Título',
              errorText: _titleError,
            ),
            onChanged: (_) {
              if (_titleError != null) {
                setState(() {
                  _titleError = null;
                });
              }
            },
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descripción',
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            AppLogger.debug('Creación de tarea cancelada desde dialog');
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}