// Piezas con el estilo de PolTraders Academy: panel de vidrio esmerilado y botón dorado.
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'pt_theme.dart';

/// Panel de vidrio: desenfoca lo que tiene detrás (el fondo animado) y pone encima el degradado claro.
class PtGlass extends StatelessWidget {
  const PtGlass({
    super.key,
    required this.child,
    this.radius = 22,
    this.width,
    this.padding,
    this.margin,
  });

  final Widget child;
  final double radius;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    final Widget glass = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            offset: Offset(0, 30),
            blurRadius: 60,
            spreadRadius: -30,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: width,
            padding: padding,
            decoration: ptGlassDecoration(radius: radius),
            child: child,
          ),
        ),
      ),
    );
    return margin == null ? glass : Padding(padding: margin!, child: glass);
  }
}

/// Botón principal dorado (.btn-primary de la Academy): se aclara al pasar el ratón
/// y se hunde un poco al hacer clic.
class PtGoldButton extends StatefulWidget {
  const PtGoldButton({super.key, required this.onPressed, required this.child});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  State<PtGoldButton> createState() => _PtGoldButtonState();
}

class _PtGoldButtonState extends State<PtGoldButton> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _down = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _down ? 0.97 : 1,
          duration: const Duration(milliseconds: 150),
          curve: ptEaseOut,
          child: Opacity(
            opacity: enabled ? 1 : 0.45,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: _hover && enabled ? ptGoldGradientHover : ptGoldGradient,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xCCD4A843),
                    offset: Offset(0, 10),
                    blurRadius: 28,
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Center(
                  widthFactor: 1,
                  child: IconTheme.merge(
                    data: const IconThemeData(color: ptGoldInk, size: 16),
                    child: DefaultTextStyle.merge(
                      style: const TextStyle(
                        color: ptGoldInk,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
