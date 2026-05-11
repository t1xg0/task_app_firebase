// Crash reporting facade selected at compile time.
//
// Web builds use the stub because Firebase Crashlytics is not available there.
// Native builds use the Firebase Crashlytics implementation.
export 'stub_crash_service.dart'
    if (dart.library.io) 'firebase_crash_service.dart';
