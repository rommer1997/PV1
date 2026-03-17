import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_user.dart';
import '../../providers/theme_provider.dart';
import '../../services/user_storage_service.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _bioCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(sessionProvider);
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _cityCtrl = TextEditingController(text: user?.location ?? '');
    _bioCtrl = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(sessionProvider);
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // 1. Guardar en almacenamiento local
      await UserStorageService.updateProfile(
        id: user.id,
        name: _nameCtrl.text.trim(),
        location: _cityCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
      );

      // 2. Actualizar estado en memoria
      final updatedUser = AppUser(
        id: user.id,
        uniqueId: user.uniqueId,
        role: user.role,
        name: _nameCtrl.text.trim(),
        sportcoins: user.sportcoins,
        isMinor: user.isMinor,
        dailyLoginStreak: user.dailyLoginStreak,
        isPubliclyVisible: user.isPubliclyVisible,
        followersCount: user.followersCount,
        followingCount: user.followingCount,
        isVerified: user.isVerified,
        location: _cityCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
      );

      ref.read(sessionProvider.notifier).login(updatedUser);

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Perfil actualizado con éxito!'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          'Editar Perfil',
          style: TextStyle(
            color: text,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.surface(isDark),
                      child: Icon(Icons.person, size: 50, color: muted),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF4CA25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Datos Personales',
                style: TextStyle(
                  color: text,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameCtrl,
                style: TextStyle(color: text),
                decoration: InputDecoration(
                  labelText: 'Nombre Completo',
                  labelStyle: TextStyle(color: muted),
                  prefixIcon: Icon(Icons.badge_outlined, color: muted),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _cityCtrl,
                style: TextStyle(color: text),
                decoration: InputDecoration(
                  labelText: 'Ciudad',
                  labelStyle: TextStyle(color: muted),
                  prefixIcon: Icon(Icons.location_city, color: muted),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _bioCtrl,
                style: TextStyle(color: text),
                maxLines: 3,
                maxLength: 150,
                decoration: InputDecoration(
                  labelText: 'Biografía Deportiva',
                  labelStyle: TextStyle(color: muted),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBg(isDark),
                    foregroundColor: AppColors.buttonFg(isDark),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Guardar Cambios',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
