import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';
import '../utils/unique_id_generator.dart';

/// Usuario registrado serializable a JSON para almacenamiento local.
class RegisteredUser {
  final String id;
  final String name;
  final String email;
  final String
  password; // en demo/beta: texto plano. En producción: hash + Supabase Auth
  final String uniqueId;
  final UserRole role;
  final String extraField;
  final DateTime createdAt;

  RegisteredUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.uniqueId,
    required this.role,
    required this.extraField,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'uniqueId': uniqueId,
    'role': role.name,
    'extraField': extraField,
    'createdAt': createdAt.toIso8601String(),
  };

  factory RegisteredUser.fromJson(Map<String, dynamic> j) => RegisteredUser(
    id: j['id'],
    name: j['name'],
    email: j['email'],
    password: j['password'],
    uniqueId: j['uniqueId'],
    role: UserRole.values.firstWhere((r) => r.name == j['role']),
    extraField: j['extraField'] ?? '',
    createdAt: DateTime.parse(j['createdAt']),
  );

  /// Convierte el usuario guardado a un AppUser en memoria.
  AppUser toAppUser() {
    Map<String, dynamic> extra = {};
    if (extraField.startsWith('{')) {
      try {
        extra = jsonDecode(extraField);
      } catch (_) {}
    }
    return AppUser(
      id: id,
      uniqueId: uniqueId,
      role: role,
      name: name,
      sportcoins: 0.0,
      dailyLoginStreak: 1,
      location: extra['location'],
      bio: extra['bio'],
    );
  }
}

/// Servicio de almacenamiento local de usuarios usando shared_preferences.
class UserStorageService {
  static const _usersKey = 'sl_registered_users';
  static const _sessionKey = 'sl_session_id';

  /// Devuelve todos los usuarios registrados.
  static Future<List<RegisteredUser>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_usersKey) ?? [];
    return raw.map((s) => RegisteredUser.fromJson(jsonDecode(s))).toList();
  }

  /// Registra un nuevo usuario. Lanza excepción si el email ya existe.
  static Future<RegisteredUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String extraField,
  }) async {
    final all = await getAll();
    final existing = all.where(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
    if (existing.isNotEmpty) throw Exception('Este correo ya está registrado.');

    final newUser = RegisteredUser(
      id: 'u${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim().toLowerCase(),
      password: password,
      uniqueId: UniqueIdGenerator.generate(
        UniqueIdGenerator.getPrefixForRole(role.name),
      ),
      role: role,
      extraField: extraField.trim(),
      createdAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    final updated = [
      ...all.map((u) => jsonEncode(u.toJson())),
      jsonEncode(newUser.toJson()),
    ];
    await prefs.setStringList(_usersKey, updated);
    return newUser;
  }

  /// Intenta hacer login. Lanza excepción si no encuentra el usuario.
  static Future<RegisteredUser> login(String email, String password) async {
    final all = await getAll();
    try {
      return all.firstWhere(
        (u) => u.email == email.trim().toLowerCase() && u.password == password,
      );
    } catch (_) {
      throw Exception('Correo o contraseña incorrectos.');
    }
  }

  /// Guarda el ID del usuario activo (sesión persistente).
  static Future<void> saveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, userId);
  }

  /// Carga el usuario de la sesión activa, si existe.
  static Future<RegisteredUser?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_sessionKey);
    if (id == null) return null;
    final all = await getAll();
    try {
      return all.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Cierra la sesión actual.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  /// Actualiza los campos de un usuario.
  static Future<void> updateProfile({
    required String id,
    String? name,
    String? location,
    String? bio,
  }) async {
    final all = await getAll();
    final idx = all.indexWhere((u) => u.id == id);
    if (idx == -1) return;

    final u = all[idx];

    // Parse current extraField as JSON if possible, or create a new map
    Map<String, dynamic> extra = {};
    if (u.extraField.startsWith('{')) {
      try {
        extra = jsonDecode(u.extraField);
      } catch (_) {}
    }

    if (location != null) extra['location'] = location;
    if (bio != null) extra['bio'] = bio;

    final updatedUser = RegisteredUser(
      id: u.id,
      name: name ?? u.name,
      email: u.email,
      password: u.password,
      uniqueId: u.uniqueId,
      role: u.role,
      extraField: jsonEncode(extra),
      createdAt: u.createdAt,
    );

    all[idx] = updatedUser;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _usersKey,
      all.map((u) => jsonEncode(u.toJson())).toList(),
    );
  }
}
