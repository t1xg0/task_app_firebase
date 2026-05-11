import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'data/app_database.dart';
import 'firebase_options.dart';
import 'pages/auth_gate.dart';
import 'services/app_logger.dart';
import 'services/auth_service.dart';
import 'services/crash/crash_service.dart';
import 'services/task_remote_service.dart';
import 'services/task_repository.dart';

/// Boots Firebase, Crashlytics, local storage, and the shared app services.
Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      AppLogger.info('Inicializando TaskSync RC');

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      AppLogger.info('Firebase inicializado correctamente');

      await configureCrashReporting();

      AppLogger.info('Monitoreo de errores configurado');

      final database = AppDatabase();

      AppLogger.info('Base de datos local inicializada');

      final remoteService = TaskRemoteService();

      AppLogger.info('Servicio remoto inicializado');

      final repository = TaskRepository(
        localDb: database,
        remoteService: remoteService,
      );

      AppLogger.info('Repositorio de tareas inicializado');

      runApp(
        MyApp(
          repository: repository,
          authService: FirebaseAuthService(),
          crashService: const CrashService(),
        ),
      );
    },
    (error, stackTrace) {
      // Keep the global zone as the last safety net for uncaught async errors.
      AppLogger.error(
        'Error global no controlado',
        error: error,
        stackTrace: stackTrace,
      );

      unawaited(recordFatalZoneError(error, stackTrace));
    },
  );
}

/// Root widget that wires the app-level dependencies into the UI tree.
class MyApp extends StatelessWidget {
  final TaskRepository repository;
  final AuthService authService;
  final CrashService crashService;

  const MyApp({
    super.key,
    required this.repository,
    required this.authService,
    required this.crashService,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('Construyendo MyApp');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskSync RC',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: AuthGate(
        authService: authService,
        crashService: crashService,
        repository: repository,
      ),
    );
  }
}
