import 'package:flutter/material.dart';
import 'package:wedding_invitation/data/wedding_data.dart';
import 'package:wedding_invitation/theme.dart';
import 'package:wedding_invitation/data/common.dart';

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
    final narrow = context.isNarrow;
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: narrow ? 24 : 28, color: AppColors.mauve),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                item.time,
                textAlign: TextAlign.center,
                style: AppText.label(
                  narrow ? 17 : 20,
                  spacing: narrow ? 2.2 : 3,
                ),
              ),
            ),
          ],
        ),
        Text(
          item.subtitle,
          textAlign: TextAlign.center,
          style: AppText.body(
            narrow ? 18 : 20,
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
