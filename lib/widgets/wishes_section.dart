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