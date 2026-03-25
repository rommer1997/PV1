import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

// ── Estado del perfil del entrenador en el marketplace ──────────────────────
class CoachProfileNotifier extends Notifier<CoachProfile> {
  @override
  CoachProfile build() => CoachProfile(
    published: false,
    schoolName: '',
    description: '',
    pricePerMonth: '',
    location: '',
    ageGroups: [],
    schedule: '',
    maxStudents: '',
  );

  void update(CoachProfile p) => state = p;
  void publish() => state = state.copyWith(published: true);
  void unpublish() => state = state.copyWith(published: false);
}

final coachProfileProvider =
    NotifierProvider<CoachProfileNotifier, CoachProfile>(
      () => CoachProfileNotifier(),
    );

class CoachProfile {
  final bool published;
  final String schoolName,
      description,
      pricePerMonth,
      location,
      schedule,
      maxStudents;
  final List<String> ageGroups;

  const CoachProfile({
    required this.published,
    required this.schoolName,
    required this.description,
    required this.pricePerMonth,
    required this.location,
    required this.ageGroups,
    required this.schedule,
    required this.maxStudents,
  });

  CoachProfile copyWith({
    bool? published,
    String? schoolName,
    String? description,
    String? pricePerMonth,
    String? location,
    List<String>? ageGroups,
    String? schedule,
    String? maxStudents,
  }) => CoachProfile(
    published: published ?? this.published,
    schoolName: schoolName ?? this.schoolName,
    description: description ?? this.description,
    pricePerMonth: pricePerMonth ?? this.pricePerMonth,
    location: location ?? this.location,
    ageGroups: ageGroups ?? this.ageGroups,
    schedule: schedule ?? this.schedule,
    maxStudents: maxStudents ?? this.maxStudents,
  );
}

// Mock de otros entrenadores en el marketplace
final _mockCoaches = [
  {
    'name': 'Pedro Martínez',
    'school': 'Academia Estrella FC',
    'location': 'Madrid',
    'price': '€80/mes',
    'ages': 'Sub-8 · Sub-10 · Sub-12',
    'rating': 4.9,
    'students': 24,
  },
  {
    'name': 'Laura Gómez',
    'school': 'Escuela Técnica Futbolera',
    'location': 'Barcelona',
    'price': '€65/mes',
    'ages': 'Sub-10 · Sub-14',
    'rating': 4.7,
    'students': 18,
  },
  {
    'name': 'Raúl Herrera',
    'school': 'Club Deportivo Juvenil',
    'location': 'Valencia',
    'price': '€55/mes',
    'ages': 'Sub-6 · Sub-8',
    'rating': 4.8,
    'students': 30,
  },
];

const _allAgeGroups = [
  'Sub-6',
  'Sub-8',
  'Sub-10',
  'Sub-12',
  'Sub-14',
  'Sub-16',
  'Sub-18',
  'Sénior',
];

// ── Pantalla principal ────────────────────────────────────────────────────────
class CoachMarketplaceScreen extends ConsumerStatefulWidget {
  const CoachMarketplaceScreen({super.key});

  @override
  ConsumerState<CoachMarketplaceScreen> createState() =>
      _CoachMarketplaceScreenState();
}

class _CoachMarketplaceScreenState extends ConsumerState<CoachMarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACADEMIA',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Marketplace',
                    style: TextStyle(
                      color: text,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Conecta con familias · Sin comisiones · Solo publicidad Cantera',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabs,
              labelColor: text,
              unselectedLabelColor: muted,
              indicatorColor: text,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: AppColors.border(isDark),
              tabs: const [
                Tab(text: 'Mi Perfil'),
                Tab(text: 'Explorar'),
              ],
            ),

            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _MyProfileTab(isDark: isDark),
                  _ExploreTab(isDark: isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab: Mi Perfil de Entrenador ──────────────────────────────────────────────
class _MyProfileTab extends ConsumerStatefulWidget {
  final bool isDark;
  const _MyProfileTab({required this.isDark});

  @override
  ConsumerState<_MyProfileTab> createState() => _MyProfileTabState();
}

class _MyProfileTabState extends ConsumerState<_MyProfileTab> {
  late TextEditingController _schoolCtrl,
      _descCtrl,
      _priceCtrl,
      _locationCtrl,
      _scheduleCtrl,
      _maxCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = ref.read(coachProfileProvider);
    _schoolCtrl = TextEditingController(text: p.schoolName);
    _descCtrl = TextEditingController(text: p.description);
    _priceCtrl = TextEditingController(text: p.pricePerMonth);
    _locationCtrl = TextEditingController(text: p.location);
    _scheduleCtrl = TextEditingController(text: p.schedule);
    _maxCtrl = TextEditingController(text: p.maxStudents);
  }

  @override
  void dispose() {
    _schoolCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    _scheduleCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(bool publish) async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final p = ref.read(coachProfileProvider);
    ref
        .read(coachProfileProvider.notifier)
        .update(
          p.copyWith(
            schoolName: _schoolCtrl.text,
            description: _descCtrl.text,
            pricePerMonth: _priceCtrl.text,
            location: _locationCtrl.text,
            schedule: _scheduleCtrl.text,
            maxStudents: _maxCtrl.text,
            published: publish,
          ),
        );

    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          publish
              ? '✓ Perfil publicado en el marketplace'
              : '✓ Cambios guardados',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(coachProfileProvider);
    final isDark = widget.isDark;
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge de estado
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: profile.published
                      ? const Color(0xFF34C759).withValues(alpha: 0.15)
                      : surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: profile.published ? const Color(0xFF34C759) : border,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: profile.published
                            ? const Color(0xFF34C759)
                            : muted,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      profile.published
                          ? 'Visible en marketplace'
                          : 'No publicado',
                      style: TextStyle(
                        color: profile.published
                            ? const Color(0xFF34C759)
                            : muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (profile.published) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _save(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: border),
                    ),
                    child: Text(
                      'Ocultar',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // Campos del perfil
          _Field(
            label: 'Nombre de tu escuela / academia',
            ctrl: _schoolCtrl,
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _Field(
            label: 'Ubicación (ciudad, barrio)',
            ctrl: _locationCtrl,
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _Field(
            label: 'Precio mensual (ej: €60/mes)',
            ctrl: _priceCtrl,
            isDark: isDark,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 14),
          _Field(
            label: 'Horario (ej: Lun-Mié-Vie 17:00-19:00)',
            ctrl: _scheduleCtrl,
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _Field(
            label: 'Plazas máximas',
            ctrl: _maxCtrl,
            isDark: isDark,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),

          // Selector de categorías de edad
          Text(
            'CATEGORÍAS',
            style: TextStyle(
              color: muted,
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _AgeGroupSelector(isDark: isDark),

          const SizedBox(height: 14),

          // Descripción
          _Field(
            label: 'Descripción de tu metodología...',
            ctrl: _descCtrl,
            isDark: isDark,
            maxLines: 4,
          ),
          const SizedBox(height: 12),

          // Nota de Cantera
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Color(0xFF007AFF),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Cantera incluirá publicidad propia en tu ficha. El precio y condiciones son íntegramente tuyos. Sin comisiones por contacto.',
                    style: TextStyle(color: muted, fontSize: 12, height: 1.5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Botones
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : () => _save(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBg(isDark),
                foregroundColor: AppColors.buttonFg(isDark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: _saving
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.buttonFg(isDark),
                      ),
                    )
                  : const Text(
                      'PUBLICAR EN MARKETPLACE',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _saving ? null : () => _save(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: text,
                side: BorderSide(color: border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('GUARDAR BORRADOR'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab: Explorar el marketplace ──────────────────────────────────────────────
class _ExploreTab extends ConsumerWidget {
  final bool isDark;
  const _ExploreTab({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ENTRENADORES DISPONIBLES',
            style: TextStyle(
              color: muted,
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_mockCoaches.length} academias cerca de ti',
            style: TextStyle(
              color: text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),

          ..._mockCoaches.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _CoachCard(coach: c, isDark: isDark),
            ),
          ),

          const SizedBox(height: 12),
          Center(
            child: Text(
              'Cantera · Todos los derechos reservados',
              style: TextStyle(color: muted, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  final Map<String, dynamic> coach;
  final bool isDark;
  const _CoachCard({required this.coach, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bg(isDark),
                  border: Border.all(color: border),
                ),
                child: Icon(Icons.sports_outlined, color: muted, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coach['school'],
                      style: TextStyle(
                        color: text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      coach['name'],
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    coach['price'],
                    style: TextStyle(
                      color: text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 11,
                        color: Color(0xFFFFD700),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${coach['rating']}',
                        style: TextStyle(color: muted, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(
                icon: Icons.location_on_outlined,
                label: coach['location'],
                isDark: isDark,
              ),
              _Tag(
                icon: Icons.group_outlined,
                label: '${coach['students']} alumnos',
                isDark: isDark,
              ),
              _Tag(
                icon: Icons.child_care_outlined,
                label: coach['ages'],
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Solicitud enviada a ${coach['name']}'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: text,
                side: BorderSide(color: border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'CONTACTAR',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _Tag({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bg(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textMuted(isDark)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textMuted(isDark),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Selector de grupos de edad ────────────────────────────────────────────────
class _AgeGroupSelector extends ConsumerWidget {
  final bool isDark;
  const _AgeGroupSelector({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(coachProfileProvider).ageGroups;
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final border = AppColors.border(isDark);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allAgeGroups.map((age) {
        final isOn = selected.contains(age);
        return GestureDetector(
          onTap: () {
            final p = ref.read(coachProfileProvider);
            final newAges = isOn
                ? p.ageGroups.where((a) => a != age).toList()
                : [...p.ageGroups, age];
            ref
                .read(coachProfileProvider.notifier)
                .update(p.copyWith(ageGroups: newAges));
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isOn ? AppColors.buttonBg(isDark) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOn ? AppColors.buttonBg(isDark) : border,
              ),
            ),
            child: Text(
              age,
              style: TextStyle(
                color: isOn ? AppColors.buttonFg(isDark) : muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Campo de texto reutilizable ───────────────────────────────────────────────
class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final bool isDark;
  final int maxLines;
  final TextInputType? keyboardType;

  const _Field({
    required this.label,
    required this.ctrl,
    required this.isDark,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final border = AppColors.border(isDark);
    final surface = AppColors.surface(isDark);

    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: text, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: muted, fontSize: 13),
        filled: true,
        fillColor: surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: text.withValues(alpha: 0.4)),
        ),
      ),
    );
  }
}
