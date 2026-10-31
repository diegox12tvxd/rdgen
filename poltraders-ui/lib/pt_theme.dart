// Colores y curvas de PolTraders Soporte: los mismos de PolTraders Academy (negro y dorado).
import 'package:flutter/material.dart';

const Color ptBlack = Color(0xFF030304);
const Color ptGold = Color(0xFFD4A843);
const Color ptGoldHi = Color(0xFFF6D98A);
const Color ptGoldDeep = Color(0xFFB8862C);
const Color ptGoldInk = Color(0xFF1A1306);

/// Degradado del botón principal, de arriba hacia abajo (.btn-primary de la Academy).
const LinearGradient ptGoldGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [ptGoldHi, ptGold, ptGoldDeep],
  stops: [0, 0.55, 1],
);

const LinearGradient ptGoldGradientHover = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFFAE3A2), Color(0xFFDDB350), Color(0xFFC4922F)],
  stops: [0, 0.55, 1],
);

/// Curva fuerte de salida para responder a un clic.
const Cubic ptEaseOut = Cubic(0.23, 1, 0.32, 1);

/// Vidrio esmerilado (.glass de la Academy) sin el desenfoque, que lo agrega PtGlass.
BoxDecoration ptGlassDecoration({double radius = 22}) => BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: const LinearGradient(
        // 155 grados, como en la Academy
        begin: Alignment(-0.42, -1),
        end: Alignment(0.42, 1),
        colors: [Color(0x2BFFFFFF), Color(0x13FFFFFF), Color(0x0DFFFFFF)],
        stops: [0, 0.45, 1],
      ),
      border: Border.all(color: const Color(0x21FFFFFF)),
    );
