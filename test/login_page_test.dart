import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_app_firebase/pages/login_page.dart';
import 'package:task_app_firebase/services/auth_service.dart';

/// Minimal auth fake used to keep widget tests independent from Firebase.
///
/// The current tests only verify validation errors, so each auth method can be
/// a no-op. If a future test needs to assert a real submit, this fake can store
/// the received email/password or throw a controlled FirebaseAuthException.
class FakeAuthService implements AuthService {
  @override
  Stream<User?> authStateChanges() {
    return Stream<User?>.value(null);
  }

  @override
  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('LoginPage shows an error when submitting without an email', (
    tester,
  ) async {
    // Arrange: render the page inside MaterialApp so form fields, buttons, and
    // Material localization behave like they do in the real app.
    await tester.pumpWidget(
      MaterialApp(home: LoginPage(authService: FakeAuthService())),
    );

    // Act: submit the untouched form.
    await tester.tap(find.text('Ingresar'));
    await tester.pump();

    // Assert: the email validator should block the submit before auth runs.
    expect(find.text('El correo es obligatorio'), findsOneWidget);
  });

  testWidgets('LoginPage shows an error when the password is empty', (
    tester,
  ) async {
    // Arrange: render a fresh login form for this scenario.
    await tester.pumpWidget(
      MaterialApp(home: LoginPage(authService: FakeAuthService())),
    );

    // Act: provide only the email and submit the form.
    await tester.enterText(
      find.byType(TextFormField).first,
      'estudiante@demo.com',
    );

    await tester.tap(find.text('Ingresar'));
    await tester.pump();

    // Assert: the password validator should show the localized helper text.
    expect(find.text('La contraseña es obligatoria'), findsOneWidget);
  });
}
