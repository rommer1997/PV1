import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../fish_card_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
// NOTA ARQUITECTURAL:
// "Capitán" NO es un perfil de usuario separado. Es una insignia dentro del
// perfil de jugador, assignada únicamente por el entrenador en su dashboard.
// Esta pantalla es simplemente la vista de jugador (capitán o no).
// ════════════════════════════════════════════════════════════════════════════

class CaptainScreen extends ConsumerStatefulWidget {
  const CaptainScreen({super.key});
  @override
  ConsumerState<CaptainScreen> createState() => _CaptainScreenState();
}

class _CaptainScreenState extends ConsumerState<CaptainScreen>
    with TickerProviderStateMixin {
  late TabController _tab;
  bool _enrolled = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JUGADOR',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'Rafa Navarro',
                        style: TextStyle(
                          color: text,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Badge capitán — solo visible si el entrenador lo asignó
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Color(0xFFFFD700),
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'CAPITÁN',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Atletico Juvenil A · Mediocampista',
                    style: TextStyle(color: muted, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Sub-tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 28),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tab,
                indicator: BoxDecoration(
                  color: AppColors.buttonBg(isDark),
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: AppColors.buttonFg(isDark),
                unselectedLabelColor: muted,
                labelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'MI PERFIL'),
                  Tab(text: 'UNIFORME'),
                  Tab(text: 'TORNEO'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  // ── Tab 1: Fish Card ──
                  FishCardScreen(),

                  // ── Tab 2: Diseñador de uniforme ──
                  _UniformDesigner(isDark: isDark),

                  // ── Tab 3: Torneos ──
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'TORNEOS DISPONIBLES',
                          style: TextStyle(
                            color: muted,
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _TournamentCard(
                          name: 'Madrid U19 Summer Cup',
                          date: '15 Jun 2026',
                          fee: '50 SC',
                          enrolled: false,
                          isDark: isDark,
                          onEnroll: () {},
                        ),
                        const SizedBox(height: 14),
                        _TournamentCard(
                          name: 'Liga Juvenil Regional',
                          date: '1 Jul 2026',
                          fee: '30 SC',
                          enrolled: _enrolled,
                          isDark: isDark,
                          onEnroll: () => setState(() => _enrolled = true),
                        ),
                        const SizedBox(height: 14),
                        _TournamentCard(
                          name: 'Copa de Primavera Sub-19',
                          date: '20 Abr 2026',
                          fee: '20 SC',
                          enrolled: false,
                          isDark: isDark,
                          onEnroll: () {},
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DISEÑADOR DE UNIFORME
// ════════════════════════════════════════════════════════════════════════════

enum ShirtModel { classic, modern, stripes, split }

enum ShortModel { plain, lateral, dual }

class _UniformDesigner extends StatefulWidget {
  final bool isDark;
  const _UniformDesigner({required this.isDark});
  @override
  State<_UniformDesigner> createState() => _UniformDesignerState();
}

class _UniformDesignerState extends State<_UniformDesigner> {
  ShirtModel _shirtModel = ShirtModel.classic;
  Color _baseColor = const Color(0xFFE53935);
  Color _accentColor = Colors.white;
  Color _collarColor = const Color(0xFFFFD700);
  int _number = 10;
  bool _vNeck = false;

  ShortModel _shortModel = ShortModel.plain;
  Color _shortBase = Colors.white;
  Color _shortStripe = const Color(0xFFE53935);

  static const _palette = [
    Color(0xFFE53935),
    Color(0xFF1E88E5),
    Colors.black,
    Color(0xFF43A047),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Colors.white,
    Color(0xFFFFD700),
    Color(0xFF607D8B),
    Color(0xFFFF5722),
    Color(0xFF795548),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final border = AppColors.border(isDark);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _Label('DISEÑO DE UNIFORME', muted),
          const SizedBox(height: 24),

          // Vista previa
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: 180,
                  height: 200,
                  child: CustomPaint(
                    painter: _ShirtPainter(
                      model: _shirtModel,
                      base: _baseColor,
                      accent: _accentColor,
                      collar: _collarColor,
                      number: _number,
                      vNeck: _vNeck,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 140,
                  height: 120,
                  child: CustomPaint(
                    painter: _ShortPainter(
                      model: _shortModel,
                      base: _shortBase,
                      stripe: _shortStripe,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Modelo camiseta
          _Label('MODELO CAMISETA', muted),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _ModelCard(
                  label: 'Clásico',
                  icon: Icons.layers_outlined,
                  selected: _shirtModel == ShirtModel.classic,
                  isDark: isDark,
                  onTap: () => setState(() => _shirtModel = ShirtModel.classic),
                ),
                _ModelCard(
                  label: 'Moderno',
                  icon: Icons.flash_on_outlined,
                  selected: _shirtModel == ShirtModel.modern,
                  isDark: isDark,
                  onTap: () => setState(() => _shirtModel = ShirtModel.modern),
                ),
                _ModelCard(
                  label: 'Franjas',
                  icon: Icons.view_column_outlined,
                  selected: _shirtModel == ShirtModel.stripes,
                  isDark: isDark,
                  onTap: () => setState(() => _shirtModel = ShirtModel.stripes),
                ),
                _ModelCard(
                  label: 'Bicolor',
                  icon: Icons.contrast_outlined,
                  selected: _shirtModel == ShirtModel.split,
                  isDark: isDark,
                  onTap: () => setState(() => _shirtModel = ShirtModel.split),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _Label('COLOR BASE', muted),
          const SizedBox(height: 10),
          _ColorRow(
            palette: _palette,
            selected: _baseColor,
            border: border,
            onPick: (c) => setState(() => _baseColor = c),
          ),

          const SizedBox(height: 16),
          _Label('COLOR ACENTO / MANGAS', muted),
          const SizedBox(height: 10),
          _ColorRow(
            palette: _palette,
            selected: _accentColor,
            border: border,
            onPick: (c) => setState(() => _accentColor = c),
          ),

          const SizedBox(height: 16),
          _Label('COLOR CUELLO / PUÑOS', muted),
          const SizedBox(height: 10),
          _ColorRow(
            palette: _palette,
            selected: _collarColor,
            border: border,
            onPick: (c) => setState(() => _collarColor = c),
          ),

          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CUELLO EN V',
                style: TextStyle(color: muted, fontSize: 10, letterSpacing: 2),
              ),
              Switch(
                value: _vNeck,
                onChanged: (v) => setState(() => _vNeck = v),
                activeThumbColor: text,
              ),
            ],
          ),

          const SizedBox(height: 10),
          _Label('NÚMERO DORSAL', muted),
          const SizedBox(height: 6),
          Row(
            children: [
              IconButton(
                onPressed: () =>
                    setState(() => _number = (_number - 1).clamp(1, 99)),
                icon: Icon(Icons.remove_circle_outline, color: text, size: 28),
              ),
              Text(
                '$_number',
                style: TextStyle(
                  color: text,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: () =>
                    setState(() => _number = (_number + 1).clamp(1, 99)),
                icon: Icon(Icons.add_circle_outline, color: text, size: 28),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Divider(color: border),
          const SizedBox(height: 20),

          // Pantaloneta
          _Label('MODELO PANTALONETA', muted),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _ModelCard(
                  label: 'Lisa',
                  icon: Icons.rectangle_outlined,
                  selected: _shortModel == ShortModel.plain,
                  isDark: isDark,
                  onTap: () => setState(() => _shortModel = ShortModel.plain),
                ),
                _ModelCard(
                  label: 'Lateral',
                  icon: Icons.border_left_outlined,
                  selected: _shortModel == ShortModel.lateral,
                  isDark: isDark,
                  onTap: () => setState(() => _shortModel = ShortModel.lateral),
                ),
                _ModelCard(
                  label: 'Dual',
                  icon: Icons.vertical_split_outlined,
                  selected: _shortModel == ShortModel.dual,
                  isDark: isDark,
                  onTap: () => setState(() => _shortModel = ShortModel.dual),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _Label('COLOR BASE PANTALÓN', muted),
          const SizedBox(height: 10),
          _ColorRow(
            palette: _palette,
            selected: _shortBase,
            border: border,
            onPick: (c) => setState(() => _shortBase = c),
          ),

          const SizedBox(height: 16),
          _Label('COLOR FRANJA PANTALÓN', muted),
          const SizedBox(height: 10),
          _ColorRow(
            palette: _palette,
            selected: _shortStripe,
            border: border,
            onPick: (c) => setState(() => _shortStripe = c),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    '✓ Uniforme guardado y enviado al equipo',
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBg(isDark),
                foregroundColor: AppColors.buttonFg(isDark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'GUARDAR UNIFORME',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Helpers estáticos ────────────────────────────────────────────────────────
Widget _Label(String t, Color c) => Text(
  t,
  style: TextStyle(
    color: c,
    fontSize: 10,
    letterSpacing: 2,
    fontWeight: FontWeight.w600,
  ),
);

class _ColorRow extends StatelessWidget {
  final List<Color> palette;
  final Color selected, border;
  final ValueChanged<Color> onPick;
  const _ColorRow({
    required this.palette,
    required this.selected,
    required this.border,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: palette.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = palette[i];
          final sel = c.value == selected.value;
          return GestureDetector(
            onTap: () => onPick(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: sel ? Colors.transparent : border,
                  width: 1,
                ),
                boxShadow: sel
                    ? [
                        BoxShadow(
                          color: c.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: sel
                  ? const Icon(Icons.check, size: 15, color: Colors.white)
                  : null,
            ),
          );
        },
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected, isDark;
  final VoidCallback onTap;
  const _ModelCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 80,
        height: 76,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.buttonBg(isDark) : surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.buttonBg(isDark) : border,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.buttonBg(isDark).withValues(alpha: 0.28),
                    blurRadius: 8,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.buttonFg(isDark) : muted,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.buttonFg(isDark) : muted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── CustomPainter Camiseta ────────────────────────────────────────────────────
class _ShirtPainter extends CustomPainter {
  final ShirtModel model;
  final Color base, accent, collar;
  final int number;
  final bool vNeck;
  _ShirtPainter({
    required this.model,
    required this.base,
    required this.accent,
    required this.collar,
    required this.number,
    required this.vNeck,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    if (!w.isFinite || !h.isFinite || w <= 0 || h <= 0) return;
    final paint = Paint()..isAntiAlias = true;

    // Silueta camiseta
    final body = Path()
      ..moveTo(w * 0.18, 0)
      ..lineTo(0, h * 0.22)
      ..lineTo(0, h * 0.42)
      ..lineTo(w * 0.22, h * 0.42)
      ..lineTo(w * 0.22, h)
      ..lineTo(w * 0.78, h)
      ..lineTo(w * 0.78, h * 0.42)
      ..lineTo(w, h * 0.42)
      ..lineTo(w, h * 0.22)
      ..lineTo(w * 0.82, 0)
      ..close();

    paint.color = base;
    canvas.drawPath(body, paint);

    // Decoración por modelo
    canvas.save();
    canvas.clipPath(body);
    switch (model) {
      case ShirtModel.modern:
        paint.color = accent.withValues(alpha: 0.85);
        canvas.drawPath(
          Path()
            ..moveTo(w * 0.1, h * 0.1)
            ..lineTo(w * 0.6, h * 0.1)
            ..lineTo(w * 0.45, h * 0.5)
            ..lineTo(0, h * 0.5)
            ..close(),
          paint,
        );
        break;
      case ShirtModel.stripes:
        paint.color = accent.withValues(alpha: 0.75);
        for (double x = 0; x < w; x += w * 0.13) {
          canvas.drawRect(Rect.fromLTWH(x, 0, w * 0.065, h), paint);
        }
        break;
      case ShirtModel.split:
        paint.color = accent;
        canvas.drawPath(
          Path()
            ..moveTo(w * 0.5, 0)
            ..lineTo(w, 0)
            ..lineTo(w, h)
            ..lineTo(w * 0.5, h)
            ..close(),
          paint,
        );
        break;
      case ShirtModel.classic:
        paint.color = accent.withValues(alpha: 0.5);
        canvas.drawRect(Rect.fromLTWH(w * 0.42, 0, w * 0.16, h), paint);
        break;
    }
    canvas.restore();

    // Mangas acento
    paint.color = accent;
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.22)
        ..lineTo(0, h * 0.42)
        ..lineTo(w * 0.22, h * 0.42)
        ..lineTo(w * 0.22, h * 0.28)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w, h * 0.22)
        ..lineTo(w, h * 0.42)
        ..lineTo(w * 0.78, h * 0.42)
        ..lineTo(w * 0.78, h * 0.28)
        ..close(),
      paint,
    );

    // Cuello
    paint.color = collar;
    if (vNeck) {
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.18, 0)
          ..lineTo(w * 0.5, h * 0.18)
          ..lineTo(w * 0.82, 0)
          ..lineTo(w * 0.75, 0)
          ..lineTo(w * 0.5, h * 0.12)
          ..lineTo(w * 0.25, 0)
          ..close(),
        paint,
      );
    } else {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w / 2, h * 0.04),
          width: w * 0.44,
          height: h * 0.1,
        ),
        paint,
      );
    }

    // Número
    final numColor = base.computeLuminance() > 0.4
        ? Colors.black
        : Colors.white;
    final tp = TextPainter(
      text: TextSpan(
        text: '$number',
        style: TextStyle(
          color: numColor,
          fontSize: h * 0.28,
          fontWeight: FontWeight.w900,
          letterSpacing: -2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w / 2 - tp.width / 2, h * 0.5 - tp.height / 2));
  }

  @override
  bool shouldRepaint(_ShirtPainter old) => true;
}

// ── CustomPainter Pantaloneta ─────────────────────────────────────────────────
class _ShortPainter extends CustomPainter {
  final ShortModel model;
  final Color base, stripe;
  _ShortPainter({
    required this.model,
    required this.base,
    required this.stripe,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    if (!w.isFinite || !h.isFinite || w <= 0 || h <= 0) return;
    final paint = Paint()..isAntiAlias = true;

    final left = Path()
      ..moveTo(w * 0.05, 0)
      ..lineTo(w * 0.5, 0)
      ..lineTo(w * 0.45, h * 0.45)
      ..lineTo(w * 0.38, h)
      ..lineTo(w * 0.05, h)
      ..close();
    final right = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w * 0.95, 0)
      ..lineTo(w * 0.95, h)
      ..lineTo(w * 0.62, h)
      ..lineTo(w * 0.55, h * 0.45)
      ..close();

    paint.color = base;
    canvas.drawPath(left, paint);
    canvas.drawPath(right, paint);

    switch (model) {
      case ShortModel.lateral:
        paint.color = stripe;
        canvas.save();
        canvas.clipPath(left);
        canvas.drawRect(Rect.fromLTWH(0, 0, w * 0.07, h), paint);
        canvas.restore();
        canvas.save();
        canvas.clipPath(right);
        canvas.drawRect(Rect.fromLTWH(w * 0.88, 0, w * 0.12, h), paint);
        canvas.restore();
        break;
      case ShortModel.dual:
        paint.color = stripe;
        canvas.drawPath(right, paint);
        break;
      case ShortModel.plain:
        break;
    }

    // Cinturilla
    paint.color = stripe.withValues(alpha: 0.7);
    canvas.drawRect(Rect.fromLTWH(w * 0.05, 0, w * 0.9, h * 0.1), paint);
  }

  @override
  bool shouldRepaint(_ShortPainter old) => true;
}

// ── Tarjeta de torneo ─────────────────────────────────────────────────────────
class _TournamentCard extends StatelessWidget {
  final String name, date, fee;
  final bool enrolled, isDark;
  final VoidCallback onEnroll;
  const _TournamentCard({
    required this.name,
    required this.date,
    required this.fee,
    required this.enrolled,
    required this.isDark,
    required this.onEnroll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enrolled
              ? AppColors.text(isDark).withValues(alpha: 0.4)
              : AppColors.border(isDark),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppColors.text(isDark),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$date · Inscripción: $fee',
                  style: TextStyle(
                    color: AppColors.textMuted(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: enrolled ? null : onEnroll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: enrolled
                    ? AppColors.surface(isDark)
                    : AppColors.buttonBg(isDark),
                borderRadius: BorderRadius.circular(20),
                border: enrolled
                    ? Border.all(color: AppColors.border(isDark))
                    : null,
              ),
              child: Text(
                enrolled ? 'Inscrito ✓' : 'Inscribir',
                style: TextStyle(
                  color: enrolled
                      ? AppColors.textMuted(isDark)
                      : AppColors.buttonFg(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
