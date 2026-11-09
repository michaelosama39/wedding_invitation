import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wedding_invitation/theme.dart';
import 'package:wedding_invitation/data/common.dart';
import 'package:carousel_slider/carousel_slider.dart';

class GallerySection extends StatefulWidget {
  const GallerySection({super.key});

  @override
  State<GallerySection> createState() => _GallerySectionState();
}

class _GallerySectionState extends State<GallerySection> {
  final _carousel = CarouselSliderController();
  List<String> _images = const [];
  bool _loaded = false;
  bool _autoPlay = true;
  int _page = 0;

  int get _count =>
      _images.isEmpty ? 3 : _images.length; // 3 painted placeholders

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    List<String> found = const [];
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      found =
          manifest
              .listAssets()
              .where((p) => p.startsWith('assets/images/gallery'))
              .where(
                (p) => RegExp(
                  r'\.(jpe?g|png|webp|gif)$',
                  caseSensitive: false,
                ).hasMatch(p),
              )
              .toList()
            ..sort(_naturalCompare);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _images = found;
      _loaded = true;
    });
  }

  /// Sorts gallery_2 before gallery_10.
  static int _naturalCompare(String a, String b) {
    int n(String s) =>
        int.tryParse(RegExp(r'(\d+)(?!.*\d)').firstMatch(s)?.group(1) ?? '') ??
        0;
    final c = n(a).compareTo(n(b));
    return c != 0 ? c : a.compareTo(b);
  }

  Widget _image(int i, BoxFit fit) {
    final placeholder = CustomPaint(
      painter: TuscanLandscapePainter(variant: (i * 0.31) % 1),
    );
    return _images.isEmpty
        ? placeholder
        : AssetOr(_images[i], fit: fit, fallback: placeholder);
  }

  Future<void> _open(int i) async {
    setState(() => _autoPlay = false);
    await showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.of(ctx).pop(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(context.isNarrow ? 8 : 24),
          child: InteractiveViewer(child: _image(i, BoxFit.contain)),
        ),
      ),
    );
    if (mounted) setState(() => _autoPlay = true);
  }

  @override
  Widget build(BuildContext context) {
    final multiple = _count > 1;
    return SectionShell(
      maxWidth: 960,
      padding: EdgeInsets.symmetric(
        vertical: context.responsive(64.0, 96.0, tablet: 80.0),
      ),
      child: Column(
        children: [
          const Reveal(child: SectionTitle(title: 'Gallery', ornament: false)),
          if (!_loaded)
            const SizedBox(height: 420)
          else
            Reveal(
              child: LayoutBuilder(
                builder: (context, c) {
                  // Never taller than ~80% of the viewport (landscape phones).
                  final maxH = (context.screenSize.height * 0.8).clamp(
                    260.0,
                    560.0,
                  );
                  final height = (c.maxWidth * 1.15).clamp(260.0, maxH);
                  final fraction = ((height * 0.78) / c.maxWidth).clamp(
                    0.4,
                    0.82,
                  );
                  final wide = c.maxWidth > 640;
                  return Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CarouselSlider.builder(
                            carouselController: _carousel,
                            itemCount: _count,
                            itemBuilder: (context, i, _) => MouseRegion(
                              cursor: SystemMouseCursors.zoomIn,
                              child: GestureDetector(
                                onTap: () => _open(i),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: ColoredBox(
                                    color: AppColors.parchment,
                                    child: SizedBox.expand(
                                      child: _image(i, BoxFit.cover),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            options: CarouselOptions(
                              height: height,
                              viewportFraction: fraction,
                              enlargeCenterPage: true,
                              enlargeFactor: 0.18,
                              enableInfiniteScroll: multiple,
                              autoPlay: multiple && _autoPlay,
                              autoPlayInterval: const Duration(seconds: 4),
                              autoPlayAnimationDuration: const Duration(
                                milliseconds: 800,
                              ),
                              autoPlayCurve: Curves.easeInOutCubic,
                              pauseAutoPlayOnTouch: true,
                              onPageChanged: (i, _) =>
                                  setState(() => _page = i),
                            ),
                          ),
                          if (wide && multiple) ...[
                            Positioned(
                              left: 12,
                              child: _ArrowButton(
                                icon: Icons.chevron_left,
                                onTap: _carousel.previousPage,
                              ),
                            ),
                            Positioned(
                              right: 12,
                              child: _ArrowButton(
                                icon: Icons.chevron_right,
                                onTap: _carousel.nextPage,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (multiple) ...[
                        const SizedBox(height: 20),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < _count; i++)
                              GestureDetector(
                                onTap: () => _carousel.animateToPage(i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: i == _page ? 22 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: i == _page
                                        ? AppColors.mauve
                                        : AppColors.ink(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.85),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: AppColors.foreground, size: 28),
        ),
      ),
    );
  }
}
