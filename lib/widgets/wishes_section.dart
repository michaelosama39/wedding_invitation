import 'package:flutter/material.dart';
import 'package:wedding_invitation/widgets/rsvp_section.dart';
import '../data/wedding_data.dart';
import '../theme.dart';
import '../data/common.dart';

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
            builder: (_, list, _) => list.isEmpty
                ? _emptyState(context)
                : Column(
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
                                  context.isNarrow ? 17 : 19,
                                  color: AppColors.ink(0.85),
                                  style: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '— ${w.name.isEmpty ? 'A GUEST' : w.name.toUpperCase()}',
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

  Widget _emptyState(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      children: [
        Icon(
          Icons.favorite_border_rounded,
          size: context.isNarrow ? 44 : 52,
          color: AppColors.roseDark,
        ),
        const SizedBox(height: 16),
        Text(
          'No wishes yet',
          textAlign: TextAlign.center,
          style: AppText.script(context.isNarrow ? 30 : 36),
        ),
        const SizedBox(height: 6),
        Text(
          'Be the first to leave a message for the couple.',
          textAlign: TextAlign.center,
          style: AppText.body(
            context.isNarrow ? 17 : 19,
            color: AppColors.ink(0.75),
            style: FontStyle.italic,
          ),
        ),
      ],
    ),
  );
}
