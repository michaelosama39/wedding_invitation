import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wedding_invitation/data/wedding_data.dart';
import 'package:wedding_invitation/l10n/l10n.dart';
import 'package:wedding_invitation/theme.dart';
import 'package:wedding_invitation/data/common.dart';

class LocationSection extends StatelessWidget {
  const LocationSection({super.key});

  Future<void> _openMaps() async {
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': WeddingData.mapsQuery,
    });
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final narrow = context.isNarrow;
    return SectionShell(
      doubleRules: true,
      child: Reveal(
        child: Column(
          children: [
            Text(
              S.location(context),
              textAlign: TextAlign.center,
              style: AppText.script(
                context.responsive(48.0, 72.0, tablet: 64.0),
              ),
            ),
            SizedBox(height: narrow ? 12 : 16),
            Text(
              WeddingData.locationName(context),
              textAlign: TextAlign.center,
              style: AppText.display(narrow ? 26 : 32, weight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              '${WeddingData.locationCity(context)}\n'
                      '${WeddingData.locationCountry(context)}'
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
            // Live, interactive Google Map.
            _MapCard(onTap: _openMaps),
            const SizedBox(height: 32),
            PillButton(
              label: S.getDirections(context),
              icon: Icons.near_me_outlined,
              onPressed: _openMaps,
            ),
          ],
        ),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  final VoidCallback onTap;
  const _MapCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.responsive(220.0, 360.0, tablet: 300.0),
      width: double.infinity,
      decoration: BoxDecoration(border: Border.all(color: AppColors.ink(0.1))),
      child: _GoogleMapEmbed(query: WeddingData.mapsQuery, onTap: onTap),
    );
  }
}

class _GoogleMapEmbed extends StatelessWidget {
  final String query;
  final VoidCallback onTap;
  const _GoogleMapEmbed({required this.query, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: TuscanLandscapePainter(variant: 0.35),
        child: const SizedBox.expand(),
      ),
    );
  }
}
