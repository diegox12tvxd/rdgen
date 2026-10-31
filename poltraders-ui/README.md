# Diseño PolTraders para PolTraders Soporte

Le pone a la app (RustDesk) el diseño de PolTraders Academy: negro y dorado, letra Poppins,
paneles de vidrio, botones dorados y el fondo animado de velas.

- `lib/` — piezas nuevas en Flutter: `pt_background.dart` (fondo animado), `pt_widgets.dart`
  (vidrio y botón dorado), `pt_theme.dart` (colores). Se copian a `flutter/lib/poltraders/`.
- `fonts/` — Poppins (licencia OFL, ver `OFL.txt`).
- `apply.py` — copia lo anterior y cambia colores y pantallas de RustDesk (ventana principal,
  tarjeta de conexión y ventana de Aceptar). Cada cambio busca un texto exacto: si RustDesk
  lo cambia en otra versión, se detiene con error.

`.github/workflows/generator-windows.yml` lo ejecuta justo después de bajar el código de RustDesk.

Probar sin fabricar (en un clon de rustdesk con Flutter 3.24.5):

```
python apply.py <carpeta de rustdesk>
cd <carpeta de rustdesk>/flutter && flutter analyze lib
```

Código base: [RustDesk](https://github.com/rustdesk/rustdesk) (AGPL-3.0).
