import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/wedding_data.dart';
import '../theme.dart';
import 'common.dart';

// ---------------------------------------------------------------- Hero

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
      height: size.height.clamp(560.0, 1100.0),
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
          const ColoredBox(color: Color(0x40000000)),
          FadeTransition(
            opacity: textIn,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(textIn),
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, size.height * 0.12, 24, 24),
                child: Column(
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
                        WeddingData.brideName,
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
                        WeddingData.groomName,
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
                        side: const BorderSide(color: Colors.white70),
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
                    const Spacer(),
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

// ---------------------------------------------------------------- Countdown

class CountdownSection extends StatefulWidget {
  const CountdownSection({super.key});

  @override
  State<CountdownSection> createState() => _CountdownSectionState();
}

class _CountdownSectionState extends State<CountdownSection> {
  late Timer _timer;
  Duration _left = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final d = WeddingData.weddingDate.difference(DateTime.now());
    setState(() => _left = d.isNegative ? Duration.zero : d);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;
    final units = [
      (_left.inDays, 'DAYS'),
      (_left.inHours % 24, 'HOURS'),
      (_left.inMinutes % 60, 'MINS'),
      (_left.inSeconds % 60, 'SECS'),
    ];
    final cells = <Widget>[];
    for (var i = 0; i < units.length; i++) {
      if (i > 0) cells.add(const _CountdownDivider());
      final (value, label) = units[i];
      cells.add(
        Expanded(
          child: Column(
            children: [
              Text(
                value.toString().padLeft(2, '0'),
                style: AppText.display(narrow ? 40 : 64),
              ),
              SizedBox(height: narrow ? 8 : 12),
              Text(
                label,
                style: AppText.label(
                  narrow ? 10 : 12,
                  spacing: narrow ? 2.2 : 3.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SectionShell(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: narrow ? 80 : 112,
      ),
      child: Reveal(
        child: Column(
          children: [
            Text('Counting the days', style: AppText.script(narrow ? 40 : 60)),
            const SizedBox(height: 28),
            DoubleRuleBox(
              color: AppColors.gold.withValues(alpha: 0.55),
              padding: EdgeInsets.symmetric(
                vertical: narrow ? 20 : 32,
                horizontal: 4,
              ),
              child: IntrinsicHeight(child: Row(children: cells)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownDivider extends StatelessWidget {
  const _CountdownDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Icon(
            Icons.spa_outlined,
            size: 14,
            color: AppColors.gold.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Container(
              width: 1,
              color: AppColors.gold.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- Welcome

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;
    return SectionShell(
      child: Reveal(
        child: Column(
          children: [
            SizedBox(
              width: narrow ? 176 : 224,
              height: narrow ? 120 : 150,
              child: AssetOr(
                WeddingAssets.story,
                fallback: CustomPaint(painter: InkSketchPainter(venue: false)),
              ),
            ),
            const SizedBox(height: 24),
            SectionTitle(title: WeddingData.welcomeTitle, size: 60),
            Text(
              WeddingData.story,
              textAlign: TextAlign.center,
              style: AppText.body(
                narrow ? 17 : 19,
                color: AppColors.ink(0.8),
                weight: FontWeight.w300,
                height: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Gallery

class GallerySection extends StatelessWidget {
  const GallerySection({super.key});

  @override
  Widget build(BuildContext context) {
    final images = WeddingData.galleryImages;
    return SectionShell(
      maxWidth: 960,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 96),
      child: Column(
        children: [
          const Reveal(child: SectionTitle(title: 'Gallery', ornament: false)),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth > 640 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: images.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, i) => Reveal(
                  delay: Duration(milliseconds: 80 * (i % cols)),
                  child: _GalleryTile(index: i, path: images[i]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  final int index;
  final String path;
  const _GalleryTile({required this.index, required this.path});

  @override
  Widget build(BuildContext context) {
    Widget image() => AssetOr(
      path,
      fit: BoxFit.cover,
      fallback: CustomPaint(
        painter: TuscanLandscapePainter(variant: (index * 0.19) % 1),
      ),
    );
    return MouseRegion(
      cursor: SystemMouseCursors.zoomIn,
      child: GestureDetector(
        onTap: () => showDialog(
          context: context,
          barrierColor: Colors.black87,
          builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(24),
            child: AspectRatio(aspectRatio: 0.78, child: image()),
          ),
        ),
        child: SizedBox.expand(child: image()),
      ),
    );
  }
}

// ---------------------------------------------------------------- Itinerary

class ItinerarySection extends StatelessWidget {
  const ItinerarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionShell(
      child: Column(
        children: [
          const Reveal(child: SectionTitle(title: 'The Day', size: 60)),
          for (var i = 0; i < WeddingData.schedule.length; i++)
            Reveal(
              delay: Duration(milliseconds: 60 * i),
              child: _ItineraryRow(
                item: WeddingData.schedule[i],
                last: i == WeddingData.schedule.length - 1,
              ),
            ),
        ],
      ),
    );
  }
}

class _ItineraryRow extends StatelessWidget {
  final ScheduleItem item;
  final bool last;
  const _ItineraryRow({required this.item, required this.last});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 28, color: AppColors.mauve),
            const SizedBox(width: 8),
            Text(item.time, style: AppText.label(20, spacing: 3)),
          ],
        ),
        Text(
          item.subtitle,
          textAlign: TextAlign.center,
          style: AppText.body(
            20,
            color: AppColors.ink(0.75),
            style: FontStyle.italic,
          ),
        ),
        if (!last)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 18),
            width: 1,
            height: 36,
            color: AppColors.gold.withValues(alpha: 0.55),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Venue

class VenueSection extends StatelessWidget {
  const VenueSection({super.key});

  Future<void> _openMaps() async {
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': WeddingData.mapsQuery,
    });
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;
    return SectionShell(
      doubleRules: true,
      child: Reveal(
        child: Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 512),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: AssetOr(
                  WeddingAssets.venue,
                  fallback: CustomPaint(painter: InkSketchPainter()),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('The Venue', style: AppText.script(narrow ? 56 : 72)),
            const SizedBox(height: 16),
            Text(
              WeddingData.venueName,
              textAlign: TextAlign.center,
              style: AppText.display(32, weight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              '${WeddingData.venueCity}\n${WeddingData.venueCountry}'
                  .toUpperCase(),
              textAlign: TextAlign.center,
              style: AppText.label(
                14,
                color: AppColors.ink(0.7),
                spacing: 2.8,
                weight: FontWeight.w300,
              ).copyWith(height: 2),
            ),
            const SizedBox(height: 32),
            // Map preview card (greyscale until hovered, like the original).
            _MapCard(onTap: _openMaps),
            const SizedBox(height: 32),
            PillButton(
              label: 'Get directions',
              icon: Icons.near_me_outlined,
              onPressed: _openMaps,
            ),
          ],
        ),
      ),
    );
  }
}

class _MapCard extends StatefulWidget {
  final VoidCallback onTap;
  const _MapCard({required this.onTap});

  @override
  State<_MapCard> createState() => _MapCardState();
}

class _MapCardState extends State<_MapCard> {
  bool _hover = false;

  static const _greyscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;
    Widget map = CustomPaint(
      painter: TuscanLandscapePainter(variant: 0.35),
      child: const SizedBox.expand(),
    );
    if (!_hover) {
      map = ColorFiltered(
        colorFilter: _greyscale,
        child: Opacity(opacity: 0.8, child: map),
      );
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: narrow ? 256 : 320,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.ink(0.1)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              map,
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: const [
                      BoxShadow(color: Color(0x22000000), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.place,
                        color: AppColors.roseDark,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        WeddingData.venueName,
                        style: AppText.body(15, height: 1.2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Dress code

// class DressCodeSection extends StatelessWidget {
//   const DressCodeSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: LinenTexturePainter(),
//       child: SectionShell(
//         maxWidth: 576,
//         decoration: const BoxDecoration(),
//         child: Reveal(
//           child: Column(
//             children: [
//               Text(WeddingData.dressCodeSubheading.toUpperCase(), style: AppText.label(12, color: AppColors.ink(0.6))),
//               const SizedBox(height: 16),
//               Text(WeddingData.dressCodeHeading, style: AppText.script(52)),
//               const SizedBox(height: 24),
//               ConstrainedBox(
//                 constraints: const BoxConstraints(maxWidth: 320),
//                 child: AspectRatio(
//                   aspectRatio: 1.4,
//                   child: AssetOr(WeddingAssets.dressCode, fallback: const _DressCodeSketch()),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Text(WeddingData.dressCodeText, textAlign: TextAlign.center, style: AppText.body(18)),
//               const SizedBox(height: 16),
//               Text(WeddingData.dressCodeNote,
//                   textAlign: TextAlign.center, style: AppText.body(15, color: AppColors.ink(0.7), style: FontStyle.italic)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class _DressCodeSketch extends StatelessWidget {
  const _DressCodeSketch();

  @override
  Widget build(BuildContext context) {
    // Palette swatches suggesting the colours to wear.
    const swatches = [
      Color(0xFFFBE3E8),
      Color(0xFFF2C4CE),
      Color(0xFFE3A6B4),
      Color(0xFFD9B8A3),
      Color(0xFFB98A99),
    ];
    return Center(
      child: Wrap(
        spacing: 12,
        children: [
          for (final c in swatches)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- Gifts

// class GiftsSection extends StatelessWidget {
//   const GiftsSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SectionShell(
//       maxWidth: 576,
//       child: Reveal(
//         child: Column(
//           children: [
//             Text(WeddingData.giftsSubheading.toUpperCase(), style: AppText.label(12, color: AppColors.ink(0.6))),
//             const SizedBox(height: 16),
//             Text(WeddingData.giftsHeading, style: AppText.script(52)),
//             const SizedBox(height: 16),
//             const GoldOrnament(),
//             const SizedBox(height: 24),
//             Text(WeddingData.giftsText, textAlign: TextAlign.center, style: AppText.body(18)),
//             const SizedBox(height: 24),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//               decoration: BoxDecoration(border: Border.all(color: AppColors.gold.withValues(alpha: 0.5))),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Flexible(
//                     child: SelectableText(WeddingData.bankDetails,
//                         textAlign: TextAlign.center, style: AppText.body(15, height: 1.3)),
//                   ),
//                   IconButton(
//                     tooltip: 'Copy',
//                     icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.mauve),
//                     onPressed: () {
//                       Clipboard.setData(const ClipboardData(text: WeddingData.bankDetails));
//                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ---------------------------------------------------------------- Leave a message

class WishesController extends ValueNotifier<List<Wish>> {
  WishesController() : super(List.of(WeddingData.initialWishes));

  void add(Wish wish) => value = [wish, ...value];
}

class RsvpSection extends StatefulWidget {
  final WishesController wishes;
  const RsvpSection({super.key, required this.wishes});

  @override
  State<RsvpSection> createState() => _RsvpSectionState();
}

class _RsvpSectionState extends State<RsvpSection> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _message = TextEditingController();
  bool _sent = false;
  String _sentName = '';

  @override
  void dispose() {
    _name.dispose();
    _message.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    // TODO: send the message to your backend (Firebase, Google Sheets, email, etc.).
    widget.wishes.add(Wish(_name.text.trim(), _message.text.trim()));
    setState(() {
      _sentName = _name.text.trim();
      _sent = true;
    });
    _message.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SectionShell(
      doubleRules: true,
      maxWidth: 520,
      child: Reveal(
        child: Column(
          children: [
            const SectionTitle(eyebrow: 'Say something sweet', title: 'Leave a Message'),
            Text(
              'Share your wishes and love for the couple',
              textAlign: TextAlign.center,
              style: AppText.body(
                18,
                color: AppColors.ink(0.75),
                style: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 32),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _sent ? _thanks() : _formBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thanks() => Column(
    key: const ValueKey('thanks'),
    children: [
      Text('Thank you, $_sentName', textAlign: TextAlign.center, style: AppText.script(44)),
      const SizedBox(height: 8),
      Text(
        'Your message means the world to us.',
        textAlign: TextAlign.center,
        style: AppText.body(19),
      ),
      const SizedBox(height: 24),
      PillButton(
        label: 'Write another',
        onPressed: () => setState(() => _sent = false),
      ),
    ],
  );

  Widget _formBody() => Form(
    key: _form,
    child: Column(
      key: const ValueKey('form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _name,
          style: AppText.body(17, height: 1.3),
          decoration: const InputDecoration(labelText: 'Your name'),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _message,
          maxLines: 4,
          maxLength: 300,
          style: AppText.body(17, height: 1.4),
          decoration: const InputDecoration(labelText: 'Your message'),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Please write a message' : null,
        ),
        const SizedBox(height: 20),
        Center(
          child: PillButton(
            label: 'Send Message',
            filled: true,
            onPressed: _submit,
          ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------- Wishes

class WishesSection extends StatelessWidget {
  final WishesController wishes;
  const WishesSection({super.key, required this.wishes});

  @override
  Widget build(BuildContext context) {
    return SectionShell(
      child: Column(
        children: [
          const Reveal(
            child: SectionTitle(eyebrow: 'From our guests', title: 'Wishes'),
          ),
          ValueListenableBuilder<List<Wish>>(
            valueListenable: wishes,
            builder: (_, list, _) => Column(
              children: [
                for (final w in list)
                  Padding(
                    key: ValueKey(w),
                    padding: const EdgeInsets.only(bottom: 28),
                    child: Column(
                      children: [
                        Text(
                          '“${w.message}”',
                          textAlign: TextAlign.center,
                          style: AppText.body(
                            19,
                            color: AppColors.ink(0.85),
                            style: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '— ${w.name.toUpperCase()}',
                          style: AppText.label(12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- Footer

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionShell(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 80),
      child: Column(
        children: [
          SizedBox(
            width: 220,
            height: 60,
            child: AssetOr(
              WeddingAssets.footer,
              fallback: const Center(child: GoldOrnament(width: 200)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${WeddingData.brideName} & ${WeddingData.groomName}',
            style: AppText.script(48),
          ),
          const SizedBox(height: 8),
          Text(WeddingData.dateLabel.toUpperCase(), style: AppText.label(13)),
          const SizedBox(height: 4),
          Text(
            'Con amore',
            style: AppText.body(
              17,
              color: AppColors.ink(0.7),
              style: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
