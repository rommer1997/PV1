import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

enum _OfferStatus { pending, approved, rejected }

class _Offer {
  final String scoutName, scoutTeam, playerId, playerName, terms;
  final bool playerIsMinor;
  _OfferStatus status;
  bool signatureRequired = false;
  bool signed = false;
  _Offer({
    required this.scoutName,
    required this.scoutTeam,
    required this.playerId,
    required this.playerName,
    required this.terms,
    required this.playerIsMinor,
    this.status = _OfferStatus.pending,
  });
}

class TutorApprovalsScreen extends ConsumerStatefulWidget {
  const TutorApprovalsScreen({super.key});
  @override
  ConsumerState<TutorApprovalsScreen> createState() =>
      _TutorApprovalsScreenState();
}

class _TutorApprovalsScreenState extends ConsumerState<TutorApprovalsScreen> {
  final _offers = [
    _Offer(
      scoutName: 'David Torres',
      scoutTeam: 'Real Madrid Academy',
      playerId: 'SLP-0982',
      playerName: 'Marco Silva',
      terms: '2 años · Juvenil A · Sin coste de traspaso',
      playerIsMinor: true,
    ),
    _Offer(
      scoutName: 'Álvaro Díaz',
      scoutTeam: 'Barcelona B',
      playerId: 'SLP-0982',
      playerName: 'Marco Silva',
      terms: '3 años · Formación · 10% SportEscrow',
      playerIsMinor: true,
      status: _OfferStatus.approved,
    ),
  ];

  bool _walletOpen = false;
  final double _donations = 320;
  bool _isPubliclyVisible = true;
  bool _waiverSigned = false;

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TUTOR / PADRE',
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Panel de\nRepresentación',
                style: TextStyle(
                  color: text,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 28),

              // Monedero del menor
              GestureDetector(
                onTap: () => setState(() => _walletOpen = !_walletOpen),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface(isDark),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border(isDark)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'MONEDERO TUTOR',
                            style: TextStyle(
                              color: muted,
                              fontSize: 10,
                              letterSpacing: 2,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            _walletOpen
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: muted,
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${_donations.toStringAsFixed(0)} SC',
                        style: TextStyle(
                          color: text,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'SportCoins en donaciones de Marco',
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                      if (_walletOpen) ...[
                        const SizedBox(height: 16),
                        _WalletAction(
                          label: 'Retirar donaciones',
                          icon: Icons.south,
                          isDark: isDark,
                          onTap: () {},
                        ),
                        const SizedBox(height: 10),
                        _WalletAction(
                          label: 'Historial de movimientos',
                          icon: Icons.receipt_outlined,
                          isDark: isDark,
                          onTap: () {},
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Controles de Privacidad (El Usuario Escéptico)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface(isDark),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border(isDark)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONTROLES DE PRIVACIDAD',
                      style: TextStyle(
                        color: muted,
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Visibilidad Pública del Menor',
                            style: TextStyle(
                              color: text,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Switch(
                          value: _isPubliclyVisible,
                          activeThumbColor: AppColors.buttonBg(isDark),
                          onChanged: (v) {
                            setState(() => _isPubliclyVisible = v);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  v
                                      ? 'Perfil visible en el Mercado Scout.'
                                      : 'Perfil oculto y protegido de terceros.',
                                ),
                                backgroundColor: v
                                    ? const Color(0xFF34C759)
                                    : Colors.orange,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Al desactivar esto, Marco Silva desaparece del "Mercado de Talentos". Tu hijo jugará protegido sin intervención externa.',
                      style: TextStyle(color: muted, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'SOLICITUDES DE SCOUTS',
                style: TextStyle(color: muted, fontSize: 10, letterSpacing: 2),
              ),
              const SizedBox(height: 16),

              ..._offers.map(
                (offer) => _OfferItem(
                  offer: offer,
                  isDark: isDark,
                  onApprove: () => setState(() {
                    offer.status = _OfferStatus.approved;
                  }),
                  onReject: () =>
                      setState(() => offer.status = _OfferStatus.rejected),
                  onSign: () => setState(() => offer.signed = true),
                ),
              ),

              const SizedBox(height: 28),

              // Permiso de juego con firma digital
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface(isDark),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border(isDark)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PERMISO DE JUEGO',
                      style: TextStyle(
                        color: muted,
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Marco Silva (SLP-0982) tiene permiso de juego activo para la temporada 2026/27.',
                      style: TextStyle(color: muted, fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) =>
                            _SignatureDialog(isDark: isDark, onSign: () {}),
                      ),
                      child: Container(
                        height: 48,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.buttonBg(isDark),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'FIRMAR / RENOVAR PERMISO',
                          style: TextStyle(
                            color: AppColors.buttonFg(isDark),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Exención de Responsabilidad Fase 0
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _waiverSigned
                      ? Colors.green.withValues(alpha: 0.05)
                      : Colors.orange.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _waiverSigned
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.orange.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _waiverSigned
                              ? Icons.verified
                              : Icons.warning_amber_rounded,
                          color: _waiverSigned ? Colors.green : Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'EXENCIÓN FASE 0 (EVENTOS FÍSICOS)',
                          style: TextStyle(
                            color: _waiverSigned ? Colors.green : Colors.orange,
                            fontSize: 10,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Requisito obligatorio para torneos presenciales. Al autorizar, confirmas que Marco Silva asiste bajo tu total supervisión legal.',
                      style: TextStyle(color: muted, fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    if (!_waiverSigned)
                      GestureDetector(
                        onTap: () {
                          setState(() => _waiverSigned = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Exención legal firmada para Fase 0.',
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          height: 48,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'FIRMAR EXENCIÓN FÍSICA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 48,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.5),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'EXENCIÓN FIRMADA',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  const _WalletAction({
    required this.label,
    required this.icon,
    required this.isDark,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted(isDark), size: 16),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _OfferItem extends StatelessWidget {
  final _Offer offer;
  final bool isDark;
  final VoidCallback onApprove, onReject, onSign;
  const _OfferItem({
    required this.offer,
    required this.isDark,
    required this.onApprove,
    required this.onReject,
    required this.onSign,
  });

  @override
  Widget build(BuildContext context) {
    final st = offer.status;
    final borderColor = st == _OfferStatus.approved
        ? Colors.green.withValues(alpha: 0.4)
        : st == _OfferStatus.rejected
        ? Colors.red.withValues(alpha: 0.3)
        : AppColors.border(isDark);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'De: ${offer.scoutName}',
                      style: TextStyle(
                        color: AppColors.text(isDark),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      offer.scoutTeam,
                      style: TextStyle(
                        color: AppColors.textMuted(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(status: st, isDark: isDark),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Para: ${offer.playerName} (${offer.playerId})',
            style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            offer.terms,
            style: TextStyle(
              color: AppColors.textMuted(isDark),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          if (offer.playerIsMinor) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: Colors.orange,
                  size: 13,
                ),
                const SizedBox(width: 6),
                Text(
                  'Menor — requiere tu aprobación obligatoria',
                  style: TextStyle(
                    color: Colors.orange.withValues(alpha: 0.9),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
          if (st == _OfferStatus.pending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ActionBtn(
                    label: 'APROBAR',
                    color: AppColors.buttonBg(isDark),
                    textColor: AppColors.buttonFg(isDark),
                    onTap: onApprove,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionBtn(
                    label: 'RECHAZAR',
                    color: Colors.transparent,
                    textColor: Colors.red,
                    border: Colors.red.withValues(alpha: 0.3),
                    onTap: onReject,
                  ),
                ),
              ],
            ),
          ],
          if (st == _OfferStatus.approved && !offer.signed) ...[
            const SizedBox(height: 12),
            _ActionBtn(
              label: 'FIRMA DIGITAL DEL TUTOR ✍️',
              color: AppColors.buttonBg(isDark),
              textColor: AppColors.buttonFg(isDark),
              onTap: onSign,
            ),
          ],
          if (st == _OfferStatus.approved && offer.signed) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.verified, color: Colors.green, size: 13),
                const SizedBox(width: 6),
                const Text(
                  'Firmado digitalmente · Enviado a SportLink Chain',
                  style: TextStyle(color: Colors.green, fontSize: 11),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final _OfferStatus status;
  final bool isDark;
  const _StatusPill({required this.status, required this.isDark});
  @override
  Widget build(BuildContext context) {
    final label = status == _OfferStatus.pending
        ? 'PENDIENTE'
        : status == _OfferStatus.approved
        ? 'APROBADA'
        : 'RECHAZADA';
    final color = status == _OfferStatus.pending
        ? Colors.orange
        : status == _OfferStatus.approved
        ? Colors.green
        : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color, textColor;
  final Color? border;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.border,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          border: border != null ? Border.all(color: border!) : null,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _SignatureDialog extends StatelessWidget {
  final bool isDark;
  final VoidCallback onSign;
  const _SignatureDialog({required this.isDark, required this.onSign});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface(isDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Firma Digital',
        style: TextStyle(
          color: AppColors.text(isDark),
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        'Al confirmar, otorgas permiso legal de juego a Marco Silva (SLP-0982) para la temporada 2026/27. Esta acción queda registrada en SportLink Chain.',
        style: TextStyle(
          color: AppColors.textMuted(isDark),
          fontSize: 13,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: TextStyle(color: AppColors.textMuted(isDark)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onSign();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonBg(isDark),
            foregroundColor: AppColors.buttonFg(isDark),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Firmar y Confirmar'),
        ),
      ],
    );
  }
}
