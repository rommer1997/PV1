import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_user.dart';
import '../../models/user_role.dart';
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
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _instagramCtrl;
  late TextEditingController _twitterCtrl;
  
  // Specific role fields
  String? _ageGroup;
  String? _position;
  String? _strongFoot;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _currentTeamCtrl;
  late TextEditingController _coachLicenseCtrl;
  late TextEditingController _scoutAgencyCtrl;
  late TextEditingController _refereeCertCtrl;
  late TextEditingController _journalistMediaCtrl;
  late TextEditingController _brandCompanyCtrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(sessionProvider);
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _cityCtrl = TextEditingController(text: user?.location ?? '');
    _bioCtrl = TextEditingController(text: user?.bio ?? '');
    _emailCtrl = TextEditingController(text: ''); // Mock
    _phoneCtrl = TextEditingController(text: ''); // Mock
    _instagramCtrl = TextEditingController(text: '');
    _twitterCtrl = TextEditingController(text: '');
    
    _ageGroup = user?.ageGroup;
    _position = user?.position;
    _strongFoot = 'Diestro';
    _heightCtrl = TextEditingController();
    _weightCtrl = TextEditingController();
    _currentTeamCtrl = TextEditingController();
    _coachLicenseCtrl = TextEditingController();
    _scoutAgencyCtrl = TextEditingController();
    _refereeCertCtrl = TextEditingController();
    _journalistMediaCtrl = TextEditingController();
    _brandCompanyCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _bioCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _instagramCtrl.dispose();
    _twitterCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _currentTeamCtrl.dispose();
    _coachLicenseCtrl.dispose();
    _scoutAgencyCtrl.dispose();
    _refereeCertCtrl.dispose();
    _journalistMediaCtrl.dispose();
    _brandCompanyCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(sessionProvider);
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final extraFields = <String, dynamic>{
        'location': _cityCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
      };
      if (user.role == UserRole.player) {
        if (_ageGroup != null) extraFields['ageGroup'] = _ageGroup;
        if (_position != null) extraFields['position'] = _position;
      }

      await UserStorageService.updateProfile(
        id: user.id,
        name: _nameCtrl.text.trim(),
        extraFields: extraFields,
      );

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
        ageGroup: _ageGroup ?? user.ageGroup,
        position: _position ?? user.position,
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

  Widget _buildSectionTitle(String title, Color text) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          color: text,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, Color text, Color muted, {int maxLines = 1, int? maxLength}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: text),
        maxLines: maxLines,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: muted),
          prefixIcon: Icon(icon, color: muted),
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final user = ref.read(sessionProvider);

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
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              
              _buildSectionTitle('Información Básica', text),
              _buildTextField(_nameCtrl, 'Nombre Completo / Usuario', Icons.badge_outlined, text, muted, maxLength: 50),
              _buildTextField(_bioCtrl, 'Biografía / Descripción', Icons.description_outlined, text, muted, maxLines: 3, maxLength: 150),
              _buildTextField(_cityCtrl, 'Ubicación (Ciudad, País)', Icons.location_on_outlined, text, muted),

              _buildSectionTitle('Información de Contacto', text),
              _buildTextField(_emailCtrl, 'Correo Electrónico', Icons.email_outlined, text, muted),
              _buildTextField(_phoneCtrl, 'Teléfono (Opcional)', Icons.phone_outlined, text, muted),

              _buildSectionTitle('Redes Sociales Externas', text),
              _buildTextField(_instagramCtrl, 'Instagram Username', Icons.camera_alt_outlined, text, muted),
              _buildTextField(_twitterCtrl, 'X (Twitter) Username', Icons.alternate_email, text, muted),
              
              if (user != null) ...[
                _buildSectionTitle('Gestión de Roles', text),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Rol Principal Actual', style: TextStyle(color: muted, fontSize: 13)),
                  subtitle: Text(user.role.label, style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.bold)),
                  trailing: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contacta a soporte para cambiar tu rol primario.')));
                    },
                    child: Text('CAMBIAR', style: TextStyle(color: AppColors.buttonBg(isDark))),
                  ),
                ),
              ],

              // ROLE SPECIFIC SECTIONS
              if (user?.role == UserRole.player) ...[
                _buildSectionTitle('Datos Deportivos (Jugador)', text),
                DropdownButtonFormField<String>(
                  value: _position,
                  dropdownColor: AppColors.surface(isDark),
                  style: TextStyle(color: text),
                  decoration: InputDecoration(labelText: 'Posición Principal', labelStyle: TextStyle(color: muted), prefixIcon: Icon(Icons.sports_soccer, color: muted)),
                  items: ['POR', 'DEF', 'MED', 'DEL'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _position = val),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _ageGroup,
                  dropdownColor: AppColors.surface(isDark),
                  style: TextStyle(color: text),
                  decoration: InputDecoration(labelText: 'Categoría de Edad', labelStyle: TextStyle(color: muted), prefixIcon: Icon(Icons.cake, color: muted)),
                  items: ['U13', '13-15 años', '15-17 años', 'U19', 'Adulto'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _ageGroup = val),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _strongFoot,
                  dropdownColor: AppColors.surface(isDark),
                  style: TextStyle(color: text),
                  decoration: InputDecoration(labelText: 'Pie Dominante', labelStyle: TextStyle(color: muted), prefixIcon: Icon(Icons.do_not_step, color: muted)),
                  items: ['Diestro', 'Zurdo', 'Ambidiestro'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _strongFoot = val),
                ),
                _buildTextField(_heightCtrl, 'Altura (cm)', Icons.height, text, muted),
                _buildTextField(_weightCtrl, 'Peso (kg)', Icons.monitor_weight_outlined, text, muted),
                _buildTextField(_currentTeamCtrl, 'Equipo Actual', Icons.shield_outlined, text, muted),
              ] else if (user?.role == UserRole.coach) ...[
                _buildSectionTitle('Datos de Entrenador', text),
                _buildTextField(_coachLicenseCtrl, 'Nivel de Licencia (Ej. UEFA Pro)', Icons.card_membership, text, muted),
                _buildTextField(_currentTeamCtrl, 'Club Actual', Icons.shield_outlined, text, muted),
              ] else if (user?.role == UserRole.scout) ...[
                _buildSectionTitle('Datos de Scout', text),
                _buildTextField(_scoutAgencyCtrl, 'Club / Agencia Afiliada', Icons.business_center_outlined, text, muted),
                SwitchListTile(
                  title: Text('Estado de Verificación KYC', style: TextStyle(color: text)),
                  subtitle: Text('Requerido para búsquedas avanzadas', style: TextStyle(color: muted)),
                  value: true,
                  onChanged: (val) {},
                  activeColor: AppColors.buttonBg(isDark),
                ),
              ] else if (user?.role == UserRole.referee) ...[
                _buildSectionTitle('Datos de Árbitro', text),
                _buildTextField(_refereeCertCtrl, 'Nivel de Certificación', Icons.sports, text, muted),
              ] else if (user?.role == UserRole.journalist) ...[
                _buildSectionTitle('Datos de Periodista', text),
                _buildTextField(_journalistMediaCtrl, 'Medio de Comunicación Afiliado', Icons.newspaper, text, muted),
              ] else if (user?.role == UserRole.brand) ...[
                _buildSectionTitle('Datos de Marca', text),
                _buildTextField(_brandCompanyCtrl, 'Nombre de la Empresa', Icons.storefront, text, muted),
              ] else if (user?.role == UserRole.tutor) ...[
                _buildSectionTitle('Datos de Tutor', text),
                Text('Administras los perfiles de los menores a tu cargo y tus datos de contacto están protegidos.', style: TextStyle(color: muted, fontSize: 13)),
              ],

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
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
