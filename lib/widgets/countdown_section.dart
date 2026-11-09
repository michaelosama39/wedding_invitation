import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wedding_invitation/data/wedding_data.dart';
import 'package:wedding_invitation/theme.dart';
import 'package:wedding_invitation/data/common.dart';

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
    final narrow = context.isNarrow;
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
              FitDown(
                child: Text(
                  value.toString().padLeft(2, '0'),
                  style: AppText.display(
                    context.responsive(40.0, 64.0, tablet: 56.0),
                  ),
                ),
              ),
              SizedBox(height: narrow ? 8 : 12),
              FitDown(
                child: Text(
                  label,
                  style: AppText.label(
                    narrow ? 10 : 12,
                    spacing: narrow ? 2.2 : 3.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SectionShell(
      padding: EdgeInsets.symmetric(
        horizontal: narrow ? 12 : 20,
        vertical: context.responsive(72.0, 112.0, tablet: 96.0),
      ),
      child: Reveal(
        child: Column(
          children: [
            Text(
              'Counting the days',
              textAlign: TextAlign.center,
              style: AppText.script(
                context.responsive(40.0, 60.0, tablet: 52.0),
              ),
            ),
            SizedBox(height: narrow ? 20 : 28),
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
      padding: EdgeInsets.symmetric(horizontal: context.isNarrow ? 2 : 6),
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
