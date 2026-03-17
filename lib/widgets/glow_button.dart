import 'package:flutter/material.dart';

/// GlowButton: botón con animación de escala al presionar
/// y un barrido de brillo (shimmer) al estar seleccionado.
class GlowButton extends StatefulWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;
  final EdgeInsets? padding;
  final double borderRadius;
  final TextStyle? labelStyle;
  final Widget? icon;

  const GlowButton({
    super.key,
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
    this.padding,
    this.borderRadius = 20,
    this.labelStyle,
    this.icon,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerCtrl;
  late final Animation<double> _shimmerAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _shimmerAnim = Tween<double>(
      begin: -1.5,
      end: 2.5,
    ).animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));
    if (widget.selected) _startShimmer();
  }

  @override
  void didUpdateWidget(GlowButton old) {
    super.didUpdateWidget(old);
    if (widget.selected && !old.selected) {
      _startShimmer();
    } else if (!widget.selected && old.selected) {
      _shimmerCtrl.stop();
    }
  }

  void _startShimmer() {
    _shimmerCtrl.repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.selected
        ? _activeBg(widget.isDark)
        : _inactiveBg(widget.isDark);
    final fg = widget.selected
        ? _activeFg(widget.isDark)
        : _inactiveFg(widget.isDark);
    final borderC = widget.selected
        ? _activeBg(widget.isDark)
        : _borderC(widget.isDark);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: borderC, width: 1.3),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: _activeBg(widget.isDark).withOpacity(0.35),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Contenido principal
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      widget.icon!,
                      const SizedBox(width: 6),
                    ],
                    Text(
                      widget.label,
                      style: (widget.labelStyle ?? const TextStyle()).copyWith(
                        color: fg,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                // Capa shimmer solo cuando está seleccionado
                if (widget.selected)
                  AnimatedBuilder(
                    animation: _shimmerAnim,
                    builder: (_, __) {
                      return ShaderMask(
                        blendMode: BlendMode.srcATop,
                        shaderCallback: (bounds) {
                          final x = _shimmerAnim.value * bounds.width;
                          return LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.22),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                            begin: Alignment(x / bounds.width - 0.3, -1),
                            end: Alignment(x / bounds.width + 0.3, 1),
                          ).createShader(bounds);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.01),
                            borderRadius: BorderRadius.circular(
                              widget.borderRadius,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _activeBg(bool isDark) => isDark ? Colors.white : Colors.black;
  static Color _activeFg(bool isDark) => isDark ? Colors.black : Colors.white;
  static Color _inactiveBg(bool isDark) =>
      isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
  static Color _inactiveFg(bool isDark) =>
      isDark ? const Color(0xFF8E8E93) : const Color(0xFF636366);
  static Color _borderC(bool isDark) =>
      isDark ? const Color(0xFF3A3A3C) : const Color(0xFFD1D1D6);
}

/// Versión para botones de acción primaria (CTA) — fondo de acento con shimmer.
class GlowCTAButton extends StatefulWidget {
  final String label;
  final bool isDark;
  final bool loading;
  final VoidCallback? onTap;
  final Color? accentColor;

  const GlowCTAButton({
    super.key,
    required this.label,
    required this.isDark,
    this.loading = false,
    this.onTap,
    this.accentColor,
  });

  @override
  State<GlowCTAButton> createState() => _GlowCTAButtonState();
}

class _GlowCTAButtonState extends State<GlowCTAButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _shimmer;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _shimmer = Tween<double>(
      begin: -2.0,
      end: 3.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.linear));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent =
        widget.accentColor ?? (widget.isDark ? Colors.white : Colors.black);
    final fg = widget.isDark ? Colors.black : Colors.white;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 130),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            color: widget.onTap == null ? accent.withOpacity(0.2) : accent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: widget.onTap != null
                ? [
                    BoxShadow(
                      color: accent.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shimmer sweep
              AnimatedBuilder(
                animation: _shimmer,
                builder: (_, __) => ShaderMask(
                  blendMode: BlendMode.srcATop,
                  shaderCallback: (b) => LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.2),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment(_shimmer.value - 0.5, -1),
                    end: Alignment(_shimmer.value + 0.5, 1),
                  ).createShader(b),
                  child: Container(color: Colors.transparent),
                ),
              ),
              // Label / Spinner
              widget.loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: fg,
                      ),
                    )
                  : Text(
                      widget.label,
                      style: TextStyle(
                        color: fg,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
