// Fondo animado de PolTraders Soporte: el mismo de PolTraders Academy (AnimatedBackground.jsx)
// pasado a Flutter. Luces doradas, cuadrícula, línea de precio, estrellas y velas flotando.
// Se detiene con la ventana minimizada y queda quieto si Windows tiene las animaciones apagadas.
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'pt_theme.dart';

class PtBackground extends StatefulWidget {
  const PtBackground({super.key, required this.child});

  final Widget child;

  @override
  State<PtBackground> createState() => _PtBackgroundState();
}

class _PtBackgroundState extends State<PtBackground>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // Basta con ~30 cuadros por segundo para un movimiento tan lento
  static const _frame = Duration(microseconds: 1000000 ~/ 30);

  late final Ticker _ticker = createTicker(_tick);
  final _scene = _Scene();
  final _repaint = ValueNotifier<int>(0);
  Duration _last = Duration.zero;
  bool _visible = true;
  bool _still = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _visible = state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive;
    _sync();
  }

  void _sync() {
    final run = _visible && !_still;
    if (run && !_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    } else if (!run && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _tick(Duration elapsed) {
    final step = elapsed - _last;
    if (step < _frame) return;
    _last = elapsed;
    _scene.advance(math.min(0.1, step.inMicroseconds / 1e6));
    _repaint.value++;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _repaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      opaque: false,
      onHover: (e) {
        final size = context.size;
        if (size == null || size.isEmpty) return;
        _scene.pointerTarget = Offset(
          e.localPosition.dx / size.width * 2 - 1,
          e.localPosition.dy / size.height * 2 - 1,
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(painter: _Painter(_scene, _repaint)),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _Painter extends CustomPainter {
  _Painter(this.scene, Listenable repaint) : super(repaint: repaint);

  final _Scene scene;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    scene.paint(canvas, size);
  }

  @override
  bool shouldRepaint(_Painter oldDelegate) => oldDelegate.scene != scene;
}

/// Luz dorada que se mueve despacio (orb-a … orb-d de la Academy).
class _Orb {
  const _Orb(this.color, this.alpha, this.size, this.left, this.top,
      this.seconds, this.keys);

  final Color color;
  final double alpha;
  final double size; // vmax
  final double left; // vw
  final double top; // vh
  final double seconds;
  final List<List<double>> keys; // [desplazamiento vw, desplazamiento vh, escala] al 0 %, 50 % y 100 %
}

const _orbs = [
  _Orb(Color(0xFFD4A843), 0.42, 62, -12, -18, 34, [
    [0, 0, 1],
    [20, 14, 1.15],
    [6, 32, 0.9],
  ]),
  _Orb(Color(0xFFAA7438), 0.40, 54, 52, 4, 41, [
    [0, 0, 1.1],
    [-24, 20, 0.9],
    [-8, -6, 1.2],
  ]),
  _Orb(Color(0xFFF6D98A), 0.22, 42, 60, 58, 37, [
    [0, 0, 1],
    [-30, -18, 1.2],
    [-12, 6, 0.95],
  ]),
  _Orb(Color(0xFFE29230), 0.30, 38, 2, 60, 46, [
    [0, 0, 0.95],
    [26, -24, 1.1],
    [40, 4, 1],
  ]),
];

// Velas alcistas en oro claro y bajistas en bronce (colores de marca: negro y dorado)
const _candleUp = Color(0xFFF2CE70);
const _candleDown = Color(0xFF9E682C);

class _Star {
  _Star(this.x, this.y, this.z, this.r, this.phase);

  double x;
  double y;
  final double z;
  final double r;
  final double phase;
}

/// Vela japonesa flotante; z es la profundidad (0 = lejos, 1 = cerca).
class _Candle {
  _Candle({
    required this.z,
    required this.up,
    required this.width,
    required this.body,
    required this.wickTop,
    required this.wickBottom,
    required this.x,
    required this.y,
    required this.speed,
    required this.sway,
    required this.swayAmp,
    required this.tilt,
  });

  final double z;
  final bool up;
  final double width;
  final double body;
  final double wickTop;
  final double wickBottom;
  final double x;
  double y;
  final double speed;
  double sway;
  final double swayAmp;
  final double tilt;

  double get height => wickTop + body + wickBottom;
}

class _Scene {
  final _rnd = math.Random();
  Size _size = Size.zero;
  double _t = 0;
  Offset _pointer = Offset.zero;
  Offset pointerTarget = Offset.zero;

  List<_Star> _stars = [];
  List<_Candle> _candles = [];
  // Línea de precio que avanza de derecha a izquierda, como un gráfico en vivo
  final _linePoints = <double>[];
  double _lineOffset = 0;
  double _lineBase = 0;
  double _lineValue = 0;
  static const _lineStep = 28.0;
  static const _lineSpeed = 16.0;

  Path _grid = Path();

  double _rand(double a, double b) => a + _rnd.nextDouble() * (b - a);

  void _build(Size s) {
    _size = s;
    final w = s.width, h = s.height;
    _stars = List.generate(
      (w * h / 16000).round(),
      (_) => _Star(_rand(0, w), _rand(0, h), _rand(0.2, 1), _rand(0.5, 1.5),
          _rand(0, math.pi * 2)),
    );
    _candles = List.generate(w < 700 ? 8 : 15, (_) => _makeCandle(true))
      ..sort((a, b) => a.z.compareTo(b.z));

    _lineBase = h * 0.66;
    _lineValue = _lineBase;
    _lineOffset = 0;
    _linePoints
      ..clear()
      ..addAll(List.generate((w / _lineStep).ceil() + 3, (_) => _nextPrice()));

    // Cuadrícula tipo terminal de trading (cada 56 px)
    _grid = Path();
    for (var x = 0.0; x <= w; x += 56) {
      _grid
        ..moveTo(x + 0.5, 0)
        ..lineTo(x + 0.5, h);
    }
    for (var y = 0.0; y <= h; y += 56) {
      _grid
        ..moveTo(0, y + 0.5)
        ..lineTo(w, y + 0.5);
    }
  }

  _Candle _makeCandle(bool anywhere, [double? depth]) {
    final z = depth ?? _rand(0.2, 1);
    return _Candle(
      z: z,
      up: _rnd.nextDouble() > 0.4,
      width: 5 + 9 * z,
      body: 10 + _rand(14, 46) * z,
      wickTop: 3 + _rand(5, 20) * z,
      wickBottom: 3 + _rand(5, 20) * z,
      x: _rand(0, _size.width),
      y: anywhere ? _rand(0, _size.height) : _size.height + 100,
      speed: _rand(5, 13) * (0.35 + z),
      sway: _rand(0, math.pi * 2),
      swayAmp: _rand(4, 16) * z,
      tilt: _rand(-0.18, 0.18),
    );
  }

  double _nextPrice() {
    _lineValue += _rand(-1, 1) * _size.height * 0.03 +
        (_lineBase - _lineValue) * 0.08;
    return _lineValue;
  }

  void advance(double dt) {
    if (_size.isEmpty) return;
    _t += dt;
    _pointer += (pointerTarget - _pointer) * 0.05;

    _lineOffset += _lineSpeed * dt;
    while (_lineOffset >= _lineStep) {
      _lineOffset -= _lineStep;
      _linePoints.removeAt(0);
      _linePoints.add(_nextPrice());
    }

    // Estrellas que suben despacio
    for (final s in _stars) {
      s.y -= 4 * s.z * dt;
      if (s.y < -4) {
        s.y = _size.height + 4;
        s.x = _rand(0, _size.width);
      }
    }

    for (var i = 0; i < _candles.length; i++) {
      final c = _candles[i];
      c.y -= c.speed * dt;
      c.sway += dt * 0.5;
      // Reaparece abajo con la misma profundidad para conservar el orden de dibujo
      if (c.y < -(c.height + 52)) _candles[i] = _makeCandle(false, c.z);
    }
  }

  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    if (size != _size) _build(size);
    final w = size.width, h = size.height;

    canvas.drawRect(Offset.zero & size, Paint()..color = ptBlack);
    _paintOrbs(canvas, size);

    // Cuadrícula desvanecida hacia los bordes
    canvas.drawPath(
      _grid,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = _ellipse(
          Offset(w * 0.5, h * 0.45),
          w * 0.75,
          h * 0.65,
          const [Color(0x0FD4A843), Color(0x00D4A843)],
          const [0.15, 0.75],
        ),
    );

    _paintLine(canvas, size);

    // Estrellas que titilan
    final star = Paint();
    for (final s in _stars) {
      final a = (0.15 + 0.6 * (0.5 + 0.5 * math.sin(_t * 1.4 + s.phase))) * s.z;
      star.color = const Color(0xFFF6E7C1).withOpacity(a.clamp(0.0, 1.0).toDouble());
      canvas.drawCircle(
        Offset(s.x + _pointer.dx * 12 * s.z, s.y + _pointer.dy * 12 * s.z),
        s.r * s.z,
        star,
      );
    }

    // Velas (las lejanas primero)
    for (final c in _candles) {
      _paintCandle(canvas, c);
    }

    // Viñeta: bordes y parte de arriba más oscuros
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = _ellipse(
          Offset(w * 0.5, h * 0.45),
          w * 0.9,
          h * 0.8,
          const [Color(0x00000000), Color(0xA6000000)],
          const [0.45, 1],
        ),
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, h),
          const [Color(0x73000000), Color(0x00000000)],
          const [0, 0.18],
        ),
    );
  }

  /// Degradado radial elíptico (como radial-gradient(ellipse rx ry at cx cy) en CSS).
  ui.Gradient _ellipse(Offset center, double rx, double ry, List<Color> colors,
      List<double> stops) {
    final m = Matrix4.identity()
      ..translate(center.dx, center.dy)
      ..scale(rx, ry);
    return ui.Gradient.radial(
        Offset.zero, 1, colors, stops, TileMode.clamp, m.storage);
  }

  void _paintOrbs(Canvas canvas, Size s) {
    final vw = s.width / 100, vh = s.height / 100;
    final vmax = math.max(s.width, s.height) / 100;
    final shift = Offset(-_pointer.dx * 24, -_pointer.dy * 24);
    for (final o in _orbs) {
      // Va y vuelve (alternate) con ease-in-out en cada tramo, como la animación CSS
      var p = (_t / o.seconds) % 2;
      if (p > 1) p = 2 - p;
      final half = p < 0.5 ? 0 : 1;
      final u = Curves.easeInOut.transform(half == 0 ? p * 2 : (p - 0.5) * 2);
      final a = o.keys[half], b = o.keys[half + 1];
      double at(int i) => a[i] + (b[i] - a[i]) * u;

      final side = o.size * vmax;
      final center = Offset(
            -0.06 * s.width + o.left * vw + side / 2 + at(0) * vw,
            -0.06 * s.height + o.top * vh + side / 2 + at(1) * vh,
          ) +
          shift;
      final r = side * math.sqrt2 / 2 * at(2);
      canvas.drawCircle(
        center,
        r * 0.68,
        Paint()
          ..blendMode = BlendMode.screen
          ..shader = ui.Gradient.radial(center, r, [
            o.color.withOpacity(o.alpha),
            o.color.withOpacity(o.alpha * 0.36),
            o.color.withOpacity(0),
          ], const [
            0,
            0.38,
            0.68
          ]),
      );
    }
  }

  void _paintLine(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    double px(int i) => i * _lineStep - _lineOffset + _pointer.dx * 8;
    double py(double v) => v + _pointer.dy * 8;

    final path = Path()..moveTo(px(0), py(_linePoints[0]));
    for (var i = 1; i < _linePoints.length - 1; i++) {
      final mx = (px(i) + px(i + 1)) / 2;
      final my = (py(_linePoints[i]) + py(_linePoints[i + 1])) / 2;
      path.quadraticBezierTo(px(i), py(_linePoints[i]), mx, my);
    }

    final stroke = ui.Gradient.linear(
      Offset.zero,
      Offset(w, 0),
      const [
        Color(0x00D4A843),
        Color(0x8CD4A843),
        Color(0x99F6D98A),
        Color(0x00F6D98A),
      ],
      const [0, 0.3, 0.75, 1],
    );
    // Brillo y trazo
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..shader = stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..shader = stroke,
    );

    final area = Path.from(path)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, _lineBase - h * 0.1),
          Offset(0, h),
          const [Color(0x14D4A843), Color(0x00D4A843)],
        ),
    );
  }

  void _paintCandle(Canvas canvas, _Candle c) {
    final color = c.up ? _candleUp : _candleDown;
    final alpha = 0.2 + 0.6 * c.z;
    final x = c.x + math.sin(c.sway) * c.swayAmp + _pointer.dx * 36 * c.z;
    final y = c.y + _pointer.dy * 26 * c.z;
    final top = -c.height / 2;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(-c.width / 2, top + c.wickTop, c.width, c.body),
      Radius.circular(math.min(3.0, c.width / 3)),
    );
    // Las velas lejanas se ven desenfocadas
    final soft = c.z < 0.55
        ? MaskFilter.blur(BlurStyle.normal, (0.55 - c.z) * 6)
        : null;

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(c.tilt + math.sin(c.sway * 0.7) * 0.06);

    canvas.drawRRect(
      body.inflate(1),
      Paint()
        ..color = color.withOpacity(0.5 * alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 + 8 * c.z),
    );
    canvas.drawLine(
      Offset(0, top),
      Offset(0, top + c.height),
      Paint()
        ..color = color.withOpacity(0.85 * alpha)
        ..strokeWidth = math.max(1.0, c.width * 0.16)
        ..strokeCap = StrokeCap.round
        ..maskFilter = soft,
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, body.top),
          Offset(0, body.bottom),
          [color.withOpacity(0.95 * alpha), color.withOpacity(0.5 * alpha)],
        )
        ..maskFilter = soft,
    );
    canvas.drawRect(
      Rect.fromLTWH(-c.width / 2 + 1.5, body.top + 2,
          math.max(1.0, c.width * 0.18), math.max(0.0, c.body - 4)),
      Paint()..color = Colors.white.withOpacity(0.35 * alpha),
    );
    canvas.restore();
  }
}
