import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_user.dart';
import '../../models/user_role.dart';
import '../../providers/theme_provider.dart';
import '../../services/user_storage_service.dart';
import '../../shell/role_shell.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final UserRole? preselectedRole;
  const LoginScreen({super.key, this.preselectedRole});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _showPass = false;
  String? _errorMsg;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    try {
      final user = await UserStorageService.login(
        _emailCtrl.text,
        _passCtrl.text,
      );
      await UserStorageService.saveSession(user.id);

      // Convertir RegisteredUser → AppUser para el provider de sesión
      // Growth Hacker: Simulamos el Daily Login Streak dando +1 SC al iniciar sesión
      final appUser = user.toAppUser();
      ref.read(sessionProvider.notifier).login(appUser);

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => RoleShell(role: user.role)),
        (_) => false,
      );
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMsg = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: text),
        title: Text(
          'Iniciar sesión',
          style: TextStyle(color: muted, fontSize: 14, letterSpacing: 0.5),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido\nde vuelta.',
                  style: TextStyle(
                    color: text,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 48),

                _Field(
                  label: 'Correo electrónico',
                  ctrl: _emailCtrl,
                  isDark: isDark,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Correo inválido'
                      : null,
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'Contraseña',
                  ctrl: _passCtrl,
                  isDark: isDark,
                  obscure: !_showPass,
                  suffix: IconButton(
                    icon: Icon(
                      _showPass ? Icons.visibility_off : Icons.visibility,
                      color: muted,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _showPass = !_showPass),
                  ),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Mínimo 6 caracteres'
                      : null,
                ),

                if (_errorMsg != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMsg!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 48),

                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: _loading ? null : _login,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 58,
                      decoration: BoxDecoration(
                        color: _loading
                            ? AppColors.surface(isDark)
                            : AppColors.buttonBg(isDark),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.center,
                      child: _loading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.buttonFg(isDark),
                              ),
                            )
                          : Text(
                              'ENTRAR',
                              style: TextStyle(
                                color: AppColors.buttonFg(isDark),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            RegisterScreen(role: widget.preselectedRole),
                      ),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: '¿Sin cuenta? ',
                        style: TextStyle(color: muted, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Regístrate',
                            style: TextStyle(
                              color: text,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
}

// ── Campo compartido ──────────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final bool isDark, obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const _Field({
    required this.label,
    required this.ctrl,
    required this.isDark,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final text = AppColors.text(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);

    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: text, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: surface,
        suffixIcon: suffix,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: text.withOpacity(0.5)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        labelStyle: TextStyle(color: AppColors.textMuted(isDark)),
      ),
    );
  }
}
