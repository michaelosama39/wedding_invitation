import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/wedding_data.dart';
import '../theme.dart';

/// Sealed rose envelope. Tapping the wax seal breaks it, lifts the
/// flap, slides the card out and then calls [onOpened].
class EnvelopeScreen extends StatefulWidget {
  final VoidCallback onOpened;
  const EnvelopeScreen({super.key, required this.onOpened});

  @override
  State<EnvelopeScreen> createState() => _EnvelopeScreenState();
}

class _EnvelopeScreenState extends State<EnvelopeScreen> with TickerProviderStateMixin {
  late final AnimationController _open =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2800));
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);

  late final Animation<double> _seal =
      CurvedAnimation(parent: _open, curve: const Interval(0.0, 0.18, curve: Curves.easeIn));
  late final Animation<double> _flap =
      CurvedAnimation(parent: _open, curve: const Interval(0.12, 0.45, curve: Curves.easeInOut));
  late final Animation<double> _card =
      CurvedAnimation(parent: _open, curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic));
  late final Animation<double> _fade =
      CurvedAnimation(parent: _open, curve: const Interval(0.85, 1.0, curve: Curves.easeIn));

  @override
  void initState() {
    super.initState();
    _open.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onOpened();
    });
  }

  @override
  void dispose() {
    _open.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _tap() {
    if (_open.isAnimating || _open.isCompleted) return;
    _pulse.stop();
    _open.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 1.2,
            colors: [AppColors.background, AppColors.parchment, Color(0xFFEFC9D2)],
            stops: [0, 0.6, 1],
          ),
        ),
        child: LayoutBuilder(builder: (context, c) {
          // Fit both width and height: the column needs ~230px of text plus
          // the envelope (h) and the room the card slides into (0.55h).
          final byHeight = math.max(120.0, (c.maxHeight - 250) / (0.66 * 1.55));
          final w = math.min(math.min(c.maxWidth * 0.86, 560.0), byHeight);
          final h = w * 0.66;
          return AnimatedBuilder(
            animation: Listenable.merge([_open, _pulse]),
            builder: (context, _) {
              final flapAngle = _flap.value * math.pi;
              final flapBehind = flapAngle > math.pi / 2;
              return Opacity(
                opacity: 1 - _fade.value,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('You are invited', style: AppText.label(14, color: AppColors.mauve, spacing: 6)),
                      const SizedBox(height: 8),
                      Text('${WeddingData.brideName} & ${WeddingData.groomName}',
                          style: AppText.script(52)),
                      SizedBox(height: 40 + h * 0.55),
                      SizedBox(
                        width: w,
                        height: h,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Back of envelope
                            Positioned.fill(child: CustomPaint(painter: _EnvelopeBackPainter())),
                            if (flapBehind) _buildFlap(w, h, flapAngle),
                            // Card sliding out
                            Positioned(
                              left: w * 0.06,
                              right: w * 0.06,
                              top: h * 0.08 - _card.value * h * 0.62,
                              height: h * 0.86,
                              child: _InnerCard(),
                            ),
                            // Front pocket
                            Positioned.fill(child: CustomPaint(painter: _EnvelopeFrontPainter())),
                            if (!flapBehind) _buildFlap(w, h, flapAngle),
                            // Wax seal
                            Positioned(
                              left: w / 2 - 40,
                              top: h * 0.5 - 40,
                              child: Opacity(
                                opacity: 1 - _seal.value,
                                child: Transform.scale(
                                  scale: (1 + _pulse.value * 0.05) * (1 + _seal.value * 0.4),
                                  child: GestureDetector(
                                    onTap: _tap,
                                    child: MouseRegion(cursor: SystemMouseCursors.click, child: const _WaxSeal()),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),
                      Opacity(
                        opacity: (1 - _seal.value * 3).clamp(0, 1),
                        child: Column(children: [
                          Icon(Icons.touch_app_outlined, color: AppColors.roseDark),
                          const SizedBox(height: 6),
                          Text('Tap the seal to open', style: AppText.body(18, style: FontStyle.italic)),
                        ]),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildFlap(double w, double h, double angle) {
    return Positioned(
      left: 0,
      top: 0,
      width: w,
      height: h * 0.58,
      child: Transform(
        alignment: Alignment.topCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0012)
          ..rotateX(-angle),
        child: CustomPaint(painter: _FlapPainter(inside: angle > math.pi / 2)),
      ),
    );
  }
}

class _InnerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.gold, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8)],
      ),
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: AppColors.gold.withValues(alpha: 0.5))),
        alignment: Alignment.center,
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text('SAVE THE DATE', style: AppText.label(12, color: AppColors.gold, spacing: 4)),
                Text(WeddingData.monogram, style: AppText.script(40, color: AppColors.foreground)),
                Text(WeddingData.dateLabel, style: AppText.body(14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WaxSeal extends StatelessWidget {
  const _WaxSeal();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [Color(0xFFF1D3BC), AppColors.gold, Color(0xFF9C6F55)],
          stops: [0, 0.55, 1],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF8A5E48).withValues(alpha: 0.6), width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(WeddingData.monogram, style: AppText.script(24, color: const Color(0xFF6B4334))),
      ),
    );
  }
}

const _envelopeColor = AppColors.rose;
const _envelopeShade = AppColors.roseDark;

class _EnvelopeBackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(4));
    canvas.drawShadow(Path()..addRRect(r), Colors.black, 12, false);
    canvas.drawRRect(r, Paint()..color = _envelopeShade);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EnvelopeFrontPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Side flaps
    final sides = Paint()..color = Color.lerp(_envelopeColor, _envelopeShade, 0.25)!;
    canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..lineTo(w * 0.52, h * 0.55)
          ..lineTo(0, h)
          ..close(),
        sides);
    canvas.drawPath(
        Path()
          ..moveTo(w, 0)
          ..lineTo(w * 0.48, h * 0.55)
          ..lineTo(w, h)
          ..close(),
        sides);
    // Bottom pocket
    final bottom = Path()
      ..moveTo(0, h)
      ..lineTo(w / 2, h * 0.45)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(bottom, Paint()..color = _envelopeColor);
    // Gold edge lines
    final line = Paint()
      ..color = AppColors.goldLight.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(bottom, line);
    canvas.drawRRect(
        RRect.fromRectAndRadius((Offset.zero & size).deflate(0.5), const Radius.circular(4)), line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FlapPainter extends CustomPainter {
  final bool inside;
  _FlapPainter({required this.inside});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: inside
              ? [_envelopeShade, Color.lerp(_envelopeShade, Colors.black, 0.15)!]
              : [Color.lerp(_envelopeColor, Colors.white, 0.08)!, _envelopeColor],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.goldLight.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _FlapPainter old) => old.inside != inside;
}
