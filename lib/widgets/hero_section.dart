import 'package:flutter/material.dart';
import 'package:wedding_invitation/data/wedding_data.dart';
import 'package:wedding_invitation/theme.dart';
import 'package:wedding_invitation/data/common.dart';

class HeroSection extends StatefulWidget {
  final VoidCallback onRsvp;
  const HeroSection({super.key, required this.onRsvp});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final narrow = size.width < 600;
    final textIn = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.25, 1, curve: Curves.easeOut),
    );
    final bgZoom = Tween(
      begin: 1.08,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    const shadow = [Shadow(color: Color(0x66000000), blurRadius: 14)];

    return SizedBox(
      height: size.height.clamp(480.0, 1100.0),
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: ScaleTransition(
              scale: bgZoom,
              child: AssetOr(
                WeddingAssets.hero,
                fit: BoxFit.cover,
                fallback: AnimatedBuilder(
                  animation: _c,
                  builder: (_, _) => CustomPaint(
                    painter: TuscanLandscapePainter(
                      sunRise: Curves.easeOut.transform(_c.value),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // bg-black/25 scrim
          const ColoredBox(color: Color.fromARGB(144, 0, 0, 0)),
          FadeTransition(
            opacity: textIn,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(textIn),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  narrow ? 20 : 32,
                  (size.height * 0.08).clamp(24.0, 96.0),
                  narrow ? 20 : 32,
                  16,
                ),
                child: Column(
                  children: [
                    // The headline block scales down to fit short or narrow
                    // screens (e.g. phones in landscape) instead of overflowing.
                    Expanded(
                      child: Center(
                        child: FitDown(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: (size.width - (narrow ? 40 : 64)).clamp(
                                240.0,
                                900.0,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  WeddingData.heroIntro.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: AppText.label(
                                    narrow ? 12 : 14,
                                    color: Colors.white,
                                    spacing: 4.5,
                                    weight: FontWeight.w600,
                                  ).copyWith(shadows: shadow),
                                ),
                                const SizedBox(height: 18),
                                FittedBox(
                                  child: Text(
                                    WeddingData.groomName,
                                    style: AppText.script(
                                      narrow ? 72 : 112,
                                      color: Colors.white,
                                    ).copyWith(shadows: shadow),
                                  ),
                                ),
                                Text(
                                  '&',
                                  style: AppText.script(
                                    narrow ? 40 : 56,
                                    color: Colors.white,
                                  ).copyWith(shadows: shadow),
                                ),
                                FittedBox(
                                  child: Text(
                                    WeddingData.brideName,
                                    style: AppText.script(
                                      narrow ? 72 : 112,
                                      color: Colors.white,
                                    ).copyWith(shadows: shadow),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  WeddingData.heroByline,
                                  textAlign: TextAlign.center,
                                  style: AppText.body(
                                    narrow ? 18 : 22,
                                    color: Colors.white,
                                    style: FontStyle.italic,
                                  ).copyWith(shadows: shadow),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  WeddingData.dateLabel.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: AppText.label(
                                    narrow ? 16 : 22,
                                    color: Colors.white,
                                    spacing: 3,
                                    weight: FontWeight.w700,
                                  ).copyWith(shadows: shadow),
                                ),
                                const SizedBox(height: 28),
                                OutlinedButton(
                                  onPressed: widget.onRsvp,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                      color: Colors.white70,
                                    ),
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 28,
                                      vertical: 14,
                                    ),
                                  ),
                                  child: Text(
                                    'LEAVE A MESSAGE',
                                    style: AppText.label(
                                      13,
                                      color: Colors.white,
                                      spacing: 4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _ScrollHint(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrollHint extends StatefulWidget {
  const _ScrollHint();

  @override
  State<_ScrollHint> createState() => _ScrollHintState();
}

class _ScrollHintState extends State<_ScrollHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) =>
          Transform.translate(offset: Offset(0, _c.value * 8), child: child),
      child: Column(
        children: [
          Text(
            'SCROLL',
            style: AppText.label(11, color: Colors.white70, spacing: 4),
          ),
          const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white70,
            size: 26,
          ),
        ],
      ),
    );
  }
}
