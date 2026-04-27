import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'data/app_database.dart';
import 'firebase_options.dart';
import 'pages/tasks_page.dart';
import 'services/app_logger.dart';
import 'services/task_remote_service.dart';
import 'services/task_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runZonedGuarded(
    () async {
      AppLogger.info('Inicializando TaskSync RC');

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      AppLogger.info('Firebase inicializado correctamente');

      final database = AppDatabase();
      final remoteService = TaskRemoteService();
      final repository = TaskRepository(
        localDb: database,
        remoteService: remoteService,
      );

      runApp(MyApp(repository: repository));
    },
    (error, stackTrace) {
      AppLogger.error(
        'Error global no controlado',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}

class MyApp extends StatelessWidget {
  final TaskRepository repository;

  const MyApp({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('Construyendo MyApp');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskSync RC',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: TasksPage(repository: repository),
    );
  }
}