import '../data/app_database.dart';
import '../models/task_model.dart';
import 'app_logger.dart';
import 'task_remote_service.dart';

class TaskRepository {
  final AppDatabase localDb;
  final TaskRemoteService remoteService;

  TaskRepository({
    required this.localDb,
    required this.remoteService,
  });

  Stream<List<TaskModel>> watchTasks() {
    AppLogger.debug('Escuchando tareas desde Drift');
    return localDb.watchTasks();
  }

  Future<void> loadInitialData() async {
    AppLogger.info('Cargando datos iniciales');

    await refreshFromRemote();
    await syncPendingTasks();
  }

  Future<void> addTask({
    required String title,
    required String description,
  }) async {
    AppLogger.info('Intentando crear tarea local');

    final localTask = TaskModel(
      title: title,
      description: description,
      completed: false,
      updatedAt: DateTime.now(),
      pendingSync: true,
    );

    final insertedTask = await localDb.insertTask(localTask);

    AppLogger.info(
      'Tarea creada localmente con id: ${insertedTask.id}',
    );

    try {
      await remoteService.upsertTask(insertedTask);

      if (insertedTask.id != null) {
        await localDb.markAsSynced(insertedTask.id!);
        AppLogger.info(
          'Tarea marcada como sincronizada: ${insertedTask.id}',
        );
      }
    } catch (error, stackTrace) {
      AppLogger.warning(
        'La tarea quedó guardada localmente, pero pendiente de sincronización',
      );

      AppLogger.error(
        'Error sincronizando nueva tarea con Firebase',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> toggleTask(TaskModel task) async {
    if (task.id == null) {
      AppLogger.warning(
        'No se puede cambiar estado de una tarea sin id',
      );
      return;
    }

    AppLogger.info('Cambiando estado local de tarea: ${task.id}');

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

      AppLogger.info(
        'Cambio de tarea sincronizado con Firebase: ${task.id}',
      );
    } catch (error, stackTrace) {
      AppLogger.warning(
        'El cambio quedó local, pero pendiente de sincronización',
      );

      AppLogger.error(
        'Error sincronizando cambio de tarea con Firebase',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> refreshFromRemote() async {
    AppLogger.info('Refrescando tareas desde Firebase');

    try {
      final remoteTasks = await remoteService.fetchTasks();

      for (final task in remoteTasks) {
        await localDb.upsertFromRemote(task);
      }

      AppLogger.info(
        'Refresco remoto finalizado. Tareas procesadas: ${remoteTasks.length}',
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error obteniendo tareas desde Firebase',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> syncPendingTasks() async {
    AppLogger.info('Sincronizando tareas pendientes');

    final pendingTasks = await localDb.getPendingTasks();

    AppLogger.info(
      'Tareas pendientes por sincronizar: ${pendingTasks.length}',
    );

    for (final task in pendingTasks) {
      try {
        await remoteService.upsertTask(task);

        if (task.id != null) {
          await localDb.markAsSynced(task.id!);

          AppLogger.info(
            'Tarea pendiente sincronizada: ${task.id}',
          );
        }
      } catch (error, stackTrace) {
        AppLogger.error(
          'Error sincronizando tarea pendiente: ${task.id}',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  Future<void> qaCreateTaskWithPermissionDenied() async {
    AppLogger.info('QA: simulando permission-denied en la siguiente sincronización');

    remoteService.simulatePermissionDeniedOnce();

    await addTask(
      title: 'QA - Permission denied',
      description: 'Esta tarea simula un error de permisos en Firebase.',
    );
  }

  Future<void> qaCreateTaskWithNetworkError() async {
    AppLogger.info('QA: simulando error de red en la siguiente sincronización');

    remoteService.simulateNetworkErrorOnce();

    await addTask(
      title: 'QA - Sin conexión',
      description: 'Esta tarea simula un fallo de red durante la sincronización.',
    );
  }

  Future<void> qaCreateTaskWithUnexpectedError() async {
    AppLogger.info('QA: simulando error inesperado en la siguiente sincronización');

    remoteService.simulateUnexpectedErrorOnce();

    await addTask(
      title: 'QA - Error inesperado',
      description: 'Esta tarea simula un error inesperado del servicio remoto.',
    );
  }

  Future<void> qaCreateLongTextTask() async {
    AppLogger.info('QA: creando tarea con texto largo');

    await addTask(
      title:
          'QA - Esta es una tarea con un título extremadamente largo para validar que la tarjeta no genere overflow visual ni rompa el diseño de la lista',
      description:
          'Descripción larga usada para probar cómo se comporta la interfaz ante datos extremos.',
    );
  }

  Future<void> qaSimulateSlowOperation() async {
    AppLogger.info('QA: simulando operación lenta');

    await Future.delayed(const Duration(seconds: 3));

    AppLogger.info('QA: operación lenta finalizada');
  }

  Future<void> qaThrowUnexpectedUiError() async {
    AppLogger.info('QA: lanzando error inesperado para validar logs');

    throw StateError(
      'QA: error inesperado simulado desde una acción de usuario.',
    );
  }
}