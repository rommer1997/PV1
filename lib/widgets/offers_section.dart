import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/players_provider.dart';

class OffersSection extends ConsumerWidget {
  final String playerId;
  final bool isDark;

  const OffersSection({
    super.key,
    required this.playerId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(playersProvider);
    final pData = players
        .where((p) => p.user.uniqueId == playerId || p.user.id == playerId)
        .firstOrNull;
    final offers = pData?.pendingOffers ?? [];

    final surface = AppColors.surface(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final border = AppColors.border(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'OFERTAS Y CONTRATOS',
              style: TextStyle(
                color: muted,
                fontSize: 11,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (offers.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${offers.length} NUEVAS',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (offers.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border, style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  color: muted.withValues(alpha: 0.3),
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  'No tienes ofertas pendientes',
                  style: TextStyle(color: muted, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sigue mejorando tu OVR para llamar la atención',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: muted.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          )
        else
          ...offers.map((offer) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFF4CA25).withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF4CA25).withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              const Color(0xFFF4CA25).withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.business,
                            color: Color(0xFFF4CA25),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                offer['club'] ?? 'Club Interesado',
                                style: TextStyle(
                                  color: text,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Enviada por: ${offer['scout'] ?? 'Scout de Cantera'}',
                                style: TextStyle(color: muted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TIPO DE CONTRATO',
                              style: TextStyle(
                                color: muted,
                                fontSize: 9,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              offer['type'] ?? 'Becas Deportivas',
                              style: TextStyle(
                                color: text,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF34C759),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Ver Detalles',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
      ],
    );
  }
}
