import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportlink_pro/services/user_storage_service.dart';
import 'package:sportlink_pro/models/user_role.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Registration creates user with hashed password', () async {
    final user = await UserStorageService.register(
      name: 'Test User',
      email: 'test@example.com',
      password: 'password123',
      role: UserRole.player,
      extraField: 'STR',
    );
    
    expect(user.name, 'Test User');
    expect(user.email, 'test@example.com');
    // Ensure the password is not stored in plaintext
    expect(user.password, isNot('password123'));
    // SHA-256 hash length is 64 characters
    expect(user.password.length, 64);
    
    // Attempt Login to verify authentication works with the hashed password
    final loggedInUser = await UserStorageService.login('test@example.com', 'password123');
    expect(loggedInUser.id, user.id);
  });
  
  test('Login with wrong password throws exception', () async {
    await UserStorageService.register(
      name: 'Test User 2',
      email: 'test2@example.com',
      password: 'mypassword',
      role: UserRole.coach,
      extraField: 'FC Team',
    );
    
    expect(
      () => UserStorageService.login('test2@example.com', 'wrongpassword'),
      throwsException,
    );
  });
}
