import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

class OfferDetailScreen extends ConsumerWidget {
  final String playerName;
  final String playerId;
  final String amount;
  final bool isDark;

  const OfferDetailScreen({
    super.key,
    required this.playerName,
    required this.playerId,
    required this.amount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(dark);
    final text = AppColors.text(dark);
    final muted = AppColors.textMuted(dark);
    final surface = AppColors.surface(dark);
    final border = AppColors.border(dark);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: text),
        title: Text(
          'Detalle de Oferta',
          style: TextStyle(color: muted, fontSize: 14, letterSpacing: 0.5),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera jugador
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: bg,
                        border: Border.all(color: border),
                      ),
                      child: Icon(Icons.person, color: muted, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playerName,
                          style: TextStyle(
                            color: text,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          playerId,
                          style: TextStyle(
                            color: muted,
                            fontSize: 12,
                            fontFamily: 'Courier',
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Desglose de la oferta
              Text(
                'DESGLOSE',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              _DetailRow(
                label: 'Club Solicitante',
                value: 'FC Barcelona B',
                isDark: dark,
              ),
              _DetailRow(
                label: 'Tipo',
                value: 'Cláusula de Observación',
                isDark: dark,
              ),
              _DetailRow(
                label: 'Cantidad Ofrecida',
                value: '$amount SC',
                isDark: dark,
              ),
              _DetailRow(label: 'Duración', value: '3 meses', isDark: dark),
              _DetailRow(
                label: 'Estado',
                value: 'Pendiente de Tutor',
                isDark: dark,
              ),

              const SizedBox(height: 32),

              // Cláusulas
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CLÁUSULAS',
                      style: TextStyle(
                        color: muted,
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• El club podrá observar al jugador en hasta 5 partidos.\n'
                      '• No se adquieren derechos deportivos sin acuerdo posterior.\n'
                      '• Los datos personales del menor NO se comparten.',
                      style: TextStyle(color: muted, fontSize: 13, height: 1.7),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Oferta rechazada')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'RECHAZAR',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '✓ Oferta aprobada y firmada digitalmente',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF34C759),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'APROBAR',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  final bool isDark;
  const _DetailRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.text(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
