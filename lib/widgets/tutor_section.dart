import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../providers/theme_provider.dart';

class TutorSection extends StatelessWidget {
  final AppUser user;
  final bool isDark;

  const TutorSection({
    super.key,
    required this.user,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);
    final muted = AppColors.textMuted(isDark);
    final text = AppColors.text(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.family_restroom, color: AppColors.buttonBg(isDark), size: 20),
            const SizedBox(width: 12),
            Text(
              'PANEL DEL TUTOR',
              style: TextStyle(
                color: muted,
                fontSize: 10,
                letterSpacing: 2.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Timeline de Hitos
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cronología de Hitos',
                style: TextStyle(
                  color: text, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              _MilestoneItem(
                date: 'Hoy',
                title: 'OVR subió a 78.4',
                desc: 'Progreso destacado en Técnica individual.',
                isLast: false,
                isDark: isDark,
              ),
              _MilestoneItem(
                date: '24 Mar',
                title: 'Primer Acta Sellada',
                desc: 'Partido validado por árbitro colegiado.',
                isLast: false,
                isDark: isDark,
              ),
              _MilestoneItem(
                date: '20 Mar',
                title: 'Registro en SportLink',
                desc: 'Inicio del historial deportivo digital.',
                isLast: true,
                isDark: isDark,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Control de Privacidad
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Seguridad y Privacidad',
                style: TextStyle(
                  color: text, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              _PrivacySwitch(
                label: 'Visibilidad en Mercado de Talentos',
                value: user.privacySettings['scoutVisible'] ?? true,
                isDark: isDark,
              ),
              _PrivacySwitch(
                label: 'Permitir Contacto de Clubes',
                value: user.privacySettings['contactEnabled'] ?? false,
                isDark: isDark,
              ),
              _PrivacySwitch(
                label: 'Ocultar Localización Exacta',
                value: user.privacySettings['hideLocation'] ?? true,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MilestoneItem extends StatelessWidget {
  final String date, title, desc;
  final bool isLast, isDark;

  const _MilestoneItem({
    required this.date,
    required this.title,
    required this.desc,
    required this.isLast,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textMuted(isDark);
    final text = AppColors.text(isDark);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.buttonBg(isDark),
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 1,
                height: 40,
                color: AppColors.border(isDark),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    date, 
                    style: TextStyle(
                      color: muted, 
                      fontSize: 10, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title, 
                    style: TextStyle(
                      color: text, 
                      fontSize: 13, 
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                desc, 
                style: TextStyle(
                  color: muted, 
                  fontSize: 11, 
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrivacySwitch extends StatelessWidget {
  final String label;
  final bool value;
  final bool isDark;

  const _PrivacySwitch({
    required this.label, 
    required this.value, 
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label, 
              style: TextStyle(
                color: AppColors.text(isDark), 
                fontSize: 13,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) {},
            activeColor: AppColors.buttonBg(isDark),
          ),
        ],
      ),
    );
  }
}
