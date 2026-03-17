import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../models/app_user.dart';

class BrandDashboardScreen extends ConsumerWidget {
  const BrandDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final user = ref.watch(sessionProvider);
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
                'MARCA',
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user?.name ?? 'Nike Iberia',
                style: TextStyle(
                  color: text,
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 36),

              // Métrica principal
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IMPRESIONES TOTALES',
                      style: TextStyle(
                        color: muted,
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1.2M',
                      style: TextStyle(
                        color: text,
                        fontSize: 52,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -2,
                      ),
                    ),
                    Text(
                      'En 50 torneos patrocinados',
                      style: TextStyle(color: muted, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Torneos Activos',
                      value: '12',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _MetricCard(
                      label: 'Equipos Patrocinados',
                      value: '8',
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),
              Text(
                'CAMPAÑAS ACTIVAS',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _CampaignCard(
                name: 'Madrid U19 Summer Cup',
                status: 'Activa',
                impressions: '340K',
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              _CampaignCard(
                name: 'Uniformes Atletico Juvenil A',
                status: 'Activa',
                impressions: '120K',
                isDark: isDark,
              ),

              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showNewCampaignDialog(context, isDark),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBg(isDark),
                    foregroundColor: AppColors.buttonFg(isDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text(
                    'LANZAR CAMPAÑA',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewCampaignDialog(BuildContext ctx, bool isDark) {
    final nameCtrl = TextEditingController();
    final budgetCtrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface(isDark),
        title: Text(
          'Nueva Campaña',
          style: TextStyle(
            color: AppColors.text(isDark),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: AppColors.text(isDark)),
              decoration: InputDecoration(
                labelText: 'Nombre de la campaña',
                labelStyle: TextStyle(color: AppColors.textMuted(isDark)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: budgetCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.text(isDark)),
              decoration: InputDecoration(
                labelText: 'Presupuesto SC',
                labelStyle: TextStyle(color: AppColors.textMuted(isDark)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textMuted(isDark)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text('Campaña "${nameCtrl.text}" lanzada ✓')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonBg(isDark),
              foregroundColor: AppColors.buttonFg(isDark),
            ),
            child: const Text('Lanzar'),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label, value;
  final bool isDark;
  const _MetricCard({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textMuted(isDark),
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppColors.text(isDark),
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final String name, status, impressions;
  final bool isDark;
  const _CampaignCard({
    required this.name,
    required this.status,
    required this.impressions,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(isDark)),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  impressions,
                  style: TextStyle(
                    color: AppColors.textMuted(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF34C759).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Color(0xFF34C759),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
