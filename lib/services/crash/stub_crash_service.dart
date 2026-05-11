import '../app_logger.dart';

/// Keeps the Crashlytics API available on platforms where it is not enabled.
Future<void> configureCrashReporting() async {
  AppLogger.warning(
    'Crashlytics no está activo en Web. Se usará CrashService stub.',
  );
}

/// Logs zone errors locally when Crashlytics is unavailable.
Future<void> recordFatalZoneError(Object error, StackTrace stackTrace) async {
  AppLogger.error(
    'Error global capturado en Web/STUB',
    error: error,
    stackTrace: stackTrace,
  );
}

/// No-op Crashlytics facade used by web and unsupported platforms.
class CrashService {
  const CrashService();

  Future<void> log(String message) async {
    AppLogger.info('[CrashService WEB/STUB] $message');
  }

  Future<void> recordNonFatal(
    Object error,
    StackTrace stackTrace, {
    String? reason,
  }) async {
    AppLogger.error(
      reason ?? '[CrashService WEB/STUB] Error no fatal',
      error: error,
      stackTrace: stackTrace,
    );
  }

  Future<void> recordFatal(
    Object error,
    StackTrace stackTrace, {
    String? reason,
  }) async {
    AppLogger.error(
      reason ?? '[CrashService WEB/STUB] Error fatal',
      error: error,
      stackTrace: stackTrace,
    );
  }

  Future<void> setUserIdentifier(String userId) async {
    AppLogger.info('[CrashService WEB/STUB] Usuario activo: $userId');
  }

  /// Exercises the same QA path as mobile without sending data to Crashlytics.
  Future<void> simulateNonFatalError() async {
    try {
      throw Exception('Error controlado de prueba en TaskApp Web/STUB');
    } catch (error, stackTrace) {
      await recordNonFatal(
        error,
        stackTrace,
        reason: 'Simulación de error no fatal en Web/STUB',
      );
    }
  }

  /// Avoids crashing unsupported builds while still confirming the menu works.
  void simulateFatalCrash() {
    AppLogger.warning(
      'Crash fatal no ejecutado en Web porque Crashlytics no está disponible allí.',
    );
  }
}
