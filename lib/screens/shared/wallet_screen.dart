import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_user.dart';
import '../../providers/theme_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final user = ref.watch(sessionProvider);
    final sc = user?.sportcoins ?? 0;
    
    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);
    final primary = AppColors.buttonBg(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Billetera SLP',
                style: TextStyle(
                  color: text,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),

              // Premium Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                      ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
                      : [const Color(0xFFE0E0E0), const Color(0xFFF5F5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SALDO ACTUAL',
                          style: TextStyle(
                            color: muted,
                            fontSize: 12,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(Icons.account_balance_wallet_outlined, color: muted, size: 20),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutQuart,
                      tween: Tween<double>(begin: 0, end: sc.toDouble()),
                      builder: (context, value, child) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              value.toStringAsFixed(0),
                              style: TextStyle(
                                color: text,
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'SC',
                              style: TextStyle(
                                color: primary,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '≈ €${(sc * 0.0092).toStringAsFixed(2)} EUR',
                      style: TextStyle(
                        color: muted,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Smart Escrow Card
              _SmartEscrowCard(isDark: isDark),
              const SizedBox(height: 32),

              // Opciones para Obtener SC
              Text(
                'NUEVAS FORMAS DE GANAR SC',
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              
              _OptionCard(
                icon: Icons.emoji_events_outlined,
                title: 'Retos Deportivos',
                subtitle: 'Participa en 2 torneos este mes (+150 SC)',
                isDark: isDark,
                onTap: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Has reclamado tu recompensa semanal.', style: TextStyle(color: text, fontWeight: FontWeight.bold)), backgroundColor: primary)
                   );
                },
              ),
              const SizedBox(height: 12),
              _OptionCard(
                icon: Icons.visibility_outlined,
                title: 'Regalías por Scouting',
                subtitle: 'Ganas +1 SC directo cada vez que un scout paga por ver tu radar',
                isDark: isDark,
                onTap: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Historial: 14 scouts pagaron por ver tu perfil esta semana.', style: TextStyle(color: text)), backgroundColor: surface)
                   );
                },
              ),
              const SizedBox(height: 12),
              _OptionCard(
                icon: Icons.play_circle_outline,
                title: 'Ver Patrocinios',
                subtitle: 'Mira 30s de publicidad oficial (+5 SC)',
                isDark: isDark,
                onTap: () {
                  ref.read(sessionProvider.notifier).addSportCoins(5);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('¡Has ganado +5 SC por ver el patrocinio!', style: TextStyle(color: text, fontWeight: FontWeight.bold)),
                      backgroundColor: primary,
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Acciones Rápidas
              Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.send_outlined,
                      label: 'Enviar',
                      isDark: isDark,
                      onTap: () => _showDonateSheet(context, isDark),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.history,
                      label: 'Stake',
                      isDark: isDark,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Staking de Tokens en desarrollo...', style: TextStyle(color: text)), backgroundColor: surface)
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Impacto Económico y Donaciones ──────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MI IMPACTO',
                          style: TextStyle(
                            color: muted,
                            fontSize: 11,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(Icons.volunteer_activism_outlined, color: text, size: 20),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _StatSmall(label: 'Donaciones', value: '12', isDark: isDark),
                        const SizedBox(width: 24),
                        _StatSmall(label: 'Ganancias Retos', value: '450 SC', isDark: isDark),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'La comunidad ha apoyado tu carrera deportiva. ¡Sigue así!',
                      style: TextStyle(color: muted, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              Text(
                'MOVIMIENTOS',
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              
              _TransactionRow(
                title: 'Recompensa por Anuncio',
                amount: '+5 SC',
                positive: true,
                date: 'Hoy, 14:30',
                isDark: isDark,
              ),
              _TransactionRow(
                title: 'Donación a Elena Vance',
                amount: '-5 SC',
                positive: false,
                date: 'Hoy, 11:20',
                isDark: isDark,
              ),
              _TransactionRow(
                title: 'Bono Inicial',
                amount: '+500 SC',
                positive: true,
                date: 'Ayer',
                isDark: isDark,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  void _showDonateSheet(BuildContext ctx, bool isDark) {
    final bg2 = AppColors.surface(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    showModalBottomSheet(
      context: ctx,
      backgroundColor: bg2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: AppColors.border(isDark), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 28),
            Text('Enviar / Donar SC', style: TextStyle(color: text, fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            TextField(
              style: TextStyle(color: text, fontSize: 32, fontWeight: FontWeight.w700),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0 SC',
                hintStyle: TextStyle(color: muted, fontSize: 32),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border(isDark))),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: text)),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBg(isDark),
                  foregroundColor: AppColors.buttonFg(isDark),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text('CONFIRMAR ENVÍO', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 2)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bg(isDark),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: text, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: muted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);
    final text = AppColors.text(isDark);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Icon(icon, color: text, size: 24),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final String title;
  final String amount;
  final bool positive;
  final String date;
  final bool isDark;
  
  const _TransactionRow({
    required this.title,
    required this.amount,
    required this.positive,
    required this.date,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border(isDark)),
            ),
            child: Icon(
              positive ? Icons.arrow_downward : Icons.arrow_upward,
              color: positive ? const Color(0xFF34C759) : Colors.redAccent,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: text, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: positive ? const Color(0xFF34C759) : text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Smart Escrow Card ────────────────────────────────────────────────────────
class _SmartEscrowCard extends StatelessWidget {
  final bool isDark;
  const _SmartEscrowCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final highlight = isDark ? Colors.blueAccent : Colors.blue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FONDOS RETENIDOS (ESCROW)',
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(Icons.shield_outlined, color: highlight, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '1,500 SC',
            style: TextStyle(
              color: text,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Contrato de firma (C.D. Madrid U19)\nEsperando firma manual del Entrenador Staff.',
            style: TextStyle(color: muted, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 24),
          // Progress Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: highlight,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(3)),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: highlight,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white12 : Colors.black12,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(3)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progreso contrato', style: TextStyle(color: muted, fontSize: 11)),
              Text('2/3 firmas', style: TextStyle(color: highlight, fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatSmall extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _StatSmall({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: AppColors.text(isDark), fontSize: 16, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
