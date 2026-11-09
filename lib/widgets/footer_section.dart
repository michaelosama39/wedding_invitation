import 'package:flutter/material.dart';
import '../data/wedding_data.dart';
import '../theme.dart';
import '../data/common.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionShell(
      padding: EdgeInsets.fromLTRB(20, context.isNarrow ? 48 : 64, 20, 80),
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
          FitDown(
            child: Text(
              '${WeddingData.groomName} & ${WeddingData.brideName}',
              style: AppText.script(context.isNarrow ? 40 : 48),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            WeddingData.dateLabel.toUpperCase(),
            style: AppText.label(13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'With all my love',
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
