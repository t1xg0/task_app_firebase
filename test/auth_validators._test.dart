import 'package:flutter_test/flutter_test.dart';
import 'package:task_app_firebase/validators/auth_validators.dart';

void main() {
  // These tests keep validation rules documented outside the UI, so the login
  // form can stay small and still rely on predictable messages.
  group('AuthValidators.validateEmail', () {
    test('returns an error when the email is empty', () {
      // Empty input should stop auth before any Firebase call is attempted.
      final result = AuthValidators.validateEmail('');

      expect(result, 'El correo es obligatorio');
    });

    test('returns an error when the email is missing @', () {
      // The app intentionally uses a simple classroom-friendly email check.
      final result = AuthValidators.validateEmail('estudiantedemo.com');

      expect(result, 'Ingrese un correo válido');
    });

    test('returns null when the email is valid', () {
      final result = AuthValidators.validateEmail('estudiante@demo.com');

      expect(result, isNull);
    });
  });

  group('AuthValidators.validatePassword', () {
    test('returns an error when the password is empty', () {
      // Empty passwords should surface a direct required-field message.
      final result = AuthValidators.validatePassword('');

      expect(result, 'La contraseña es obligatoria');
    });

    test('returns an error when the password is shorter than 6 characters', () {
      // Firebase Auth requires at least six characters for email/password users.
      final result = AuthValidators.validatePassword('123');

      expect(result, 'La contraseña debe tener mínimo 6 caracteres');
    });

    test('returns null when the password is valid', () {
      final result = AuthValidators.validatePassword('123456');

      expect(result, isNull);
    });
  });
}
