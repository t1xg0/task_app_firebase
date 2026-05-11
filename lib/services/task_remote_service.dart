import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_model.dart';
import 'app_logger.dart';

enum QaRemoteFailure { none, permissionDenied, network, unexpected }

/// Lightweight exception used to simulate network failures in QA flows.
class QaNetworkException implements Exception {
  final String message;

  const QaNetworkException(this.message);

  @override
  String toString() {
    return 'QaNetworkException: $message';
  }
}

/// Firestore adapter for reading and writing remote task records.
class TaskRemoteService {
  final CollectionReference<Map<String, dynamic>> _tasksRef = FirebaseFirestore
      .instance
      .collection('tasks');

  QaRemoteFailure _nextFailure = QaRemoteFailure.none;

  void simulatePermissionDeniedOnce() {
    _nextFailure = QaRemoteFailure.permissionDenied;
  }

  void simulateNetworkErrorOnce() {
    _nextFailure = QaRemoteFailure.network;
  }

  void simulateUnexpectedErrorOnce() {
    _nextFailure = QaRemoteFailure.unexpected;
  }

  /// Throws one queued QA failure, then resets the queue for the next call.
  void _throwFailureIfNeeded() {
    final failure = _nextFailure;
    _nextFailure = QaRemoteFailure.none;

    if (failure == QaRemoteFailure.permissionDenied) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'Missing or insufficient permissions.',
      );
    }

    if (failure == QaRemoteFailure.network) {
      throw const QaNetworkException(
        'Simulación QA: no hay conexión a internet.',
      );
    }

    if (failure == QaRemoteFailure.unexpected) {
      throw StateError(
        'Simulación QA: error inesperado en el servicio remoto.',
      );
    }
  }

  Future<void> upsertTask(TaskModel task) async {
    if (task.id == null) {
      AppLogger.warning('No se puede sincronizar una tarea sin id local');
      return;
    }

    AppLogger.debug('Intentando guardar tarea en Firebase: ${task.id}');

    _throwFailureIfNeeded();

    try {
      await _tasksRef.doc(task.id.toString()).set(task.toFirestore());

      AppLogger.info('Tarea guardada en Firebase: ${task.id}');
    } on FirebaseException catch (error, stackTrace) {
      AppLogger.error(
        'FirebaseException guardando tarea remota',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } on QaNetworkException catch (error, stackTrace) {
      AppLogger.error(
        'Error de red simulado guardando tarea remota',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error inesperado guardando tarea remota',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<List<TaskModel>> fetchTasks() async {
    AppLogger.debug('Consultando tareas desde Firebase');

    _throwFailureIfNeeded();

    try {
      final snapshot = await _tasksRef.get();

      AppLogger.info(
        'Tareas obtenidas desde Firebase: ${snapshot.docs.length}',
      );

      return snapshot.docs.map((doc) {
        return TaskModel.fromFirestore(doc.data(), id: int.parse(doc.id));
      }).toList();
    } on FirebaseException catch (error, stackTrace) {
      AppLogger.error(
        'FirebaseException consultando tareas remotas',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } on QaNetworkException catch (error, stackTrace) {
      AppLogger.error(
        'Error de red simulado consultando tareas remotas',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error inesperado consultando tareas remotas',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
