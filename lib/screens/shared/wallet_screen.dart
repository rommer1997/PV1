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

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BILLETERA',
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 48),

              // Saldo principal
              Center(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutQuart,
                  tween: Tween<double>(begin: 0, end: sc),
                  builder: (context, value, child) {
                    return Column(
                      children: [
                        Text(
                          '${value.toStringAsFixed(0)} SC',
                          style: TextStyle(
                            color: text,
                            fontSize: 56,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '≈ €${(value * 0.0092).toStringAsFixed(2)} EUR',
                          style: TextStyle(
                            color: muted,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '≈ \$${(value * 0.01).toStringAsFixed(2)} USD',
                          style: TextStyle(color: muted, fontSize: 13),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 48),

              // Botones de acción
              _ActionButton(
                label: '🎁 Simular Ingreso (+100 SC)',
                isDark: isDark,
                onTap: () {
                  ref.read(sessionProvider.notifier).addSportCoins(100);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        '¡Has recibido +100 SC por rendimiento deportivo!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: AppColors.buttonBg(isDark),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              _ActionButton(
                label: 'Donar a Jugador / Equipo',
                outline: true,
                isDark: isDark,
                onTap: () => _showDonateSheet(context, isDark),
              ),

              const SizedBox(height: 48),

              Text(
                'TRANSACCIONES RECIENTES',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _TxRow(
                label: 'Predicción acertada',
                amount: '+50 SC',
                positive: true,
                isDark: isDark,
              ),
              _TxRow(
                label: 'Donación a Marco Silva',
                amount: '-30 SC',
                positive: false,
                isDark: isDark,
              ),
              _TxRow(
                label: 'Recompensa comunidad',
                amount: '+100 SC',
                positive: true,
                isDark: isDark,
              ),
              _TxRow(
                label: 'Inscripción torneo',
                amount: '-200 SC',
                positive: false,
                isDark: isDark,
              ),
              const SizedBox(height: 24),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Donar SportCoins',
              style: TextStyle(
                color: text,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              style: TextStyle(
                color: text,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0 SC',
                hintStyle: TextStyle(color: muted, fontSize: 32),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.border(isDark)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: text),
                ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text(
                  'ENVIAR',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool outline;
  final bool isDark;
  final VoidCallback onTap;
  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.isDark,
    this.outline = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: outline
          ? OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.text(isDark),
                side: BorderSide(color: AppColors.border(isDark)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, letterSpacing: 1),
              ),
            )
          : ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBg(isDark),
                foregroundColor: AppColors.buttonFg(isDark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
    );
  }
}

class _TxRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool positive;
  final bool isDark;
  const _TxRow({
    required this.label,
    required this.amount,
    required this.positive,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 14),
          ),
          Text(
            amount,
            style: TextStyle(
              color: positive
                  ? const Color(0xFF34C759)
                  : Colors.red.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
