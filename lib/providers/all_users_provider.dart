import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../services/user_storage_service.dart';

final allUsersProvider = FutureProvider.autoDispose<List<AppUser>>((ref) async {
  final regUsers = await UserStorageService.getAll();
  final memUsers = regUsers.map((u) => u.toAppUser()).toList();

  // Evitar duplicados por uniqueId si hubiera
  final Map<String, AppUser> uniqueMap = {};
  for (final u in mockUsers.values) {
    uniqueMap[u.uniqueId] = u;
  }
  for (final u in memUsers) {
    uniqueMap[u.uniqueId] = u; // Memoria local tiene prioridad
  }

  return uniqueMap.values.toList();
});
