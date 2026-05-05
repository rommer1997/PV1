import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/app_user.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/welcome_screen.dart';
import 'services/user_storage_service.dart';
import 'shell/role_shell.dart';
import 'widgets/onboarding_welcome_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final savedUser = await UserStorageService.loadSession();

  runApp(ProviderScope(child: CanteraApp(loggedInUser: savedUser)));
}

class CanteraApp extends ConsumerWidget {
  final RegisteredUser? loggedInUser;
  const CanteraApp({super.key, this.loggedInUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    Widget home;
    if (loggedInUser != null) {
      final appUser = loggedInUser!.toAppUser();
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

  ThemeData _buildDarkTheme() {
    const surface = Color(0xFF0F1115);
    const card = Color(0xFF161A23);
    const outline = Color(0xFF2C3444);

    final base = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surface,
      fontFamily: 'Inter',
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF7C9BFF),
        secondary: Color(0xFF42E0C1),
        surface: surface,
        error: Color(0xFFFF6B7A),
      ),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: outline, width: 1),
        ),
      ),
      inputDecorationTheme: _buildInputTheme(
        fillColor: card,
        borderColor: outline,
        focusColor: const Color(0xFF7C9BFF),
        hintColor: Colors.white38,
        labelColor: Colors.white70,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: const Color(0xFF7C9BFF),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          foregroundColor: Colors.white,
          side: const BorderSide(color: outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    const surface = Color(0xFFF4F6FB);
    const card = Colors.white;
    const outline = Color(0xFFE1E7F3);

    final base = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: surface,
      fontFamily: 'Inter',
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF2D4EF5),
        secondary: Color(0xFF13B89A),
        surface: surface,
        error: Color(0xFFDD3F55),
      ),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: Color(0xFF151A24),
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: outline, width: 1),
        ),
      ),
      inputDecorationTheme: _buildInputTheme(
        fillColor: card,
        borderColor: outline,
        focusColor: const Color(0xFF2D4EF5),
        hintColor: const Color(0xFF6D7587),
        labelColor: const Color(0xFF5C6373),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: const Color(0xFF2D4EF5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          foregroundColor: const Color(0xFF151A24),
          side: const BorderSide(color: outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  InputDecorationTheme _buildInputTheme({
    required Color fillColor,
    required Color borderColor,
    required Color focusColor,
    required Color hintColor,
    required Color labelColor,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: focusColor, width: 1.4),
      ),
      hintStyle: TextStyle(color: hintColor),
      labelStyle: TextStyle(color: labelColor),
    );
  }
}
