import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_role.dart';
import '../../models/app_user.dart';
import '../../shell/role_shell.dart';
import '../../providers/theme_provider.dart';
import '../../services/user_storage_service.dart';

class RegisterScreen extends StatefulWidget {
  final UserRole? role;
  const RegisterScreen({super.key, this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _extraCtrl = TextEditingController();
  final _tutorCtrl = TextEditingController();
  
  UserRole _selectedRole = UserRole.player;
  bool _isLoading = false;
  bool _showPass = false;
  String? _errorMsg;

  String _selectedAgeGroup = '+21 años';
  final List<String> _ageGroups = ['10-14 años', '15-17 años', '18-20 años', '+21 años'];
  String _selectedPosition = 'DEL';

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.role ?? UserRole.player;
  }

  String get _extraLabel {
    switch (_selectedRole) {
      case UserRole.scout: return 'Número de Licencia Scout (KYC)';
      case UserRole.referee: return 'ID de Árbitro Oficial';
      case UserRole.coach: return 'Club o Academia';
      case UserRole.journalist: return 'Medio de Comunicación';
      case UserRole.brand: return 'Nombre de la Empresa';
      case UserRole.tutor: return 'DNI / Documento del Tutor';
      case UserRole.player: return 'Posición en el campo';
      case UserRole.fan: return 'Ciudad (opcional)';
      case UserRole.staff: return 'Código de Administrador';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final bool requiresTutor = _selectedAgeGroup == '10-14 años' || _selectedAgeGroup == '15-17 años';
    if (requiresTutor) {
      final tCode = _tutorCtrl.text.trim().toUpperCase();
      if (!tCode.startsWith('TUTOR-') || tCode.length != 10) {
        setState(() => _errorMsg = 'Código de tutor inválido. Formato: TUTOR-XXXX');
        return;
      }
      final nums = tCode.substring(6); // Obtiene los 4 dígitos
      int sum = 0;
      for (int i=0; i<nums.length; i++) {
        sum += int.tryParse(nums.substring(i, i+1)) ?? -999;
      }
      if (sum != 15) {
        setState(() => _errorMsg = 'Código de tutor denegado. (Algoritmo checksum)');
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final Map<String, dynamic> extraData = {
      'ageGroup': _selectedAgeGroup,
    };
    if (requiresTutor) {
      extraData['tutorDni'] = _tutorCtrl.text.trim();
    }
    if (_selectedRole == UserRole.player) {
      extraData['position'] = _selectedPosition;
    } else if (_selectedRole != UserRole.fan) {
      extraData['extraData'] = _extraCtrl.text.trim();
    }

    try {
      final user = await UserStorageService.register(
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        password: _passCtrl.text,
        role: _selectedRole,
        extraField: jsonEncode(extraData),
      );
      await UserStorageService.saveSession(user.id);

      final appUser = user.toAppUser();

      if (!mounted) return;
      final ref = ProviderScope.containerOf(context);
      ref.read(sessionProvider.notifier).login(appUser);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => RoleShell(role: user.role)),
        (_) => false,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMsg = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final container = ProviderScope.containerOf(context);
    final isDark = container.read(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);

    final bool requiresTutor = _selectedAgeGroup == '10-14 años' || _selectedAgeGroup == '15-17 años';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: text),
        title: Text(
          'Crear cuenta',
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
                  'Elige tu\nperfil.',
                  style: TextStyle(
                    color: text,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 32),

                if (widget.role == null) ...[
                  Text(
                    'ROL',
                    style: TextStyle(
                      color: muted,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface(isDark),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border(isDark)),
                    ),
                    child: DropdownButton<UserRole>(
                      value: _selectedRole,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      dropdownColor: AppColors.surface(isDark),
                      style: TextStyle(color: text, fontSize: 15, fontFamily: 'Inter'),
                      onChanged: (r) => setState(() => _selectedRole = r!),
                      items: UserRole.values
                          .map((r) => DropdownMenuItem(value: r, child: Text('${r.emoji}  ${r.label}')))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Rango de Edad
                Text(
                  'RANGO DE EDAD',
                  style: TextStyle(color: muted, fontSize: 10, letterSpacing: 2),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _ageGroups.map((age) {
                    final selected = _selectedAgeGroup == age;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAgeGroup = age),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.buttonBg(isDark) : AppColors.surface(isDark),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: selected ? AppColors.buttonBg(isDark) : AppColors.border(isDark)),
                        ),
                        child: Text(
                          age,
                          style: TextStyle(
                            color: selected ? AppColors.buttonFg(isDark) : text,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                _Field(
                  label: 'Nombre completo',
                  ctrl: _nameCtrl,
                  isDark: isDark,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 14),
                _Field(
                  label: 'Correo electrónico',
                  ctrl: _emailCtrl,
                  isDark: isDark,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    if (!v.contains('@')) return 'Correo inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _Field(
                  label: 'Contraseña',
                  ctrl: _passCtrl,
                  isDark: isDark,
                  obscure: !_showPass,
                  suffix: IconButton(
                    icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility, color: muted, size: 18),
                    onPressed: () => setState(() => _showPass = !_showPass),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 14),

                if (requiresTutor) ...[
                  _Field(
                    label: 'Documento / Email del Tutor pre-registrado',
                    ctrl: _tutorCtrl,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),
                ],

                if (_selectedRole == UserRole.player) ...[
                  Text(
                    'POSICIÓN ESTUDIADA (JUGASTE)',
                    style: TextStyle(color: muted, fontSize: 10, letterSpacing: 2),
                  ),
                  const SizedBox(height: 12),
                  _FootballFieldSelector(
                    selectedPosition: _selectedPosition,
                    onSelected: (pos) => setState(() => _selectedPosition = pos),
                  ),
                  const SizedBox(height: 24),
                ] else if (_selectedRole != UserRole.fan) ...[
                  _Field(
                    label: _extraLabel,
                    ctrl: _extraCtrl,
                    isDark: isDark,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 14),
                ],

                if (_errorMsg != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 16),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_errorMsg!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                Text(
                  'Al registrarte aceptas los Términos de Uso y la Política de Privacidad (COPPA/RGPD).',
                  style: TextStyle(color: muted, fontSize: 11, height: 1.5),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: _isLoading ? null : _submit,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 58,
                      decoration: BoxDecoration(
                        color: _isLoading ? AppColors.surface(isDark) : AppColors.buttonBg(isDark),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.center,
                      child: _isLoading
                          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.buttonFg(isDark)))
                          : Text(
                              'CREAR CUENTA',
                              style: TextStyle(color: AppColors.buttonFg(isDark), fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2),
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
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _extraCtrl.dispose();
    _tutorCtrl.dispose();
    super.dispose();
  }
}

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
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: text, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surface(isDark),
        suffixIcon: suffix,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: text.withValues(alpha: 0.5)),
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

class _FootballFieldSelector extends StatelessWidget {
  final String selectedPosition;
  final ValueChanged<String> onSelected;

  const _FootballFieldSelector({required this.selectedPosition, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320, // Increased height for realistic vertical proportions
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          // 1. Striped Grass Background
          ...List.generate(11, (index) {
            final isDarkStripe = index % 2 == 0;
            return Positioned(
              top: index * (320 / 11),
              left: 0,
              right: 0,
              height: 320 / 11,
              child: Container(
                color: isDarkStripe ? const Color(0xFF111111) : const Color(0xFF1A1A1A),
              ),
            );
          }),

          // 2. Pitch Markings
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
              ),
              child: Stack(
                children: [
                  // Center Line
                  Center(
                    child: Container(
                      height: 1.5,
                      width: double.infinity,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  // Center Circle
                  Center(
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                      ),
                    ),
                  ),
                  // Center Dot
                  Center(
                    child: Container(
                      height: 4,
                      width: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Top Penalty Area
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 120,
                      height: 45,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                          right: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  // Bottom Penalty Area
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 120,
                      height: 45,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                          right: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                          top: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  // Top Goal Area
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 50,
                      height: 18,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                          right: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  // Bottom Goal Area
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 50,
                      height: 18,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                          right: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                          top: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Interactive Positions
          ..._buildPositionDot('DEL', 0.15, 0.5),
          ..._buildPositionDot('EXI', 0.25, 0.15), // Extremo Izq
          ..._buildPositionDot('EXD', 0.25, 0.85), // Extremo Der
          ..._buildPositionDot('MED', 0.50, 0.5),
          ..._buildPositionDot('LI', 0.72, 0.15), // Lateral Izq
          ..._buildPositionDot('DFC', 0.75, 0.5), // Central
          ..._buildPositionDot('LD', 0.72, 0.85), // Lateral Der
          ..._buildPositionDot('POR', 0.94, 0.5),
        ],
      ),
    );
  }

  List<Widget> _buildPositionDot(String pos, double yFactor, double xFactor) {
    final isSelected = selectedPosition == pos;
    final primaryColor = const Color(0xFFE2F163); // SLP Accent Lime

    return [
      Align(
        alignment: FractionalOffset(xFactor, yFactor),
        child: GestureDetector(
          onTap: () => onSelected(pos),
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                padding: EdgeInsets.all(isSelected ? 6 : 4),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor.withValues(alpha: 0.15) : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? primaryColor.withValues(alpha: 0.4) : Colors.transparent,
                      blurRadius: isSelected ? 15 : 0,
                      spreadRadius: isSelected ? 5 : 0,
                    )
                  ],
                ),
                child: Icon(
                  Icons.accessibility_new_rounded,
                  size: isSelected ? 30 : 22,
                  color: isSelected ? primaryColor : Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 6),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? primaryColor.withValues(alpha: 0.5) : Colors.transparent, width: 1),
                  ),
                  child: Text(
                    pos,
                    style: TextStyle(
                      color: isSelected ? primaryColor : Colors.white,
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }
}
