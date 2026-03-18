import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../providers/theme_provider.dart';

/// Widget que muestra u oculta contenido según el permiso del rol activo.
/// Si [allow] es false, muestra un candado/bloqueo elegante en su lugar.
class PermissionGate extends ConsumerWidget {
  final bool allow;
  final Widget child;
  final String? blockedMessage;
  final bool showLock; // Si false simplemente oculta sin mostrar candado

  const PermissionGate({
    super.key,
    required this.allow,
    required this.child,
    this.blockedMessage,
    this.showLock = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocked = ref.watch(safetyLockProvider);

    // Si el bloqueo global está activo, forzamos el bloqueo si no hay permiso explícito
    if (isLocked && !allow) {
      return _BlockedView(
        message: 'Protección de Privacidad Activa — Acceso Restricted',
      );
    }

    if (allow) return child;
    if (!showLock) return const SizedBox.shrink();
    return _BlockedView(
      message: blockedMessage ?? 'Acceso restringido para tu perfil',
    );
  }
}

class _BlockedView extends StatelessWidget {
  final String message;
  const _BlockedView({required this.message});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            color: AppColors.textMuted(isDark),
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.textMuted(isDark),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge de privacidad para menores — visible en el Athletic-CV
class MinorPrivacyBadge extends StatelessWidget {
  const MinorPrivacyBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shield_outlined, color: Colors.orange, size: 14),
          const SizedBox(width: 6),
          const Text(
            'Perfil Protegido — Menor de Edad',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge de stats inmutables — solo lectura para jugadores
class LockedStatBadge extends StatelessWidget {
  final String label;
  final double value;
  const LockedStatBadge({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textMuted(isDark),
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.lock_outline,
              color: AppColors.textMuted(isDark),
              size: 10,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            color: AppColors.text(isDark),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
