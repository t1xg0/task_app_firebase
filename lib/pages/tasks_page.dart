import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/crash/crash_service.dart';

import '../models/task_model.dart';
import '../services/app_logger.dart';
import '../services/task_repository.dart';
import '../widgets/task_form_dialog.dart';
import '../widgets/task_tile.dart';

class TasksPage extends StatefulWidget {
  final TaskRepository repository;
  final User? user;
  final AuthService? authService;
  final CrashService? crashService;

  const TasksPage({
    super.key,
    required this.repository,
    this.user,
    this.authService,
    this.crashService,
  });

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  bool _loadingInitialData = true;
  bool _qaLoading = false;
  String? _initialErrorMessage;
  int _reloadKey = 0;

  @override
  void initState() {
    super.initState();
    AppLogger.info('TasksPage abierta');
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _loadingInitialData = true;
      _initialErrorMessage = null;
    });

    try {
      AppLogger.info('Cargando datos iniciales desde TasksPage');
      await widget.repository.loadInitialData();
      AppLogger.info('Datos iniciales cargados correctamente');
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error cargando datos iniciales desde TasksPage',
        error: error,
        stackTrace: stackTrace,
      );

      _initialErrorMessage =
          'No se pudieron cargar los datos iniciales. Intenta nuevamente.';
    } finally {
      if (!mounted) return;

      setState(() {
        _loadingInitialData = false;
      });
    }
  }

  /// Forces the StreamBuilder to recreate its subscription to the local data.
  void _reloadStream() {
    AppLogger.info('Recargando StreamBuilder de tareas');

    setState(() {
      _reloadKey++;
    });
  }

  Future<void> _openCreateTaskDialog() async {
    AppLogger.debug('Abriendo formulario para crear tarea');

    final result = await showDialog<TaskFormResult>(
      context: context,
      builder: (_) => const TaskFormDialog(),
    );

    if (result == null) {
      AppLogger.debug('Creación de tarea cancelada por el usuario');
      return;
    }

    await _createTask(title: result.title, description: result.description);
  }

  Future<void> _createTask({
    required String title,
    required String description,
  }) async {
    try {
      AppLogger.info('Creando tarea desde la pantalla');

      await widget.repository.addTask(title: title, description: description);

      _showMessage('Tarea creada correctamente.');
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error creando tarea desde TasksPage',
        error: error,
        stackTrace: stackTrace,
      );

      _showMessage('No se pudo crear la tarea.');
    }
  }

  Future<void> _toggleTask(TaskModel task) async {
    try {
      AppLogger.info('Cambiando estado de tarea desde la pantalla');

      await widget.repository.toggleTask(task);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error cambiando estado de tarea desde TasksPage',
        error: error,
        stackTrace: stackTrace,
      );

      _showMessage('No se pudo actualizar la tarea.');
    }
  }

  Future<void> _refreshFromRemote() async {
    try {
      AppLogger.info('Actualizando datos desde Firebase manualmente');

      await widget.repository.refreshFromRemote();

      _showMessage('Datos actualizados desde Firebase.');
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error actualizando datos desde Firebase',
        error: error,
        stackTrace: stackTrace,
      );

      _showMessage('No se pudieron actualizar los datos.');
    }
  }

  Future<void> _syncPendingTasks() async {
    try {
      AppLogger.info('Sincronizando tareas pendientes manualmente');

      await widget.repository.syncPendingTasks();

      _showMessage('Sincronización pendiente ejecutada.');
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error sincronizando tareas pendientes',
        error: error,
        stackTrace: stackTrace,
      );

      _showMessage('No se pudieron sincronizar las tareas pendientes.');
    }
  }

  /// Shows the signed-in user before the task list for quick session context.
  Widget _buildUserCard() {
    final user = widget.user;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(user.email ?? 'Usuario autenticado'),
        subtitle: Text(
          'UID: ${user.uid}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await widget.authService?.logout();
  }

  Future<void> _simulateNonFatalCrashlyticsError() async {
    await widget.crashService?.simulateNonFatalError();

    _showMessage(
      'Error no fatal registrado. Revisa Firebase Crashlytics o la consola.',
    );
  }

  void _simulateFatalCrash() {
    widget.crashService?.simulateFatalCrash();
  }

  /// Runs QA-only actions from the debug menu with consistent logging.
  Future<void> _runQaAction(
    String successMessage,
    Future<void> Function() action,
  ) async {
    try {
      AppLogger.info('Ejecutando acción QA');

      await action();

      _showMessage(successMessage);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error ejecutando acción QA',
        error: error,
        stackTrace: stackTrace,
      );

      _showMessage('Error simulado registrado en logs.');
    }
  }

  Future<void> _simulateSlowLoading() async {
    setState(() {
      _qaLoading = true;
    });

    try {
      AppLogger.info('Iniciando simulación de carga lenta');

      await widget.repository.qaSimulateSlowOperation();

      _showMessage('Carga lenta simulada correctamente.');
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error simulando carga lenta',
        error: error,
        stackTrace: stackTrace,
      );

      _showMessage('Error simulando carga lenta.');
    } finally {
      if (!mounted) return;

      setState(() {
        _qaLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Debug-only menu used to exercise sync, loading, and Crashlytics paths.
  Widget _buildQaMenu() {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      tooltip: 'Herramientas QA',
      icon: const Icon(Icons.bug_report_outlined),
      onSelected: (value) {
        if (value == 'permission_denied') {
          _runQaAction(
            'QA: tarea creada localmente con error permission-denied.',
            widget.repository.qaCreateTaskWithPermissionDenied,
          );
        }

        if (value == 'network_error') {
          _runQaAction(
            'QA: tarea creada localmente con error de red.',
            widget.repository.qaCreateTaskWithNetworkError,
          );
        }

        if (value == 'unexpected_sync_error') {
          _runQaAction(
            'QA: tarea creada localmente con error inesperado.',
            widget.repository.qaCreateTaskWithUnexpectedError,
          );
        }

        if (value == 'long_text') {
          _runQaAction(
            'QA: tarea con texto largo creada.',
            widget.repository.qaCreateLongTextTask,
          );
        }

        if (value == 'slow_loading') {
          _simulateSlowLoading();
        }

        if (value == 'ui_error') {
          _runQaAction(
            'QA: error inesperado registrado en logs.',
            widget.repository.qaThrowUnexpectedUiError,
          );
        }

        if (value == 'refresh_remote') {
          _refreshFromRemote();
        }

        if (value == 'sync_pending') {
          _syncPendingTasks();
        }

        if (value == 'reload_stream') {
          _reloadStream();
          _showMessage('Stream recargado.');
        }
        if (value == 'crashlytics_non_fatal') {
          _simulateNonFatalCrashlyticsError();
        }

        if (value == 'crashlytics_fatal') {
          _simulateFatalCrash();
        }
      },
      itemBuilder: (context) {
        return const [
          PopupMenuItem(
            value: 'permission_denied',
            child: Text('QA: simular permission-denied'),
          ),
          PopupMenuItem(
            value: 'network_error',
            child: Text('QA: simular error de red'),
          ),
          PopupMenuItem(
            value: 'unexpected_sync_error',
            child: Text('QA: simular error inesperado'),
          ),
          PopupMenuItem(
            value: 'long_text',
            child: Text('QA: crear texto largo'),
          ),
          PopupMenuItem(
            value: 'slow_loading',
            child: Text('QA: simular carga lenta'),
          ),
          PopupMenuItem(
            value: 'ui_error',
            child: Text('QA: simular error de UI'),
          ),
          PopupMenuItem(
            value: 'crashlytics_non_fatal',
            child: Text('QA: registrar error no fatal Crashlytics'),
          ),
          PopupMenuItem(
            value: 'crashlytics_fatal',
            child: Text('QA: forzar crash fatal Crashlytics'),
          ),
          PopupMenuDivider(),
          PopupMenuItem(
            value: 'refresh_remote',
            child: Text('Actualizar desde Firebase'),
          ),
          PopupMenuItem(
            value: 'sync_pending',
            child: Text('Sincronizar pendientes'),
          ),
          PopupMenuItem(
            value: 'reload_stream',
            child: Text('Recargar stream local'),
          ),
        ];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingInitialData || _qaLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('TaskSync RC'),
          actions: [
            _buildQaMenu(),
            IconButton(
              tooltip: 'Cerrar sesión',
              onPressed: widget.authService == null ? null : _logout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: const _LoadingView(message: 'Cargando tareas...'),
      );
    }

    if (_initialErrorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('TaskSync RC'),
          actions: [
            _buildQaMenu(),
            IconButton(
              tooltip: 'Cerrar sesión',
              onPressed: widget.authService == null ? null : _logout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: _ErrorView(
          message: _initialErrorMessage!,
          onRetry: _loadInitialData,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskSync RC'),
        actions: [
          IconButton(
            tooltip: 'Actualizar desde Firebase',
            onPressed: _refreshFromRemote,
            icon: const Icon(Icons.cloud_download_outlined),
          ),
          IconButton(
            tooltip: 'Sincronizar pendientes',
            onPressed: _syncPendingTasks,
            icon: const Icon(Icons.sync),
          ),
          _buildQaMenu(),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
      body: Column(
        children: [
          _buildUserCard(),
          Expanded(
            child: StreamBuilder<List<TaskModel>>(
              key: ValueKey(_reloadKey),
              stream: widget.repository.watchTasks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _LoadingView(
                    message: 'Consultando base local...',
                  );
                }

                if (snapshot.hasError) {
                  AppLogger.error(
                    'Error en StreamBuilder de tareas',
                    error: snapshot.error,
                    stackTrace: snapshot.stackTrace,
                  );

                  return _ErrorView(
                    message: 'No se pudieron cargar las tareas locales.',
                    onRetry: _reloadStream,
                  );
                }

                final tasks = snapshot.data ?? [];

                if (tasks.isEmpty) {
                  return _EmptyView(
                    message: 'Aún no hay tareas registradas.',
                    actionLabel: 'Crear primera tarea',
                    onAction: _openCreateTaskDialog,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final task = tasks[index];

                    return TaskTile(
                      task: task,
                      onToggle: () => _toggleTask(task),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  final String message;

  const _LoadingView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyView({required this.message, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 56),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
