import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/auth/welcome_screen.dart';
import 'shell/role_shell.dart';
import 'providers/theme_provider.dart';
import 'models/app_user.dart';
import 'services/user_storage_service.dart';
import 'widgets/onboarding_welcome_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Comprobar si hay sesión guardada al arrancar
  final savedUser = await UserStorageService.loadSession();

  runApp(ProviderScope(child: CanteraApp(loggedInUser: savedUser)));
}

class CanteraApp extends ConsumerWidget {
  final RegisteredUser? loggedInUser;
  const CanteraApp({super.key, this.loggedInUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    // Si hay sesión guardada, navegar directo al rol correspondiente
    Widget home;
    if (loggedInUser != null) {
      final appUser = loggedInUser!.toAppUser();
      // Registrar en el provider después de que el árbol esté listo
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(sessionProvider.notifier).login(appUser);
      });
      home = OnboardingWelcomeOverlay(
        child: RoleShell(role: loggedInUser!.role),
      );
    } else {
      home = const WelcomeScreen();
    }

    return MaterialApp(
      title: 'Cantera',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      darkTheme: _buildDarkTheme(),
      theme: _buildLightTheme(),
      home: home,
    );
  }

  ThemeData _buildDarkTheme() => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      surface: Colors.black,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0A0A0A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white54),
      ),
      hintStyle: const TextStyle(color: Colors.white24),
      labelStyle: const TextStyle(color: Colors.white54),
    ),
  );

  ThemeData _buildLightTheme() => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1C1C1E),
      surface: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1C1C1E)),
      ),
      hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
      labelStyle: const TextStyle(color: Color(0xFF8E8E93)),
    ),
  );
}
