import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/crash/crash_service.dart';
import '../services/task_repository.dart';
import 'login_page.dart';
import 'tasks_page.dart';

/// Chooses between the login screen and the task list based on Firebase Auth.
class AuthGate extends StatelessWidget {
  final AuthService authService;
  final CrashService crashService;
  final TaskRepository repository;

  const AuthGate({
    super.key,
    required this.authService,
    required this.crashService,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          // Attach authenticated sessions to Crashlytics reports.
          unawaited(crashService.setUserIdentifier(user.uid));

          return TasksPage(
            repository: repository,
            user: user,
            authService: authService,
            crashService: crashService,
          );
        }

        return LoginPage(authService: authService);
      },
    );
  }
}
