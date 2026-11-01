#!/usr/bin/env python3
"""Pone el diseño de PolTraders Academy (negro y dorado, vidrio, fondo animado de velas)
en la interfaz Flutter de RustDesk antes de compilar PolTraders Soporte.

Uso: python3 apply.py <carpeta con el código de rustdesk>

Cada texto que se reemplaza se busca un número exacto de veces. Si RustDesk cambió esa parte,
el script se detiene con error para que la fabricación falle enseguida y no salga una app a medias.
"""
import shutil
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()
FLUTTER = ROOT / 'flutter'


def patch(rel, pairs):
    """Reemplaza cada (viejo, nuevo[, veces]) en flutter/<rel>, respetando los saltos de línea del archivo."""
    path = FLUTTER / rel
    raw = path.read_bytes().decode('utf-8')
    crlf = '\r\n' in raw
    text = raw.replace('\r\n', '\n')
    for item in pairs:
        old, new = item[0], item[1]
        expected = item[2] if len(item) > 2 else 1
        found = text.count(old)
        if found != expected:
            sys.exit(f'apply.py: en {rel} se esperaba {expected} vez/veces y aparece {found}:\n{old}')
        text = text.replace(old, new)
    if crlf:
        text = text.replace('\n', '\r\n')
    path.write_bytes(text.encode('utf-8'))
    print(f'  {rel}: {len(pairs)} cambio(s)')


GOLD_BAR = 'BoxDecoration(gradient: ptGoldGradient, borderRadius: BorderRadius.all(Radius.circular(2)))'


def main():
    if not (FLUTTER / 'pubspec.yaml').is_file():
        sys.exit(f'apply.py: no encuentro flutter/pubspec.yaml en {ROOT}')
    print('Diseño PolTraders:')

    # Piezas nuevas: fondo animado, vidrio, botón dorado y colores
    dest = FLUTTER / 'lib' / 'poltraders'
    dest.mkdir(parents=True, exist_ok=True)
    for f in (HERE / 'lib').glob('*.dart'):
        shutil.copy2(f, dest / f.name)

    # Letra Poppins (la de la Academy), licencia OFL
    fonts = FLUTTER / 'assets' / 'fonts'
    fonts.mkdir(parents=True, exist_ok=True)
    for f in (HERE / 'fonts').iterdir():
        shutil.copy2(f, fonts / f.name)
    patch('pubspec.yaml', [
        ('\n  fonts:\n',
         '\n  fonts:\n'
         '    - family: Poppins\n'
         '      fonts:\n'
         '        - asset: assets/fonts/Poppins-Regular.ttf\n'
         '        - asset: assets/fonts/Poppins-Medium.ttf\n'
         '          weight: 500\n'
         '        - asset: assets/fonts/Poppins-SemiBold.ttf\n'
         '          weight: 600\n'
         '        - asset: assets/fonts/Poppins-Bold.ttf\n'
         '          weight: 700\n'),
    ])

    # Colores de la app: el azul pasa a dorado y los grises a negro cálido
    patch('lib/common.dart', [
        ('  static const Color accent = Color(0xFF0071FF);\n'
         '  static const Color accent50 = Color(0x770071FF);\n'
         '  static const Color accent80 = Color(0xAA0071FF);\n',
         '  static const Color accent = Color(0xFFD4A843);\n'
         '  static const Color accent50 = Color(0x77D4A843);\n'
         '  static const Color accent80 = Color(0xAAD4A843);\n'),
        ('  static const Color idColor = Color(0xFF00B6F0);\n',
         '  static const Color idColor = Color(0xFFF6D98A);\n'),
        ('  static const Color button = Color(0xFF2C8CFF);\n',
         '  static const Color button = Color(0xFFD4A843);\n'),
        ("    useMaterial3: false,\n",
         "    useMaterial3: false,\n    fontFamily: 'Poppins',\n", 2),
        # Tema claro: botón dorado con texto oscuro y acento dorado
        ('        backgroundColor: MyTheme.accent,\n        shape: RoundedRectangleBorder(\n',
         '        backgroundColor: MyTheme.accent,\n        foregroundColor: Color(0xFF1A1306),\n'
         '        shape: RoundedRectangleBorder(\n'),
        ('primary: Colors.blue, secondary: accent, background: grayBg),',
         'primary: accent, secondary: accent, background: grayBg),'),
        # Tema oscuro (el que usa la app)
        ('    scaffoldBackgroundColor: Color(0xFF18191E),\n    dialogBackgroundColor: Color(0xFF18191E),\n',
         '    scaffoldBackgroundColor: Color(0xFF0B0A09),\n    dialogBackgroundColor: Color(0xFF15120E),\n'),
        ('    hoverColor: Color.fromARGB(255, 45, 46, 53),\n',
         '    hoverColor: Color(0xFF2A241B),\n'),
        ('          width: 1,\n          color: Color(0xFF24252B),\n',
         '          width: 1,\n          color: Color(0x40D4A843),\n'),
        ('            fillColor: Color(0xFF24252B),\n',
         '            fillColor: Color(0xFF1A1612),\n'),
        ('    cardColor: Color(0xFF24252B),\n',
         '    cardColor: Color(0xFF15120F),\n'),
        ('        backgroundColor: MyTheme.accent,\n        foregroundColor: Colors.white,\n',
         '        backgroundColor: MyTheme.accent,\n        foregroundColor: Color(0xFF1A1306),\n'),
        ('        backgroundColor: Color(0xFF24252B),\n        side: BorderSide(color: Colors.white12, width: 0.5),\n',
         '        backgroundColor: Color(0xFF1A1612),\n        side: BorderSide(color: Colors.white12, width: 0.5),\n'),
        ('MaterialStatePropertyAll(Color(0xFF121212))',
         'MaterialStatePropertyAll(Color(0xFF0E0C0A))'),
        ('      primary: Colors.blue,\n      secondary: accent,\n      background: Color(0xFF24252B),\n',
         '      primary: accent,\n      secondary: accent,\n      background: Color(0xFF0E0C0A),\n'),
        ('    border: Color(0xFF555555),\n', '    border: Color(0xFF3A3122),\n'),
        ('    highlight: Color(0xFF3F3F3F),\n', '    highlight: Color(0xFF2A241B),\n'),
    ])

    patch('lib/desktop/widgets/tabbar_widget.dart', [
        ('      unSelectedTabIconColor: Color.fromARGB(255, 30, 65, 98),\n',
         '      unSelectedTabIconColor: Color.fromARGB(255, 120, 96, 44),\n'),
        ('      dividerColor: Color.fromARGB(255, 64, 64, 64),\n',
         '      dividerColor: Color.fromARGB(255, 48, 41, 31),\n'),
    ])

    # Ventana principal: fondo animado detrás, panel izquierdo de vidrio, ID dorado
    patch('lib/desktop/pages/desktop_home_page.dart', [
        ("import 'package:flutter_hbb/common.dart';\n",
         "import 'package:flutter_hbb/common.dart';\n"
         "import 'package:flutter_hbb/poltraders/pt_background.dart';\n"
         "import 'package:flutter_hbb/poltraders/pt_theme.dart';\n"
         "import 'package:flutter_hbb/poltraders/pt_widgets.dart';\n"),
        ('    return _buildBlock(\n'
         '        child: Row(\n'
         '      crossAxisAlignment: CrossAxisAlignment.start,\n'
         '      children: [\n'
         '        buildLeftPane(context),\n'
         '        if (!isIncomingOnly) const VerticalDivider(width: 1),\n'
         '        if (!isIncomingOnly) Expanded(child: buildRightPane(context)),\n'
         '      ],\n'
         '    ));\n',
         '    return _buildBlock(\n'
         '        child: PtBackground(\n'
         '            child: Row(\n'
         '      crossAxisAlignment: CrossAxisAlignment.start,\n'
         '      children: [\n'
         '        buildLeftPane(context),\n'
         '        if (!isIncomingOnly) Expanded(child: buildRightPane(context)),\n'
         '      ],\n'
         '    )));\n'),
        ('      child: Container(\n'
         '        width: isIncomingOnly ? 280.0 : 200.0,\n'
         '        color: Theme.of(context).colorScheme.background,\n'
         '        child: Stack(\n',
         '      child: PtGlass(\n'
         '        width: isIncomingOnly ? 280.0 : 200.0,\n'
         '        margin: isIncomingOnly ? null : const EdgeInsets.fromLTRB(10, 10, 0, 10),\n'
         '        child: Stack(\n'),
        ('      color: Theme.of(context).scaffoldBackgroundColor,\n      child: ConnectionPage(),\n',
         '      color: Colors.transparent,\n      child: ConnectionPage(),\n'),
        ('            decoration: const BoxDecoration(color: MyTheme.accent),\n',
         f'            decoration: const {GOLD_BAR},\n'),
        ('                        style: TextStyle(\n'
         '                          fontSize: 22,\n'
         '                        ),\n',
         '                        style: TextStyle(\n'
         '                          fontSize: 22,\n'
         '                          fontWeight: FontWeight.w600,\n'
         '                          color: ptGoldHi,\n'
         '                          letterSpacing: 0.5,\n'
         '                        ),\n'),
        ('            decoration: BoxDecoration(color: MyTheme.accent),\n',
         f'            decoration: const {GOLD_BAR},\n'),
        # Sin la tarjeta que pide instalar la app: PolTraders Soporte se usa sin instalar
        ('      if (!bind.mainIsInstalled()) {\n'
         '        return buildInstallCard(\n'
         '            "", bind.isOutgoingOnly() ? "" : "install_tip", "Install",\n'
         '            () async {\n'
         '          await rustDeskWinManager.closeAllSubWindows();\n'
         '          bind.mainGotoInstall();\n'
         '        });\n'
         '      } else if (bind.mainIsInstalledLowerVersion()) {\n',
         '      if (bind.mainIsInstalled() && bind.mainIsInstalledLowerVersion()) {\n'),
        # Los avisos que quedan, en dorado oscuro en lugar de rosa
        ('                colors: [\n'
         '                  Color.fromARGB(255, 226, 66, 188),\n'
         '                  Color.fromARGB(255, 244, 114, 124),\n'
         '                ],\n',
         '                colors: [\n'
         '                  Color(0xFF3A2E17),\n'
         '                  Color(0xFF15110C),\n'
         '                ],\n'),
    ])

    # Tarjeta "Controlar escritorio remoto": vidrio y botón Conectar dorado
    patch('lib/desktop/pages/connection_page.dart', [
        ("import 'package:flutter_hbb/models/peer_model.dart';\n",
         "import 'package:flutter_hbb/models/peer_model.dart';\n"
         "import 'package:flutter_hbb/poltraders/pt_widgets.dart';\n"),
        ('    var w = Container(\n'
         '      width: 320 + 20 * 2,\n'
         '      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),\n'
         '      decoration: BoxDecoration(\n'
         '          borderRadius: const BorderRadius.all(Radius.circular(13)),\n'
         '          border: Border.all(color: Theme.of(context).colorScheme.background)),\n'
         '      child: Ink(\n',
         '    var w = PtGlass(\n'
         '      width: 320 + 20 * 2,\n'
         '      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),\n'
         '      child: Ink(\n'),
        ('                  child: ElevatedButton(\n'
         '                    onPressed: () {\n'
         '                      onConnect();\n'
         '                    },\n'
         '                    child: Text(translate("Connect")),\n',
         '                  child: PtGoldButton(\n'
         '                    onPressed: () {\n'
         '                      onConnect();\n'
         '                    },\n'
         '                    child: Text(translate("Connect")),\n'),
    ])

    # Ventana que ve el cliente al recibir la conexión: fondo animado, encabezado y Aceptar dorados
    patch('lib/desktop/pages/server_page.dart', [
        ("import '../../common.dart';\n",
         "import '../../common.dart';\n"
         "import 'package:flutter_hbb/poltraders/pt_background.dart';\n"
         "import 'package:flutter_hbb/poltraders/pt_theme.dart';\n"),
        ('          final body = Scaffold(\n'
         '            backgroundColor: Theme.of(context).colorScheme.background,\n'
         '            body: ConnectionManager(),\n'
         '          );\n',
         '          final body = Scaffold(\n'
         '            backgroundColor: ptBlack,\n'
         '            body: PtBackground(child: ConnectionManager()),\n'
         '          );\n'),
        ('        borderRadius: BorderRadius.circular(10.0),\n'
         '        gradient: LinearGradient(\n'
         '          begin: Alignment.topRight,\n'
         '          end: Alignment.bottomLeft,\n'
         '          colors: [\n'
         '            Color(0xff00bfe1),\n'
         '            Color(0xff0071ff),\n'
         '          ],\n',
         '        borderRadius: BorderRadius.circular(14.0),\n'
         '        border: Border.all(color: Color(0x55D4A843)),\n'
         '        gradient: LinearGradient(\n'
         '          begin: Alignment.topRight,\n'
         '          end: Alignment.bottomLeft,\n'
         '          colors: [\n'
         '            Color(0xFF3A2E17),\n'
         '            Color(0xFF15110C),\n'
         '          ],\n'),
        ('    assert(!(onClick == null && onTapDown == null));\n    Widget textWidget;\n',
         '    assert(!(onClick == null && onTapDown == null));\n'
         '    // Los botones con el color de acento (Aceptar, etc.) van dorados como en la Academy\n'
         '    final gold = color == MyTheme.accent;\n'
         '    Widget textWidget;\n'),
        ('        style: TextStyle(color: textColor),\n',
         '        style: gold\n'
         '            ? const TextStyle(color: ptGoldInk, fontWeight: FontWeight.w600)\n'
         '            : TextStyle(color: textColor),\n', 2),
        ('    final borderRadius = BorderRadius.circular(10.0);\n'
         '    final btn = Container(\n'
         '      height: 28,\n'
         '      decoration: BoxDecoration(\n'
         '          color: color, borderRadius: borderRadius, border: border),\n',
         '    final borderRadius = BorderRadius.circular(14.0);\n'
         '    final btn = Container(\n'
         '      height: 28,\n'
         '      decoration: BoxDecoration(\n'
         '          color: gold ? null : color,\n'
         '          gradient: gold ? ptGoldGradient : null,\n'
         '          borderRadius: borderRadius,\n'
         '          border: border),\n'),
    ])
    print('Diseño PolTraders aplicado.')


if __name__ == '__main__':
    main()
