import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:cantera_pro/models/user_role.dart';
import 'package:cantera_pro/services/user_storage_service.dart';

void main() {
  test('RegisteredUser.toAppUser parses extra fields correctly', () {
    final extra = jsonEncode({'location': 'Madrid', 'bio': 'Striker'});
    final regUser = RegisteredUser(
      id: '123',
      name: 'Test Player',
      email: 'test@example.com',
      password: 'hashed_password',
      uniqueId: 'SLP-PLAYER-1234',
      role: UserRole.player,
      extraField: extra,
      createdAt: DateTime.now(),
    );
    
    final appUser = regUser.toAppUser();
    expect(appUser.id, '123');
    expect(appUser.role, UserRole.player);
    expect(appUser.name, 'Test Player');
    expect(appUser.location, 'Madrid');
    expect(appUser.bio, 'Striker');
  });
}
