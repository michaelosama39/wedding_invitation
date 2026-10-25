import 'package:flutter/material.dart';

import '../theme.dart';

/// Centred column on the cream background, constrained to a readable width.
class SectionShell extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final bool doubleRules;
  final Decoration? decoration;
  final EdgeInsets padding;
  const SectionShell({
    super.key,
    required this.child,
    this.maxWidth = 672,
    this.doubleRules = false,
    this.decoration,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 96),
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: double.infinity,
      padding: padding,
      decoration: decoration ?? const BoxDecoration(color: AppColors.background),
      child: Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child)),
    );
    if (doubleRules) {
      content = DoubleRuleBox(color: AppColors.mauve.withValues(alpha: 0.25), child: content);
    }
    return content;
  }
}

/// Top and bottom double hairlines, like CSS `border-y-[3px] border-double`.
class DoubleRuleBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsets padding;
  const DoubleRuleBox({super.key, required this.child, required this.color, this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    Widget rule() => Column(children: [
          Container(height: 1, color: color),
          const SizedBox(height: 1),
          Container(height: 1, color: color),
        ]);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [rule(), Padding(padding: padding, child: child), rule()],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String? eyebrow;
  final String title;
  final double size;
  final Color color;
  final bool ornament;
  const SectionTitle({
    super.key,
    this.eyebrow,
    required this.title,
    this.size = 60,
    this.color = AppColors.foreground,
    this.ornament = true,
  });

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;
    return Column(
      children: [
        if (eyebrow != null) ...[
          Text(eyebrow!.toUpperCase(), style: AppText.label(12, color: color.withValues(alpha: 0.6))),
          const SizedBox(height: 14),
        ],
        Text(title, textAlign: TextAlign.center, style: AppText.script(narrow ? size * 0.8 : size, color: color)),
        if (ornament) ...[
          const SizedBox(height: 14),
          const GoldOrnament(),
        ],
        const SizedBox(height: 36),
      ],
    );
  }
}

/// Small gold flourish: a ring flanked by curling sprigs and fading rules.
class GoldOrnament extends StatelessWidget {
  final double width;
  final Color color;
  const GoldOrnament({super.key, this.width = 120, this.color = AppColors.gold});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(width, width * 22 / 120), painter: _OrnamentPainter(color));
}

class _OrnamentPainter extends CustomPainter {
  final Color color;
  _OrnamentPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 120;
    canvas.scale(s);
    final ring = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final line = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(const Offset(60, 12), 4, ring);
    for (final d in [-1.0, 1.0]) {
      final x0 = 60 + d * 8;
      canvas.drawPath(
        Path()
          ..moveTo(x0, 12)
          ..cubicTo(x0 + d * 8, 4, x0 + d * 16, 4, x0 + d * 20, 10)
          ..moveTo(x0 + d * 10, 7)
          ..quadraticBezierTo(x0 + d * 12, 2, x0 + d * 16, 3),
        line,
      );
      canvas.drawLine(Offset(x0 + d * 24, 12), Offset(60 + d * 58, 12), line..color = color.withValues(alpha: 0.35));
      line.color = color.withValues(alpha: 0.6);
    }
  }

  @override
  bool shouldRepaint(covariant _OrnamentPainter old) => old.color != color;
}

/// Shows an asset image if it exists, otherwise [fallback].
class AssetOr extends StatelessWidget {
  final String path;
  final Widget fallback;
  final BoxFit fit;
  const AssetOr(this.path, {super.key, required this.fallback, this.fit = BoxFit.contain});

  @override
  Widget build(BuildContext context) {
    return Image.asset(path, fit: fit, errorBuilder: (_, _, _) => fallback);
  }
}

/// Fades and slides its child in the first time it scrolls into view.
class Reveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const Reveal({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
  ScrollPosition? _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _position?.removeListener(_check);
    _position = Scrollable.maybeOf(context)?.position;
    _position?.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (!mounted || _c.isAnimating || _c.isCompleted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final top = box.localToGlobal(Offset.zero).dy;
    if (top < MediaQuery.sizeOf(context).height * 0.9) {
      _position?.removeListener(_check);
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_check);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(curve),
        child: widget.child,
      ),
    );
  }
}

/// Outlined pill button (`rounded-full border border-foreground/20`).
class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;
  const PillButton({super.key, required this.label, this.onPressed, this.icon, this.filled = false});

  @override
  Widget build(BuildContext context) {
    final fg = filled ? AppColors.background : AppColors.ink(0.8);
    return Material(
      color: filled ? AppColors.foreground : Colors.transparent,
      shape: StadiumBorder(side: BorderSide(color: filled ? AppColors.foreground : AppColors.ink(0.2))),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        hoverColor: AppColors.ink(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 16, color: fg), const SizedBox(width: 8)],
              Text(label, style: AppText.body(15, color: fg, height: 1.2)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Faint linen weave used behind the dress-code section.
class LinenTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.background);
    final h = Paint()..color = AppColors.foreground.withValues(alpha: 0.02);
    final v = Paint()..color = AppColors.foreground.withValues(alpha: 0.015);
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), h);
    }
    for (double x = 0; x < size.width; x += 4) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 1, size.height), v);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painted Tuscan landscape: used where no photo has been supplied.
class TuscanLandscapePainter extends CustomPainter {
  final double variant;
  final double sunRise;
  TuscanLandscapePainter({this.variant = 0, this.sunRise = 1});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(const Color(0xFFE9A7B6), const Color(0xFFD7A2C0), variant)!,
            const Color(0xFFF6CFCF),
            const Color(0xFFFCEAEA),
          ],
          stops: const [0, 0.45, 0.7],
        ).createShader(rect),
    );

    final sunC = Offset(w * (0.68 - variant * 0.3), h * (0.62 - 0.22 * sunRise));
    canvas.drawCircle(
      sunC,
      h * 0.22,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFFF1CF).withValues(alpha: 0.9),
          const Color(0xFFFFE2A8).withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(center: sunC, radius: h * 0.22)),
    );
    canvas.drawCircle(sunC, h * 0.06, Paint()..color = const Color(0xFFFFF4DC));

    void hill(double baseY, double amp, double phase, Color color) {
      final path = Path()
        ..moveTo(0, h)
        ..lineTo(0, h * baseY);
      const steps = 6;
      for (var i = 0; i < steps; i++) {
        final x0 = w * i / steps, x1 = w * (i + 1) / steps;
        final up = ((i + phase) % 2 == 0) ? -1 : 1;
        path.quadraticBezierTo((x0 + x1) / 2, h * (baseY + up * amp), x1, h * baseY);
      }
      path
        ..lineTo(w, h)
        ..close();
      canvas.drawPath(path, Paint()..color = color);
    }

    hill(0.62, 0.05, variant > 0.5 ? 1 : 0, const Color(0xFFBFA77A));
    hill(0.70, 0.06, 1, const Color(0xFFA19A62));
    hill(0.80, 0.05, 0, AppColors.olive);

    final cypress = Paint()..color = AppColors.cypress;
    final count = (w / 70).clamp(4, 14).round();
    for (var i = 0; i < count; i++) {
      final t = (i + 0.5) / count;
      final x = w * (0.1 + t * 0.55 + variant * 0.2);
      final baseY = h * (0.72 + 0.02 * ((i % 3) - 1));
      final th = h * (0.13 + 0.03 * (i % 2));
      canvas.drawOval(Rect.fromCenter(center: Offset(x, baseY - th / 2), width: th * 0.22, height: th), cypress);
    }

    final vx = w * (0.78 - variant * 0.5), vy = h * 0.70;
    final vw = w * 0.09, vh = h * 0.06;
    canvas.drawRect(Rect.fromLTWH(vx, vy - vh, vw, vh), Paint()..color = const Color(0xFFEBD7B3));
    canvas.drawPath(
      Path()
        ..moveTo(vx - vw * 0.08, vy - vh)
        ..lineTo(vx + vw / 2, vy - vh * 1.55)
        ..lineTo(vx + vw * 1.08, vy - vh)
        ..close(),
      Paint()..color = AppColors.rose,
    );
    canvas.drawRect(Rect.fromLTWH(vx + vw * 0.7, vy - vh * 2.1, vw * 0.22, vh * 1.1),
        Paint()..color = const Color(0xFFDCC39A));

    hill(0.90, 0.04, 1, const Color(0xFF5E6639));
  }

  @override
  bool shouldRepaint(covariant TuscanLandscapePainter old) => old.variant != variant || old.sunRise != sunRise;
}

/// Line-drawn villa + cypress sketch in walnut ink — the fallback for the
/// venue / story illustrations.
class InkSketchPainter extends CustomPainter {
  final bool venue;
  InkSketchPainter({this.venue = true});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p = Paint()
      ..color = AppColors.foreground.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Ground line with gentle hills
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.86)
        ..quadraticBezierTo(w * 0.25, h * 0.78, w * 0.5, h * 0.85)
        ..quadraticBezierTo(w * 0.75, h * 0.92, w, h * 0.82),
      p,
    );

    void cypress(double x, double base, double height) {
      canvas.drawPath(
        Path()
          ..moveTo(x, base)
          ..quadraticBezierTo(x - height * 0.13, base - height * 0.55, x, base - height)
          ..quadraticBezierTo(x + height * 0.13, base - height * 0.55, x, base),
        p,
      );
    }

    if (venue) {
      // Villa
      final vx = w * 0.36, vy = h * 0.84, vw = w * 0.32, vh = h * 0.28;
      canvas.drawRect(Rect.fromLTWH(vx, vy - vh, vw, vh), p);
      canvas.drawPath(
        Path()
          ..moveTo(vx - 6, vy - vh)
          ..lineTo(vx + vw / 2, vy - vh - h * 0.1)
          ..lineTo(vx + vw + 6, vy - vh),
        p,
      );
      // Tower
      final tx = vx + vw * 0.68, tw = vw * 0.2;
      canvas.drawRect(Rect.fromLTWH(tx, vy - vh - h * 0.2, tw, h * 0.2), p);
      canvas.drawLine(Offset(tx - 3, vy - vh - h * 0.2), Offset(tx + tw + 3, vy - vh - h * 0.2), p);
      // Windows + door
      for (var i = 0; i < 3; i++) {
        final wx = vx + vw * (0.14 + i * 0.28);
        canvas.drawRRect(
            RRect.fromRectAndCorners(Rect.fromLTWH(wx, vy - vh * 0.78, vw * 0.12, vh * 0.24),
                topLeft: const Radius.circular(6), topRight: const Radius.circular(6)),
            p);
      }
      canvas.drawRRect(
          RRect.fromRectAndCorners(Rect.fromLTWH(vx + vw * 0.42, vy - vh * 0.38, vw * 0.16, vh * 0.38),
              topLeft: const Radius.circular(10), topRight: const Radius.circular(10)),
          p);
      cypress(w * 0.18, h * 0.84, h * 0.5);
      cypress(w * 0.26, h * 0.83, h * 0.38);
      cypress(w * 0.8, h * 0.86, h * 0.46);
      cypress(w * 0.88, h * 0.85, h * 0.34);
    } else {
      // Olive branch for the story vignette
      final stem = Path()
        ..moveTo(w * 0.1, h * 0.7)
        ..quadraticBezierTo(w * 0.5, h * 0.3, w * 0.9, h * 0.35);
      canvas.drawPath(stem, p);
      for (var i = 1; i <= 7; i++) {
        final t = i / 8;
        final x = w * (0.1 + 0.8 * t);
        final y = h * (0.7 - 0.38 * t + 0.08 * t * t);
        for (final d in [-1.0, 1.0]) {
          canvas.drawPath(
            Path()
              ..moveTo(x, y)
              ..quadraticBezierTo(x + 10, y + d * 14, x + 22, y + d * 10)
              ..quadraticBezierTo(x + 10, y + d * 4, x, y),
            p,
          );
        }
      }
      final fill = Paint()..color = AppColors.olive.withValues(alpha: 0.8);
      canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.42, h * 0.62), width: 9, height: 12), fill);
      canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.66, h * 0.52), width: 9, height: 12), fill);
    }
  }

  @override
  bool shouldRepaint(covariant InkSketchPainter old) => old.venue != venue;
}
